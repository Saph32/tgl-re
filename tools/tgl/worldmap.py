"""Bank 5's world map stream: the walk both `tools/parse-map.py` and the site use.

The format and every check behind it are in the header of `tools/parse-map.py`.
"""

from __future__ import annotations

START = 0x8A6E
END = 0x960F          # the dialogue pointer table; the walk must land here exactly
COLUMNS = 0x18        # $80F5: CMP #$18
DRAWN_ROWS = 0x18     # $88DF: the status screen stops at CMP #$18 on $14
ENTRANCE = 0x82       # byte 0 of an area entrance
EMPTY = 0x80


def records(b5: bytes):
    """Every record as {addr, n, b, row, col}, and the address the walk ended on."""
    out, a, col, row = [], START, 0, 0
    while a < END:
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
