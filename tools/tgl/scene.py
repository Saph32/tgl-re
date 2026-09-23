"""Scenes: how a labyrinth area or a corridor gets its tiles, metatiles and palettes.

The loader
----------
Bank 5 ``$ACA9`` (entry ``$8000``) loads **scene A**: three bytes at ``$AD91 + 3A``, each an
index or ``$FF`` for "skip".

1. **Tile list** - ``$AE06[i]`` points at ``[count]`` then count x ``[tile][bank][block]``;
   each block is decompressed through ``$C042``/``$D7F9`` to background CHR ``$1000 + tile *
   16``. A block byte with bit 7 set becomes ``(block AND $0F) + ($5C AND $0F)``.
2. **Metatile sets** - ``$AE24[i]`` points at ``[count]`` then count x ``[set | list << 4]
   [tile base][pointer lo][pointer hi]``, loaded by ``$AD1A`` into ``$0460``/``$0468``
   (pointer), ``$0470`` (tile base) and ``$0478`` (the ground-object list, see
   ``tgl/enemy.py``) for set ``0-7``. A set is a window of 32 metatiles, 5 bytes each; a
   room cell's byte picks set = bits 5-7 and metatile = bits 0-4 (``$83B3``), whose bytes
   are four tile numbers (``$FF`` = blank, ``$20``) and a fifth: low three bits the
   attribute slot in ``$0199``, high nibble a ground object.
3. **Nametable job** - ``$AE50[i]`` points at ``[flags][pointer]``, the pointer handed to
   ``$C05D``/``$D92D`` as a palette list (8 indices into the 36 palettes at ``$B30A``, ``$FE``
   ends, ``$FF`` skips); flag bit 1 adds 8 bytes copied to ``$0199``.

Who loads what
--------------
* **Labyrinth area n loads scene n + 5** - bank 7 ``$EEE0`` stores ``$50 + 5`` in ``$5C``,
  and ``$8711`` reloads ``$5C`` after the status screen. Before it, ``$F282`` loads scenes
  0 and ``$20``: the common set.
* **Corridor c loads scene 1, then ``$EF55[c]``** (bank 7 ``$EF6C``).
* **Special rooms** load ``$51 OR $10`` (bank 7 ``$EE6B``) - scenes 16-31.

Checked against hardware
------------------------
A labyrinth savestate (area 0, ``$5C = 5``): replaying scenes 0, 32, a special room and 5
rebuilds the background pattern table **159 of 159** tiles; the set pointers match **6 of
6**; and **all 192** cells of the room on screen are metatiles of the live sets. A corridor
savestate (corridor 15, scene 35 via ``$EF55``): **141 of 142** tiles, sets **6 of 6**.
"""

from __future__ import annotations

SCENES = 0xAD91           # 39 x 3 bytes; ends where the tile-list table begins
N_SCENES = 39
TILE_LISTS = 0xAE06       # 15 pointers
SET_RECORDS = 0xAE24      # 22 pointers, zero for unused
NT_RECORDS = 0xAE50       # 8 pointers
PALETTES = 0xB30A         # 36 x 3
N_PALETTES = 36
LAB_FIRST_SCENE = 5       # labyrinth area n -> scene n + 5
COMMON = (0, 0x20)        # $F282 loads these before the area's own
BANKS = {0: 0x8030, 1: 0x8010, 2: 0x8024, 3: 0x8020}   # $D842/$D84A


def _b(b5, a):
    return b5[a - 0x8000]


def _w(b5, a):
    return b5[a - 0x8000] | b5[a - 0x7FFF] << 8


def scene(b5, n):
    """(tile list index, set record index, nametable record index), $FF = none."""
    a = SCENES + 3 * n
    return _b(b5, a), _b(b5, a + 1), _b(b5, a + 2)


def tile_list(b5, i, scene_no=0):
    """[(tile, bank, block)] for tile list i."""
    p = _w(b5, TILE_LISTS + 2 * i)
    if not p:
        return []
    out = []
    for k in range(_b(b5, p)):
        t, bank, bl = (_b(b5, p + 1 + 3 * k + j) for j in range(3))
        if bl & 0x80:
            bl = (bl & 0x0F) + (scene_no & 0x0F)
        out.append((t, bank, bl))
    return out


def set_record(b5, i):
    """(address, [(set, list, tile base, pointer)]) for set record i."""
    p = _w(b5, SET_RECORDS + 2 * i)
    if not p:
        return 0, []
    out = []
    for k in range(_b(b5, p)):
        q = p + 1 + 4 * k
        f = _b(b5, q)
        out.append((f & 7, f >> 4, _b(b5, q + 1), _w(b5, q + 2)))
    return p, out


def nt_record(b5, i):
    """(address, flags, palette-list pointer, extra 8 bytes or None)."""
    p = _w(b5, NT_RECORDS + 2 * i)
    f = _b(b5, p)
    extra = [_b(b5, p + 3 + k) for k in range(8)] if f & 2 else None
    return p, f, _w(b5, p + 1), extra


def palette_list(bank, a):
    """Up to 8 palette indices from ``a`` in a bank image, $FE ending early."""
    out = []
    for k in range(8):
        v = bank[a - 0x8000 + k]
        if v == 0xFE:
            break
        out.append(v)
    return out


def area_scenes(area):
    """The scenes a labyrinth area is built from, in load order."""
    return list(COMMON) + [LAB_FIRST_SCENE + area]


def effective_sets(b5, scenes):
    """{set: (list, tile base, pointer)} after loading ``scenes`` in order."""
    st = {}
    for s in scenes:
        idx = scene(b5, s)[1]
        if idx != 0xFF:
            for n, lst, base, ptr in set_record(b5, idx)[1]:
                st[n] = (lst, base, ptr)
    return st


def block_tiles(rm, bank, k):
    from tgl import gfx
    d = rm.prg_bank(bank)
    p = BANKS[bank] + 2 * k - 0x8000
    return gfx.decode(d, (d[p] | d[p + 1] << 8) - 0x8000)[0]


def background_chr(rm, scenes):
    """{tile: 16 bytes} of pattern table 1 after loading ``scenes`` in order."""
    b5 = rm.prg_bank(5)
    chr_ = {}
    for s in scenes:
        idx = scene(b5, s)[0]
        if idx == 0xFF:
            continue
        for t, bank, bl in tile_list(b5, idx, s):
            data = block_tiles(rm, bank, bl)
            for i in range(len(data) // 16):
                if t + i < 0x100:
                    chr_[t + i] = bytes(data[16 * i:16 * i + 16])
    return chr_
