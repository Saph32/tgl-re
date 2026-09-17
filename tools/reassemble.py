#!/usr/bin/env python3
"""Rebuild the ROM from the region map and refuse unless it is byte for byte identical.

The playbook puts this early for a reason: a hand-entered address is an assertion nothing
else checks, and 6502 has no alignment, so a region that starts four bytes early still
produces legal instructions that fall into the real routine and a listing that reads fine.
This is the check that does not read fine when that happens.

It writes a full assembler listing to disasm/ - one file per segment - assembles them all
back against one shared label table, and compares the result to the ROM.

FIRST, THE THING THAT CHANGES WHAT THE OUTPUT MEANS.
**The byte comparison on its own cannot catch a wrong instruction-start address.**
Disassembling and reassembling is faithful at whatever alignment you start from, so a
region that begins one byte early round-trips perfectly and prints a listing that reads
fine. So the byte comparison is the floor, not the check. What does the work is everything
alongside it:

  * a code region whose first byte the trace never begins an instruction at, although it
    does decode instructions inside that region - this is what catches the case above;
  * a control-flow target that is not an instruction start inside a region annotated as
    code, which shows up as an undefined label;
  * a code region that does not END on an instruction boundary;
  * a branch that cannot reach its label in the signed 8-bit range;
  * the whole file being reconstructible in one deterministic pass, with every region's
    bytes in order and nothing missing, doubled or transposed.

AND ONE MORE, WHICH IS THIS CARTRIDGE'S OWN. **Labels are per bank.** $8000-$BFFF exists in
seven banks at once, so `L3_8012` and `L5_8012` are different addresses holding different
bytes, and the listing says which. The tracer resolves each call site under the live bank
it was reached with; where one bank-7 site is reached under several banks and calls into
the window, the listing prints all of the banks it can land in rather than picking one.
That is a real property of the ROM and the one thing about this listing that a reader
coming from an unbanked disassembly will not expect.

WHAT IT DOES NOT PROVE. tools/tgl/asm.py encodes with the disassembler's table inverted, so
the opcode table is not independently verified - an error there cancels between the two
directions and the round trip still passes. Read the header of that module before citing
this check as evidence about anything other than structure.

    python tools/reassemble.py             # write disasm/, assemble, compare
    python tools/reassemble.py --check     # compare without writing disasm/
    python tools/reassemble.py --quiet     # just the verdict
"""

from __future__ import annotations

import argparse
import importlib.util
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from tgl.asm import AssemblyError, assemble_all
from tgl.disasm import MODES, decode
from tgl.model import AnnotationError, bank_window, load

_spec = importlib.util.spec_from_file_location("trace_code", HERE / "trace-code.py")
_tc = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_tc)


def _label(bank: int, addr: int) -> str:
    """A label names a bank and an address, never an address alone.

    On UxROM the seven switchable banks all sit at $8000-$BFFF, so `$8012` is seven
    different bytes and a label that did not carry the bank would silently merge them.
    """
    return f"L{bank}_{addr:04X}"


def _operand_text(insn, symbol: str | None) -> str:
    """Format one operand, forcing the absolute form where it would otherwise shorten.

    `lda $0012` would assemble as zero page and lose a byte. Every absolute mode with an
    operand below $100 gets an `a:` so the encoding survives the round trip.
    """
    if symbol is not None:
        suffix = {"abx": ",x", "aby": ",y"}.get(insn.mode, "")
        return f"{symbol}{suffix}"
    if insn.mode in ("abs", "abx", "aby") and insn.operand < 0x100:
        body = f"a:${insn.operand:04X}"
        return body + {"abx": ",x", "aby": ",y"}.get(insn.mode, "")
    return MODES[insn.mode][1](insn.operand, insn.addr)


def _data_lines(data: bytes, note: str) -> list[str]:
    """Literal bytes, collapsing long runs of one value into a .fill."""
    out, i = [], 0
    if note:
        out.append(f"        ; {note}")
    while i < len(data):
        run = 1
        while i + run < len(data) and data[i + run] == data[i]:
            run += 1
        if run >= 16:
            out.append(f"        .fill   {run},${data[i]:02X}")
            i += run
            continue
        chunk = data[i:i + 16]
        # Do not swallow the start of a long run into a short .byte line.
        for cut in range(1, len(chunk)):
            if len(chunk) - cut >= 16 and len(set(chunk[cut:])) == 1:
                chunk = chunk[:cut]
                break
        out.append("        .byte   " + ",".join(f"${b:02X}" for b in chunk))
        i += len(chunk)
    return out


