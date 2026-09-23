"""Bank 4: the per-corridor screen data, and the command stream that drives it.

**Terminology - CORRECTION.** This module says "area" for ``$51`` throughout. ``$51`` is the
**corridor** number: the vertically scrolling shooter stages, 1-21, entered from the
labyrinth ("Corridor No.2" in the game's own dialogue). The labyrinth has areas of its own,
``$50``, 0-10, which the HUD prints after "AREA" (bank 7 ``$E169``). Read "area N" below as
"corridor N". The code keeps the old variable names.

How it is reached
-----------------
Bank 4 has ONE entry point and it returns a pointer instead of running code, which is why a
control-flow trace found nineteen bytes of a sixteen-kilobyte bank. ``$EF9B`` in bank 7
switches to bank 4, ``$EF9E`` loads the corridor number from ``$51`` and ``$EFA0`` calls
``$8000``, which indexes the 25-entry table at ``$8013`` by ``(A + 2) * 2`` and hands back
the block address in ``$18``/``$19``.

The interpreter
---------------
``$E5BD`` runs it. The walking pointer is ``$BC``/``$BD`` and the shape is **not** a plain
command list - it is a list of events keyed to a scroll position:

* A block opens with a **two-byte trigger**, read by ``$E760`` into ``$B2``/``$B3`` and
  also into ``$B0``/``$B1``; the stream proper starts two bytes in.
* ``$E6CE`` compares the running position ``$B0``/``$B1`` against the pending trigger
  ``$B2``/``$B3`` every step. While they differ nothing happens. When they match, ``$E6EB``
  fetches one command byte and dispatches it through the ten-entry table at ``$E6F3``.
* A handler reads its own operands, and then **``$E89D`` reads two more bytes into
  ``$B2``/``$B3``** - the trigger for the *next* event - and jumps back to the compare.

So a record is ``[command][operands...][next trigger lo][next trigger hi]``, and every
record carries the position at which the record after it fires.

Why a linear walk is not enough
-------------------------------
Command 3 is an unconditional jump: ``$E760`` reads a two-byte pointer, takes a fresh
two-byte trigger through it and sets ``$BC`` to the target plus two. Command 9 is the same
jump made conditional on ``$70``. So the blocks form a GRAPH, and walking one linearly stops
at the first command 3 with live bytes still ahead of it. ``blocks()`` follows the jumps
instead, which is the same worklist the code tracer uses.

Operand lengths, and the one that depends on the area
-----------------------------------------------------
Read off each handler. Commands 0, 1, 3, 4, 7 and 9 take two; command 2 takes one, or three
when bit 1 of its first operand is set; command 8 is a run of ``[index][value]`` pairs ended
by a byte of ``$08`` or more; command 6 is a count followed by that many variable-length
records whose length is driven by flag bits. **Command 5 takes one operand in area 21 and
none anywhere else** - ``$E79F`` compares ``$51`` against ``#$15`` and does a bare ``DEY``
when it does not match. That is runtime state deciding a byte count, and it is only
parseable here because each block belongs to a known area.

The second pool
---------------
Command 4 and command 6 both carry pointers to data elsewhere in the bank. 149 distinct
targets turn up, and they account for the bytes the stream walk does not reach. WHAT THOSE
BLOCKS CONTAIN is not established - only that they are referenced, and where from.
"""

from __future__ import annotations

ENTRY_TABLE = 0x8013      # 25 pointers, indexed by (area + 2) * 2
ENTRY_COUNT = 25
FIRST_AREA = -2           # entry 0 is two slots below area 0
DISPATCH = 0xE6F3         # bank 7, ten handlers
TRIGGER_BYTES = 2         # the [next trigger] suffix on every record
AREA_21 = 0x15            # the area whose command 5 takes an operand

