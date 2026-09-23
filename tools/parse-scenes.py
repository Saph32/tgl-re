#!/usr/bin/env python3
"""Claim bank 5's scene tables, tile lists, metatile set records and metatile data into
`annotations/regions/78-scenes.json`.

    python tools/parse-scenes.py                 # rewrite the file, print the checks
    python tools/parse-scenes.py --check         # report, write nothing
    python tools/parse-scenes.py --areas         # each labyrinth area's scene, sets, lists
    python tools/parse-scenes.py --verify S.fcs  # a savestate's sets and room vs the ROM

**The output file is generated. A hand edit to it is lost on the next run.** The format,
the loaders and the hardware checks are in the header of `tools/tgl/scene.py`.

The checks this prints
----------------------
1. **Each table ends where the next begins.** The scene table is 39 x 3 bytes and the next
   byte is the tile-list table; the tile-list table's 15 entries end at the set-record
   table, whose 22 end at the nametable-record table, whose 8 end at its first target.
2. **The small records partition their stretch.** The 8 nametable records, then the 8
   palette lists they point at, then the 14 tile lists, walked by their own length rules,
   cover ``$AE60-$AF1B`` byte for byte and end on the first set record.
3. **Every palette index anywhere in the ROM is 0-35**, which bounds the palette table.
4. ``--verify`` against a savestate: the set pointers the scenes predict, and whether every
   2x2 cell of the room on screen is a metatile of the live sets.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl import scene as sc
from tgl.model import load

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "annotations" / "regions" / "78-scenes.json"
BANK = 5
WINDOW = 32 * 5            # a set is 32 metatiles of 5 bytes ($83B3: AND #$1F, x5)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--areas", action="store_true")
    ap.add_argument("--verify", metavar="STATE")
    args = ap.parse_args()

    rm = load(ROOT, exclude={OUT.name})
    b5 = rm.prg_bank(BANK)
    B = lambda a: b5[a - 0x8000]
    W = lambda a: B(a) | B(a + 1) << 8

    if args.verify:
        return verify(rm, b5, Path(args.verify))

    # 1. tables bounded by each other
    n_tl = (sc.SET_RECORDS - sc.TILE_LISTS) // 2
    n_sr = (sc.NT_RECORDS - sc.SET_RECORDS) // 2
    nt_ptrs = [W(sc.NT_RECORDS + 2 * i) for i in range(8)]
    n_nt = (min(nt_ptrs) - sc.NT_RECORDS) // 2
    scenes = [sc.scene(b5, n) for n in range(sc.N_SCENES)]
    print(f"{sc.N_SCENES} scenes, ${sc.SCENES:04X}-${sc.SCENES + 3 * sc.N_SCENES - 1:04X}, "
          f"ending at the tile-list table: {sc.SCENES + 3 * sc.N_SCENES == sc.TILE_LISTS}")
    used = [max(s[k] for s in scenes if s[k] != 0xFF) for k in range(3)]
    print(f"tables: {n_tl} tile lists (scenes use up to {used[0]}), {n_sr} set records "
          f"(up to {used[1]}), {n_nt} nametable records (up to {used[2]})")

    # 2. the small records partition $AE60-$AF1B
    cover = set()
    for p in nt_ptrs:
        _, f, pl, extra = sc.nt_record(b5, p and nt_ptrs.index(p))
        cover |= set(range(p, p + 3 + (8 if extra else 0)))
        n = len(sc.palette_list(b5, pl))
        cover |= set(range(pl, pl + n + (1 if n < 8 else 0)))
    tl_ptrs = sorted({W(sc.TILE_LISTS + 2 * i) for i in range(n_tl)} - {0})
    for p in tl_ptrs:
        cover |= set(range(p, p + 1 + 3 * B(p)))
    span = set(range(min(nt_ptrs), 0xAF1C))
    print(f"records, palette lists and tile lists cover {len(cover & span)} of {len(span)} "
          f"bytes ${min(nt_ptrs):04X}-$AF1B, {len(cover - span)} outside")

    # set records
    recs = {}
    for i in range(n_sr):
        p, ents = sc.set_record(b5, i)
        if p:
            recs[p] = ents
    windows = sorted({ptr for ents in recs.values() for *_, ptr in ents})
    print(f"{len(recs)} distinct set records, {len(windows)} distinct set windows")

    if args.areas:
        for area in range(11):
            s = sc.LAB_FIRST_SCENE + area
            t, r, nt = sc.scene(b5, s)
            st = sc.effective_sets(b5, sc.area_scenes(area))
            _, _, pl, _ = sc.nt_record(b5, nt)
            print(f"\n area {area:2d}: scene {s}, tile list {t}, set record {r}, "
                  f"palettes {sc.palette_list(b5, pl)}")
            for n in sorted(st):
                lst, base, ptr = st[n]
                print(f"    set {n}: metatiles at ${ptr:04X}, tile base ${base:02X}, "
                      f"object list {lst}")

    # ------------------------------------------------------------------ regions
    base = rm.meta["prg_offset"] + BANK * rm.meta["prg_bank_size"] - 0x8000
    claimed = bytearray(len(rm.rom))
    for r in rm.regions:
        claimed[r["offset"]:r["offset"] + r["size"]] = b"\1" * r["size"]
    R = []

    def region(rid, a, n, kind, name, desc):
        off = base + a
        if any(claimed[off:off + n]):
            raise SystemExit(f"${a:04X}+{n} collides with a claimed region")
        claimed[off:off + n] = b"\1" * n
        R.append({"id": f"bank{BANK}.{rid}_{a:04X}", "offset": off, "size": n, "kind": kind,
                  "name": name, "confidence": "confirmed", "cpu_addr": a,
                  "sha1": hashlib.sha1(rm.rom[off:off + n]).hexdigest(),
                  "description": desc})

    region("tbl", sc.SCENES, 3 * sc.N_SCENES, "data", f"Scenes: {sc.N_SCENES} x 3",
           "Read by $ACA9 (entry $8000) at $AD91 + 3A: a tile-list index, a metatile-set "
           "record index and a nametable-record index, $FF for none. Labyrinth area n is "
           "scene n + 5 (bank 7 $EEE0 stores $50 + 5 in $5C); corridors use scenes 32-38 "
           "through bank 7 $EF55; special rooms 16-31. 39 scenes end exactly where the "
           "tile-list pointer table begins. HARDWARE: a labyrinth savestate has $5C = 5 at "
           "area 0, and replaying its scenes rebuilds its background CHR and set pointers.")
    region("tbl", sc.TILE_LISTS, 2 * n_tl, "pointer_table", f"Tile-list pointers: {n_tl}",
           f"$ACC7 LDA $AE06,Y with Y = 2 x the scene's first byte. {n_tl} entries (one zero), "
           "ending where the set-record table begins; scenes use 0-14.")
    region("tbl", sc.SET_RECORDS, 2 * n_sr, "pointer_table",
           f"Metatile-set record pointers: {n_sr}",
           f"$AD1C LDA $AE24,Y. {n_sr} entries, zero where unused, ending where the "
           "nametable-record table begins; scenes use 0-21.")
    region("tbl", sc.NT_RECORDS, 2 * n_nt, "pointer_table", f"Nametable-record pointers: {n_nt}",
           f"$AD5E LDA $AE50,Y. {n_nt} entries, ending at their own first target $AE60.")
    region("data", min(nt_ptrs), 0xAEAB - min(nt_ptrs), "data",
           "Nametable records and palette lists",
           "Eight [flags][pointer] records - the first with eight more bytes for $0199, "
           "flag bit 1 - then the palette lists they name: up to eight indices into $B30A, "
           "$FE ending a short one, walked by $D92D. They cover this stretch byte for byte "
           "and end where the tile lists begin.")
    region("data", 0xAEAB, 0xAF1C - 0xAEAB, "data", f"Tile lists: {len(tl_ptrs)}",
           "[count] then count x [tile][bank][block]: $ACD6 decompresses each block through "
           "$C042 to background CHR $1000 + tile x 16; bit 7 on a block adds $5C AND $0F. "
           "The lists tile this stretch exactly and end on the first set record. HARDWARE: "
           "replaying a labyrinth savestate's scenes rebuilds 159 of 159 background tiles, "
           "a corridor savestate's 141 of 142.")
    for p in sorted(recs):
        n = 1 + 4 * len(recs[p])
        note = (" CORRECTION: this record's first three bytes were counted as a 37th palette, "
                "and its entries were published as 'six block pointers with ids' at $B379, a "
                "lead with no reader. The reader is $AD1A." if p == 0xB376 else "")
        note += (" It points at itself: its five bytes are also metatile 0 of set 0."
                 if p == 0xAF1C else "")
        region("data", p, n, "data", f"Metatile-set record: {len(recs[p])} sets",
               "[count] then count x [set | object list << 4][tile base][pointer]: $AD1A "
               "loads $0478, $0470 and $0460/$0468 for each set. Sets: "
               + "; ".join(f"{s} at ${ptr:04X}" for s, _, _, ptr in recs[p]) + "." + note)

    # the metatile data: every byte some set window can reach, around what is claimed
    reach = bytearray(0x4000)
    for w in windows:
        for a in range(w, min(w + WINDOW, 0xBFFF)):
            reach[a - 0x8000] = 1
    runs, s0 = [], None
    for a in range(0xAF1C, 0xC000):
        free = a < 0xBFFF and reach[a - 0x8000] and not claimed[base + a]
        if free and s0 is None:
            s0 = a
        elif not free and s0 is not None:
            runs.append((s0, a))
            s0 = None
    for a, e in runs:
        inside = [w for w in windows if a <= w < e]
        region("data", a, e - a, "level", f"Metatiles, {e - a} bytes",
               "Metatile data: 5 bytes each - four tile numbers ($FF blank) and a fifth "
               "whose low three bits pick the attribute slot in $0199 and whose high nibble "
               "names a ground object - read by $83B3 through a set window of 32 metatiles "
               "(AND #$1F, x5). Every byte here lies inside some set window"
               + (": windows start at " + ", ".join(f"${w:04X}" for w in inside)
                  if inside else "") + ". Windows overlap, so a metatile can belong to "
               "several sets. HARDWARE: all 192 room cells of a labyrinth savestate are "
               "metatiles of its live sets. Which of a window's 32 ids a game actually "
               "uses is not established - a window can run past real data.")

    doc = {"_comment": "GENERATED by tools/parse-scenes.py - do not hand-edit. Bank 5's "
                       "scene tables, tile lists, metatile set records and metatile data.",
           "regions": sorted(R, key=lambda r: r["offset"])}
    text = json.dumps(doc, indent=2) + "\n"
    print(f"{len(R)} regions, {sum(r['size'] for r in R):,} bytes")
    if args.check:
        print("no change" if OUT.exists() and OUT.read_text() == text else "WOULD CHANGE")
        return 0
    OUT.write_text(text)
    print(f"wrote {OUT.relative_to(ROOT)}")
    return 0


def verify(rm, b5, state: Path) -> int:
    import importlib.util
    spec = importlib.util.spec_from_file_location("savestate", ROOT / "tools" / "savestate.py")
    ss = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(ss)
    s = ss.read_state(state)
    ram, nt = s["RAM"], s["NTAR"]
    live = {n: (ram[0x478 + n], ram[0x470 + n], ram[0x460 + n] | ram[0x468 + n] << 8)
            for n in range(8)}
    scene_no = ram[0x5C]
    lab = scene_no in range(sc.LAB_FIRST_SCENE, sc.LAB_FIRST_SCENE + 11)
    seq = sc.area_scenes(scene_no - sc.LAB_FIRST_SCENE) if lab else [1, scene_no]
    pred = sc.effective_sets(b5, seq)
    same = sum(1 for n in pred if pred[n] == live[n])
    print(f"$5C = scene {scene_no} ({'labyrinth area %d' % (scene_no - 5) if lab else 'not a labyrinth area'})")
    print(f"sets predicted from scenes {seq}: {same} of {len(pred)} match the live $0460-$047F")
    mt = set()
    for n in range(8):
        lst, base, ptr = live[n]
        if not ptr:
            continue
        for i in range(32):
            a = ptr + 5 * i - 0x8000
            if a + 4 <= len(b5):
                mt.add(tuple((x + base) & 0xFF if x != 0xFF else 0x20 for x in b5[a:a + 4]))
    ok = sum(1 for r in range(12) for c in range(16)
             if (nt[64 * r + 2 * c], nt[64 * r + 2 * c + 1], nt[64 * r + 32 + 2 * c],
                 nt[64 * r + 33 + 2 * c]) in mt)
    print(f"{ok} of 192 cells of nametable 0's room area are metatiles of the live sets")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
