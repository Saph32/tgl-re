#!/usr/bin/env python3
"""Read an FCEUX savestate and put it against the ROM.

    python tools/savestate.py STATE.fcs              # what is in it
    python tools/savestate.py STATE.fcs --chr        # which live CHR bytes are in the ROM
    python tools/savestate.py STATE.fcs --font       # rebuild the font and check it
    python tools/savestate.py STATE.fcs --dump DIR   # write the raw chunks out

Playbook section 9 rates a savestate the strongest check available, because it is the
hardware's own answer rather than an argument about the bytes. On a CHR RAM cartridge it is
worth more than on any other kind: the state carries the live 8 KB of CHR, which IS the tile
data, and no amount of reading the ROM produces it.

What it settled here, and what it did not
-----------------------------------------
A title-screen state gave the font. `--font` rebuilds the 41 glyphs the record table at
bank 2 $80EC uploads, straight out of the ROM through the expander's own arithmetic, and
compares them with the live CHR: 41 of 41 exact. That is the whole of the evidence for the
font's codec and for the character encoding, and it is hardware agreeing with the ROM
rather than this project agreeing with itself.

`--chr` is the part that did NOT settle. It reports the stretches of live CHR that appear
verbatim in the ROM - 1,046 of 8,192 bytes over 13 stretches on the title screen - and the
sources march forward through bank 0 and bank 2 at a different rate from the destinations.
That is what a codec's literal runs look like. It is a LEAD. A second state from inside a
stage would say whether the raw stretches move, and that is worth more than any further
static search.

Format note: an FCEUX .fcs is a 16-byte header - "FCSX", the uncompressed size, the emulator
version, the compressed size - and then zlib. Inside, a section is a 1-byte id and a 4-byte
little-endian size, and each entry within it is a 4-byte null-padded name and a 4-byte size.
The savestate is NOT in this repository; it is the user's file and carries no ROM data.
"""

from __future__ import annotations

import argparse
import pathlib
import sys
import zlib
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl.model import load

ROOT = Path(__file__).resolve().parent.parent

# The font uploader, read off bank 2 $806C and $80C5. Held here so --font can rebuild the
# glyphs without the annotation store, which is the point: the check has to be able to
# disagree with what this project believes.
FONT_BANK = 2
FONT_RECORDS = 0x80EC
GLYPH_BYTES = 7          # source stride, from the ADC #$07 at $80AB
TILE_BYTES = 0x10        # destination stride, from the ADC #$10 at $80A0


def read_state(path: Path) -> dict:
    raw = path.read_bytes()
    if raw[:4] != b"FCSX":
        raise SystemExit(f"{path} is not an FCEUX savestate (no FCSX magic)")
    data = zlib.decompress(raw[16:])
    out: dict[str, bytes] = {}
    i = 0
    while i + 5 <= len(data):
        size = int.from_bytes(data[i + 1:i + 5], "little")
        if size <= 0 or i + 5 + size > len(data):
            break
        j, end = i + 5, i + 5 + size
        while j + 8 <= end:
            name = data[j:j + 4].rstrip(b"\0").decode("latin1", "replace")
            n = int.from_bytes(data[j + 4:j + 8], "little")
            if n < 0 or j + 8 + n > end:
                break
            out.setdefault(name, data[j + 8:j + 8 + n])
            j += 8 + n
        i = end
    return out


