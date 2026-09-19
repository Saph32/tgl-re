"""The sound driver: how The Guardian Legend stores music and sound effects.

Where it lives
--------------
**Bank 0 is the sound bank.** Three of its nine entry-table slots are audio, and one of
them is called every frame:

* ``$8000`` -> ``$97A0``  - init / silence everything
* ``$8006`` -> ``$97CC``  - "play sound A", the only way anything starts
* ``$8009`` -> ``$917C``  - the per-frame tick, called from the NMI handler in bank 7
  (``$DCDD``: save the bank, switch to 0, ``JSR $8009``, switch back)

The channel model
-----------------
**Seven soft channels compete for four hardware ones.** Per-channel state is a
structure of arrays in page 3: field *f* of channel *c* is at ``$0319 + 7f + c``, so the
stride is 7 and the channel index is the offset. ``$97E4`` copies NINE fields straight out
of a song header; the rest are runtime.

Fields 7 and 8 - ``$034A,X`` and ``$0351,X`` - are the stream pointer, which ``$92F7``
copies into ``$1C``/``$1D`` before reading. Field 6, ``$0343,X``, is which of the four
hardware channels the soft channel drives; ``$0306`` is the busy mask over those four, set
and cleared through the mask tables at ``$9771`` (``01 02 04 08``) and ``$9775``
(``FE FD FB F7``). That is the allocator: seven voices, four outputs, first come first
served.

Output goes through a **16-byte APU shadow at ``$0308-$0317``**, four bytes per hardware
channel, flushed at ``$9267`` by ``LDA $0308,X / STA $4000,X`` for X from $0F down to 0. A
shadow byte of ``$FF`` means "do not write this register this frame". Idle channels are
silenced with ``$30`` (pulse/noise volume 0) or ``$80`` (triangle linear counter).

The stream format
-----------------
One byte at a time, read by ``$9307`` through ``($1C),Y``:

* ``$00-$7F`` - a **note**, stored to ``$036D,X``. A duration byte may follow.
* ``$80-$94`` - a **command**; see ``COMMANDS``. ``$9315`` does ``ASL A / TAX`` and pushes
  ``$932D,X`` then ``$932C,X``, each entry being the handler address minus one.
* ``$E0-$FF`` - **repeat the previous note** with this as its duration.

The duration byte is read at ``$94CC`` and is optional: below ``$E0`` it is not a duration
at all and the previous one is reused (``$037B,X``), ``$E0`` means the literal byte after
it, and ``$E1-$FF`` indexes the duration table at ``$9941``.

**Two ranges are holes, and the code says so rather than a comment.** ``$95-$AF`` passes
the ``CMP #$B0 / BCC`` at ``$930E`` into a table with only 21 entries, so it would jump
through handler bytes. ``$B0-$DF`` reaches ``$94C2``, which re-reads the same byte as a
duration, finds it below ``$E0``, reuses the previous duration and advances the pointer by
zero - an infinite loop. Neither can be intended. ``tools/parse-sound.py`` counts what
actually occurs instead of assuming.

What checks this
----------------
The partition. Every track of every song is walked to its end command, and the tracks are
required to tile the song data with no overlap. A wrong operand length for any command
would put a later track's start in the middle of an earlier one's bytes and show up
immediately. See ``tools/parse-sound.py`` for the result.
"""

from __future__ import annotations

SONG_TABLE = 0x9B04       # bank 0; pointer per song id, read by $97E4 as LDA $9B04,X
DISPATCH = 0x932C         # bank 0; 21 entries, handler address minus one
PERIOD_TABLE = 0x9840     # bank 0; 16-bit, indexed by (note + transpose) * 2, at $9596
DURATION_TABLE = 0x9941   # bank 0; 8-bit, indexed by (duration byte - $E0), at $94E6
VOL_ENVELOPES = 0x99AB    # bank 0; 16-bit pointers, indexed by $0327,X * 2, at $95B2
PITCH_ENVELOPES = 0x995F  # bank 0; 16-bit pointers, indexed by $032E,X * 2, at $964A
CHAN_SET_MASK = 0x9771    # bank 0; 01 02 04 08
CHAN_CLR_MASK = 0x9775    # bank 0; FE FD FB F7