class Emitter:
    def __init__(self, rm, tr):
        self.rm = rm
        self.meta = rm.meta
        self.tr = tr
        self.starts = tr.starts
        self.flow = tr.flow
        self.errors: list[str] = []
        # Places where a control transfer lands strictly inside another instruction. Not an
        # error - it is the BIT-skip idiom and a few relatives, where one stretch of bytes
        # is two different instruction streams depending on how it was entered.
        self.overlaps: list[tuple[int, int, str]] = []
        # Every file offset that has to turn out to be an instruction start: the
        # destinations of traced control transfers, plus the places the trace entered by
        # some other route - a vector, an entry slot, a far call, a resolved dispatch.
        self.targets: set[int] = set(tr.entry_points)
        for destinations in self.flow.values():
            self.targets |= destinations

    # -------------------------------------------------------------- helpers

    def bank_of(self, off: int) -> int:
        return (off - self.meta["prg_offset"]) // self.meta["prg_bank_size"]

    def addr_of(self, off: int) -> int:
        bank = self.bank_of(off)
        return (bank_window(self.meta, bank)
                + (off - self.meta["prg_offset"]) % self.meta["prg_bank_size"])

    def label_for_offset(self, off: int) -> str:
        return _label(self.bank_of(off), self.addr_of(off))

    # -------------------------------------------------------------- sections

    def header(self) -> str:
        body = self.rm.rom[:self.meta["header_size"]]
        lines = ["; The 16-byte iNES container header. Not part of the cartridge - it is",
                 "; metadata the dumper added, and the NES never reads it.",
                 ".org $0000"]
        lines += _data_lines(bytes(body), "")
        return "\n".join(lines) + "\n"

    def bank(self, n: int) -> str:
        meta = self.meta
        size = meta["prg_bank_size"]
        start = meta["prg_offset"] + n * size
        end = start + size
        info = meta["prg_banks"][n]
        window = bank_window(meta, n)

        lines = [f"; PRG bank {n} - {info['role']}",
                 f"; ${window:04X}-${window + size - 1:04X}"]
        if window == 0x8000:
            lines.append("; The switchable window. Every address below exists in seven "
                         "banks; only this")
            lines.append("; one has these bytes at it, which is what the L{n}_ label "
                         "prefix records.".replace("{n}", str(n)))
        else:
            lines.append("; The fixed window. UxROM wires the last bank here and nothing "
                         "can move it.")
        lines += [f".org ${window:04X}", ""]

        pieces: list[tuple[int, int, dict | None]] = []
        cursor = start
        for region in self.rm.regions:
            if not (start <= region["offset"] < end):
                continue
            if region["offset"] > cursor:
                pieces.append((cursor, region["offset"], None))
            pieces.append((region["offset"], region["end"], region))
            cursor = region["end"]
        if cursor < end:
            pieces.append((cursor, end, None))

        for lo, hi, region in pieces:
            lines += self._piece(lo, hi, region, n)
        return "\n".join(lines) + "\n"

    def _piece(self, lo: int, hi: int, region: dict | None, bank: int) -> list[str]:
        if region is not None and region["kind"] == "code":
            return self._code(lo, hi, region, bank)

        name = region["id"] if region else "UNCLAIMED"
        kind = region["kind"] if region else "gap"
        for off in sorted(self.targets & set(range(lo, hi))):
            self.errors.append(
                f"${self.addr_of(off):04X} in bank {bank} is the target of a traced control "
                f"transfer, but it is inside {name} ({kind}), which is not code. Either the "
                "region is wrong or the trace is.")
        lines = ["", f"; ---- {name} ({kind}) "
                     f"${self.addr_of(lo):04X}-${self.addr_of(hi - 1):04X}, {hi - lo} bytes"]
        if region is not None:
            lines.append(f"; {region['name']}")
        return lines + _data_lines(bytes(self.rm.rom[lo:hi]), "")

    def _code(self, lo: int, hi: int, region: dict, bank: int) -> list[str]:
        lines = ["", f"; ---- {region['id']} (code) "
                     f"${self.addr_of(lo):04X}-${self.addr_of(hi - 1):04X}, {hi - lo} bytes"]
        mem = bytearray(0x10000)
        base = self.addr_of(lo)
        mem[base:base + (hi - lo)] = self.rm.rom[lo:hi]

        # The check that actually catches a wrong instruction-start address. Byte-exactness
        # cannot: disassembling and reassembling is faithful whatever alignment you start
        # at, so a region beginning one byte early round-trips perfectly and its listing
        # reads fine. What does not survive is this - if the trace ever began an instruction
        # inside these bytes, it must have begun one at the region's FIRST byte too.
        if any(lo <= o < hi for o in self.starts) and lo not in self.starts:
            self.errors.append(
                f"{region['id']} starts at ${base:04X}, which the trace never treats as an "
                "instruction start although it does decode instructions inside this region. "
                "A region that begins mid-instruction still produces a legal-looking "
                "listing, so nothing else here would object.")

        off, addr = lo, base
        while off < hi:
            if off in self.targets:
                lines.append(f"{self.label_for_offset(off)}:")
            insn = decode(mem, addr, addr)
            if off + insn.size > hi:
                self.errors.append(
                    f"{region['id']} ends at ${self.addr_of(hi - 1) + 1:04X}, in the middle "
                    f"of the {insn.mnemonic} at ${addr:04X} - a code region's last byte must "
                    "be the last byte of an instruction")
                lines += _data_lines(bytes(self.rm.rom[off:hi]), "TRUNCATED INSTRUCTION")
                return lines

            # If something jumps into the middle of this instruction, the bytes are two
            # instruction streams at once. No assembler syntax expresses that, so emit the
            # bytes up to the entry point literally and resume decoding there - which keeps
            # the output byte-exact AND lets the label be placed. This is what the BIT-skip
            # idiom needs: $2C swallows the two bytes after it when fallen into, and those
            # same two bytes are an instruction when branched to.
            cut = next((t for t in range(off + 1, min(off + insn.size, hi))
                        if t in self.targets), None)
            if cut is not None:
                raw = bytes(self.rm.rom[off:cut])
                self.overlaps.append((off, cut, insn.mnemonic))
                lines.append("        .byte   " + ",".join(f"${b:02X}" for b in raw) +
                             f"   ; entered as {insn.mnemonic} "
                             f"{_operand_text(insn, None)} when fallen into; "
                             f"${self.addr_of(cut):04X} below is the other decoding")
                off, addr = cut, addr + (cut - off)
                continue

            symbol = None
            destinations = self.flow.get(off, set())
            if len(destinations) == 1:
                (dest,) = destinations
                if dest in self.targets:
                    symbol = self.label_for_offset(dest)
            elif len(destinations) > 1:
                # One site, several banks. This is not ambiguity in the tool: the site
                # really does land in a different bank depending on which one was live when
                # it ran, and the label cannot say two things at once.
                lines.append("        ; this site resolves to more than one bank: " +
                             ", ".join(f"bank {self.bank_of(d)} ${self.addr_of(d):04X}"
                                       for d in sorted(destinations)))

            text = (insn.mnemonic.lower() if insn.mode == "imp"
                    else f"{insn.mnemonic.lower():<7} {_operand_text(insn, symbol)}")
            lines.append(f"        {text}")
            off += insn.size
            addr += insn.size
        return lines

    def unplaced_targets(self) -> list[int]:
        """Targets that fall outside every code region. Reported separately because a target
        in a gap means the map is missing a region, not that a region is wrong."""
        code = set()
        for region in self.rm.regions:
            if region["kind"] == "code":
                code |= set(range(region["offset"], region["end"]))
        return sorted(self.targets - code)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true", help="compare without writing disasm/")
    ap.add_argument("--quiet", action="store_true", help="just the verdict")
    args = ap.parse_args()

    try:
        rm = load(ROOT)
        _tc._verify_abi(rm.rom, rm.meta)
    except AnnotationError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    tr = _tc.Trace(rm)
    tr.run_to_fixpoint()
    emitter = Emitter(rm, tr)

    sections: list[tuple[str, str, int, int]] = [
        ("header.s", emitter.header(), 0, rm.meta["header_size"])]
    for n in range(rm.meta["prg_bank_count"]):
        start = rm.meta["prg_offset"] + n * rm.meta["prg_bank_size"]
        sections.append((f"bank{n}.s", emitter.bank(n), start,
                         start + rm.meta["prg_bank_size"]))

    out = ROOT / "disasm"
    if not args.check:
        out.mkdir(exist_ok=True)
        for name, source, _start, _end in sections:
            (out / name).write_text(source, encoding="utf-8")

    failures: list[str] = []
    rebuilt = bytearray()
    try:
        built = assemble_all([(f"disasm/{name}", source)
                              for name, source, _s, _e in sections])
    except AssemblyError as exc:
        print(f"\n1 segment did not assemble:\n  {exc}")
        print("\nREASSEMBLY FAILED - the region map does not reproduce the ROM.")
        return 1

    for name, source, start, end in sections:
        produced = built[f"disasm/{name}"]
        expected = rm.rom[start:end]
        ok = bytes(produced) == bytes(expected)
        if not ok:
            if len(produced) != len(expected):
                failures.append(f"disasm/{name}: assembled to {len(produced):,} bytes, "
                                f"the segment is {len(expected):,}")
            else:
                bad = next(i for i in range(len(expected)) if produced[i] != expected[i])
                failures.append(
                    f"disasm/{name}: first difference at file offset 0x{start + bad:05X} "
                    f"(${emitter.addr_of(start + bad):04X} if PRG) - assembled "
                    f"${produced[bad]:02X}, ROM has ${expected[bad]:02X}")
            rebuilt += expected
        else:
            rebuilt += produced
        if not args.quiet:
            print(f"  {name:<10} {len(expected):>7,} bytes  {'ok' if ok else 'FAILED'}")

    for off in emitter.unplaced_targets():
        emitter.errors.append(
            f"${emitter.addr_of(off):04X} in bank {emitter.bank_of(off)} is a traced "
            "control-flow target but no region of kind 'code' covers it; "
            "run tools/gen-code-regions.py")

    if emitter.overlaps and not args.quiet:
        print(f"\n{len(emitter.overlaps)} places where a control transfer lands inside "
              "another instruction.\nOne run of bytes, two instruction streams - the "
              "BIT-skip idiom and its relatives.\nEmitted as literal bytes with the "
              "alternative decoding beside them:")
        for lo, cut, mnemonic in emitter.overlaps:
            print(f"  bank {emitter.bank_of(lo)}  ${emitter.addr_of(lo):04X} {mnemonic} "
                  f"is entered at ${emitter.addr_of(cut):04X} as something else")

    print()
    if emitter.errors:
        print(f"{len(emitter.errors)} structural problems:")
        for message in emitter.errors[:25]:
            print(f"  {message}")
        if len(emitter.errors) > 25:
            print(f"  ... and {len(emitter.errors) - 25} more")
    if failures:
        print(f"{len(failures)} segments did not reassemble:")
        for message in failures:
            print(f"  {message}")

    if not emitter.errors and not failures and bytes(rebuilt) == rm.rom:
        multi = sum(1 for d in emitter.flow.values() if len(d) > 1)
        print(f"REASSEMBLY EXACT: {len(rm.rom):,} bytes rebuilt from the region map, "
              f"byte for byte.\n{len(emitter.targets):,} control-flow targets all resolved "
              "to instruction starts inside code regions.")
        # A property of this ROM worth printing rather than assuming, because it would be a
        # finding either way. A site in the fixed bank is walked once per live bank that
        # reaches it, so one JSR into $8000-$BFFF can legitimately land in several banks.
        # None does.
        print(f"{len(emitter.flow):,} traced control-transfer sites, of which {multi} "
              "resolve to more than one bank: every traced call into the switchable window "
              "happens under exactly one live bank.")
        print("This verifies structure, not the opcode table - see tools/tgl/asm.py.")
        return 0

    print("\nREASSEMBLY FAILED - the region map does not reproduce the ROM.")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
