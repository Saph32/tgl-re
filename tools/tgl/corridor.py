"""One corridor's stage: what its event stream uses, and pictures of it.

Built on ``tgl.screen`` (the stream format and the decoded pool). For corridor ``c`` the
block is entry ``c + 2`` of bank 4's table; it is walked through its jumps, each record
tagged with the row it fires on (the trigger carried by the record before it). From that:

* **placements** - every command 6 record's structures, with slot, delay, repeats,
  sideways step and column, as ``$E7B6`` reads them;
* **row tables** - every command 1 target, the background strip;
* **palettes** - the corridor's scenes (1, then ``$EF55[c]``) set the palette slots, then
  the stream's command 4 lists and command 8 pairs override them; the pictures use the
  state after row 0's records;
* **art** - the scenes' background CHR and metatile sets (``tgl.scene``), a metatile drawn
  from its four tiles and coloured by its fifth byte's palette.

A structure's row 0 is the FIRST row its overlay slot writes. New rows enter the screen at
the top and scroll down, so on screen row 0 ends up at the BOTTOM of the structure, and
``Art.structure`` draws it that way (``ROW0_AT_BOTTOM``).
"""

from __future__ import annotations

from . import scene as sc
from . import screen

ROW0_AT_BOTTOM = True
MUSIC = 0xEF2A            # bank 7: corridor -> song
SCENE = 0xEF55            # bank 7: corridor -> scene, after scene 1
FIRST_SCENE = 1


def _b(b, a):
    return b[a - 0x8000]


def _w(b, a):
    return _b(b, a) | _b(b, a + 1) << 8


def records(bank4: bytes, c: int) -> list[dict]:
    """Every record reachable from corridor c's block, with the row it fires on."""
    start = screen.entry_pointers(bank4)[c - screen.FIRST_AREA]
    out, seen, work = [], set(), [start]
    while work:
        p = work.pop()
        if p in seen or not 0x8045 <= p < 0xC000:
            continue
        seen.add(p)
        row = _w(bank4, p)
        a = p + screen.TRIGGER_BYTES
        while a < 0xC000 - 4:
            cmd = _b(bank4, a)
            n = screen.operand_len(bank4, a, c)
            if cmd > 9 or n is None:
                break
            nxt = None if cmd == 3 else _w(bank4, a + 1 + n)
            out.append({"addr": a, "cmd": cmd, "n": n, "row": row})
            if cmd in screen.JUMPS:
                work.append(_w(bank4, a + 1))
            if cmd == 3 or nxt >= screen.TERMINAL_TRIGGER:
                break
            row = nxt
            a += 1 + n + screen.TRIGGER_BYTES
    return out


def placements(bank4: bytes, recs) -> list[dict]:
    """Each structure a command 6 record places, with its fields."""
    out = []
    for r in recs:
        if r["cmd"] != 6:
            continue
        a = r["addr"]
        k, o = _b(bank4, a + 1), a + 2
        for _ in range(k):
            f = _b(bank4, o)
            o += 1
            d = {"row": r["row"], "record": a, "slot": f & 7, "flags": f}
            if f & 0x80:
                d["delay"], d["gap"] = 0, 0
            else:
                d["delay"] = _b(bank4, o)
                o += 1
                if f & 0x20:
                    d["gap"] = d["delay"]
                else:
                    d["gap"] = _b(bank4, o)
                    o += 1
            if f & 0x40:
                d["step"] = 0
            else:
                d["step"] = _b(bank4, o)
                o += 1
            if f & 0x20:
                d["repeats"] = 1
            else:
                d["repeats"] = _b(bank4, o)
                o += 1
            d["column"] = _b(bank4, o)
            o += 1
            if f & 0x10:
                d["data"], d["w"], d["h"] = _w(bank4, o), _b(bank4, o + 2), _b(bank4, o + 3)
                d["inline"], d["structure"] = True, None
                o += 4
            else:
                t = _w(bank4, o)
                d["structure"], d["w"], d["h"], d["data"] = t, _b(bank4, t), _b(bank4, t + 1), t + 2
                d["inline"] = False
                o += 2
            out.append(d)
    return out