FIELD_BASE = 0x0319       # per-channel state; field f of channel c at FIELD_BASE + 7f + c
FIELD_STRIDE = 7
CHANNELS = 7
HW_CHANNELS = 4
APU_SHADOW = 0x0308       # 16 bytes, 4 per hardware channel

# Operand bytes AFTER the command byte. The dispatcher at $9315 always pre-reads one, so a
# handler's count is 1 + the number of INYs it executes before its RTS. $82 and $84 do not
# return - they pop the pushed return address and jump to the next channel - so they end a
# track and take no operand.
COMMANDS: dict[int, tuple[str, int, str]] = {
    0x80: ("jump", 2, "$9356: the two operand bytes become $1C/$1D and Y is reset, so the "
                      "stream continues at that address. This is how a track loops."),
    0x81: ("loop", 3, "$9361: operand 0 plus the channel index selects a counter field, "
                      "which is decremented; if it is still non-zero the other two operands "
                      "are jumped to as in $80, otherwise the stream falls through."),
    0x82: ("end", 0, "$9376: zeroes $0319,X so the channel goes idle, pops the pushed "
                     "return address and jumps to $9239, the next channel. Ends a track."),
    0x83: ("pitch envelope", 1, "$9382: sets $032E,X, the index into the pointer table at "
                                "$995F."),
    0x84: ("end (2)", 0, "$9370: like $82 but writes two fields first, then pops and jumps "
                         "to $9239. Also ends a track."),
    0x85: ("instrument", 1, "$9386: sets $0327,X, the index into the volume-envelope "
                            "pointer table at $99AB."),
    0x86: ("transpose", 1, "$9397: adds to $0335,X, which $9596 adds to the note before "
                           "indexing the period table."),
    0x87: ("volume adjust", 1, "$93B1: a signed adjustment clamped into $0320,X's low "
                               "nibble."),
    0x88: ("set field", 2, "$93A1: operand 0 plus the channel index selects a field, "
                           "operand 1 is stored into it."),
    0x89: ("detune", 1, "$9457: a signed value folded into $03EB,X."),
    0x8A: ("field $0327", 1, "$93AD: stores straight into $0327,X."),
    0x8B: ("transpose via pointer", 2, "$9414: the two operands build a pointer in $1E/$1F, "
                                    "biased by a per-channel counter at $0389,X, and the "
                                    "byte read through it is added to $0335,X - a transpose "
                                    "taken from a table rather than an immediate."),
    0x8C: ("vibrato", 2, "$93E1: sets $03CF,X and $03C1,X and flags bit $20 of $0358,X."),
    0x8D: ("sweep", 1, "$9477: sets $03D6,X and flags bits $80/$40 of $0358,X."),
    0x8E: ("conditional jump", 2, "$9406: if bit 1 of $0358,X is clear it falls into $9356 "
                                 "and jumps to the two operands; if set it skips them. Both "
                                 "paths consume two operands, which is why counting INYs to "
                                 "the first RTS gets this one wrong."),
    0x8F: ("portamento", 1, "$9439: sets $0397,X and $039E,X and flags bit 0 of $0358,X."),
    0x90: ("duty / flags", 2, "$949E: sets $03F2,X and $03F9,X and flags bit 3 of $0358,X."),
    0x91: ("field $03xx", 1, "$94BE: a single store."),
    0x92: ("volume", 1, "$938A: replaces the low nibble of $0320,X."),
    0x93: ("play sound", 1, "$97CC: the driver's own 'play sound A' entry, called from "
                            "inside a stream - one track starting another sound."),
    0x94: ("set global flag", 1, "$93DA: ORs the operand into $0300."),
}

# A track ends at $82/$84, which stop the channel - or at $80, which is an UNCONDITIONAL
# jump, so nothing after it is reachable by walking forward. Looping music never reaches
# an $82 at all: it ends on a jump back to its loop point. $81 and $8E also jump but are
# conditional and fall through, so they are not terminators.
END_COMMANDS = (0x82, 0x84)
TERMINATORS = (0x80, 0x82, 0x84)


