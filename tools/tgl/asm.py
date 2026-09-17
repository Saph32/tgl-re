"""A small 6502 assembler, for the reassembly check only.

WHAT THIS PROVES, AND WHAT IT DOES NOT
--------------------------------------
Say this before using the output as evidence, because a tool that gives the right answer
for an incomplete reason gives no signal that it is incomplete.

Carried over from the Yoshi project unchanged apart from this header. The 6502 is the 6502;
what differs between cartridges is the reassembler that drives this, not the encoding.

The encoding table below is ``disasm.OPCODES`` **inverted**. So this assembler does NOT
independently verify the opcode table: an error there would be an error in both directions
and would cancel, and the round trip would pass. (The inversion is asserted to be a
bijection over the 151 documented opcodes, which catches a table typo that made two
mnemonic/mode pairs collide, and nothing more than that. It is restricted to the documented
set because the undocumented NOPs share a mnemonic and mode with real instructions - NOP
implied is $EA and also six other bytes - so no assembler can round-trip them from text.)

What the round trip does verify is everything structural, which is what the playbook built
this check for:

  * every region's declared extent reproduces its own bytes, in order, with nothing missing,
    doubled or transposed - across the whole file, not region by region;
  * every code region decodes into whole instructions and ends on an instruction boundary,
    so a region edge cannot sit in the middle of one;
  * every control-flow target the trace found is an address a label can be placed on, i.e.
    an instruction start inside a region annotated as code - a target that lands in a data
    region or mid-instruction is a hard error rather than a plausible-looking listing;
  * on this cartridge specifically, that every cross-bank reference resolves. A label here
    is per bank - $8000 exists in seven of them - so a call that would be fine in one bank
    and nonsense in another cannot be written down as though it were the same address;
  * every branch reaches its label within the signed 8-bit range;
  * the whole file is reconstructible in one deterministic pass.

A wrong instruction-start address does not survive that, which is the failure the check
exists to catch.

SYNTAX
------
Deliberately tiny, and ca65-flavoured so the listings read like assembler people know:

    .org $8000              set the assembly address
    LABEL:                  define a label at the current address
            lda #$12        an instruction
            lda a:$0012     absolute form forced - see below
            bne LABEL       a branch to a label
            .byte $01,$02   literal bytes
            .fill 779,$FF   a run of one repeated byte
    ; anything after a semicolon is a comment

The ``a:`` prefix matters and is not decoration. ``lda $0012`` is ambiguous - an assembler
would choose the two-byte zero-page form and silently shorten the output by one byte, and
the round trip would then fail for a reason that has nothing to do with the ROM. Emitting
``a:`` whenever the original instruction used absolute mode with an operand below $100
keeps the encoding faithful.
"""

from __future__ import annotations

import re

from .disasm import DOCUMENTED, LEGAL, MODES, OPCODES


def _build_encode() -> dict[tuple[str, str], int]:
    table: dict[tuple[str, str], int] = {}
    for opcode, (mnemonic, mode) in enumerate(OPCODES):
        if opcode not in DOCUMENTED:
            continue
        key = (mnemonic, mode)
        if key in table:
            raise AssemblyError(
                f"the opcode table is not a bijection over legal opcodes: {mnemonic} {mode} "
                f"is both ${table[key]:02X} and ${opcode:02X}")
        table[key] = opcode
    return table


class AssemblyError(Exception):
    """The source does not assemble, or does not assemble to what was expected."""


ENCODE = _build_encode()

# Operand syntax -> addressing mode. Order matters: the indexed and indirect forms have to
# be tried before the plain ones, or `$12,x` parses as `$12` with trailing junk.
_PATTERNS = [
    (re.compile(r"^$"), "imp"),
    (re.compile(r"^a$", re.I), "acc"),
    (re.compile(r"^#(?P<v>.+)$"), "imm"),
    (re.compile(r"^\((?P<v>.+),\s*x\)$", re.I), "izx"),
    (re.compile(r"^\((?P<v>.+)\)\s*,\s*y$", re.I), "izy"),
    (re.compile(r"^\((?P<v>.+)\)$"), "ind"),
    (re.compile(r"^(?P<v>.+?)\s*,\s*x$", re.I), "_x"),
    (re.compile(r"^(?P<v>.+?)\s*,\s*y$", re.I), "_y"),
    (re.compile(r"^(?P<v>.+)$"), "_plain"),
]


