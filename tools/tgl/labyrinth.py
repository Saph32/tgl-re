"""What the labyrinth's rooms hold, read from the world map and the code that uses it.

Everything here is a rule read off the code, applied to the 24 x 24 map records of
``tgl.worldmap``. The rules, with their addresses:

* **Special screens.** A record whose byte 0 has bit 7 set is not a labyrinth room. The
  move-room path sends it to ``$EC12`` (keeping the loaded area) and ``$EE1D`` picks a
  *screen type* ``$51`` from byte 2, loads scene ``$10 + $51`` and draws it through the room
  drawer's special path (``$30`` bit 5). ``$9F22`` then runs the screen's controller through
  the table at ``$9F32``. Byte 2 with bit 7 is a **corridor entrance** (low 7 bits the
  corridor): screen 8 - the sealed gate, two type-``$35`` halves - until the corridor is
  cleared (``$EFAC``, bit c-1 of ``$04A9``), then screen 5 (4 with ``$30`` bit 6), which
  also sets out the corridor's reward, ``$EF40[c]``; corridor 21's gate is screen 0 until
  areas 1-10 are all cleared. Otherwise the screen is byte 2's low nibble, and screens 2 and 6
  become 7 once flag ``$5E`` (the record's sub-id) is set.
* **Key doors** (``$82DD``). In every open exit, if this record's byte 0 OR the
  neighbour's has bit 7, a door (metatile 8) goes into the opening and ``$58-$5B`` (N W E S)
  take the NEIGHBOUR's byte 1 AND 7 - so entering a special screen needs that screen's key.
  Bank 3 ``$8FF5`` lets the player through when the key is 0 or bit k-1 of ``$04B0`` is set.
* **Item rooms** - kind ``$20`` (byte 0 bits 5-6) with byte 0 bit 7 clear. ``$A3BB``: the
  sub-id is the room's flag; ``$55`` = ``$A377[sub-id]``, an item icon. The item stands on
  the layout's metatile 6, whose fifth byte ``$10`` spawns spawn-list entry 1 - type ``$31``,
  the item object (``$AF61``) - which ``$84CB`` gives icon ``$55``. Once taken (bank 2
  ``$8669`` sets the flag) ``$A425`` turns the cell into metatile 1 before the room is drawn.
* **Miniboss rooms** - kind ``$40``. ``$A663``: while flag ``$5E`` is clear, the record at
  ``$A6A3 + $A682[sub-id]`` gives the boss type (``$72``) and its graphics stream, and
  ``$70 = 1`` starts the boss phase.
* **Loop rooms** - kind ``$60``. ``$A3DB`` adds up the last ten moves (``$04F0-$04F9``, one
  direction pushed per move, steps from ``$A41B``); if some run of the latest moves sums to
  zero - the player has walked a loop back into this room - metatiles 4 and 5 become 3.

NOT ESTABLISHED: whether a cleared corridor's reward can be taken more than once; what the
third byte of a three-ware shop entry and the value $14 there mean; screen 4's use.
"""

from __future__ import annotations

from . import worldmap as wm

SCREENS = {
    0: "corridor 21's gate, until corridors 1-10 are cleared",
    1: "record your progress (message 4)",
    2: "the round creature's shop: three wares, buy one (message 8)",
    3: "a message (the sub-id)",
    4: "a cleared corridor's entrance, without reward",
    5: "a cleared corridor's entrance, with its reward",
    6: "the round creature's shop: one ware (message 7)",
    7: "a shop after buying (message 10, \"Any luck?\")",
    8: "a sealed corridor gate",
}
DOOR_CELLS = {"N": 0x37, "W": 0x72, "E": 0x7D, "S": 0xA7}   # $82DD: $0777 $07B2 $07BD $07E7
EXIT_BITS = (("N", 0x80, -1, 0), ("W", 0x40, 0, -1), ("E", 0x20, 0, 1), ("S", 0x10, 1, 0))


def _B(b5, a):
    return b5[a - 0x8000]