def song_pointers(bank0: bytes, count: int) -> list[int]:
    o = SONG_TABLE - 0x8000
    return [bank0[o + 2 * i] | (bank0[o + 2 * i + 1] << 8) for i in range(count)]


def parse_header(bank0: bytes, addr: int) -> dict:
    """A song header: a count byte, then [channel][9 field bytes] records until a zero.

    ``$97E4`` reads it. A header whose first byte is zero is not a header at all - the
    routine pushes the pointer and RTSes to it, so the "song" is code.
    """
    o = addr - 0x8000
    if bank0[o] == 0:
        return {"addr": addr, "kind": "code", "target": addr + 1, "size": 0, "tracks": []}
    # $9854 is DEC $0305 / BNE $9804: the record loop is driven by the count byte, not by a
    # terminator. A record whose second byte is zero takes the $9850 arm, which only clears
    # the channel and consumes two bytes instead of ten.
    i = o + 1
    tracks = []
    for _ in range(bank0[o]):
        if i + 10 > len(bank0):
            break
        chan = bank0[i]
        if bank0[i + 1] == 0:
            tracks.append({"channel": chan, "fields": [], "stream": None, "hw": None})
            i += 2
            continue
        fields = list(bank0[i + 1:i + 10])
        tracks.append({"channel": chan, "fields": fields,
                       "stream": fields[7] | (fields[8] << 8),
                       "hw": fields[6]})
        i += 10
    return {"addr": addr, "kind": "song", "count": bank0[o], "size": i - o,
            "tracks": tracks}


def walk_track(bank0: bytes, start: int, limit: int = 0x4000) -> dict:
    """Walk one track from ``start`` to its end command, linearly.

    Linear, not following jumps: the point is the EXTENT, and a $80 jump inside a track
    points backwards into bytes already walked. Returns the byte range and a census of the
    command bytes met, which is what turns "those ranges are unused" from an assumption
    into a count.
    """
    o = start - 0x8000
    if not 0 <= o < len(bank0):
        return {"start": start, "end": start, "size": 0, "notes": 0, "census": {},
                "ok": False, "bad": None, "at": start, "off_bank": True}
    i = o
    census: dict[int, int] = {}
    notes = 0
    while i + 3 < len(bank0) and i - o < limit:
        b = bank0[i]
        if b < 0x80:                                     # note
            notes += 1
            i += 1
            if i < len(bank0) and bank0[i] >= 0xE0:      # a duration byte follows
                i += 2 if bank0[i] == 0xE0 else 1
            continue
        if b >= 0xE0:                                    # repeat note with duration
            i += 2 if b == 0xE0 else 1
            continue
        census[b] = census.get(b, 0) + 1
        if b in TERMINATORS:
            n = 1 + COMMANDS[b][1]
            return {"start": start, "end": 0x8000 + i + n, "size": i + n - o,
                    "notes": notes, "census": census, "ok": True,
                    "loops": b == 0x80}
        if b not in COMMANDS:                            # $95-$AF, or $B0-$DF
            return {"start": start, "end": 0x8000 + i, "size": i - o, "notes": notes,
                    "census": census, "ok": False, "bad": b, "at": 0x8000 + i}
        i += 1 + COMMANDS[b][1]
    return {"start": start, "end": 0x8000 + i, "size": i - o, "notes": notes,
            "census": census, "ok": False, "bad": None, "at": 0x8000 + i}


# --------------------------------------------------------------------- musical reading

CPU_HZ = 1789773.0          # NTSC 2A03
PERIODS = 0x985A            # the first entry the table's own index range reaches
PERIOD_COUNT = 108
FIRST_INDEX = 13            # note + transpose that selects PERIODS, because the read is
                            # based at $9840 and $9840 + 2*13 = $985A
NAMES = ("C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B")


def periods(bank0: bytes) -> list[int]:
    o = PERIODS - 0x8000
    return [bank0[o + 2 * i] | (bank0[o + 2 * i + 1] << 8) for i in range(PERIOD_COUNT)]


