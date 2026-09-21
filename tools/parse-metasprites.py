#!/usr/bin/env python3
"""Walk the metasprite table into `annotations/regions/70-metasprites.json`.

    python tools/parse-metasprites.py          # rewrite the file, print the checks
    python tools/parse-metasprites.py --check  # report, write nothing
    python tools/parse-metasprites.py --dump   # every metasprite, sprite by sprite
    python tools/parse-metasprites.py --id 1   # one of them, drawn as a grid

**The output file is generated. A hand edit to it is lost on the next run.**

The format and what bounds it are in `tools/tgl/metasprite.py`.

What this checks
----------------
1. **Records and offset tables collide with nothing already claimed.** That is the test
   that caught the table entries which are not metasprites at all - their absurd sprite
   counts (112, 116, 124) run their offset tables straight through traced code.
2. **The count separates cleanly.** Real records use 1 to 25 sprites; the bad ones use 112
   or more, a gap of 87 with nothing in between.
3. Records and offset tables are allowed to SHARE bytes and do - far fewer offset tables
   than metasprites - so regions are emitted per contiguous run of covered bytes rather
   than per record, the same way the screen-data streams are. No counts are typed in this
   docstring; run the tool for them.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl import metasprite as ms
from tgl.model import load

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "annotations" / "regions" / "70-metasprites.json"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--dump", action="store_true")
    ap.add_argument("--id", type=int)
    ap.add_argument("--objects", action="store_true",
                    help="which object type wears which metasprite")
    args = ap.parse_args()

    rm = load(ROOT, exclude={OUT.name})
    b7 = rm.prg_bank(7)
    ptrs = ms.pointers(b7)
    good, bad = {}, []
    for i, p in enumerate(ptrs):
        m = ms.parse(b7, p)
        if m is None:
            bad.append((i, p))
        else:
            good[p] = m

    if args.id is not None:
        p = ptrs[args.id]
        m = ms.parse(b7, p)
        if m is None:
            print(f"entry {args.id} points at ${p:04X}, which is not a metasprite")
            return 0
        print(f"metasprite {args.id} at ${p:04X}: {m['count']} sprites"
              + (", drawn twice mirrored" if m["mirror"] else "")
              + f", offsets at ${m['offsets']:04X}, {m['size']} bytes")
        sp = ms.sprites(m)
        for x, y, t, a in sp:
            print(f"   ({x:+4d},{y:+4d})  tile +${t:02X}  attr ${a:02X}"
                  + ("  [skip]" if t == ms.SKIP_TILE else ""))
        # The offsets are not on an 8-pixel lattice - sprites overlap, 7 apart is common -
        # so the grid uses the coordinates that actually occur rather than a fixed step.
        xs = sorted({s[0] for s in sp})
        ys = sorted({s[1] for s in sp})
        print("\n   arrangement, columns and rows at the offsets that occur:")
        print("        " + " ".join(f"{x:+4d}" for x in xs))
        for yy in ys:
            row = ""
            for xx in xs:
                hit = [s for s in sp if s[0] == xx and s[1] == yy]
                row += f"  {hit[0][2]:02X}{'<' if hit[0][3] & 0x40 else ' '}" if hit \
                    else "  .. "
            print(f"   {yy:+4d}" + row)
        print("   ('<' marks a sprite drawn horizontally flipped)")
        return 0

    if args.objects:
        b6 = rm.prg_bank(BANK6 := 6)
        rows = ms.object_map(b6, b7)
        valid = {i for i, q in enumerate(ptrs) if ms.parse(b7, q)}
        reached = set()
        for r in rows:
            reached |= r["ids"]
            for v in r["tables"].values():
                reached |= set(v)
        hit = sum(1 for r in rows if r["ids"] or r["tables"])
        for r in rows:
            if not r["ids"] and not r["tables"]:
                continue
            line = f"  type ${r['type']:02X}  handler ${r['handler']:04X}  "
            if r["ids"]:
                line += "ids " + ",".join(str(i) for i in sorted(r["ids"]))
            for a, v in sorted(r["tables"].items()):
                line += f"  anim ${a:04X}[" + ",".join(str(x) for x in v) + "]"
            print(line)
        print(f"\n{hit} of {len(rows)} object types resolve to a metasprite")
        print(f"{len(reached & valid)} of {len(valid)} valid table entries are reached from "
              "bank 6 alone; writers in banks 1, 2, 3 and 7 reach more - see the Sprites "
              "section of docs/graphics.html for the combined figure")
        print("An id set from a frame table is bounded ONLY by the first byte that is not a "
              "valid id, which is weak: valid ids cover most byte values, so a long run may "
              "have walked past the table's end.")
        return 0

    cov = set()
    for m in good.values():
        cov.update(range(m["addr"], m["addr"] + m["size"]))
        if m["pairs"]:
            cov.update(range(m["offsets"], m["offsets"] + m["offsets_size"]))

    prg, bsz = rm.meta["prg_offset"], rm.meta["prg_bank_size"]
    claimed = bytearray(len(rm.rom))
    for r in rm.regions:
        claimed[r["offset"]:r["offset"] + r["size"]] = b"\1" * r["size"]
    coll = [a for a in cov if claimed[prg + 7 * bsz + (a - 0xC000)]]

    counts = sorted(m["count"] for m in good.values())
    mirrored = sum(1 for m in good.values() if m["mirror"])
    offs = {m["offsets"] for m in good.values() if m["pairs"]}
    print(f"{ms.ENTRIES} table entries -> {len(good)} distinct metasprites, "
          f"{len(bad)} entries that are not one")
    print(f"   the {len(bad)} bad entries are {[f'{i}' for i, _ in bad]} - entry 0 is "
          "provably never read, because $CC2C does BEQ $CC44 on a zero index")
    print(f"sprite counts run {counts[0]} to {counts[-1]}; {mirrored} records are mirrored")
    print(f"{len(offs)} distinct offset tables shared between {len(good)} metasprites")
    print(f"{len(cov):,} bytes covered, {len(coll)} of them already claimed elsewhere")

    if args.dump:
        for i, p in enumerate(ptrs):
            m = good.get(p)
            print(f"  {i:3d} ${p:04X}  " + ("NOT a metasprite" if not m else
                  f"{m['count']:2d} sprites{' mirrored' if m['mirror'] else '        '}  "
                  f"offs ${m['offsets']:04X}  {m['size']:3d} B  "
                  f"tiles {' '.join(f'{t:02X}' for t in m['tiles'][:8])}"))

    xs = sorted(cov)
    runs, i = [], 0
    while i < len(xs):
        j = i
        while j + 1 < len(xs) and xs[j + 1] == xs[j] + 1:
            j += 1
        runs.append((xs[i], xs[j] - xs[i] + 1))
        i = j + 1

    regions = []
    for a, n in runs:
        off = prg + 7 * bsz + (a - 0xC000)
        if any(claimed[off:off + n]):
            continue
        inside = [m for m in good.values() if a <= m["addr"] < a + n]
        tabs = [o for o in offs if a <= o < a + n]
        regions.append({
            "id": f"bank7.sprite_{a:04X}", "offset": off, "size": n, "kind": "graphics",
            "name": f"Metasprites: {len(inside)} records, {len(tabs)} offset tables",
            "confidence": "confirmed", "cpu_addr": a,
            "sha1": hashlib.sha1(rm.rom[off:off + n]).hexdigest(),
            "codec": "metasprite",
            "description":
                f"${a:04X}-${a + n - 1:04X}. {len(inside)} metasprite records and "
                f"{len(tabs)} (x, y) offset tables, interleaved. A record is "
                "[count][offsets lo][offsets hi][tiles][attributes], named by the split "
                "pointer table at $C28D (low) and $C319 (high) and drawn by $CC46. Bit 7 of "
                "the count means draw the whole thing twice with bit 6 of the attribute "
                "flipped - a free mirror image. Tile numbers are RELATIVE, added to the "
                "object's own base tile at $87, and $FF skips a sprite. The attribute array "
                "is run-length coded: $CE23 advances it only when bit 3 of the byte is "
                "clear, which is why a record's length does not follow from its count. "
                "Offset tables are shared - 118 metasprites use 57 of them - so records and "
                "tables interleave and this region is a contiguous run of covered bytes "
                "rather than one record. Generated by tools/parse-metasprites.py; the "
                "format is in tools/tgl/metasprite.py.",
        })
        claimed[off:off + n] = b"\1" * n

    regions.sort(key=lambda r: r["offset"])
    doc = {"_comment": "GENERATED by tools/parse-metasprites.py - do not hand-edit. The "
                       "metasprite records and their (x, y) offset tables in bank 7.",
           "regions": regions}
    text = json.dumps(doc, indent=2) + "\n"
    print(f"{len(regions)} regions, {sum(r['size'] for r in regions):,} bytes")
    if args.check:
        print("no change" if OUT.exists() and OUT.read_text() == text else "WOULD CHANGE")
        return 0
    OUT.write_text(text)
    print(f"wrote {OUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