def cells(bank4: bytes, p: int, w: int, h: int) -> list[list[tuple[int, int]]]:
    """h rows of (column, metatile id), read with $E90F's codes."""
    rows, o = [], p
    for _ in range(h):
        row, x, left = [], 0, w
        while left:
            b = _b(bank4, o)
            if b == 0:
                x += _b(bank4, o + 1)
                o += 2
            elif b == 1:
                o += 1
                break
            else:
                row.append((x, b))
                x += 1
                o += 1
                left -= 1
        rows.append(row)
    return rows


def row_tables(bank4: bytes, recs) -> list[dict]:
    out, seen = [], set()
    for r in recs:
        if r["cmd"] == 1:
            t = _w(bank4, r["addr"] + 1)
            if t in seen:
                continue
            seen.add(t)
            rows, n = _w(bank4, t), _b(bank4, t + 2)
            out.append({"table": t, "rows": rows, "count": n, "row": r["row"],
                        "ids": [list(bank4[rows - 0x8000 + 16 * i:rows - 0x8000 + 16 * i + 16])
                                for i in range(n)]})
    return out


def scenes(bank7: bytes, c: int) -> list[int]:
    return [FIRST_SCENE, bank7[SCENE - 0xC000 + c]]


def palette_slots(b5: bytes, bank4: bytes, seq, recs, upto_row: int = 0) -> list:
    """Palette index per slot 0-7 after the scenes and the stream's records up to a row."""
    slots = [None] * 8
    for s in seq:
        i = sc.scene(b5, s)[2]
        if i == 0xFF:
            continue
        for k, v in enumerate(sc.palette_list(b5, sc.nt_record(b5, i)[2])):
            if v != 0xFF:
                slots[k] = v
    for r in sorted(recs, key=lambda r: (r["row"], r["addr"])):
        if r["row"] > upto_row:
            break
        if r["cmd"] == 4:
            for k, v in enumerate(sc.palette_list(bank4, _w(bank4, r["addr"] + 1))):
                if v != 0xFF:
                    slots[k] = v
        elif r["cmd"] == 8:
            o = r["addr"] + 1
            while _b(bank4, o) < 8:
                slots[_b(bank4, o)] = _b(bank4, o + 1)
                o += 2
    return slots


class Art:
    """A scene sequence's tiles and metatiles with given palette slots; draws with PIL."""

    def __init__(self, rm, seq, slots, rgb):
        b5 = self.b5 = rm.prg_bank(5)
        self.chr = sc.background_chr(rm, seq)
        self.sets = sc.effective_sets(b5, seq)
        self.back = rgb[0x0F]
        self.pals = [[rgb[b5[0x330A + 3 * slots[k] + j] & 0x3F] for j in range(3)]
                     if slots[k] is not None else [self.back] * 3 for k in range(4)]
        self.cache = {}

    def metatile(self, cell: int):
        from PIL import Image
        if cell in self.cache:
            return self.cache[cell]
        img = Image.new("RGB", (16, 16), self.back)
        entry = self.sets.get(cell >> 5)
        if entry:
            _, base, ptr = entry
            a = ptr + 5 * (cell & 31) - 0x8000
            t4, attr = self.b5[a:a + 4], self.b5[a + 4]
            pal = self.pals[attr & 3]
            px = img.load()
            for k, t in enumerate(t4):
                if t == 0xFF:
                    continue
                tile = self.chr.get((t + base) & 0xFF)
                if tile is None:
                    continue
                for y in range(8):
                    for x in range(8):
                        v = ((tile[y] >> (7 - x)) & 1) | (((tile[8 + y] >> (7 - x)) & 1) << 1)
                        if v:
                            px[(k % 2) * 8 + x, (k // 2) * 8 + y] = pal[v - 1]
        self.cache[cell] = img
        return img

    def structure(self, rows, hole=(40, 40, 48)):
        """A structure's cells as an image; columns it skips are left as `hole`."""
        from PIL import Image
        w = max([x + 1 for row in rows for x, _ in row] or [1])
        h = len(rows)
        img = Image.new("RGB", (16 * w, 16 * h), hole)
        for i, row in enumerate(rows):
            y = (h - 1 - i) if ROW0_AT_BOTTOM else i
            for x, cell in row:
                img.paste(self.metatile(cell), (16 * x, 16 * y))
        return img

    def strip(self, ids_rows):
        """Background rows (16 ids each), drawn the same way up as structures."""
        return self.structure([[(x, v) for x, v in enumerate(r)] for r in ids_rows])
