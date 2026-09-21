"""Metasprites: how The Guardian Legend assembles one object out of many sprite tiles.

Where they are
--------------
A **split pointer table in bank 7**, low bytes at ``$C28D`` and high bytes at ``$C319``,
141 entries, indexed by an object's ``$0548,X``. ``$CC2F`` reads it::

    LDA $0548,X
    TAY
    BEQ $CC44          ; 0 means "this object draws nothing"
    LDA $C28D,Y / STA $88
    LDA $C319,Y / STA $89
    JSR $CC46          ; draw through ($88)

This is the second split table in the ROM; the first is bank 6's object dispatch at
``$80DE``/``$815D``. Neither is interleaved, and a scan for 16-bit pointer runs reads both
as nonsense.

The record
----------
``[count][offsets lo][offsets hi][tiles...][attributes...]``

* **byte 0** is the sprite count, and **bit 7 means "draw the whole thing twice, mirrored"**
  - ``$CC4A`` flips bit 6 of the attribute byte, draws, flips it back and draws again,
  which is how a symmetrical enemy costs half the data.
* **bytes 1-2** point at a separate table of **(x, y) offset pairs**, two bytes per sprite.
  Offset tables are SHARED - far fewer tables than metasprites. Run
  ``tools/parse-metasprites.py`` for the counts; none are typed here, because they drifted
  once already when the entry count was corrected from 140 to 141.
* **bytes 3 onward** are the tile numbers, one per sprite. Each is **added to the object's
  own base tile** in ``$87`` (``$CE03: ADC $87``), so a record is a shape rather than a
  fixed picture, and ``$FF`` means skip this sprite.
* **after the tiles** come the attribute bytes, and they are run-length coded: ``$CE23``
  advances the attribute index only when **bit 3 of the attribute is clear**, so a byte with
  bit 3 set covers the next sprite too. That is why the attribute array is usually shorter
  than the tile array, and why a record's length cannot be read off the count alone.

``$CDD7`` emits one hardware sprite per pass: ``$0201,X`` is the tile, ``$0202,X`` the
attribute merged with the object's own (``AND #$E3 / EOR``), ``$0203,X`` the x offset added
to ``$85``, and ``$0200,X`` the y offset added to ``$84``. Under a horizontal flip the x
offset is negated and biased by 7 and the y by 15 - the sprite's own width and height minus
one, because flipping a metasprite has to flip each tile's position as well as the tile.

What bounds the count
---------------------
Nothing in the code - ``$CC80`` is ``JSR $CDD7 / DEC $8F / BNE``, with no limit. **The data
bounds it.** Across the distinct records the counts run 1 to 25 and then jump straight to
112, 116 and 124, a gap of 87. The records with those impossible counts are the only ones
whose bytes collide with an already-claimed region, and one of them is entry 0, which
``BEQ $CC44`` proves is never read. So 25 is the largest real metasprite and those four are
not metasprites at all.
"""

from __future__ import annotations

PTR_LO = 0xC28D
PTR_HI = 0xC319
# 141, not 140. The halves OVERLAP BY ONE BYTE: $C28D + 140 is $C319, which is both
# low[140] and high[0], and high[0] is never read because id 0 is filtered by the
# BEQ $CC44 two instructions before the lookup. Exactly the trick bank 6's object dispatch
# at $80DE/$815D uses, and it was missed here first time round - id 140 resolves to $CBDC,
# a real eight-sprite metasprite, while id 141 gives $E8C4 with an offset table in RAM.
ENTRIES = 141
MAX_SPRITES = 64          # OAM holds 64; the largest real record uses 25
ATTR_HOLD = 0x08          # bit 3 of an attribute: do not advance, reuse for the next sprite
MIRROR = 0x80             # bit 7 of the count: draw twice, horizontally mirrored
SKIP_TILE = 0xFF
OAM = 0x0200


def pointers(bank7: bytes) -> list[int]:
    b = lambda a: bank7[a - 0xC000]
    return [b(PTR_LO + k) | (b(PTR_HI + k) << 8) for k in range(ENTRIES)]


def parse(bank7: bytes, addr: int) -> dict | None:
    """One metasprite, or None when the bytes are not one."""
    b = lambda a: bank7[a - 0xC000]
    if not 0xC000 <= addr < 0x10000:
        return None
    raw = b(addr)
    count = raw & 0x7F
    if count == 0 or count > MAX_SPRITES:
        return None
    offs = b(addr + 1) | (b(addr + 2) << 8)
    tiles = [b(addr + 3 + i) for i in range(count)]
    attrs, ai = [], 0
    for s in range(count):
        a = b(addr + 3 + count + ai)
        attrs.append(a)
        if not a & ATTR_HOLD and s < count - 1:
            ai += 1
    size = 3 + count + ai + 1
    pairs = [(b(offs + 2 * i), b(offs + 2 * i + 1)) for i in range(count)] \
        if 0xC000 <= offs < 0x10000 else []
    return {"addr": addr, "size": size, "count": count, "mirror": bool(raw & MIRROR),
            "offsets": offs, "offsets_size": 2 * count, "tiles": tiles, "attrs": attrs,
            "pairs": pairs, "attr_bytes": ai + 1}


