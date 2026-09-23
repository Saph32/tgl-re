#!/usr/bin/env python3
"""Claim the enemy tables, spawn scripts and graphics-load streams into
`annotations/regions/80-enemies.json`.

    python tools/parse-enemies.py           # rewrite the file, print the checks
    python tools/parse-enemies.py --check   # report, write nothing
    python tools/parse-enemies.py --types   # the per-type table, one line per type
    python tools/parse-enemies.py --scripts # every spawn script, decoded

**The output file is generated. A hand edit to it is lost on the next run.** The formats,
and where each was read, are in the header of `tools/tgl/enemy.py`.

The checks
----------
1. **Every graphics id names a real tile block.** 52 distinct ids in ``$CFC4`` and 24 in the
   load streams, routed through ``$D7F9``'s table bases, all land on a block start that the
   codec's own partition test found.
2. **The load streams pack tiles exactly.** In each stream the next record's tile is the
   previous one's plus that block's decoded tile count - 19 of 19 consecutive pairs. So the
   codec's lengths, the streams and the loader agree with each other.
3. **The spawn scripts partition their stretch.** Walked from the 47 pointers, they cover
   ``$A525-$A662`` byte for byte, and the map uses script ids 1-47, all of them.
4. **The special-room tables are bounded both ways**: ``$A682`` is read with sub-ids
   11-32, and ``$A682 + 11`` is exactly the first byte after code; its records at ``$A6A3``
   point at streams that end exactly where the next code begins.

Not established: five scripts end ``[byte] 01 02``, which the code reads as a long wait and a
jump whose operand overlaps the next script's first byte - whether that is ever reached, or
this reading of the script is incomplete, is open. What ``$0620`` and the special-room type
``$72`` do.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl import enemy, gfx, worldmap
from tgl.model import load

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "annotations" / "regions" / "80-enemies.json"

TABLE_BASES = {2: 0x8024, 3: 0x8020}      # $D842/$D84A
SPECIAL_IDX, SPECIAL_REC, SPECIAL_STREAMS, SPECIAL_END = 0xA68D, 0xA6A3, 0xA6CA, 0xA6EB


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--types", action="store_true")
    ap.add_argument("--scripts", action="store_true")
    args = ap.parse_args()

    rm = load(ROOT, exclude={OUT.name})
    b5, b7 = rm.prg_bank(5), rm.prg_bank(7)
    B5 = lambda a: b5[a - 0x8000]

    # 1. graphics ids
    starts = {b: {x["addr"] for x in gfx.blocks(rm.prg_bank(b), b)} for b in (2, 3)}

    def block_ptr(k):
        bank, i = enemy.block_source(k)
        d = rm.prg_bank(bank)
        p = TABLE_BASES[bank] + 2 * i - 0x8000
        return bank, d[p] | d[p + 1] << 8

    def ntiles(k):
        bank, ptr = block_ptr(k)
        return len(gfx.decode(rm.prg_bank(bank), ptr - 0x8000)[0]) // 16

    type_ids = {enemy.per_type(b7, t)["gfx"] for t in range(enemy.GFX_FIRST, enemy.GFX_LAST + 1)}
    type_ids = {g for g in type_ids if g and g < 0x80}
    idx = [B5(SPECIAL_IDX - 11 + s) for s in range(11, 33)]
    recs = sorted({o // 3 for o in idx})
    specials = [(B5(SPECIAL_REC + 3 * r), B5(SPECIAL_REC + 3 * r + 1)
                 | B5(SPECIAL_REC + 3 * r + 2) << 8) for r in range(len(recs))]
    streams = [enemy.GFX_DEFAULT] + sorted({p for _, p in specials})
    stream_ids, pairs, ok_pairs, stream_bytes = set(), 0, 0, 0
    for s in streams:
        rs, e = enemy.walk_gfx_stream(b5, s)
        stream_bytes += e - s
        stream_ids |= {b for _, b, _ in rs}
        for (_, b, t), (_, _, t2) in zip(rs, rs[1:]):
            pairs += 1
            ok_pairs += (t2 - t == ntiles(b))
    all_ids = type_ids | stream_ids
    real = sum(1 for k in all_ids if block_ptr(k)[1] in starts[enemy.block_source(k)[0]])
    print(f"{len(type_ids)} type graphics ids + {len(stream_ids)} stream ids: "
          f"{real} of {len(all_ids)} name a real tile block")
    print(f"load streams: {ok_pairs} of {pairs} consecutive records are exactly one block's "
          "tiles apart")

    # 3. scripts
    ptrs = enemy.script_pointers(b5)
    covered, odd, walks = set(), [], {}
    for p in sorted(set(ptrs)):
        ev, e, how = enemy.walk_script(b5, p)
        walks[p] = ev
        covered |= set(range(p, e))
        if how != "end":
            odd.append(p)
    span = set(range(enemy.SCRIPT_START, enemy.SCRIPT_END))
    print(f"{len(ptrs)} script pointers, first target ${min(ptrs):04X}; walks cover "
          f"{len(covered & span)} of {len(span)} bytes, {len(covered - span)} outside; "
          f"{len(odd)} end on a jump: " + " ".join(f"${p:04X}" for p in odd))
    recs_map, _ = worldmap.records(b5)
    used = {worldmap.fields(r).get("script") for r in recs_map if r["b"][0] != 0x80}
    used.discard(None)
    print(f"the map uses script ids {min(used)}-{max(used)}, {len(used)} distinct")

    # 4. special rooms
    s_end = max(enemy.walk_gfx_stream(b5, p)[1] for _, p in specials)
    print(f"special rooms: $A682 read with sub-ids 11-32 -> ${SPECIAL_IDX:04X}-"
          f"${SPECIAL_IDX + 21:04X}; {len(specials)} records at ${SPECIAL_REC:04X}; their "
          f"streams end at ${s_end:04X}" + ("  (exactly the code)" if s_end == SPECIAL_END
                                           else "  ** MISMATCH **"))

    if args.types:
        print("\ntype flags  hp  atk  $0620 death  gfx")
        for t in range(1, 128):
            v = enemy.per_type(b7, t)
            g = "" if v["gfx"] is None else f"${v['gfx']:02X}"
            print(f" ${t:02X}   ${v['flags']:02X} {v['hp']:4d} {v['attack']:4d}   "
                  f"${v['p620']:02X}   ${v['death']:02X}   {g}")
    if args.scripts:
        for i, p in enumerate(ptrs, 1):
            print(f"\n script {i:2d}  ${p:04X}")
            for e in walks[p]:
                print("   " + " ".join(str(x) if not isinstance(x, int) or x < 10
                                       else f"${x:02X}" for x in e))

    # ------------------------------------------------------------------ regions
    def region(bank, rid, a, n, kind, name, desc, conf="confirmed"):
        base = 0xC000 if bank == 7 else 0x8000
        off = rm.meta["prg_offset"] + bank * rm.meta["prg_bank_size"] + a - base
        return {"id": f"bank{bank}.{rid}_{a:04X}", "offset": off, "size": n, "kind": kind,
                "name": name, "confidence": conf, "cpu_addr": a,
                "sha1": hashlib.sha1(rm.rom[off:off + n]).hexdigest(), "description": desc}

    R = []
    six = ("$CFA0 copies it into the slot with LDA table,Y where Y = type AND $7F - four "
           "reads six bytes apart, which is also what bounds the tables. ")
    R.append(region(7, "tbl", 0xD02C, 127, "data", "Enemy collision flags, by type",
                    six + "Destination $0578. $D348 skips an object whose bit 7 is set and "
                    "ANDs the rest with the collision class it is testing ($30 or $20). 127 "
                    "bytes, types 0-126: type $7F would read $D0AB's first byte."))
    R.append(region(7, "tbl", 0xD0AB, 127, "data", "Enemy hit points, by type",
                    six + "Destination $0590, HIT POINTS: $D30E subtracts the other side's "
                    "$05A8 from it, clamping at 0, and $D32A turns the object into its death "
                    "type when it reaches 0. Families climb in step - types $10-$13 have 24, "
                    "32, 48, 80."))
    R.append(region(7, "tbl", 0xD12A, 127, "data", "Enemy attack, by type",
                    six + "Destination $05A8, ATTACK: the hit points an object takes from "
                    "whatever it collides with ($D30E). For the player the damage is divided "
                    "by the player's own $0590 first ($D2DC-$D2DF, through $F9AE)."))
    R.append(region(7, "tbl", 0xD1A9, 128, "data", "Per-type value copied to $0620",
                    six + "Destination $0620. 128 bytes, ending at the code at $D229. What "
                    "$0620 means for an enemy is NOT established - bank 5 also uses it as a "
                    "dialogue index for some objects."))
    R.append(region(7, "tbl", 0xD441, 128, "data", "What each type becomes at 0 HP",
                    "$D32A: when $0590 reaches 0, LDA $D441,Y / STA $0500,X with Y = the "
                    "type, after saving the old type in $0740. Mostly $08 and $07 - "
                    "explosions. $D2F3 reads $D442 directly for the player (type 1). 128 "
                    "bytes, ending at the code at $D4C1."))
    R.append(region(7, "tbl", 0xCFC4, 104, "data", "The tile block holding each type's art",
                    "$CF4C: type AND $7F, CMP #$0E / BCC returns 0, else LDA $CFB6,Y - so "
                    "this table starts at type $0E, and it runs to $D02B, type $75. A "
                    "negative entry means 'per object' ($07B8,X). $CF5F finds the id in the "
                    "loaded list $0480 and makes the object wait until it is there; $0490 "
                    "then gives the tile the block was loaded at. THE CHECK: all "
                    f"{len(type_ids)} distinct ids name a real tile block when routed the "
                    "way $EA58 routes them (below $40 bank 3, else bank 2 id - $30)."))
    R.append(region(7, "tbl", 0xC201, 140, "data", "Hitbox half-height, by metasprite id",
                    "$D229: LDA $0548,X (the metasprite id) / TAY, then $0518 +/- $C201,Y "
                    "into $0728/$0710 - the vertical extent $D364 overlaps. 140 bytes, "
                    "ending where the metasprite pointer table begins; id 140 would read its "
                    "first byte."))
    R.append(region(7, "tbl", 0xC174, 141, "data", "Hitbox half-width, by metasprite id",
                    "$D229: $0530 +/- $C174,Y into $06F8/$06E0, Y = the metasprite id. 141 "
                    "bytes, one per metasprite id - bounded by $C201, read by the same "
                    "routine."))
    R.append(region(5, "tbl", 0x803C, 6, "pointer_table", "Labyrinth spawn lists: 3 pointers",
                    "$89FB reads $803C,Y / $803D,Y with Y = 2 * $0478[low nibble of $04C0,X], "
                    "then (pointer),Y with the high nibble for an object type. Three "
                    "pointers, $AF61, $AF69, $AF71; the 6 bytes are exactly the gap between "
                    "the entry table and the code at $8042. How far each list runs is NOT "
                    "established - the index can reach 15 and the lists are 8 apart.",
                    conf="lead"))
    R.append(region(5, "tbl", 0x82D9, 4, "data", "Layout step directions: -15, 1, 16, 17",
                    "$82B9 LDA $82D9,Y with Y = the top two bits of a layout item: the step "
                    "$82A3 adds between the six cells of its mask in the 16-wide room buffer "
                    "- up-right, right, down, down-right. The BNE / BEQ pair at $82D5 jumps "
                    "over it."))
    R.append(region(5, "data", enemy.GFX_DEFAULT, 48, "data",
                    "Enemy graphics: the default load stream",
                    "Sixteen [flags | slot][block][tile] records - $A46E points $28/$29 here "
                    "with $27 = $80 on entering a room, and $E99F loads one block per pass "
                    "into CHR at tile * 16, recording it in $0480/$0490. Bit 7 of the last "
                    "record's first byte ($8F) ends it. THE CHECK: each record's tile is the "
                    "previous one's plus that block's decoded tile count, all 15 pairs, "
                    "$80 to $E2 + 14."))
    R.append(region(5, "tbl", enemy.SCRIPT_PTRS, 94, "pointer_table",
                    "Spawn script pointers: 47",
                    "$A480: LDA $A4C5,Y / $A4C6,Y with Y = 2 * $57, the script id from the map "
                    "record; $57 = 0 skips it, so entry 0 is never read and the table starts "
                    "at $A4C7. 47 entries, ending where the first target, $A525, begins - "
                    "and the map uses ids 1-47, every one."))
    R.append(region(5, "data", enemy.SCRIPT_START, enemy.SCRIPT_END - enemy.SCRIPT_START,
                    "data", "Enemy spawn scripts",
                    "The scripts bank 7 $F78F runs: < 3 a command (0 wait, 1 jump, 2 end, via "
                    "the inline table at $F7C9), else a spawn - bit 7 clear one object of "
                    "that type, bit 7 set a formation [type|$80][count][interval] carried by "
                    "a type-$29 spawner. A spawn is followed by another bit-7 spawn or a wait "
                    "in units of 60 frames. THE CHECK: walked from the 47 pointers they cover "
                    "this stretch byte for byte. NOT ESTABLISHED: five scripts ("
                    + ", ".join(f"${p:04X}" for p in odd) + ") end [byte] 01 02, which the "
                    "code reads as a long wait and then a jump whose operand overlaps the "
                    "next script. tools/parse-enemies.py --scripts decodes them all."))
    R.append(region(5, "tbl", SPECIAL_IDX, 22, "data", "Special rooms: sub-id to record",
                    "$A66B: LDY $5E / LDA $A682,Y, for rooms of kind $40 - and $A682 itself is code, the STA $27 two instructions on, so sub-ids 0-10 could not be used. The sub-ids those "
                    "rooms carry run 11-32, so the bytes read are $A68D-$A6A2 - starting "
                    "exactly after the code, ending exactly before the records. Values are "
                    "offsets 0-36 in steps of 3."))
    R.append(region(5, "tbl", SPECIAL_REC, 3 * len(specials), "data",
                    f"Special rooms: {len(specials)} x [type][stream]",
                    "$A671-$A67D: the first byte to $72, the next two to $28/$29 as a "
                    "graphics-load stream, then $27 = $80 starts the load. Types: "
                    + ", ".join(f"${t:02X}" for t, _ in specials) + ". What $72 does is "
                    "NOT established; bank 3 compares it with $4D."))
    R.append(region(5, "data", SPECIAL_STREAMS, SPECIAL_END - SPECIAL_STREAMS, "data",
                    "Special rooms: graphics-load streams",
                    "Seven streams in the same [flags | slot][block][tile] format, named by "
                    "the records at $A6A3. They tile this stretch exactly and end on the "
                    "code at $A6EB; the tile positions inside them pack block by block like "
                    "the default stream's."))
    doc = {"_comment": "GENERATED by tools/parse-enemies.py - do not hand-edit. Enemy "
                       "per-type tables, spawn scripts and graphics-load streams.",
           "regions": sorted(R, key=lambda r: r["offset"])}
    text = json.dumps(doc, indent=2) + "\n"
    if args.check:
        print("\nno change" if OUT.exists() and OUT.read_text() == text else "\nWOULD CHANGE")
        return 0
    OUT.write_text(text)
    print(f"\nwrote {OUT.relative_to(ROOT)}  ({len(R)} regions)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
