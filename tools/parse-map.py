#!/usr/bin/env python3
"""Walk bank 5's world map, room shapes and room layouts into
`annotations/regions/77-bank5-map.json`.

    python tools/parse-map.py          # rewrite the file, print the checks
    python tools/parse-map.py --check  # report, write nothing
    python tools/parse-map.py --grid   # draw the map as a 24-column grid
    python tools/parse-map.py --areas  # just the 21 area entrances

**The output file is generated. A hand edit to it is lost on the next run.** The walks
themselves are in `tools/tgl/worldmap.py`.

What the block is
-----------------
Bank 5 ``$8A6E-$960E`` is **three** structures, not one:

* ``$8A6E-$91E9`` - **the world map**, 24 x 24 = 576 variable-length records.
* ``$91EA-$933F`` - **19 room shapes**, 18 bytes each: a 1bpp mask, 8 cells a byte, 144
  cells = rows 2-10 of the room's 16-wide buffer at ``$0740``.
* ``$9340-$960E`` - **79 room layouts**, ``2 + 3 x count`` bytes each.

**CORRECTION.** This tool first walked the whole block as 807 map records in 34 rows and
cited "the walk lands exactly on ``$960F``" as the proof of the extent. That check was weak -
with steps of 1-16 bytes, a walk over arbitrary data lands on a given byte about one time in
four - and the conclusion was wrong. Rows 24-33 fail every test the real rows pass, and
their bytes are the room shapes and layouts below.

The map
-------
* ``$80F5`` is a **seek**. ``$8103`` does ``LDA ($16),Y / AND #$0F / SEC / ADC $16``, so a
  record is ``(first byte AND $0F) + 1`` bytes. ``$15`` counts columns to ``CMP #$18`` and
  rolls into a row counter ``$14``. ``$8071`` steps the player's column ``$52`` and row
  ``$53`` and seeks to the new room, whose address it keeps in ``$E4``.
* ``$882D`` draws it **on the status screen**, rows 0-23 (``CMP #$18`` on ``$14``), as
  **background tiles covering 2 x 2 cells**: ``$891F`` ORs a quadrant bit into a 12-byte
  row buffer at ``$0150``, flushed as 12 tiles every second row. **Hardware sprites mark
  area entrances only**, at ``column * 4 + $10``, ``row * 4 + $3B``, tile ``$01``; bank 2
  ``$8998`` blinks one more at (``$52``, ``$53``).

What a record's bytes mean
--------------------------
* **byte 0** - low nibble = length - 1; ``$80`` exactly = empty. **Bit 4** = a layout
  pointer is present. **Bits 5-6** = the room kind, which ``$8121`` stores in ``$5D``:
  ``$20`` and ``$40`` carry a sub-id (``$5E``), and ``$40`` is taken to ``$A663`` instead
  of an ordinary enemy script.
* **byte 1** - low three bits name the **key** that reveals the cell (``$8860`` against
  ``$04B0``, the key inventory bank 7 ``$F547`` fills). **Bit 3** = the room has enemies.
* **byte 2** - bit 7 marks an **area entrance**, low seven bits the area number; its marker
  shows while the area's ``$04A9`` bit is clear, and area 21's only once areas 1-10 are all
  flagged.
* **then, in this order** (``$8121``, ``$8243``): the sub-id if the kind is ``$20``/``$40``;
  the **spawn script id** if byte 1 bit 3 is set (``$57``, 0 read as 1, indexing bank 5
  ``$A4C7``); the **layout pointer** if byte 0 bit 4 is set.

**CORRECTION** (an earlier one): this header first said every qualifying cell is a sprite,
that byte 0 bit 7 means "drawn", and that byte 1 is a been-there flag. All three were wrong.

The checks
----------
1. **Every non-empty record is exactly as long as its flags say** - 3 + sub-id + script +
   2 for a layout. That is the check that carries the field order.
2. The records with byte 0 ``$82`` and byte 2 bit 7 carry area numbers **1 to 21, each
   exactly once**; the keys they need repeat with period ten across 1-10 and 11-20.
3. **211 rooms have enemies, their script ids are all in 1-47, and all 47 are used** - the
   script table's 47 was fixed independently, by where its first target begins.
4. **The layouts partition their stretch**: chained from ``$9340`` they land exactly on
   ``$960F``, and all 67 layouts the map points at are on that chain. The shapes they use
   are 0-18, and 19 shapes of 18 bytes end exactly at ``$9340``.

What is NOT established
-----------------------
Bit 7 of byte 0 beyond its part in the entrance test; what the sub-id ``$5E`` selects
through ``$A377``; the 12 layouts on the chain that no map record points at (``$9340``
among them, a two-byte empty layout); what ``$04A9`` means in play.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl.model import load
from tgl.worldmap import (COLUMNS, EMPTY, END, LAYOUTS, MAP_END, ROWS, SHAPE_SIZE, SHAPES,
                          START, entrances, fields, key, layouts, records)

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
    full = [r for r in recs if r["b"][0] != EMPTY]
    f = {r["addr"]: fields(r) for r in full}
    exact = sum(1 for r in full if f[r["addr"]]["need"] == r["n"])
    scripts = Counter(f[r["addr"]]["script"] for r in full if "script" in f[r["addr"]])
    refs = {f[r["addr"]]["layout"] for r in full if "layout" in f[r["addr"]]}
    chain, lend = layouts(b5)
    on_chain = {a for a, _ in chain}
    shapes_used = sorted({b5[a - 0x8000] & 0x1F for a in refs})
    by_area = {r["b"][2] & 0x7F: r for r in ent}
    keys = [key(by_area[a]) for a in sorted(by_area)]

    print(f"{len(recs)} map records = {ROWS} x {COLUMNS}, ${START:04X}-${MAP_END - 1:04X}"
          + ("" if landed == MAP_END and len(recs) == ROWS * COLUMNS else "  ** MISMATCH **"))
    print(f"{exact} of {len(full)} non-empty records are exactly as long as their flags say")
    print(f"{len(ent)} area entrances; 1-21 once each: {areas == list(range(1, 22))}; "
          f"keys by area {keys}")
    print(f"{sum(scripts.values())} rooms with enemies, script ids {min(scripts)}-"
          f"{max(scripts)}, {len(scripts)} distinct")
    print(f"{len(refs)} layouts referenced, {len(refs & on_chain)} on the chain from "
          f"${LAYOUTS:04X}; the chain of {len(chain)} lands on ${lend:04X}"
          + ("  (exactly the dialogue table)" if lend == END else "  ** OVERSHOT **"))
    print(f"shapes used {shapes_used[0]}-{shapes_used[-1]}: {SHAPES} x {SHAPE_SIZE} from "
          f"${MAP_END:04X} ends at ${MAP_END + SHAPES * SHAPE_SIZE:04X}")

    if args.areas:
        for r in sorted(ent, key=lambda r: r["b"][2] & 0x7F):
            print(f"  area {r['b'][2] & 0x7F:2d}  row {r['row']:2d} col {r['col']:2d}  "
                  f"${r['addr']:04X}  " + " ".join(f"{x:02X}" for x in r["b"]))

    if args.grid:
        grid = {(r["row"], r["col"]): r for r in recs}
        print("\n    " + "".join(f"{c % 10}" for c in range(COLUMNS)))
        for row in range(ROWS):
            line = ""
            for c in range(COLUMNS):
                r = grid[(row, c)]
                if r in ent:
                    line += "A"
                elif r["b"][0] == EMPTY:
                    line += "."
                else:
                    line += str(key(r)) if key(r) else "#"
            print(f" {row:2d} {line}")
        print("\n A = area entrance, # = a cell needing no key, 1-7 = the key that reveals "
              "it, . = empty")

    base = rm.meta["prg_offset"] + BANK * rm.meta["prg_bank_size"] - 0x8000

    def region(rid, a, e, name, desc):
        return {"id": f"bank{BANK}.{rid}_{a:04X}", "offset": base + a, "size": e - a,
                "kind": "level", "name": name, "confidence": "confirmed", "cpu_addr": a,
                "sha1": hashlib.sha1(rm.rom[base + a:base + e]).hexdigest(),
                "description": desc}

    regions = [
        region("map", START, MAP_END, f"World map: {ROWS} x {COLUMNS} rooms",
               f"{len(recs)} variable-length records, {ROWS} rows of {COLUMNS} - one per room "
               "of the labyrinth. A record is (first byte AND $0F) + 1 bytes ($8103: "
               "LDA ($16),Y / AND #$0F / SEC / ADC $16). $80F5 seeks through it; $8071 walks "
               "it as the player moves ($52 column, $53 row); $882D draws it on the status "
               "screen as 2x2-cell background tiles, sprites marking area entrances only. "
               "BYTE 0: low nibble length-1, $80 exactly empty, bit 4 = layout pointer "
               "present, bits 5-6 = room kind ($5D; $20 and $40 carry a sub-id). BYTE 1: low "
               "three bits = the KEY that reveals the cell ($04B0), bit 3 = the room has "
               "enemies. BYTE 2: bit 7 = area entrance, low seven bits = area number. THEN, "
               "in order: sub-id ($5E), spawn script id ($57, into $A4C7), layout pointer. "
               f"CHECKS: {exact} of {len(full)} non-empty records are exactly as long as "
               "their flags imply; area numbers 1-21 occur once each; "
               f"{sum(scripts.values())} rooms with enemies use script ids "
               f"{min(scripts)}-{max(scripts)}, {len(scripts)} distinct. CORRECTION: this "
               "region was first 807 records running to $960E, proved by 'the walk lands "
               "exactly on $960F' - a weak test that a walk over arbitrary data passes about "
               "one time in four. The map ends at $91EA, which $8042 names as the room-shape "
               "base. Generated by tools/parse-map.py."),
        region("level", MAP_END, LAYOUTS, f"Room shapes: {SHAPES} x {SHAPE_SIZE} bytes, 1bpp",
               f"{SHAPES} room shapes. $8042 computes $91EA + 18 * (A AND $1F), and $8278 "
               "shifts the 18 bytes out one bit at a time (CPY #$12) into the 16-wide room "
               "buffer at $0740 from index $20, writing the layout's fill tile wherever a bit "
               "is set: 144 cells, rows 2-10. THE EXTENT: the layouts use shapes "
               f"{shapes_used[0]}-{shapes_used[-1]}, and {SHAPES} x 18 bytes from $91EA end "
               "exactly where the layout chain begins. Generated by tools/parse-map.py."),
        region("level", LAYOUTS, END, f"Room layouts: {len(chain)}",
               f"{len(chain)} room layouts, read by $8243 through the pointer at the end of a "
               "map record. [shape | count << 5][fill tile], then count x [tile][position]"
               "[six-bit mask | direction]: $82A3 walks the mask along a step from $82D9 "
               "(-15, 1, 16, 17 - up-right, right, down, down-right), writing the tile at "
               "each set bit. So a layout is 2 + 3 * count bytes. THE CHECK: chained from "
               f"$9340 the layouts land exactly on $960F, and all {len(refs)} layouts the map "
               f"points at are on the chain; {len(chain) - len(refs & on_chain)} are not "
               "pointed at by any map record. Generated by tools/parse-map.py."),
    ]
    doc = {"_comment": "GENERATED by tools/parse-map.py - do not hand-edit. Bank 5's world "
                       "map, its room shapes and its room layouts.",
           "regions": regions}
    text = json.dumps(doc, indent=2) + "\n"
    if args.check:
        print("\nno change" if OUT.exists() and OUT.read_text() == text else "\nWOULD CHANGE")
        return 0
    OUT.write_text(text)
    print(f"\nwrote {OUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
