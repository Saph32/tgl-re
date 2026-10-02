#!/usr/bin/env python3
"""Run the ROM's own ending code and cutscene (tgl/cpu.py) and write what they draw.

    python tools/render-ending.py --state "D:/emu/.../Guardian Legend, The.ingame.fcs"

Writes into docs/:

* ``cutscene.gif`` and ``cutscene-film.png`` - the scene after corridor 21 (bank 0 ``$8012``
  then bank 2 ``$801B``, ``$8836``), run from ``$ECCA`` to ``$ECDC``;
* ``ending-normal.png`` and ``ending-tgl.png`` - the screen the ending routine (bank 2
  ``$8A69``) leaves when it far-calls the credits, for a normal game and a TGL game (``$30``
  bit 1), run from ``$F66B``.

**This needs a savestate and the savestate is not in the repository** - it is the owner's
file - which is why ``build.py`` does not run this and the images are committed. Any
corridor savestate works as a start; the one used is recorded on the Ending page. Read the
header of ``tgl/cpu.py`` before citing anything drawn this way: it runs the code on an
approximate NES (no cycle accuracy, one scroll value per frame, no IRQ, no audio), from a
savestate's RAM, CHR and OAM, with only the palette, ``$51``, ``$30`` and the stage-clear
state replaced.
"""

from __future__ import annotations

import argparse
import importlib.util
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from PIL import Image

from tgl import ending
from tgl.model import load
from tgl.site import NES_RGB

ROOT = Path(__file__).resolve().parent.parent
FILM_COLS, FILM_ROWS = 6, 4


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--state", type=Path, required=True)
    ap.add_argument("--out", type=Path, default=ROOT / "docs")
    args = ap.parse_args()

    spec = importlib.util.spec_from_file_location("savestate", ROOT / "tools" / "savestate.py")
    ss = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(ss)
    state = ss.read_state(args.state)
    rm = load(ROOT)

    frames, total = ending.cutscene(rm, state, NES_RGB, every=4)
    args.out.mkdir(parents=True, exist_ok=True)
    frames[0].save(args.out / "cutscene.gif", save_all=True, append_images=frames[1:],
                   duration=67, loop=0, optimize=True)
    n = FILM_COLS * FILM_ROWS
    pick = [frames[round(i * (len(frames) - 1) / (n - 1))] for i in range(n)]
    sheet = Image.new("RGB", (FILM_COLS * 130, FILM_ROWS * 122), (40, 40, 44))
    for i, f in enumerate(pick):
        sheet.paste(f.resize((128, 120), Image.LANCZOS), ((i % FILM_COLS) * 130 + 1,
                                                          (i // FILM_COLS) * 122 + 1))
    sheet.save(args.out / "cutscene-film.png", optimize=True)

    for name, img in ending.ending_screens(rm, state, NES_RGB).items():
        img.save(args.out / f"ending-{name}.png", optimize=True)
    print(f"cutscene: {total} frames ({total / 60:.1f} s) run, {len(frames)} kept in "
          f"cutscene.gif; ending-normal.png, ending-tgl.png written to {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
