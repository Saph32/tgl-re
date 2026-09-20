"""Metasprites: how The Guardian Legend assembles one object out of many sprite tiles.

Where they are
--------------
A **split pointer table in bank 7**, low bytes at ``$C28D`` and high bytes at ``$C319``,
140 entries, indexed by an object's ``$0548,X``. ``$CC2F`` reads it::

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
  - ``$CC4A`` flips bit 6 of the attribute byte, draws, flips it back and draws again. Nine
  of the 118 metasprites use it, which is how a symmetrical enemy costs half the data.
* **bytes 1-2** point at a separate table of **(x, y) offset pairs**, two bytes per sprite.
  Offset tables are SHARED - 118 metasprites use only 57 of them.
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
bounds it.** Across the 118 distinct records the counts run 1 to 25 and then jump straight
to 112, 116 and 124, a gap of 87. The four records with those impossible counts are the only
ones whose bytes collide with an already-claimed region, and one of them is entry 0, which
``BEQ $CC44`` proves is never read. So 25 is the largest real metasprite and the four are
not metasprites at all.
"""

from __future__ import annotations

PTR_LO = 0xC28D
PTR_HI = 0xC319
ENTRIES = 140
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
