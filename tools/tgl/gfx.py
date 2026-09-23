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

**The second header byte is a second escape: MIRROR.** Read off the decoder itself, bank 7
``$DB52`` (header loaded by ``$DC5A`` into ``$09``/``$0A``; armed by ``$D7F9``, entry
``$C042``, with the block number in A and the bank in Y). When it meets the mirror byte it
reads a two-byte pointer and continues from there with every output byte bit-reversed
(``$DBCE``, eight ``ASL A / ROR $10``) - a horizontally flipped copy of earlier data - until
the mirror byte comes round again, when it skips that one's two pointer bytes and carries
on. A run count of 0 means 256 (``DEC $08 / BEQ``). **CORRECTION:** this header used to call
the byte "NOT established, nothing in the decode needs it", and three blocks decoded to
"3 bytes over a whole number of tiles" - those three bytes were a mirror reference emitted
as literals. With the mirror implemented every block in banks 0-3 is whole tiles.

**Bank 0's table is at ``$8030``, two entries** - named by ``$D842``/``$D84A``, the per-bank
table bases ``$D7F9`` uses, and called from bank 0 with Y = 0 and A = 0 and 1. The two
blocks, ``$8BBB`` and ``$8D90``, end exactly on ``$917C``, the sound driver's per-frame
entry, and reproduce **38/38 and 128/128** tiles of a title-screen savestate's live CHR.

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
3. **Hardware.** Decoding these blocks out of the ROM reproduces 398 of the 512 tiles of an
   in-game savestate's live CHR RAM byte for byte, and 181 of 512 of a title-screen one
   (18 before bank 0's table was found). That is the hardware's own answer, not
   this project agreeing with itself.

What is NOT claimed: that these tables are all of them. ``$D842`` also names bases for banks
4-7 (``$8003``, ``$8048``, ``$8040``, ``$C000``); no caller found passes those banks.
"""

from __future__ import annotations

# Pointer tables, per bank, as (cpu address, entry count). Established by the partition
# test above; the $FFFF and $0000 words between groups are separators, not pointers.
TABLES: dict[int, list[tuple[int, int]]] = {
    0: [(0x8030, 2)],
    1: [(0x8010, 22)],
    2: [(0x8024, 13), (0x8042, 21)],
    3: [(0x8022, 6), (0x8040, 47)],
}


# Where chaining must stop because the next byte is established as something else. Bank 0's
# second block ends exactly on $917C, the sound driver's per-frame entry (bank 0 slot $8009),
# and a chain that went on would decode that code as a runaway block.
CHAIN_END = {0: 0x917C}


def _rev(b: int) -> int:
    """Bit-reverse a byte: what eight ASL A / ROR $10 pairs at $DBCE do."""
    return int(f"{b:08b}"[::-1], 2)


def decode(data: bytes, off: int, cap: int = 0x4000) -> tuple[bytes, int]:
    """Decode one block at ``off`` in a 16 KB bank image, exactly as bank 7 $DB52 does.

    Returns (tiles, bytes consumed from ``off`` along the block's own stream). A mirror
    back-reference sends the read pointer elsewhere and back past its own three bytes, so
    "consumed" is measured to where the stream ended, not summed over what was read.
    """
    esc, mir = data[off], data[off + 1]
    s = off + 2
    run = mirror = False
    out = bytearray()
    while s < len(data) and len(out) < cap:
        c = data[s]
        s += 1
        if c == esc:                               # $DB91: toggle literal/run
            run = not run
            if s < len(data) and data[s] == esc:   # $DB9C: ESC ESC ends the block
                return bytes(out), s + 1 - off
            continue
        if c == mir:                               # $DBAD: toggle mirror
            mirror = not mirror
            if mirror:                             # jump to the pointer, bit-reversed
                s = (data[s] | data[s + 1] << 8) - 0x8000
            else:                                  # leaving: skip the pointer bytes
                s += 2
            continue
        if mirror:
            c = _rev(c)
        if run:                                    # $DBFB: [value][count], 0 means 256
            n = data[s] or 256
            s += 1
            out += bytes([c]) * n
        else:
            out.append(c)
    return bytes(out), s - off


def mirror_refs(data: bytes, off: int) -> int:
    """How many times a block enters mirror mode along its own stream."""
    esc, mir = data[off], data[off + 1]
    s, run, n = off + 2, False, 0
    while s < len(data):
        c = data[s]
        s += 1
        if c == esc:
            run = not run
            if data[s] == esc:
                return n
        elif c == mir:
            n += 1
            s += 2
        elif run:
            s += 1
    return n


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
    while p < CHAIN_END.get(bank, 0xC000 - 4):
        dec, used = decode(data, p - 0x8000)
        if used < 4 or not dec:
            break
        out.append({"addr": p, "size": used, "esc": data[p - 0x8000],
                    "hdr2": data[p - 0x8000 + 1], "tiles": dec,
                    "in_table": p in ptrs})
        p += used
    return out
