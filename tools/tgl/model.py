"""Load, validate and derive The Guardian Legend's ROM map.

The files under ``annotations/`` are the source of truth for everything a human has
asserted about this ROM. This module's job is to make sure none of those assertions
contradict the actual ROM image, and to derive whatever follows mechanically - segment,
PRG bank, CPU address, coverage, gaps - rather than having it hand-maintained.

Every check here exists because a wrong offset that nothing checks reads perfectly fine.
The SHA-1 per region is the load-bearing one: it makes a mis-stated offset impossible to
commit, because the declared hash stops matching the bytes.

Two differences from the Yoshi model this is descended from, both consequences of the
mapper:

* **There is no CHR segment.** iNES byte 5 is zero, so the cartridge has CHR RAM and every
  tile the PPU ever sees was uploaded from PRG by code. The file is header + PRG and
  nothing else, and ``_check_container`` asserts that rather than leaving it implied.
* **A PRG bank's window follows from the mapper, not from traced code.** UxROM puts the
  selected bank at $8000-$BFFF and the last bank permanently at $C000-$FFFF. So unlike
  MMC1 there is no PRG mode to establish and no bank without an address: banks 0-6 are
  $8000 windows and bank 7 is a $C000 window, and this module derives that rather than
  reading it out of the annotation. What is *not* derived, and is recorded as a lead in
  ``annotations/rom.json``, is whether bank 7 is ever also selected into $8000.
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass, field
from pathlib import Path

KINDS = [
    "header",
    "vectors",
    "code",
    "data",
    "pointer_table",
    "graphics",
    "nametable",
    "attributes",
    "palette",
    "music",
    "sfx",
    "level",
    "text",
    "padding",
    "unknown",
]

# How sure are we? Every region says. "confirmed" means the claim was checked against the
# bytes or against executing code; "lead" means it is a hypothesis worth recording but not
# yet established. The build does not police which is which - only the writer can - but
# having the field forces the question to be answered once per region.
CONFIDENCE = ["confirmed", "lead"]


class AnnotationError(Exception):
    """An annotation contradicts the ROM, or contradicts another annotation."""


@dataclass
class RomMap:
    meta: dict
    rom: bytes
    regions: list[dict]
    gaps: list[dict] = field(default_factory=list)

    @property
    def covered(self) -> int:
        return sum(r["size"] for r in self.regions)

    @property
    def prg(self) -> bytes:
        return self.rom[self.meta["prg_offset"]: self.meta["prg_offset"] + self.meta["prg_size"]]

    def prg_bank(self, n: int) -> bytes:
        size = self.meta["prg_bank_size"]
        start = self.meta["prg_offset"] + n * size
        return self.rom[start: start + size]

    def bank_window(self, n: int) -> int:
        """The CPU address bank ``n`` is mapped at. A property of the mapper, not of the
        bytes: UxROM's last bank is wired to $C000 and every other bank is selected into
        $8000."""
        return 0xC000 if n == self.meta["prg_bank_count"] - 1 else 0x8000

    def bank_info(self, n: int) -> dict:
        return self.meta["prg_banks"][n]


def _sha1(data: bytes) -> str:
    return hashlib.sha1(data).hexdigest()


def segments(meta: dict) -> list[dict]:
    """The top-level parts of this iNES file, as half-open file-offset ranges.

    Two, not three. There is no CHR segment: iNES byte 5 is zero.
    """
    return [
        {"name": "header", "start": 0, "end": meta["header_size"]},
        {"name": "prg", "start": meta["prg_offset"], "end": meta["prg_offset"] + meta["prg_size"]},
    ]


def bank_window(meta: dict, n: int) -> int:
    return 0xC000 if n == meta["prg_bank_count"] - 1 else 0x8000


def load(root: Path, exclude: set[str] | None = None) -> RomMap:
    """Load the annotations. ``exclude`` skips region files by name, which is how a
    generator avoids seeing its own previous output as already-claimed ground."""
    exclude = exclude or set()
    meta = json.loads((root / "annotations" / "rom.json").read_text(encoding="utf-8"))
    rom = (root / meta["file"]).read_bytes()

    _check_container(rom, meta)

    regions: list[dict] = []
    for path in sorted((root / "annotations" / "regions").glob("*.json")):
        if path.name in exclude:
            continue
        doc = json.loads(path.read_text(encoding="utf-8"))
        for region in doc["regions"]:
            region["source"] = path.name
            regions.append(_check_region(region, rom, meta))

    regions.sort(key=lambda r: r["offset"])
    _check_disjoint(regions)

    return RomMap(meta=meta, rom=rom, regions=regions, gaps=_find_gaps(regions, meta))


def _check_container(rom: bytes, meta: dict) -> None:
    """The file is what the annotations think it is, and the iNES header still says what
    this project recorded it as saying."""
    if len(rom) != meta["size"]:
        raise AnnotationError(f"ROM is {len(rom)} bytes, annotations expect {meta['size']}")
    if _sha1(rom) != meta["sha1"]:
        raise AnnotationError(f"ROM SHA-1 is {_sha1(rom)}, annotations expect {meta['sha1']}")

    expected = meta["header_size"] + meta["prg_size"]
    if expected != meta["size"]:
        raise AnnotationError(
            f"header_size + prg_size = {expected}, but the ROM is {meta['size']} bytes")

    declared = meta["ines_header"]
    if rom[4] * 16384 != declared["prg_size_declared"]:
        raise AnnotationError(
            f"header byte 4 gives {rom[4] * 16384} bytes of PRG, "
            f"annotations record {declared['prg_size_declared']}")
    if rom[5] * 8192 != declared["chr_size_declared"]:
        raise AnnotationError(
            f"header byte 5 gives {rom[5] * 8192} bytes of CHR, "
            f"annotations record {declared['chr_size_declared']}")
    if declared["prg_size_declared"] != meta["prg_size"]:
        raise AnnotationError("the header's PRG size disagrees with prg_size")

    # This one is an assertion about the *cartridge*, not about the container, and it is
    # here because everything downstream depends on it. A zero CHR figure means CHR RAM:
    # no tile data is present in the file as tiles, every tile is uploaded from PRG by
    # code, and finding the uploaders is the whole graphics problem. If this ever stops
    # being zero, the file being loaded is not this ROM.
    if declared["chr_size_declared"] != 0:
        raise AnnotationError(
            "header byte 5 is non-zero, so this file declares CHR ROM - but this project "
            "is built on the cartridge having CHR RAM; re-read annotations/rom.json:chr")

    mapper = (rom[7] & 0xF0) | (rom[6] >> 4)
    if mapper != meta["mapper"]["number"]:
        raise AnnotationError(
            f"header encodes mapper {mapper}, annotations say {meta['mapper']['number']}")

    if meta["prg_bank_size"] * meta["prg_bank_count"] != meta["prg_size"]:
        raise AnnotationError("prg_bank_size x prg_bank_count does not equal prg_size")
    if len(meta["prg_banks"]) != meta["prg_bank_count"]:
        raise AnnotationError("prg_banks does not have one entry per PRG bank")

    # The mapper's own numbers, asserted rather than assumed. UxROM switches a 16 KB
    # window, so a bank that is not 16 KB is not a UxROM bank and every CPU address this
    # module derives would be wrong.
    if meta["prg_bank_size"] != 0x4000:
        raise AnnotationError("UxROM banks PRG in 16 KB units; prg_bank_size is not 0x4000")

    # The three vectors, read out of the file rather than trusted. This check exists
    # because it was missing and something got through: rom.json carried the NMI vector as
    # 53877 ($D275) when the bytes at $FFFA say $DC75 - a typo in a hand-entered address,
    # which is exactly the assertion the playbook says nothing else checks. It survived
    # because $D275 is a perfectly legal address that disassembles into the middle of a
    # real routine, and what caught it was the code tracer seeding itself there and
    # reporting one illegal opcode. A number in an annotation is not checked by anything
    # unless something checks it.
    for name, addr in (("nmi", 0xFFFA), ("reset", 0xFFFC), ("irq", 0xFFFE)):
        off = len(rom) - (0x10000 - addr)
        actual = rom[off] | (rom[off + 1] << 8)
        if meta["vectors"][name] != actual:
            raise AnnotationError(
                f"annotations record the {name.upper()} vector as "
                f"${meta['vectors'][name]:04X}, but the bytes at ${addr:04X} say "
                f"${actual:04X}")


def _check_region(region: dict, rom: bytes, meta: dict) -> dict:
    rid = region.get("id")
    if not rid:
        raise AnnotationError(f"region in {region['source']} has no id")

    def bad(msg: str) -> AnnotationError:
        return AnnotationError(f"{rid} ({region['source']}): {msg}")

    for required in ("offset", "size", "kind", "name", "description", "confidence"):
        if required not in region:
            raise bad(f"missing required key {required!r}")

    offset, size = region["offset"], region["size"]
    if size <= 0:
        raise bad("size must be positive")
    if offset < 0 or offset + size > len(rom):
        raise bad(f"[0x{offset:X},0x{offset + size:X}) falls outside the ROM")
    if region["kind"] not in KINDS:
        raise bad(f"unknown kind {region['kind']!r}; expected one of {', '.join(KINDS)}")
    if region["confidence"] not in CONFIDENCE:
        raise bad(f"confidence must be one of {', '.join(CONFIDENCE)}")

    actual = _sha1(rom[offset: offset + size])
    if region.get("sha1") != actual:
        raise bad(f"declared sha1 {region.get('sha1')} but the bytes hash to {actual}")

    # A graphics region must say how to read its bytes. A raw block run through a
    # decompressor produces plausible noise rather than an error, so a wrong default draws
    # garbage and nothing complains. Say it, or the build stops.
    if region["kind"] == "graphics" and "codec" not in region:
        raise bad("a graphics region must declare a codec; use a raw_* name if it is not "
                  "compressed")

    region["end"] = offset + size
    region["segment"] = _derive_segment(region, meta, bad)
    region["prg_bank"] = _derive_prg_bank(region, meta, bad)
    region["cpu_addr"] = _derive_cpu_addr(region, meta, bad)

    # An id ending in four hex digits names an address, so it has to be the address the
    # region is actually at. This looks like pedantry and is not: it is the only check that
    # catches two same-sized regions whose offsets have been swapped. That corruption
    # survives everything else - the same bytes are emitted in the same order, so the
    # reassembly is still exact, and if the SHA-1s are recomputed they match too. Confirmed
    # by doing it on purpose: bank0.code_8187 and bank0.code_818E were swapped with their
    # hashes recomputed and the whole 131,088 bytes still rebuilt byte for byte.
    if region["cpu_addr"] is not None and len(rid) > 5 and rid[-5] == "_":
        try:
            named = int(rid[-4:], 16)
        except ValueError:
            named = None
        if named is not None and named != region["cpu_addr"]:
            raise bad(f"the id names ${named:04X} but the region is at "
                      f"${region['cpu_addr']:04X}")
    region["fields"] = [_check_field(f, region, rom, bad) for f in region.get("fields", [])]
    return region


def _derive_segment(region: dict, meta: dict, bad) -> str:
    for seg in segments(meta):
        if seg["start"] <= region["offset"] < seg["end"]:
            if region["end"] > seg["end"]:
                raise bad(f"region straddles the end of the {seg['name']} segment")
            return seg["name"]
    raise bad(f"offset 0x{region['offset']:X} is in no segment")


def _derive_prg_bank(region: dict, meta: dict, bad) -> int | None:
    """Which 16 KB PRG bank a region is in. A region may not straddle two of them: the two
    halves would be separate unknowns living at the same CPU addresses."""
    if region["segment"] != "prg":
        if region.get("bank") is not None:
            raise bad("only PRG regions have a PRG bank")
        return None
    size = meta["prg_bank_size"]
    rel = region["offset"] - meta["prg_offset"]
    first, last = rel // size, (region["end"] - 1 - meta["prg_offset"]) // size
    if first != last:
        raise bad(f"region spans PRG banks {first} and {last}; split it at the bank boundary")
    declared = region.get("bank")
    if declared is not None and declared != first:
        raise bad(f"declared bank {declared} but the offset is in bank {first}")
    return first


def _derive_cpu_addr(region: dict, meta: dict, bad) -> int | None:
    """Where the bytes live when the CPU can see them.

    Unlike the MMC1 cartridges this code is descended from, every UxROM bank has a window:
    the last one is wired to $C000 and all the others are selected into $8000. So there is
    no such thing here as a bank with no CPU address. What an address in $8000-$BFFF does
    *not* do is identify a byte - it exists in all seven switchable banks at once - which
    is why every tool in this project carries the bank alongside it.
    """
    if region["segment"] != "prg":
        if region.get("cpu_addr") is not None:
            raise bad("only PRG regions have a CPU address")
        return None
    rel = (region["offset"] - meta["prg_offset"]) % meta["prg_bank_size"]
    actual = bank_window(meta, region["prg_bank"]) + rel
    declared = region.get("cpu_addr")
    if declared is not None and declared != actual:
        raise bad(f"declared cpu_addr ${declared:04X} but bank {region['prg_bank']} maps it "
                  f"to ${actual:04X}")
    return actual


def _check_field(fld: dict, region: dict, rom: bytes, bad) -> dict:
    name = fld.get("name", "?")
    if fld["offset"] < 0 or fld["offset"] + fld["size"] > region["size"]:
        raise bad(f"field {name} does not fit inside the region")

    start = region["offset"] + fld["offset"]
    actual = rom[start: start + fld["size"]]
    declared = fld.get("bytes")
    if declared is not None and bytes.fromhex(declared) != actual:
        raise bad(f"field {name} declares bytes {declared} but the ROM has {actual.hex()}")

    fld["bytes"] = actual.hex()
    fld["file_offset"] = start
    if region["cpu_addr"] is not None:
        fld["cpu_addr"] = region["cpu_addr"] + fld["offset"]
    return fld


def _check_disjoint(regions: list[dict]) -> None:
    seen: dict[str, dict] = {}
    for region in regions:
        if region["id"] in seen:
            raise AnnotationError(f"duplicate region id {region['id']}")
        seen[region["id"]] = region
    for a, b in zip(regions, regions[1:]):
        if b["offset"] < a["end"]:
            raise AnnotationError(
                f"{a['id']} [0x{a['offset']:X},0x{a['end']:X}) overlaps "
                f"{b['id']} [0x{b['offset']:X},0x{b['end']:X})")


def bank_edges(meta: dict) -> list[int]:
    """Every file offset at which the mapping of the bytes changes."""
    edges = {s["start"] for s in segments(meta)} | {s["end"] for s in segments(meta)}
    for n in range(meta["prg_bank_count"] + 1):
        edges.add(meta["prg_offset"] + n * meta["prg_bank_size"])
    return sorted(edges)


def _find_gaps(regions: list[dict], meta: dict) -> list[dict]:
    """Every stretch of ROM nobody has claimed yet, split at segment and bank edges.

    Splitting at bank boundaries is not cosmetic. A stretch spanning two banks is two
    separate unknowns at the same CPU addresses, not one, and reporting it as one produces
    an address range that does not exist.
    """
    edges = bank_edges(meta)
    gaps, cursor = [], 0
    for region in regions + [{"offset": meta["size"], "end": meta["size"]}]:
        while cursor < region["offset"]:
            stop = min([region["offset"]] + [e for e in edges if e > cursor])
            gaps.append({"offset": cursor, "size": stop - cursor, "end": stop})
            cursor = stop
        cursor = max(cursor, region["end"])

    for gap in gaps:
        gap["segment"] = next(
            (s["name"] for s in segments(meta) if s["start"] <= gap["offset"] < s["end"]), None)
        gap["prg_bank"] = gap["cpu_addr"] = None
        if gap["segment"] == "prg":
            rel = gap["offset"] - meta["prg_offset"]
            gap["prg_bank"] = rel // meta["prg_bank_size"]
            gap["cpu_addr"] = bank_window(meta, gap["prg_bank"]) + rel % meta["prg_bank_size"]
    return gaps
