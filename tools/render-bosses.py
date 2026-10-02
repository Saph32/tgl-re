#!/usr/bin/env python3
"""Run corridors 0, 7 and 17 to their bosses on the real code and write what is on screen.

    python tools/render-bosses.py --state "D:/emu/.../Guardian Legend, The.ingame.fcs"

Writes ``docs/boss-C.png`` (the playfield, 256 x 192, as the game draws it) for C = 0, 7, 17
and ``docs/boss-objects.json`` (the live objects at that moment, and whether the frame with the
background left out is empty - it is, for all three, so no second picture is written). Corridor 0's boss is the
Defense System, corridors 7 and 17's the Eyeball Growth (names from the owner). **Needs a
savestate, which is not in the repository**, so this is not part of ``build.py``; the images
are committed. See ``tgl/bossrun.py`` for how the run is set up and ``tgl/cpu.py`` for what
the NES model does not do. Each corridor takes one to three minutes.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl import bossrun
from tgl.model import load
from tgl.site import NES_RGB

ROOT = Path(__file__).resolve().parent.parent
PLAYFIELD_H = 192


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--state", type=Path, required=True)
    ap.add_argument("--out", type=Path, default=ROOT / "docs")
    ap.add_argument("--corridors", type=int, nargs="*", default=[0, 7, 17])
    args = ap.parse_args()
    spec = importlib.util.spec_from_file_location("savestate", ROOT / "tools" / "savestate.py")
    ss = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(ss)
    state = ss.read_state(args.state)
    rm = load(ROOT)
    args.out.mkdir(parents=True, exist_ok=True)
    meta = {}
    for c in args.corridors:
        r = bossrun.run_to_boss(rm, state, c, NES_RGB)
        r["full"].crop((0, 0, 256, PLAYFIELD_H)).save(args.out / f"boss-{c}.png", optimize=True)
        empty = r["sprites"].crop((0, 0, 256, PLAYFIELD_H)).convert("RGB").getbbox() is None
        meta[str(c)] = {"frames": r["frames"], "row": r["row"], "objects": r["objects"],
                        "sprites_empty": empty}
        print(f"corridor {c}: boss phase after {r['frames']} frames, row {r['row']}, "
              f"{len(r['objects'])} objects")
    old = {}
    f = args.out / "boss-objects.json"
    if f.exists():
        old = json.loads(f.read_text(encoding="utf-8"))
    old.update(meta)
    f.write_text(json.dumps(old, indent=1), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