def is_special(r) -> bool:
    return r["b"][0] != wm.EMPTY and bool(r["b"][0] & 0x80)


def screen(r, cleared: bool = False, flagged: bool = False, all_ten: bool = False) -> int:
    """$EE1D: the screen type of a special record, in a given game state."""
    b2 = r["b"][2]
    if b2 & 0x80:
        c = b2 & 0x7F
        if cleared:
            return 5
        if c == 0x15 and not all_ten:
            return 0
        return 8
    s = b2 & 0x0F
    if s in (2, 6) and flagged:
        return 7
    return s


def grid(recs) -> dict:
    return {(r["row"], r["col"]): r for r in recs}


def key_doors(recs) -> list[dict]:
    """Every door $82DD puts in an opening: (room, side, key needed to go through)."""
    g, out = grid(recs), []
    for (row, col), r in g.items():
        b = r["b"]
        if b[0] == wm.EMPTY or len(b) < 2:
            continue
        for side, bit, dr, dc in EXIT_BITS:
            n = g.get((row + dr, col + dc))
            if not b[1] & bit or n is None or n["b"][0] == wm.EMPTY:
                continue
            if (b[0] | n["b"][0]) & 0x80:
                out.append({"row": row, "col": col, "side": side,
                            "to": (row + dr, col + dc), "key": n["b"][1] & 7})
    return out


def item_rooms(b5, recs, build=None) -> list[dict]:
    """Kind $20 rooms that are real rooms: item $A377[sub-id], and where metatile 6 sits."""
    out = []
    for r in recs:
        b = r["b"]
        if b[0] == wm.EMPTY or b[0] & 0x80 or (b[0] & 0x60) != 0x20:
            continue
        sub = wm.fields(r)["sub"]
        cells = [i for i, v in enumerate(build(r)) if v == 6] if build else []
        out.append({"row": r["row"], "col": r["col"], "sub": sub,
                    "item": _B(b5, 0xA377 + sub), "cells": cells})
    return out


def miniboss_rooms(b5, recs) -> list[dict]:
    out = []
    for r in recs:
        b = r["b"]
        if b[0] == wm.EMPTY or b[0] & 0x80 or (b[0] & 0x60) != 0x40:
            continue
        sub = wm.fields(r)["sub"]
        rec = 0xA6A3 + _B(b5, 0xA682 + sub)
        out.append({"row": r["row"], "col": r["col"], "sub": sub, "type": _B(b5, rec),
                    "stream": _B(b5, rec + 1) | _B(b5, rec + 2) << 8})
    return out


def loop_rooms(recs) -> list[dict]:
    return [{"row": r["row"], "col": r["col"]} for r in recs
            if r["b"][0] != wm.EMPTY and not r["b"][0] & 0x80 and (r["b"][0] & 0x60) == 0x60]


def special_rooms(b5, b7, recs) -> list[dict]:
    """Every special record with its screen type as a new game meets it, and what it holds."""
    out = []
    for r in recs:
        if not is_special(r):
            continue
        b, f = r["b"], wm.fields(r)
        d = {"row": r["row"], "col": r["col"], "key": b[1] & 7, "screen": screen(r),
             "sub": f.get("sub")}
        if b[2] & 0x80:
            c = b[2] & 0x7F
            d["corridor"] = c
            d["reward"] = b7[0xEF40 - 0xC000 + c] if c <= 20 else None
        elif d["screen"] == 3:
            d["message"] = f.get("sub")
        elif d["screen"] == 2:
            k = _B(b5, 0xA377 + f["sub"])
            y = 0xA04E + 5 * k
            d["price"] = _B(b5, y) | _B(b5, y + 1) << 8
            d["wares"] = [_B(b5, y + 2 + i) for i in range(3)]
        elif d["screen"] == 6:
            k = _B(b5, 0xA377 + f["sub"])
            y = 0xA067 + 3 * k
            d["price"] = _B(b5, y) | _B(b5, y + 1) << 8
            d["wares"] = [_B(b5, y + 2)]
        out.append(d)
    return out