class Assembler:
    """Two passes: the first places labels, the second emits bytes.

    Two passes rather than one with backpatching, because a branch whose label is defined
    later has to know the label's address to check its range, and a range error is one of
    the things this check is for.
    """

    def __init__(self, source: str, name: str = "<source>",
                 labels: dict[str, int] | None = None):
        self.source = source
        self.name = name
        # Shared across sources when there is more than one, because this ROM's code calls
        # across banks constantly and a bank-7 routine referring to a bank-0 label is the
        # normal case, not an error.
        self.labels = {} if labels is None else labels

    def assemble(self) -> bytearray:
        self._pass(collect=True)
        return self._pass(collect=False)

    # ---------------------------------------------------------------- the passes

    def _pass(self, collect: bool) -> bytearray:
        out = bytearray()
        addr = 0
        origin_set = False
        for lineno, raw in enumerate(self.source.splitlines(), 1):
            line = raw.split(";", 1)[0].strip()
            if not line:
                continue
            try:
                if line.endswith(":"):
                    name = line[:-1].strip()
                    if collect:
                        if name in self.labels:
                            raise AssemblyError(f"label {name} defined twice")
                        self.labels[name] = addr
                    elif self.labels[name] != addr:
                        raise AssemblyError(
                            f"label {name} moved between passes: pass 1 put it at "
                            f"${self.labels[name]:04X}, pass 2 at ${addr:04X}")
                    continue

                head, _, rest = line.partition(" ")
                head, rest = head.lower(), rest.strip()

                if head == ".org":
                    addr = self._value(rest)
                    origin_set = True
                    continue
                if not origin_set:
                    raise AssemblyError("code before any .org")

                if head == ".byte":
                    data = [self._value(p) & 0xFF for p in rest.split(",")]
                    addr += len(data)
                    if not collect:
                        out += bytes(data)
                    continue
                if head == ".fill":
                    count, _, value = rest.partition(",")
                    n, v = self._value(count), self._value(value) & 0xFF
                    addr += n
                    if not collect:
                        out += bytes([v]) * n
                    continue

                size, encoded = self._instruction(head, rest, addr, collect)
                addr += size
                if not collect:
                    out += encoded
            except AssemblyError as exc:
                raise AssemblyError(f"{self.name}:{lineno}: {exc}\n    {raw.strip()}") from None
        return out

    # ---------------------------------------------------------------- one instruction

    def _instruction(self, mnemonic: str, operand: str, addr: int,
                     collect: bool) -> tuple[int, bytes]:
        up = mnemonic.upper()
        if up not in LEGAL:
            raise AssemblyError(f"unknown mnemonic {mnemonic!r}")

        forced_abs = False
        text = operand
        for pattern, kind in _PATTERNS:
            match = pattern.match(text)
            if not match:
                continue
            inner = match.groupdict().get("v", "")
            if kind in ("imp", "acc"):
                return self._emit(up, kind, None, addr, collect)
            inner = inner.strip()
            if inner.lower().startswith("a:"):
                forced_abs, inner = True, inner[2:].strip()
            value = self._value(inner) if not collect or _is_literal(inner) else 0
            wide = forced_abs or not _is_literal(inner) or value > 0xFF

            if kind == "imm":
                return self._emit(up, "imm", value, addr, collect)
            if kind in ("izx", "izy", "ind"):
                return self._emit(up, kind, value, addr, collect)
            if kind == "_x":
                return self._emit(up, "abx" if wide else "zpx", value, addr, collect)
            if kind == "_y":
                mode = "aby" if wide else "zpy"
                if (up, mode) not in ENCODE:
                    mode = "zpy" if mode == "aby" else "aby"
                return self._emit(up, mode, value, addr, collect)
            # Plain: relative for branches, otherwise absolute or zero page.
            if (up, "rel") in ENCODE:
                return self._emit(up, "rel", value, addr, collect)
            return self._emit(up, "abs" if wide else "zp", value, addr, collect)
        raise AssemblyError(f"cannot parse operand {operand!r}")

    def _emit(self, mnemonic: str, mode: str, value: int | None, addr: int,
              collect: bool) -> tuple[int, bytes]:
        key = (mnemonic, mode)
        if key not in ENCODE:
            raise AssemblyError(f"{mnemonic} has no {mode} addressing mode")
        size = 1 + MODES[mode][0]
        if collect:
            return size, b""
        opcode = ENCODE[key]
        if mode in ("imp", "acc"):
            return size, bytes([opcode])
        if mode == "rel":
            delta = value - (addr + 2)
            if not -128 <= delta <= 127:
                raise AssemblyError(
                    f"branch from ${addr:04X} to ${value:04X} is {delta} bytes, out of the "
                    "signed 8-bit range a relative branch can encode")
            return size, bytes([opcode, delta & 0xFF])
        if size == 2:
            if not 0 <= value <= 0xFF:
                raise AssemblyError(f"${value:04X} does not fit in a one-byte operand")
            return size, bytes([opcode, value])
        if not 0 <= value <= 0xFFFF:
            raise AssemblyError(f"{value} does not fit in a two-byte operand")
        return size, bytes([opcode, value & 0xFF, value >> 8])

    # ---------------------------------------------------------------- values

    def _value(self, text: str) -> int:
        text = text.strip()
        if not text:
            raise AssemblyError("expected a value")
        if text.startswith("$"):
            return int(text[1:], 16)
        if text.startswith("%"):
            return int(text[1:], 2)
        if text[0].isdigit():
            return int(text, 10)
        if text in self.labels:
            return self.labels[text]
        raise AssemblyError(f"undefined label {text!r} - nothing in the source defines it, "
                            "so the address it names is not an instruction start")


def _is_literal(text: str) -> bool:
    text = text.strip()
    return bool(text) and (text[0] in "$%" or text[0].isdigit())


def assemble(source: str, name: str = "<source>") -> bytearray:
    return Assembler(source, name).assemble()


def assemble_all(sources: list[tuple[str, str]]) -> dict[str, bytearray]:
    """Assemble several sources against one label table.

    Label collection runs over every source before any of them is encoded, so a reference
    from one segment to a label defined in another resolves. Without this the check would
    report every cross-bank call as an undefined label, which says nothing about the ROM and
    a great deal about the tool.
    """
    labels: dict[str, int] = {}
    units = [Assembler(source, name, labels) for name, source in sources]
    for unit in units:
        unit._pass(collect=True)
    return {unit.name: unit._pass(collect=False) for unit in units}
