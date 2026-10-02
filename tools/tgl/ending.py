"""The ending picture, rebuilt from what bank 2 $8A69 does.

What the routine does, in the order it does it (all read from the code):

* ``$8A85`` loads tile block 4 of bank 1 (``$D7F9``, A = 4, Y = 1) to PPU ``$18F0``: tile
  ``$8F`` of pattern table 1 onward, 109 tiles (``$8F-$FB``).
* ``$8A88-$8ABF`` queues attribute fills (``$D5CC``: ``[count][hi][lo][value]``, ``count``
  bytes of one value; ``$D576``: an inline string) at ``$23C0-$23FF``.
* ``$8AC1-$8ADA`` blits the 10 x 13 picture ``$8B05`` to PPU ``$21F1`` (``$D99C``, width
  ``$0A``, height ``$0D``) - row 15, column 17.
* ``$8ADD-$8AE8`` copies 88 bytes (22 sprites) from ``$8B87`` to OAM ``$0200``;
  ``$8AEA-$8AF5`` copies 25 palette bytes from ``$8BDF`` to ``$0180``.

The background reads pattern table 1 because every tile the picture names (``$B0-$ED`` and
the frame ``$F2-$F9``) lies inside block 4's range ``$8F-$FB`` - which is an inference from
that fit, not something read from ``$2000``. Sprites are 8 x 16: an odd tile number picks
table 1 and the pair ``t AND $FE`` / ``t OR 1``.

NOT checked against hardware. The rest of the screen is taken as blank (the routine's
callers clear the nametable at ``$F66E``, ``$D534``, unread), and tile ``$20``, which the
picture uses for its empty cells, is drawn blank.
"""

from __future__ import annotations

from . import gfx

TILE_BASE = 0x8F            # first tile of block 4 in pattern table 1
PIC_COL, PIC_ROW = 17, 15   # PPU $21F1


def _attr_fills(b2: bytes) -> dict[int, int]:
    """The attribute bytes the $8A88 items write, in order (later writes win)."""
    a, out = 0x8A88, {}
    while b2[a - 0x8000] == 0x20:
        tgt = b2[a + 1 - 0x8000] | b2[a + 2 - 0x8000] << 8
        a += 3
        if tgt == 0xC06C:           # $D5CC: [count][hi][lo][value]
            n, hi, lo, v = b2[a - 0x8000:a + 4 - 0x8000]
            for k in range(n & 0x7F):
                out[(hi << 8 | lo) + k] = v
            a += 4
        elif tgt == 0xC06F:         # $D576: [count][hi][lo][count x data]
            n = b2[a - 0x8000]
            hi, lo = b2[a + 1 - 0x8000], b2[a + 2 - 0x8000]
            for k in range(n & 0x7F):
                out[(hi << 8 | lo) + k] = b2[a + 3 + k - 0x8000]
            a += 3 + (n & 0x7F)
        else:
            break
    return out


def build(rm, rgb):
    """-> (background RGB image 256 x 240, with sprites, dict of facts used)."""
    from PIL import Image
    b1, b2 = rm.prg_bank(1), rm.prg_bank(2)
    p = 0x8010 + 2 * 4 - 0x8000
    ptr = b1[p] | b1[p + 1] << 8
    chrdata = gfx.decode(b1, ptr - 0x8000)[0]
    ntiles = len(chrdata) // 16

    def tile(n):                                  # pattern table 1 tile n -> 16 bytes or None
        i = n - TILE_BASE
        return chrdata[16 * i:16 * i + 16] if 0 <= i < ntiles else None

    pic = b2[0x8B05 - 0x8000:0x8B05 - 0x8000 + 130]
    oam = b2[0x8B87 - 0x8000:0x8B87 - 0x8000 + 88]
    pal = b2[0x8BDF - 0x8000:0x8BDF - 0x8000 + 25]
    attrs = _attr_fills(b2)

    def colours(slot):                             # slot 0-3 background, 4-7 sprite
        return [rgb[pal[0] & 0x3F]] + [rgb[pal[1 + 3 * slot + k] & 0x3F] for k in range(3)]

    img = Image.new("RGB", (256, 240), rgb[pal[0] & 0x3F])
    px = img.load()

    def draw(data, x0, y0, cols, flip_h=False, flip_v=False, rows=8, base=0):
        for y in range(8):
            for x in range(8):
                lo, hi = data[base + y], data[base + 8 + y]
                v = ((lo >> (7 - x)) & 1) | (((hi >> (7 - x)) & 1) << 1)
                if not v:
                    continue
                X = x0 + (7 - x if flip_h else x)
                Y = y0 + (7 - y if flip_v else y) if rows == 8 else None
                if Y is not None and 0 <= X < 256 and 0 <= Y < 240:
                    px[X, Y] = cols[v]

    missing = set()
    for r in range(13):
        for c in range(10):
            n = pic[r * 10 + c]
            col, row = PIC_COL + c, PIC_ROW + r
            a = attrs.get(0x23C0 + (row // 4) * 8 + col // 4, 0)
            slot = (a >> (((row % 4) // 2) * 4 + ((col % 4) // 2) * 2)) & 3
            t = tile(n)
            if t is None:
                if n != 0x20:
                    missing.add(n)
                continue
            draw(t, col * 8, row * 8, colours(slot))
    bg = img.copy()
    px = img.load()
    for i in range(22):
        y, t, a, x = oam[4 * i:4 * i + 4]
        if y >= 0xEF:
            continue
        cols = colours(4 + (a & 3))
        fh, fv = bool(a & 0x40), bool(a & 0x80)
        top, bot = tile(t & 0xFE), tile(t | 1)       # odd tile -> table 1
        parts = [(top, 0), (bot, 8)]
        if fv:
            parts = [(bot, 0), (top, 8)]
        for data, dy in parts:
            if data is None:
                missing.add(t)
                continue
            draw(data, x, y + 1 + dy, cols, fh, fv)
    return bg, img, {"tiles": ntiles, "missing": sorted(missing), "attrs": len(attrs)}
