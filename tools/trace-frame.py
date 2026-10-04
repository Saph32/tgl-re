#!/usr/bin/env python3
"""Trace the game loop on the NES model: one frame in order, and timing over many.

    python tools/trace-frame.py --state "D:/emu/.../Guardian Legend, The.ingame.fcs" [--frames 400]

Runs the ROM's own code from a corridor savestate (``$30`` bit 7 cleared: the savestate is a demo
frame whose input would otherwise override everything; the ship's collision flags and life are
held so a long run does not end) and records the first CPU cycle, counted from the start of the
frame's NMI, at which each marked routine is reached. Prints (1) one frame in which a new
background row is built, routine by routine, and (2) min / median / max of each routine's first
cycle over the run, how many frames built a new row, and whether the NMI ever fired before the
loop reached its sync (``$2B`` already non-zero at ``$DA9A``: a frame that overran).

This is the evidence behind ``docs/gameloop.html``. The model is not cycle-accurate (no DMA
stalls, no IRQ, DMC or APU), so the numbers are indicative; see ``tgl/cpu.py``. The savestate is the
owner's, so this is not part of ``build.py``.
"""

from __future__ import annotations

import argparse
import importlib.util
import statistics
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl.cpu import Machine
from tgl.model import load

ROOT = Path(__file__).resolve().parent.parent

# (address, bank or 7 for the fixed bank) -> (short key, description)
MARKS = {
    (0xDC75, 7): ("nmi", "NMI entry"),
    (0xDD54, 7): ("nmi_ppu", "  NMI: PPU row and queue writes"),
    (0xDEC9, 7): ("nmi_pal", "  NMI: palette upload"),
    (0xD68B, 7): ("nmi_scroll", "  NMI: scroll registers"),
    (0x917C, 0): ("sound", "  NMI: sound tick (bank 0 $917C)"),
    (0xDCF2, 7): ("rti", "  NMI: RTI"),
    (0xF493, 7): ("pads", "F493  pads, pause check"),
    (0x81FB, 6): ("objloop", "bank 6 $81FB  object loop"),
    (0xCDB4, 7): ("oam_start", "  CDB4  sprite allocator reset"),
    (0xCE88, 7): ("objend", "  CE88  sprites finished"),
    (0xE0F9, 7): ("hud", "E0F9  HUD meter and score"),
    (0xDB52, 7): ("decomp", "DB52  tile decompressor"),
    (0x917F, 3): ("stage3", "bank 3 $917F  stage/boss state"),
    (0xFF7A, 7): ("looptop", "FF7A  main loop top"),
    (0xE655, 7): ("e655", "E655  stage step"),
    (0xE530, 7): ("scroll", "  E530  scroll step"),
    (0xE6AC, 7): ("newrow", "  E6AC  new background row"),
    (0xE6CE, 7): ("stream", "  E6CE  stream trigger test"),
    (0xE8AB, 7): ("e8ab", "  E8AB  build row ids"),
    (0xE995, 7): ("loader", "E995  art loader and spawn script"),
    (0xDA9A, 7): ("sync", "DA9A  frame sync"),
    (0xDAB6, 7): ("wait", "  DAB6  sprite-0 wait loop"),
    (0xDD21, 7): ("split", "  DD21  the split"),
}
HANDLER = (0x821E, 6)


def machine(rm, state):
    m = Machine(rm)
    m.load_savestate(state)
    m.a, m.x, m.y = state["A"][0], state["X"][0], state["Y"][0]
    m.s, m.p = state["S"][0], state["P"][0]
    m.pc = state["PC"][0] | state["PC"][1] << 8
    m.ram[0x30] &= 0x7F
    return m


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--state", type=Path, required=True)
    ap.add_argument("--frames", type=int, default=400)
    ap.add_argument("--pad", type=lambda v: int(v, 0), default=0,
                    help="buttons held every frame, bit 0 = A, 1 = B, 2 = Select, 3 = Start, 4-7 = Up Down Left Right")
    args = ap.parse_args()
    spec = importlib.util.spec_from_file_location("savestate", ROOT / "tools" / "savestate.py")
    ss = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(ss)
    rm = load(ROOT)
    m = machine(rm, ss.read_state(args.state))
    for _ in range(30):
        m.run_frame()

    events: list = []
    firsts: dict = {}
    orig = m.step

    def step():
        key = (m.pc, m.bank if m.pc < 0xC000 else 7)
        if key in MARKS:
            k = MARKS[key][0]
            events.append((m.fc, MARKS[key][1]))
            firsts.setdefault(k, m.fc)
            if k == "sync":
                firsts["sync_overrun"] = m.ram[0x2B]
        elif key == HANDLER:
            slot = m.ram[0x37]
            events.append((m.fc, f"    handler: slot {slot}, type ${m.ram[0x500 + slot] & 0x7F:02X}"))
        return orig()

    m.step = step
    rows, shown = [], False
    for f in range(args.frames):
        events.clear()
        firsts.clear()
        m.pad = args.pad
        m.ram[0x578] = 0
        m.ram[0x48] = 0xFF
        m.run_frame()
        rows.append(dict(firsts))
        if not shown and ("newrow" in firsts or (f == 20 and "newrow" not in firsts and not any("newrow" in r for r in rows))):
            shown = True
            print(f"--- frame {f}: " + ("a frame that builds a new row" if "newrow" in firsts else "a frame (no row is ever built here: not a scrolling stage)") + " ---")
            last = None
            for c, text in events:
                if "sprite-0 wait" in text and last == text:
                    continue
                print(f"{c:6d}  {text}")
                last = text
    print(f"\n--- {args.frames} frames: first cycle of each routine (min / median / max, frames having it) ---")
    for key in ("rti", "pads", "objloop", "objend", "hud", "decomp", "stage3", "e655", "newrow",
                "e8ab", "loader", "sync", "wait", "split"):
        v = [r[key] for r in rows if key in r]
        if v:
            print(f"  {key:8s} {min(v):6d} {int(statistics.median(v)):6d} {max(v):6d}   ({len(v)})")
    print("  frames that built a new row:", sum(1 for r in rows if "newrow" in r), "of", len(rows))
    print("  frames where the NMI had already fired at the sync:",
          sum(1 for r in rows if r.get("sync_overrun")))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
