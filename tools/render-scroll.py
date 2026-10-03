#!/usr/bin/env python3
"""Draw how the game scrolls: both nametables, the visible window, and the screen it gives.

    python tools/render-scroll.py --corridor "D:/emu/.../...ingame.fcs" --labyrinth "D:/emu/.../...labyrinth.fcs"

Writes ``docs/scroll-lab-rest.png``, ``-lab-north.png``, ``-lab-east.png``, ``-corridor.png`` and
``-status.png``. Each is the two nametables side by side (NT0 left, NT1 right: vertical mirroring
puts them next to each other, and ``$2800``/``$2C00`` are the same two), a red outline for the
part the picture is taken from (it wraps at the edges), a green one for the HUD (NT1 rows 24-29,
what the sprite-0 split switches to), yellow marks on the column-0 ``$FE`` tiles sprite 0 hits, and
beside it the screen the NES model draws from that same state. The savestates are the owner's, so
this is not part of ``build.py``; the pictures are committed. How the states are reached
(``tgl/cpu.py`` is the NES model; the savestates are demo/ingame frames, so ``$30`` bit 7 is
cleared): the labyrinth room is walked out of its north and east exits with the pad held, and a
frame is kept part-way through the scroll; the corridor is left running a few dozen frames; the
status screen is opened by calling ``$E4EE``.
"""

from __future__ import annotations

import argparse
import importlib.util
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from PIL import Image, ImageDraw

from tgl.cpu import Machine
from tgl.model import load
from tgl.site import NES_RGB

ROOT = Path(__file__).resolve().parent.parent
RET = 0xC000


def machine(rm, state):
    m = Machine(rm)
    m.load_savestate(state)
    m.a, m.x, m.y = state["A"][0], state["X"][0], state["Y"][0]
    m.s, m.p = state["S"][0], state["P"][0]
    m.pc = state["PC"][0] | state["PC"][1] << 8
    m.ram[0x30] &= 0x7F                      # the savestates are demo frames
    return m


def nt_map(m) -> Image.Image:
    """Both nametables, 512 x 240, drawn with the live CHR RAM and palettes."""
    img = Image.new("RGB", (512, 240), NES_RGB[m.pal[0] & 0x3F])
    px = img.load()
    base = 0x1000 if m.ctrl & 0x10 else 0
    for nt in (0, 1):
        for row in range(30):
            for col in range(32):
                n = m.nt[nt * 0x400 + row * 32 + col]
                at = m.nt[nt * 0x400 + 0x3C0 + (row // 4) * 8 + col // 4]
                pal = (at >> (((row % 4) // 2) * 4 + ((col % 4) // 2) * 2)) & 3
                d = base + 16 * n
                for y in range(8):
                    lo, hi = m.chr[d + y], m.chr[d + 8 + y]
                    for x in range(8):
                        v = ((lo >> (7 - x)) & 1) | (((hi >> (7 - x)) & 1) << 1)
                        if v:
                            px[nt * 256 + col * 8 + x, row * 8 + y] = NES_RGB[m.pal[4 * pal + v] & 0x3F]
    return img


def window(m):
    """(x, y) the picture is taken from for the playfield: the scroll in force at scanline 90."""
    at = 2273 + 114 + 90 * 113.67
    e = m.scroll_log[0]
    for ent in m.scroll_log:
        if ent[0] <= at:
            e = ent
    _, sx, sy, cx = e
    return (sx + 256 * (cx & 1)) % 512, sy % 240


def outline(d, x0, y0, w, h, colour, wrap_x=512, wrap_y=240):
    for dx in (0, -wrap_x):
        for dy in (0, -wrap_y):
            d.rectangle((x0 + dx, y0 + dy, x0 + dx + w - 1, y0 + dy + h - 1), outline=colour)


def panel(m, with_window=True, window_h=192) -> Image.Image:
    m.mask |= 0x18
    nts = nt_map(m).convert("RGB")
    d = ImageDraw.Draw(nts)
    if with_window:
        x0, y0 = window(m)
        outline(d, x0, y0, 256, window_h, (255, 60, 60))
    d.rectangle((256, 192, 511, 239), outline=(60, 255, 60))
    for nt in (0, 1):
        for row in range(30):
            if m.nt[nt * 0x400 + row * 32] == 0xFE:
                d.rectangle((nt * 256, row * 8, nt * 256 + 7, row * 8 + 7), outline=(255, 230, 0))
    scr = m.render(NES_RGB)
    out = Image.new("RGB", (512 + 12 + 256, 240), (24, 24, 32))
    out.paste(nts, (0, 0))
    out.paste(scr, (512 + 12, 0))
    return out


def frames(m, n, pad=0, hook=None):
    for f in range(n):
        m.pad = pad
        for i in range(5, 24):
            m.ram[0x500 + i] = 0
        m.ram[0x48] = 0xFF
        m.run_frame()
        if hook and hook(m, f):
            return f
    return None


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--corridor", type=Path, required=True)
    ap.add_argument("--labyrinth", type=Path, required=True)
    ap.add_argument("--out", type=Path, default=ROOT / "docs")
    args = ap.parse_args()
    spec = importlib.util.spec_from_file_location("savestate", ROOT / "tools" / "savestate.py")
    ss = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(ss)
    rm = load(ROOT)
    lab = ss.read_state(args.labyrinth)
    cor = ss.read_state(args.corridor)

    m = machine(rm, lab)
    frames(m, 6)
    panel(m).save(args.out / "scroll-lab-rest.png", optimize=True)
    print("rest", window(m))

    m = machine(rm, lab)                         # north: the ship at the top of the open column
    m.ram[0x518], m.ram[0x530] = 0x34, 0x78
    frames(m, 120, 0x10, lambda m, f: m.ram[0xA4] == 0 and m.ram[0xA6] and 120 <= m.ram[0xA6] <= 124)
    panel(m).save(args.out / "scroll-lab-north.png", optimize=True)
    print("north", window(m), m.ram[0xA6])

    m = machine(rm, lab)                         # east
    m.ram[0x518], m.ram[0x530] = 0x78, 0xD8
    frames(m, 150, 0x80, lambda m, f: m.ram[0xA4] == 6 and 124 <= m.ram[0xA8] <= 128)
    panel(m).save(args.out / "scroll-lab-east.png", optimize=True)
    print("east", window(m), m.ram[0xA8])

    m = machine(rm, cor)
    frames(m, 40)
    panel(m).save(args.out / "scroll-corridor.png", optimize=True)
    print("corridor", window(m), m.ram[0xA6], m.ram[0xAE])

    m = machine(rm, lab)
    frames(m, 5)
    m.push((RET - 1) >> 8)
    m.push((RET - 1) & 255)
    m.pc = 0xE4EE
    for _ in range(40):
        m.pad = 0
        if m.run_frame(stops=(RET,)) == RET:
            break
    panel(m, window_h=240).save(args.out / "scroll-status.png", optimize=True)
    print("status", window(m))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
