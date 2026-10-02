"""Run a corridor to its boss on the real code (``tgl.cpu``) and capture the screen.

Used for the bosses that are not mobile objects but part of the stage - corridor 0's Defense
System and corridors 7 and 17's Eyeball Growth: type ``$06`` (bank 6 ``$A889``) is only a
controller that waits for the scroll to stop and dies when no object of type ``$36``, ``$37``,
``$7E`` or ``$7F`` is left, so what the player fights is the stage's own background and the
ground objects its metatiles spawn (bank 5 ``$89FB``).

How the run is set up (see ``tgl/cpu.py`` for the model's limits): a corridor savestate is
loaded, ``$51`` is set to the corridor and ``$30`` to ``$40``, and the corridor loader
``$EC94`` is entered as a subroutine whose return address is the savestate's own PC, so the
game's main loop carries on afterwards. Every frame the ship's life (``$0590`` and ``$47``)
and the lives count ``$6B`` are topped up, and the ship's collision flags ``$0578`` are zeroed (``$D348`` skips a player-side object with flags 0, so nothing can hit it) - the ship may still be hit and, in these runs,
is destroyed, which leaves the boss screen empty of it. The capture is taken a fixed number of
frames after the controller (type ``$06``) exists, ``$70`` is at least 4 and the scroll has stopped.
"""

from __future__ import annotations

from .cpu import Machine, StopRun


def run_to_boss(rm, state: dict, corridor: int, rgb, settle: int = 60,
                max_frames: int = 60000) -> dict:
    m = Machine(rm)
    m.load_savestate(state)
    m.a, m.x, m.y = state["A"][0], state["X"][0], state["Y"][0]
    m.s, m.p = state["S"][0], state["P"][0]
    ret = state["PC"][0] | state["PC"][1] << 8
    m.push((ret - 1) >> 8)
    m.push((ret - 1) & 0xFF)
    m.ram[0x51], m.ram[0x30] = corridor, 0x40
    m.pc = 0xEC94
    if corridor == 0:
        # $F282 takes its $F290 branch for corridor 0 (and 22) and returns without switching
        # banks; $EF6C then calls $8000 expecting bank 5, as the new-game path ($EB34) has
        # live. Without it the scene (tiles, metatile sets, palette) is never loaded.
        m.bank = 5
        m.ram[0x04] = 5
    at = None
    for f in range(max_frames):
        m.ram[0x590] = 0xFF
        m.ram[0x47] = 0xFF
        m.ram[0x6B] = 9                 # lives
        m.ram[0x578] = 0                # the ship's collision flags: $D348 skips a player-side
                                        # object whose flags are 0, so enemies cannot hit it
        m.run_frame()
        if at is None and m.ram[0x70] >= 4 and not (m.ram[0xB8] | m.ram[0xB9]) and                 any(m.ram[0x500 + i] & 0x7F == 6 for i in range(1, 24)):
            at = f                          # the controller exists and the scroll has stopped
        if at is not None and f - at >= settle:
            break
    else:
        raise RuntimeError(f"corridor {corridor}: no boss phase in {max_frames} frames")
    objs = []
    for i in range(1, 24):
        t = m.ram[0x500 + i]
        if t:
            objs.append({"slot": i, "type": t & 0x7F, "x": m.ram[0x530 + i], "y": m.ram[0x518 + i],
                         "metasprite": m.ram[0x548 + i], "base": m.ram[0x6C8 + i]})
    return {"frames": f + 1, "row": m.ram[0xB0] | m.ram[0xB1] << 8, "objects": objs,
            "full": m.render(rgb), "bg": m.render(rgb, sprites=False),
            "sprites": m.render(rgb, bg=False), "machine": m}