# A trigger this large never fires, so the record carrying it is a block's last.
# CORRECTION: those four values are NOT trigger data. The interpreter reads two bytes after
# the last record whatever they are, and three of the four - $1100 at $B165, $3800 at
# $B48D, $3700 at $BFC2 - are exactly the first two bytes of a bank 4 spawn script or
# graphics-load stream (tools/parse-enemies.py); the fourth, $270F at $81B2, is two bytes
# before area 0's script. They never fire because they happen to be large. The
# threshold is not a guess: across all 25 entry blocks the 476 triggers separate cleanly
# into 209 distinct values at $0791 or below and exactly four above - $1100, $270F, $3700
# and $3800 - with a gap of 2,415 between the two groups. Each of those four sits at the
# end of a block whose next byte is not a command, which is the same four places a walk
# without this rule runs off.
TERMINAL_TRIGGER = 0x0800

COMMANDS = {
    0: ("set scroll limit", "$E707: two bytes into $BA/$BB; if the second has bit 7 set it "
                            "is masked and also copied to $B8/$B9."),
    1: ("set $B4/$B5", "$E721: two bytes into $B4/$B5, and clears $A1."),
    2: ("mode bits", "$E733: operand 0's low two bits go into $60. If bit 1 is set it takes "
                     "two more bytes into $66/$67 and sets $68, $69 and $7F."),
    3: ("jump", "$E760: a two-byte pointer. Reads a fresh trigger through it and continues "
                "at target+2. Unconditional, so nothing after it is reachable linearly."),
    4: ("call $D92D", "$E78A: a two-byte pointer into $18/$19, then JSR $D92D. The target "
                      "is in the second pool."),
    5: ("set $70", "$E79F: sets $70. Takes ONE operand into $72 in area 21 and NONE "
                   "otherwise - $51 is compared with #$15 and the miss path does DEY."),
    6: ("spawn list", "$E7B6: a count, then that many records. Each opens with a flag byte "
                      "whose bits 7, 6, 5 and 4 each suppress or add operands, and ends "
                      "with either four inline bytes or a two-byte pointer into the second "
                      "pool."),
    7: ("wait then set $28/$29", "$E85E: spins while $27 is non-zero, then two bytes into "
                                 "$28/$29 and sets $27 and $7E."),
    8: ("register writes", "$E881: [index][value] pairs into $0199,X while the index is "
                           "below 8; a byte of $08 or more ends the run and is consumed."),
    9: ("conditional jump", "$E893: if $70 is non-zero it falls into command 3's body and "
                            "jumps; otherwise it skips the two bytes. Either way two "
                            "operands."),
}

JUMPS = (3, 9)


def entry_pointers(bank4: bytes) -> list[int]:
    o = ENTRY_TABLE - 0x8000
    return [bank4[o + 2 * i] | (bank4[o + 2 * i + 1] << 8) for i in range(ENTRY_COUNT)]


def _b(bank4: bytes, a: int) -> int:
    return bank4[a - 0x8000]


def operand_len(bank4: bytes, a: int, area: int) -> int | None:
    """Operand bytes after the command byte at ``a``, or None if it is not a command."""
    B = lambda x: _b(bank4, x)
    c = B(a)
    if c in (0, 1, 3, 4, 7, 9):
        return 2
    if c == 2:
        return 3 if (B(a + 1) & 2) else 1
    if c == 5:
        return 1 if area == AREA_21 else 0
    if c == 6:
        n = B(a + 1)
        if n == 0:
            return 1
        o = a + 2
        for _ in range(n):
            f = B(o)
            o += 1
            if not f & 0x80:                 # $E7D5
                o += 1
                if not f & 0x20:
                    o += 1
            if not f & 0x40:                 # $E7EF
                o += 1
            if not f & 0x20:                 # $E7FF
                o += 1
            o += 1                           # $E802, always
            o += 4 if f & 0x10 else 2        # $E80C inline, or $E82B pointer
        return o - a - 1
    if c == 8:
        o = a + 1
        while B(o) < 8 and o < 0xBFFF:
            o += 2
        return o - a
    return None


