"""The tile codec: how The Guardian Legend stores CHR data in a CHR RAM cartridge.

The format, and how it was established
--------------------------------------
A block is ``[escape][?] <sections...>``. Decoding starts in LITERAL mode and the escape
byte toggles between two modes:

* **literal** - every byte that is not the escape is one output byte.
* **run** - entered by the escape byte; a sequence of ``[value][count]`` PAIRS, each
  emitting ``value`` ``count`` times. The escape byte ends the section.

Two escape bytes in a row - an EMPTY section, in either mode - end the block. That single
rule covers both shapes seen in the data: ``literals ESC ESC`` (empty run section) and
``ESC pairs... ESC ESC`` (empty literal section). The compressor picks a byte that does not
occur in the block's literal data, which is why the escape differs per block and why values
like ``$FD`` and ``$A4`` turn up alongside ``$01``.

The second header byte is NOT established. It is always greater than the escape, often by
one, and nothing in the decode needs it.

What checks this, and what does not
-----------------------------------
1. **The partition.** Each bank's blocks are named by a pointer table, and a block decoded
   with the rule above ends EXACTLY on the next pointer - 21 of 22 in bank 1 (the last runs
   to the bank's tail padding), and the same in banks 2 and 3. Nothing was tuned to make
   that happen; the terminator rule was derived from four blocks and then predicted the
   other eighteen.
2. **The escape is forced.** Brute-forcing all 256 possible escape values against the
   partition test leaves exactly ONE survivor for 14 of bank 1's blocks, and it is header
   byte 1 every time.
3. **Hardware.** Decoding these blocks out of the ROM reproduces 339 of the 512 tiles of an
   in-game savestate's live CHR RAM byte for byte. That is the hardware's own answer, not
   this project agreeing with itself.

What is NOT claimed: that these tables are all of them (bank 0 has tile-shaped data and no
table has been found for it), that the second header byte is understood, or that the three
blocks whose output is 3 bytes over a whole number of tiles are understood.
"""

from __future__ import annotations

# Pointer tables, per bank, as (cpu address, entry count). Established by the partition
# test above; the $FFFF and $0000 words between groups are separators, not pointers.
TABLES: dict[int, list[tuple[int, int]]] = {
    1: [(0x8010, 22)],
    2: [(0x8024, 13), (0x8042, 21)],
    3: [(0x8022, 6), (0x8040, 47)],
}


def decode(data: bytes, off: int, cap: int = 0x4000) -> tuple[bytes, int]:
    """Decode one block at ``off`` in a 16 KB bank image. Returns (tiles, bytes consumed)."""
    esc = data[off]
    s = off + 2
    out = bytearray()
    while s < len(data) and len(out) < cap:
        c = data[s]
        s += 1
        if c != esc:
            out.append(c)
            continue
        if s < len(data) and data[s] == esc:        # empty run section -> end of block
            return bytes(out), s + 1 - off
        while s + 1 < len(data):
            v = data[s]
            s += 1
            if v == esc:
                if s < len(data) and data[s] == esc:  # empty literal section -> end
                    return bytes(out), s + 1 - off
                break
            out += bytes([v]) * data[s]
            s += 1
    return bytes(out), s - off


def table_pointers(data: bytes, bank: int) -> list[int]:
    """Every pointer the bank's tables name, in table order, duplicates kept."""
    out = []
    for addr, count in TABLES.get(bank, []):
        o = addr - 0x8000
        out += [data[o + 2 * i] | (data[o + 2 * i + 1] << 8) for i in range(count)]
    return out


def blocks(data: bytes, bank: int) -> list[dict]:
    """Every block in the bank, found by chaining forward from the first pointer.

    Chaining is the check: a block's decoded length says where the next one starts, so a
    wrong length derails the rest of the bank immediately instead of failing quietly.
    """
    ptrs = set(table_pointers(data, bank))
    if not ptrs:
        return []
    # Start at the lowest pointer that actually behaves like a block: one whose decoded
    # length lands exactly on another pointer. Bank 2's table also names the font block
    # (a different format, see annotations/regions/41-font.json) and one code address, and
    # neither of those would chain.
    start = None
    for p in sorted(ptrs):
        if p + decode(data, p - 0x8000)[1] in ptrs:
            start = p
            break
    if start is None:
        return []
    out, p = [], start
    while p < 0xC000 - 4:
        dec, used = decode(data, p - 0x8000)
        if used < 4 or not dec:
            break
        out.append({"addr": p, "size": used, "esc": data[p - 0x8000],
                    "hdr2": data[p - 0x8000 + 1], "tiles": dec,
                    "in_table": p in ptrs})
        p += used
    return out
