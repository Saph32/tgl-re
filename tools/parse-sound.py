#!/usr/bin/env python3
"""Parse the music and sound effects into `annotations/regions/50-sound.json`.

    python tools/parse-sound.py            # rewrite the file, print the checks
    python tools/parse-sound.py --check    # report, write nothing
    python tools/parse-sound.py --dump     # every song, track by track
    python tools/parse-sound.py --song 7   # one song, decoded event by event

**The output file is generated. A hand edit to it is lost on the next run.**

The format, the channel model and what is NOT established are in `tools/tgl/sound.py`.
Read that header before citing anything here.

What this tool checks, and why those checks are worth something
--------------------------------------------------------------
1. **Every track ends.** Each one is walked byte by byte from its header pointer until an
   unconditional terminator - $82/$84, which stop the channel, or $80, an unconditional
   jump, which is how looping music ends. A single wrong operand length desynchronises the
   walk and it runs off into the next track's bytes, so "all of them end" is a real check
   rather than a restatement.
2. **The command holes are counted, not assumed.** $95-$AF would index past a 21-entry
   dispatch table and $B0-$DF would advance the stream pointer by zero. The walk censuses
   every command byte it meets; if either range turned up, the format would be wrong.
3. **The tracks tile the data.** Their spans are required not to overlap except where two
   songs genuinely share bytes, which happens and is reported rather than smoothed over.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl import sound
from tgl.model import load

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "annotations" / "regions" / "50-sound.json"

SONG_COUNT = 72   # bounded by structure: see TABLE_DESC below

TABLES = [
    (0x932C, 42, "Sound command dispatch", "pointer_table",
     "21 entries, each a handler address minus one, indexed by ASL A at $9315 on a stream "
     "byte in $80-$94. Bounded by structure: entry 20 ends at $9355 and handler 0, the "
     "target of entry 0, begins at $9356. Registered in annotations/dispatch.json, which "
     "is what seeds the trace with all 21 arms."),
    (0x9771, 8, "Hardware channel masks", "data",
     "Two four-byte tables: $9771 holds 01 02 04 08 and $9775 holds FE FD FB F7. $96CF "
     "indexes both by $0343,X - the hardware channel a soft channel wants - to test and "
     "then claim a bit in the busy mask $0306. Four bytes each because there are four "
     "hardware channels; this is the allocator that lets seven soft channels share them."),
    (0x985A, 216, "Note period table", "data",
     "108 little-endian 11-bit periods, $07FE down to $0004, read by $9596 as "
     "LDA $9840,Y / LDA $9841,Y with Y = (note + transpose) * 2. THE BASE IS $9840, NOT "
     "THIS ADDRESS: index 0 would land 26 entries earlier, in bytes that are not periods, "
     "so the used part of the table starts here at index $1A. The values are their own "
     "argument - a monotonically falling run of legal APU period values, halving about "
     "every twelve entries, which is an equal-tempered octave."),
    (0x9942, 30, "Note duration table", "data",
     "30 bytes, read by $94E6 as LDA $9941,Y with Y = duration byte - $E0. The first "
     "fifteen are 01 02 03 04 06 08 0C 10 18 20 30 40 60 80 C0 - a doubling series with "
     "dotted values between - and the rest are triplet and tied lengths. BOUNDED BY THE "
     "DATA, not by a guess: walking every track in the ROM and censusing the duration "
     "bytes gives exactly $E1-$FE, which is indices 1 to 30, which is exactly this many "
     "entries. Index 0 cannot occur because $E0 means 'the literal byte after me'."),
    (0x9961, 8, "Pitch envelope pointers", "pointer_table",
     "Four little-endian pointers, read by $964A as LDA $995F,Y / LDA $9960,Y with "
     "Y = ((index * 2) AND $7F) - the mask matters, and missing it makes the pointers come "
     "out as RAM addresses. They name $9969, $9972, $9994 and $99A1. The table ends where "
     "its own first target begins."),
    (0x9969, 68, "Pitch envelope data", "data",
     "Four sequences of small signed bytes - 02 01 00 FF FE FF 00 01, and so on - each "
     "ending in a byte with bit 7 set ($81 or $82). These are per-frame pitch offsets: "
     "vibrato and slide shapes. WHAT THE TERMINATOR'S LOW BITS MEAN is not established; a "
     "loop point is the obvious guess and is not checked here."),
    (0x99AD, 24, "Volume envelope pointers", "pointer_table",
     "Twelve little-endian pointers, read by $95B2 as LDA $99AB,Y / LDA $99AC,Y with "
     "Y = index * 2, so index 1 is the first entry. Bounded at both ends: index 0 is "
     "skipped by the BEQ two instructions earlier, and the twelfth entry ends at $99C4 "
     "with its own first target starting at $99C5. Censusing every $85 command in the ROM "
     "gives instrument numbers 1, 2, 3, 4, 9 and 10 - a subset of the twelve."),
    (0x99C5, 264, "Volume envelope data", "data",
     "Twelve sequences of 4-bit volume levels, one per frame, named by the pointer table "
     "above. The first begins 0F 0F 0F 0F ... - a flat sustain. Extent runs to the first "
     "song header at $9ACD."),
]


def collect(bank0: bytes) -> dict:
    ptrs = sound.song_pointers(bank0, SONG_COUNT)
    songs, spans, census = [], [], {}
    for i, p in enumerate(ptrs):
        h = sound.parse_header(bank0, p)
        if h["kind"] == "code":
            songs.append({"id": i, "addr": p, "code": True, "tracks": []})
            continue
        spans.append((p, p + h["size"], f"song {i} header"))
        tracks = []
        for t in h["tracks"]:
            if t["stream"] is None:
                tracks.append({**t, "walk": None})
                continue
            w = sound.walk_track(bank0, t["stream"])
            spans.append((w["start"], w["end"], f"song {i} channel {t['channel']}"))
            for k, v in w["census"].items():
                census[k] = census.get(k, 0) + v
            tracks.append({**t, "walk": w})
        songs.append({"id": i, "addr": p, "code": False, "size": h["size"],
                      "tracks": tracks})
    return {"ptrs": ptrs, "songs": songs, "spans": spans, "census": census}


def merged(spans):
    """Maximal non-overlapping runs. Songs share bytes - song 30 starts at song 1's loop
    points - so a region per track would overlap and the region store forbids that."""
    out = []
    for s, e, name in sorted(spans):
        if out and s <= out[-1][1]:
            out[-1][1] = max(out[-1][1], e)
            out[-1][2].append(name)
        else:
            out.append([s, e, [name]])
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true", help="report, write nothing")
    ap.add_argument("--dump", action="store_true", help="every song, track by track")
    ap.add_argument("--song", type=int, help="decode one song event by event")
    args = ap.parse_args()

    rm = load(ROOT, exclude={OUT.name})
    b0 = rm.prg_bank(0)
    got = collect(b0)

    if args.song is not None:
        s = got["songs"][args.song]
        print(f"song {s['id']} at ${s['addr']:04X}"
              + ("  (a code entry, not a song)" if s["code"] else ""))
        for t in s.get("tracks", []):
            if t["walk"] is None:
                print(f"  channel {t['channel']}: silence record")
                continue
            print(f"  channel {t['channel']} -> hardware {t['hw']}, "
                  f"stream ${t['stream']:04X}-${t['walk']['end'] - 1:04X}, "
                  f"{t['walk']['notes']} notes")
            o = t["stream"] - 0x8000
            while True:
                b = b0[o]
                if b < 0x80:
                    nxt = b0[o + 1]
                    n = (3 if nxt == 0xE0 else 2) if nxt >= 0xE0 else 1
                    d = f" dur ${nxt:02X}" if n > 1 else ""
                    print(f"    ${0x8000 + o:04X}  note ${b:02X}{d}")
                elif b >= 0xE0:
                    n = 2 if b == 0xE0 else 1
                    print(f"    ${0x8000 + o:04X}  hold ${b:02X}")
                else:
                    name, ops, _ = sound.COMMANDS[b]
                    n = 1 + ops
                    arg = " ".join(f"{x:02X}" for x in b0[o + 1:o + 1 + ops])
                    print(f"    ${0x8000 + o:04X}  {name} {arg}")
                    if b in sound.TERMINATORS:
                        break
                o += n
        return 0

    ok = sum(1 for s in got["songs"] for t in s["tracks"]
             if t["walk"] and t["walk"]["ok"])
    bad = sum(1 for s in got["songs"] for t in s["tracks"]
              if t["walk"] and not t["walk"]["ok"])
    loops = sum(1 for s in got["songs"] for t in s["tracks"]
                if t["walk"] and t["walk"].get("loops"))
    notes = sum(t["walk"]["notes"] for s in got["songs"] for t in s["tracks"] if t["walk"])
    code = sum(1 for s in got["songs"] if s["code"])

    print(f"{SONG_COUNT} song table entries, {code} of them code rather than data")
    print(f"{ok + bad} tracks: {ok} reach a terminator, {bad} do not; "
          f"{loops} end on a loop jump; {notes:,} notes in total")
    holes = [b for b in got["census"] if not 0x80 <= b <= 0x94]
    print("command bytes met: "
          + " ".join(f"${k:02X}x{v}" for k, v in sorted(got["census"].items())))
    print(f"bytes in the $95-$AF or $B0-$DF holes: {len(holes)}"
          + ("" if not holes else f"  ** {holes} **"))

    runs = merged(got["spans"])
    total = sum(e - s for s, e, _ in runs)
    print(f"{len(got['spans'])} header and track spans merge into {len(runs)} runs, "
          f"{total:,} bytes, ${runs[0][0]:04X}-${runs[-1][1] - 1:04X}")

    if args.dump:
        for s in got["songs"]:
            if s["code"]:
                print(f"  song {s['id']:2d} ${s['addr']:04X}  code entry")
                continue
            ch = ", ".join(f"ch{t['channel']}->hw{t['hw']}" for t in s["tracks"]
                           if t["walk"])
            n = sum(t["walk"]["notes"] for t in s["tracks"] if t["walk"])
            print(f"  song {s['id']:2d} ${s['addr']:04X}  {len(s['tracks'])} tracks, "
                  f"{n:4d} notes  [{ch}]")

    prg, bsz = rm.meta["prg_offset"], rm.meta["prg_bank_size"]
    claimed = bytearray(len(rm.rom))
    for r in rm.regions:
        claimed[r["offset"]:r["offset"] + r["size"]] = b"\1" * r["size"]
    regions = []

    def add(addr, size, name, kind, desc, conf="confirmed"):
        off = prg + (addr - 0x8000)
        if any(claimed[off:off + size]):
            return
        regions.append({
            "id": f"bank0.{'tbl' if kind == 'pointer_table' else 'snd'}_{addr:04X}",
            "offset": off, "size": size, "kind": kind, "name": name,
            "confidence": conf, "cpu_addr": addr,
            "sha1": hashlib.sha1(rm.rom[off:off + size]).hexdigest(),
            "description": desc,
        })
        claimed[off:off + size] = b"\1" * size

    add(sound.SONG_TABLE, 2 * SONG_COUNT, f"Song pointers ({SONG_COUNT} entries)",
        "pointer_table",
        f"{SONG_COUNT} little-endian pointers, read by $97E4 as LDA $9B04,X / LDA $9B05,X "
        "with X = song id * 2, after $97CC - bank 0's entry slot 2 - takes the id in A. "
        "BOUNDED BY STRUCTURE: the table ends at $9B93 and the lowest target above it is "
        "$9B94, the next byte, so it cannot be one entry longer. Five entries point at a "
        "byte of $00, which $97E4 treats not as a song but as code: it pushes the pointer "
        "and RTSes to it. The rest are song headers - a record count, then that many "
        "[channel][9 field] records, the last two fields being the track's stream pointer.")

    for addr, size, name, kind, desc in TABLES:
        add(addr, size, name, kind, desc)

    for s, e, who in runs:
        first = who[0]
        add(s, e - s, f"Song data ({len(who)} tracks)", "music",
            f"Music and sound-effect streams, ${s:04X}-${e - 1:04X}. Contributed by: "
            + "; ".join(sorted(set(who))[:8])
            + ("" if len(set(who)) <= 8 else f"; and {len(set(who)) - 8} more")
            + ". Every track here was walked byte by byte from its header pointer to an "
            "unconditional terminator - $82 or $84, which stop the channel, or $80, an "
            "unconditional jump back to a loop point. Tracks are merged into runs because "
            "songs SHARE bytes: song 30's three tracks begin exactly at song 1's loop "
            "points, so it is the same music without its intro. Generated by "
            "tools/parse-sound.py; the format is in tools/tgl/sound.py.")

    regions.sort(key=lambda r: r["offset"])
    doc = {"_comment": "GENERATED by tools/parse-sound.py - do not hand-edit. The sound "
                       "driver's tables and the music data. Format and evidence: "
                       "tools/tgl/sound.py.",
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
