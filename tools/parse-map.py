#!/usr/bin/env python3
"""Walk bank 5's map stream into `annotations/regions/77-bank5-map.json`.

    python tools/parse-map.py          # rewrite the file, print the checks
    python tools/parse-map.py --check  # report, write nothing
    python tools/parse-map.py --grid   # draw the map as a 24-column grid
    python tools/parse-map.py --areas  # just the 21 area entrances

**The output file is generated. A hand edit to it is lost on the next run.**

What the stream is
------------------
**The world map.** Bank 5 ``$8A6E-$960E`` is 807 variable-length records, twenty-four to a
row, and two routines walk it:

* ``$80F5`` is a **seek**. ``$8103`` does ``LDA ($16),Y / AND #$0F / SEC / ADC $16``, so a
  record is ``(first byte AND $0F) + 1`` bytes and the ``SEC`` supplies the plus one. ``$15``
  counts columns to ``CMP #$18`` then rolls into a row counter ``$14``, and the walk stops
  when (row, column) reaches the pair the caller asked for.
* ``$8853`` is the **map screen**. For each cell that passes its tests it writes one hardware
  sprite: ``$0203,Y`` gets ``column * 4 + $10``, ``$0200,Y`` gets ``row * 4 + $3B``, the tile
  is ``$01`` and the attribute ``$03``. Four pixels a cell, so the whole 24-wide map is 96
  pixels across - a minimap.

What a record's bytes mean
--------------------------
* **byte 0** - bit 7 means the cell is drawn on the map screen; the low nibble is the
  length minus one. ``$80`` exactly is an empty cell and ``$8853`` skips it outright.
* **byte 1** - the low three bits select a progress flag. ``$8860`` subtracts one, calls
  ``$C078`` to turn it into a bit, ANDs it with ``$04B0`` and skips the cell when the bit is
  clear, so this is what hides parts of the map until you have been there.
* **byte 2** - bit 7 marks an **area entrance**, and the low seven bits are the area number.

**The check that carries all of it:** the records with byte 0 of ``$82`` and byte 2's bit 7
set carry the area numbers **1 to 21, each exactly once**. Twenty-one areas is what the game
has and what this project established from an unrelated direction - the bank 4 screen-data
table and the ``CPY #$15`` tests. Nothing was tuned to produce that.

What is NOT established
-----------------------
Bits 4 to 6 of byte 0, and everything past byte 2 in the longer records - a record runs to
16 bytes. 807 is not a multiple of 24, so the last row holds 15 records rather than 24, and
whether that is a short row or a different structure is unknown. The three records that pass
a loose version of the entrance test but carry byte 2 values of 32, 120 and 124 all have a
byte 0 other than ``$82`` and are a different record type.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl.model import load

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "annotations" / "regions" / "77-bank5-map.json"

BANK = 5
START = 0x8A6E
END = 0x960F          # the dialogue pointer table; the walk must land here exactly
COLUMNS = 0x18        # $80F5: CMP #$18
ENTRANCE = 0x82       # byte 0 of an area entrance
EMPTY = 0x80


def records(b5: bytes):
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


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--grid", action="store_true")
    ap.add_argument("--areas", action="store_true")
    args = ap.parse_args()

    rm = load(ROOT, exclude={OUT.name})
    b5 = rm.prg_bank(BANK)
    recs, landed = records(b5)
    ent = entrances(recs)
    areas = sorted(r["b"][2] & 0x7F for r in ent)
    rows = max(r["row"] for r in recs) + 1

    print(f"{len(recs)} records, ${START:04X}-${END - 1:04X}, walked to ${landed:04X}"
          + ("  (exactly the next claimed region)" if landed == END else "  ** OVERSHOT **"))
    print(f"{rows} rows of {COLUMNS}; the last holds {len(recs) % COLUMNS or COLUMNS}")
    print(f"{len(ent)} area entrances (byte 0 == ${ENTRANCE:02X} and byte 2 bit 7 set)")
    print(f"their area numbers: {areas}")
    print("  -> 1 to 21, each exactly once: "
          + str(areas == list(range(1, 22))))
    print(f"{sum(1 for r in recs if r['b'][0] == EMPTY)} cells are empty (byte 0 == $80); "
          f"{sum(1 for r in recs if r['b'][0] & 0x80)} are drawn on the map screen")

    if args.areas:
        for r in sorted(ent, key=lambda r: r["b"][2] & 0x7F):
            print(f"  area {r['b'][2] & 0x7F:2d}  row {r['row']:2d} col {r['col']:2d}  "
                  f"${r['addr']:04X}  " + " ".join(f"{x:02X}" for x in r["b"]))

    if args.grid:
        grid = {(r["row"], r["col"]): r for r in recs}
        print("\n    " + "".join(f"{c % 10}" for c in range(COLUMNS)))
        for row in range(rows):
            line = ""
            for c in range(COLUMNS):
                r = grid.get((row, c))
                if r is None:
                    line += " "
                elif r in ent:
                    line += "A"
                elif r["b"][0] == EMPTY:
                    line += "."
                elif r["b"][0] & 0x80:
                    line += "#"
                else:
                    line += "-"
            print(f" {row:2d} {line}")
        print("\n A = area entrance, # = drawn on the map, . = empty cell, "
              "- = present but not drawn")

    off = rm.meta["prg_offset"] + BANK * rm.meta["prg_bank_size"] + (START - 0x8000)
    size = END - START
    doc = {"_comment": "GENERATED by tools/parse-map.py - do not hand-edit. Bank 5's world "
                       "map: variable-length records, 24 to a row.",
           "regions": [{
               "id": f"bank{BANK}.map_{START:04X}", "offset": off, "size": size,
               "kind": "level", "name": f"World map: {len(recs)} cells, {COLUMNS} per row",
               "confidence": "confirmed", "cpu_addr": START,
               "sha1": hashlib.sha1(rm.rom[off:off + size]).hexdigest(),
               "description":
                   f"{len(recs)} variable-length records in {rows} rows of {COLUMNS} - the "
                   "world map. A record is (first byte AND $0F) + 1 bytes, stated by $8103: "
                   "LDA ($16),Y / AND #$0F / SEC / ADC $16, the SEC supplying the plus one. "
                   "$80F5 seeks through it counting columns to CMP #$18 and rows in $14. "
                   "$8853 draws it: each qualifying cell becomes one hardware sprite at "
                   "column * 4 + $10 across and row * 4 + $3B down, tile $01, attribute $03 "
                   "- four pixels a cell, 96 across, a minimap. "
                   "BYTE 0 bit 7 means drawn on the map and the low nibble is the length "
                   "minus one; $80 exactly is an empty cell. BYTE 1's low three bits pick a "
                   "progress flag - $8860 subtracts one, calls $C078 for a bit mask, ANDs "
                   "with $04B0 and skips the cell when clear, which is what hides the map "
                   "until you have been somewhere. BYTE 2 bit 7 marks an AREA ENTRANCE and "
                   "the low seven bits are the area number. "
                   f"THE CHECK: the {len(ent)} records with byte 0 of $82 and byte 2 bit 7 "
                   "set carry the area numbers 1 to 21, EACH EXACTLY ONCE. Twenty-one areas "
                   "is what this project established from an unrelated direction - bank 4's "
                   "per-area table and the CPY #$15 tests - and nothing here was tuned to "
                   "produce it. The extent is checked the same way: walking the whole stream "
                   f"lands on ${END:04X}, the first byte of the dialogue pointer table. "
                   "NOT ESTABLISHED: bits 4-6 of byte 0, and everything past byte 2 in the "
                   "longer records, which run to 16 bytes. The last row holds "
                   f"{len(recs) % COLUMNS} records rather than {COLUMNS}."}]}
    text = json.dumps(doc, indent=2) + "\n"
    if args.check:
        print("\nno change" if OUT.exists() and OUT.read_text() == text else "\nWOULD CHANGE")
        return 0
    OUT.write_text(text)
    print(f"\nwrote {OUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
