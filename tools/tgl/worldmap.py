"""Bank 5's world map, its room shapes and its room layouts: the walks `tools/parse-map.py`
and the site share.

The format and every check behind it are in the header of `tools/parse-map.py`.
"""

from __future__ import annotations

START = 0x8A6E
COLUMNS = 0x18        # $80F5: CMP #$18
DRAWN_ROWS = 0x18     # $88DF: the status screen stops at CMP #$18 on $14
ROWS = 0x18           # 24 x 24 records, and then the shapes begin
MAP_END = 0x91EA      # $8042: LDA #$91 / ADC #$EA - the shape table's own base
SHAPE_SIZE = 18       # $8042 multiplies by 18; $828C: CPY #$12
SHAPES = 19           # shapes 0-18 are used, and 19 x 18 lands on the first layout
LAYOUTS = MAP_END + SHAPES * SHAPE_SIZE      # $9340
END = 0x960F          # the dialogue pointer table; the layout chain lands here exactly
ENTRANCE = 0x82       # byte 0 of a corridor entrance
EMPTY = 0x80

# Byte 0 bits 5-6, stored in $5D by $8121.
# CORRECTION: these were "sub-id", "special" and "entrance" - read off $A3BB and $A663 (see
# tgl/labyrinth.py): kind $20 holds an item, $40 a miniboss, $60 a loop gate. Byte 0 bit 7,
# not the kind, makes a record a special screen (corridor entrances among them).
KINDS = {0x00: "plain", 0x20: "item", 0x40: "miniboss", 0x60: "loop gate"}


def records(b5: bytes, end: int = MAP_END):
    """Every record as {addr, n, b, row, col}, and the address the walk ended on."""
    out, a, col, row = [], START, 0, 0
    while a < end:
        n = (b5[a - 0x8000] & 0x0F) + 1
        out.append({"addr": a, "n": n, "b": list(b5[a - 0x8000:a - 0x8000 + n]),
                    "row": row, "col": col})
        a += n
        col += 1
        if col == COLUMNS:
            col = 0
            row += 1
    return out, a


def entrances(recs):
    return [r for r in recs if r["b"][0] == ENTRANCE and len(r["b"]) > 2
            and r["b"][2] & 0x80]


def key(r) -> int:
    """The key that reveals a cell, 0 for none: byte 1 AND 7, tested by $8860."""
    return r["b"][1] & 7 if r["n"] > 1 else 0


def fields(r) -> dict:
    """The optional fields after byte 2, in the order $8121 and $8243 read them.

    A sub-id when the kind is $20 or $40 ($5E), then the spawn script id when byte 1 bit 3
    is set ($57, 0 read as 1), then a two-byte layout pointer when byte 0 bit 4 is set.
    `need` is the length those flags imply; for every non-empty record it equals the
    record's own length.
    """
    b = r["b"]
    kind = b[0] & 0x60
    i, out = 3, {"kind": kind}
    if kind in (0x20, 0x40):
        out["sub"] = b[i] if i < len(b) else None
        i += 1
    if len(b) > 1 and b[1] & 0x08:
        out["script"] = (b[i] or 1) if i < len(b) else None
        i += 1
    if b[0] & 0x10:
        out["layout"] = (b[i] | b[i + 1] << 8) if i + 1 < len(b) else None
        i += 2
    out["need"] = i
    return out


def layouts(b5: bytes):
    """The layout chain from $9340: (address, length) for each, and where it ended.

    A layout is [shape | count << 5][fill tile], then count x [tile][position][mask|dir] -
    read by $8243 and $82A3, so its length is 2 + 3 * count."""
    out, a = [], LAYOUTS
    while a < END:
        n = 2 + 3 * (b5[a - 0x8000] >> 5)
        out.append((a, n))
        a += n
    return out, a