def sprites(ms: dict) -> list[tuple[int, int, int, int]]:
    """(x, y, tile, attr) per sprite, with the offsets read as signed."""
    out = []
    for i in range(ms["count"]):
        if i >= len(ms["pairs"]):
            break
        x, y = ms["pairs"][i]
        out.append((x - 256 if x > 127 else x, y - 256 if y > 127 else y,
                    ms["tiles"][i], ms["attrs"][i]))
    return out


# --------------------------------------------------------- which object wears which shape

OBJ_LO = 0x80DE           # bank 6 object dispatch, low bytes
OBJ_HI = 0x815D           # ... high bytes; same one-byte overlap, same reason
OBJ_ENTRIES = 128
ID_STORE = 0x0548         # the metasprite id, per object


def handlers(bank6: bytes) -> list[int]:
    b = lambda a: bank6[a - 0x8000]
    return [((b(OBJ_LO + k) | (b(OBJ_HI + k) << 8)) + 1) & 0xFFFF
            for k in range(OBJ_ENTRIES)]


def reachable(bank6: bytes, start: int, limit: int = 4000) -> set[int]:
    """Instruction starts reachable from ``start`` inside bank 6.

    A small local walk, not the project tracer: it only needs to know which stores belong
    to which handler, and handlers share subroutines, so a store can legitimately be
    attributed to several object types.
    """
    from . import disasm
    seen, work = set(), [start]
    while work:
        a = work.pop()
        while True:
            if a in seen or not 0x8000 <= a < 0xC000 or len(seen) > limit:
                break
            seen.add(a)
            ins = disasm.decode(bank6, a - 0x8000, a)
            if ins.mnemonic == "TRUNC":
                break
            if ins.mnemonic == "JSR" and ins.operand is not None:
                if 0x8000 <= ins.operand < 0xC000:
                    work.append(ins.operand)
            elif ins.mnemonic == "JMP":
                if ins.mode == "abs" and ins.operand is not None \
                        and 0x8000 <= ins.operand < 0xC000:
                    work.append(ins.operand)
                break
            elif ins.mnemonic in ("RTS", "RTI"):
                break
            elif ins.mnemonic in disasm.BRANCHES:
                d = ins.operand - 256 if ins.operand > 127 else ins.operand
                t = a + ins.size + d
                if 0x8000 <= t < 0xC000:
                    work.append(t)
            a += ins.size
    return seen


def frame_table(bank6: bytes, addr: int, valid: set[int], limit: int = 32) -> list[int]:
    """Ids from an animation table, stopping at the first byte that is not a valid id.

    A WEAK bound and the caller should treat it as one: valid ids cover most byte values,
    so a long run may well have walked past the table's real end.
    """
    o, out = addr - 0x8000, []
    while 0 <= o < 0x4000 and bank6[o] in valid and len(out) < limit:
        out.append(bank6[o])
        o += 1
    return out


def object_map(bank6: bytes, bank7: bytes) -> list[dict]:
    """Per object type: its handler, the metasprite ids it assigns, and its frame tables."""
    valid = {i for i, p in enumerate(pointers(bank7)) if parse(bank7, p)}
    out = []
    for t in range(1, OBJ_ENTRIES):            # type 0 is filtered by BEQ before dispatch
        h = handlers(bank6)[t]
        row = {"type": t, "handler": h, "ids": set(), "tables": {}}
        if 0x8000 <= h < 0xC000:
            for a in reachable(bank6, h):
                o = a - 0x8000
                if bank6[o] in (0x9D, 0x99) and bank6[o + 1] == (ID_STORE & 0xFF) \
                        and bank6[o + 2] == (ID_STORE >> 8):
                    if o >= 2 and bank6[o - 2] == 0xA9:
                        row["ids"].add(bank6[o - 1])
                    elif o >= 3 and bank6[o - 3] in (0xB9, 0xBD):
                        tab = bank6[o - 2] | (bank6[o - 1] << 8)
                        if 0x8000 <= tab < 0xC000:
                            row["tables"][tab] = frame_table(bank6, tab, valid)
        out.append(row)
    return out
