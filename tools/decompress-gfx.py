#!/usr/bin/env python3
"""Decode the tile blocks, and check them against a savestate's live CHR RAM.

    python tools/decompress-gfx.py                    # the inventory
    python tools/decompress-gfx.py --verify S.fcs     # against the hardware's own CHR
    python tools/decompress-gfx.py --block 1:B545     # one block, decoded and shown
    python tools/decompress-gfx.py --dump DIR         # every block as a .chr file

The codec, the evidence for it and what is NOT claimed are in ``tools/tgl/gfx.py``. Read
that header before citing any number this prints.

The one thing to keep in mind: this cartridge has CHR RAM, so no byte of the file is a tile
until code uploads it. ``--verify`` is therefore the only check here that involves the
hardware. Everything else is the ROM agreeing with itself - which is worth something,
because the blocks partition their banks end to end, but it is not the same thing.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl import gfx
from tgl.model import load

ROOT = Path(__file__).resolve().parent.parent


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--verify", metavar="STATE", help="an FCEUX savestate to check against")
    ap.add_argument("--block", metavar="BANK:ADDR", help="decode one block and show it")
    ap.add_argument("--dump", metavar="DIR", help="write every block's tiles out")
    args = ap.parse_args()

    rm = load(ROOT)

    if args.block:
        b, a = args.block.split(":")
        bank, addr = int(b), int(a, 16)
        data = rm.prg_bank(bank)
        out, used = gfx.decode(data, addr - 0x8000)
        print(f"bank {bank} ${addr:04X}  escape ${data[addr-0x8000]:02X}  "
              f"header byte 2 ${data[addr-0x8000+1]:02X}")
        print(f"{used} ROM bytes -> {len(out)} bytes = {len(out)/16:g} tiles "
              f"({len(out)/used:.2f}x)")
        for t in range(len(out) // 16):
            print(f"  tile {t:3d}: " + " ".join(f"{x:02X}" for x in out[16*t:16*t+16]))
        return 0

    total_in = total_out = 0
    all_blocks = {}
    for bank in sorted(gfx.TABLES):
        data = rm.prg_bank(bank)
        bl = gfx.blocks(data, bank)
        all_blocks[bank] = bl
        bi = sum(x["size"] for x in bl)
        bo = sum(len(x["tiles"]) for x in bl)
        total_in += bi
        total_out += bo
        print(f"bank {bank}: {len(bl):3d} blocks  ${bl[0]['addr']:04X}-"
              f"${bl[-1]['addr']+bl[-1]['size']-1:04X}  {bi:6,} B -> {bo:6,} B "
              f"= {bo//16:5,} tiles  ({sum(len(x['tiles'])%16==0 for x in bl)}/{len(bl)} whole-tile)")
    print(f"total: {total_in:,} ROM bytes -> {total_out:,} bytes of tile data "
          f"({total_out//16:,} tiles, {total_out/total_in:.2f}x)")

    if args.dump:
        out = Path(args.dump)
        out.mkdir(parents=True, exist_ok=True)
        for bank, bl in all_blocks.items():
            for x in bl:
                (out / f"b{bank}_{x['addr']:04X}.chr").write_bytes(x["tiles"])
        print(f"wrote {sum(len(v) for v in all_blocks.values())} blocks to {out}")

    if args.verify:
        sys.path.insert(0, str(Path(__file__).resolve().parent))
        import importlib.util
        spec = importlib.util.spec_from_file_location(
            "savestate", Path(__file__).resolve().parent / "savestate.py")
        ss = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(ss)
        chr_ram = ss.read_state(Path(args.verify)).get("CHRR")
        if chr_ram is None:
            print("\nthat state has no CHRR chunk")
            return 1
        live = {chr_ram[16*t:16*t+16]: t for t in range(len(chr_ram) // 16)}
        hit = set()
        print()
        for bank, bl in all_blocks.items():
            for x in bl:
                got = [live[x["tiles"][16*t:16*t+16]]
                       for t in range(len(x["tiles"]) // 16)
                       if x["tiles"][16*t:16*t+16] in live]
                hit |= set(got)
                if got:
                    n = len(x["tiles"]) // 16
                    print(f"  bank {bank} ${x['addr']:04X}: {len(got):3d} of {n:3d} tiles "
                          f"are in this state's CHR"
                          + (f", contiguous from tile ${min(got):03X}"
                             if sorted(got) == list(range(min(got), min(got)+len(got)))
                             else f", {len(set(got))} destinations"))
        blank = sum(1 for t in range(len(chr_ram) // 16)
                    if chr_ram[16*t:16*t+16] == b"\0" * 16)
        print(f"\n{len(hit)} of {len(chr_ram)//16} live tiles reproduced byte-exactly from "
              f"the ROM ({100*len(hit)/(len(chr_ram)//16):.1f}%); {blank} live tiles are blank.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