def period_hz(period: int) -> float:
    """A pulse channel's frequency for a given period register value."""
    return CPU_HZ / (16 * (period + 1))


def note_name(value: int) -> str:
    """Name for a stream note byte at transpose 0.

    Entry 0 of the period table is 54.65 Hz, which is A1, and the table runs one entry per
    semitone - the ratio between neighbours is 2^(1/12) to five places and the period halves
    exactly every twelve entries. So the naming is not a guess about what sounds right; it
    is read off the frequencies the table actually produces.
    """
    idx = value - FIRST_INDEX
    midi = 33 + idx                     # A1 is MIDI 33
    return f"{NAMES[midi % 12]}{midi // 12 - 1}"


def events(bank0: bytes, start: int):
    """Yield (addr, kind, a, b) for one track. kind is 'note', 'hold' or 'cmd'."""
    o = start - 0x8000
    if not 0 <= o < len(bank0):
        return
    while o + 3 < len(bank0):
        b = bank0[o]
        if b < 0x80:
            nxt = bank0[o + 1]
            dur = nxt if nxt >= 0xE0 else None
            n = (3 if nxt == 0xE0 else 2) if nxt >= 0xE0 else 1
            yield (0x8000 + o, "note", b, dur)
        elif b >= 0xE0:
            n = 2 if b == 0xE0 else 1
            yield (0x8000 + o, "hold", None, b)
        else:
            if b not in COMMANDS:
                return
            n = 1 + COMMANDS[b][1]
            yield (0x8000 + o, "cmd", b, bytes(bank0[o + 1:o + 1 + n - 1]))
            if b in TERMINATORS:
                return
        o += n


def durations(bank0: bytes) -> list[int]:
    o = DURATION_TABLE + 1 - 0x8000
    return list(bank0[o:o + 30])


def duration_of(bank0: bytes, byte: int | None, literal: int | None = None) -> int:
    """Frames for a duration byte, or 0 when the stream reuses the previous one."""
    if byte is None:
        return 0
    if byte == 0xE0:
        return literal or 0
    return durations(bank0)[byte - 0xE1]


def envelope(bank0: bytes, addr: int, limit: int = 64) -> list[int]:
    """One envelope: bytes up to and including the first with bit 7 set."""
    o = addr - 0x8000
    out = []
    while o < len(bank0) and len(out) < limit:
        v = bank0[o]
        out.append(v)
        if v & 0x80:
            break
        o += 1
    return out


def envelope_pointers(bank0: bytes, base: int, count: int, first: int = 1) -> list[int]:
    return [bank0[base - 0x8000 + 2 * i] | (bank0[base - 0x8000 + 2 * i + 1] << 8)
            for i in range(first, first + count)]


def roll(bank0: bytes, start: int, max_events: int = 4000):
    """A track as (time, note, length) in frames, for drawing.

    Time is the running sum of note lengths, so it is the track's own clock and not
    wall-clock: the driver divides it again per channel through $033C,X. Rests (note $00)
    advance the clock without producing a note.
    """
    dur_table = durations(bank0)
    o = start - 0x8000
    if not 0 <= o < len(bank0):
        return []
    t = 0
    cur = 1
    out = []
    while o + 3 < len(bank0) and len(out) < max_events:
        b = bank0[o]
        if b < 0x80 or b >= 0xE0:
            if b < 0x80:
                note, dur_byte, n = b, bank0[o + 1], 1
                if dur_byte >= 0xE0:
                    n = 3 if dur_byte == 0xE0 else 2
                else:
                    dur_byte = None
            else:
                note, dur_byte = None, b
                n = 2 if b == 0xE0 else 1
            if dur_byte is not None:
                cur = bank0[o + 2] if dur_byte == 0xE0 else dur_table[dur_byte - 0xE1]
            if note:
                out.append((t, note, cur))
            t += cur
            o += n
            continue
        if b not in COMMANDS:
            break
        o += 1 + COMMANDS[b][1]
        if b in TERMINATORS:
            break
    return out
