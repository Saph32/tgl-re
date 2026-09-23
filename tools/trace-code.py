#!/usr/bin/env python3
"""Seeded control-flow trace of The Guardian Legend's PRG.

Static tracing is how a code region gets its extent instead of us guessing it. On a banked
cartridge the trace has to carry one extra piece of state: **which bank is live**. An
address in $8000-$BFFF names a different byte in each of the seven switchable banks, so a
tracer that follows a JSR into $8000 without knowing the bank is not tracing anything.

    python tools/trace-code.py                # summary
    python tools/trace-code.py --runs         # the contiguous traced stretches
    python tools/trace-code.py --gaps         # what is still unreached, largest first
    python tools/trace-code.py --leads        # transfers the trace could not follow
    python tools/trace-code.py --calls        # resolved far calls
    python tools/trace-code.py --inline       # calls with inline argument data
    python tools/trace-code.py --illegal      # instruction starts that are not real opcodes
    python tools/trace-code.py --seeds        # where the trace was started from
    python tools/trace-code.py --assumptions  # what the answer rests on - READ THIS

**Read --assumptions before citing any coverage figure from this tool.** A trace's
coverage number is a claim about the trace's model of the machine, not about the ROM.

The signal to watch is the illegal-opcode count on the second line of the summary. It is
zero, and every mechanism below was added because it was not. A trace that has walked into
data decodes it happily and reports the coverage anyway; the count is the cheap thing that
says otherwise, and on this ROM it has been right every time. It is also what caught a typo
in this project's own annotations/rom.json, where the NMI vector was recorded as $D275 when
the bytes at $FFFA say $DC75 - a legal address that disassembles into the middle of a real
routine, and would have gone on looking fine forever.

What the model covers
---------------------
* JSR, JMP absolute, all eight conditional branches, and fall-through.
* **Entry-table aliases.** Every bank opens with a run of `JMP`s, and `JSR slot` where the
  slot holds `JMP X` is in every way a `JSR X`. Resolving through them is not cosmetic:
  the far-call trampoline is published at $C006, and until that was resolved 28 of the 35
  far calls in the ROM were invisible and their inline bytes were being decoded as code.
* **The nine bank-switch routines**, by their effect: after `JSR $D714` the live bank is 0,
  after `JSR $D705` it is whatever was in A, and so on. When A is not known and the call
  is in the fixed bank, the walk goes on with the live bank unknown rather than stopping.
* **The far-call trampoline at $D76F**: three inline bytes follow the JSR - bank, then the
  target address **minus one**, because $D790 pushes them as a fake return address and lets
  RTS add the one back. The call site continues at pc+6 with its own bank restored, which
  is what $D79C does on the way home.
* **Inline-argument calls**, from `annotations/dispatch.json`. Six routines in this ROM pop
  their own return address and read the bytes after the call as data. Two queue a PPU
  string whose length is a function of its first byte; one takes a fixed four bytes; three
  are jump tables whose entry the trace resolves from A or Y and which never come back.
* **Routines that never return**, computed rather than listed: a callee with no reachable
  RTS does not resume at the instruction after the call, so the bytes there are not code.
  This needs the trace and the trace needs it, so `run_to_fixpoint` iterates the two - two
  passes on this ROM.
* **Complementary branch pairs.** `BNE x / BEQ y` back to back is an unconditional two-way,
  so the second branch's fall-through is unreachable - and in this ROM it is a data table.
* **Routines that return through the stack**, listed in `dispatch.json`
  (`returns_via_stack`): a subroutine that does `PLA / PLA` and jumps on returns from its
  caller, which no reachability test can see.
* **Branches decided by an immediate load.** `LDA #$01 / BNE` is an unconditional jump, so
  its fall-through is not code; bank 6 `$87DA` and bank 5 `$85D8` hide tables behind one.
* A small constant tracker for A, X and Y - immediates, the transfers between them, and
  `LDA $04`, which yields the live bank because $04 is the shadow every switch routine
  writes. PHA/PLA and PHP/PLP push and pop it, so the `PHA / JSR $D714 / ... / PLA /
  JSR $D705` save-and-restore idiom resolves.

What it does not cover is in --assumptions. The list is the point; it is the to-do list for
the next mechanism, in the sense of playbook section 4.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl.disasm import BRANCHES, DOCUMENTED, OPCODES, decode
from tgl.model import AnnotationError, bank_window, load

ROOT = Path(__file__).resolve().parent.parent

# ---------------------------------------------------------------- the bank-switch ABI
#
# Every address here is checked against the bytes at load time by `_verify_abi`. A
# hand-entered address is an assertion nothing else checks, and seeding a tracer from a
# typo turns it into claimed ground - 6502 has no alignment, so starting four bytes early
# produces legal instructions that fall into the real routine and the listing still reads
# fine. These signatures are what stops that.

SWITCH_A = 0xD705           # JSR here with the bank number in A
SWITCH_FIXED = {            # JSR here to select one particular bank, no register needed
    0xD714: 0, 0xD721: 1, 0xD72E: 2, 0xD73B: 3, 0xD748: 4, 0xD755: 5, 0xD762: 6,
}
FARCALL = 0xD76F            # JSR here, then three inline bytes: bank, lo, hi
BANK_SHADOW = 0x04          # RAM byte every switch routine writes with the live bank

# Two complementary branches back to back test the same flag both ways, so the pair is an
# unconditional two-way and the second one's FALL-THROUGH IS UNREACHABLE. Modelling this is
# not a refinement: without it the trace walks straight into whatever the pair was branching
# around, which in this ROM is a table. `$82D5 BNE $82A3 / $82D7 BEQ $82DD` in bank 5 jumps
# over four bytes at $82D9 that `$82B9 LDA $82D9,Y` reads as data - and the trace decoded
# them, producing a BPL into the middle of an instruction two bytes later.
COMPLEMENT = {"BNE": "BEQ", "BEQ": "BNE", "BCC": "BCS", "BCS": "BCC",
              "BPL": "BMI", "BMI": "BPL", "BVC": "BVS", "BVS": "BVC"}

# Whether a branch is taken, given the value an immediate load just put in the flags.
IMM_DECIDES = {"BNE": lambda v: v != 0, "BEQ": lambda v: v == 0,
               "BPL": lambda v: v < 0x80, "BMI": lambda v: v >= 0x80}

_SIG_SWITCH_A = bytes.fromhex("8504 98 48 a404 b9f2ff 99f2ff 68 a8 60".replace(" ", ""))
_SIG_FARCALL = bytes.fromhex(
    "8510 8411 68 8512 18 6903 a8 68 8513 6900 48 98 48 a504 48 2090d7"
    "8510 8411 68 4c9cd7".replace(" ", ""))


def _sig_switch_fixed(bank: int) -> bytes:
    """`PHA / LDA #bank / STA $04 / LDA $FFF2+bank / STA $FFF2+bank / PLA / RTS`."""
    slot = 0xFFF2 + bank
    return bytes([0x48, 0xA9, bank, 0x85, BANK_SHADOW,
                  0xAD, slot & 0xFF, slot >> 8,
                  0x8D, slot & 0xFF, slot >> 8, 0x68, 0x60])


def _verify_abi(rom: bytes, meta: dict) -> None:
    fixed = meta["prg_bank_count"] - 1
    base = meta["prg_offset"] + fixed * meta["prg_bank_size"]

    def at(addr: int, n: int) -> bytes:
        return rom[base + addr - 0xC000: base + addr - 0xC000 + n]

    if at(SWITCH_A, len(_SIG_SWITCH_A)) != _SIG_SWITCH_A:
        raise AnnotationError(f"${SWITCH_A:04X} does not hold the generic bank-switch "
                              "routine this tool expects")
    if at(FARCALL, len(_SIG_FARCALL)) != _SIG_FARCALL:
        raise AnnotationError(f"${FARCALL:04X} does not hold the far-call trampoline this "
                              "tool expects")
    for addr, bank in SWITCH_FIXED.items():
        sig = _sig_switch_fixed(bank)
        if at(addr, len(sig)) != sig:
            raise AnnotationError(f"${addr:04X} does not hold the switch-to-bank-{bank} "
                                  "routine this tool expects")


def entry_aliases(rm) -> dict[int, dict[int, int]]:
    """`{bank: {entry slot address: the address the slot jumps to}}`.

    A bank's opening JMP table publishes routines under a second address, and `JSR slot`
    where the slot holds `JMP X` behaves in every way like `JSR X` - the JMP is transparent.
    Resolving through it is not cosmetic: anything the trace recognises by target address
    (the bank-switch ABI, the inline-argument registry) is silently defeated by an alias.

    **The far-call trampoline is published at $C006**, and a `JSR $C006` is followed by the
    same three inline bytes as a `JSR $D76F`. Tracing those three bytes as instructions is
    how this tool first walked off the rails: it produced an `ASL $08 / NOP #$A5 /
    JMP ($A0CD)` in bank 3 and reported the last of those as an unresolved indirect jump,
    which read as a real finding. Resolving the aliases turned 13 far calls into 41.

    Derived from the ROM rather than listed by hand, so a slot that moves cannot go stale.
    """
    out: dict[int, dict[int, int]] = {}
    for n in range(rm.meta["prg_bank_count"]):
        data = rm.prg_bank(n)
        base = bank_window(rm.meta, n)
        table: dict[int, int] = {}
        k = 0
        while k + 3 <= len(data) and data[k] == 0x4C:
            table[base + k] = data[k + 1] | (data[k + 2] << 8)
            k += 3
        out[n] = table
    return out


def load_registry(root: Path) -> dict:
    """`annotations/dispatch.json` - what a human resolved that the trace cannot."""
    path = root / "annotations" / "dispatch.json"
    if not path.exists():
        return {"inline_calls": [], "dispatch_tables": [], "unresolved": []}
    return json.loads(path.read_text(encoding="utf-8"))


# ---------------------------------------------------------------- the machine model

class Machine:
    """PRG as the CPU sees it: one switchable bank at $8000, the fixed bank at $C000."""

    def __init__(self, rm) -> None:
        self.meta = rm.meta
        self.fixed = rm.meta["prg_bank_count"] - 1
        self.banks = [rm.prg_bank(n) for n in range(rm.meta["prg_bank_count"])]

    def resolve(self, live: int | None, addr: int) -> tuple[int, int] | None:
        """(bank, index into that bank) for a CPU address, or None if it is not ROM or the
        live bank is unknown and the address is in the switchable window."""
        if addr >= 0xC000:
            return self.fixed, addr - 0xC000
        if addr < 0x8000:
            return None
        if live is None:
            return None
        return live, addr - 0x8000

    def offset(self, bank: int, index: int) -> int:
        return self.meta["prg_offset"] + bank * self.meta["prg_bank_size"] + index

    def byte(self, live: int | None, addr: int) -> int | None:
        place = self.resolve(live, addr)
        return None if place is None else self.banks[place[0]][place[1]]

    def decode_at(self, live: int | None, addr: int):
        place = self.resolve(live, addr)
        if place is None:
            return None
        bank, index = place
        base = 0xC000 if bank == self.fixed else 0x8000
        return decode(self.banks[bank], index, base + index)


# ---------------------------------------------------------------- the trace

class Trace:
    def __init__(self, rm) -> None:
        self.rm = rm
        self.m = Machine(rm)
        self.covered: set[int] = set()          # file offsets reached as any byte of an insn
        self.starts: set[int] = set()           # file offsets an instruction begins at
        self.seen: set[tuple] = set()           # (live, addr) already walked
        self.leads: list[dict] = []
        self.farcalls: list[dict] = []
        self.switch_sites: list[dict] = []
        self.seeds: list[dict] = []
        self.unknown_bank_entries: list[dict] = []
        self.callsites: list[dict] = []
        self.inline_sites: list[dict] = []
        self.inline_data: list[dict] = []
        self.dispatched: list[dict] = []
        self.dispatch_tables: list[dict] = []
        self.unconditional_pairs: list[dict] = []
        self.decided_branches: list[dict] = []
        self.nonreturn_sites: list[dict] = []
        self.farcall_targets: set[tuple] = set()
        self._last_nonreturning: set[tuple] = set()
        # For the reassembler. `flow` maps an instruction's file offset to the file offsets
        # its OPERAND names - one per live bank it was reached under, so a bank-7 site that
        # calls $8000 can have several. `entry_points` holds every offset that must be an
        # instruction start for some reason other than an operand: a vector, an entry slot,
        # a far-call target, a resolved dispatch entry.
        self.flow: dict[int, set[int]] = {}
        # Routines that never resume at the instruction after the call, as
        # (live bank, address). Computed by `find_nonreturning`, not listed by
        # hand, and fed back into a second pass - see `run_to_fixpoint`.
        self.nonreturning: set[tuple] = set()
        self.entry_points: set[int] = set()
        self.aliases = entry_aliases(rm)
        self.registry = load_registry(ROOT)
        # Keyed by (bank, address) because three of these helpers live in switchable
        # banks: an address alone would match the wrong routine in six other banks. A null
        # bank in the registry means the fixed bank, which every bank can see.
        self.inline = {}
        for c in self.registry.get("inline_calls", []):
            addr = int(c["cpu_addr"].lstrip("$"), 16)
            self.inline[(c.get("bank"), addr)] = {**c, "addr": addr}

    # -- deduplication -----------------------------------------------------------
    #
    # Bank 7 code is walked once per live bank that reaches it, because the live bank is
    # part of the state and has to be: the same instruction can call into seven different
    # banks. That means one physical site can be recorded several times, so everything
    # reported by site is collapsed on the way out rather than being counted twice.

    @staticmethod
    def _by_site(items: list[dict], *keys: str) -> list[dict]:
        seen, out = set(), []
        for it in items:
            k = tuple(it[key] for key in keys)
            if k not in seen:
                seen.add(k)
                out.append(it)
        return out

    @property
    def sites_farcalls(self) -> list[dict]:
        return self._by_site(self.farcalls, "bank", "addr", "to_bank", "target")

    @property
    def sites_switches(self) -> list[dict]:
        return self._by_site(self.switch_sites, "bank", "addr", "to")

    @property
    def sites_dispatched(self) -> list[dict]:
        return self._by_site(self.dispatched, "bank", "addr", "index", "target")

    @property
    def sites_inline_data(self) -> list[dict]:
        return self._by_site(self.inline_data, "offset", "size", "kind")

    @property
    def sites_inline(self) -> list[dict]:
        return self._by_site(self.inline_sites, "bank", "addr", "target")

    @property
    def sites_leads(self) -> list[dict]:
        return self._by_site(self.leads, "bank", "addr", "why")

    # -- seeding -----------------------------------------------------------------

    def seed(self, live: int | None, addr: int, why: str) -> None:
        self.seeds.append({"bank": live, "addr": addr, "why": why})
        place = self.m.resolve(live, addr)
        if place is not None:
            self.entry_points.add(self.m.offset(*place))
        self._work.append((live, addr, (None, None, None), ()))

    def entry_table(self, bank: int) -> list[int]:
        """The run of `JMP abs` instructions a bank opens with.

        Defined as the maximal run of $4C bytes at three-byte spacing from the window base.
        That is a *definition*, not a finding: a run of JMPs can end by running into code
        that happens to start with one, so the count this returns is an upper bound on the
        entry table and a lower bound on nothing. The far calls resolved by the trace land
        on slots of this table and are the independent check on it.
        """
        data = self.m.banks[bank]
        base = bank_window(self.rm.meta, bank)
        out = []
        k = 0
        while k + 3 <= len(data) and data[k] == 0x4C:
            out.append(base + k)
            k += 3
        return out

    # -- does a routine ever come back? ------------------------------------------

    def _can_return(self, live, start) -> bool:
        """Can any path from ``start`` reach an RTS or RTI?

        Deliberately conservative: anything this cannot reason about - an indirect jump, an
        illegal opcode, a tail call into the window with the bank unknown - counts as "yes,
        it may return", so a routine is only called non-returning when every path out of it
        is accounted for. A false "no" would make the trace stop at a live call site and
        silently lose everything downstream, which is the more expensive mistake.
        """
        seen, work = set(), [(live, start)]
        while work:
            lv, a = work.pop()
            while True:
                place = self.m.resolve(lv, a)
                if place is None or (lv, a) in seen:
                    if place is None:
                        return True          # cannot see it; assume it may return
                    break
                seen.add((lv, a))
                insn = self.m.decode_at(lv, a)
                if insn.mnemonic == "TRUNC" or insn.raw[0] not in DOCUMENTED:
                    return True
                if insn.mnemonic in ("RTS", "RTI"):
                    return True
                if insn.mnemonic in ("BRK", "KIL"):
                    break
                target = self._unalias(lv, insn.target)

                if insn.mnemonic == "JSR" and target in SWITCH_FIXED:
                    lv = SWITCH_FIXED[target]
                    a += insn.size
                    continue
                if insn.mnemonic == "JSR" and target == SWITCH_A:
                    return True              # bank now unknown; do not reason further
                if insn.mnemonic == "JSR" and target == FARCALL:
                    a += insn.size + 3
                    continue
                entry = self._inline_entry(lv, target) if insn.mnemonic == "JSR" else None
                if entry is not None:
                    if entry["kind"] == "jump_table":
                        break                # RTSes into the table; never comes back here
                    if entry["kind"] == "fixed":
                        a += insn.size + entry["length"]
                        continue
                    count = self.m.byte(lv, a + insn.size)
                    if count is None:
                        return True
                    length = 9 if count >= 0xC0 else (count & 0x7F) + 3
                    a += insn.size + length + entry.get("block_adjust", 0)
                    continue
                if insn.mnemonic == "JSR":
                    # The callee's body is NOT explored. An RTS inside a callee returns to
                    # *this* routine, not out of it, so counting it would make almost every
                    # routine look like it returns - which is what the first version of
                    # this did, and why it found 22 non-returning routines and stopped at
                    # none of them. Only an RTS reached without going through a JSR is a
                    # way out of this routine.
                    if (lv, target) in self.nonreturning:
                        break
                    a += insn.size
                    continue
                if insn.mnemonic == "JMP":
                    if insn.mode != "abs":
                        return True          # computed target; unknowable
                    a = target
                    continue
                if insn.mnemonic in BRANCHES:
                    work.append((lv, target))
                a += insn.size
        return False

    def find_nonreturning(self) -> set[tuple]:
        """Every reached JSR target with no reachable RTS, to a fixed point."""
        found = set(self.nonreturning)
        for (bank, addr), entry in self.inline.items():
            if entry["kind"] == "jump_table":
                found.add((bank, addr))
                if bank is None:
                    for n in range(self.rm.meta["prg_bank_count"]):
                        found.add((n, addr))
        changed = True
        while changed:
            changed = False
            self.nonreturning = found
            candidates = [(s["live"], s["target"]) for s in self.callsites
                          if s["target"] not in ABI]
            # A far call is a call. Its target is reached through the trampoline rather
            # than by a JSR operand, so it is not in callsites - and leaving it out is how
            # the one real case in this ROM was missed: bank 2 $8AFF far-calls bank 0
            # $8015, which is an endless display loop, and the bytes after the call are the
            # data block the pointer built at $8AC8/$8ACC names.
            candidates += sorted(self.farcall_targets)
            # A routine can return without an RTS of its own: bank 3 $887F loops forever
            # until a subroutine drops its return address (PLA / PLA) and jumps to code
            # whose RTS then returns to $887F's caller. The walk cannot see that, so such
            # routines are listed, with the reason, in dispatch.json "returns_via_stack".
            stack = {(e["bank"], int(e["cpu_addr"].lstrip("$"), 16))
                     for e in self.registry.get("returns_via_stack", [])}
            for key in candidates:
                if key in found or key in stack:
                    continue
                if not self._can_return(*key):
                    found.add(key)
                    changed = True
        return found

    # -- the walk ----------------------------------------------------------------

    def run_to_fixpoint(self, passes: int = 6) -> int:
        """Trace, work out which routines never return, trace again knowing that.

        Two passes are needed because the two answers depend on each other: the walk has to
        know whether a callee returns before it can decide the bytes after the call are
        code, and working that out needs a walk. Iterating to a fixed point is the honest
        way round it, and the loop is bounded - it settles after two passes on this ROM.
        """
        for n in range(1, passes + 1):
            self.run()
            found = self.find_nonreturning()
            if found == self._last_nonreturning:
                return n
            self._last_nonreturning = set(found)
            self._reset(found)
        return passes

    def _reset(self, nonreturning) -> None:
        keep = nonreturning
        self.__init__(self.rm)
        self.nonreturning = keep
        self._last_nonreturning = set(keep)

    def run(self) -> None:
        self._work: list[tuple] = []
        meta = self.rm.meta
        v = meta["vectors"]
        # The three vectors. The live bank at each is unknown and is modelled as unknown:
        # UxROM does not define the latch's power-on value, and an NMI or IRQ can arrive
        # with any bank selected. Saying "bank 0" here would be inventing information.
        self.seed(None, v["reset"], "RESET vector at $FFFC")
        self.seed(None, v["nmi"], "NMI vector at $FFFA")
        self.seed(None, v["irq"], "IRQ/BRK vector at $FFFE")

        # Every bank's opening JMP table. A switchable bank's entries are seeded with that
        # bank live, because that is the only way they can be running. Bank 7's are seeded
        # with the bank unknown, because bank 7 code runs under any of them.
        for n in range(meta["prg_bank_count"]):
            live = None if n == self.m.fixed else n
            for k, addr in enumerate(self.entry_table(n)):
                self.seed(live, addr, f"bank {n} entry table, slot {k}")

        # Hand-resolved dispatch tables. Each entry is a target the trace cannot reach on
        # its own because the index is a runtime value; registering the table and its entry
        # count - with the argument for the count in the registry, not here - turns one
        # unfollowable JSR into as many seeds as it has arms.
        for tbl in self.registry.get("dispatch_tables", []):
            addr = int(tbl["cpu_addr"].lstrip("$"), 16)
            live = tbl.get("bank")
            self.dispatch_tables.append({"bank": live, "addr": addr,
                                         "entries": tbl["entries"], "name": tbl["name"]})
            # A table is either interleaved - lo, hi, lo, hi - or SPLIT into a run of low
            # bytes and a separate run of high bytes, which is what bank 6's object
            # dispatch does. `hi_addr` names the second run when it is split.
            hi_addr = tbl.get("hi_addr")
            hi_base = int(hi_addr.lstrip("$"), 16) if hi_addr else None
            for k in range(tbl["entries"]):
                if hi_base is None:
                    lo = self.m.byte(live, addr + 2 * k)
                    hi = self.m.byte(live, addr + 2 * k + 1)
                else:
                    lo = self.m.byte(live, addr + k)
                    hi = self.m.byte(live, hi_base + k)
                if lo is None or hi is None:
                    continue
                target = ((lo | (hi << 8)) + 1) & 0xFFFF
                if tbl.get("skip_first") and k == 0:
                    continue
                self.seed(live, target, f'{tbl["name"]} (${addr:04X}) entry {k}')

        # The ABI routines and the inline-argument helpers themselves. They are recognised
        # at their call sites by target and stepped over rather than entered, so without
        # this they are never walked and their own bytes sit in a gap - 106 bytes of
        # $D705-$D76E, the bank-switch routines, were reported as unclaimed for exactly
        # that reason. Seeding them is not an assumption: _verify_abi has already matched
        # every switch routine and the trampoline against its literal bytes, and each
        # inline helper was disassembled before being registered.
        for addr, n in SWITCH_FIXED.items():
            self.seed(None, addr, f"bank-switch routine (to bank {n})")
        self.seed(None, SWITCH_A, "bank-switch routine (bank in A)")
        self.seed(None, FARCALL, "far-call trampoline")
        for (bank, addr), entry in self.inline.items():
            self.seed(bank, addr, f"inline-argument helper: {entry['name']}")

        while self._work:
            live, addr, regs, astack = self._work.pop()
            self._walk(live, addr, regs, astack)

    def _walk(self, live, addr, regs, astack) -> None:
        prev = None
        prev_insn = None
        while True:
            key = (live, addr)
            if key in self.seen:
                return
            place = self.m.resolve(live, addr)
            if place is None:
                if 0x8000 <= addr < 0xC000:
                    self.unknown_bank_entries.append({"addr": addr})
                return
            self.seen.add(key)

            insn = self.m.decode_at(live, addr)
            bank, index = place
            off = self.m.offset(bank, index)
            self.starts.add(off)
            self.covered.update(range(off, off + insn.size))
            if insn.mnemonic == "TRUNC":
                self.leads.append({"bank": bank, "addr": addr,
                                   "why": "instruction runs off the end of the bank"})
                return

            a, x, y = regs
            # An ABI routine reached through a bank's entry table is still that routine,
            # so the target is resolved through the aliases before anything is matched on it.
            target = self._unalias(live, insn.target)

            # Record the operand-level control transfer for the reassembler, which turns
            # these into labels. The RAW operand is recorded, not the unaliased target: the
            # listing has to print `jsr L7_C06F` for a call through an entry slot, because
            # $C06F is the address in the bytes. Where the slot leads is the tracer's
            # business, not the assembler's.
            if insn.mnemonic in ("JSR", "JMP") or insn.mnemonic in BRANCHES:
                if insn.target is not None and insn.mode != "ind":
                    dest = self.m.resolve(live, insn.target)
                    if dest is not None:
                        self.flow.setdefault(off, set()).add(self.m.offset(*dest))

            # --- the bank-switch ABI, recognised by target -----------------------
            if insn.mnemonic == "JSR" and target in SWITCH_FIXED:
                new = SWITCH_FIXED[target]
                self.switch_sites.append({"bank": bank, "addr": addr, "to": new,
                                          "how": "fixed"})
                self._note_switch_in_window(bank, addr, live, new)
                live, regs = new, (a, x, y)
                addr += insn.size
                continue

            if insn.mnemonic == "JSR" and target == SWITCH_A:
                if a is None:
                    self.leads.append({"bank": bank, "addr": addr,
                                       "why": "JSR $D705 with A not statically known"})
                    # In the fixed bank the walk can go on: the bytes after the JSR are
                    # bank 7's whatever got switched in, so only the LIVE bank becomes
                    # unknown, and resolve() then refuses any call into the window. In a
                    # switchable bank the next instruction is fetched from the new bank,
                    # so there it has to stop. This let $E9AA-$EA67 be traced, which
                    # holds the only writers of the loaded-graphics list at $0480.
                    if bank != self.m.fixed:
                        return
                    live = None
                    addr += insn.size
                    continue
                new = a & 0x07
                self.switch_sites.append({"bank": bank, "addr": addr, "to": new,
                                          "how": "A"})
                self._note_switch_in_window(bank, addr, live, new)
                live = new
                addr += insn.size
                continue

            if insn.mnemonic == "JSR" and target == FARCALL:
                dest = self._farcall(live, bank, addr)
                if dest is not None and dest in self.nonreturning:
                    self.nonreturn_sites.append({"bank": bank, "addr": addr,
                                                 "target": target})
                    return
                addr += insn.size + 3          # the three inline bytes are not code
                continue

            # A registered inline-argument call. The bytes after the JSR are data the
            # callee reads through its own return address, so decoding them is guaranteed
            # to produce nonsense that still looks like instructions. With a known length
            # the walk steps over them; without one it stops and says so, because a
            # resumption point we invented would claim bytes on no evidence at all.
            entry = self._inline_entry(live, target) if insn.mnemonic == "JSR" else None
            if entry is not None:
                self.inline_sites.append({"bank": bank, "addr": addr, "target": target,
                                          "kind": entry["kind"]})
                ret = addr + insn.size

                if entry["kind"] == "fixed":
                    # The one case with a resumption point: the callee advances its pointer
                    # by a constant, so the bytes are stepped over and the walk goes on.
                    self.inline_data.append({"offset": self.m.offset(bank, index) + insn.size,
                                             "size": entry["length"], "kind": "fixed",
                                             "bank": bank, "addr": ret})
                    addr = ret + entry["length"]
                    continue

                if entry["kind"] == "ppu_string":
                    # One item per call, and its length is a function of its first byte -
                    # see the long note in annotations/dispatch.json, which records this as
                    # a correction to an earlier reading of the same loop.
                    count = self.m.byte(live, ret)
                    if count is None:
                        self.leads.append({"bank": bank, "addr": addr,
                                           "why": "inline string runs off the bank"})
                        return
                    length = 9 if count >= 0xC0 else (count & 0x7F) + 3
                    n = length + entry.get("block_adjust", 0)
                    self.inline_data.append({
                        "offset": self.m.offset(bank, index) + insn.size, "size": n,
                        "kind": "ppu_string", "bank": bank, "addr": ret, "count": count,
                        "target": target})
                    addr = ret + n
                    continue

                if entry["kind"] == "jump_table":
                    # The index arrives in A at the doubling entry and in Y at the body.
                    if entry.get("index_reg") == "A":
                        idx = None if a is None else (a * 2) & 0xFF
                    else:
                        idx = y
                    # Entry k is the two little-endian bytes at ret+2k holding target-1,
                    # selected by the caller arriving with Y = 2k. Control does not come
                    # back, so the walk ends either way.
                    if idx is None:
                        self.leads.append({
                            "bank": bank, "addr": addr,
                            "why": f"JSR ${target:04X} ({entry['name']}) with "
                                   f"{entry.get('index_reg', 'Y')} not "
                                   "statically known: which entry of the inline table is "
                                   "taken is undetermined"})
                        return
                    lo = self.m.byte(live, ret + idx)
                    hi = self.m.byte(live, ret + idx + 1)
                    if lo is None or hi is None:
                        self.leads.append({"bank": bank, "addr": addr,
                                           "why": "inline jump table runs off the bank"})
                        return
                    dest = ((lo | (hi << 8)) + 1) & 0xFFFF
                    self.inline_data.append({"offset": self.m.offset(bank, index) + insn.size,
                                             "size": idx + 2, "kind": "jump_table",
                                             "bank": bank, "addr": ret})
                    self.dispatched.append({"bank": bank, "addr": addr, "index": idx // 2,
                                            "target": dest})
                    place = self.m.resolve(live, dest)
                    if place is not None:
                        self.entry_points.add(self.m.offset(*place))
                    self._push(live, dest, (a, x, None), astack)
                    return

                self.leads.append({
                    "bank": bank, "addr": addr,
                    "why": f"JSR ${target:04X} ({entry['name']}): inline argument data of "
                           "undetermined length follows; see annotations/dispatch.json"})
                return

            if insn.mnemonic == "JMP" and target in SWITCH_FIXED:
                # A tail call: switch, then RTS to whoever called *this* routine. The bank
                # change lands in a caller this walk cannot see, so it is recorded and the
                # run ends rather than being followed with a bank we would be guessing.
                self.leads.append({
                    "bank": bank, "addr": addr,
                    "why": f"JMP to the switch-to-bank-{SWITCH_FIXED[target]} routine: "
                           "the bank change reaches this routine's caller, which this walk "
                           "cannot follow"})
                return
            if insn.mnemonic == "JMP" and target == SWITCH_A:
                self.leads.append({
                    "bank": bank, "addr": addr,
                    "why": "JMP to the generic switch routine: the bank change reaches this "
                           "routine's caller, which this walk cannot follow"})
                return

            # --- ordinary control flow -------------------------------------------
            if insn.mnemonic == "JSR":
                self.callsites.append({"bank": bank, "addr": addr, "live": live,
                                       "target": target})
                self._push(live, target, (a, x, y), astack)
                # A callee with no reachable RTS never comes back, so the bytes after the
                # call are not the next instruction. In this ROM they are usually data: at
                # bank 2 $8AFF the far call leads to an endless display loop, and the bytes
                # at $8B05 that the trace used to decode are the block the pointer built at
                # $8AC8/$8ACC names.
                if (live, target) in self.nonreturning:
                    self.nonreturn_sites.append({"bank": bank, "addr": addr,
                                                 "target": target})
                    return
            elif insn.mnemonic in BRANCHES:
                # A branch straight after LDA/LDX/LDY #imm tests flags that constant set, so
                # it is decided: LDA #$01 / BNE is an unconditional jump and the bytes after
                # it are not code. Bank 6 $87DA and bank 5 $85D8 both do this with a data
                # table behind the branch, and walking the fall-through decoded it.
                decided = None
                if prev_insn is not None and prev_insn.mode == "imm" and                         prev_insn.mnemonic in ("LDA", "LDX", "LDY") and                         insn.mnemonic in IMM_DECIDES:
                    decided = IMM_DECIDES[insn.mnemonic](prev_insn.operand & 0xFF)
                    self.decided_branches.append({"bank": bank, "addr": addr,
                                                  "taken": decided})
                if decided is not False:
                    self._push(live, target, (a, x, y), astack)
                if decided is True:
                    return
                if COMPLEMENT.get(prev) == insn.mnemonic:
                    self.unconditional_pairs.append({"bank": bank, "addr": addr,
                                                     "pair": f"{prev}/{insn.mnemonic}"})
                    return
            elif insn.mnemonic == "JMP":
                if insn.mode == "abs":
                    addr = target
                    continue
                self.leads.append({"bank": bank, "addr": addr,
                                   "why": f"JMP (${insn.operand:04X}) - indirect, target "
                                          "built at runtime"})
                return
            elif insn.mnemonic in ("RTS", "RTI", "BRK", "KIL"):
                return

            regs, astack = self._regs(insn, (a, x, y), astack, live)
            prev = insn.mnemonic
            prev_insn = insn
            addr += insn.size

    def _inline_entry(self, live, target):
        """The registry entry for a call target, if it is a registered inline-argument
        routine. A target in the fixed window is matched on the null-bank key; one in the
        switchable window only matches a routine registered for the live bank."""
        if target is None:
            return None
        if target >= 0xC000:
            return self.inline.get((None, target))
        return self.inline.get((live, target))

    def _unalias(self, live, target):
        """An ABI routine reached through a bank's entry table is still that routine."""
        if target is None:
            return None
        owner = self.m.fixed if target >= 0xC000 else live
        if owner is None:
            return target
        return self.aliases.get(owner, {}).get(target, target)

    def _note_switch_in_window(self, bank, addr, live, new) -> None:
        """A switch executed from $8000-$BFFF changes the bytes under the program counter.

        Nothing stops a programmer doing it, and it would be a real finding, so it is
        recorded rather than assumed away. Every site found so far is in the fixed bank.
        """
        if addr < 0xC000 and live != new:
            self.leads.append({
                "bank": bank, "addr": addr,
                "why": f"bank switch to {new} executed from the switchable window; "
                       "execution continues at bytes this walk is now reading from the new "
                       "bank"})

    def _farcall(self, live, bank, addr) -> None:
        lo = self.m.byte(live, addr + 3)
        mid = self.m.byte(live, addr + 4)
        hi = self.m.byte(live, addr + 5)
        if None in (lo, mid, hi):
            self.leads.append({"bank": bank, "addr": addr,
                               "why": "far call whose inline bytes run off the bank"})
            return None
        target = ((mid | (hi << 8)) + 1) & 0xFFFF
        self.farcalls.append({"bank": bank, "addr": addr, "to_bank": lo & 0x07,
                              "target": target})
        self.farcall_targets.add((lo & 0x07, target))
        # The three inline bytes are the trampoline's argument, not instructions. Recorded
        # so the region generator can claim them as data instead of leaving a three-byte
        # hole in the middle of a code region.
        self.inline_data.append({"offset": self.m.offset(bank, addr - (0xC000 if bank ==
                                 self.m.fixed else 0x8000) + 3), "size": 3,
                                 "kind": "farcall", "bank": bank, "addr": addr + 3})
        self.seed(lo & 0x07, target, f"far call from bank {bank} ${addr:04X}")
        return (lo & 0x07, target)

    def _push(self, live, addr, regs, astack) -> None:
        if addr is not None:
            self._work.append((live, addr, regs, astack))

    def _regs(self, insn, regs, astack, live):
        """The constant tracker. Deliberately tiny: it knows immediates, the register
        transfers, `LDA $04`, and the stack. Everything else clears the register it writes,
        because a tracker that guesses is worse than one that says it does not know."""
        a, x, y = regs
        m, mode, op = insn.mnemonic, insn.mode, insn.operand

        if m == "LDA":
            a = op if mode == "imm" else (live if (mode == "zp" and op == BANK_SHADOW) else None)
        elif m == "LDX":
            x = op if mode == "imm" else (live if (mode == "zp" and op == BANK_SHADOW) else None)
        elif m == "LDY":
            y = op if mode == "imm" else (live if (mode == "zp" and op == BANK_SHADOW) else None)
        elif m == "TAX":
            x = a
        elif m == "TAY":
            y = a
        elif m == "TXA":
            a = x
        elif m == "TYA":
            a = y
        elif m == "PHA":
            astack = astack + (a,)
        elif m == "PLA":
            a, astack = (astack[-1], astack[:-1]) if astack else (None, astack)
        elif m == "PHP":
            astack = astack + (None,)
        elif m == "PLP":
            astack = astack[:-1] if astack else astack
        elif m in ("INX", "DEX"):
            x = None if x is None else (x + (1 if m == "INX" else -1)) & 0xFF
        elif m in ("INY", "DEY"):
            y = None if y is None else (y + (1 if m == "INY" else -1)) & 0xFF
        elif m in ("ADC", "SBC", "AND", "ORA", "EOR", "ASL", "LSR", "ROL", "ROR", "PLA",
                   "TSX"):
            a = None if m != "TSX" else a
            if m == "TSX":
                x = None
        elif m in ("LAX",):
            a = x = None
        # Anything not named above leaves the registers alone: it either does not write one
        # (a store, a compare, a branch) or is an illegal opcode the trace should not be
        # meeting anyway.
        return (a, x, y), astack


