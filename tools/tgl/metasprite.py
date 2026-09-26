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


def emit(ms: dict, obj_attr: int = 0) -> list[tuple[int, int, int, int]]:
    """The hardware sprites $CC46 / $CDD7 produce, as (dx, dy, tile, attr) relative to the
    object's position and base tile. ``obj_attr`` is the object's own attribute ($86).

    * a mirrored record (count bit 7) is drawn twice, first with bit 6 of $86 flipped;
    * under bit 6 of $86 the x offset becomes -x - 8 ($CE0A: EOR #$FF / SBC #$07), under
      bit 7 the y offset becomes -y - 16 ($CE39: EOR #$FF / SBC #$0F) - 8 x 16 sprites;
    * the attribute is ($86 AND $E3) EOR the record's byte ($CDEE);
    * tile $FF is skipped.
    """
    out = []

    def one(a86):
        for dx, dy, tile, attr in sprites(ms):
            if tile == SKIP_TILE:
                continue
            if a86 & 0x40:
                dx = -dx - 8
            if a86 & 0x80:
                dy = -dy - 16
            out.append((dx, dy, tile, (a86 & 0xE3) ^ attr))

    if ms["mirror"]:
        one(obj_attr ^ 0x40)
    one(obj_attr)
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


# Fixed-bank helpers that take bytes from the instruction stream (annotations/dispatch.json).
# A walk that does not know them decodes the inline bytes as instructions and runs off into
# whatever follows - CORRECTION: that is how type $40 (Fleepa) was attributed ids 25 and 42,
# which belong to the code after its handler's far call.
FAR_CALL = 0xD76F         # JSR $D76F / bank / target-1 lo / hi; $C006 is a JMP to it
PPU_STRING = {0xD576: 0, 0xD53F: -2}   # length (b0 & $7F) + 3, or 9 from $C0; $D53F 2 less
FIXED_ARG = {0xD5CC: 4}
JUMP_TABLES = {0xD6B0, 0xD6AE}
DRAW_ID = 0xCC34          # draw metasprite A with the current $84-$87; $C093 jumps here


def _resolve(bank7: bytes, a: int) -> int:
    """Follow one JMP in bank 7's entry table ($C000-...) to the routine it names."""
    o = a - 0xC000
    if 0 <= o < 0x3FFD and bank7[o] == 0x4C:
        return bank7[o + 1] | bank7[o + 2] << 8
    return a


def reachable(banks: dict, bank: int, start: int, limit: int = 6000) -> set:
    """(bank, address) instruction starts reachable from ``start``, following far calls.

    A small local walk, not the project tracer: it only needs to know which stores belong
    to which handler. It knows the inline-argument helpers and follows ``$D76F`` far calls
    into banks 0-6, because several object handlers in bank 6 are nothing but a far call
    into bank 1, 2 or 3. Handlers share subroutines, so a store can legitimately be
    attributed to several object types.
    """
    from . import disasm
    b7 = banks[7]
    seen, work = set(), [(bank, start)]
    while work:
        bk, a = work.pop()
        data = banks[bk]
        while True:
            if (bk, a) in seen or not 0x8000 <= a < 0xC000 or len(seen) > limit:
                break
            seen.add((bk, a))
            ins = disasm.decode(data, a - 0x8000, a)
            if ins.mnemonic == "TRUNC":
                break
            nxt = a + ins.size
            if ins.mnemonic == "JSR" and ins.operand is not None:
                t = _resolve(b7, ins.operand) if ins.operand >= 0xC000 else ins.operand
                o = nxt - 0x8000
                if t == FAR_CALL and o + 3 <= len(data):
                    fb, fa = data[o], (data[o + 1] | data[o + 2] << 8) + 1
                    if fb in banks and fb != 7:
                        work.append((fb, fa))
                    nxt += 3
                elif t in PPU_STRING and o < len(data):
                    b0 = data[o]
                    nxt += ((b0 & 0x7F) + 3 if b0 < 0xC0 else 9) + PPU_STRING[t]
                elif t in FIXED_ARG:
                    nxt += FIXED_ARG[t]
                elif t in JUMP_TABLES:
                    break
                elif 0x8000 <= t < 0xC000:
                    work.append((bk, t))
            elif ins.mnemonic == "JMP":
                if ins.mode == "abs" and ins.operand is not None                         and 0x8000 <= ins.operand < 0xC000:
                    work.append((bk, ins.operand))
                break
            elif ins.mnemonic in ("RTS", "RTI"):
                break
            elif ins.mnemonic in disasm.BRANCHES:
                d = ins.operand - 256 if ins.operand > 127 else ins.operand
                t = a + ins.size + d
                if 0x8000 <= t < 0xC000:
                    work.append((bk, t))
            a = nxt
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


def _read_bases(banks: dict, reach: set) -> dict:
    """Per bank, every absolute,X/Y read base in the walked code - the ends of tables."""
    out: dict[int, set] = {}
    for bk, a in reach:
        d = banks[bk]
        o = a - 0x8000
        if d[o] in (0xB9, 0xBD, 0x79, 0x7D, 0x19, 0x1D, 0x39, 0x3D, 0xD9, 0xDD):
            out.setdefault(bk, set()).add(d[o + 1] | d[o + 2] << 8)
    return out


def _table(banks: dict, bk: int, tab: int, valid: set, bases: dict,
           starts: dict | None = None) -> list[int]:
    """A frame table, cut at the next read base in the same walk (the reader-states-length
    rule), at the next claimed region's start (``starts``, per bank), and at the first
    invalid id, whichever comes first."""
    ids = frame_table(banks[bk], tab, valid)
    nxt = [x for x in bases.get(bk, ()) if x > tab]
    nxt += [x for x in (starts or {}).get(bk, ()) if x > tab]
    if nxt:
        ids = ids[:min(nxt) - tab]
    return ids


