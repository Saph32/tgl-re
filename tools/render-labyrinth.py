#!/usr/bin/env python3
"""Render the whole labyrinth - all 24 x 24 map cells, every room as the game draws it - to
one PNG.

    python tools/render-labyrinth.py                    # docs/labyrinth-map.png (+ a half-size)
    python tools/render-labyrinth.py --out FILE.png
    python tools/render-labyrinth.py --verify S.fcs     # render a savestate's room both ways

Everything comes from the ROM, through the tools that already carry the checks:

* **the room** - ``parse-structs.build_room``: structure, its items, the door set with the
  walls its neighbours call for, the item list, then the room layout (``$8155``, ``$8243``);
* **the area** - byte 2's low nibble for a room whose byte 0 has bit 7 clear. That is what
  ``$EEE0`` loads into ``$50`` when the move-room path (``$EC5B``) enters such a room; a room
  with byte 0 bit 7 set (corridor entrances ``$82``, key-door rooms ``$A3``) takes the
  ``$EC12`` path, which keeps the area already loaded, so it is drawn with its neighbours'
  area (the most common one; a LEAD where they disagree);
* **tiles, metatiles, palettes** - ``tgl.scene``: the area's scenes (the common scenes 0 and
  32, then area + 5) give the background CHR, the eight metatile set windows and the palette
  list; a cell byte is set (bits 5-7) + metatile (bits 0-4), a metatile four tiles plus a
  fifth byte whose low bits pick the palette.

Objects, enemies and the HUD are not drawn - this is the background only. Neighbours off
the map edge count as empty.

``--verify`` renders a labyrinth savestate's live screen from its own nametable, CHR RAM and
palette RAM, renders the same room with this tool, and compares the 256 x 192 room area
pixel for pixel.
"""

from __future__ import annotations

import argparse
import importlib.util
import sys
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from PIL import Image

from tgl import scene as sc
from tgl import worldmap as wm
from tgl.model import load
from tgl.site import NES_RGB

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "docs" / "labyrinth-map.png"
ROOM_W, ROOM_H = 16 * 16, 12 * 16        # 16 x 12 cells of 16 x 16 pixels
BACKDROP = NES_RGB[0x0F]
EMPTY_RGB = (24, 24, 28)


