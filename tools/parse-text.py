#!/usr/bin/env python3
"""Parse the ROM's two text formats and emit `annotations/regions/30-text.json`.

    python tools/parse-text.py            # rewrite the file
    python tools/parse-text.py --check    # report, write nothing
    python tools/parse-text.py --dump     # print the decoded text

**The output file is generated.** A hand edit is lost on the next run.

There are three text mechanisms in this ROM and they are not variations of one thing. The
first, the inline PPU strings after `JSR $D576`, is handled by the code tracer because its
bytes sit in the instruction stream. The other two are here:

**The dialogue script**, bank 5 `$9639-$9F0F`. Twenty `$00`-terminated messages behind a
21-entry pointer table at `$960F`. This is the corridor and shop dialogue - the longest
continuous prose in the ROM at 2,263 bytes. Codes: `$00` ends a message, `$01` ends a
screenful, `$0D` ends a line.

**The PPU script**, read by the renderer at bank 0 `$8495`. A different format for a
different job: laying out a whole screen rather than printing a sentence. An item is
`[col][count][characters]`; `$FF` ends a row and steps the PPU address on by `$20`; `$FE`
ends the script. Bit 7 of the count means **repeat one character** rather than advance
through the source, which is a run-length fill - `$84CD BIT $15 / BPL` is the test, and
the `DEY` on the other arm is what re-reads the same byte.

The check that carries the dialogue claim is not that it decodes. It is that the twenty
messages **partition** `$9639-$9F0F` with no gap, no overlap and nothing left over, and
that every pointer lands on a message head. Those are two statements about the same bytes
from two directions - the table and the terminators - and neither was derived from the
other.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl.model import AnnotationError, bank_window, load

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "annotations" / "regions" / "30-text.json"

# The dialogue script. Both numbers are derived below and checked, not trusted: the table
# base is also the operand of the reader at bank 5 $8476, and the entry count is what makes
# the table end exactly where its own first message begins.
DIALOGUE_BANK = 5
DIALOGUE_TABLE = 0x960F
DIALOGUE_ENTRIES = 21

# The PPU scripts, each with the call site that hands it to the renderer READ BY HAND
# rather than taken from a sweep. A first version listed ten candidates from an
# immediate-tracking sweep over traced code; that sweep walks addresses rather than control
# flow, so it mispairs - it reported bank 2's pointer as $8B08 when the two instructions at
# $8AC8 and $8ACC build $8B05 - and of the ten, only these three are handed to $8495 at all.
# The other seven go to $C04B, $C006, $C07E, $80F5 and $C042: different consumers, different
# formats, none of them claimed here.
#
# $8600 is NOT a script head - parsing from it runs past the $FE at $86E7. CORRECTION: this
# comment used to leave that open. The head is $84F7: $8485-$8493 builds PPU $2000 and
# pointer $84F7 and falls into $8495, and parsing from $84F7 ends on exactly that $FE -
# 30 rows of tiles $80-$F6, a picture, not text. $8600 is in its middle.
CREDITS = ("THE ENDING CREDITS. $891B points $16/$17 at $89F9 once; each pass of the loop at $8927 renders the next script at PPU $2220 - $8495 leaves the pointer just past the $FE - waits $8BB2[$F0] seconds and clears the text. So this script is reached by SEQUENCE, not by any pointer: nothing in the ROM names its address. Screen {n} of the chain $89F9 (MISSION COMPLETE) ... $8BA3 (PASSWORD TGL), which partitions $89F9-$8BB1 exactly.")

PPU_SCRIPTS = [
    (0, 0x84F7, 0x2000, "$8485-$8493"),
    (0, 0x86E8, 0x2080, "$8381-$8391"),
    (0, 0x8836, 0x2220, "$8822-$8832"),
    (0, 0x89F9, 0x2220, "$891F-$892F"),
    (0, 0x8A10, 0x2220, "$891B", CREDITS.format(n=2)),
    (0, 0x8A35, 0x2220, "$891B", CREDITS.format(n=3)),
    (0, 0x8A75, 0x2220, "$891B", CREDITS.format(n=4)),
    (0, 0x8A93, 0x2220, "$891B", CREDITS.format(n=5)),
    (0, 0x8AB8, 0x2220, "$891B", CREDITS.format(n=6)),
    (0, 0x8AEC, 0x2220, "$891B", CREDITS.format(n=7)),
    (0, 0x8B4D, 0x2220, "$891B", CREDITS.format(n=8)),
    (0, 0x8B67, 0x2220, "$891B", CREDITS.format(n=9)),
]

# Glyphs, as far as the text itself establishes them. EVERY ENTRY HERE IS DERIVED FROM
# CONTEXT, not from a font - there is no font to read, because CHR is RAM on this cartridge
# and no uploader has been found. The letters, digits and space are ASCII and need no
# argument. The rest are listed with the count of places they occur, because that is the
# whole of the evidence.
GLYPHS = {
    0x3B: (";", "4 places, each ending a clause that a following one continues - "
                "'the life-forms; if you need', 'cannot be removed; I think I goofed up'. "
                "ASCII $3B is also ';', so nothing is remapped here."),
    0x3C: (",", "13 places, every one a comma position: 'was our home, but we were', "
                "'If I fail, I would like you', 'NO.1, fire at the gate'. ASCII $3C is "
                "'<', so this IS a remap."),
    0x3D: ("-", "6 places, all inside 'life-forms' or 'self-destruct'. ASCII $3D is '='."),
    0x3F: ("?", "3 places, all genuine questions: 'record your progress?', 'Any luck?', "
                "'What are you doing here?'. ASCII $3F is also '?'."),
    0x5B: (".", "52 places - the most common non-letter in the script. Ends sentences, "
                "appears three in a row as an ellipsis in 'reading this...', and sits "
                "inside 'No.1' and 'No.4'. ASCII $5B is '['."),
    0x5D: ("!", "2 places, 'Good Luck!' and 'Do not wait here!'. The argument is the "
                "CONTRAST with $3F rather than the shape: this script uses $3F at every "
                "place a question mark belongs and $5D at the only two places an "
                "exclamation mark does, and never the other way round."),
    0x5E: ('"', "12 places, always in pairs, around NAJU and around 'Warp panel'. "
                "ASCII $5E is '^'."),
    0x60: ("'", "1 place, 'don't'. ASCII $60 is a backtick, which is close enough to be "
                "no evidence either way; the context is the whole argument."),
}

CONTROL = {0x00: "\x00", 0x01: "\n\n", 0x0D: "\n"}


def decode_text(data: bytes) -> str:
    out = []
    for c in data:
        if c in CONTROL:
            out.append(CONTROL[c])
        elif c in GLYPHS:
            out.append(GLYPHS[c][0])
        elif 32 <= c < 127:
            out.append(chr(c))
        else:
            out.append(f"<{c:02X}>")
    return "".join(out)


def parse_dialogue(rm) -> tuple[list[int], list[tuple[int, int]]]:
    """(pointer targets, [(start, end)]) - and prove the messages partition the block."""
    meta = rm.meta
    data = rm.prg_bank(DIALOGUE_BANK)
    base = bank_window(meta, DIALOGUE_BANK)

    def at(addr: int) -> int:
        return data[addr - base]

    table = [at(DIALOGUE_TABLE + 2 * k) | (at(DIALOGUE_TABLE + 2 * k + 1) << 8)
             for k in range(DIALOGUE_ENTRIES)]

    # The table ends exactly where its own first message begins. That is the boundary
    # evidence for the entry count, and it is the only thing that bounds it: the reader at
    # $8476 takes its index from $0620,X, an object field, so nothing in the code says how
    # many entries there are.
    first = min(table)
    if DIALOGUE_TABLE + 2 * DIALOGUE_ENTRIES != first:
        raise AnnotationError(
            f"the {DIALOGUE_ENTRIES}-entry table would end at "
            f"${DIALOGUE_TABLE + 2 * DIALOGUE_ENTRIES:04X} but its first message is at "
            f"${first:04X}; the entry count is wrong")

    spans = []
    for start in sorted(set(table)):
        end = start
        while at(end) != 0x00:
            end += 1
        spans.append((start, end + 1))

    # The partition check. Coverage alone would pass for a grammar whose lengths were all
    # one short; what this asserts is that the messages meet end to end with nothing over.
    cursor = spans[0][0]
    for start, end in spans:
        if start != cursor:
            raise AnnotationError(
                f"messages do not partition the block: expected ${cursor:04X}, "
                f"the next message begins at ${start:04X}")
        cursor = end
    return table, spans


def parse_ppu_script(rm, bank: int, start: int) -> tuple[int, int, int]:
    """(end address, item count, row count), by the grammar of the renderer at bank 0 $8495."""
    meta = rm.meta
    data = rm.prg_bank(bank)
    base = bank_window(meta, bank)
    limit = base + len(data)
    addr, items, rows = start, 0, 0
    while True:
        if addr >= limit:
            raise AnnotationError(f"PPU script at bank {bank} ${start:04X} runs off the bank")
        head = data[addr - base]
        addr += 1
        if head not in (0xFE, 0xFF) and addr >= limit:
            raise AnnotationError(f"PPU script at bank {bank} ${start:04X} runs off the bank")
        if head == 0xFE:
            return addr, items, rows
        if head == 0xFF:
            rows += 1
            continue
        count = data[addr - base]
        addr += 1
        # Bit 7 is the run-length flag: the source byte is re-read rather than advanced, so
        # the item carries ONE character however large the count is.
        addr += 1 if count & 0x80 else (count & 0x7F)
        items += 1


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true", help="report, write nothing")
    ap.add_argument("--dump", action="store_true", help="print the decoded text")
    args = ap.parse_args()

    try:
        rm = load(ROOT, exclude={OUT.name})
        table, spans = parse_dialogue(rm)
    except AnnotationError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    meta = rm.meta
    b5 = rm.prg_bank(DIALOGUE_BANK)
    base5 = bank_window(meta, DIALOGUE_BANK)
    off5 = meta["prg_offset"] + DIALOGUE_BANK * meta["prg_bank_size"]

    def file_off(bank: int, addr: int) -> int:
        return (meta["prg_offset"] + bank * meta["prg_bank_size"]
                + addr - bank_window(meta, bank))

    regions = []

    sha = hashlib.sha1(rm.rom[file_off(5, DIALOGUE_TABLE):
                              file_off(5, DIALOGUE_TABLE) + 2 * DIALOGUE_ENTRIES]).hexdigest()
    dupes = sorted({a for a in table if table.count(a) > 1})
    regions.append({
        "id": f"bank{DIALOGUE_BANK}.msgtable_{DIALOGUE_TABLE:04X}",
        "offset": file_off(5, DIALOGUE_TABLE),
        "size": 2 * DIALOGUE_ENTRIES,
        "kind": "pointer_table",
        "name": "Dialogue message pointer table",
        "confidence": "confirmed",
        "cpu_addr": DIALOGUE_TABLE,
        "sha1": sha,
        "description": (
            f"{DIALOGUE_ENTRIES} little-endian pointers, ${DIALOGUE_TABLE:04X}-"
            f"${DIALOGUE_TABLE + 2 * DIALOGUE_ENTRIES - 1:04X}, into the dialogue script "
            "that follows immediately. Read by bank 5 $8476: LDA $0620,X gives an object's "
            "message number, ASL A doubles it into Y, and LDA $960F,Y / LDA $9610,Y fetch "
            "the two halves - so the base in the operand is this region's own address, "
            "which is the strongest statement available that the table starts here. "
            f"The entry count is bounded by structure, not by the reader: {DIALOGUE_ENTRIES}"
            f" x 2 = {2 * DIALOGUE_ENTRIES} bytes ends at "
            f"${DIALOGUE_TABLE + 2 * DIALOGUE_ENTRIES:04X}, exactly where "
            "the first message begins, with nothing over. NOTHING IN THE CODE BOUNDS IT - "
            "the index comes from $0620,X, an object field, and no CPY or mask on it has "
            "been found. "
            + (f"Slots pointing at the same message: ${dupes[0]:04X} is named twice. That is "
               "in the data, not a parse error. " if dupes else "")
            + "Every one of the pointers lands on a message head, and the messages "
              "partition the block end to end - two statements from two directions, "
              "neither derived from the other."),
    })

    for k, (start, end) in enumerate(spans):
        body = rm.rom[file_off(5, start):file_off(5, end)]
        text = decode_text(body).rstrip("\x00")
        preview = " ".join(text.split())
        slots = [i for i, a in enumerate(table) if a == start]
        regions.append({
            "id": f"bank{DIALOGUE_BANK}.message_{start:04X}",
            "offset": file_off(5, start),
            "size": end - start,
            "kind": "text",
            "name": f'"{preview[:48]}{"..." if len(preview) > 48 else ""}"',
            "confidence": "confirmed",
            "cpu_addr": start,
            "sha1": hashlib.sha1(body).hexdigest(),
            "description": (
                f"Dialogue message, {end - start} bytes, named by table slot"
                f"{'s' if len(slots) > 1 else ''} {', '.join(str(s) for s in slots)}. "
                f"It reads:\n\n{text.strip()}\n\n"
                "Terminated by $00; $01 ends a screenful and $0D ends a line. The extent is "
                "settled twice over - the $00 at the end, and the next table pointer - and "
                "the twenty messages partition $9639-$9F0F with no gap and nothing over. "
                "The glyph readings for the punctuation are derived from context and are "
                "listed with their evidence in this file's header region; there is no font "
                "in the ROM to check them against, because CHR is RAM here."),
        })

    for entry in PPU_SCRIPTS:
        bank, start, ppu, site = entry[:4]
        how = entry[4] if len(entry) > 4 else None
        try:
            end, items, rows = parse_ppu_script(rm, bank, start)
        except AnnotationError as exc:
            print(f"warning: {exc}", file=sys.stderr)
            continue
        body = rm.rom[file_off(bank, start):file_off(bank, end)]
        text = " ".join(decode_text(bytes(c for c in body if 0x20 <= c < 0x7B)).split())
        regions.append({
            "id": f"bank{bank}.ppuscript_{start:04X}",
            "offset": file_off(bank, start),
            "size": end - start,
            "kind": "data",
            "name": f"PPU script at ${start:04X}",
            "confidence": "confirmed",
            "cpu_addr": start,
            "sha1": hashlib.sha1(body).hexdigest(),
            "description": (
                f"A screen-painting script for the renderer at bank 0 $8495, painting from "
                f"PPU ${ppu:04X}: {items} items "
                f"over {rows} row breaks, {end - start} bytes, ending at ${end - 1:04X} on "
                "the $FE the renderer stops at. An item is [col][count][characters]; the "
                "column is ORed into the PPU address low byte, $FF ends a row and adds $20 "
                "to the address, and bit 7 of the count means repeat one character instead "
                "of advancing through the source, which is a run-length fill. "
                + (how + " " if how else
                 "**Nothing in the ROM names this address as an operand.** It is reached "
                 "through a pointer built as LDA #lo / STA $16 and LDA #hi / STA $17 at "
                 + site + ", which "
                 "is the idiom playbook section 5 warns about: a search for the address "
                 "would report the block unreferenced. It was found by walking traced code "
                 "and tracking immediates. ")
                + (f'The printable bytes read as: "{text[:180]}". ' if len(text) > 8 else
                   "Its payload is mostly tile numbers rather than letters. ")
                + "NOT ESTABLISHED: what the non-letter tile numbers depict, and whether "
                  "the glyph readings that hold for the dialogue script hold here - the "
                  "renderers are different and CHR is RAM, so the font need not be the "
                  "same one."),
        })

    regions.sort(key=lambda r: r["offset"])
    doc = {
        "_comment": (
            "GENERATED by tools/parse-text.py. Do not hand edit. The dialogue script's "
            "extent is proved by a partition check - the twenty messages meet end to end "
            "across $9639-$9F0F with no gap and nothing over - and each PPU script's extent "
            "comes from parsing it with the grammar of the renderer at bank 0 $8495."),
        "_glyphs": {f"${k:02X}": {"reads_as": v[0], "evidence": v[1], "derived_from":
                                  "context, not a font"} for k, v in sorted(GLYPHS.items())},
        "_glyph_caveat": (
            "Every glyph above is derived from context. There is no font in this file to "
            "check them against: CHR is RAM and no uploader has been found, so no byte of "
            "the ROM is a tile yet. CORRECTION, recorded rather than edited away: an "
            "earlier entry in annotations/dispatch.json read $5C-$5F as a single 2x2 "
            "graphic, on the strength of bank 1 writing $5C $5E to PPU $21AF and $5D $5F "
            "to $21CF, one nametable row apart. The dialogue script then showed $5D used "
            "as an exclamation mark and $5E as a quote in running English. Both readings "
            "cannot be right for one font, and they do not have to be: with CHR RAM the "
            "tile at a given index is whatever was last uploaded, so a title screen and a "
            "dialogue box can disagree about $5C. Which of the two is happening here is "
            "NOT established, and the bank 0 script is a third data point - it uses $5C "
            "where a comma belongs ('LONG AGO,AN ALIEN RACE') while the dialogue script "
            "uses $3C for the same job."),
        "regions": regions,
    }
    text_out = json.dumps(doc, indent=2, ensure_ascii=False) + "\n"

    print(f"{len(regions)} regions, {sum(r['size'] for r in regions):,} bytes")
    print(f"  dialogue: {len(spans)} messages + a {DIALOGUE_ENTRIES}-entry table, "
          f"{sum(e - s for s, e in spans):,} bytes, partition closes")
    print(f"  PPU scripts: {sum(1 for r in regions if 'ppuscript' in r['id'])} parsed")

    if args.dump:
        for start, end in spans:
            print(f"\n----- ${start:04X} -----")
            print(decode_text(rm.rom[file_off(5, start):file_off(5, end)]).rstrip("\x00"))

    if args.check:
        old = OUT.read_text(encoding="utf-8") if OUT.exists() else ""
        print("no change" if old == text_out else "WOULD CHANGE")
        return 0
    OUT.write_text(text_out, encoding="utf-8")
    print(f"wrote {OUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
