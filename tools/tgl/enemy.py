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

The scrolling areas
-------------------
Three mechanisms, all found from bank 4's screen-data commands (``tools/tgl/screen.py``):

* **Command 2 with bit 1 set** (``$E733``) loads ``$66``/``$67`` and sets ``$7F = 4``: it
  starts a spawn script **in bank 4**, run by the same ``$F78F``. There the wait counts
  frames in which ``$A0`` bit 2 is set - ``$E98F`` sets it when a new background row is
  brought in and ``$E655`` clears it every frame - so area waves are keyed to how far the
  screen has scrolled, not to time. Areas 1-21 name exactly one script each.
* **Command 7** (``$E85E``) waits for any load in progress, then points ``$28``/``$29`` at a
  graphics-load stream in bank 4 (``$7E = 4``): the art for that area's enemies.
* **The terrain.** Each new row is 16 metatile ids copied into ``$04C0`` (``$E8AB``, from
  command 1's table at ``$B4``; command 6's channels paint over it). Bank 5 ``$83B3`` draws a
  metatile from 5 bytes - four tiles and a fifth byte it writes back into ``$04C0`` - and
  ``$89FB`` then spawns an object for every cell whose fifth byte has a high nibble: the
  type is entry (high nibble) of the list ``$803C`` names for ``$0478[low nibble]``. So
  ground enemies are placed in the scenery itself.

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


def walk_script(b5: bytes, p: int, stop: int = 0xC000):
    """Events of one script, and the address after its last byte.

    A jump ends the walk (its target is not followed); so does reaching ``stop``, which
    returns how = "overrun". Returns (events, end, how)."""
    s, ev = p, []
    B = lambda a: b5[a - 0x8000]
    while True:
        if s >= stop:
            return ev, stop, "overrun"
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
    """[(slot, block, tile)] and the address after the stream.

    Block 0 means "empty the slot, load nothing", and that record is TWO bytes: $E9F6
    backs Y up to the record start and sets $27 to it plus $82 - bit 7 for "next record",
    plus two. Such a record is returned with tile None."""
    out, s = [], p
    while True:
        f, blk = b5[s - 0x8000], b5[s - 0x7FFF]
        if blk == 0:
            out.append((f & 0x0F, 0, None))
            s += 2
        else:
            out.append((f & 0x0F, blk, b5[s - 0x7FFE]))
            s += 3
        if f & 0x80:
            return out, s


def area_spawns(bank4: bytes):
    """{area: set of script pointers}, {area: set of graphics-stream pointers}, walking every
    bank 4 block through its jumps with the area it belongs to."""
    from tgl import screen as sc
    B = lambda a: bank4[a - 0x8000]
    W = lambda a: B(a) | B(a + 1) << 8
    scripts, streams = {}, {}
    work = [(p, i + sc.FIRST_AREA) for i, p in enumerate(sc.entry_pointers(bank4))]
    seen = set()
    while work:
        p, area = work.pop()
        if (p, area) in seen or not 0x8045 <= p < 0xC000:
            continue
        seen.add((p, area))
        a = p + sc.TRIGGER_BYTES
        while a < 0xC000 - 4:
            c, n = B(a), sc.operand_len(bank4, a, area)
            if c > 9 or n is None:
                break
            if c == 2 and B(a + 1) & 2:
                scripts.setdefault(area, set()).add(W(a + 2))
            if c == 7:
                streams.setdefault(area, set()).add(W(a + 1))
            if c in sc.JUMPS:
                work.append((W(a + 1), area))
            trig = None if c == 3 else W(a + 1 + n)
            a += 1 + n + (0 if c == 3 else sc.TRIGGER_BYTES)
            if c == 3 or trig >= sc.TERMINAL_TRIGGER:
                break
    return scripts, streams


def block_source(block: int) -> tuple[int, int]:
    """(bank, index) of a tile block id as $EA58 routes it."""
    return (3, block) if block < 0x40 else (2, block - 0x30)