def _module(name: str):
    spec = importlib.util.spec_from_file_location(name.replace("-", "_"),
                                                  ROOT / "tools" / f"{name}.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def room_areas(recs) -> dict:
    """(row, col) -> labyrinth area, by the rule in the header."""
    grid = {(r["row"], r["col"]): r for r in recs}
    area = {}
    for (row, col), r in grid.items():
        b = r["b"]
        if b[0] != wm.EMPTY and not b[0] & 0x80:
            area[(row, col)] = b[2] & 0x0F
    todo = [k for k, r in grid.items() if r["b"][0] != wm.EMPTY and k not in area]
    while todo:
        left = []
        for row, col in todo:
            near = Counter(area[n] for n in ((row - 1, col), (row + 1, col), (row, col - 1),
                                              (row, col + 1)) if n in area)
            if near:
                area[(row, col)] = near.most_common(1)[0][0]
            else:
                left.append((row, col))
        if len(left) == len(todo):
            for k in left:
                area[k] = 0
            break
        todo = left
    return area


class AreaArt:
    """One area's tiles, metatile sets and palettes, with a cache of drawn metatiles."""

    def __init__(self, rm, area: int):
        b5 = self.b5 = rm.prg_bank(5)
        seq = sc.area_scenes(area)
        self.chr = sc.background_chr(rm, seq)
        self.sets = sc.effective_sets(b5, seq)
        slots = [None] * 8
        for s in seq:
            i = sc.scene(b5, s)[2]
            if i == 0xFF:
                continue
            for k, v in enumerate(sc.palette_list(b5, sc.nt_record(b5, i)[2])):
                if v != 0xFF:
                    slots[k] = v
        self.pals = [[NES_RGB[b5[0x330A + 3 * slots[k] + c] & 0x3F] for c in range(3)]
                     if slots[k] is not None else [BACKDROP] * 3 for k in range(4)]
        self.cache: dict[int, Image.Image] = {}

    def metatile(self, cell: int) -> Image.Image:
        if cell in self.cache:
            return self.cache[cell]
        img = Image.new("RGB", (16, 16), BACKDROP)
        entry = self.sets.get(cell >> 5)
        if entry:
            _, base, ptr = entry
            a = ptr + 5 * (cell & 31) - 0x8000
            t4, attr = self.b5[a:a + 4], self.b5[a + 4]
            pal = self.pals[attr & 3]
            px = img.load()
            for k, t in enumerate(t4):
                if t == 0xFF:
                    continue
                tile = self.chr.get((t + base) & 0xFF)
                if tile is None:
                    continue
                for y in range(8):
                    for x in range(8):
                        v = ((tile[y] >> (7 - x)) & 1) | (((tile[8 + y] >> (7 - x)) & 1) << 1)
                        if v:
                            px[(k % 2) * 8 + x, (k // 2) * 8 + y] = pal[v - 1]
        self.cache[cell] = img
        return img


def room_ram(recs, grid, r, area: int) -> bytearray:
    """The RAM build_room reads, as the game would hold it in room r."""
    ram = bytearray(0x800)
    empty = next(x["addr"] for x in recs if x["b"][0] == wm.EMPTY)
    ram[0x50], ram[0x51], ram[0x30] = area, 0, 0
    ram[0xE4], ram[0xE5] = r["addr"] & 0xFF, r["addr"] >> 8
    for zp, (dr, dc) in ((0xE0, (-1, 0)), (0xE2, (0, -1)), (0xE6, (0, 1)), (0xE8, (1, 0))):
        n = grid.get((r["row"] + dr, r["col"] + dc))
        a = n["addr"] if n else empty
        ram[zp], ram[zp + 1] = a & 0xFF, a >> 8
    f = wm.fields(r)
    ram[0x57] = f.get("script") or 0 if len(r["b"]) > 1 and r["b"][1] & 0x08 else 0
    ram[0x5D] = r["b"][0] & 0x60
    return ram


def render_room(art: AreaArt, buf) -> Image.Image:
    img = Image.new("RGB", (ROOM_W, ROOM_H))
    for i, cell in enumerate(buf):
        img.paste(art.metatile(cell), ((i % 16) * 16, (i // 16) * 16))
    return img


def verify(rm, state: Path) -> int:
    ss, ps = _module("savestate"), _module("parse-structs")
    st = ss.read_state(state)
    ram, nt, chr_, pram = st["RAM"], st["NTAR"], st["CHRR"], st["PRAM"]
    b5 = rm.prg_bank(5)
    live = Image.new("RGB", (ROOM_W, ROOM_H))
    px = live.load()
    tb = 0x1000 if st.get("PPUR", b"\0")[0] & 0x10 else 0
    for ty in range(24):
        for tx in range(32):
            t = nt[32 * ty + tx]
            attr = nt[0x3C0 + (ty // 4) * 8 + tx // 4] >> (((ty % 4) // 2) * 4 + ((tx % 4) // 2) * 2)
            pal = attr & 3
            d = chr_[tb + 16 * t:tb + 16 * t + 16]
            for y in range(8):
                for x in range(8):
                    v = ((d[y] >> (7 - x)) & 1) | (((d[8 + y] >> (7 - x)) & 1) << 1)
                    c = pram[4 * pal + v] if v else pram[0]
                    px[8 * tx + x, 8 * ty + y] = NES_RGB[c & 0x3F]
    area = ram[0x50]
    buf = ps.build_room(b5, ram)
    mine = render_room(AreaArt(rm, area), buf)
    a, b = live.load(), mine.load()
    same = sum(a[x, y] == b[x, y] for x in range(ROOM_W) for y in range(ROOM_H))
    cells = sum(all(a[cx * 16 + x, cy * 16 + y] == b[cx * 16 + x, cy * 16 + y]
                    for x in range(16) for y in range(16))
                for cx in range(16) for cy in range(12))
    print(f"area {area}, room ${ram[0xE4] | ram[0xE5] << 8:04X}: {same:,} of "
          f"{ROOM_W * ROOM_H:,} pixels and {cells} of 192 cells identical to the savestate's "
          f"own screen (pattern table ${tb:04X})")
    both = Image.new("RGB", (ROOM_W * 2 + 8, ROOM_H), (0, 0, 0))
    both.paste(live, (0, 0))
    both.paste(mine, (ROOM_W + 8, 0))
    import tempfile
    out = Path(tempfile.gettempdir()) / "labyrinth-verify.png"
    both.save(out)
    print(f"wrote {out} (left: the savestate, right: this tool)")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--out", type=Path, default=OUT)
    ap.add_argument("--verify", type=Path, metavar="STATE")
    args = ap.parse_args()

    rm = load(ROOT)
    if args.verify:
        return verify(rm, args.verify)
    ps = _module("parse-structs")
    b5 = rm.prg_bank(5)
    recs, _ = wm.records(b5)
    grid = {(r["row"], r["col"]): r for r in recs}
    areas = room_areas(recs)
    arts = {a: AreaArt(rm, a) for a in sorted(set(areas.values()))}
    img = Image.new("RGB", (wm.COLUMNS * ROOM_W, wm.ROWS * ROOM_H), EMPTY_RGB)
    drawn = 0
    for (row, col), area in sorted(areas.items()):
        r = grid[(row, col)]
        buf = ps.build_room(b5, room_ram(recs, grid, r, area))
        img.paste(render_room(arts[area], buf), (col * ROOM_W, row * ROOM_H))
        drawn += 1
    args.out.parent.mkdir(parents=True, exist_ok=True)
    img.save(args.out, optimize=True)
    half = args.out.with_name(args.out.stem + "-half.png")
    img.resize((img.width // 2, img.height // 2), Image.LANCZOS).save(half, optimize=True)
    print(f"{drawn} rooms in {len(arts)} areas; wrote {args.out.relative_to(ROOT)} "
          f"({img.width} x {img.height}) and {half.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
