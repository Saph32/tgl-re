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
* ``$882D`` draws it **on the status screen** (Select during play). It walks rows 0-23 only
  (``CMP #$18`` on ``$14``) and draws **background tiles, two by two cells each**: ``$891F``
  ORs a quadrant bit into a 12-byte row buffer at ``$0150`` - 1 and 2 for an even row, 4 and
  8 for an odd one, doubled for an odd column - and every second row the buffer is queued as
  12 tiles with 0 replaced by ``$20``. So tiles ``$01-$0F`` are the fifteen quadrant patterns.
  **Hardware sprites mark area entrances only**, one at ``column * 4 + $10``,
  ``row * 4 + $3B``, tile ``$01`` - the one-quadrant tile, a single cell. Bank 2 ``$8998``
  blinks one more at (``$52``, ``$53``) with the same arithmetic: the player's position.

What a record's bytes mean
--------------------------
* **byte 0** - the low nibble is the length minus one; ``$80`` exactly is an empty cell and
  is skipped outright. Bit 7 is required, with byte 2's bit 7, before an entrance sprite is
  drawn.
* **byte 1** - the low three bits name the **key** that reveals the cell. ``$8860``
  subtracts one, calls ``$C078`` for a bit, ANDs with ``$04B0`` and skips the cell when the
  bit is clear. ``$04B0`` is the key inventory: bank 7 ``$F547`` sets bit k-1 when key k is
  collected, and the status screen draws key k's icon only when it is set. 0 means no key.
* **byte 2** - bit 7 marks an **area entrance**, and the low seven bits are the area number.
  The entrance sprite is then drawn only while the area's bit in ``$04A9`` is clear
  (``$C07B``) - except area 21, drawn only when ``$04A9`` is ``$FF`` and bits 0-1 of
  ``$04AA`` are set: areas 1 to 10 all flagged.

**CORRECTION.** The first version of this header said every qualifying cell becomes a sprite,
that byte 0 bit 7 means "drawn on the map", and that byte 1 is a progress flag "that hides
the map until you have been there". Reading the rest of the routine (``$891F`` and the flush
at ``$88DF``) and the status screen around it showed all three wrong as stated.

**The checks that carry it:** the records with byte 0 of ``$82`` and byte 2's bit 7 set carry
the area numbers **1 to 21, each exactly once**, and **all 21 lie in rows 0-23**, the rows the
status screen draws. And the keys they need repeat with period ten - areas 1-10 need keys
0, 1, 2, 3, 4, 4, 5, 5, 6, 7 and areas 11-20 need 1, 1, 2, 3, 4, 4, 5, 5, 6, 7, area 21 none.

What is NOT established
-----------------------
Bits 4 to 6 of byte 0, and everything past byte 2 in the longer records - a record runs to
16 bytes. **Rows 24-33** (231 records, the last row 15 long) are walked by the seek like the
rest but never drawn on the status screen, and hold no entrance; what they are is open. What
the ``$04A9`` flag means in play ("cleared" is the obvious reading) is not established.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl.model import load
from tgl.worldmap import (COLUMNS, DRAWN_ROWS, EMPTY, END, ENTRANCE, START, entrances,
                          key, records)

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "annotations" / "regions" / "77-bank5-map.json"

BANK = 5


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
    print(f"{sum(1 for r in recs if r['b'][0] == EMPTY)} cells are empty (byte 0 == $80)")
    print(f"entrance rows: {sorted(r['row'] for r in ent)}  -> all inside rows 0-{DRAWN_ROWS - 1}, "
          f"the rows the status screen draws: {all(r['row'] < DRAWN_ROWS for r in ent)}")
    by_area = {r["b"][2] & 0x7F: r for r in ent}
    keys = [key(by_area[a]) for a in sorted(by_area)]
    print(f"key each area needs (byte 1 AND 7), areas 1-21: {keys}")
    print("  -> areas 1-10 and 11-20 differ only in the first: "
          + str(keys[1:10] == keys[11:20]))

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
                else:
                    line += str(key(r)) if key(r) else "#"
            print(f" {row:2d} {line}")
            if row == DRAWN_ROWS - 1:
                print("    " + "-" * COLUMNS + "  (the status screen draws the rows above)")
        print("\n A = area entrance, # = a cell needing no key, 1-7 = the key that reveals "
              "it, . = empty")

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
                   "- four pixels a cell, 96 across, as background tiles each covering "
                   "two by two cells (a quadrant bitmask built by $891F in $0150). Only rows "
                   "0-23 are drawn. Hardware sprites mark area entrances only. "
                   "BYTE 0's low nibble is the length minus one; $80 exactly is an empty "
                   "cell. BYTE 1's low three bits name the KEY that reveals the cell - $8860 "
                   "subtracts one, calls $C078 for a bit mask and ANDs with $04B0, the key "
                   "inventory bank 7 $F547 fills. BYTE 2 bit 7 marks an AREA ENTRANCE and the "
                   "low seven bits are the area number; its sprite shows while the area's "
                   "$04A9 bit is clear, and area 21's only once areas 1-10 are all flagged. "
                   "CORRECTION: an earlier version said every drawn cell is a sprite, that "
                   "byte 0 bit 7 means 'drawn', and that byte 1 is a been-there flag. "
                   f"THE CHECK: the {len(ent)} records with byte 0 of $82 and byte 2 bit 7 "
                   "set carry the area numbers 1 to 21, EACH EXACTLY ONCE. Twenty-one areas "
                   "is what this project established from an unrelated direction - bank 4's "
                   "per-area table and the CPY #$15 tests - and nothing here was tuned to "
                   "produce it. All 21 lie in rows 0-23, and the keys they need repeat with period "
                   "ten across areas 1-10 and 11-20. The extent: walking the whole stream "
                   f"lands on ${END:04X}, the first byte of the dialogue pointer table. "
                   "NOT ESTABLISHED: bits 4-6 of byte 0, everything past byte 2 in the "
                   "longer records, which run to 16 bytes, and rows 24-33 - 231 records the "
                   "status screen never draws, holding no entrance."}]}
    text = json.dumps(doc, indent=2) + "\n"
    if args.check:
        print("\nno change" if OUT.exists() and OUT.read_text() == text else "\nWOULD CHANGE")
        return 0
    OUT.write_text(text)
    print(f"\nwrote {OUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
