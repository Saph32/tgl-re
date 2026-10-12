#!/usr/bin/env python3
"""Profile the game loop on the NES model: how many cycles each phase of an iteration takes.

    python tools/profile-loop.py --state A.fcs --state B.fcs ... [--frames 300] [--json out.json]

``tools/trace-frame.py`` reports where in a frame each routine *starts*, which is only meaningful
while the loop keeps up with the screen. This tool times the loop in absolute cycles instead, so an
iteration that overruns a frame (the NMI fires before the loop reaches its sync) is counted as what
it is: one iteration spanning several frames.

An **iteration** runs from one ``$F493`` (pads) to the next. Its phases, in the order the loop
runs them, are measured as the cycles between the marker routines, **minus the cycles spent inside
the NMI** (``$DC75`` to its RTI at ``$DCF2``), which interrupts whichever phase it lands in:

    pads      $F493 -> bank 6 $81FB      pads, pause check
    objects   $81FB -> $CE88             the object loop (also split by handler type)
    finish    $CE88 -> $E0F9             the player's death check, the end of the loop
    hud       $E0F9 -> $DB52             life meter, score
    decomp    $DB52 -> bank 3 $917F      tile decompressor
    boss      $917F -> $E655             the boss/stage state (including the loop top)
    stage     $E655 -> $E995             scroll step; plus the new row when one is built
    loader    $E995 -> $DA9A             art loader and spawn script
    wait      $DA9A -> next $F493        the frame sync: idle time (0 if the loop overran)

It also reports the NMI's own cost, how many frames each iteration took (the game's real frame
rate is 60 / that), and how often the main thread did not reach the sprite-0 hit in time (on the
console the DMC interrupt does the split then; the model has none).

The savestates are the owner's; ``$30`` bit 7 (demo) is cleared and the ship's collision flags and
life are held (from the first frame, life = maximum, the HUD meter equal to it) so the run does not end. Not cycle-accurate: see ``tgl/cpu.py``.
"""

from __future__ import annotations

import argparse
import collections
import importlib.util
import json
import statistics
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl.cpu import Machine, StopRun
from tgl.model import load

ROOT = Path(__file__).resolve().parent.parent
FRAME = 29781
VBLANK = 2273            # cycles the model gives vblank (20 scan lines)

MARKS = {
    (0xDC75, 7): "nmi", (0xDCF2, 7): "rti",
    (0xF493, 7): "pads", (0x81FB, 6): "objects", (0xCE88, 7): "finish", (0xE0F9, 7): "hud",
    (0xDB52, 7): "decomp", (0x917F, 3): "boss", (0xE655, 7): "stage", (0xE6AC, 7): "newrow",
    (0xE995, 7): "loader", (0xDA9A, 7): "sync", (0xDD21, 7): "split",
    (0xD7C3, 7): "qwait", (0xD7F8, 7): "qdone",
}
HANDLER = (0x821E, 6)
PHASES = [("pads", "objects"), ("objects", "finish"), ("finish", "hud"), ("hud", "decomp"),
          ("decomp", "boss"), ("boss", "stage"), ("stage", "loader"), ("loader", "sync")]
NAMES = ["pads", "objects", "finish", "hud", "decomp", "boss", "stage", "loader"]


def machine(rm, state):
    m = Machine(rm)
    m.load_savestate(state)
    m.a, m.x, m.y = state["A"][0], state["X"][0], state["Y"][0]
    m.s, m.p = state["S"][0], state["P"][0]
    m.pc = state["PC"][0] | state["PC"][1] << 8
    m.ram[0x30] &= 0x7F
    return m


def describe(m) -> dict:
    r = m.ram
    types = collections.Counter(f"${r[0x500 + s] & 0x7F:02X}" for s in range(24) if r[0x500 + s])
    return {"corridor": r[0x51], "boss_phase": r[0x70], "speed": r[0xB8] | r[0xB9] << 8,
            "row": r[0xB0] | r[0xB1] << 8, "objects": sum(types.values()), "types": dict(types),
            "player_type": f"${r[0x500] & 0x7F:02X}",
            "sprites": sum(1 for k in range(64) if m.oam[4 * k] < 0xEF), "weapon": r[0x3C],
            "weapon_level": r[0x3D], "chips": r[0x4C] | r[0x4D] << 8}