def chr_matches(chr_ram: bytes, rom: bytes) -> list[tuple[int, int, int]]:
    """Stretches of live CHR that appear verbatim in the ROM, as (chr, length, rom)."""
    spans, pos = [], 0
    while pos < len(chr_ram):
        window = chr_ram[pos:pos + 32]
        if window == b"\0" * 32 or rom.find(window) < 0:
            pos += 16
            continue
        src, n = rom.find(window), 32
        while pos + n < len(chr_ram) and src + n < len(rom) and rom[src + n] == chr_ram[pos + n]:
            n += 1
        back = 0
        while (pos - back - 1 >= 0 and src - back - 1 >= 16
               and rom[src - back - 1] == chr_ram[pos - back - 1]):
            back += 1
        if not spans or pos - back > spans[-1][0] + spans[-1][1]:
            spans.append((pos - back, n + back, src - back))
        pos += n
    return spans


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("state", help="an FCEUX .fcs / .fc8 savestate")
    ap.add_argument("--chr", action="store_true", help="which live CHR bytes are in the ROM")
    ap.add_argument("--font", action="store_true", help="rebuild the font and check it")
    ap.add_argument("--dump", metavar="DIR", help="write the raw chunks out")
    args = ap.parse_args()

    rm = load(ROOT)
    st = read_state(Path(args.state))
    print(f"{len(st)} entries: " + ", ".join(sorted(st)))
    for name in ("CHRR", "RAM", "NTAR", "PRAM", "SPRA", "LATC"):
        if name in st:
            print(f"  {name:<5} {len(st[name]):>6} bytes")
    if "LATC" in st:
        print(f"  mapper latch = ${st['LATC'][0]:02X}, so PRG bank "
              f"{st['LATC'][0] & 7} was live at $8000")

    if args.dump:
        out = pathlib.Path(args.dump)
        out.mkdir(parents=True, exist_ok=True)
        for k, v in st.items():
            (out / f"{k}.bin").write_bytes(v)
        print(f"wrote {len(st)} chunks to {out}")

    chr_ram = st.get("CHRR")
    if chr_ram is None:
        print("\nno CHRR chunk - this state is not from a CHR RAM cartridge")
        return 0

    if args.chr:
        spans = chr_matches(chr_ram, rm.rom)
        total = sum(n for _, n, _ in spans)
        print(f"\n{len(spans)} stretches of live CHR present verbatim in the ROM, "
              f"{total:,} of {len(chr_ram):,} bytes ({100 * total / len(chr_ram):.1f}%):")
        for c, n, src in spans:
            rel = src - rm.meta["prg_offset"]
            bank = rel // rm.meta["prg_bank_size"]
            addr = (0xC000 if bank == 7 else 0x8000) + rel % rm.meta["prg_bank_size"]
            print(f"  CHR ${c:04X} (table {c // 0x1000}, tile ${(c % 0x1000) // 16:02X}) "
                  f"{n:>5} B  <- bank {bank} ${addr:04X}")
        print("\nThe sources advance at a different rate from the destinations, which is what "
              "a codec's literal runs look like. That is a LEAD, not a decode.")

    if args.font:
        data = rm.prg_bank(FONT_BANK)
        k = FONT_RECORDS - 0x8000
        ok = bad = 0
        print("\nfont upload records, rebuilt from the ROM and checked against live CHR:")
        while data[k] != 0xFF:
            count = data[k]
            dest = data[k + 1] | (data[k + 2] << 8)
            src = data[k + 3] | (data[k + 4] << 8)
            good = 0
            for g in range(count):
                seven = data[src - 0x8000 + GLYPH_BYTES * g:
                             src - 0x8000 + GLYPH_BYTES * (g + 1)]
                # The expander's own arithmetic: seven rows into the low plane, row 8 and
                # the entire high plane left at zero.
                built = bytes(seven) + b"\0" * (TILE_BYTES - GLYPH_BYTES)
                live = chr_ram[dest + TILE_BYTES * g: dest + TILE_BYTES * (g + 1)]
                good += built == live
            ok += good
            bad += count - good
            print(f"  {count:>2} glyphs  ${src:04X} -> PPU ${dest:04X} (tile "
                  f"${(dest % 0x1000) // 16:02X})   {good}/{count} exact")
            k += 5
        print(f"\n{ok} of {ok + bad} glyphs match the hardware exactly."
              + ("" if bad else "  The codec and the destinations are confirmed."))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
