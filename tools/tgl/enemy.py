"""Enemies: the per-type tables, the spawn scripts and the graphics-load streams.

Objects
-------
24 slots, fields at ``$0500 + $18 * field + slot``. Slots 0-4 are the player's side (the
collision loop ``$D348`` walks only those against everything else); ``$EA8C`` allocates
enemies from 5-23. ``$0500`` is the type, bit 7 set once ``$CFA0`` has initialised it from
the per-type tables below, and bank 6 dispatches behaviour on it.

Per-type tables (bank 7), indexed by ``type AND $7F``
-----------------------------------------------------
Read by ``$CFA0`` into the slot, one ``LDA table,Y`` each, six bytes apart:

* ``$D02C`` -> ``$0578`` collision flags. ``$D348`` skips an object whose bit 7 is set and
  ANDs the rest with the collision class the caller asks for (``$30``, ``$20``).
* ``$D0AB`` -> ``$0590`` **hit points**.
* ``$D12A`` -> ``$05A8`` **attack**: ``$D30E`` subtracts each side's attack from the other's
  hit points, clamping at 0.
* ``$D1A9`` -> ``$0620``, **drawing flags**: ``$CBE8`` calls ``$CC88`` for bit 0 and
  ``$CCEB`` for bit 1, and bits 2 and 3 alter the attribute - what each step does is not
  yet read.

``$D02C``, ``$D0AB`` and ``$D12A`` are 127 bytes each - bounded by the next base - so type
``$7F`` reads the next table's first byte. ``$D1A9`` is 128, ending at code ``$D229``.

* ``$D441`` - **what an object becomes at 0 HP**: ``$D32A`` stores ``$D441,type`` into
  ``$0500``. Mostly ``$08`` or ``$07``, explosion types. 128 bytes, ending at code ``$D4C1``.
* ``$CFC4`` - **the tile block an enemy's art is in**, for types ``$0E`` and up (``$CF4C``:
  ``CMP #$0E / BCC`` returns 0 below). ``$CF5F`` looks it up in the loaded list ``$0480``
  and makes the object wait until it is there; ``$0490`` gives the tile it was loaded at.
  Negative means "per object", from ``$07B8,X``. 104 bytes, ``$0E-$75``, ending at ``$D02C``.
* ``$C174`` / ``$C201`` - hitbox half-width and half-height, indexed by **metasprite id**
  (``$0548``), not type: ``$D229`` sets ``$06E0``-``$0728`` to position +/- these.

Spawn scripts (bank 5 ``$A525``, pointers ``$A4C7``)
-----------------------------------------------------
Run by bank 7 ``$F78F`` each frame through ``$66``/``$67``. A byte below 3 is a command
(the inline table at ``$F7C9``): **0** n = wait, **1** lo hi = jump, **2** = end. Otherwise it
spawns: bit 7 clear = one object of that type; bit 7 set = a **formation**, two more bytes,
creating a type-``$29`` spawner (bank 6 ``$9A19``) that makes ``count`` objects of type
``byte AND $7F``, one every ``interval`` frames. After a spawn, a byte with bit 7 set is
another spawn; otherwise it is the wait before the next command, in units of 60 frames
(``$69``) - or, in the scrolling areas, of events.

Graphics-load streams
---------------------
``[flags | slot][block][tile]``, bit 7 of the first byte ends the stream. ``$E99F`` evicts
whatever was in ``slot`` (objects using it become type ``$28``), decodes ``block`` through
``$D7F9`` to CHR ``tile * 16`` - below ``$40`` from bank 3, else bank 2 block ``id - $30`` -
and records the block in ``$0480,slot`` and the tile in ``$0490,slot``.
"""

from __future__ import annotations

# (bank-7 address, entries, destination field, meaning)
TYPE_TABLES = [
    (0xD02C, 127, "$0578", "collision flags"),
    (0xD0AB, 127, "$0590", "hit points"),
    (0xD12A, 127, "$05A8", "attack"),
    (0xD1A9, 128, "$0620", "drawing flags"),
]
DEATH = 0xD441          # 128
GFX = 0xCFB6            # indexed by type; types $0E-$75 -> $CFC4-$D02B
GFX_FIRST, GFX_LAST = 0x0E, 0x75
HALF_W, HALF_H = 0xC174, 0xC201   # by metasprite id

SCRIPT_PTRS = 0xA4C7    # entries 1-47, read as $A4C5,Y with Y = 2 * $57
SCRIPTS = 47
SCRIPT_START, SCRIPT_END = 0xA525, 0xA663
GFX_DEFAULT = 0xA497    # the stream $A46E hands to $E99F on entering a room


def _w(b: bytes, a: int) -> int:
    return b[a - 0x8000] | b[a - 0x7FFF] << 8


def per_type(b7: bytes, ty: int) -> dict:
    t = lambda a: b7[a - 0xC000 + ty]
    return {"flags": t(0xD02C), "hp": t(0xD0AB), "attack": t(0xD12A), "p620": t(0xD1A9),
            "death": t(DEATH),
            "gfx": t(GFX) if GFX_FIRST <= ty <= GFX_LAST else None}


def script_pointers(b5: bytes) -> list[int]:
    return [_w(b5, SCRIPT_PTRS + 2 * i) for i in range(SCRIPTS)]


def walk_script(b5: bytes, p: int):
    """Events of one script, and the address after its last byte.

    A jump ends the walk (its target is not followed). Returns (events, end, how)."""
    s, ev = p, []
    B = lambda a: b5[a - 0x8000]
    while True:
        c = B(s)
        s += 1
        if c == 0:
            ev.append(("wait", B(s)))
            s += 1
            continue
        if c == 1:
            ev.append(("jump", _w(b5, s)))
            return ev, s + 2, "jump"
        if c == 2:
            ev.append(("end",))
            return ev, s, "end"
        while True:
            if c & 0x80:
                ev.append(("formation", c & 0x7F, B(s), B(s + 1)))
                s += 2
            else:
                ev.append(("spawn", c))
            d = B(s)
            s += 1
            if d & 0x80:
                c = d
                continue
            ev.append(("delay", d))
            if d == 0:
                s += 1          # $F84D: a zero wait skips one more byte
            break


def walk_gfx_stream(b5: bytes, p: int):
    """[(slot, block, tile)] and the address after the stream."""
    out, s = [], p
    while True:
        f, blk, tile = b5[s - 0x8000:s - 0x8000 + 3]
        out.append((f & 0x0F, blk, tile))
        s += 3
        if f & 0x80:
            return out, s


def block_source(block: int) -> tuple[int, int]:
    """(bank, index) of a tile block id as $EA58 routes it."""
    return (3, block) if block < 0x40 else (2, block - 0x30)