def run(rm, state, frames):
    m = machine(rm, state)
    info = describe(m)
    def hold():
        m.ram[0x578] = 0                       # the ship's collision flags: nothing can hurt it
        m.ram[0x48] = m.ram[0x47]              # full life, and the HUD meter already at it
        m.ram[0x49] = m.ram[0x47]

    for _ in range(20):                       # settle
        hold()
        m.run_frame()
    base = [0]
    ev: list = []                              # (absolute cycle, name, extra)
    orig = m.step

    def step():
        key = (m.pc, m.bank if m.pc < 0xC000 else 7)
        name = MARKS.get(key)
        if name:
            ev.append((base[0] + m.fc, name, None))
        elif key == HANDLER:
            ev.append((base[0] + m.fc, "handler", (m.ram[0x37], m.ram[0x500 + m.ram[0x37]] & 0x7F)))
        return orig()

    m.step = step
    crashed = None
    frames_run = 0
    try:
        for f in range(frames):
            base[0] = f * FRAME
            hold()
            m.run_frame()
            frames_run += 1
    except StopRun as exc:
        crashed = str(exc)
    return info, ev, frames_run, crashed


def analyse(ev, frames_run):
    nmi_iv, cur = [], None
    for t, n, _ in ev:                         # NMI intervals
        if n == "nmi":
            cur = t
        elif n == "rti" and cur is not None:
            nmi_iv.append((cur, t))
            cur = None

    def nmi_in(a, b):
        return sum(max(0, min(b, y) - max(a, x)) for x, y in nmi_iv if y > a and x < b)

    # stalls waiting for the PPU queue to drain ($D7C3 .. its RTS), net of the NMIs inside them
    stall_iv, cur = [], None
    for t, n, _ in ev:
        if n == "qwait" and cur is None:
            cur = t
        elif n == "qdone" and cur is not None:
            stall_iv.append((cur, t))
            cur = None

    def stall_in(a, b):
        return sum(max(0, min(b, y) - max(a, x)) - nmi_in(max(a, x), min(b, y))
                   for x, y in stall_iv if y > a and x < b)

    def dead(a, b):                            # cycles that are neither this phase's work
        return nmi_in(a, b) + stall_in(a, b)

    pads = [t for t, n, _ in ev if n == "pads"]
    out = {k: [] for k in NAMES + ["wait", "iter", "stall", "newrow_extra", "stage_row", "stage_idle",
                                   "obj_overhead", "logic"]}
    handlers = collections.defaultdict(list)
    seq = [(t, n, x) for t, n, x in ev if n in MARKS.values() and n not in ("nmi", "rti", "split", "qwait", "qdone")
           or n == "handler"]
    for i in range(len(pads) - 1):
        a, b = pads[i], pads[i + 1]
        mk = {"pads": a}
        newrow = False
        hs = []
        for t, n, x in seq:
            if t < a or t >= b:
                continue
            if n == "newrow":
                newrow = True
            elif n == "handler":
                hs.append((t, x))
            elif n not in mk:
                mk[n] = t
        tot = 0
        for (p, q), name in zip(PHASES, NAMES):      # a phase only when both its markers are in order
            if p in mk and q in mk and mk[q] > mk[p]:
                d = mk[q] - mk[p] - dead(mk[p], mk[q])
                out[name].append(d)
                tot += d
                if name == "stage":
                    out["stage_row" if newrow else "stage_idle"].append(d)
        out["logic"].append(tot)
        if "sync" in mk:
            out["wait"].append(b - mk["sync"] - nmi_in(mk["sync"], b))
        out["iter"].append(b - a)
        out["stall"].append(stall_in(a, b))
        out["newrow_extra"].append(1 if newrow else 0)
        if "finish" in mk:                     # handlers: each runs until the next one (or $CE88)
            ends = [t for t, _ in hs[1:]] + [mk["finish"]]
            work = 0
            for (t, (slot, typ)), e in zip(hs, ends):
                if e > t:
                    d = e - t - dead(t, e)
                    handlers[typ].append(d)
                    work += d
            if "objects" in mk and mk["finish"] > mk["objects"]:
                out["obj_overhead"].append(mk["finish"] - mk["objects"] - dead(mk["objects"], mk["finish"]) - work)
    splits = {t // FRAME for t, n, _ in ev if n == "split"}
    # a frame is "late" when its NMI arrived while the logic was still running (the last marker
    # before it is not the sync): that frame repeats the previous picture
    late, order = 0, [(t, n) for t, n, _ in ev if n in ("nmi", "pads", "objects", "finish", "hud", "decomp",
                                                          "boss", "stage", "loader", "sync")]
    last = None
    for t, n in order:
        if n == "nmi":
            if last not in (None, "sync"):
                late += 1
        else:
            last = n
    nmi_cost = [y - x for x, y in nmi_iv]
    return out, handlers, nmi_cost, len(splits), late


def stat(v):
    if not v:
        return None
    v = sorted(v)
    return {"min": v[0], "median": int(statistics.median(v)), "p90": v[int(0.9 * (len(v) - 1))],
            "max": v[-1], "n": len(v)}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--state", type=Path, action="append", required=True)
    ap.add_argument("--frames", type=int, default=300)
    ap.add_argument("--json", type=Path)
    args = ap.parse_args()
    spec = importlib.util.spec_from_file_location("savestate", ROOT / "tools" / "savestate.py")
    ss = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(ss)
    rm = load(ROOT)
    results = {}
    for path in args.state:
        info, ev, frames_run, crashed = run(rm, ss.read_state(path), args.frames)
        out, handlers, nmi_cost, split_frames, late = analyse(ev, frames_run)
        res = {"state": path.name, "info": info, "frames_run": frames_run, "crashed": crashed,
               "iterations": len(out["iter"]), "nmi": stat(nmi_cost),
               "phases": {k: stat(out[k]) for k in NAMES + ["wait", "iter", "stall", "stage_row", "stage_idle",
                                                           "obj_overhead", "logic"]},
               "late_frames": late,
               "nmi_over_vblank": sum(1 for x in nmi_cost if x > VBLANK),
               "new_row_iterations": sum(out["newrow_extra"]),
               "split_frames": split_frames,
               "handlers": {f"${t:02X}": {**stat(v), "total": sum(v)} for t, v in sorted(handlers.items())
                            if v}}
        # iterations that overran
        res["overrun_iterations"] = sum(1 for x in out["iter"] if x > FRAME * 1.05)
        results[path.name] = res
        print(f"\n=== {path.name}")
        print("  state:", {k: info[k] for k in ("corridor", "boss_phase", "speed", "objects", "sprites",
                                                "player_type")}, info["types"])
        if crashed:
            print("  STOPPED:", crashed)
        print(f"  {frames_run} frames, {res['iterations']} loop iterations, "
              f"{res['overrun_iterations']} of them took more than a frame, {late} frames were late (the NMI "
              f"arrived while the logic was still running), "
              f"{res['new_row_iterations']} built a row; the main thread did the split in "
              f"{split_frames} of {frames_run} frames")
        print(f"  NMI: {res['nmi']}; longer than vblank ({VBLANK}) in {res['nmi_over_vblank']} of {len(nmi_cost)} frames")
        for k in NAMES + ["wait", "iter", "stall", "stage_row", "stage_idle", "obj_overhead", "logic"]:
            print(f"  {k:8s} {res['phases'][k]}")
        top = sorted(res["handlers"].items(), key=lambda kv: -kv[1]["total"])[:8]
        print("  handlers by total cycles:", [(t, v["median"], v["max"], v["n"]) for t, v in top])
    if args.json:
        args.json.write_text(json.dumps(results, indent=1), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
