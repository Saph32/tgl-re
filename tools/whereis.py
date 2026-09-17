#!/usr/bin/env python3
"""Where is this? Address to file offset to bank, plus the region or gap it lands in.

The playbook says build this on day one, and the reason is that every other number in the
project depends on getting a bank right. On this cartridge a CPU address in $8000-$BFFF
exists in **all seven** switchable PRG banks, so an address alone is not an answer - and
that mismatch is silent if you let it be, because the wrong bank still produces a
perfectly plausible disassembly.

    python tools/whereis.py FEDE              # $C000-$FFFF: always bank 7, unambiguous
    python tools/whereis.py 8000 --bank 1     # $8000-$BFFF: say which bank you mean
    python tools/whereis.py 0x1C010 --offset  # a file offset instead
    python tools/whereis.py --bytes "4C DE FE"

``--bytes`` is the one to reach for when reading any outside report about this ROM. Always
ask for the bytes at PC: a four-byte sequence is usually unique in the whole image and
settles the bank when nothing else can.

On bank numbering: this project numbers PRG banks in 16 KB units, 0 to 7, which is the
unit UxROM itself switches in and the unit FCEUX's debugger reports. So unlike the 32 KB
cartridges the playbook warns about, there is no conversion here to get wrong. The tool
says so on every report rather than leaving it to be remembered.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl.disasm import Bank
from tgl.model import AnnotationError, bank_window, load

ROOT = Path(__file__).resolve().parent.parent


def _parse_int(text: str) -> int:
    text = text.strip().lstrip("$").lstrip("#")
    return int(text, 16)


def _describe_place(rm, offset: int) -> str:
    for r in rm.regions:
        if r["offset"] <= offset < r["end"]:
            inside = offset - r["offset"]
            return (f'region {r["id"]} ({r["kind"]}, {r["confidence"]}) '
                    f'"{r["name"]}" +{inside} of {r["size"]}')
    for g in rm.gaps:
        if g["offset"] <= offset < g["end"]:
            return (f'UNCLAIMED gap 0x{g["offset"]:05X}-0x{g["end"] - 1:05X}, '
                    f'{g["size"]:,} bytes, +{offset - g["offset"]} in')
    return "outside every region and every gap - which should be impossible; check the build"


def _report_offset(rm, offset: int, listing: int) -> None:
    meta = rm.meta
    print(f"file offset   0x{offset:05X} ({offset:,})")
    if offset < meta["header_size"]:
        print("segment       iNES header")
    else:
        rel = offset - meta["prg_offset"]
        bank = rel // meta["prg_bank_size"]
        info = meta["prg_banks"][bank]
        window = bank_window(meta, bank)
        addr = window + rel % meta["prg_bank_size"]
        print(f"segment       PRG, bank {bank} ({info['role']})")
        print(f"bank offset   0x{rel % meta['prg_bank_size']:04X}")
        print(f"cpu address   ${addr:04X}", end="")
        if window == 0x8000:
            print(f" (while bank {bank} is selected)")
            print(f"              NOTE: ${addr:04X} exists in all seven switchable banks; "
                  f"only bank {bank} has these bytes at it")
        else:
            print(" (the fixed window - always these bytes)")
        print(f"FCEUX bank    {bank}  (FCEUX numbers PRG in 16 KB units, the same unit "
              "UxROM switches in and the same one this project uses, so there is no "
              "conversion to get wrong here)")
    print(f"place         {_describe_place(rm, offset)}")

    body = rm.rom[offset: offset + 16]
    print(f"bytes         {' '.join(f'{b:02X}' for b in body)}")

    if listing and offset >= meta["prg_offset"]:
        rel = offset - meta["prg_offset"]
        bank = rel // meta["prg_bank_size"]
        base = bank_window(meta, bank)
        start = meta["prg_offset"] + bank * meta["prg_bank_size"]
        win = Bank(rm.rom[start: start + meta["prg_bank_size"]], base)
        print(f"\ndisassembly from ${base + rel % meta['prg_bank_size']:04X}")
        print(win.listing(base + rel % meta["prg_bank_size"], listing))


def _find_bytes(rm, text: str) -> None:
    needle = bytes(int(t, 16) for t in text.replace(",", " ").split())
    meta = rm.meta
    hits = []
    i = rm.rom.find(needle)
    while i >= 0:
        hits.append(i)
        i = rm.rom.find(needle, i + 1)
    print(f"{' '.join(f'{b:02X}' for b in needle)}  -  {len(hits)} occurrence"
          f"{'' if len(hits) == 1 else 's'} in the file\n")
    for off in hits:
        where = "header"
        if off >= meta["prg_offset"]:
            rel = off - meta["prg_offset"]
            bank = rel // meta["prg_bank_size"]
            addr = bank_window(meta, bank) + rel % meta["prg_bank_size"]
            where = f"PRG bank {bank}  ${addr:04X}"
        print(f"  0x{off:05X}  {where:<22} {_describe_place(rm, off)}")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("address", nargs="?", help="CPU address, or file offset with --offset")
    ap.add_argument("--bank", type=int, default=None,
                    help="which PRG bank, for an address in $8000-$BFFF")
    ap.add_argument("--offset", action="store_true", help="the argument is a file offset")
    ap.add_argument("--bytes", dest="bytes_", metavar="HEX",
                    help='find which bank holds these bytes, e.g. "4C DE FE"')
    ap.add_argument("-n", "--listing", type=int, default=8,
                    help="instructions to disassemble (0 for none)")
    args = ap.parse_args()

    try:
        rm = load(ROOT)
    except AnnotationError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    if args.bytes_:
        _find_bytes(rm, args.bytes_)
        return 0

    if args.address is None:
        ap.print_help()
        return 2

    value = _parse_int(args.address)
    meta = rm.meta
    fixed = meta["prg_bank_count"] - 1

    if args.offset:
        if not 0 <= value < meta["size"]:
            print(f"error: 0x{value:X} is outside the {meta['size']:,}-byte file",
                  file=sys.stderr)
            return 1
        _report_offset(rm, value, args.listing)
        return 0

    if value < 0x8000:
        print(f"error: ${value:04X} is below $8000, so it is RAM or a register, not ROM. "
              "Pass --offset if you meant a file offset.", file=sys.stderr)
        return 1

    if value >= 0xC000:
        if args.bank is not None and args.bank != fixed:
            print(f"error: ${value:04X} is in the fixed window, which UxROM wires to the "
                  f"last bank, bank {fixed}; --bank {args.bank} cannot be right.",
                  file=sys.stderr)
            return 1
        bank, rel = fixed, value - 0xC000
    else:
        bank = args.bank
        if bank is None:
            print(f"${value:04X} is in the switchable window, so it exists in all "
                  f"{fixed} switchable banks (0-{fixed - 1}). Showing each; pass --bank to "
                  "pick one.\n")
            for n in range(fixed):
                off = meta["prg_offset"] + n * meta["prg_bank_size"] + (value - 0x8000)
                _report_offset(rm, off, args.listing)
                print()
            return 0
        rel = value - 0x8000

    if not 0 <= bank < meta["prg_bank_count"]:
        print(f"error: bank {bank} does not exist; there are {meta['prg_bank_count']}",
              file=sys.stderr)
        return 1
    _report_offset(rm, meta["prg_offset"] + bank * meta["prg_bank_size"] + rel, args.listing)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
