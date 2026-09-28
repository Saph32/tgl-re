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


# ------------------------------------------------------------------ the whole stage
# The row builder, simulated: bank 7 $E6CE (fire the records whose trigger is this row),
# then $E8AB (the strip's next row, then the eight overlay slots, $E8E5-$E969).

def simulate(bank4: bytes, c: int, rows_after: int = 16, limit: int = 4000) -> dict:
    """Every background row the stage builds, as 16 metatile ids each, plus the palette
    slot changes by row. Command 9 is taken once a command 5 has set $70 (the boss phase);
    the simulation stops `rows_after` rows after the last record fires."""
    B = lambda a: _b(bank4, a)
    W = lambda a: _w(bank4, a)
    start = screen.entry_pointers(bank4)[c - screen.FIRST_AREA]
    ptr, trig = start + 2, W(start)
    boss = False
    table = None
    a1 = 0
    col = [0x80] * 8
    delay = [0] * 8
    gap = [0] * 8
    step = [0] * 8
    reps = [0] * 8
    width = [0] * 8
    height = [0] * 8
    base = [0] * 8
    cur = [0] * 8
    left = [0] * 8
    events, out, last_fire = [], [], 0

    def fire(row):
        nonlocal ptr, trig, boss, table, a1, last_fire
        guard = 0
        while trig == row and ptr and guard < 64:
            guard += 1
            a, cmd = ptr, B(ptr)
            n = screen.operand_len(bank4, a, c)
            if cmd > 9 or n is None:
                ptr = None
                return
            last_fire = row
            if cmd in (3, 9) and (cmd == 3 or boss):
                t = W(a + 1)
                trig, ptr = W(t), t + 2
                continue
            if cmd == 1:
                table, a1 = W(a + 1), 0
            elif cmd == 5:
                boss = True
            elif cmd in (4, 8, 0):
                events.append((row, a, cmd))
            elif cmd == 6:
                for d in placements(bank4, [{"addr": a, "cmd": 6, "row": row}]):
                    x = d["slot"]
                    col[x], delay[x], gap[x] = d["column"], d["delay"], d["gap"]
                    step[x], reps[x] = d["step"], d["repeats"]
                    width[x], height[x], base[x] = d["w"], d["h"], d["data"]
                    cur[x], left[x] = base[x], height[x]
            nxt = W(a + 1 + n)
            ptr, trig = a + 1 + n + 2, nxt

    row = trig
    while row < limit:
        fire(row)
        ids = [0] * 16
        if table is not None:
            n = B(table + 2)
            if a1 >= n:
                a1 = 0
            src = W(table) + 16 * a1
            ids = [B(src + i) for i in range(16)]
            a1 += 1
        for x in range(8):
            if col[x] == 0x80:
                continue
            if delay[x]:
                delay[x] -= 1
                continue
            o, cx, k = cur[x], col[x], width[x]
            while k:
                b = B(o)
                if b == 0:
                    cx = (cx + B(o + 1)) & 0xFF
                    o += 2
                    continue
                o += 1
                if b == 1:
                    break
                if cx < 16:
                    ids[cx] = b
                cx = (cx + 1) & 0xFF
                k -= 1
            cur[x] = o
            left[x] -= 1
            if left[x]:
                continue
            if reps[x]:
                reps[x] -= 1
                if not reps[x]:
                    col[x] = 0x80
                    continue
            col[x] = (col[x] + step[x]) & 0xFF
            if 0x20 <= col[x] < 0xF0:
                col[x] = 0x80
                continue
            delay[x], cur[x], left[x] = gap[x], base[x], height[x]
        out.append(ids)
        if ptr is None or trig >= screen.TERMINAL_TRIGGER or trig < row:
            if row >= last_fire + rows_after:
                break
        row += 1
    return {"first": out and trig or 0, "start": W(start), "rows": out, "events": events,
            "last_fire": last_fire}


def stage_image(rm, c: int, rgb):
    """The whole stage, row 0 at the bottom, background only; palette changes applied at
    their rows. Returns (image, simulation)."""
    from PIL import Image
    b4, b5, b7 = rm.prg_bank(4), rm.prg_bank(5), rm.prg_bank(7)
    sim = simulate(b4, c)
    seq = scenes(b7, c)
    slots = palette_slots(b5, b4, seq, [], upto_row=-1)
    ev = sorted(sim["events"])
    arts, rows = {}, sim["rows"]
    img = Image.new("RGB", (256, 16 * len(rows)))
    e = 0
    for i, ids in enumerate(rows):
        r = sim["start"] + i
        while e < len(ev) and ev[e][0] <= r:
            _, a, cmd = ev[e]
            if cmd == 4:
                for k, v in enumerate(sc.palette_list(b4, _w(b4, a + 1))):
                    if v != 0xFF:
                        slots[k] = v
            elif cmd == 8:
                o = a + 1
                while _b(b4, o) < 8:
                    slots[_b(b4, o)] = _b(b4, o + 1)
                    o += 2
            e += 1
        key = tuple(slots[:4])
        if key not in arts:
            arts[key] = Art(rm, seq, slots, rgb)
        art = arts[key]
        y = 16 * (len(rows) - 1 - i)
        for x, v in enumerate(ids):
            img.paste(art.metatile(v), (16 * x, y))
    return img, sim


def film(img, rows_per_column: int = 120, gap: int = 8, back=(15, 15, 20)):
    """The stage cut into columns of rows_per_column rows, left to right, each read bottom
    to top - row 0 at the bottom of the first column."""
    from PIL import Image
    h = 16 * rows_per_column
    n = (img.height + h - 1) // h
    out = Image.new("RGB", (n * (256 + gap) - gap, h), back)
    for k in range(n):
        bottom = img.height - k * h
        top = max(0, bottom - h)
        piece = img.crop((0, top, 256, bottom))
        out.paste(piece, (k * (256 + gap), h - piece.height))
    return out
