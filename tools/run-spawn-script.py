#!/usr/bin/env python3
"""Run a bank 5 spawn script on the NES model, one second at a time, and print what it spawns.

    python tools/run-spawn-script.py --state LABYRINTH.fcs --script 16 [--seconds 900] [--bus open|zero]

Runs the ROM's own interpreter (bank 7 ``$F78F``) from a labyrinth savestate. In the labyrinth
``$69`` counts 60 frames and a wait is in seconds, so the tool sets ``$69`` = 1 and calls the
interpreter once per second, emptying the enemy slots after each call to count spawns. Prints one line
per second in which something was spawned: the pointer ``$66/$67``, the wait left in ``$68``, and
(type, ``$0548``) of every new object. A formation shows as type ``$29``, the spawner, whose ``$0548``
is the type it will spawn.

``--bus`` says what a read of ``$6000-$7FFF`` returns. This cartridge has nothing there, so the real
answer is open bus. ``zero`` is what the harness does by default. ``open`` returns ``$67``, the pointer
high byte: for ``LDA ($66),Y`` that is the last thing the 6502 fetched before the data read, so it is
what the bus holds - an inference from the addressing sequence, **not** checked on FCEUX or a console.

The five scripts that end ``[byte] 01 02`` are 16, 24, 28, 32 and 38 (``parse-enemies.py --scripts``).
The savestate is the owner's, so this is not part of ``build.py``.
"""

from __future__ import annotations

import argparse
import importlib.util
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl.cpu import Machine
from tgl.model import load

ROOT = Path(__file__).resolve().parent.parent
RET = 0xC000
INTERPRETER = 0xF78F


def call(m, addr):
    m.push((RET - 1) >> 8)
    m.push((RET - 1) & 255)
    pc = m.pc
    m.pc = addr
    n = 0
    while m.pc != RET:
        m.step()
        n += 1
        if n > 200000:
            raise SystemExit("the interpreter did not return")
    m.pc = pc


def run(rm, st, script_addr, seconds, bus):
    m = Machine(rm)
    m.load_savestate(st)
    m.a, m.x, m.y = st["A"][0], st["X"][0], st["Y"][0]
    m.s, m.p = st["S"][0], st["P"][0]
    m.pc = st["PC"][0] | st["PC"][1] << 8
    orig = m.read
    if bus == "open":
        m.read = lambda a: m.ram[0x67] if 0x6000 <= a < 0x8000 else orig(a)
    for i in range(5, 24):
        m.ram[0x500 + i] = 0
    m.ram[0x30] &= 0xBF                              # the labyrinth: waits are in seconds
    m.ram[0x7F] = 5                                  # the scripts are in bank 5
    m.ram[0x60] = (m.ram[0x60] & ~8) | 2             # script running, spawning not suppressed
    m.ram[0x66], m.ram[0x67] = script_addr & 255, script_addr >> 8
    m.ram[0x68], m.ram[0x69] = 1, 1
    out = []
    for sec in range(seconds):
        before = [(m.ram[0x500 + i], m.ram[0x548 + i]) for i in range(5, 24)]
        m.ram[0x69] = 1
        call(m, INTERPRETER)
        after = [(m.ram[0x500 + i], m.ram[0x548 + i]) for i in range(5, 24)]
        new = [a for b, a in zip(before, after) if a != b and a[0]]
        for i in range(5, 24):
            m.ram[0x500 + i] = 0
        if new:
            out.append((sec, m.ram[0x66] | m.ram[0x67] << 8, m.ram[0x68], m.ram[0x60] & 2, new))
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--state", type=Path, required=True)
    ap.add_argument("--script", type=int, required=True, help="script id 1-47")
    ap.add_argument("--seconds", type=int, default=900)
    ap.add_argument("--bus", choices=("open", "zero"), default="open")
    args = ap.parse_args()
    spec = importlib.util.spec_from_file_location("savestate", ROOT / "tools" / "savestate.py")
    ss = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(ss)
    rm = load(ROOT)
    st = ss.read_state(args.state)
    rom = (ROOT / "Guardian Legend, The.nes").read_bytes()
    b5 = rom[16 + 5 * 0x4000:16 + 6 * 0x4000]
    base = 0xA4C7 - 0x8000 + 2 * (args.script - 1)     # entry 0 is never read; the table starts at $A4C7
    addr = b5[base] | b5[base + 1] << 8
    print(f"script {args.script} at ${addr:04X}, bus = {args.bus}")
    for sec, p, w, alive, new in run(rm, st, addr, args.seconds, args.bus):
        print(f"  second {sec:4d}  pointer ${p:04X}  wait left {w:3d}  running {bool(alive)}  new "
              + ", ".join(f"${t:02X}/${g:02X}" for t, g in new))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
