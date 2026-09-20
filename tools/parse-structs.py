#!/usr/bin/env python3
"""Walk bank 5's structure records into `annotations/regions/66-structs.json`.

    python tools/parse-structs.py          # rewrite the file, print the checks
    python tools/parse-structs.py --check  # report, write nothing
    python tools/parse-structs.py --dump   # every chain, link by link

**The output file is generated. A hand edit to it is lost on the next run.**

What a structure is
-------------------
A record is ``[next][dest][width][height][tiles...]`` and the consumer is bank 5 ``$8155``:

* ``$A749`` puts the record's address in ``$18``/``$19`` - via the area-indexed offset table
  at ``$A7A7`` and the pointer table at ``$A7B0``.
* ``$815A`` takes byte 1 as the destination offset and ``$8162`` takes bytes 2 and 3 as
  width and height.
* ``$8172`` copies ``width`` tiles a row into **a 16-wide, 192-byte buffer at ``$0740``**,
  wrapping on ``TXA / AND #$0F`` and stopping on ``CPX #$C0`` - so the buffer is 16 by 12.
* ``$81A4`` then reads byte 0 as an OFFSET, looks at the byte there, and calls ``$8379``
  when it is non-zero. So byte 0 chains to the next record, and records pile onto the same
  buffer: a screen is built by blitting several structures over each other.

Where the walk stops, and why that is not a guess
-------------------------------------------------
A link is taken only when **``next == 4 + width * height``** - the record's own two claims
about its size agreeing. That is what ends a chain, and it has to be, because the obvious
alternative does not work: chaining until the next byte is zero walks
``$AC0D``'s chain straight past ``$AC99`` (12x1, sixteen bytes, ending exactly at
``$ACA8``) and into ``$ACA9``, which is traced CODE, reading it as a 10x101 record. The
self-consistency rule stops there on its own.

What that leaves
----------------
13 of the 21 distinct pointer targets start a chain; the other eight are contiguous
(``$A8A6``-``$A938``) and their first record does not satisfy the rule. They are pointed at
by table entries the area path never selects - only offsets ``$16`` and ``$18`` occur there
- so **what reads them has not been found**, and nothing here claims their bytes.
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
OFFSET_TABLE = 0xA7A7     # area -> byte offset, read at $A78E
POINTER_TABLE = 0xA7B0    # read at $A792/$A797
POINTER_ENTRIES = 35
BUFFER = 0x0740           # 16 x 12 tiles
HEADER = 4                # [next][dest][width][height]


def heads(b5: bytes) -> list[int]:
    o = POINTER_TABLE - 0x8000
    return sorted({b5[o + 2 * k] | (b5[o + 2 * k + 1] << 8)
                   for k in range(POINTER_ENTRIES)})


def chain(b5: bytes, head: int, limit: int = 80):
    """Links from ``head`` while each one's size claims agree."""
    out, a = [], head
    while len(out) < limit:
        nxt, dest, w, h = (b5[a - 0x8000 + k] for k in range(HEADER))
        if not w or not h or nxt != HEADER + w * h:
            break
        out.append({"addr": a, "size": nxt, "dest": dest, "w": w, "h": h})
        a += nxt
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--dump", action="store_true")
    args = ap.parse_args()

    rm = load(ROOT, exclude={OUT.name})
    b5 = rm.prg_bank(BANK)
    hs = heads(b5)
    links: dict[int, dict] = {}
    started = 0
    for h in hs:
        c = chain(b5, h)
        started += bool(c)
        if args.dump and c:
            print(f"chain from ${h:04X}: {len(c)} links")
            for l in c:
                print(f"   ${l['addr']:04X}  {l['size']:3d} B  dest ${l['dest']:02X}  "
                      f"{l['w']}x{l['h']}")
        for l in c:
            links[l["addr"]] = l

    ks = sorted(links)
    total = sum(links[a]["size"] for a in ks)
    ov = sum(1 for i in range(len(ks) - 1)
             if ks[i] + links[ks[i]]["size"] > ks[i + 1])
    print(f"{started} of {len(hs)} distinct pointer targets start a self-consistent chain")
    print(f"{len(links)} links, {total:,} bytes, ${ks[0]:04X}-"
          f"${ks[-1] + links[ks[-1]]['size'] - 1:04X}")
    print(f"{ov} links overlap an earlier one")

    prg, bsz = rm.meta["prg_offset"], rm.meta["prg_bank_size"]
    claimed = bytearray(len(rm.rom))
    for r in rm.regions:
        claimed[r["offset"]:r["offset"] + r["size"]] = b"\1" * r["size"]
    regions, skipped = [], 0
    for a in ks:
        l = links[a]
        off = prg + BANK * bsz + (a - 0x8000)
        if any(claimed[off:off + l["size"]]):
            skipped += 1
            continue
        regions.append({
            "id": f"bank{BANK}.struct_{a:04X}", "offset": off, "size": l["size"],
            "kind": "level", "name": f"Structure {l['w']}x{l['h']} to +${l['dest']:02X}",
            "confidence": "confirmed", "cpu_addr": a,
            "sha1": hashlib.sha1(rm.rom[off:off + l["size"]]).hexdigest(),
            "description":
                f"[next][dest][width][height][tiles]: {l['size']} bytes, "
                f"{l['w']} by {l['h']} tiles blitted to offset ${l['dest']:02X} of the "
                f"16-wide, 192-byte buffer at ${BUFFER:04X}. Consumed by bank 5 $8155, which "
                f"copies through ($18) and wraps rows on TXA / AND #$0F. Byte 0 is an offset "
                f"to the next record in the chain, and $81A4 follows it when the byte there "
                f"is non-zero, so a screen is several of these blitted over each other. "
                f"THE EXTENT IS THE RECORD'S OWN TWO CLAIMS AGREEING: byte 0 is "
                f"{l['size']} and 4 + {l['w']} x {l['h']} is {4 + l['w'] * l['h']}. That "
                f"agreement is also what ends a chain - following byte 0 blindly instead "
                f"walks $AC0D's chain out of the pool and into traced code at $ACA9. "
                f"Generated by tools/parse-structs.py."})
        claimed[off:off + l["size"]] = b"\1" * l["size"]
    if skipped:
        print(f"{skipped} links skipped because another region already claims their bytes")

    regions.sort(key=lambda r: r["offset"])
    doc = {"_comment": "GENERATED by tools/parse-structs.py - do not hand-edit. Bank 5's "
                       "structure records, blitted into the 16x12 tile buffer at $0740.",
           "regions": regions}
    text = json.dumps(doc, indent=2) + "\n"
    print(f"{len(regions)} regions, {sum(r['size'] for r in regions):,} bytes")
    if args.check:
        print("no change" if OUT.exists() and OUT.read_text() == text else "WOULD CHANGE")
        return 0
    OUT.write_text(text)
    print(f"wrote {OUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