def object_map(bank6: bytes, bank7: bytes, banks: dict | None = None,
               starts: dict | None = None) -> list[dict]:
    """Per object type: its handler, the metasprite ids it assigns (``ids``, ``tables``), and
    the extra metasprites it draws on top through ``$CC34`` (``pieces``, id -> source).

    ``banks`` maps bank numbers to their bytes; without it far calls cannot be followed and
    handlers that are only a far call (types $40, $41 into bank 3, and others) resolve to
    nothing rather than to their neighbours' code."""
    banks = dict(banks or {})
    banks[6], banks[7] = bank6, bank7
    valid = {i for i, p in enumerate(pointers(bank7)) if parse(bank7, p)}
    out = []
    for t in range(1, OBJ_ENTRIES):            # type 0 is filtered by BEQ before dispatch
        h = handlers(bank6)[t]
        row = {"type": t, "handler": h, "ids": set(), "tables": {}, "pieces": {},
               "banks": set()}
        if 0x8000 <= h < 0xC000:
            reach = reachable(banks, 6, h)
            bases = _read_bases(banks, reach)
            row["banks"] = {bk for bk, _ in reach}
            for bk, a in reach:
                d, o = banks[bk], a - 0x8000
                if d[o] in (0x9D, 0x99) and d[o + 1] == (ID_STORE & 0xFF)                         and d[o + 2] == (ID_STORE >> 8):
                    if o >= 2 and d[o - 2] == 0xA9:
                        row["ids"].add(d[o - 1])
                    elif o >= 3 and d[o - 3] in (0xB9, 0xBD):
                        tab = d[o - 2] | (d[o - 1] << 8)
                        if 0x8000 <= tab < 0xC000:
                            row["tables"][tab] = _table(banks, bk, tab, valid, bases, starts)
                if d[o] == 0x20 and _resolve(bank7, d[o + 1] | d[o + 2] << 8) == DRAW_ID:
                    if o >= 2 and d[o - 2] == 0xA9:
                        row["pieces"][f"${d[o - 1]:02X}"] = [d[o - 1]]
                    else:                                            # LDA tab,Y (/PHA)
                        for k in (3, 4):
                            if o >= k and d[o - k] in (0xB9, 0xBD) and                                     (k == 3 or d[o - 1] == 0x48):
                                tab = d[o - k + 1] | d[o - k + 2] << 8
                                ids = _table(banks, bk, tab, valid, bases, starts)                                     if tab >= 0x8000 else []
                                if ids:
                                    row["pieces"][f"bank {bk} ${tab:04X}"] = ids
        out.append(row)
    return out


def region_starts(rm) -> dict:
    """Per switchable bank, the CPU address of every claimed region - table ends."""
    prg, bsz = rm.meta["prg_offset"], rm.meta["prg_bank_size"]
    out: dict[int, list] = {}
    for r in rm.regions:
        if r["offset"] >= prg:
            bk = (r["offset"] - prg) // bsz
            out.setdefault(bk, []).append(r["cpu_addr"])
    return out


def object_map_rm(rm) -> list[dict]:
    """object_map with every bank and the claimed-region boundaries - what callers want."""
    banks = {b: rm.prg_bank(b) for b in range(8)}
    return object_map(banks[6], banks[7], banks, region_starts(rm))


# ---------------------------------------------------------------- objects drawn in pieces
# Some handlers draw more than their $0548 metasprite: after the object's own draw they call
# $CC34 (via $C093) with other ids, changing $86 (attributes), $87 (base tile) and $84 (y)
# between calls. Such an object looks nothing like any one of its metasprites, which is why
# the enemies page showed Fleepa (corridor 1's boss) as two unrelated shapes.

def composite_952E(b3: bytes, s16: int, s7b8: int, s17: int, a86: int = 0):
    """Bank 3 $952E, the handler of types $40/$41 (bank 6 $9081 far-calls it): Fleepa.

    Read off $95BB-$964B:
      1. the object's own draw, metasprite $0548 = $83 (131), attributes $0560;
      2. $95CF: LDY $16 / LDA $9679,Y - drawn twice, the second time with $86 EOR $40;
      3. $95E3: LDY $07B8,X - $86 = $967B,Y, $87 += $967E,Y, then id $9681,Y;
      4. $9638: $86 = $0560 again, $84 += $18, $87 = $06C8, id $9684,Y with Y = $17.
    Returns (id, attributes, base-tile offset, dy) per part. The state indices are
    s16 in 0-1, s7b8 in 0-2, s17 in 0-1 - the extents of the tables they index."""
    B = lambda a: b3[a - 0x8000]
    piece = B(0x9679 + s16)
    return [(131, a86, 0, 0), (piece, a86, 0, 0), (piece, a86 ^ 0x40, 0, 0),
            (B(0x9681 + s7b8), B(0x967B + s7b8), B(0x967E + s7b8), 0),
            (B(0x9684 + s17), a86, 0, 24)]


COMPOSITES = {0x40: "composite_952E", 0x41: "composite_952E"}


def emit_parts(bank7: bytes, parts) -> list[tuple[int, int, int, int]]:
    """All hardware sprites of a pieced object, tiles relative to the object's base tile."""
    ptrs = pointers(bank7)
    out = []
    for i, attr, dbase, dy in parts:
        for dx, y, t, a in emit(parse(bank7, ptrs[i]), attr):
            out.append((dx, y + dy, (t + dbase) & 0xFF, a))
    return out