# ---------------------------------------------------------------- assumption 1, checked

ABI = {SWITCH_A, FARCALL, *SWITCH_FIXED}


def bank_changing_calls(tr: Trace) -> tuple[set[tuple[int | None, int]], list[dict]]:
    """Which reached routines contain a bank switch, and which call sites enter them.

    The trace assumes a JSR returns with the live bank unchanged, except at the nine
    routines it special-cases. That assumption is what attributes everything after a call
    to the right bank, so it should not be left as prose. This walks each routine's own
    body - branches and JMPs, but not into its callees - then propagates through the call
    graph to a fixed point, and returns the call sites the assumption is doing real work at.

    What it reports is **untested**, not wrong. A routine that switches and switches back -
    the `PHA / JSR $D714 / ... / PLA / JSR $D705` idiom, which is all over this ROM - has no
    net effect and is still listed here, because deciding that needs dataflow this does not
    do. Read the list as "these are the places to check", in the sense of playbook section
    10: a completeness claim is a claim about your mechanism.
    """
    bodies: dict[tuple[int | None, int], dict] = {}
    for site in tr.callsites:
        key = (site["live"], site["target"])
        if key in bodies or site["target"] in ABI:
            continue
        switches, callees, seen, work = False, set(), set(), [site["target"]]
        live = site["live"]
        while work:
            addr = work.pop()
            while addr not in seen:
                insn = tr.m.decode_at(live, addr)
                if insn is None or insn.mnemonic == "TRUNC":
                    break
                seen.add(addr)
                if insn.mnemonic == "JSR":
                    if insn.target in ABI and insn.target != FARCALL:
                        switches = True
                    elif insn.target is not None:
                        callees.add((live, insn.target))
                elif insn.mnemonic == "JMP" and insn.target in ABI:
                    switches = True
                    break
                elif insn.mnemonic in BRANCHES:
                    work.append(insn.target)
                elif insn.mnemonic == "JMP":
                    if insn.mode == "abs":
                        addr = insn.target
                        continue
                    break
                elif insn.mnemonic in ("RTS", "RTI", "BRK", "KIL"):
                    break
                addr += insn.size
        bodies[key] = {"switches": switches, "callees": callees}

    # Deliberately NOT propagated through the call graph. Transitive closure was tried and
    # is useless here: almost everything eventually calls something that switches, so it
    # marked 236 of the reached routines and 351 call sites, which is a list nobody can act
    # on. What makes the closure meaningless is that the restoring idiom - switch, call,
    # switch back - is indistinguishable from a net change without dataflow this does not
    # do, so every restorer propagates as though it were a changer. The direct list is the
    # one worth reading: these routines switch the bank in their own bodies.
    changers = {k for k, b in bodies.items() if b["switches"]}
    sites = [s for s in tr.callsites
             if s["target"] not in ABI and (s["live"], s["target"]) in changers]
    return changers, Trace._by_site(sites, "bank", "addr", "target")


