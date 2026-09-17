#!/usr/bin/env python3
"""Build The Guardian Legend ROM map: validate the annotations, then emit docs/.

The validation is the point. Prose is not checked by anything, so every claim that can be
made mechanical is: each region declares the SHA-1 of its own bytes, regions may not
overlap or straddle a bank boundary, named fields may declare their literal bytes, and the
coverage percentage is computed here rather than typed anywhere.

    python tools/build.py            # validate and write docs/
    python tools/build.py --check    # validate only, write nothing
    python tools/build.py --gaps     # list the largest unclaimed stretches
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl.model import AnnotationError, bank_window, load, segments
from tgl.site import build_site

ROOT = Path(__file__).resolve().parent.parent


def _span_coverage(regions, start, end):
    return sum(min(r["end"], end) - max(r["offset"], start)
               for r in regions if r["offset"] < end and r["end"] > start)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true", help="validate only, write nothing")
    ap.add_argument("--gaps", action="store_true", help="list the largest unclaimed stretches")
    args = ap.parse_args()

    try:
        rm = load(ROOT)
    except AnnotationError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    total = rm.meta["size"]
    print(f"{len(rm.regions)} regions, {rm.covered:,} / {total:,} bytes documented "
          f"({100 * rm.covered / total:.3f}%)")

    for seg in segments(rm.meta):
        span = seg["end"] - seg["start"]
        got = _span_coverage(rm.regions, seg["start"], seg["end"])
        print(f"  {seg['name']:<7} {got:>7,} / {span:>7,}  ({100 * got / span:6.2f}%)")

    print()
    for n, bank in enumerate(rm.meta["prg_banks"]):
        start = rm.meta["prg_offset"] + n * rm.meta["prg_bank_size"]
        end = start + rm.meta["prg_bank_size"]
        got = _span_coverage(rm.regions, start, end)
        print(f"  PRG bank {n} ${bank_window(rm.meta, n):04X}  "
              f"{got:>6,} / {rm.meta['prg_bank_size']:,}  "
              f"({100 * got / rm.meta['prg_bank_size']:6.2f}%)  {bank['role']}")

    if args.gaps:
        print(f"\n{len(rm.gaps)} unclaimed stretches, largest first:")
        for gap in sorted(rm.gaps, key=lambda g: -g["size"])[:25]:
            where = (f'bank {gap["prg_bank"]} ${gap["cpu_addr"]:04X}'
                     if gap["segment"] == "prg" else "-")
            print(f"  0x{gap['offset']:05X}-0x{gap['end'] - 1:05X}  {gap['size']:>6,} B  "
                  f"{gap['segment']:<6} {where}")

    if not args.check:
        out = ROOT / "docs"
        out.mkdir(exist_ok=True)
        payload = {
            "rom": rm.meta,
            "coverage": {
                "documented_bytes": rm.covered,
                "total_bytes": total,
                "percent": round(100 * rm.covered / total, 4),
                "region_count": len(rm.regions),
            },
            "regions": rm.regions,
            "gaps": rm.gaps,
        }
        (out / "rom.json").write_text(
            json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        # The site build has guards of its own - notably that every region ends up with a
        # card on some page - so its failures are reported the same way the loader's are
        # rather than escaping as a traceback.
        try:
            written = build_site(rm, out)
        except AnnotationError as exc:
            print(f"error: {exc}", file=sys.stderr)
            return 1
        print(f"\nwrote docs/: rom.json, {', '.join(written)}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
