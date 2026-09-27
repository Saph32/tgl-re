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
this reading of the script is incomplete, is open. What the special-room type ``$72`` does.
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
    ap.add_argument("--areas", action="store_true", help="each corridor's scripts and streams")
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
        rs = [r for r in rs if r[1]]
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

    # 5. the corridors
    b4 = rm.prg_bank(4)
    a_scripts, a_streams = enemy.area_spawns(b4)
    all_s = sorted(set().union(*a_scripts.values()))
    all_g = sorted(set().union(*a_streams.values()))
    s_walk = {s: enemy.walk_script(b4, s) for s in all_s}
    g_walk = {g: enemy.walk_gfx_stream(b4, g) for g in all_g}
    # A script whose walk runs past the next structure something else names is cut there:
    # the steps beyond it are that structure's bytes, and are either never reached (the
    # area ends first) or this reading is incomplete. Reported, not claimed.
    from tgl import screen as sc
    g4 = sc.walk(b4)
    fences = sorted(set(g4["starts"]) | set(g4["pool"]) | set(all_s) | set(all_g))
    overrun = {}
    for s in all_s:
        ev, e, how = s_walk[s]
        nxt = next((f for f in fences if f > s), 0xC000)
        if e > nxt:
            overrun[s] = nxt
            s_walk[s] = enemy.walk_script(b4, s, stop=nxt)
    one_each = all(len(a_scripts.get(a, ())) == 1 for a in range(1, 22))
    loops = [s for s in all_s if s_walk[s][2] == "jump"]
    loops_ok = all(s <= s_walk[s][0][-1][1] < s_walk[s][1] for s in loops)
    a_pairs = a_ok = 0
    for g in all_g:
        rs = [r for r in g_walk[g][0] if r[1]]
        for (_, b, t), (_, _, t2) in zip(rs, rs[1:]):
            a_pairs += 1
            a_ok += (t2 - t == ntiles(b))
    need = have = 0
    misses = []
    for area, ss in sorted(a_scripts.items()):
        loaded = {b for g in a_streams.get(area, ()) for _, b, _ in g_walk[g][0] if b}
        for s in ss:
            for ty in sorted({e[1] for e in s_walk[s][0] if e[0] in ("spawn", "formation")}):
                gid = enemy.per_type(b7, ty)["gfx"]
                if not gid or gid >= 0x80:
                    continue
                need += 1
                if gid in loaded:
                    have += 1
                else:
                    misses.append(f"corridor {area} type ${ty:02X} block ${gid:02X}")
    spans = sorted([(s, s_walk[s][1]) for s in all_s] + [(g, g_walk[g][1]) for g in all_g])
    disjoint = all(a2 >= b1 for (_, b1), (a2, _) in zip(spans, spans[1:]))
    print(f"areas: {len(all_s)} spawn scripts (corridors 1-21 one each: {one_each}), "
          f"{len(all_g)} graphics streams, all in bank 4, pairwise disjoint: {disjoint}")
    print(f"  {len(loops)} scripts end on a jump, every one back into itself: {loops_ok}")
    print(f"  load streams pack exactly: {a_ok} of {a_pairs}")
    print(f"  {len(overrun)} scripts run into the next named structure: "
          + ", ".join(f"${s:04X} into ${n:04X}" for s, n in overrun.items()))
    print(f"  {have} of {need} (corridor, spawned type) pairs have the type's art block loaded by "
          f"that corridor's own streams; misses: {', '.join(misses)}")

    if args.types:
        print("\ntype flags  hp  atk  $0620 death  gfx")
        for t in range(1, 128):
            v = enemy.per_type(b7, t)
            g = "" if v["gfx"] is None else f"${v['gfx']:02X}"
            print(f" ${t:02X}   ${v['flags']:02X} {v['hp']:4d} {v['attack']:4d}   "
                  f"${v['p620']:02X}   ${v['death']:02X}   {g:4s} "
                  f"{enemy.score(b7, v['score_class'])}")
    if args.areas:
        for area in sorted(set(a_scripts) | set(a_streams)):
            print(f"\n area {area}: streams "
                  + " ".join(f"${g:04X}" for g in sorted(a_streams.get(area, ()))))
            for s in sorted(a_scripts.get(area, ())):
                print(f"   script ${s:04X}:")
                for e in s_walk[s][0]:
                    print("     " + " ".join(str(x) if not isinstance(x, int) or x < 10
                                            else f"${x:02X}" for x in e))
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
                    six + "Destination $0620: DRAWING FLAGS. The draw path $CBE8 tests them bit "
                    "by bit - bit 0 calls $CC88 and bit 1 $CCEB before drawing, bit 2 flips "
                    "the attribute when $05D8 is non-negative, bit 3 is tested at $CC1F - so "
                    "the per-type value says how the object is drawn. What each extra step "
                    "does is not yet read. 128 bytes, ending at the code at $D229."))
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
    classes = [b7[0xE00D - 0xC000 + ty] for ty in range(128)]
    top = max(c for c in classes if c < 0x80)
    R.append(region(7, "tbl", 0xE00D, 128, "data", "Score class, by type",
                    "$DFB1: LDY $0740,X (the dead object's type, saved by $D32A) / LDA $E00D,Y; "
                    "negative means per object, from $07D0,X. $DFCF turns the class into six "
                    "decimal digits at $E08C + 6 x class + 1 and adds them into the score at "
                    f"$0170-$0175, capping at 999999. Classes 0-{top} occur, plus $FF. 128 "
                    "entries: type 127's is the byte at $E08C, which is also the never-read "
                    "first byte of the digit rows (class 0's digits start at $E08D) - the "
                    "overlap trick the split tables use. Values: " + ", ".join(
                        f"class {c} = {enemy.score(b7, c)}" for c in range(top + 1)) + "."))
    R.append(region(7, "tbl", 0xE08D, 6 * (top + 1), "data",
                    f"Score values: {top + 1} classes x 6 digits",
                    "Six decimal digits per class, most significant first, read by $DFE3 "
                    "LDA $E08C,Y with Y counting down from 6 x class + 6. The highest class any "
                    f"type names is {top}, and {top + 1} x 6 bytes from $E08D end exactly at "
                    "$E0F8, where the code resumes."))
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
    R.append(region(5, "tbl", SPECIAL_IDX, 22, "data", "Miniboss rooms: sub-id to record",
                    "$A66B: LDY $5E / LDA $A682,Y, for rooms of kind $40 - and $A682 itself is code, the STA $27 two instructions on, so sub-ids 0-10 could not be used. The sub-ids those "
                    "rooms carry run 11-32, so the bytes read are $A68D-$A6A2 - starting "
                    "exactly after the code, ending exactly before the records. Values are "
                    "offsets 0-36 in steps of 3."))
    R.append(region(5, "tbl", SPECIAL_REC, 3 * len(specials), "data",
                    f"Miniboss rooms: {len(specials)} x [type][stream]",
                    "$A671-$A67D: the first byte to $72, the next two to $28/$29 as a "
                    "graphics-load stream, then $27 = $80 starts the load. Types: "
                    + ", ".join(f"${t:02X}" for t, _ in specials) + ". $72 is the boss type: $A663 also sets $70 = 1, the boss phase bank 3 $9184 "
                    "runs for corridors too, which spawns type $72 ($92E5) and waits for it "
                    "($92EE) - so these are the labyrinth's minibosses, set out only while the "
                    "room's sub-id flag is clear (JSR $C0E1). CORRECTION: named 'special rooms' "
                    "with $72's use not established; see docs/labyrinth.html#minibosses."))
    R.append(region(5, "data", SPECIAL_STREAMS, SPECIAL_END - SPECIAL_STREAMS, "data",
                    "Miniboss rooms: graphics-load streams",
                    "Seven streams in the same [flags | slot][block][tile] format, named by "
                    "the records at $A6A3. They tile this stretch exactly and end on the "
                    "code at $A6EB; the tile positions inside them pack block by block like "
                    "the default stream's."))
    by_script = {s: sorted(a for a, v in a_scripts.items() if s in v) for s in all_s}
    by_stream = {g: sorted(a for a, v in a_streams.items() if g in v) for g in all_g}
    for s in all_s:
        ev, e, how = s_walk[s]
        kinds = sorted({x[1] for x in ev if x[0] in ("spawn", "formation")})
        R.append(region(4, "data", s, e - s, "data",
                        f"Corridor spawn script: corridor {', '.join(map(str, by_script[s]))}",
                        "Started by screen-data command 2 with bit 1 set ($E733: pointer to "
                        "$66/$67, $7F = 4) and run by bank 7 $F78F, the same interpreter as the "
                        "labyrinth's. Here a wait counts frames in which $A0 bit 2 is set - a "
                        "new background row came in - so the waves follow the scroll. "
                        f"{len(ev)} steps spawning types "
                        + ", ".join(f"${k:02X}" for k in kinds)
                        + (". Ends with a jump back into itself, a loop." if how == "jump"
                           else f". NOT ESTABLISHED WHERE IT ENDS: its last steps run into "
                           f"${e:04X}, which is named separately, so the claim stops there."
                           if how == "overrun" else ". Ends with command 2.")
                        + " tools/parse-enemies.py --areas decodes it."))
    for g in all_g:
        rs, e = g_walk[g]
        R.append(region(4, "data", g, e - g, "data",
                        f"Corridor graphics stream: corridor {', '.join(map(str, by_stream[g]))}",
                        "Started by screen-data command 7 ($E85E: waits for $27 to clear, "
                        "then $28/$29 and $7E = 4) and loaded by $E99F. Records: "
                        + "; ".join(f"slot {sl} empty" if not b else
                                    f"slot {sl} block ${b:02X} at tile ${tl:02X}"
                                    for sl, b, tl in rs) + "."))
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