def targets(bank4: bytes, a: int, area: int) -> tuple[list[int], list[int]]:
    """(jump targets, pool pointers) for the record at ``a``."""
    B = lambda x: _b(bank4, x)
    W = lambda x: B(x) | (B(x + 1) << 8)
    c = B(a)
    if c in JUMPS:
        return [W(a + 1)], []
    # Commands 1, 2, 4 and 7 all hand a two-byte value to something that dereferences it.
    # Whether a given one really is a pointer is decided by the value: an address inside
    # this bank's data is taken as one, anything else is not.
    if c == 4:
        return [], [W(a + 1)]
    if c == 7:
        return [], [W(a + 1)]
    if c == 1:
        return [], [W(a + 1)]
    if c == 2 and B(a + 1) & 2:
        return [], [W(a + 2)]
    if c == 6:
        n = B(a + 1)
        pool, o = [], a + 2
        for _ in range(n):
            f = B(o)
            o += 1
            if not f & 0x80:
                o += 1
                if not f & 0x20:
                    o += 1
            if not f & 0x40:
                o += 1
            if not f & 0x20:
                o += 1
            o += 1
            if f & 0x10:
                o += 4
            else:
                pool.append(B(o) | (B(o + 1) << 8))
                o += 2
        return [], pool
    return [], []


def walk(bank4: bytes) -> dict:
    """Follow every block from the entry table, through the jumps, recording what is read."""
    ptrs = entry_pointers(bank4)
    work = [(p, i + FIRST_AREA) for i, p in enumerate(ptrs)]
    seen: set[tuple[int, int]] = set()
    covered = bytearray(0x4000)
    starts: set[int] = set()
    records: list[tuple[int, int, int]] = []
    pool: set[int] = set()
    stops: list[tuple[int, str]] = []

    def mark(a, n):
        for k in range(n):
            if 0 <= a - 0x8000 + k < 0x4000:
                covered[a - 0x8000 + k] = 1

    while work:
        p, area = work.pop()
        if (p, area) in seen:
            continue
        seen.add((p, area))
        if not 0x8045 <= p < 0xC000:
            stops.append((p, "block start outside the bank's data"))
            continue
        starts.add(p)
        mark(p, TRIGGER_BYTES)
        a = p + TRIGGER_BYTES
        while a < 0xC000 - 4:
            c = _b(bank4, a)
            n = operand_len(bank4, a, area)
            if c > 9 or n is None:
                stops.append((a, f"byte ${c:02X} is not a command"))
                break
            size = 1 + n + (0 if c == 3 else TRIGGER_BYTES)
            trig = (None if c == 3 else
                    _b(bank4, a + 1 + n) | (_b(bank4, a + 2 + n) << 8))
            # A block's LAST record has no trigger of its own: $E89D reads the two bytes
            # after it regardless, and they belong to whatever follows - three of the four
            # are the first bytes of a spawn script or graphics stream. So they are not
            # marked as this block's.
            last = trig is not None and trig >= TERMINAL_TRIGGER
            mark(a, size - (TRIGGER_BYTES if last else 0))
            records.append((a, c, n))
            jt, pt = targets(bank4, a, area)
            for t in jt:
                if 0x8045 <= t < 0xC000:
                    work.append((t, area))
                else:
                    stops.append((a, f"jump to ${t:04X}, outside the bank"))
            pool.update(x for x in pt if 0x8045 <= x < 0xC000)
            # Command 3 does NOT go through $E89D - $E760 jumps straight to $E6CC - so it
            # is the one record with no trailing trigger. Three bytes, not five.
            a += size - (TRIGGER_BYTES if c == 3 else 0)
            if c == 3 or (trig is not None and trig >= TERMINAL_TRIGGER):
                break
    return {"pointers": ptrs, "starts": sorted(starts), "records": records,
            "covered": covered, "pool": sorted(pool), "stops": stops}
