#!/usr/bin/env python3
"""Run the eleven A-button weapons at all three levels on the real code and draw their paths.

    python tools/render-subweapons.py --state "D:/emu/.../Guardian Legend, The.ingame.fcs"

Writes ``docs/subweapons.png``: one column per weapon, one row per level, each cell the weapon's
sprites overlaid every few frames (a trail, newest brightest) with the ship's own position as a
white cross, in a corridor (the savestate's), nothing else on screen. The Enemy Eraser (12) has
no object to draw. The savestate is the owner's and not in the repository, so this is not part of
``build.py``; the picture is committed. How the run is set up (``tgl/cpu.py`` has the NES model):

* the savestate is a **demo frame** (``$30`` bit 7), whose input would overwrite the pad, so the
  bit is cleared;
* the weapon and its level are poked into ``$04AC-$04AE`` / ``$3C`` and the ROM's own ``$FD77``
  is called to fill ``$3D``, ``$3E``, ``$3B``, ``$45`` exactly as the game does; chips are 5,000;
* A is tapped for six frames (held for the two lasers, which stop when it is released), the ship's
  collision flags are zeroed, and every enemy slot is cleared each frame so only the weapon is
  drawn (this also means the Area Blaster has nothing to home in on here).
"""

from __future__ import annotations

import argparse
import importlib.util
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from PIL import Image, ImageChops, ImageDraw

from tgl.cpu import Machine
from tgl.model import load
from tgl.site import NES_RGB

ROOT = Path(__file__).resolve().parent.parent
RET = 0xC000
CELL_W, CELL_H = 128, 192
FRAMES = 96
STEP = 4


def call(m, addr):
    m.push((RET - 1) >> 8)
    m.push((RET - 1) & 255)
    pc = m.pc
    m.pc = addr
    while m.pc != RET:
        m.step()
    m.pc = pc


def setup(rm, st, w, lvl, chips=5000):
    m = Machine(rm)
    m.load_savestate(st)
    m.a, m.x, m.y = st["A"][0], st["X"][0], st["Y"][0]
    m.s, m.p = st["S"][0], st["P"][0]
    m.pc = st["PC"][0] | st["PC"][1] << 8
    for i in range(0x4AC, 0x4B0):
        m.ram[i] = 0
    k = w - 1
    m.ram[0x4AC + (k >> 2)] = lvl << (2 * (k & 3))
    m.ram[0x4AF] = 9
    for i in range(1, 5):
        m.ram[0x500 + i] = 0
    m.ram[0x30] &= 0x7F
    m.ram[0x3C] = w
    m.ram[0x4C], m.ram[0x4D] = chips & 255, chips >> 8
    m.ram[0x4E], m.ram[0x4F] = 0xFF, 0x1F
    m.ram[0x47] = m.ram[0x48] = 0xFF
    regs = (m.a, m.x, m.y, m.s, m.p)
    call(m, 0xFD77)
    m.a, m.x, m.y, m.s, m.p = regs
    return m


def cell(rm, st, w, lvl):
    m = setup(rm, st, w, lvl)
    tap = (3, 60) if w in (10, 11) else (3, 9)
    trail = Image.new("RGB", (256, 240), (0, 0, 0))
    sx = sy = None
    for f in range(FRAMES):
        m.pad = 1 if tap[0] <= f < tap[1] else 0
        m.ram[0x578] = 0
        m.ram[0x48] = 0xFF
        for i in range(5, 24):
            m.ram[0x500 + i] = 0
        m.run_frame()
        sx, sy = m.ram[0x530], m.ram[0x518]
        if f >= 4 and f % STEP == 0:
            m.mask |= 0x18                  # this savestate has rendering off at its moment
            img = m.render(NES_RGB, bg=False).convert("RGB")
            # keep only the weapon's pixels: blank the ship by painting over its box
            ImageDraw.Draw(img).rectangle((sx - 14, sy - 14, sx + 14, sy + 14), fill=(0, 0, 0))
            trail = ImageChops.lighter(trail, img)
    x0 = sx - CELL_W // 2
    out = trail.crop((x0, 0, x0 + CELL_W, CELL_H))
    d = ImageDraw.Draw(out)
    cx, cy = CELL_W // 2, sy
    d.line((cx - 5, cy, cx + 5, cy), fill=(255, 255, 255))
    d.line((cx, cy - 5, cx, cy + 5), fill=(255, 255, 255))
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--state", type=Path, required=True)
    ap.add_argument("--out", type=Path, default=ROOT / "docs")
    args = ap.parse_args()
    spec = importlib.util.spec_from_file_location("savestate", ROOT / "tools" / "savestate.py")
    ss = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(ss)
    st = ss.read_state(args.state)
    rm = load(ROOT)
    top = 18
    sheet = Image.new("RGB", (CELL_W * 11, top + CELL_H * 3), (24, 24, 32))
    d = ImageDraw.Draw(sheet)
    for w in range(1, 12):
        d.text((w * 0 + (w - 1) * CELL_W + 4, 3), f"weapon {w}", fill=(230, 230, 230))
        for lvl in (1, 2, 3):
            sheet.paste(cell(rm, st, w, lvl), ((w - 1) * CELL_W, top + (lvl - 1) * CELL_H))
            print(f"weapon {w} level {lvl}", flush=True)
    for x in range(1, 11):
        d.line((x * CELL_W, 0, x * CELL_W, sheet.height), fill=(60, 60, 80))
    for y in (1, 2):
        d.line((0, top + y * CELL_H, sheet.width, top + y * CELL_H), fill=(60, 60, 80))
    sheet.save(args.out / "subweapons.png", optimize=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
