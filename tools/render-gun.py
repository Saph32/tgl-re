#!/usr/bin/env python3
"""Run the main gun at four chip totals on the real code and write what a shot looks like.

    python tools/render-gun.py --state "D:/emu/.../Guardian Legend, The.ingame.fcs"

Writes ``docs/gun-tiers.png`` (one column per chip tier, the shot's two alternating frames, 4x)
and ``docs/gun-tiers.json`` (what each live shot held: speed class, metasprite, hitbox,
measured speed). The savestate (corridor 15, ship alive) is the owner's and is not in the
repository, so this is not part of ``build.py``; the picture is committed. B is held on the
NES model's pad (``tgl/cpu.py``); the chip total is poked and ``$3A`` set the way ``$E213`` does
(the routine itself is checked against the thresholds in the same run). One shot is kept
alive and the others are removed, so the crop holds nothing else.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from PIL import Image, ImageDraw

from tgl.cpu import Machine
from tgl.model import load
from tgl.site import NES_RGB

ROOT = Path(__file__).resolve().parent.parent
RET = 0xC000
CHIPS = (50, 150, 500, 3000)


def tier_by_routine(rm, st, chips: int) -> int:
    """Call the ROM's own $E213 and read $3A."""
    m = Machine(rm)
    m.load_savestate(st)
    m.a, m.x, m.y = st["A"][0], st["X"][0], st["Y"][0]
    m.s, m.p = st["S"][0], st["P"][0]
    m.ram[0x4C], m.ram[0x4D] = chips & 255, chips >> 8
    m.push((RET - 1) >> 8)
    m.push((RET - 1) & 255)
    m.pc = 0xE213
    while m.pc != RET:
        m.step()
    return m.ram[0x3A]


def shot(rm, st, chips: int, tier: int, frames: int = 14) -> dict:
    m = Machine(rm)
    m.load_savestate(st)
    m.a, m.x, m.y = st["A"][0], st["X"][0], st["Y"][0]
    m.s, m.p = st["S"][0], st["P"][0]
    m.pc = st["PC"][0] | st["PC"][1] << 8
    m.ram[0x3A] = tier
    m.ram[0x47] = m.ram[0x48] = 0xFF
    m.pad = 0x02                                    # B held
    mine = None
    got = []
    b7 = rm.prg_bank(7)
    for f in range(300):
        m.ram[0x4C], m.ram[0x4D] = chips & 255, chips >> 8
        m.ram[0x578] = 0
        if mine is not None:
            m.pad = 0
            for i in range(1, 5):
                if i != mine:
                    m.ram[0x500 + i] = 0
        m.run_frame()
        if mine is None:
            fresh = [i for i in range(1, 5) if m.ram[0x500 + i] & 0x7F == 2
                     and m.ram[0x518 + i] > 150 and m.ram[0x698 + i] == (0x81, 0x43, 0x82, 0x83)[tier]]
            if fresh:
                mine = fresh[0]
                t0 = m.frame
                prev = (m.ram[0x548 + mine], m.ram[0x518 + mine], m.ram[0x530 + mine], m.ram[0x698 + mine])
            continue
        # the OAM at the end of a frame was DMA'd at its start, so it shows the previous
        # frame's drawing: pair the picture with the previous frame's object state
        here = (m.ram[0x548 + mine], m.ram[0x518 + mine], m.ram[0x530 + mine], m.ram[0x698 + mine])
        if m.frame - t0 >= 10 and len(got) < 2:
            ms, y, x, param = prev
            m.mask |= 0x18      # this savestate has $2001 = $0E (rendering off) at its moment
            img = m.render(NES_RGB, bg=False).convert("RGB")
            got.append({"metasprite": ms, "y": y, "x": x, "param": param,
                        "half_w": b7[0xC174 - 0xC000 + ms], "half_h": b7[0xC201 - 0xC000 + ms],
                        "image": img.crop((x - 24, y - 24, x + 24, y + 24))})
        prev = here
        if len(got) == 2:
            break
    return {"chips": chips, "tier": tier, "frames": got}


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
    runs = []
    for c in CHIPS:
        t = tier_by_routine(rm, st, c)
        r = shot(rm, st, c, t)
        runs.append(r)
        print(f"chips {c}: tier {t}, frames {[f['metasprite'] for f in r['frames']]}")
    cell, scale = 48 * 4, 4
    sheet = Image.new("RGB", (cell * len(runs), cell * 2 + 24), (24, 24, 32))
    d = ImageDraw.Draw(sheet)
    meta = []
    for col, r in enumerate(runs):
        d.text((col * cell + 6, 4), f"{r['chips']} chips (tier {r['tier']})", fill=(230, 230, 230))
        for row, f in enumerate(r["frames"]):
            sheet.paste(f["image"].resize((cell, cell), Image.NEAREST), (col * cell, 24 + row * cell))
        meta.append({"chips": r["chips"], "tier": r["tier"],
                     "frames": [{k: v for k, v in f.items() if k != "image"} for f in r["frames"]]})
    sheet.save(args.out / "gun-tiers.png", optimize=True)
    (args.out / "gun-tiers.json").write_text(json.dumps(meta, indent=1), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
