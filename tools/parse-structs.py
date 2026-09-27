#!/usr/bin/env python3
"""Walk bank 5's room-drawing data into `annotations/regions/66-structs.json`.

    python tools/parse-structs.py          # rewrite the file, print the checks
    python tools/parse-structs.py --check  # report, write nothing
    python tools/parse-structs.py --dump   # every structure, door set and list
    python tools/parse-structs.py --verify S.fcs  # rebuild a savestate's room, check it

**The output file is generated. A hand edit to it is lost on the next run.**

How a room's tile buffer is built
---------------------------------
Bank 5 ``$8155`` fills **a 16-wide, 192-byte buffer at ``$0740``** (16 x 12 tiles) before
the room's layout goes on top. ``$A749`` chooses three pointers first:

* ``$18``/``$19`` - a **structure**, from ``$A7B0`` (13 entries): in the labyrinth entry
  ``2 x $50`` (the area, 0-10); when ``$30`` bit 5 or 6 is set, the entry at the byte offset
  ``$A7A7[$51]`` (``$16`` or ``$18`` - entries 11 and 12).
* ``$14``/``$15`` - a **door set**, from ``$A7CA`` (12 entries), with X = ``2 x $50`` or
  ``$16``.
* ``$16``/``$17`` - a **pointer list**, ``$A916`` (an empty list) in the labyrinth, else
  ``$A7E2[2 x $51]`` (10 entries), or ``$A938`` on the override at ``$A76C``-``$A788``.

Then:

1. **The structure** is ``[list offset][dest][w][h][w x h pattern]``. ``$8162``-``$81A2``
   copies the pattern into the buffer from ``dest`` and **tiles it**: a row repeats until
   the column wraps (``TXA / AND #$0F``) and the rows repeat until ``CPX #$C0``. So a 1 x 1
   structure is a floor.
2. ``$81A4``: if the byte at the list offset is non-zero, ``$8379`` draws **four items**
   from there. An offset landing on a ``$00`` byte means no items.
3. ``$81B0``: ``$8379`` draws the door set's first four items, then ``$81C5``-``$8226``
   draws items 5-8 **one per exit, N W E S**, each only when that exit is closed (room byte
   1 bit 7/6/5/4 clear) or the neighbour is empty (its byte 0 has bit 7) - so they are the
   walls across unused openings. ``$30`` bit 5 skips all four.
4. ``$8227``: every pointer in the list, up to a ``$0000``, names one bare item.

**An item** (``$A6EB``) is ``[dest][w][h][tiles]``, written row by row with ``$00`` as
transparent. Width bit 7 means *one tile repeated* (``BIT $13 / BMI`` skips the ``INY``);
height bit 7 means the tiles are elsewhere - two bytes of pointer follow instead. In a list
walked by ``$8379`` each item is preceded by ``[length]``, which ``$8385`` adds to Y to
reach the next.

Why the extent is not a guess
-----------------------------
Two parts are shared on purpose and are folded into their container: item ``$A8AD``'s
16 x 1 tiles are the first row of item ``$A8A7``'s 16 x 3 at ``$A8BE``, and the empty list
``$A916`` is list 3's own ``$0000`` terminator.

**Every length byte agrees with the item it heads**: ``length == 1 + 3 + tiles`` (or
``1 + 5`` for a pointer item). That is two independent claims about the same bytes, and
one misread field anywhere breaks it. With the structures, door sets and lists walked this
way, **``$A7F6``-``$ACA8`` is partitioned exactly** - every byte claimed once, none twice,
ending on traced code at ``$ACA9``.

CORRECTION. This file used to walk ``[next][dest][w][h]`` records by chaining through byte
0 while ``next == 4 + w x h``. That rule was an accident of the format: a structure's list
offset usually points just past its pattern, and a length byte heads a structure-shaped
item. It found 48 links and left eight pointer targets (``$A8A6``-``$A938``) unexplained;
they are the special-room door set and the pointer lists, which the chain reading had no
way to express. Byte 0 of a structure is not a "next" link.

Hardware
--------
``--verify`` rebuilds the room a labyrinth savestate is in - structure, its items, the door
set with the exit walls its neighbours call for, the item list, then the room layout the
way ``$8243``-``$82DC`` draws it - and compares each of the 192 cells, drawn through the
live metatile sets, with the nametable. The zakkythegoatragon labyrinth state (area 0,
room ``$8E4C``, west exit walled) gives **191 of 192**; the one miss is the cell an object
is standing on. Without the west-exit wall item it drops to 156, so the exit logic is being
tested, not just the floor.

NOT ESTABLISHED: what ``$30`` bits 5-6 and ``$51`` mean on the special path, and so which
rooms use structures 11-12, door set 11 and the pointer lists.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl.model import load

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "annotations" / "regions" / "66-structs.json"

BANK = 5
STRUCTS, N_STRUCTS = 0xA7B0, 13     # $A792/$A797, Y = 2 x $50 or $A7A7[$51]
DOORS, N_DOORS = 0xA7CA, 12         # $A79C/$A7A1, X = 2 x $50 or $16
LISTS, N_LISTS = 0xA7E2, 10         # $A762/$A767, Y = 2 x $51
LIST_EXTRA = (0xA916, 0xA938)       # $A749 default, $A782 override
SPECIAL_DOORS = 11                  # $30 bit 5 skips the four exit walls
POOL = (0xA7F6, 0xACA9)
EXITS = "NWES"


class Walker:
    def __init__(self, b: bytes):
        self.b = b
        self.parts: dict[int, dict] = {}    # addr -> {size, name, desc}
        self.bad: list[str] = []

    def byte(self, a: int) -> int:
        return self.b[a - 0x8000]

    def word(self, a: int) -> int:
        return self.byte(a) | self.byte(a + 1) << 8

    def add(self, a: int, size: int, name: str, desc: str, user: str) -> None:
        p = self.parts.get(a)
        if p:
            if p["size"] != size:
                self.bad.append(f"${a:04X} claimed as {p['size']} and {size} bytes")
            p["users"].append(user)
            return
        self.parts[a] = {"size": size, "name": name, "desc": desc, "users": [user]}

    def tiles(self, w: int, h: int) -> int:
        return 1 if w & 0x80 else (w & 0x7F) * (h & 0x7F)

    def item(self, a: int, user: str, head: int | None = None) -> int:
        """A bare item at ``a`` (or a length-headed one at ``head`` = a - 1)."""
        dest, w, h = self.byte(a), self.byte(a + 1), self.byte(a + 2)
        shape = f"{w & 0x7F} x {h & 0x7F}" + (", one tile repeated" if w & 0x80 else "")
        if h & 0x80:
            ptr = self.word(a + 3)
            body = 5
            self.add(ptr, self.tiles(w, h), f"Room item tiles ({shape})",
                     f"Tiles for an item whose height byte has bit 7 set, so $A6EB reads "
                     f"a pointer instead of inline tiles and continues here.",
                     f"${a:04X}")
            what = f"{shape} at +${dest:02X}, tiles at ${ptr:04X}"
        else:
            body = 3 + self.tiles(w, h)
            what = f"{shape} at +${dest:02X}"
        start, size = (a, body) if head is None else (head, body + 1)
        if head is not None and self.byte(head) != size:
            self.bad.append(f"${head:04X}: length byte {self.byte(head)} but the item "
                            f"is {size} bytes")
        self.add(start, size, f"Room item: {what}",
                 ("[length][dest][width][height][tiles]" if head is not None else
                  "[dest][width][height][tiles]") +
                 f", drawn by bank 5 $A6EB into the 16 x 12 buffer at $0740 from offset "
                 f"${dest:02X}; $00 tiles are transparent." +
                 (f" The length byte, {size}, agrees with the item's own size." if head
                  is not None else ""), user)
        return size

    def items(self, a: int, n: int, user: str, roles: list[str]) -> int:
        for k in range(n):
            self.item(a + 1, f"{user} {roles[k]}", head=a)
            a += self.byte(a)
        return a

    def structure(self, a: int, user: str) -> None:
        off, dest, w, h = (self.byte(a + k) for k in range(4))
        size = 4 + w * h
        marker = off == size and self.byte(a + off) == 0
        self.add(a, size + marker, f"Room structure: {w} x {h} pattern, tiled",
                 f"[list offset][dest][width][height][pattern], read by bank 5 $8155: the "
                 f"{w} x {h} pattern is copied into the 16 x 12 buffer at $0740 from offset "
                 f"${dest:02X} and repeated across each row and down the rows until the "
                 f"buffer is full." +
                 (" The list offset lands on the $00 just after the pattern, so $81A4 "
                  "draws no items; that byte is claimed here." if marker else
                  f" The list offset, {off}, names four length-headed items at "
                  f"${a + off:04X} that $81A4 hands to $8379."), user)
        if off and self.byte(a + off):
            self.items(a + off, 4, user, [f"item {k + 1}" for k in range(4)])

    def doorset(self, a: int, user: str, n: int) -> None:
        roles = [f"item {k + 1}" for k in range(4)] + \
                [f"wall across exit {e}" for e in EXITS]
        self.items(a, n, user, roles)

    def plist(self, a: int, user: str) -> None:
        p = a
        while self.word(p):
            self.item(self.word(p), f"{user} entry {(p - a) // 2}")
            p += 2
        n = (p - a) // 2
        self.add(a, p + 2 - a, f"Room item list: {n} pointer{'s' * (n != 1)}",
                 f"Little-endian pointers ended by $0000, walked by bank 5 $8227: each "
                 f"names a bare [dest][width][height][tiles] item drawn by $A6EB.", user)


    def fold(self) -> int:
        """Merge a part lying wholly inside another into it - deliberate sharing."""
        n = 0
        for a in sorted(self.parts):
            if a not in self.parts:
                continue
            p = self.parts[a]
            for b in sorted(self.parts):
                q = self.parts[b]
                if b != a and a <= b and b + q["size"] <= a + p["size"]:
                    p["desc"] += (f" It also serves as {q['name'][0].lower()}{q['name'][1:]}"
                                  f" at ${b:04X} ({', '.join(q['users'])}): the ROM shares "
                                  f"these bytes.")
                    del self.parts[b]
                    n += 1
        return n


def walk(b: bytes) -> Walker:
    wk = Walker(b)
    for k in range(N_STRUCTS):
        wk.structure(wk.word(STRUCTS + 2 * k), f"structure {k}")
    for k in range(N_DOORS):
        wk.doorset(wk.word(DOORS + 2 * k), f"door set {k}",
                   4 if k == SPECIAL_DOORS else 8)
    for k in range(N_LISTS):
        wk.plist(wk.word(LISTS + 2 * k), f"list {k}")
    for a in LIST_EXTRA:
        wk.plist(a, f"list ${a:04X}")
    return wk


def build_room(b5: bytes, ram: bytes) -> list[int]:
    """The 16 x 12 buffer as $A749, $8155 and $8243 build it, from a savestate's RAM."""
    B = lambda a: b5[a - 0x8000]
    W = lambda a: B(a) | B(a + 1) << 8
    buf = [0] * 192

    def item(a: int) -> None:
        x, w, h = B(a), B(a + 1), B(a + 2)
        src = W(a + 3) if h & 0x80 else a + 3
        rows = h & 0x7F
        while True:
            for _ in range(w & 0x7F):
                if B(src):
                    buf[x] = B(src)
                src += 0 if w & 0x80 else 1
                x += 1
            x += 16 - (w & 0x7F)
            rows -= 1
            if x >= 0xC0 or not rows:
                return

    def items(a: int, n: int) -> int:
        for _ in range(n):
            item(a + 1)
            a += B(a)
        return a

    special = ram[0x30] & 0x60
    s_ix = B(0xA7A7 + ram[0x51]) if special else 2 * ram[0x50]
    d_ix = 0x16 if special else 2 * ram[0x50]
    s, doors = W(STRUCTS + s_ix), W(DOORS + d_ix)
    plist = W(LISTS + 2 * ram[0x51]) if special else 0xA916
    room0 = ram[0xE4] | ram[0xE5] << 8
    if special and 2 * ram[0x51] in (0x0A, 0x10):      # $A76C-$A788: corridors 11-20
        c = B(room0 + 2) & 0x7F
        if c >= 0x0B and c != 0x15:
            plist = 0xA938
    off, dest, w, h = (B(s + k) for k in range(4))
    for pos in range(dest, 192):
        buf[pos] = B(s + 4 + ((pos - dest) // 16 % h) * w + ((pos % 16) - (dest % 16)) % w)
    if off and B(s + off):
        items(s + off, 4)
    room = ram[0xE4] | ram[0xE5] << 8
    p = items(doors, 4)
    if not ram[0x30] & 0x20:
        for k, bit in enumerate((0x80, 0x40, 0x20, 0x10)):
            zp = (0xE0, 0xE2, 0xE6, 0xE8)[k]
            if B(ram[zp] | ram[zp + 1] << 8) & 0x80 or not B(room + 1) & bit:
                item(p + 1)
            p += B(p)
    while W(plist):
        item(W(plist))
        plist += 2
    if B(room) & 0x10:                                  # $8243: the room layout
        y = 3 + bool(ram[0x57]) + (ram[0x5D] not in (0, 0x60))
        lay = W(room + y)
        fill, shape, x = B(lay + 1), 0x91EA + 18 * (B(lay) & 0x1F), 0x20
        for k in range(18 * 8):
            if B(shape + k // 8) & (0x80 >> k % 8):
                buf[x + k] = fill
        q = lay + 2
        for _ in range(B(lay) >> 5):
            t, x, m = B(q), B(q + 1), B(q + 2)
            q += 3
            for bit in range(6):
                if m & 1 << bit:
                    buf[x] = t
                x = (x + (0xF1, 1, 0x10, 0x11)[m >> 6]) & 0xFF
    return buf


def verify(b5: bytes, state: Path) -> int:
    import importlib.util
    spec = importlib.util.spec_from_file_location("savestate", ROOT / "tools" / "savestate.py")
    ss = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(ss)
    st = ss.read_state(state)
    ram, nt = st["RAM"], st["NTAR"]
    buf = build_room(b5, ram)
    sets = {n: (ram[0x478 + n], ram[0x460 + n] | ram[0x468 + n] << 8) for n in range(8)}

    def tiles(cell: int) -> tuple:
        base, ptr = sets[cell >> 5]
        a = ptr + 5 * (cell & 31) - 0x8000
        return tuple((x + base) & 0xFF if x != 0xFF else 0x20 for x in b5[a:a + 4])

    ok, grid = 0, []
    for r in range(12):
        row = ""
        for c in range(16):
            got = (nt[64 * r + 2 * c], nt[64 * r + 2 * c + 1],
                   nt[64 * r + 32 + 2 * c], nt[64 * r + 33 + 2 * c])
            hit = tiles(buf[16 * r + c]) == got
            ok += hit
            row += "." if hit else "X"
        grid.append(row)
    print(f"area {ram[0x50]}, room ${ram[0xE4] | ram[0xE5] << 8:04X}: {ok} of 192 cells of "
          f"the rebuilt room match the nametable")
    print("\n".join("   " + g for g in grid))
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--dump", action="store_true")
    ap.add_argument("--verify", type=Path, metavar="STATE")
    args = ap.parse_args()

    rm = load(ROOT, exclude={OUT.name})
    if args.verify:
        return verify(rm.prg_bank(BANK), args.verify)
    wk = walk(rm.prg_bank(BANK))
    nested = wk.fold()
    ks = sorted(wk.parts)
    if args.dump:
        for a in ks:
            p = wk.parts[a]
            print(f"${a:04X} {p['size']:4d}  {p['name']:48s} {'; '.join(p['users'])}")

    overlaps = [a for a, b in zip(ks, ks[1:]) if a + wk.parts[a]["size"] > b]
    covered = set()
    for a in ks:
        covered.update(range(a, a + wk.parts[a]["size"]))
    holes = [a for a in range(*POOL) if a not in covered]
    outside = sorted(a for a in covered if not POOL[0] <= a < POOL[1])
    heads = sum(1 for a in ks if wk.parts[a]["desc"].startswith("[length]"))
    print(f"{len(ks)} parts: {heads} length-headed items, every length byte agreeing"
          if not wk.bad else f"{len(wk.bad)} DISAGREEMENTS: {wk.bad[:5]}")
    print(f"{nested} parts lie inside another and share its bytes")
    print(f"pool ${POOL[0]:04X}-${POOL[1] - 1:04X}: {len(holes)} bytes unclaimed, "
          f"{len(overlaps)} overlaps, {len(outside)} bytes outside")

    prg, bsz = rm.meta["prg_offset"], rm.meta["prg_bank_size"]
    claimed = bytearray(len(rm.rom))
    for r in rm.regions:
        claimed[r["offset"]:r["offset"] + r["size"]] = b"\1" * r["size"]
    regions, skipped = [], 0
    for a in ks:
        p = wk.parts[a]
        off = prg + BANK * bsz + (a - 0x8000)
        if any(claimed[off:off + p["size"]]):
            skipped += 1
            continue
        users = p["users"]
        regions.append({
            "id": f"bank{BANK}.struct_{a:04X}", "offset": off, "size": p["size"],
            "kind": "level", "name": p["name"], "confidence": "confirmed", "cpu_addr": a,
            "sha1": hashlib.sha1(rm.rom[off:off + p["size"]]).hexdigest(),
            "description": p["desc"] + f" Used by: {', '.join(users)}. Generated by "
                                       f"tools/parse-structs.py; see its header."})
        claimed[off:off + p["size"]] = b"\1" * p["size"]
    if skipped:
        print(f"{skipped} parts skipped because another region already claims their bytes")

    doc = {"_comment": "GENERATED by tools/parse-structs.py - do not hand-edit. Bank 5's "
                       "room structures, door sets and item lists, drawn into the 16x12 "
                       "tile buffer at $0740.",
           "regions": regions}
    text = json.dumps(doc, indent=2) + "\n"
    print(f"{len(regions)} regions, {sum(r['size'] for r in regions):,} bytes")
    if wk.bad or overlaps:
        print("REFUSING to write: the walk is inconsistent")
        return 1
    if args.check:
        print("no change" if OUT.exists() and OUT.read_text() == text else "WOULD CHANGE")
        return 0
    OUT.write_text(text)
    print(f"wrote {OUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
