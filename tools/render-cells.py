#!/usr/bin/env python3
"""Draw what a shot does to the labyrinth's cells: ``docs/cell-effects.png``.

    python tools/render-cells.py --state "D:/emu/.../...labyrinth.fcs"

Area 0's tiles, metatile sets and palettes come from the ROM, the way ``render-labyrinth.py`` draws
a room. The warp ring and bracket tiles (``$00-$07`` of the background table) are not in the tile
blocks that decoder knows - where they are loaded is not established - so those two are drawn from
the labyrinth savestate's live CHR RAM, which is the owner's file: this is not part of
``build.py`` and the picture is committed. Top row: each metatile that a
weapon can change and what it becomes - the checkered floor (tiles ``$1C-$1F``), the blue
sphere (``$28-$2B``), the warp ring (``$00-$03``) or the bracketed panel (``$04-$07``), which
bank 7 ``$D865`` draws as a raw 2 x 2 block of tile numbers in palette 0. Bottom row: the ones
a weapon does not change. Tile order of the block is the one ``$D865`` writes (A, A+2 / A+1, A+3,
i.e. column by column). See ``tgl/site.py`` ``_cell_hit_section`` for what each is.
"""

from __future__ import annotations

import argparse
import importlib.util
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from PIL import Image, ImageDraw

from tgl.model import load

ROOT = Path(__file__).resolve().parent.parent
S = 4
BACKDROP = (0, 0, 0)


def _art():
    spec = importlib.util.spec_from_file_location("rl", ROOT / "tools" / "render-labyrinth.py")
    rl = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(rl)
    return rl


def quad(art, first: int, pal: int = 0, live=None) -> Image.Image:
    """The 2 x 2 block bank 7 $D865 draws for tile number `first`."""
    img = Image.new("RGB", (16, 16), BACKDROP)
    px = img.load()
    colours = art.pals[pal]
    for k, off in enumerate((0, 2, 1, 3)):                  # TL, TR, BL, BR
        tile = art.chr.get(first + off)
        if tile is None and live is not None:
            tile = live[first + off]
        if tile is None:
            continue
        for y in range(8):
            for x in range(8):
                v = ((tile[y] >> (7 - x)) & 1) | (((tile[8 + y] >> (7 - x)) & 1) << 1)
                if v:
                    px[(k % 2) * 8 + x, (k // 2) * 8 + y] = colours[v - 1]
    return img


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--state", type=Path, required=True)
    args = ap.parse_args()
    spec = importlib.util.spec_from_file_location("savestate", ROOT / "tools" / "savestate.py")
    ss = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(ss)
    st = ss.read_state(args.state)
    base = 0x1000 if st["PPUR"][0] & 0x10 else 0
    live = {k: bytes(st["CHRR"][base + 16 * k: base + 16 * k + 16]) for k in range(256)}
    rl = _art()
    rm = load(ROOT)
    art = rl.AreaArt(rm, 0)
    big = lambda im: im.resize((16 * S, 16 * S), Image.NEAREST)
    hits = [("id 1", art.metatile(1), "3 hits", quad(art, 0x1C), "floor"),
            ("id 2", art.metatile(2), "2 hits", quad(art, 0x1C), "floor"),
            ("id 3", art.metatile(3), "1 hit", quad(art, 0x1C), "floor"),
            ("id 4", art.metatile(4), "1 hit", quad(art, 0x28), "sphere"),
            ("id 8", art.metatile(8), "4 hits", quad(art, 0x00, live=live), "warp ring"),
            ("id 8", art.metatile(8), "4 hits, other key", quad(art, 0x04, live=live), "brackets")]
    same = [("id 9", art.metatile(9)), ("id 12", art.metatile(12)), ("id 6", art.metatile(6)),
            ("id 7", art.metatile(7)), ("id 5", art.metatile(5)), ("id 10", art.metatile(10))]
    cw = 16 * S * 2 + 56
    img = Image.new("RGB", (cw * len(hits), 2 * (16 * S + 34) + 12), (24, 24, 32))
    d = ImageDraw.Draw(img)
    for i, (n, before, label, after, what) in enumerate(hits):
        x = i * cw + 8
        d.text((x, 2), f"{n}: {label}", fill=(230, 230, 230))
        img.paste(big(before), (x, 16))
        d.text((x + 16 * S + 8, 16 + 16 * S // 2 - 5), "->", fill=(230, 230, 230))
        img.paste(big(after), (x + 16 * S + 28, 16))
        d.text((x + 16 * S + 28, 18 + 16 * S), what, fill=(230, 230, 230))
    y0 = 16 * S + 44
    d.text((8, y0 - 14), "unchanged by any weapon", fill=(230, 230, 230))
    for i, (n, mt) in enumerate(same):
        x = i * (16 * S + 14) + 8
        img.paste(big(mt), (x, y0 + 4))
        d.text((x, y0 + 8 + 16 * S), n, fill=(230, 230, 230))
    img = img.crop((0, 0, img.width, y0 + 16 * S + 26))
    out = ROOT / "docs" / "cell-effects.png"
    img.save(out, optimize=True)
    print(f"wrote {out.relative_to(ROOT)} ({img.width} x {img.height})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
