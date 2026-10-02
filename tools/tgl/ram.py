"""A cross-reference of the console's RAM ($0000-$07FF), built from the traced code.

Every instruction in every region the build calls code is decoded once, in the bank the
region sits in, and each operand that names a RAM address is recorded with how it is used:

* **read** - LDA/LDX/LDY, CMP/CPX/CPY, ADC/SBC, AND/ORA/EOR, BIT;
* **write** - STA/STX/STY;
* **modify** - INC/DEC and the shifts and rotates on memory.

An indexed operand (``LDA $0500,X``) names the base of an array, not one byte: it is
recorded as an *indexed* access to the base and the entry says so. An indirect pointer
(``LDA ($16),Y``) records a read of the pointer's two zero-page bytes. Instructions that
are not in a code region are not seen, so a byte touched only by code the trace has not
reached shows no accesses - **absence here is not evidence a byte is unused**.

What this is not: it does not know a byte's meaning, and it cannot see an access through
a pointer or an index it computes (``$0500 + $18 f + s`` is seen as the base ``$0500 + $18 f``
only where code spells that base). The meanings are in ``annotations/ram.json``, written by
hand, each with its evidence.
"""

from __future__ import annotations

from collections import defaultdict

from . import disasm

READS = {"LDA", "LDX", "LDY", "CMP", "CPX", "CPY", "ADC", "SBC", "AND", "ORA", "EOR", "BIT"}
WRITES = {"STA", "STX", "STY"}
MODIFY = {"INC", "DEC", "ASL", "LSR", "ROL", "ROR"}
RAM_END = 0x0800
MAX_SITES = 6


def _kind(mn: str) -> str | None:
    if mn in READS:
        return "r"
    if mn in WRITES:
        return "w"
    if mn in MODIFY:
        return "m"
    return None


def build(rm) -> dict[int, dict]:
    """address -> {r, w, m, indexed, banks, sites[(bank, pc, mnemonic)]} for every RAM
    address any traced instruction names."""
    prg, bsz = rm.meta["prg_offset"], rm.meta["prg_bank_size"]
    banks = {n: rm.prg_bank(n) for n in range(rm.meta["prg_bank_count"])}
    acc: dict[int, dict] = defaultdict(lambda: {"r": 0, "w": 0, "m": 0, "indexed": 0,
                                                "banks": set(), "sites": []})

    def note(addr, kind, bank, pc, mn, indexed=False):
        if not 0 <= addr < RAM_END:
            return
        e = acc[addr]
        e[kind] += 1
        e["banks"].add(bank)
        if indexed:
            e["indexed"] += 1
        if len(e["sites"]) < MAX_SITES:
            e["sites"].append((bank, pc, mn))

    for r in rm.regions:
        if r["kind"] != "code" or r["offset"] < prg:
            continue
        bank = (r["offset"] - prg) // bsz
        data = banks[bank]
        base = 0xC000 if bank == rm.meta["prg_bank_count"] - 1 else 0x8000
        pc, end = r["cpu_addr"], r["cpu_addr"] + r["size"]
        while pc < end:
            i = disasm.decode(data, pc - base, pc)
            if i.illegal or i.size == 0:
                pc += max(i.size, 1)
                continue
            kind = _kind(i.mnemonic)
            mode, op = i.mode, i.operand
            if kind and op is not None:
                if mode in ("zp", "abs"):
                    note(op, kind, bank, pc, i.mnemonic)
                elif mode in ("zpx", "zpy", "abx", "aby"):
                    note(op, kind, bank, pc, i.mnemonic, indexed=True)
                elif mode in ("izx", "izy"):
                    note(op, "r", bank, pc, i.mnemonic)
                    note((op + 1) & 0xFF, "r", bank, pc, i.mnemonic)
            elif i.mnemonic in ("JMP", "JSR") and False:
                pass
            pc += i.size
    return dict(acc)