# ---------------------------------------------------------------- reporting

def _runs(offsets: set[int], meta: dict) -> list[tuple[int, int]]:
    """Contiguous traced stretches, split at bank boundaries."""
    out: list[tuple[int, int]] = []
    edges = {meta["prg_offset"] + n * meta["prg_bank_size"]
             for n in range(meta["prg_bank_count"] + 1)}
    for off in sorted(offsets):
        if out and off == out[-1][1] and off not in edges:
            out[-1] = (out[-1][0], off + 1)
        else:
            out.append((off, off + 1))
    return out


def _where(meta: dict, off: int) -> str:
    rel = off - meta["prg_offset"]
    bank = rel // meta["prg_bank_size"]
    return f'bank {bank} ${bank_window(meta, bank) + rel % meta["prg_bank_size"]:04X}'


ASSUMPTIONS = """\
What this trace's answer rests on
---------------------------------
Every line is a way the reported coverage could be too low or too high. None of them is
hypothetical: each is a mechanism the model does not have. The illegal-opcode count is
currently zero, which says the trace stayed on the rails everywhere it went - it says
nothing at all about where it did not go.

 1. **A JSR is assumed to return with the live bank unchanged**, except at the nine switch
    routines and the far-call trampoline, which are special-cased. A callee that switches
    the bank and returns would make everything the caller does afterwards be attributed to
    the wrong bank. --risky lists the call sites where this is doing real work: they are
    computed from the trace, not assumed, and the list is untested rather than wrong.
 2. **JMP to a switch routine is not followed.** The bank change lands in a caller this
    walk cannot see. Each site is reported as a lead.
 3. **JMP (indirect) is not followed**, and neither is any address built at runtime - an
    RTS dispatch, a jump through a RAM vector, a computed JMP. One RAM vector is already
    known: JMP ($10C0) in bank 2, where $10C0 mirrors $00C0 in CPU RAM. Playbook section 4
    records a RAM NMI vector hiding a quarter of a bank on another cartridge. Nothing that
    installs this one has been looked for.
 4. **The inline PPU strings are stepped over on a rule read from $D591**, not on a
    terminator: (first byte & $7F) + 3, less two for $D53F. Every one of the 32 blocks
    resumes on a legal opcode, which is 32 independent agreements and is why this is in the
    model rather than in the leads. What it does NOT establish is the $C0-and-above form:
    two sites use it, its length is a fixed 9, and nothing says what the nine bytes are.
 5. **The inline jump tables are read at one entry each.** The trace resolves the entry the
    caller's index selects and no other, because nothing in the helper bounds the index.
    The count has to come from each caller - per playbook section 3, from an index mask or
    a CPY bound, never from dividing the gap.
 6. **Dispatch tables in data are not resolved.** annotations/dispatch.json has an
    unresolved list, and an empty one would be a weaker statement than it sounds: it says
    every table the file knows about is resolved, not that every table is in the file.
 7. **The entry-table length is a definition, not a finding.** It is the maximal run of $4C
    at three-byte spacing from the window base, which is an upper bound: a run of JMPs can
    end by running into code that happens to start with one. The independent check is that
    34 of the 35 far calls resolved land on a slot of one of these tables, and the 35th
    targets the fixed bank with a bank preselected rather than an entry at all.
 8. **The constant tracker is per path and shallow.** It knows immediates, the register
    transfers, LDA $04 and the stack; it does not follow a value through memory, and it does
    not merge the register states of two paths meeting at one address. The first visitor to
    an address wins, which is the bug playbook section 6 names for find-callargs: a second
    predecessor carrying different constants is never walked.
 9. **"Never returns" is conservative by construction.** `_can_return` answers "it may
    return" for anything it cannot reason about - an indirect jump, an illegal opcode, a
    bank switch through A. So the 26 it names are sound and the list is a lower bound;
    a routine that really never returns but exits through something unmodelled is still
    treated as returning, and the bytes after the call are still decoded.
10. **A bank is entered only where something reaches it.** Bank 4 is at 19 bytes of 16,384
    and nothing in the ROM far-calls it. "Nothing reaches this" is a claim about the
    searcher, not the ROM.
11. **No latch write outside the nine routines is modelled.** On UxROM *any* store into
    $8000-$FFFF loads the bank register, so a stray STA $8000 would switch banks. An
    instruction-walk inventory of such stores over traced code is the check for this, and it
    has not been built. A byte scan is useless here - it returns thousands of operand bytes
    decoded as store opcodes.\
"""


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--runs", action="store_true", help="the contiguous traced stretches")
    ap.add_argument("--gaps", action="store_true", help="what is still unreached")
    ap.add_argument("--leads", action="store_true", help="transfers the trace could not follow")
    ap.add_argument("--calls", action="store_true", help="resolved far calls")
    ap.add_argument("--seeds", action="store_true", help="where the trace was started from")
    ap.add_argument("--switches", action="store_true", help="every bank-switch site reached")
    ap.add_argument("--inline", action="store_true",
                    help="call sites with inline argument data, and what follows them")
    ap.add_argument("--illegal", action="store_true",
                    help="every instruction start whose opcode is not one of the 151")
    ap.add_argument("--risky", action="store_true",
                    help="call sites where the bank-unchanged assumption is doing real work")
    ap.add_argument("--assumptions", action="store_true", help="what the answer rests on")
    ap.add_argument("--json", metavar="PATH", help="write the raw result for other tools")
    args = ap.parse_args()

    try:
        rm = load(ROOT)
        _verify_abi(rm.rom, rm.meta)
    except AnnotationError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    tr = Trace(rm)
    passes = tr.run_to_fixpoint()
    meta = rm.meta
    size = meta["prg_size"]

    print(f"{len(tr.covered):,} of {size:,} PRG bytes reached as code "
          f"({100 * len(tr.covered) / size:.2f}%), "
          f"{len(tr.starts):,} instruction starts, from {len(tr.seeds)} seeds")

    # The rails signal, per playbook section 9.5. A trace that has walked into data decodes
    # it happily and reports coverage anyway; the one cheap thing that says otherwise is an
    # opcode outside the documented 151. The undocumented NOPs count as illegal here on
    # purpose - they take operands, so a decode that accepts them walks through arbitrary
    # data while reporting that it never met an illegal opcode.
    illegal = [o for o in tr.starts if rm.rom[o] not in DOCUMENTED]
    pct = 100 * len(illegal) / max(len(tr.starts), 1)
    print(f"{len(illegal)} illegal or undocumented opcodes among the instruction starts "
          f"({pct:.3f}%)"
          + ("   <-- the trace has left the rails somewhere" if illegal else ""))
    print()
    for n in range(meta["prg_bank_count"]):
        start = meta["prg_offset"] + n * meta["prg_bank_size"]
        end = start + meta["prg_bank_size"]
        got = sum(1 for o in tr.covered if start <= o < end)
        print(f"  bank {n}  {got:>6,} / {meta['prg_bank_size']:,}  "
              f"({100 * got / meta['prg_bank_size']:6.2f}%)")

    # The one check on the entry tables that does not come from their own definition: a far
    # call names its target as a raw address, so nothing forces it to land on a slot.
    slots = {(n, a) for n in range(meta["prg_bank_count"]) for a in tr.entry_table(n)}
    far = tr.sites_farcalls
    on_slot = [c for c in far if (c["to_bank"], c["target"]) in slots]
    into_fixed = [c for c in far if c["target"] >= 0xC000]
    odd = [c for c in far if c not in on_slot and c not in into_fixed]
    print(f"\n{len(far)} far-call sites resolved: {len(on_slot)} onto an entry-table slot, "
          f"{len(into_fixed)} into the fixed bank with a bank preselected, {len(odd)} other")
    for c in odd:
        print(f"  neither: bank {c['bank']} ${c['addr']:04X} -> "
              f"bank {c['to_bank']} ${c['target']:04X}")

    changers, risky = bank_changing_calls(tr)
    stops = Trace._by_site(tr.nonreturn_sites, "bank", "addr")
    print(f"\n{len(tr.nonreturning)} reached routines never return - no RTS is reachable in "
          f"any of them - and the walk stops at {len(stops)} call sites because of it "
          f"(settled in {passes} passes)")
    print(f"{len(tr.sites_switches)} bank-switch sites reached, "
          f"{len(tr.sites_leads)} leads, "
          f"{len(tr.unknown_bank_entries)} entries into $8000-$BFFF with the bank unknown")
    print(f"{len(changers)} reached routines contain a bank switch; "
          f"{len(risky)} call sites enter one, and the trace assumes each returns with the "
          "bank unchanged")

    if args.risky:
        print("\ncall sites where assumption 1 is doing real work:")
        for s in sorted(risky, key=lambda s: (s["bank"], s["addr"])):
            print(f"  bank {s['bank']} ${s['addr']:04X}  JSR ${s['target']:04X}")
        print("  (untested, not wrong: a routine that switches and switches back is still "
              "listed, because deciding that needs dataflow this tool does not do)")
    if args.inline:
        print(f"\n{len(tr.sites_inline)} inline-argument call sites:")
        for c in sorted(tr.sites_inline, key=lambda c: (c["bank"], c["addr"])):
            print(f"  bank {c['bank']} ${c['addr']:04X}  JSR ${c['target']:04X}  {c['kind']}")
        print(f"\n{len(tr.sites_dispatched)} inline jump-table entries resolved:")
        for c in sorted(tr.sites_dispatched, key=lambda c: (c["bank"], c["addr"])):
            print(f"  bank {c['bank']} ${c['addr']:04X}  entry {c['index']}  ->  "
                  f"${c['target']:04X}")
        print(f"\n{len(tr.unconditional_pairs)} complementary branch pairs whose "
              "fall-through was NOT followed:")
        for c in Trace._by_site(tr.unconditional_pairs, "bank", "addr"):
            print(f"  bank {c['bank']} ${c['addr']:04X}  {c['pair']}")
    if args.illegal:
        print(f"\n{len(illegal)} illegal or undocumented instruction starts:")
        for o in sorted(illegal):
            m, mode = OPCODES[rm.rom[o]]
            print(f"  0x{o:05X}  {_where(meta, o)}  {rm.rom[o]:02X}  {m} {mode}")
    if args.seeds:
        print("\nseeds:")
        for s in tr.seeds:
            b = "bank ?" if s["bank"] is None else f'bank {s["bank"]}'
            print(f"  {b:<7} ${s['addr']:04X}  {s['why']}")
    if args.calls:
        print("\nfar calls:")
        for c in sorted(tr.sites_farcalls, key=lambda c: (c["bank"], c["addr"])):
            mark = "" if (c["to_bank"], c["target"]) in slots else "   <- not an entry slot"
            print(f"  bank {c['bank']} ${c['addr']:04X}  ->  bank {c['to_bank']} "
                  f"${c['target']:04X}{mark}")
    if args.switches:
        print("\nbank switches:")
        for s in sorted(tr.sites_switches, key=lambda s: (s["bank"], s["addr"])):
            print(f"  bank {s['bank']} ${s['addr']:04X}  ->  bank {s['to']}  ({s['how']})")
    if args.leads:
        print(f"\n{len(tr.sites_leads)} leads:")
        for l in sorted(tr.sites_leads, key=lambda l: (l["bank"], l["addr"])):
            print(f"  bank {l['bank']} ${l['addr']:04X}  {l['why']}")
    if args.runs:
        runs = _runs(tr.covered, meta)
        print(f"\n{len(runs)} traced runs:")
        for a, b in runs:
            print(f"  0x{a:05X}-0x{b - 1:05X}  {b - a:>6,} B  {_where(meta, a)}")
    if args.gaps:
        runs = _runs(set(range(meta["prg_offset"], meta["prg_offset"] + size)) - tr.covered,
                     meta)
        print(f"\n{len(runs)} unreached stretches, largest first:")
        for a, b in sorted(runs, key=lambda r: r[0] - r[1])[:30]:
            print(f"  0x{a:05X}-0x{b - 1:05X}  {b - a:>6,} B  {_where(meta, a)}")
    if args.assumptions:
        print()
        print(ASSUMPTIONS)

    if args.json:
        Path(args.json).write_text(json.dumps({
            "covered": sorted(tr.covered),
            "starts": sorted(tr.starts),
            "farcalls": tr.sites_farcalls,
            "switches": tr.sites_switches,
            "leads": tr.sites_leads,
            "seeds": tr.seeds,
        }), encoding="utf-8")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
