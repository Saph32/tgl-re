"""Generate docs/ - the human-readable side of the ROM map.

Everything on these pages comes from the validated annotation store. Nothing is typed in
here that could be derived: counts, percentages, hex dumps and byte figures are all
computed from the ROM at build time, because a number in prose is not checked by anything.

The presentation half (the stylesheet, the coverage bar, the region card, the palette
swatches) is carried over from the Yoshi project. The page set is not: this cartridge has
CHR RAM and no CHR segment, so the site is an overview plus one page per PRG bank and
nothing else until regions exist to justify more.

Two guards run on every build:
  * every region gets a card on some page, so nothing can be annotated and then quietly
    not shown;
  * the per-page coverage figures are recomputed from the regions rather than carried.
"""

from __future__ import annotations

import html
from pathlib import Path

from .model import AnnotationError, bank_window, segments

KIND_COLOURS = {
    "header": "#7c8cf8", "vectors": "#f2704f", "code": "#4fb0f2", "data": "#9d7cf8",
    "pointer_table": "#c77cf8", "graphics": "#38c172", "nametable": "#38b2ac",
    "attributes": "#48bb78", "palette": "#ed8936", "ppu_script": "#00a3a3", "music": "#ecc94b", "sfx": "#d69e2e",
    "level": "#f56565", "text": "#ed64a6", "checksum": "#0bc5ea", "padding": "#718096",
    "unknown": "#4a5568",
}

# Any kind added to model.KINDS without a colour here falls back rather than crashing the
# build; the legend and the bar must agree on that.
DEFAULT_COLOUR = "#4a5568"

CSS = """
:root{--bg:#fbfbfd;--fg:#1c2024;--dim:#5b6470;--line:#e2e5ea;--card:#fff;--accent:#2563c9;
--code:#f3f5f8;--gap:#d8dce3;--navbg:#fff}
@media (prefers-color-scheme:dark){:root{--bg:#14161a;--fg:#e6e9ee;--dim:#9aa3af;
--line:#282c34;--card:#1b1e24;--accent:#6aa6ff;--code:#22262d;--gap:#343a44;--navbg:#1b1e24}}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--fg);
font:15px/1.65 -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif}
.wrap{max-width:1080px;margin:0 auto;padding:28px 24px 96px}
nav{background:var(--navbg);border-bottom:1px solid var(--line);position:sticky;top:0;z-index:5}
nav .inner{max-width:1080px;margin:0 auto;padding:0 24px;display:flex;flex-wrap:wrap;gap:2px}
nav a{display:block;padding:13px 12px;color:var(--dim);text-decoration:none;font-size:14px;
font-weight:500;border-bottom:2px solid transparent;white-space:nowrap}
nav a:hover{color:var(--fg)}
nav a.on{color:var(--accent);border-bottom-color:var(--accent)}
nav a.dimmed{opacity:.55}
h1{font-size:30px;margin:0 0 4px;letter-spacing:-.02em}
h2{font-size:20px;margin:48px 0 14px;letter-spacing:-.01em;
padding-bottom:8px;border-bottom:1px solid var(--line)}
h3{font-size:16px;margin:0 0 6px}
h4{font-size:14px;margin:26px 0 6px;color:var(--dim);text-transform:uppercase;
letter-spacing:.06em}
.sub{color:var(--dim);margin:0 0 28px}
code,pre,.mono{font-family:ui-monospace,SFMono-Regular,"SF Mono",Menlo,Consolas,monospace}
code{background:var(--code);padding:1px 5px;border-radius:4px;font-size:.9em}
pre{background:var(--code);padding:12px 14px;border-radius:8px;overflow-x:auto;
font-size:12.5px;line-height:1.55;margin:10px 0}
.card{background:var(--card);border:1px solid var(--line);border-radius:10px;
padding:18px 20px;margin:14px 0}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(210px,1fr));gap:12px}
.stat{background:var(--card);border:1px solid var(--line);border-radius:10px;padding:14px 16px}
.stat .k{color:var(--dim);font-size:12px;text-transform:uppercase;letter-spacing:.06em}
.stat .v{font-size:19px;font-weight:600;margin-top:3px}
table{border-collapse:collapse;width:100%;font-size:13.5px;margin:10px 0}
th,td{text-align:left;padding:7px 10px;border-bottom:1px solid var(--line);vertical-align:top}
th{color:var(--dim);font-weight:600;font-size:12px;text-transform:uppercase;letter-spacing:.05em}
tbody tr:last-child td{border-bottom:none}
.scroll{overflow-x:auto}
.bar{display:flex;height:26px;border-radius:6px;overflow:hidden;border:1px solid var(--line);
margin:6px 0 4px}
.bar span{display:block;min-width:0}
.legend{display:flex;flex-wrap:wrap;gap:14px;font-size:12.5px;color:var(--dim);margin-top:8px}
.legend i{display:inline-block;width:10px;height:10px;border-radius:2px;margin-right:5px}
.tag{display:inline-block;font-size:11px;font-weight:600;padding:2px 8px;border-radius:20px;
text-transform:uppercase;letter-spacing:.05em;color:#fff;vertical-align:2px}
.conf{display:inline-block;font-size:11px;font-weight:600;padding:2px 8px;border-radius:20px;
border:1px solid var(--line);color:var(--dim);vertical-align:2px}
.conf.confirmed{color:#2f855a;border-color:#2f855a66}
.conf.lead{color:#b7791f;border-color:#b7791f66}
.desc{color:var(--fg);margin:8px 0 0}
.meta{color:var(--dim);font-size:12.5px;margin:2px 0 0}
.field{border-left:2px solid var(--line);padding:2px 0 2px 14px;margin:14px 0}
.field .fname{font-weight:600;font-size:13.5px}
.field .fmeta{color:var(--dim);font-size:12px;margin:1px 0 4px}
.field .fdesc{font-size:13.5px}
.note{border-left:3px solid var(--accent);background:var(--card);padding:12px 16px;
border-radius:0 8px 8px 0;margin:14px 0;font-size:14px}
.warn{border-left-color:#b7791f}
a{color:var(--accent)}
.pagelinks{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:14px;
margin:18px 0}
.pagelink{display:block;background:var(--card);border:1px solid var(--line);border-radius:10px;
padding:16px 18px;text-decoration:none;color:inherit}
.pagelink:hover{border-color:var(--accent)}
.pagelink .t{font-weight:600;font-size:15px;color:var(--accent)}
.pagelink .d{color:var(--dim);font-size:13px;margin-top:4px}
.pagelink .n{font-size:12px;color:var(--dim);margin-top:8px;font-family:ui-monospace,monospace}
.toc{column-width:250px;column-gap:20px;font-size:13px;margin:12px 0}
.toc a{display:block;text-decoration:none;padding:1px 0}
.toc a:hover{text-decoration:underline}
figure{margin:18px 0 26px}
figure img{max-width:100%;height:auto;image-rendering:pixelated;border:1px solid var(--line);
border-radius:6px;background:#000;display:block}
figcaption{color:var(--dim);font-size:13px;margin-top:8px}
figcaption strong{color:var(--fg)}
.envs{display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:12px;
margin:16px 0}
.env{margin:0;background:var(--card);border:1px solid var(--line);border-radius:8px;
padding:10px}
.envbars{display:flex;align-items:flex-end;gap:2px;height:56px}
.bar1{flex:1;background:var(--accent);border-radius:1px;min-width:2px;opacity:.85}
.env figcaption{font-size:11.5px;margin-top:6px}
.ch{display:inline-block;background:var(--code);border-radius:3px;padding:0 4px;
font-size:11px;font-family:ui-monospace,monospace;color:var(--dim)}
.pals{display:grid;grid-template-columns:repeat(auto-fit,minmax(330px,1fr));gap:12px;
margin:14px 0}
.pal{border:1px solid var(--line);border-radius:8px;padding:10px 12px;background:var(--card)}
.palh{font-size:12px;color:var(--dim);text-transform:uppercase;letter-spacing:.06em;
margin-bottom:6px;font-family:ui-monospace,monospace}
.palrow{display:flex;align-items:center;gap:6px;margin:3px 0}
.pall{width:74px;font-size:11px;color:var(--dim)}
.palgrp{display:flex;margin-right:6px;border-radius:3px;overflow:hidden;
border:1px solid var(--line)}
.sw{width:30px;height:24px;font:10px/24px ui-monospace,monospace;text-align:center;
display:block}
"""


# The 2C02's 64 colours, as RGB. THIS IS AN APPROXIMATION AND THE PAGE SAYS SO. The NES
# generates colour as an analogue NTSC signal rather than from a lookup table, so there is no
# single correct set of RGB values - every emulator ships a slightly different one, and the
# same ROM looks different on two televisions. These are here so a palette region can be
# looked at instead of read as hex; they are not a claim about what the hardware emits.
NES_RGB = [
    (84, 84, 84), (0, 30, 116), (8, 16, 144), (48, 0, 136), (68, 0, 100), (92, 0, 48),
    (84, 4, 0), (60, 24, 0), (32, 42, 0), (8, 58, 0), (0, 64, 0), (0, 60, 0),
    (0, 50, 60), (0, 0, 0), (0, 0, 0), (0, 0, 0),
    (152, 150, 152), (8, 76, 196), (48, 50, 236), (92, 30, 228), (136, 20, 176),
    (160, 20, 100), (152, 34, 32), (120, 60, 0), (84, 90, 0), (40, 114, 0), (8, 124, 0),
    (0, 118, 40), (0, 102, 120), (0, 0, 0), (0, 0, 0), (0, 0, 0),
    (236, 238, 236), (76, 154, 236), (120, 124, 236), (176, 98, 236), (228, 84, 236),
    (236, 88, 180), (236, 106, 100), (212, 136, 32), (160, 170, 0), (116, 196, 0),
    (76, 208, 32), (56, 204, 108), (56, 180, 204), (60, 60, 60), (0, 0, 0), (0, 0, 0),
    (236, 238, 236), (168, 204, 236), (188, 188, 236), (212, 178, 236), (236, 174, 236),
    (236, 174, 212), (236, 180, 176), (228, 196, 144), (204, 210, 120), (180, 222, 120),
    (168, 226, 144), (152, 226, 180), (160, 214, 228), (160, 162, 160), (0, 0, 0), (0, 0, 0),
]


def _h(text) -> str:
    return html.escape(str(text))


def _swatches(data: bytes, base_addr: int | None) -> str:
    """Draw a palette region as colour, 32 bytes to a record and 4 to a sub-palette.

    A palette is the one kind of region whose whole content is colour, so a hex dump of it
    communicates nothing. Every byte is still printed beside its swatch - the picture is a
    way to look at the values, not a replacement for them.
    """
    out = ['<div class="pals">']
    for r in range(0, len(data), 32):
        record = data[r:r + 32]
        if len(record) < 32:
            break
        label = f"record {r // 32}"
        if base_addr is not None:
            label += f" &middot; ${base_addr + r:04X}"
        out.append(f'<div class="pal"><div class="palh">{label}</div>')
        for half, name in ((0, "background"), (16, "sprite")):
            out.append(f'<div class="palrow"><span class="pall">{name}</span>')
            for sub in range(4):
                out.append('<span class="palgrp">')
                for i in range(4):
                    value = record[half + sub * 4 + i] & 0x3F
                    red, green, blue = NES_RGB[value]
                    dark = (red * 299 + green * 587 + blue * 114) / 1000 < 128
                    out.append(
                        f'<span class="sw" style="background:rgb({red},{green},{blue});'
                        f'color:{"#fff" if dark else "#000"}" '
                        f'title="${value:02X}">{value:02X}</span>')
                out.append("</span>")
            out.append("</div>")
        out.append("</div>")
    out.append("</div>")
    return "".join(out)


# --------------------------------------------------------------------------- fragments

def _hexdump(data: bytes, base: int, addr_fmt) -> str:
    out = []
    for i in range(0, len(data), 16):
        row = data[i: i + 16]
        hexes = " ".join(f"{b:02X}" for b in row)
        ascii_ = "".join(chr(b) if 32 <= b < 127 else "." for b in row)
        out.append(f"{addr_fmt(base + i)}  {hexes:<47}  |{ascii_}|")
    return "\n".join(out)


def _span_coverage(regions, start, end) -> int:
    return sum(min(r["end"], end) - max(r["offset"], start)
               for r in regions if r["offset"] < end and r["end"] > start)


def _bar(regions: list[dict], start: int, end: int) -> str:
    """A coverage bar over one span of the file, to scale."""
    total = end - start
    p, cursor, kinds = [], start, set()
    for r in sorted(regions, key=lambda r: r["offset"]):
        if r["offset"] > cursor:
            p.append(f'<span style="width:{100 * (r["offset"] - cursor) / total}%;'
                     'background:var(--gap)"></span>')
        colour = KIND_COLOURS.get(r["kind"], DEFAULT_COLOUR)
        kinds.add(r["kind"])
        p.append(f'<span style="width:{100 * r["size"] / total}%;background:{colour}" '
                 f'title="{_h(r["id"])}"></span>')
        cursor = r["end"]
    if cursor < end:
        p.append(f'<span style="width:{100 * (end - cursor) / total}%;'
                 'background:var(--gap)"></span>')
    legend = "".join(
        f'<span><i style="background:{KIND_COLOURS.get(k, DEFAULT_COLOUR)}"></i>{_h(k)}</span>'
        for k in sorted(kinds))
    legend += '<span><i style="background:var(--gap)"></i>unclaimed</span>'
    return f'<div class="bar">{"".join(p)}</div><div class="legend">{legend}</div>'


def _stats(items: list[tuple[str, str]]) -> str:
    cells = "".join(f'<div class="stat"><div class="k">{_h(k)}</div>'
                    f'<div class="v">{v}</div></div>' for k, v in items)
    return f'<div class="grid">{cells}</div>'


def _kind_table(regions: list[dict]) -> str:
    by: dict[str, list[int]] = {}
    for r in regions:
        e = by.setdefault(r["kind"], [0, 0])
        e[0] += 1
        e[1] += r["size"]
    total = sum(v[1] for v in by.values()) or 1
    rows = "".join(
        f'<tr><td><span class="tag" style="background:'
        f'{KIND_COLOURS.get(k, DEFAULT_COLOUR)}">{_h(k)}</span></td>'
        f'<td class="mono">{v[0]}</td><td class="mono">{v[1]:,}</td>'
        f'<td class="mono">{100 * v[1] / total:.1f}%</td></tr>'
        for k, v in sorted(by.items(), key=lambda kv: -kv[1][1]))
    return ("<table><thead><tr><th>Kind</th><th>Regions</th><th>Bytes</th>"
            f"<th>Share of documented</th></tr></thead><tbody>{rows}</tbody></table>")


def _region_card(rm, r: dict) -> str:
    colour = KIND_COLOURS.get(r["kind"], DEFAULT_COLOUR)
    p = [f'<div class="card" id="{_h(r["id"])}">']
    p.append(f'<h3>{_h(r["name"])} '
             f'<span class="tag" style="background:{colour}">{_h(r["kind"])}</span> '
             f'<span class="conf {_h(r["confidence"])}">{_h(r["confidence"])}</span></h3>')
    bits = [f'<code>{_h(r["id"])}</code>',
            f'file 0x{r["offset"]:05X}-0x{r["end"] - 1:05X}',
            f'{r["size"]:,} bytes']
    if r["prg_bank"] is not None:
        bits.append(f'PRG bank {r["prg_bank"]}')
    if r["cpu_addr"] is not None:
        bits.append(f'CPU ${r["cpu_addr"]:04X}-${r["cpu_addr"] + r["size"] - 1:04X}')
    p.append(f'<p class="meta">{" &middot; ".join(bits)}</p>')
    p.append(f'<p class="desc">{_h(r["description"])}</p>')

    if r["kind"] == "palette" and r["size"] >= 32:
        p.append(_swatches(rm.rom[r["offset"]:r["end"]], r["cpu_addr"]))
        p.append('<p class="meta">Colours are an approximation. The NES makes colour as an '
                 "analogue NTSC signal, not from a table, so no set of RGB values is the "
                 "right one and every emulator ships a different one. The hex value in each "
                 "swatch is the byte in the ROM; that part is exact.</p>")

    fmt = ((lambda x: f"${x:04X}") if r["cpu_addr"] is not None else (lambda x: f"0x{x:05X}"))
    base = r["cpu_addr"] if r["cpu_addr"] is not None else r["offset"]
    limit = 128
    body = rm.rom[r["offset"]: r["end"]]
    p.append(f"<pre>{_h(_hexdump(body[:limit], base, fmt))}</pre>")
    if len(body) > limit:
        p.append(f'<p class="meta">First {limit} of {r["size"]:,} bytes. The region\'s SHA-1 '
                 f'<code>{_h(r["sha1"])}</code> covers all of them.</p>')
    for f in r["fields"]:
        p.append('<div class="field">')
        p.append(f'<div class="fname">{_h(f["name"])}</div>')
        fm = [f'+{f["offset"]}', f'{f["size"]} byte{"s" if f["size"] != 1 else ""}',
              f'<span class="mono">{_h(f["bytes"].upper())}</span>']
        if "cpu_addr" in f:
            fm.insert(0, f'<span class="mono">${f["cpu_addr"]:04X}</span>')
        if "value" in f:
            fm.append(f'= {f["value"]}')
        p.append(f'<div class="fmeta">{" &middot; ".join(fm)}</div>')
        p.append(f'<div class="fdesc">{_h(f["description"])}</div>')
        p.append("</div>")
    p.append("</div>")
    return "".join(p)


def _toc(regions: list[dict], label) -> str:
    links = "".join(f'<a href="#{_h(r["id"])}">{_h(label(r))}</a>' for r in regions)
    return f'<div class="toc">{links}</div>'


def _gap_table(gaps: list[dict], fmt_where) -> str:
    if not gaps:
        return '<p class="meta">None - every byte in this span is claimed by a region.</p>'
    rows = "".join(
        f'<tr><td class="mono">0x{g["offset"]:05X}-0x{g["end"] - 1:05X}</td>'
        f'<td class="mono">{g["size"]:,}</td><td class="mono">{fmt_where(g)}</td></tr>'
        for g in sorted(gaps, key=lambda g: -g["size"]))
    return ('<div class="scroll"><table><thead><tr><th>File offset</th><th>Bytes</th>'
            f"<th>Where</th></tr></thead><tbody>{rows}</tbody></table></div>")


def _pages(rm) -> list[tuple[str, str]]:
    """(filename, nav label) for every page of the site.

    Eight bank pages and an overview, and nothing else yet. There is deliberately no
    graphics page: this cartridge has CHR RAM, so no byte of this file is a tile until
    some routine uploads it, and a page called "graphics" before an uploader is found
    would be a page about nothing. Same for sound. They arrive when their regions do.
    """
    out = [("index.html", "Overview")]
    for n in range(rm.meta["prg_bank_count"]):
        out.append((f"bank{n}.html", f"Bank {n}"))
    out += [(f, label) for f, label, _, _ in _topic_pages(rm)]
    return out


# The topic pages, and the one place that decides which of them exist. The nav, the index
# grid and build_site() all read this, because they drifted apart once: sound.html was
# generated for a whole commit while appearing in neither the nav nor the index, so the
# only way to reach it was to type the filename.
# A topic's `select` picks the regions it is about. Most of them are one region kind, but
# not all: the password system is two text regions in bank 0 and a data region in bank 3,
# which is a subject rather than a kind, so the selector takes the regions and decides.
TOPICS = [
    ("text.html", "Text",
     lambda rs: [r for r in rs if r["kind"] == "text"],
     "Three formats that do not share a character map: inline PPU strings, the dialogue "
     "script and the screen scripts."),
    ("graphics.html", "Graphics",
     lambda rs: [r for r in rs if r["kind"] == "graphics"],
     "CHR RAM, so no byte of the file is a tile until code uploads it. The tile codec, "
     "every decoded tile, and the font."),
    ("sound.html", "Sound",
     lambda rs: [r for r in rs if r["kind"] == "music"],
     "Seven soft channels competing for four hardware ones, 72 songs, and a DMC channel "
     "that plays nothing at all."),
    ("password.html", "Password",
     lambda rs: [r for r in rs if r["id"] in PASSWORD_REGIONS],
     "32 characters, six bits each, a running XOR key and a checksum \u2014 and a back door "
     "that skips all of it."),
    ("enemies.html", "Enemies",
     lambda rs: [r for r in rs if r.get("source") == ENEMY_SOURCE],
     "127 object types with hit points, attack and art; 47 spawn scripts; and the loader "
     "that decompresses enemy tiles as rooms are entered."),
    ("labyrinth.html", "Labyrinth",
     lambda rs: [r for r in rs if r.get("source") == SCENE_SOURCE],
     "The whole labyrinth, how its rooms are encoded, where entrances, key doors, items and "
     "minibosses are, and every area's metatiles, drawn from the ROM with the tiles and palettes it "
     "loads - checked against a savestate cell for cell."),
    ("corridors.html", "Corridors",
     lambda rs: [r for r in rs if r.get("source") == SCREEN_SOURCE],
     "The vertically scrolling stages, for every corridor alike: the event stream that "
     "encodes a stage, how it is decoded a row at a time, what spawns enemies and what "
     "sets the scroll speed."),
    ("demo.html", "Demo",
     lambda rs: [r for r in rs if r["id"] in DEMO_REGIONS],
     "What plays when the title screen is left alone: a powered-up state, a random corridor "
     "and button presses invented from a 31-entry table - not a recording."),
    ("ending.html", "Ending",
     lambda rs: [r for r in rs if _is_ending(r)],
     "What happens when the final boss dies: the stage-end flag, the cutscene after corridor 21, "
     "the last corridor, the final score and the credits that never return."),
    ("status.html", "Status screen",
     lambda rs: [r for r in rs if r["id"] in STATUS_REGIONS],
     "Select during play: the world map, seven keys, twelve weapons and what each one costs "
     "to fire."),
]



def _is_ending(r) -> bool:
    """Regions of the ending sequence: bank 0 $88F5-$8BBA and bank 2 $8836-$8BF7."""
    a = r.get("cpu_addr", 0)
    b = r.get("prg_bank")
    return (b == 0 and 0x88F5 <= a < 0x8BBB) or (b == 2 and 0x8836 <= a < 0x8BF8)


SCREEN_SOURCE = "60-screen.json"
DEMO_REGIONS = ("bank7.tbl_DB22", "bank7.tbl_DB32")
PASSWORD_REGIONS = ("bank3.data_8513", "bank0.text_8BA3", "bank0.ppuscript_8B67")
# Everything tools/parse-enemies.py generates. Selected by source file rather than a list
# of ids, because the set grows whenever another spawn script or stream is found.
ENEMY_SOURCE = "80-enemies.json"
SCENE_SOURCE = "78-scenes.json"
STATUS_REGIONS = ("bank5.map_8A6E", "bank5.tbl_8690", "bank5.tbl_85DA", "bank5.tbl_87E4",
                  "bank2.gfx_8E0C", "bank2.gfx_928C", "bank2.gfx_92AC", "bank3.tbl_817A",
                  "bank7.tbl_EFD8", "bank7.tbl_FDCA", "bank7.tbl_FDD7")


EXTERNAL = Path(__file__).resolve().parents[2] / "annotations" / "external.json"
EXTERNAL_STATUSES = ("confirmed", "consistent", "rom-differs", "unchecked", "inconclusive")


def _external():
    """annotations/external.json, validated: every fact names a known source and status."""
    if not EXTERNAL.exists():
        return None
    import json as _json
    d = _json.loads(EXTERNAL.read_text(encoding="utf-8"))
    ids = {s["id"] for s in d["sources"]}
    seen = set()
    for f in d["facts"]:
        if f["source"] not in ids:
            raise AnnotationError(f'external fact {f["id"]}: unknown source {f["source"]}')
        if f["status"] not in EXTERNAL_STATUSES:
            raise AnnotationError(f'external fact {f["id"]}: unknown status {f["status"]}')
        if f["id"] in seen:
            raise AnnotationError(f'external fact {f["id"]} is duplicated')
        seen.add(f["id"])
    return d


STAGE_BOSSES = ((0, "Defense System", "cannons"), (7, "Eyeball Growth", "eyeballs"),
                (17, "Eyeball Growth", "eyeballs"))


def _stage_boss_section(rm, out=None) -> str:
    """The bosses that are part of the stage: pictures from tools/render-bosses.py."""
    import json as _json
    meta = {}
    if out is not None and (out / "boss-objects.json").exists():
        meta = _json.loads((out / "boss-objects.json").read_text(encoding="utf-8"))
    o = ['<h2 id="stage-bosses">Bosses that are part of the stage</h2>',
         '<p class="sub">Corridors 0, 7 and 17 list type <code>$06</code> as their boss (bank 3 '
         "<code>$9151</code>), and type <code>$06</code> is not something you can see. Its "
         "handler, bank 6 <code>$A889</code>, waits until the scroll has stopped, counts the "
         "objects of types <code>$36</code>, <code>$37</code>, <code>$7E</code> and "
         "<code>$7F</code> still alive and dies when there are none - which is what ends the "
         "fight. Those are ground objects, spawned by the stage&rsquo;s own background tiles "
         "(bank 5 <code>$89FB</code>) and drawn over them, so the boss is a part of the "
         "scenery. The names are the owner&rsquo;s (see Outside sources).</p>"]
    for c, name, what in STAGE_BOSSES:
        o.append(f'<h3 id="stage-boss-{c}">{name} &mdash; corridor {c}</h3>')
        if out is not None and (out / f"boss-{c}.png").exists():
            m = meta.get(str(c), {})
            objs = m.get("objects", [])
            kinds = sorted({x["type"] for x in objs} & {0x06, 0x36, 0x37, 0x7E, 0x7F})
            empty = bool(m.get("sprites_empty"))
            o.append(f'<p><img src="boss-{c}.png" width="512" height="384" alt="{name}, the '
                     f'screen when the boss phase starts" style="image-rendering:pixelated;'
                     f'max-width:100%;height:auto"></p>')
            o.append('<p class="meta">The playfield 60 frames after the controller '
                     "(type <code>$06</code>) exists with the scroll stopped, row "
                     f"{m.get('row', '?')}, as the game draws it. "
                     + ("<strong>With the background left out the frame is empty: everything "
                        "here is background tiles.</strong> The objects of the boss &mdash; "
                        + (", ".join(f"<code>${t:02X}</code>" for t in kinds) or "none found")
                        + " &mdash; are alive but never drawn: their handlers "
                          "(<code>$A8D8</code>, <code>$B851</code>) update hit boxes and fire, "
                          "and never call the sprite drawer."
                        if empty else
                        "Object types alive in that frame that this boss uses: "
                        + (", ".join(f"<code>${t:02X}</code>" for t in kinds) or "none found")
                        + ".")
                     + "</p>")
        else:
            o.append('<p class="meta">Not rendered yet (tools/render-bosses.py).</p>')
    o.append('<div class="note warn"><strong>Run, not recorded.</strong> These frames come from '
             "<code>tools/render-bosses.py</code>, which runs the ROM&rsquo;s own code on the NES "
             "model in <code>tools/tgl/cpu.py</code> (no cycle accuracy, no IRQ, one scroll "
             "value per scanline from the logged writes) from a corridor savestate, loading each "
             "corridor with <code>$EC94</code> and keeping the ship&rsquo;s life and lives topped "
             "up. The ship is usually destroyed by then, which leaves the boss alone on screen. "
             "The layouts are the code&rsquo;s; exact colours and pixels are the model&rsquo;s "
             "and have not been compared with hardware.</div>")
    return "".join(o)


def _boss_section(rm, names) -> str:
    """Movement and fire of each corridor boss, from tools/tgl/boss.py."""
    from tgl import boss
    b3 = rm.prg_bank(3)
    corr = {}
    for c in range(23):
        if c != 21:                    # slot 21 is never read: corridor 21 uses command 5
            corr.setdefault(b3[0x9151 - 0x8000 + c], []).append(c)
    out = ['<h2 id="boss-behaviour">How the corridor bosses move and fire</h2>',
           '<p class="sub">There is no shared boss engine: the boss type for a corridor comes '
           "from bank 3 <code>$9151</code>, and each type's behaviour is its own state machine "
           "in bank 6, built from a few shared routines. Whether a boss follows the player "
           "is therefore a property of each handler.</p>",
           '<div class="note warn"><strong>Read from the code, not observed.</strong> Only '
           "Fleepa's setup values are checked against a savestate (target y <code>$10</code>, "
           "mask <code>$0F</code>, and a y and velocity matching the bounce its code implies). "
           "Direction numbers are 0-15 in 22.5&deg; steps; 0/4/8/12 are down/right/up/left.</div>",
           "<table><thead><tr><th>Routine</th><th>What it does</th></tr></thead><tbody>"]
    for addr, what in boss.PRIMITIVES:
        out.append(f"<tr><td><code>{_h(addr)}</code></td><td>{_h(what)}</td></tr>")
    out.append("</tbody></table>")
    out.append('<div style="overflow-x:auto"><table><thead><tr><th>Boss</th><th>Corridors</th>'
               "<th>Follows the player?</th><th>Movement</th><th>Fire</th><th>Handler</th>"
               "</tr></thead><tbody>")
    for types, kind, handler, move, fire in boss.BEHAVIOUR:
        nm = sorted({names[t] for t in types if t in names})
        cs = sorted(c for t in types for c in corr.get(t, []))
        label = " / ".join(nm) if nm else "unnamed"
        label += "<br>" + ", ".join(f"<code>${t:02X}</code>" for t in types)
        out.append(f"<tr><td>{label}</td><td>{', '.join(str(c) for c in cs) or '&mdash;'}</td>"
                   f"<td><strong>{_h(boss.FOLLOW[kind])}</strong></td><td>{_h(move)}</td>"
                   f"<td>{_h(fire)}</td><td>{_h(handler)}</td></tr>")
    out.append("</tbody></table></div>")
    out.append(f'<div class="note">{boss.NOT_READ}</div>')
    return "".join(out)


def _boss_label(c: int, t: int) -> str:
    """The owner's name for corridor c's boss of type t: type $06 is three different bosses."""
    if t == 6:
        return {0: "Defense System", 7: "Eyeball Growth", 17: "Eyeball Growth"}.get(c, "")
    return _enemy_names().get(t, "")


def _tn(t) -> str:
    """' Name' for an object type the owner named, else ''."""
    n = _enemy_names().get(t)
    return f" <strong>{_h(n)}</strong>" if n else ""


def _enemy_names() -> dict:
    """Object type -> the owner's name for it (external.json fact enemy-names)."""
    ext = _external() or {"facts": []}
    m = next((f.get("enemy_names") for f in ext["facts"] if f.get("enemy_names")), {})
    return {int(k): v for k, v in m.items()}


def _topic_pages(rm):
    """(filename, nav label, blurb, count text) for each topic page that has content.

    The outside-sources page is the one topic with no regions: it is about what is known
    from OUTSIDE the ROM, so it counts facts."""
    out = []
    for fname, label, select, blurb in TOPICS:
        n = len(select(rm.regions))
        if n:
            out.append((fname, label, blurb, f"{n:,} regions"))
    ext = _external()
    if ext and ext["facts"]:
        out.append(("external.html", "Outside sources",
                    "What the manual and other outside sources say, each claim checked "
                    "against the ROM - or marked as not yet checked.",
                    f'{len(ext["facts"])} facts'))
    return out


def _doc(rm, title: str, active: str, body: str) -> str:
    nav = "".join(f'<a href="{f}" class="{"on" if f == active else ""}">{_h(label)}</a>'
                  for f, label in _pages(rm))
    return ('<!doctype html><html lang="en"><head><meta charset="utf-8">'
            '<meta name="viewport" content="width=device-width,initial-scale=1">'
            f"<title>{_h(title)}</title><style>{CSS}</style></head><body>"
            f'<nav><div class="inner">{nav}</div></nav><div class="wrap">'
            f"{body}</div></body></html>\n")


# --------------------------------------------------------------------------- pages

def _index(rm) -> str:
    meta = rm.meta
    total = meta["size"]
    pct = 100 * rm.covered / total
    p = [f'<h1>{_h(meta["title"])}</h1>',
         '<p class="sub">A byte-by-byte map of the ROM image, built from annotations that '
         "are checked against the file on every build.</p>"]

    p.append(_stats([
        ("Documented", f"{pct:.2f}%"),
        ("Bytes accounted for", f"{rm.covered:,} / {total:,}"),
        ("Regions", f"{len(rm.regions)}"),
        ("Unclaimed stretches", f"{len(rm.gaps)}"),
    ]))

    p.append('<div class="note"><strong>Accounting for a byte and understanding it are '
             "different claims.</strong> The percentage above is the first one. A region "
             "whose description says its format is undecoded still counts towards it, and "
             "every region says in its own text which of the two it is.</div>")

    p.append("<h2>The whole file</h2>")
    p.append(_bar(rm.regions, 0, total))
    rows = []
    for seg in segments(meta):
        span = seg["end"] - seg["start"]
        got = _span_coverage(rm.regions, seg["start"], seg["end"])
        rows.append(f'<tr><td>{_h(seg["name"])}</td>'
                    f'<td class="mono">0x{seg["start"]:05X}-0x{seg["end"] - 1:05X}</td>'
                    f'<td class="mono">{span:,}</td>'
                    f'<td class="mono">{got:,}</td>'
                    f'<td class="mono">{100 * got / span:.2f}%</td></tr>')
    p.append("<table><thead><tr><th>Segment</th><th>File offsets</th><th>Bytes</th>"
             f"<th>Documented</th><th></th></tr></thead><tbody>{''.join(rows)}</tbody></table>")
    p.append('<p class="meta">Two segments, not three. iNES byte 5 is zero, so there is no '
             "CHR segment in this file at all.</p>")

    p.append("<h2>What is in the container</h2>")
    hdr = next(r for r in rm.regions if r["id"] == "header.ines")
    p.append(_region_card(rm, hdr))

    p.append("<h2>How the cartridge is wired</h2>")
    m = meta["mapper"]
    p.append(f'<div class="card"><h3>Mapper {m["number"]} &mdash; {_h(m["name"])}</h3>'
             f'<p class="desc">{_h(m["description"])}</p></div>')
    bc = m["bus_conflicts"]
    p.append('<div class="card"><h3>Bus conflicts, and how this ROM avoids them</h3>'
             f'<p class="desc">{_h(bc["description"])}</p>'
             f'<p class="desc"><strong>Evidence.</strong> {_h(bc["evidence"])}</p></div>')
    p.append(f'<div class="card"><h3>Mirroring &mdash; {_h(m["mirroring"]["value"])}</h3>'
             f'<p class="desc">{_h(m["mirroring"]["description"])}</p></div>')
    c = meta["chr"]
    p.append(f'<div class="card"><h3>{_h(c["kind"])}</h3>'
             f'<p class="desc">{_h(c["evidence"])}</p></div>')

    p.append("<h2>Interrupt vectors</h2>")
    v = meta["vectors"]
    vec = next(r for r in rm.regions if r["kind"] == "vectors")
    p.append(f'<div class="card"><table><tbody>'
             f'<tr><td>NMI</td><td class="mono">$FFFA</td>'
             f'<td class="mono">${v["nmi"]:04X}</td></tr>'
             f'<tr><td>RESET</td><td class="mono">$FFFC</td>'
             f'<td class="mono">${v["reset"]:04X}</td></tr>'
             f'<tr><td>IRQ/BRK</td><td class="mono">$FFFE</td>'
             f'<td class="mono">${v["irq"]:04X}</td></tr></tbody></table>'
             f'<p class="desc">{_h(v["description"])}</p>'
             f'<p class="meta">The bytes themselves, and the argument for each target, are '
             f'on <a href="bank{vec["prg_bank"]}.html#{_h(vec["id"])}">bank '
             f'{vec["prg_bank"]}</a>.</p></div>')

    p.append("<h2>The eight PRG banks</h2>")
    p.append('<p class="sub">A PRG byte has a CPU address only once you say which bank it is '
             "in. Banks 0 to 6 are all selected into the same $8000-$BFFF window, so an "
             "address there names seven different bytes; bank 7 is wired to $C000-$FFFF and "
             "is the only one an address identifies on its own.</p>")
    links = []
    for n in range(meta["prg_bank_count"]):
        bank = meta["prg_banks"][n]
        start = meta["prg_offset"] + n * meta["prg_bank_size"]
        end = start + meta["prg_bank_size"]
        got = _span_coverage(rm.regions, start, end)
        w = bank_window(meta, n)
        links.append(
            f'<a class="pagelink" href="bank{n}.html">'
            f'<div class="t">PRG bank {n}</div>'
            f'<div class="d">{_h(bank["role"])} &middot; '
            f'${w:04X}-${w + meta["prg_bank_size"] - 1:04X}</div>'
            f'<div class="n">{got:,} / {meta["prg_bank_size"]:,} bytes '
            f'&middot; {100 * got / meta["prg_bank_size"]:.2f}% documented</div></a>')
    p.append(f'<div class="pagelinks">{"".join(links)}</div>')

    topics = _topic_pages(rm)
    if topics:
        p.append("<h2>By subject</h2>")
        tl = []
        for fname, label, blurb, n in topics:
            tl.append(f'<a class="pagelink" href="{fname}">'
                      f'<div class="t">{_h(label)}</div>'
                      f'<div class="d">{_h(blurb)}</div>'
                      f'<div class="n">{n}</div></a>')
        p.append(f'<div class="pagelinks">{"".join(tl)}</div>')

    p.append("<h2>What is documented so far</h2>")
    p.append(_kind_table(rm.regions))

    p.append("<h2>Open threads</h2>")
    p.append('<p class="sub">What is not established, kept here rather than in anyone\'s '
             "head. Each of these is a claim about the searches run so far.</p>")
    p.append("<ul>" + "".join(f"<li>{_h(t)}</li>" for t in meta["open_threads"]) + "</ul>")

    p.append("<h2>How to read these pages</h2>")
    p.append(
        '<div class="card"><p class="desc">Every region carries a <strong>confidence</strong>: '
        "<em>confirmed</em> means the claim was checked against the bytes or against code "
        "that executes; <em>lead</em> means it is a hypothesis worth recording and nothing "
        "more. Every region also declares the SHA-1 of its own bytes, and the build refuses "
        "to run if a hash stops matching, if two regions overlap, or if a region straddles a "
        "bank boundary. The machine-readable form of everything here is "
        '<a href="rom.json">rom.json</a>.</p></div>')
    return "".join(p)


def _bank_page(rm, n: int) -> str:
    meta = rm.meta
    bank = meta["prg_banks"][n]
    size = meta["prg_bank_size"]
    start = meta["prg_offset"] + n * size
    end = start + size
    window = bank_window(meta, n)
    regions = [r for r in rm.regions if r["segment"] == "prg" and r["prg_bank"] == n]
    gaps = [g for g in rm.gaps if g["segment"] == "prg" and g["prg_bank"] == n]
    got = _span_coverage(rm.regions, start, end)
    fixed = n == meta["prg_bank_count"] - 1

    p = [f"<h1>PRG bank {n}</h1>",
         f'<p class="sub">{_h(bank["role"])} &middot; '
         f'${window:04X}-${window + size - 1:04X}</p>']
    p.append(_stats([
        ("Documented", f"{100 * got / size:.2f}%"),
        ("Bytes", f"{got:,} / {size:,}"),
        ("Regions", f"{len(regions)}"),
        ("File offsets", f"0x{start:05X}-0x{end - 1:05X}"),
    ]))

    p.append('<div class="card"><h3>Why this bank sits where it does</h3>'
             f'<p class="desc">{_h(bank["evidence"])}</p></div>')

    if fixed:
        p.append('<div class="note"><strong>This is the fixed bank.</strong> UxROM wires '
                 "the last PRG bank to $C000-$FFFF and there is no register that can move "
                 "it, so these bytes are visible to the CPU at every moment the console is "
                 "running. That is why the interrupt vectors, the bank-switching routines "
                 "and the far-call trampoline are all here: none of them could work from a "
                 "window that is about to be switched out from under them.</div>")
    else:
        p.append('<div class="note warn"><strong>An address on this page does not identify '
                 "a byte.</strong> $8000-$BFFF is the switchable window, so every address "
                 "below exists in seven banks at once and only bank "
                 f"{n} has these particular bytes at it. Any address taken from a debugger, "
                 "a wiki or another disassembly has to carry a bank with it before it means "
                 "anything &mdash; <code>tools/whereis.py --bytes</code> settles which bank "
                 "really holds a given sequence.</div>")

    p.append("<h2>Layout</h2>")
    p.append(_bar(regions, start, end))

    p.append("<h2>Unclaimed</h2>")
    p.append(_gap_table(gaps, lambda g: (f'${g["cpu_addr"]:04X}-'
                                         f'${g["cpu_addr"] + g["size"] - 1:04X}')))

    p.append("<h2>Regions</h2>")
    if regions:
        p.append(_toc(regions, lambda r: f'${r["cpu_addr"]:04X} {r["name"]}'))
        p.extend(_region_card(rm, r) for r in regions)
    else:
        p.append('<p class="meta">Nothing annotated in this bank yet.</p>')
    return "".join(p)


# The glyph readings, for display only. The evidence for each is in
# annotations/regions/30-text.json, which is where they are argued; repeating the argument
# here would be a second copy of a claim that nothing compares against the first.
GLYPH_TEXT = {0x00: "", 0x01: "\n\n", 0x0D: "\n", 0x3B: ";", 0x3C: ",", 0x3D: "-",
              0x3F: "?", 0x5B: ".", 0x5D: "!", 0x5E: '"', 0x60: "'"}


def _text_page(rm) -> str:
    """Every decoded string, in all three of the formats that carry text."""
    inline = [r for r in rm.regions if r["kind"] == "text" and "inline_" in r["id"]]
    msgs = [r for r in rm.regions if r["kind"] == "text" and "message_" in r["id"]]
    scripts = [r for r in rm.regions if "ppuscript_" in r["id"]]
    table = next((r for r in rm.regions if "msgtable_" in r["id"]), None)

    p = ["<h1>Text</h1>",
         '<p class="sub">Three formats, not one, and they are not variations of each other. '
         "None of the text in this ROM sits in a block you could find by searching for it: "
         "the short strings are written inline after the <code>JSR</code> that prints them, "
         "the dialogue is behind a pointer table, and the screen layouts are reached through "
         "a pointer built from immediates that appears nowhere as an operand. All of it was "
         "found by following code.</p>"]

    p.append(_stats([
        ("Inline strings", f"{len(inline)}"),
        ("Dialogue messages", f"{len(msgs)}"),
        ("Screen scripts", f"{len(scripts)}"),
        ("Bytes of text", f"{sum(r['size'] for r in inline + msgs + scripts):,}"),
    ]))

    p.append('<div class="note warn"><strong>Every punctuation glyph here is read from '
             "context, and the ROM cannot settle any of them.</strong> A font would, and "
             "there is no font: CHR is RAM on this cartridge, so no byte of this file is a "
             "tile until code uploads one, and no uploader has been found. The letters, "
             "digits and space are ASCII and need no argument. The rest are guesses with "
             "evidence, and the evidence is counted below.</div>")

    if msgs:
        p.append("<h2>The dialogue script</h2>")
        p.append('<p class="sub">Twenty messages in bank 5, 2,263 bytes, the longest '
                 "continuous prose in the ROM. <code>$00</code> ends a message, "
                 "<code>$01</code> ends a screenful, <code>$0D</code> ends a line.</p>")
        p.append('<div class="note"><strong>What carries this is not that it decodes.</strong> '
                 "It is that the twenty messages <em>partition</em> "
                 "<code>$9639-$9F0F</code> end to end with no gap and nothing over, and that "
                 "every one of the 21 pointers lands on a message head. Those are two "
                 "statements about the same bytes from two directions &mdash; the table and "
                 "the terminators &mdash; and neither was derived from the other. A grammar "
                 "whose lengths were all one short would still cover every byte.</div>")
        for r in msgs:
            body = rm.rom[r["offset"]:r["end"]]
            text = "".join(GLYPH_TEXT.get(c, chr(c) if 32 <= c < 127 else "·")
                           for c in body).strip()
            slot = r["description"].split("table slot")[1].split(".")[0].strip()
            p.append(f'<div class="card" id="{_h(r["id"])}">'
                     f'<h3>${r["cpu_addr"]:04X} '
                     f'<span class="tag" style="background:{KIND_COLOURS["text"]}">text</span></h3>'
                     f'<p class="meta">slot {_h(slot)} &middot; {r["size"]} bytes &middot; '
                     f'<a href="bank{r["prg_bank"]}.html#{_h(r["id"])}">on bank '
                     f'{r["prg_bank"]}</a></p>'
                     f'<pre>{_h(text)}</pre></div>')

    if table:
        p.append("<h2>The pointer table</h2>")
        p.append(_region_card(rm, table))

    if scripts:
        p.append("<h2>Screen scripts</h2>")
        p.append('<p class="sub">A different format for a different job &mdash; painting a '
                 "whole screen rather than printing a sentence. An item is "
                 "<code>[col][count][characters]</code>, <code>$FF</code> ends a row and "
                 "steps the PPU address on by <code>$20</code>, <code>$FE</code> ends the "
                 "script, and bit 7 of the count repeats one character instead of advancing "
                 "through the source. All of that is read off the renderer at bank 0 "
                 "<code>$8495</code>, not inferred from the data.</p>")
        rows = "".join(
            f'<tr><td class="mono"><a href="bank{r["prg_bank"]}.html#{_h(r["id"])}">'
            f'${r["cpu_addr"]:04X}</a></td><td class="mono">{r["size"]}</td>'
            f'<td>{_h(r["description"].split(":")[1].split(",")[0].strip())}</td></tr>'
            for r in scripts)
        p.append("<table><thead><tr><th>Block</th><th>Bytes</th><th></th></tr></thead>"
                 f"<tbody>{rows}</tbody></table>")

    if inline:
        p.append("<h2>Inline strings</h2>")
        p.append('<p class="sub">Written immediately after the <code>JSR</code> that queues '
                 "them, so the bytes sit in the instruction stream and the code tracer has "
                 "to know about them or it decodes them as instructions.</p>")
        body = []
        for r in sorted(inline, key=lambda r: (r["prg_bank"], r["cpu_addr"])):
            raw = rm.rom[r["offset"]:r["end"]]
            has_addr = "[ppu_hi]" in r["description"]
            chars = raw[3:] if has_addr else raw[1:]
            text = "".join(chr(c) if 33 <= c < 127 else "·" for c in chars)
            dest = f"${raw[1]:02X}{raw[2]:02X}" if has_addr else "from $18/$19"
            body.append(
                f'<tr><td class="mono">{r["prg_bank"]}</td>'
                f'<td class="mono"><a href="bank{r["prg_bank"]}.html#{_h(r["id"])}">'
                f'${r["cpu_addr"]:04X}</a></td><td class="mono">{dest}</td>'
                f'<td class="mono">{raw[0]:02X}</td><td class="mono">{r["size"]}</td>'
                f'<td><code>{_h(text)}</code></td></tr>')
        p.append('<div class="scroll"><table><thead><tr><th>Bank</th><th>Block</th>'
                 "<th>PPU address</th><th>Count</th><th>Bytes</th><th>Reads as</th></tr>"
                 f"</thead><tbody>{''.join(body)}</tbody></table></div>")

    p.append("<h2>The glyphs, and why each is only a lead</h2>")
    p.append('<div class="note warn"><strong>The three formats do not agree with each other, '
             "and that disagreement is the finding.</strong> The dialogue script uses "
             "<code>$3C</code> where a comma belongs; the bank 0 screen script uses "
             "<code>$5C</code> for the same job (<em>LONG AGO,AN ALIEN RACE</em>). An earlier "
             "entry in this project read <code>$5C-$5F</code> as a single 2&times;2 graphic "
             "from a bank 1 screen. All three readings cannot hold for one font &mdash; and "
             "they do not have to, because with CHR RAM the tile at a given index is "
             "whatever was uploaded last. Which is happening here is not established.</div>")
    return "".join(p)


def _glyphs(data: bytes, per_row: int = 15) -> str:
    """Draw a 1bpp 7-byte-per-glyph block as SVG, at the size the PPU would."""
    n = len(data) // 7
    cell, gap = 8, 2
    w = per_row * (cell + gap)
    h = ((n + per_row - 1) // per_row) * (8 + gap + 7)
    out = [f'<svg viewBox="0 0 {w} {h}" width="100%" style="max-width:640px;'
           'image-rendering:pixelated" xmlns="http://www.w3.org/2000/svg">']
    for g in range(n):
        gx = (g % per_row) * (cell + gap)
        gy = (g // per_row) * (8 + gap + 7)
        for y in range(7):
            row = data[g * 7 + y]
            for x in range(8):
                if (row >> (7 - x)) & 1:
                    out.append(f'<rect x="{gx + x}" y="{gy + y}" width="1" height="1" '
                               'fill="currentColor"/>')
    out.append("</svg>")
    return "".join(out)


def _tiles_svg(tiles: bytes, per_row: int = 32, px: int = 22) -> str:
    """Render every 2bpp tile in a block. Colour 0 is transparent, so the page theme shows.

    One ``<path>`` per shade, not one ``<rect>`` per pixel. That matters: this page carries
    all 2,485 tiles in the ROM, and a rect per pixel makes it about 30 MB. Horizontal runs
    of one colour are merged into a single subpath, which brings it under a megabyte.
    """
    n = len(tiles) // 16
    if not n:
        return ""
    per_row = min(per_row, n)
    rows = (n + per_row - 1) // per_row
    w, h = per_row * 9 - 1, rows * 9 - 1
    paths: dict[int, list[str]] = {1: [], 2: [], 3: []}
    for i in range(n):
        ox, oy = (i % per_row) * 9, (i // per_row) * 9
        lo = tiles[16 * i:16 * i + 8]
        hi = tiles[16 * i + 8:16 * i + 16]
        for y in range(8):
            x = 0
            while x < 8:
                v = ((lo[y] >> (7 - x)) & 1) | (((hi[y] >> (7 - x)) & 1) << 1)
                run = 1
                while x + run < 8 and (((lo[y] >> (7 - x - run)) & 1)
                                       | (((hi[y] >> (7 - x - run)) & 1) << 1)) == v:
                    run += 1
                if v:
                    paths[v].append(f"M{ox + x} {oy + y}h{run}v1h-{run}z")
                x += run
    out = [f'<svg viewBox="0 0 {w} {h}" width="{min(w * px // 9, 780)}" '
           f'style="max-width:100%;height:auto;image-rendering:pixelated" '
           'xmlns="http://www.w3.org/2000/svg">']
    for v, op in ((1, "0.34"), (2, "0.67"), (3, "1")):
        if paths[v]:
            out.append(f'<path fill="currentColor" opacity="{op}" d="{"".join(paths[v])}"/>')
    out.append("</svg>")
    return "".join(out)


ICON_CODECS = ("raw_2bpp_icon", "raw_1bpp_low_plane", "raw_1bpp_shared_plane")


def _tgl_mode(rm) -> str:
    """The TGL back door's game: corridors only, in the order of bank 7 $ED08, with the
    bank 3 $817A reward list handed out between them."""
    b3, b7 = rm.prg_bank(3), rm.prg_bank(7)
    order = list(b7[0xED08 - 0xC000:0xED08 - 0xC000 + 21])
    pairs = [(b3[0x017A + 2 * k], b3[0x017B + 2 * k]) for k in range(73)]
    ext = _external()
    facts = ext["facts"] if ext else []
    names = next((f.get("weapon_names") for f in facts if f.get("weapon_names")), [])
    items = next((f.get("item_icons") for f in facts if f.get("item_icons")), {})
    label = lambda i: names[i] if i < 12 and i < len(names) else items.get(str(i), f"icon {i}")
    ic = dict(_icons(rm))["items"]

    p = ["<h2>The TGL game: corridors only</h2>",
         '<p class="sub">What <code>$30 = 2</code> does. Bit 1 of <code>$30</code> is tested '
         "wherever the game would go back to the labyrinth, and every time it sends the player "
         "to the next corridor instead &mdash; with a reward screen in between.</p>"]
    p.append('<div class="note"><strong>The loop.</strong> A new game (<code>$EB18</code>) '
             "clears <code>$51</code> and <code>$77</code> and starts corridor 0, the opening "
             "flight. When a corridor ends, <code>$ECE7</code> tests <code>$30</code> bit 1: "
             "in a normal game it returns to the labyrinth, in the TGL game it far-calls the "
             "reward screen (bank 3 <code>$80A0</code>), then <code>$ECFC</code> takes "
             "<code>$51 = $ED08[$77]</code>, increments <code>$77</code> and starts that "
             "corridor. After corridor 21 the normal ending runs. The HUD shows the corridor "
             "number instead of the area (<code>$E169</code>).</div>")
    p.append("<h3>Corridor order, <code>$ED08</code></h3>")
    p.append('<p class="desc">' + " &rarr; ".join(str(c) for c in order) +
             f" &mdash; each of 1-21 exactly once ({'checked' if sorted(order) == list(range(1, 22)) else 'NOT a permutation'}"
             "): the second-half corridor of a pair is played before the first of the next.</p>")

    p.append("<h3>What the score buys, <code>$817A</code></h3>")
    p.append('<div class="note"><strong>The score it counts is corridor score, less a boss '
             "clock.</strong> Each corridor start copies the score into <code>$04B9</code> "
             "(<code>$EF86</code>); when the boss appears bank 3 <code>$91A7</code> turns that "
             "into the points gained so far, and during the fight <code>$9305</code> takes 10 "
             "points off every 64 frames, down to zero. The reward screen adds the result to a "
             "running total at <code>$04B3</code> (bank 6 <code>$805A</code>) and prints it. "
             "<code>$15</code> is that total in units of 10,000 points (capped at 255), and "
             "<code>$80E7</code> hands out every entry from <code>$76</code> onward whose "
             "threshold is at most <code>$15</code> &mdash; through bank 2 <code>$86BC</code>, "
             "the ordinary pick-up routine. <code>$76</code> persists, so each entry is given "
             "once per game; at most five fit on a screen (the loop stops at PPU row "
             "<code>$23xx</code>), and the rest wait for the next corridor.</div>")
    rows = []
    for k, (t, i) in enumerate(pairs):
        rows.append(f"<tr><td>{k + 1}</td><td>{t * 10000:,}</td>"
                    f"<td>{_icons_svg([ic[i]], px=2) if i < 18 else ''}</td>"
                    f"<td>{_h(label(i))}</td><td>{i}</td></tr>")
    p.append("<table><thead><tr><th>#</th><th>Total score at least</th><th></th><th>Item</th>"
             f"<th>Icon</th></tr></thead><tbody>{''.join(rows)}</tbody></table>")
    p.append('<p class="meta">Scores are as the game prints them: the HUD shows the six '
             "score digits followed by a fixed 0 (labyrinth savestate: RAM 001684, screen "
             "<code>16840</code>), and the reward screen prints each threshold followed by the "
             "text <code>0000</code> (<code>$802E</code>). Weapons 0-10 go up a level (or become "
             "chips at level 3); 11 adds 20 Enemy Erasers; 12 refills life; 13 raises max life "
             "by 8; 14 attack; 15 shield; 16 fire rate (<code>$6B</code>, max 5); 17 the chip "
             "maximum (<code>$46</code>, max 10). NOT tried on hardware.</p>")
    return "".join(p)


def _icons(rm):
    """(label, list of 64-byte 2bpp icons) for bank 2's two icon sets.

    Weapon/item icons are four ordinary tiles each. Key icons are rebuilt the way $8212
    builds them: eight low-plane bytes from the icon, eight high-plane bytes from the frame
    at $928C shared by all eight."""
    b2 = rm.prg_bank(2)
    items = [bytes(b2[0x0E0C + 64 * i:0x0E0C + 64 * i + 64]) for i in range(18)]
    hi = b2[0x128C:0x12AC]
    keys = []
    for i in range(8):
        lo = b2[0x12AC + 32 * i:0x12AC + 32 * i + 32]
        keys.append(b"".join(bytes(lo[8 * k:8 * k + 8]) + bytes(hi[8 * k:8 * k + 8])
                             for k in range(4)))
    return [("items", items), ("keys", keys)]


def _icons_svg(icons, px: int = 3, labels=None) -> str:
    """16x16 icons in a row, four tiles each, column-major as the status screen draws them
    (tiles 0 and 2 on top, 1 and 3 below)."""
    paths: dict[int, list[str]] = {1: [], 2: [], 3: []}
    step = 20
    for i, ic in enumerate(icons):
        for k in range(4):
            ox, oy = i * step + (k // 2) * 8, (k % 2) * 8
            lo, hi = ic[16 * k:16 * k + 8], ic[16 * k + 8:16 * k + 16]
            for y in range(8):
                for x in range(8):
                    v = ((lo[y] >> (7 - x)) & 1) | (((hi[y] >> (7 - x)) & 1) << 1)
                    if v:
                        paths[v].append(f"M{ox + x} {oy + y}h1v1h-1z")
    w, h = len(icons) * step - 4, 16 + (8 if labels else 0)
    out = [f'<svg viewBox="0 0 {w} {h}" width="{min(w * px, 780)}" '
           'style="max-width:100%;height:auto;image-rendering:pixelated" '
           'xmlns="http://www.w3.org/2000/svg" font-family="ui-monospace,monospace">']
    for v, op in ((1, "0.34"), (2, "0.67"), (3, "1")):
        if paths[v]:
            out.append(f'<path fill="currentColor" opacity="{op}" d="{"".join(paths[v])}"/>')
    for i, lab in enumerate(labels or []):
        out.append(f'<text x="{i * step + 8}" y="{h - 1}" font-size="5.5" '
                   f'text-anchor="middle" fill="currentColor" opacity="0.7">{_h(lab)}</text>')
    out.append("</svg>")
    return "".join(out)


def _metasprite_svg(sp, cell=16):
    """One metasprite's arrangement: a box per hardware sprite at its real offset."""
    if not sp:
        return ""
    xs = [s[0] for s in sp]
    ys = [s[1] for s in sp]
    x0, y0 = min(xs), min(ys)
    w = (max(xs) + 8 - x0) * cell // 8
    h = (max(ys) + 8 - y0) * cell // 8
    out = [f'<svg viewBox="0 0 {w} {h}" width="{min(w * 2, 260)}" '
           'style="max-width:100%;height:auto;overflow:visible" '
           'xmlns="http://www.w3.org/2000/svg" font-family="ui-monospace,monospace">']
    for x, y, tile, attr in sp:
        if tile == 0xFF:
            continue
        px, py = (x - x0) * cell // 8, (y - y0) * cell // 8
        flip = attr & 0x40
        out.append(f'<rect x="{px}" y="{py}" width="{cell}" height="{cell}" rx="2" '
                   f'fill="currentColor" fill-opacity="{0.20 if flip else 0.10}" '
                   'stroke="currentColor" stroke-opacity="0.55" stroke-width="0.7"/>')
        out.append(f'<text x="{px + cell / 2:.0f}" y="{py + cell / 2 + 3:.0f}" '
                   f'font-size="7" text-anchor="middle" fill="currentColor" '
                   f'opacity="0.9">{tile:02X}{"&#9666;" if flip else ""}</text>')
    out.append("</svg>")
    return "".join(out)


def _graphics_page(rm) -> str:
    from . import gfx

    p = ["<h1>Graphics</h1>",
         '<p class="sub">This cartridge has CHR RAM, so not one byte of the file is a tile as '
         "stored. Everything the PPU draws was written there by code, and finding the writers "
         "is the whole problem.</p>"]
    p.append('<div class="note"><strong>The PPU write surface is closed and it is one '
             "queue.</strong> 31 <code>STA $2007</code> sites and 18 <code>STA $2006</code> "
             "sites in the whole file, all in bank 7, all traced &mdash; and a byte scan of the "
             "entire ROM finds exactly the same ones. An entry is "
             "<code>[count][ppu_hi][ppu_lo][data]</code>, and the count byte's top two bits pick "
             "the type: under <code>$80</code> a run with increment 1, <code>$80-$BF</code> the "
             "same with increment 32, <code>$C0+</code> an attribute read-modify-write.</div>")

    p.append("<h2>The tile codec</h2>")
    p.append('<div class="note"><strong>A block is a stream that toggles between two modes, and '
             "the toggle is a byte the block chooses for itself.</strong> A block begins "
             "<code>[escape][mirror]</code>. Decoding starts in <em>literal</em> mode, where "
             "every byte that is not the escape is one output byte. The escape switches into a "
             "<em>run</em> section, which is a sequence of <code>[value][count]</code> pairs; the "
             "escape switches back. <strong>Two escape bytes in a row &mdash; an empty section, "
             "in either mode &mdash; end the block.</strong> The compressor picks a byte that "
             "does not occur in the block's literal data, which is why the escape differs per "
             "block and why values like <code>$A4</code> and <code>$FD</code> turn up alongside "
             "<code>$01</code>.</div>")
    p.append('<div class="note"><strong>The second header byte is a second escape: mirror.'
             "</strong> Read off the decoder itself, bank 7 <code>$DB52</code>, which the NMI "
             "runs a budgeted number of bytes per frame after <code>$D7F9</code> (entry "
             "<code>$C042</code>, block in A, bank in Y) arms it. The mirror byte is followed "
             "by a pointer; decoding continues from there with every byte <em>bit-reversed</em>"
             " &mdash; a horizontally flipped copy of earlier data &mdash; until the mirror byte "
             "comes round again, whose pointer bytes are then skipped. A run count of 0 means "
             "256. <strong>Correction:</strong> this page used to call the byte not understood, "
             "and three blocks decoded to &ldquo;3 bytes over a whole number of tiles&rdquo;; "
             "those were mirror references emitted as literals.</div>")
    p.append('<div class="note"><strong>Worked example</strong> &mdash; bank 1 '
             "<code>$B76D</code>, inside the block at <code>$B664</code> whose escape is "
             "<code>$0A</code>:<pre><code>0A  FF 04  1F 01  00 03  0A\n"
             " |   \\___/  \\___/  \\___/   |\n"
             " |   FF x4  1F x1  00 x3   back to literal mode\n"
             " into run mode</code></pre>Eight source bytes become the eight output bytes "
             "<code>FF FF FF FF 1F 00 00 00</code>.</div>")

    by_id = {r["id"]: r for r in rm.regions}
    counts = {}
    for bank in sorted(gfx.TABLES):
        bl = gfx.blocks(rm.prg_bank(bank), bank)
        counts[bank] = (len(bl), sum(b["size"] for b in bl),
                        sum(len(b["tiles"]) for b in bl))
    ti = sum(v[1] for v in counts.values())
    to = sum(v[2] for v in counts.values())
    p.append("<table><thead><tr><th>Bank</th><th>Blocks</th><th>ROM bytes</th>"
             "<th>Tile bytes</th><th>Tiles</th><th>Ratio</th></tr></thead><tbody>")
    for bank, (n, bi, bo) in counts.items():
        p.append(f'<tr><td><a href="bank{bank}.html">bank {bank}</a></td><td>{n}</td>'
                 f"<td>{bi:,}</td><td>{bo:,}</td><td>{bo // 16:,}</td>"
                 f"<td>{bo / bi:.2f}x</td></tr>")
    p.append(f"<tr><th>total</th><th>{sum(v[0] for v in counts.values())}</th>"
             f"<th>{ti:,}</th><th>{to:,}</th><th>{to // 16:,}</th>"
             f"<th>{to / ti:.2f}x</th></tr></tbody></table>")

    p.append('<div class="note"><strong>Three things check this, and they are '
             "independent.</strong> <em>The partition:</em> every block's decoded length ends "
             "exactly on the next pointer in its bank's table &mdash; 21 of 22 in bank 1, 29 of "
             "29 in bank 2, 50 of 50 in bank 3. The terminator rule was worked out on four "
             "blocks and then predicted the other ninety-seven. <em>The escape is forced:</em> "
             "brute-forcing all 256 possible escape values against that test leaves exactly one "
             "survivor for 14 of bank 1's blocks, and it is header byte 1 every time. "
             "<em>Hardware:</em> decoding these blocks out of the ROM reproduces "
             "<strong>398 of the 512 tiles</strong> of an in-game savestate's live CHR RAM, byte "
             "for byte, with 16 more blank.</div>")

    for bank in sorted(gfx.TABLES):
        data = rm.prg_bank(bank)
        p.append(f'<h3 id="gfx-bank{bank}">Bank {bank} &mdash; {counts[bank][0]} blocks</h3>')
        for b in gfx.blocks(data, bank):
            rid = f"bank{bank}.gfx_{b['addr']:04X}"
            reg = by_id.get(rid)
            n = len(b["tiles"])
            conf = reg["confidence"] if reg else "lead"
            p.append(f'<div class="card" id="{_h(rid)}">')
            p.append(f'<h4><code>${b["addr"]:04X}</code> &mdash; {n // 16} tiles'
                     + (f" + {n % 16} B" if n % 16 else "")
                     + f' <span class="tag" style="background:{KIND_COLOURS["graphics"]}">'
                     f'graphics</span> <span class="conf {conf}">{conf}</span></h4>')
            p.append(f'<p class="meta"><code>{_h(rid)}</code> &middot; escape '
                     f'<code>${b["esc"]:02X}</code> &middot; header byte 2 '
                     f'<code>${b["hdr2"]:02X}</code> &middot; {b["size"]:,} ROM bytes &rarr; '
                     f"{n:,} &middot; {n / b['size']:.2f}x &middot; "
                     + ("named by the table" if b["in_table"] else "chained, not in a table")
                     + "</p>")
            p.append(f'<div style="margin:12px 0">{_tiles_svg(b["tiles"])}</div>')
            if reg:
                p.append(f'<p class="desc">{_h(reg["description"])}</p>')
            p.append("</div>")

    p.append("<h2>Icons</h2>")
    p.append('<p class="sub">Not compressed and not in any pointer table: two small sets in '
             "bank 2, each with its own uploader, which the status screen and the item screens "
             "call. Found by reading the status screen, "
             '<a href="status.html">written up there</a>.</p>')
    ic = dict(_icons(rm))
    p.append('<div class="card"><h4>Items, <code>$8E0C</code> &mdash; 0-11 weapons, 12-17 '
             "other</h4>" + _icons_svg(ic["items"], labels=[str(i) for i in range(18)])
             + '<h4>Keys, <code>$92AC</code> + shared plane <code>$928C</code> &mdash; 0 is '
             "the empty frame, 1-7 the seven keys</h4>"
             + _icons_svg(ic["keys"], labels=[str(i) for i in range(8)]) + "</div>")
    for r in [x for x in rm.regions if x.get("codec") in ICON_CODECS]:
        p.append(f'<div class="card" id="{_h(r["id"])}">')
        p.append(f'<h3>{_h(r["name"])} '
                 f'<span class="tag" style="background:{KIND_COLOURS["graphics"]}">graphics</span>'
                 f' <span class="conf {r["confidence"]}">{_h(r["confidence"])}</span></h3>')
        p.append(f'<p class="meta"><code>{_h(r["id"])}</code> &middot; bank {r["prg_bank"]} '
                 f'${r["cpu_addr"]:04X}-${r["cpu_addr"] + r["size"] - 1:04X} &middot; '
                 f'{r["size"]:,} bytes &middot; codec <code>{_h(r["codec"])}</code></p>')
        p.append(f'<p class="desc">{_h(r["description"])}</p></div>')

    p.append("<h2>The font</h2>")
    for r in [x for x in rm.regions if x.get("codec") == "font_1bpp_7byte"]:
        body = rm.rom[r["offset"]:r["end"]]
        p.append(f'<div class="card" id="{_h(r["id"])}">')
        p.append(f'<h3>{_h(r["name"])} '
                 f'<span class="tag" style="background:{KIND_COLOURS["graphics"]}">graphics</span>'
                 f' <span class="conf confirmed">confirmed</span></h3>')
        p.append(f'<p class="meta"><code>{_h(r["id"])}</code> &middot; bank {r["prg_bank"]} '
                 f'${r["cpu_addr"]:04X}-${r["cpu_addr"] + r["size"] - 1:04X} &middot; '
                 f'{r["size"]:,} bytes &middot; codec <code>{_h(r.get("codec", "?"))}</code></p>')
        p.append(f'<div style="margin:16px 0">{_glyphs(bytes(body))}</div>')
        p.append(f'<p class="desc">{_h(r["description"])}</p></div>')

    # ------------------------------------------------------------------ metasprites
    from tgl import metasprite as msp
    b7 = rm.prg_bank(7)
    ptrs = msp.pointers(b7)
    good = [(i, msp.parse(b7, q)) for i, q in enumerate(ptrs)]
    good = [(i, m) for i, m in good if m]
    seen, uniq = set(), []
    for i, m in good:
        if m["addr"] not in seen:
            seen.add(m["addr"])
            uniq.append((i, m))
    tabs = {m["offsets"] for _, m in uniq if m["pairs"]}
    mirrored = sum(1 for _, m in uniq if m["mirror"])

    p.append("<h2>Metasprites</h2>")
    p.append('<p class="sub">A tile is 8 by 8 pixels, so anything bigger than that is '
             "several hardware sprites placed together. This is the table that says "
             "which.</p>")
    p.append('<div class="note"><strong>A split pointer table at <code>$C28D</code> (low) '
             "and <code>$C319</code> (high), 140 entries, indexed by an object's "
             "<code>$0548,X</code>.</strong> A record is "
             "<code>[count][offsets lo][offsets hi][tiles&hellip;][attributes&hellip;]</code>, "
             "drawn by <code>$CC46</code>. Three things make it compact:"
             "<ul><li><strong>Bit 7 of the count means draw it twice, mirrored.</strong> "
             "<code>$CC4A</code> flips bit 6 of the attribute, draws, flips back and draws "
             f"again &mdash; so a symmetrical enemy costs half the data. {mirrored} records "
             "use it.</li>"
             "<li><strong>Tile numbers are relative.</strong> <code>$CE03</code> adds the "
             "object's own base tile in <code>$87</code>, so one record is a shape that any "
             "number of objects can wear. <code>$FF</code> skips a sprite.</li>"
             "<li><strong>The attribute array is run-length coded.</strong> "
             "<code>$CE23</code> advances it only when bit 3 of the byte is clear, so one "
             "byte can cover several sprites &mdash; which is why a record's length does "
             "not follow from its count.</li></ul>"
             f"The (x, y) offset tables are shared: {len(uniq)} metasprites use only "
             f"{len(tabs)} of them.</div>")
    p.append('<div class="note warn"><strong>Nothing in the code bounds the sprite count '
             "&mdash; the data does.</strong> <code>$CC80</code> is "
             "<code>JSR $CDD7 / DEC $8F / BNE</code> with no limit. Across the records the "
             "counts run <strong>1 to 25</strong> and then jump straight to 112, 116 and "
             "124, a gap of 87. Those four are the only ones whose bytes collide with an "
             "already-claimed region, and one of them is entry 0, which "
             "<code>BEQ $CC44</code> proves is never read. So they are not metasprites, and "
             f"{len(ptrs)} table entries give {len(uniq)} real ones.</div>")

    p.append("<h4>A few of them, drawn at their real offsets</h4>")
    p.append('<div class="envs" style="grid-template-columns:repeat(auto-fill,minmax(170px,1fr))">')
    for i, m in sorted(uniq, key=lambda x: -x[1]["count"])[:12]:
        sp = msp.sprites(m)
        p.append(f'<figure class="env">{_metasprite_svg(sp)}'
                 f'<figcaption><strong>{i}</strong> <code>${m["addr"]:04X}</code> &middot; '
                 f'{m["count"]} sprites{" &middot; mirrored" if m["mirror"] else ""}'
                 "</figcaption></figure>")
    p.append("</div>")
    p.append('<p class="meta">Each box is one hardware sprite; the number is its tile '
             "offset from the object's base tile, and &#9666; marks one drawn horizontally "
             "flipped. These are arrangements, not pictures &mdash; the actual tiles depend "
             "on whatever the object's base tile is at the time.</p>")

    # ---- which object wears which
    b6 = rm.prg_bank(6)
    rows = msp.object_map_rm(rm)
    valid = {i for i, q in enumerate(ptrs) if msp.parse(b7, q)}
    reached6 = set()
    for r in rows:
        reached6 |= r["ids"]
        for v in r["tables"].values():
            reached6 |= set(v)
    # writers outside bank 6, found by byte scan for STA $0548 preceded by LDA
    extra = set()
    rom = rm.rom
    prgo, bsz = rm.meta["prg_offset"], rm.meta["prg_bank_size"]
    for i in range(len(rom) - 2):
        if rom[i] in (0x9D, 0x99, 0x8D) and rom[i + 1] == 0x48 and rom[i + 2] == 0x05:
            bk = (i - prgo) // bsz
            if bk == 6:
                continue
            if rom[i - 2] == 0xA9:
                extra.add(rom[i - 1])
            elif rom[i - 3] in (0xB9, 0xBD):
                tab = rom[i - 2] | (rom[i - 1] << 8)
                d = rm.prg_bank(bk)
                o = tab - (0xC000 if bk == 7 else 0x8000)
                n = 0
                while 0 <= o + n < len(d) and d[o + n] in valid and n < 32:
                    n += 1
                extra |= set(d[o:o + n])
    allr = (reached6 | extra) & valid
    hit = sum(1 for r in rows if r["ids"] or r["tables"])

    pal = [x for x in rm.regions if x["kind"] == "palette"]
    if pal:
        p.append("<h2>Palettes</h2>")
        r = pal[0]
        body = rm.rom[r["offset"]:r["end"]]
        p.append('<div class="note"><strong>Thirty-seven palettes of three colours, and the '
                 "reader states the layout rather than leaving it to be inferred.</strong> "
                 "<code>$B2E4</code> does <code>ASL A / ADC $11 / TAX</code> to make "
                 "<code>X = A &times; 3</code>, then reads <code>$B30A,X</code>, "
                 "<code>$B30B,X</code> and <code>$B30C,X</code> into the palette staging "
                 "area at <code>$0181</code>. Colour 0 is not here: it comes from "
                 "<code>$0180</code>, the shared backdrop, which is why a record is three "
                 "bytes and not four.</div>")
        p.append('<div class="note warn"><strong>The extent lands on a record '
                 "boundary.</strong> Every byte from <code>$B30A</code> is a legal NES "
                 "colour for exactly 111 bytes &mdash; <strong>37 records of three with "
                 "nothing left over</strong> &mdash; and the first byte past it is "
                 "<code>$93</code>. A limit that falls on a record edge by accident is a "
                 "one-in-three coincidence. <em>Which palette is used where is not "
                 "established.</em></div>")
        p.append('<div class="pals">')
        for k in range(len(body) // 3):
            trio = body[3 * k:3 * k + 3]
            sw = "".join(
                f'<span class="sw" style="background:rgb{NES_RGB[c & 0x3F]};'
                f'color:{"#000" if sum(NES_RGB[c & 0x3F]) > 340 else "#fff"}">{c:02X}</span>'
                for c in trio)
            p.append(f'<div class="pal"><div class="palh">{k} &middot; '
                     f'${r["cpu_addr"] + 3 * k:04X}</div>'
                     f'<div class="palrow"><span class="palgrp">'
                     f'<span class="sw" style="background:repeating-linear-gradient('
                     f'45deg,#8884,#8884 3px,#0000 3px,#0000 6px);font-size:9px">bg</span>'
                     f'{sw}</span></div></div>')
        p.append("</div>")
        p.append(f'<div class="card" id="{_h(r["id"])}">')
        p.append(f'<h3>{_h(r["name"])} <span class="tag" '
                 f'style="background:{KIND_COLOURS["palette"]}">palette</span> '
                 f'<span class="conf {r["confidence"]}">{_h(r["confidence"])}</span></h3>')
        p.append(f'<p class="meta"><code>{_h(r["id"])}</code> &middot; bank '
                 f'{r["prg_bank"]} ${r["cpu_addr"]:04X}-'
                 f'${r["cpu_addr"] + r["size"] - 1:04X} &middot; {r["size"]:,} bytes</p>')
        p.append(f'<p class="desc">{_h(r["description"])}</p></div>')

    p.append("<h2>Which object wears which</h2>")
    p.append('<div class="note"><strong>An object&rsquo;s metasprite is whatever its '
             "behaviour handler puts in <code>$0548,X</code>.</strong> Bank 6 dispatches on "
             "the object type, so walking each of the 127 handlers and collecting its "
             f"stores gives the map. <strong>{hit} of 127 types</strong> resolve to at "
             "least one metasprite. Most do it through an <em>animation table</em> &mdash; "
             "<code>LDA table,Y / STA $0548,X</code> &mdash; so a type owns a cycle of "
             "shapes rather than one.</div>")
    p.append('<div class="note warn"><strong>Two limits worth stating.</strong> An '
             "animation table is bounded only by the first byte that is not a valid "
             "metasprite id, which is <em>weak</em>: valid ids cover most byte values, so a "
             "long run may have walked past the table&rsquo;s end. And handlers share "
             "subroutines, so a store reached from several handlers is attributed to all of "
             "them &mdash; which is right, but it is not evidence that each one uses it."
             f" Counting bank 6 and the writers in banks 1, 2, 3 and 7 together, "
             f"<strong>{len(allr)} of {len(valid)}</strong> table entries are reached by "
             f"some writer and <strong>{len(valid) - len(allr)}</strong> are not.</div>")
    p.append('<div class="scroll"><table><thead><tr><th>Type</th><th>Handler</th>'
             "<th>Metasprites</th></tr></thead><tbody>")
    for r in rows:
        if not r["ids"] and not r["tables"]:
            continue
        cells = []
        if r["ids"]:
            cells.append("fixed " + ", ".join(str(i) for i in sorted(r["ids"])))
        for a, v in sorted(r["tables"].items()):
            cells.append(f'anim <code>${a:04X}</code> '
                         + ("&rarr; " + " ".join(str(x) for x in v) if v
                            else "<em>(empty &mdash; first byte is not an id)</em>"))
        p.append(f'<tr><td><code>${r["type"]:02X}</code>{_tn(r["type"])}</td>'
                 f'<td><code>${r["handler"]:04X}</code></td>'
                 f'<td>{" &middot; ".join(cells)}</td></tr>')
    p.append("</tbody></table></div>")

    for r in [x for x in rm.regions if x.get("codec") == "metasprite"]:
        p.append(f'<div class="card" id="{_h(r["id"])}">')
        p.append(f'<h3>{_h(r["name"])} '
                 f'<span class="tag" style="background:{KIND_COLOURS["graphics"]}">'
                 f'graphics</span> <span class="conf {r["confidence"]}">'
                 f'{_h(r["confidence"])}</span></h3>')
        p.append(f'<p class="meta"><code>{_h(r["id"])}</code> &middot; bank '
                 f'{r["prg_bank"]} ${r["cpu_addr"]:04X}-'
                 f'${r["cpu_addr"] + r["size"] - 1:04X} &middot; {r["size"]:,} bytes</p>')
        p.append(f'<p class="desc">{_h(r["description"])}</p></div>')

    p.append('<div class="note"><strong>Bank 0 has a table after all: <code>$8030</code>, two '
             "entries.</strong> <code>$D7F9</code> takes each bank's table base from "
             "<code>$D842</code>/<code>$D84A</code>, and bank 0's is <code>$8030</code>, "
             "naming <code>$8BBB</code> and <code>$8D90</code>. They end exactly on "
             "<code>$917C</code>, the sound driver's per-frame entry, and reproduce "
             "<strong>38 of 38 and 128 of 128</strong> tiles of a title-screen savestate's live "
             "CHR &mdash; which takes the title screen from 18 to 181 of 512 explained. "
             "<strong>Correction:</strong> this note used to say bank 0 had no table and that "
             "the code running the codec had not been found. It was in the traced code all "
             "along, unrecognised.</div>")
    return "".join(p)


# --------------------------------------------------------------------------- entry point

CHAN_COLOURS = ("#4fb0f2", "#ed64a6", "#38c172", "#ecc94b", "#f2704f", "#9d7cf8", "#38b2ac")


def _roll_svg(tracks, height=150):
    """A piano roll: x is the track's own clock in frames, y is pitch."""
    notes = [(ci, t, n, l) for ci, rows in tracks for t, n, l in rows]
    if not notes:
        return ""
    span = max(t + l for _, t, _, l in notes)
    lo = min(n for _, _, n, _ in notes)
    hi = max(n for _, _, n, _ in notes)
    rng = max(hi - lo + 1, 8)
    w = 900
    rh = max(2.0, min(6.0, height / rng))
    h = rng * rh
    out = [f'<svg viewBox="0 0 {w} {h:.0f}" width="100%" '
           f'style="max-width:100%;height:auto;display:block" '
           'xmlns="http://www.w3.org/2000/svg">']
    for ci, tt, n, l in notes:
        x = w * tt / span
        ww = max(1.2, w * l / span - 0.5)
        y = (hi - n) * rh
        out.append(f'<rect x="{x:.1f}" y="{y:.1f}" width="{ww:.1f}" height="{rh:.1f}" '
                   f'rx="0.6" fill="{CHAN_COLOURS[ci % len(CHAN_COLOURS)]}" opacity="0.85"/>')
    out.append("</svg>")
    return "".join(out)


def _env_svg(values, signed=False):
    """One envelope as a bar chart. Signed envelopes are drawn about a centre line."""
    body = values[:-1] if values and values[-1] & 0x80 else values
    if not body:
        return ""
    if signed:
        vals = [v - 256 if v > 127 else v for v in body]
        peak = max(1, max(abs(v) for v in vals))
        bars = []
        for v in vals:
            up = v > 0
            frac = abs(v) / peak
            bars.append(f'<div style="flex:1;min-width:2px;display:flex;'
                        f'flex-direction:column;justify-content:center;height:100%">'
                        f'<div style="height:{50 * (frac if up else 0):.0f}%"></div>'
                        f'<div class="bar1" style="height:{50 * frac:.0f}%;'
                        f'align-self:stretch"></div>'
                        f'<div style="height:{50 * (0 if up else frac):.0f}%"></div></div>')
        return f'<div class="envbars">{"".join(bars)}</div>'
    bars = "".join(f'<div class="bar1" style="height:{100 * v / 15:.0f}%"></div>'
                   for v in body)
    return f'<div class="envbars">{bars}</div>'


def _sound_page(rm) -> str:
    import math
    import sys
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
    from tgl import sound

    b0 = rm.prg_bank(0)
    p = ["<h1>Sound</h1>",
         '<p class="sub">Bank 0 is the sound bank. Three of its nine entry slots are audio, '
         "and one of them runs every frame from the NMI handler.</p>"]

    p.append('<div class="note"><strong>Seven soft channels compete for four hardware '
             "ones.</strong> Per-channel state is a structure of arrays in page 3: field "
             "<em>f</em> of channel <em>c</em> lives at <code>$0319 + 7f + c</code>, so the "
             "stride is 7 and the channel index is the offset. <code>$97E4</code> copies "
             "nine of those fields straight out of a song header; fields 7 and 8 are the "
             "track's stream pointer. Field 6 says which of the four hardware channels the "
             "voice wants, and <code>$0306</code> is the busy mask over them &mdash; that is "
             "the whole allocator. Output goes to a 16-byte APU shadow at "
             "<code>$0308-$0317</code>, flushed by <code>LDA $0308,X / STA $4000,X</code>; a "
             "shadow byte of <code>$FF</code> means do not write that register this "
             "frame.</div>")

    p.append("<h2>The stream format</h2>")
    p.append("<table><thead><tr><th>Byte</th><th>Meaning</th></tr></thead><tbody>"
             "<tr><td><code>$00-$7F</code></td><td>A note. A duration byte may follow. "
             "<code>$00</code> is a rest &mdash; it advances the clock and sounds "
             "nothing.</td></tr>"
             "<tr><td><code>$80-$94</code></td><td>One of 21 commands &mdash; the table "
             "below.</td></tr>"
             "<tr><td><code>$95-$AF</code></td><td><em>Hole.</em> Would index past the "
             "21-entry dispatch table.</td></tr>"
             "<tr><td><code>$B0-$DF</code></td><td><em>Hole.</em> Would advance the stream "
             "pointer by zero &mdash; an infinite loop.</td></tr>"
             "<tr><td><code>$E0-$FF</code></td><td>Repeat the previous note with this "
             "duration. <code>$E0</code> takes a literal byte; the rest index the duration "
             "table.</td></tr></tbody></table>")

    census: dict[int, int] = {}
    songs = []
    for i, addr in enumerate(sound.song_pointers(b0, 72)):
        h = sound.parse_header(b0, addr)
        if h["kind"] == "code":
            songs.append((i, addr, h, []))
            continue
        rows = []
        for tr in h["tracks"]:
            if tr["stream"] is None:
                continue
            w = sound.walk_track(b0, tr["stream"])
            for k, v in w["census"].items():
                census[k] = census.get(k, 0) + v
            rows.append((tr, w, sound.roll(b0, tr["stream"])))
        songs.append((i, addr, h, rows))

    tracks = sum(len(r) for _, _, _, r in songs)
    notes = sum(w["notes"] for _, _, _, r in songs for _, w, _ in r)
    loops = sum(1 for _, _, _, r in songs for _, w, _ in r if w.get("loops"))
    p.append('<div class="note"><strong>The holes are counted, not assumed.</strong> '
             f"Walking all {tracks} tracks in the ROM byte by byte meets "
             f"{sum(census.values()):,} command bytes, and "
             f"<strong>{sum(v for k, v in census.items() if not 0x80 <= k <= 0x94)}</strong> "
             "of them fall in either hole. Every one of those tracks reaches an "
             f"unconditional terminator, {loops} of them a jump back to a loop point, for "
             f"{notes:,} notes in total. A single wrong operand length would desynchronise a "
             "walk and send it off into the next track's bytes, so this is a check and not a "
             "restatement.</div>")

    # ---------------------------------------------------------------- period table
    per = sound.periods(b0)
    hz = [sound.period_hz(x) for x in per]
    ratios = [hz[i + 12] / hz[i] for i in range(0, len(hz) - 12, 12)]
    neigh = [hz[i + 1] / hz[i] for i in range(60)]
    mean = sum(neigh) / len(neigh)
    p.append("<h2>The period table is equal-tempered, and that is checkable</h2>")
    p.append('<div class="note"><strong>The note names below are not a guess about what '
             "sounds right &mdash; they are read off the frequencies the table actually "
             "produces.</strong> A pulse channel runs at "
             "<code>1789773 / (16 &times; (period + 1))</code> Hz. Taking the 108 entries at "
             f"<code>$985A</code> and doing that arithmetic: the ratio between neighbours "
             f"averages <strong>{mean:.5f}</strong> against 2<sup>1/12</sup> = "
             f"{2 ** (1 / 12):.5f}, and the frequency doubles every twelve entries "
             + ", ".join(f"{r:.4f}" for r in ratios[:6])
             + ". So the table is one entry per semitone. Entry 0 is "
             f"<strong>{hz[0]:.2f} Hz</strong>, which is A1, and that fixes the whole "
             "scale. The read is based at <code>$9840</code> with index "
             "<code>(note + transpose) &times; 2</code>, so a note plus transpose of 13 "
             "selects entry 0.</div>")
    p.append("<table><thead><tr><th>Entry</th><th>note+transpose</th><th>Period</th>"
             "<th>Frequency</th><th>Note</th></tr></thead><tbody>")
    for i in list(range(0, 13)) + [24, 36, 48, 60, 72, 84, 96, 107]:
        p.append(f"<tr><td>{i}</td><td>{i + sound.FIRST_INDEX}</td>"
                 f"<td><code>${per[i]:03X}</code></td><td>{hz[i]:,.1f} Hz</td>"
                 f"<td><strong>{sound.note_name(i + sound.FIRST_INDEX)}</strong></td></tr>")
    p.append("</tbody></table>")
    p.append('<div class="note warn"><strong>One loose end.</strong> Note bytes as low as '
             "<code>$01</code> occur, and at transpose 0 those index below the table into "
             "bytes that are not periods. So a track using them must carry a positive "
             "transpose &mdash; <code>$86</code> values of <code>+1</code> to <code>+12</code> "
             "do occur. That the two always line up is <em>not</em> checked here.</div>")

    # ---------------------------------------------------------------- commands
    p.append("<h2>Commands</h2>")
    p.append("<table><thead><tr><th>Byte</th><th>Name</th><th>Operands</th><th>Seen</th>"
             "<th>Handler</th></tr></thead><tbody>")
    for b in sorted(sound.COMMANDS):
        name, ops, desc = sound.COMMANDS[b]
        p.append(f"<tr><td><code>${b:02X}</code></td><td>{_h(name)}</td><td>{ops}</td>"
                 f'<td>{census.get(b, 0)}</td><td class="mono">{_h(desc)}</td></tr>')
    p.append("</tbody></table>")
    p.append('<div class="note warn"><strong>The names in that table are inferred from what '
             "each handler stores, not confirmed by listening.</strong> "
             "<code>$8C</code> writes the fields a vibrato would and is called vibrato here; "
             "that is an argument, not a measurement. The operand counts are the solid part "
             "&mdash; those are forced by the walk.</div>")

    # ---------------------------------------------------------------- envelopes
    p.append("<h2>Envelopes</h2>")
    p.append('<p class="sub">Per-frame shapes the driver steps through under each note. '
             "Both kinds end at the first byte with bit 7 set; what that byte's low bits "
             "mean is not established.</p>")
    p.append("<h4>Volume &mdash; 12 of them, pointers at <code>$99AD</code></h4>")
    p.append('<div class="envs">')
    for k, a in enumerate(sound.envelope_pointers(b0, sound.VOL_ENVELOPES, 12), start=1):
        e = sound.envelope(b0, a)
        p.append(f'<figure class="env">{_env_svg(e)}'
                 f'<figcaption><strong>{k}</strong> <code>${a:04X}</code> &middot; '
                 f"{len(e)} steps</figcaption></figure>")
    p.append("</div>")
    p.append("<h4>Pitch &mdash; 4 of them, pointers at <code>$9961</code></h4>")
    p.append('<div class="envs">')
    for k, a in enumerate(sound.envelope_pointers(b0, sound.PITCH_ENVELOPES, 4), start=1):
        e = sound.envelope(b0, a)
        p.append(f'<figure class="env">{_env_svg(e, signed=True)}'
                 f'<figcaption><strong>{k}</strong> <code>${a:04X}</code> &middot; '
                 f"{len(e)} steps</figcaption></figure>")
    p.append("</div>")

    # ---------------------------------------------------------------- DMC
    p.append("<h2>The DMC is a timer, not a voice</h2>")
    p.append('<div class="note"><strong>There is no sampled audio in this ROM.</strong> '
             "The DMC registers are written once, at bank 6 <code>$802A</code>: "
             "<code>$4010 = $81</code> (IRQ enabled, rate 1), <code>$4011 = $00</code>, "
             "<code>$4012 = $FF</code> and <code>$4013 = $01</code> &mdash; a 17-byte sample "
             "at <code>$FFC0</code>. <strong>Those 17 bytes are all zero</strong>, so the "
             "channel emits nothing. What it does instead is fire an IRQ: the handler at "
             "<code>$DCF3</code> acknowledges it with <code>$4015 = $0F</code>, polls sprite "
             "0 through <code>BIT $2002</code> against the frame counter in <code>$2B</code>, "
             "and restarts the timer from <code>$05</code> &mdash; nudging that rate index up "
             "and down between <code>$81</code> and <code>$89</code> to converge on the "
             "split. It is a self-calibrating mid-frame raster interrupt wearing the DMC's "
             "clothes.</div>")

    # ---------------------------------------------------------------- songs
    p.append("<h2>Songs</h2>")
    p.append('<p class="sub">Every song in the ROM, drawn from its own bytes. In each roll '
             "the horizontal axis is the track&rsquo;s clock in frames and the vertical axis "
             "is pitch; colour is the soft channel. These are the notes as stored &mdash; "
             "the driver divides the clock again per channel, so the width is relative and "
             "not seconds.</p>")
    for i, addr, h, rows in songs:
        if h["kind"] == "code":
            p.append(f'<div class="card"><h3>Song {i} '
                     f'<span class="conf lead">code, not a song</span></h3>'
                     f'<p class="meta"><code>${addr:04X}</code> begins with a zero byte, so '
                     f"$97E4 pushes the pointer and RTSes to ${h['target']:04X} instead of "
                     f"reading a header. What that code does is not established.</p></div>")
            continue
        if not rows:
            continue
        n = sum(w["notes"] for _, w, _ in rows)
        span = max((r[-1][0] + r[-1][2]) for _, _, r in rows if r) if any(r for _, _, r in rows) else 0
        p.append(f'<div class="card"><h3>Song {i}</h3>')
        p.append(f'<p class="meta"><code>${addr:04X}</code> &middot; {len(rows)} tracks '
                 f"&middot; {n:,} notes &middot; {span:,} frames long</p>")
        p.append(_roll_svg([(tr["channel"], r) for tr, _, r in rows]))
        legend = " ".join(
            f'<span class="ch" style="color:{CHAN_COLOURS[tr["channel"] % 7]}">'
            f'ch{tr["channel"]}&rarr;hw{tr["hw"]} '
            f'${tr["stream"]:04X} {w["notes"]}n{" loop" if w.get("loops") else ""}</span>'
            for tr, w, _ in rows)
        p.append(f'<p class="meta" style="margin-top:8px">{legend}</p></div>')

    # ---------------------------------------------------------------- regions
    p.append("<h2>Regions</h2>")
    for r in [x for x in rm.regions if x["kind"] == "music"
              or (x["prg_bank"] == 0 and x["cpu_addr"] is not None
                  and 0x932C <= x["cpu_addr"] <= 0x9B93
                  and x["kind"] in ("pointer_table", "data"))]:
        p.append(f'<div class="card" id="{_h(r["id"])}">')
        p.append(f'<h3>{_h(r["name"])} '
                 f'<span class="tag" style="background:'
                 f'{KIND_COLOURS.get(r["kind"], DEFAULT_COLOUR)}">{_h(r["kind"])}</span> '
                 f'<span class="conf {r["confidence"]}">{_h(r["confidence"])}</span></h3>')
        p.append(f'<p class="meta"><code>{_h(r["id"])}</code> &middot; bank '
                 f'{r["prg_bank"]} ${r["cpu_addr"]:04X}-'
                 f'${r["cpu_addr"] + r["size"] - 1:04X} &middot; {r["size"]:,} bytes</p>')
        p.append(f'<p class="desc">{_h(r["description"])}</p></div>')
    return "".join(p)


# The on-screen grid, as the password savestate's nametable shows it: five columns, a gap,
# five more, and the three controls on the last row. Row and column here are the layout, and
# the index is what $88F2 stores.
# Seven rows of ten, with the screen's gap after the fifth column. Lowercase letters are
# drawn with two dots above them on screen, which the page shows as a diaeresis.
GRID_ROWS = ("ABCDE FGHIJ", "KLMNO PQRST", "UVWXY Z0123", "abcde fghij", "klmno pqrst",
             "uvwxy z4567", "89!?")
CONTROLS = ("FR", "BA", "END")


def _grid_table(alphabet):
    out = ['<table style="width:auto;text-align:center"><tbody>']
    i = 0
    for row in GRID_ROWS:
        cells = []
        for c in row:
            if c == " ":
                cells.append('<td style="border:none;padding:4px 10px"></td>')
                continue
            cells.append(
                '<td style="border:none;padding:4px 10px">'
                f'<div style="font-weight:600;font-size:16px">'
                f'{c + chr(0x308) if c.islower() else c}</div>'
                f'<div style="color:var(--dim);font-size:11px;font-family:ui-monospace,'
                f'monospace">{alphabet.index(c)}</div></td>')
            i += 1
        out.append("<tr>" + "".join(cells) + "</tr>")
    out.append('<tr><td colspan="11" style="border:none;padding:8px 10px 0;'
               'color:var(--dim);font-size:12px">'
               + " &middot; ".join(f"<code>{c}</code>" for c in CONTROLS)
               + " &mdash; forward, back, end. Not characters.</td></tr>")
    out.append("</tbody></table>")
    return "".join(out)


def _packing_svg():
    """Four six-bit characters shifted into three bytes, drawn to scale."""
    w, bit = 760, 30
    h = 150
    cols = ("#4fb0f2", "#ed64a6", "#38c172", "#ecc94b")
    out = [f'<svg viewBox="0 0 {w} {h}" width="100%" style="max-width:100%;height:auto" '
           'xmlns="http://www.w3.org/2000/svg" font-family="ui-monospace,monospace">']
    ox = 20
    out.append(f'<text x="0" y="22" font-size="12" fill="currentColor" opacity=".65">'
               '4 characters, 6 bits each</text>')
    for k in range(4):
        x = ox + k * 6 * bit
        out.append(f'<rect x="{x}" y="32" width="{6 * bit - 4}" height="34" rx="4" '
                   f'fill="{cols[k]}" opacity="0.8"/>')
        out.append(f'<text x="{x + 3 * bit - 2}" y="54" font-size="13" text-anchor="middle" '
                   f'fill="#fff">char {k} &#183; 6 bits</text>')
    out.append(f'<text x="0" y="98" font-size="12" fill="currentColor" opacity=".65">'
               '3 bytes, 8 bits each</text>')
    for k in range(3):
        x = ox + k * 8 * bit
        out.append(f'<rect x="{x}" y="108" width="{8 * bit - 4}" height="34" rx="4" '
                   'fill="none" stroke="currentColor" stroke-opacity=".45"/>')
        out.append(f'<text x="{x + 4 * bit - 2}" y="130" font-size="13" text-anchor="middle" '
                   'fill="currentColor">byte ' + str(k) + '</text>')
    # the boundaries that do not line up are the point of the picture
    for b in (6, 12, 18):
        x = ox + b * bit - 2
        out.append(f'<line x1="{x}" y1="66" x2="{x}" y2="108" stroke="currentColor" '
                   'stroke-dasharray="3 3" stroke-opacity=".5"/>')
    out.append("</svg>")
    return "".join(out)


def _password_page(rm):
    import random
    import sys
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
    from tgl import password as pw

    b3 = rm.prg_bank(3)
    tgl = list(b3[pw.TGL_CONST - 0x8000:pw.TGL_CONST - 0x8000 + 3])
    word = "".join(pw.ALPHABET[x] for x in tgl)

    p = ["<h1>Password</h1>",
         '<p class="sub">Thirty-two characters, six bits each, a running XOR key and a '
         "checksum &mdash; and a back door that skips all of it.</p>"]

    p.append('<div class="note"><strong>A character is stored as its position on the grid, '
             "not as a letter.</strong> <code>$88F2</code> is <code>LDX $17 / LDA $16 / "
             "STA $0411,X</code>, and <code>$16</code> holds the cursor's grid index. So "
             "<strong>A is 0</strong>, T is 19, <code>0</code> is 26, <code>a</code> is 30 "
             "and <code>?</code> is 63 &mdash; <strong>64 values, exactly six bits</strong>. "
             "The layout is read off the nametable of a savestate taken on the password "
             "screen; lowercase letters are tiles <code>$81-$9A</code>, drawn under a row "
             "of <code>$AE</code> dots, so on screen they carry an umlaut.</div>")
    p.append('<div class="note warn"><strong>Correction.</strong> This page used to show '
             "a 36-character grid, A-Z and 0-9, with 4-9 at 30-35. The savestate had seven "
             "rows and only three were read; 4-9 are 56-61. It was a scanned manual, whose "
             "former owner wrote passwords full of umlauted letters, that prompted the "
             'second look (<a href="external.html">outside sources</a>).</div>')
    p.append(_grid_table(pw.ALPHABET))

    p.append('<div class="note warn"><strong>A blank and the letter A are the same '
             "byte.</strong> A's grid index is 0, and the savestate shows an untouched "
             "entry field is all <code>$00</code>. Nothing in the field distinguishes "
             '"not typed" from "typed an A". That matters below. <em>This is what the code '
             "says; it was not tried on hardware.</em></div>")

    p.append("<h2>How a password decodes</h2>")
    p.append('<p class="sub">All of this is read off <code>$8516</code> in bank 3, which is '
             "the bank the password screen runs with live &mdash; the savestate's mapper "
             "latch reads <code>$83</code>.</p>")

    p.append("<h3>1. The seed comes out of the last two characters</h3>")
    p.append("<pre><code>seed = ((char[31] &lt;&lt; 2) | (char[30] &gt;&gt; 4)) + $1D"
             "      ; $8519, kept in $19</code></pre>")
    p.append('<p class="desc">So the two characters that look like the tail of the password '
             "are really its key. Change either one and every decoded byte changes.</p>")

    p.append("<h3>2. Four characters become three bytes</h3>")
    p.append('<p class="desc"><code>$85BB</code> copies four characters to <code>$0403</code>,'
             " masks each with <code>AND #$3F</code> and shifts them together. Six bits times "
             "four is twenty-four, which is three bytes exactly &mdash; and the character "
             "boundaries deliberately do not line up with the byte boundaries:</p>")
    p.append(_packing_svg())

    p.append("<h3>3. Every byte gets a different key</h3>")
    p.append("<pre><code>$854D:  EOR $19        ; XOR with the seed\n"
             "        DEC $19        ; and the seed counts down\n\n"
             "$854B:  CPX #$17 / BEQ ; ...except byte index $17, which is exempt</code></pre>")
    p.append('<p class="desc">Eight groups of four characters give <strong>24 bytes</strong> '
             "at <code>$011E-$0135</code>. That buffer is the PPU write queue's staging "
             "area, borrowed while the password screen is up. Why index <code>$17</code> "
             "is exempt is <strong>not established</strong>.</p>")

    p.append("<h3>4. The checksum decides</h3>")
    p.append("<pre><code>$859B:  sum of $011E..$0133, plus $0135\n"
             "        CMP $0134\n"
             "        BNE $8578      ; SEC / RTS  -> rejected\n"
             "        ...            ; copy to $0438, CLC / RTS -> accepted</code></pre>")
    p.append('<p class="desc">There is also a short circuit: <code>$8552</code> counts how '
             "many decoded bytes already differ from <code>$0439,X</code> into "
             "<code>$18</code>, and if none do, <code>$8576</code> returns carry clear "
             "without copying anything.</p>")

    p.append("<h2>The back door</h2>")
    p.append('<div class="note"><strong>Three bytes at bank 3 <code>$8513</code> read '
             f'<code>{" ".join(f"${x:02X}" for x in tgl)}</code>, which as grid indices is '
             f'<strong>{word}</strong>.</strong> <code>$857C</code> compares them against '
             "the first three characters, and <code>$8589</code> then requires every "
             "character from index 3 to <code>$1F</code> to be zero. On a match "
             "<code>$8592</code> sets <code>$2F = 0</code> and <code>$30 = 2</code> and "
             "returns carry clear &mdash; <strong>the checksum at <code>$859B</code> never "
             "runs</strong>. <code>$30</code> is the game-mode byte.</div>")
    p.append("<pre><code>$857A:  LDY #$00\n"
             "$857C:  LDA $8513,Y      ; 13 06 0B\n"
             "        CMP $0411,Y      ; the entry field\n"
             "        BNE $859B        ; ...otherwise fall through to the checksum\n"
             "        INY / CPY #$03 / BNE $857C\n"
             "$8589:  LDA $0411,Y      ; and everything after must be blank\n"
             "        BNE $859B\n"
             "        INY / CPY #$20 / BNE $8589\n"
             "        STA $2F          ; A is 0 here\n"
             "        LDA #$02 / STA $30\n"
             "        CLC / RTS        ; accepted</code></pre>")
    p.append('<div class="note"><strong>And the ROM names it.</strong> Bank 0 '
             "<code>$8BA3</code> is a screen script reading "
             f'<strong>&ldquo;PASSWORD {word}&rdquo;</strong>, sitting immediately after one '
             "reading &ldquo;PRODUCED BY / IREM / CORPORATION&rdquo;. Both parse cleanly "
             "under the screen-script format derived elsewhere in this project, on blocks "
             "that were not used to derive it. <strong>What the mode actually does is not "
             "established</strong> &mdash; only that the ROM contains a screen that says "
             "this.</div>")
    p.append('<div class="note warn">Because a blank and an A are the same byte, '
             f'<strong>&ldquo;{word}&rdquo; followed by any number of A&rsquo;s is '
             "byte-identical</strong> to it followed by blanks, and <code>$8589</code> "
             "cannot tell them apart.</div>")

    # ---------------------------------------------------------------- live decoder
    # Vectors are generated from random characters - every one of the 64 is typeable.
    random.seed(11)
    vectors = []
    for _ in range(5):
        text = "".join(random.choice(pw.ALPHABET) for _ in range(pw.FIELD_LEN))
        payload, _ = pw.decode(pw.to_indices(text))
        vectors.append((text, "".join(f"{x:02X}" for x in payload)))
    import json as _json
    p.append("<h2>Try it</h2>")
    p.append('<p class="sub">The same arithmetic, transcribed into the page. Type a '
             "password and it decodes exactly as bank 3 would &mdash; including the back "
             "door, which is checked first here just as it is there.</p>")
    p.append('<div class="card">'
             '<input id="pw" maxlength="32" placeholder="TGL" '
             'style="width:100%;font:16px ui-monospace,monospace;padding:10px 12px;'
             'border:1px solid var(--line);border-radius:8px;background:var(--code);'
             'color:var(--fg)" />'
             '<div id="out" style="margin-top:14px"></div>'
             '<p class="meta" id="selfcheck" style="margin-top:12px"></p></div>')
    p.append("<script>" + f"""
const AB={_json.dumps(pw.ALPHABET)}, TGL={_json.dumps(tgl)}, EXEMPT={pw.XOR_EXEMPT};
const VEC={_json.dumps(vectors)};
function idx(s){{const o=[];for(const c of s.normalize("NFD").replace(/̈/g,"")){{
  if(c===" "||c==="_"){{o.push(0);continue;}} const i=AB.indexOf(c); if(i<0) return null; o.push(i);}}
  while(o.length<32) o.push(0); return o.slice(0,32);}}
function decode(ch){{
  let seed=(((ch[31]<<2)|(ch[30]>>4))+0x1D)&0xFF, out=[];
  for(let g=0;g<8;g++){{
    const a=ch[4*g]&63,b=ch[4*g+1]&63,c=ch[4*g+2]&63,d=ch[4*g+3]&63;
    const bits=(a*262144)+(b*4096)+(c*64)+d;
    const trio=[(bits>>16)&255,(bits>>8)&255,bits&255];
    for(let k=0;k<3;k++){{let v=trio[k];
      if(3*g+k!==EXEMPT){{v^=seed; seed=(seed-1)&255;}}
      out.push(v&255);}}}}
  let s=0; for(let i=0;i<0x16;i++) s=(s+out[i])&255; s=(s+out[0x17])&255;
  return [out,s===out[0x16]];}}
function hex(n){{return n.toString(16).toUpperCase().padStart(2,"0");}}
const el=document.getElementById("pw"), out=document.getElementById("out");
function render(){{
  const t=el.value, ch=idx(t);
  if(!t){{out.innerHTML='<span class="meta">Nothing entered.</span>';return;}}
  if(!ch){{out.innerHTML='<span class="meta">Only the 64 characters on the grid (type a lowercase letter for an umlauted one).</span>';return;}}
  if(ch[0]===TGL[0]&&ch[1]===TGL[1]&&ch[2]===TGL[2]&&ch.slice(3).every(x=>x===0)){{
    out.innerHTML='<strong>The back door.</strong> $857A matches, $8589 finds the rest '+
      'blank, and $8592 sets $2F = 0 and $30 = 2 and returns carry clear. The checksum '+
      'never runs.';return;}}
  const [b,ok]=decode(ch); let h="";
  for(let r=0;r<24;r+=8) h+="$"+(0x011E+r).toString(16).toUpperCase().padStart(4,"0")+
    ": "+b.slice(r,r+8).map(hex).join(" ")+"\\n";
  let s=0; for(let i=0;i<0x16;i++) s=(s+b[i])&255; s=(s+b[0x17])&255;
  out.innerHTML="<pre><code>"+h+"</code></pre>"+
    "<p class=\\"meta\\">checksum byte $0134 = $"+hex(b[0x16])+", computed $"+hex(s)+
    " &rarr; <strong>"+(ok?"accepted (CLC / RTS, copied to $0438)":
    "rejected ($8578: SEC / RTS)")+"</strong></p>";}}
el.addEventListener("input",render); render();
let bad=0; for(const [txt,want] of VEC){{
  const [b]=decode(idx(txt)); if(b.map(hex).join("")!==want) bad++;}}
document.getElementById("selfcheck").innerHTML = bad
  ? "<strong>Self-check FAILED on "+bad+" of "+VEC.length+" vectors.</strong> This page's "+
    "decoder disagrees with the one in tools/tgl/password.py."
  : "Self-check: "+VEC.length+" vectors from tools/tgl/password.py decode identically here. "+
    "That is two transcriptions of the ROM agreeing, not hardware.";
""" + "</script>")

    p.append("<h2>Regions</h2>")
    for r in [x for x in rm.regions if x["id"] in PASSWORD_REGIONS]:
        p.append(f'<div class="card" id="{_h(r["id"])}">')
        p.append(f'<h3>{_h(r["name"])} '
                 f'<span class="tag" style="background:'
                 f'{KIND_COLOURS.get(r["kind"], DEFAULT_COLOUR)}">{_h(r["kind"])}</span> '
                 f'<span class="conf {r["confidence"]}">{_h(r["confidence"])}</span></h3>')
        p.append(f'<p class="meta"><code>{_h(r["id"])}</code> &middot; bank '
                 f'{r["prg_bank"]} ${r["cpu_addr"]:04X}-'
                 f'${r["cpu_addr"] + r["size"] - 1:04X} &middot; {r["size"]:,} bytes</p>')
        p.append(f'<p class="desc">{_h(r["description"])}</p></div>')

    p.append('<div class="note"><strong>What the 24 bytes are.</strong> <code>$85B0</code> '
             "copies buffer index <em>i</em> to <code>$0439 + i</code>, and bank 3 "
             "<code>$8473</code> turns that into game state: indices 0-16 become "
             "<code>$04A0-$04B0</code> &mdash; corridor flags, weapon levels, the Enemy Eraser "
             "count and the keys; index 17 the maximum life (<code>$47</code>, high five bits); "
             "18 and 19 attack and shield; 20 and 21 the score; 22 is the checksum; 23 is read "
             "by nothing. <code>$83AE</code> runs the other way &mdash; the game&rsquo;s own "
             "password generator.</div>")
    p.append(_tgl_mode(rm))
    p.append('<div class="note warn"><strong>Not established.</strong> What '
             "<code>$04A0-$04A8</code> hold. Why "
             "byte index <code>$17</code> is exempt from the XOR and never read. And whether a real in-game password "
             "round-trips: everything here is the ROM's arithmetic transcribed, checked "
             "against itself, never against a password a real save produced.</div>")
    return "".join(p)


KEY_COLOURS = ("#8a94a6", "#4fb0f2", "#ed64a6", "#38c172", "#ecc94b", "#f2704f", "#9d7cf8",
               "#38b2ac")


def _worldmap_svg(recs, cell=14):
    """Rows 0-23 of the world map as the status screen reveals them: one square per
    non-empty cell, coloured by the key that reveals it, corridor entrances numbered."""
    from tgl import worldmap as wm
    n = wm.COLUMNS
    w, h = n * cell, wm.DRAWN_ROWS * cell
    out = [f'<svg viewBox="-1 -1 {w + 2} {h + 2}" width="{min(w * 2, 700)}" '
           'style="max-width:100%;height:auto" xmlns="http://www.w3.org/2000/svg" '
           'font-family="ui-monospace,monospace">',
           f'<rect x="-1" y="-1" width="{w + 2}" height="{h + 2}" fill="none" '
           'stroke="currentColor" stroke-opacity="0.3"/>']
    for r in recs:
        if r["row"] >= wm.DRAWN_ROWS or r["b"][0] == wm.EMPTY:
            continue
        x, y = r["col"] * cell, r["row"] * cell
        out.append(f'<rect x="{x + 1}" y="{y + 1}" width="{cell - 2}" height="{cell - 2}" '
                   f'rx="2" fill="{KEY_COLOURS[wm.key(r)]}" fill-opacity="0.8"/>')
    for r in wm.entrances(recs):
        x, y = r["col"] * cell, r["row"] * cell
        out.append(f'<rect x="{x + 1}" y="{y + 1}" width="{cell - 2}" height="{cell - 2}" '
                   'rx="2" fill="none" stroke="currentColor" stroke-width="1.6"/>'
                   f'<text x="{x + cell / 2}" y="{y + cell / 2 + 3.5}" font-size="9" '
                   'font-weight="700" text-anchor="middle" fill="currentColor">'
                   f'{r["b"][2] & 0x7F}</text>')
    out.append("</svg>")
    return "".join(out)


def _status_page(rm):
    import sys
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
    from tgl import worldmap as wm

    b5, b7 = rm.prg_bank(5), rm.prg_bank(7)
    recs, _ = wm.records(b5)
    ent = {r["b"][2] & 0x7F: r for r in wm.entrances(recs)}
    ic = dict(_icons(rm))

    p = ["<h1>Status screen</h1>",
         '<p class="sub">Press Select during play: the world map, the seven keys, the twelve '
         "weapons, attack and shield, and a cursor to choose the weapon you fire.</p>"]

    p.append("<h2>How the game gets there</h2>")
    p.append('<div class="note">Bank 7 <code>$E4B3</code> runs every frame of play. The '
             "controller routine <code>$D626</code> shifts buttons in with <code>ROL</code>, so "
             "A lands in bit 7 and Right in bit 0; <code>$D678</code> then keeps "
             "<code>$F7</code>/<code>$F8</code> as <em>held</em> and <code>$F5</code>/"
             "<code>$F6</code> as <em>newly pressed</em>. A new Start (<code>$10</code>) "
             "pauses; a new Select (<code>$20</code>), or Select during the pause, goes to "
             "<code>$E4EE</code>: sound <code>$3E</code>, bit 4 of <code>$30</code> cleared, "
             "bank 5, <code>JSR $801B</code> &rarr; <code>$84CB</code> to <strong>open</strong>, "
             "then each frame <code>JSR $8021</code> &rarr; <code>$8937</code> until Start or "
             "Select is pressed, then <code>JSR $801E</code> &rarr; <code>$8711</code> to "
             "<strong>close</strong>, bank 6 <code>$8000</code>, and the saved bank and "
             "<code>$30</code> put back.</div>")
    p.append("<table><thead><tr><th>Routine</th><th>What it does</th></tr></thead><tbody>"
             "<tr><td><code>$84CB</code></td><td>Saves the palette (<code>$0181-$0198</code> "
             "&rarr; <code>$04D0</code>) and sprite 0's Y, then queues the whole screen: the "
             "map, twelve weapon icons to CHR <code>$1800</code> and seven key icons to "
             "<code>$1B00</code> through bank 2, the text, the stat bars and each slot's "
             "icon.</td></tr>"
             "<tr><td><code>$8937</code></td><td>Moves the weapon cursor <code>$3C</code>; "
             "bank 2 <code>$8998</code> draws it and blinks the player's map position."
             "</td></tr>"
             "<tr><td><code>$8711</code></td><td>Puts the palette back and, if the weapon "
             "changed, clears two object slots (<code>$C048</code> with X = 3, 4) before "
             "returning to play.</td></tr></tbody></table>")

    p.append("<h2>The map</h2>")
    p.append('<p class="sub">Bank 5 <code>$8A6E</code>, the same records the game walks '
             "while you move. <code>$882D</code> draws rows 0-23 as background tiles, each "
             "covering two by two cells; hardware sprites mark only the corridor entrances and "
             "(blinking) you.</p>")
    p.append(f'<div class="card">{_worldmap_svg(recs)}<p class="meta">'
             + " ".join(f'<span style="color:{KEY_COLOURS[k]}">&#9632;</span> '
                        + ("no key" if k == 0 else f"key {k}") for k in range(8))
             + " &middot; numbered squares are corridor entrances</p></div>")
    keys = [wm.key(ent[a]) for a in sorted(ent)]
    p.append('<div class="note"><strong>Byte 1 of a cell is a key, and the picture shows it'
             "</strong>: <code>$8860</code> tests <code>byte 1 AND 7</code> against "
             "<code>$04B0</code>, and a cell whose key is not held is not drawn. The colours "
             "above come out in solid zones, not noise. And the keys the 21 entrances need "
             "repeat with period ten &mdash; areas 1-10: "
             + ", ".join(str(k) for k in keys[:10]) + "; areas 11-20: "
             + ", ".join(str(k) for k in keys[10:20]) + f"; area 21: {keys[20]}."
             " <strong>Correction:</strong> this project first read byte 1 as a "
             "been-there flag and every drawn cell as a sprite; both were wrong.</div>")
    p.append('<div class="note"><strong>The map is exactly 24 &times; 24.</strong> '
             f"{len(recs)} records, and the status screen draws all of them. "
             "<strong>Correction:</strong> this page first said the stream held 807 records in "
             "34 rows. The last ten &ldquo;rows&rdquo; were bank 5's room shapes and room "
             "layouts, which <code>$8042</code> and <code>$8243</code> read; the old proof "
             "(&ldquo;the walk lands exactly on <code>$960F</code>&rdquo;) was one a walk over "
             "arbitrary data passes about one time in four.</div>")
    p.append('<div class="note warn"><strong>Not established.</strong> An entrance marker is '
             "shown while the corridor's <code>$04A9</code> bit is clear, and corridor 21's only once "
             "corridors 1-10 are all flagged &mdash; &ldquo;cleared&rdquo; is the obvious reading "
             "of that flag and has not been checked.</div>")

    p.append("<h2>Keys and weapons</h2>")
    p.append('<p class="sub">Twenty slots from the table at <code>$8690</code>, '
             "<code>[ppu lo][ppu hi][attribute lo][tile]</code>. A key's icon is drawn when its "
             "bit in <code>$04B0</code> is set; a weapon's when its two-bit level is not zero, "
             "with the palette picked by the level through <code>$85DA</code>.</p>")
    slots = b5[0x0690:0x06E0]
    rows = []
    for i in range(20):
        lo, hi, at, tile = slots[4 * i:4 * i + 4]
        if i == 7:
            rows.append('<tr><td>7</td><td colspan="4"><em>all zero, skipped by '
                        "<code>CPY #$1C</code></em></td></tr>")
            continue
        addr = hi << 8 | lo
        what = f"key {i + 1}" if i < 7 else f"weapon {i - 7}"
        art = ic["keys"][i + 1] if i < 7 else ic["items"][i - 8]
        rows.append(f"<tr><td>{i}</td><td>{what}</td><td>{_icons_svg([art], px=2)}</td>"
                    f"<td><code>${addr:04X}</code> row {(addr & 0x3FF) // 32}, "
                    f"col {addr & 31}</td><td><code>${tile:02X}</code></td></tr>")
    p.append("<table><thead><tr><th>Slot</th><th>Holds</th><th>Icon</th><th>Nametable</th>"
             f"<th>Tile</th></tr></thead><tbody>{''.join(rows)}</tbody></table>")

    p.append("<h3>Moving the cursor</h3>")
    p.append('<p class="desc"><code>$8937</code>: a new press acts at once and sets a 20-frame '
             "delay, a held direction repeats every 6. Right adds 1 and Left subtracts 1, "
             "wrapping over 0-12; Down adds 5 and Up subtracts 5, wrapping within the columns. "
             "Position 0 is &ldquo;no weapon&rdquo; and 1-12 are the weapons, five to a row. "
             "After a move, <code>$FD77</code> looks the weapon's level up into <code>$3D</code>, "
             "and a weapon at level 0 is skipped by moving again the same way &mdash; you "
             "cannot select what you do not have.</p>")

    p.append("<h3>What a weapon costs</h3>")
    cost = b7[0x3DD3:0x3DF8]
    rows = []
    ext = _external() or {"facts": []}
    names = next((f.get("weapon_names") for f in ext["facts"] if f.get("weapon_names")),
                 None) or [""] * 12
    for w in range(1, 12):
        c = [cost[3 * w + lv] for lv in (1, 2, 3)]
        rows.append(f"<tr><td>{w} {_h(names[w - 1])}</td>"
                    f"<td>{_icons_svg([ic['items'][w - 1]], px=2)}</td>"
                    + "".join(f'<td class="mono">{x}</td>' for x in c)
                    + f'<td class="mono">{b7[0x3DCA + w]}</td></tr>')
    rows.append(f"<tr><td>12 {_h(names[11])}</td><td>{_icons_svg([ic['items'][11]], px=2)}</td>"
                '<td colspan="3"><em>no cost row: its count is <code>$04AF</code></em></td>'
                f'<td class="mono">{b7[0x3DCA + 12]}</td></tr>')
    p.append('<p class="desc"><code>$FD77</code> reads <code>$FDD3 + 3 &times; weapon + '
             "level</code> into <code>$45</code>, the chips one use costs &mdash; the number "
             "printed after USE CHIP &mdash; and <code>$3E = chips / $45</code> is how many "
             "uses you have left, drawn in the play HUD. The table's first byte read is "
             "<code>$FDD7</code>, straight after the 13-byte table at <code>$FDCA</code>, and "
             "its last is <code>$FDF7</code>, straight before code.</p>")
    p.append("<table><thead><tr><th>Weapon</th><th></th><th>Level 1</th><th>Level 2</th>"
             "<th>Level 3</th><th><code>$FDCA</code> &rarr; <code>$3B</code></th></tr></thead>"
             f"<tbody>{''.join(rows)}</tbody></table>")

    p.append("<h2>The rest of the screen</h2>")
    p.append("<table><thead><tr><th>Shown</th><th>From</th><th>How</th></tr></thead><tbody>"
             "<tr><td>ATTACK</td><td><code>$4A</code></td><td>a bar of tile <code>$CD</code>, "
             "one tile per unit (<code>$87BC</code>)</td></tr>"
             "<tr><td>SHIELD</td><td><code>$4B</code></td><td>a bar of tile <code>$CC</code>"
             "</td></tr>"
             "<tr><td>CHIP MAX</td><td><code>$4E</code>/<code>$4F</code></td><td>16-bit "
             "decimal (<code>$E24B</code>)</td></tr>"
             "<tr><td>WEAPON POWER</td><td><code>$3D</code></td><td>one digit, the selected "
             "weapon's level</td></tr>"
             "<tr><td>USE CHIP</td><td><code>$45</code></td><td>decimal (<code>$E1CD</code>)"
             "</td></tr>"
             "<tr><td>NO USE</td><td>&mdash;</td><td>fixed text, beside slot 0</td></tr>"
             "<tr><td>&ldquo;EE&rdquo; and a number</td><td><code>$04AF</code></td><td>only "
             "when weapon 12's level bits (<code>$04AE</code> bits 6-7) are set. <em>A lead:"
             "</em> the letters read as an abbreviation of weapon 12's name, and weapon 12 "
             "is the one counted rather than charged.</td></tr>"
             "</tbody></table>")

    p.append("<h2>RAM this screen names</h2>")
    p.append("<table><thead><tr><th>Address</th><th>Meaning</th></tr></thead><tbody>"
             + "".join(f"<tr><td><code>{a}</code></td><td>{m}</td></tr>" for a, m in (
                 ("$F5 / $F6", "buttons newly pressed, players 1 / 2 (A = $80 &hellip; "
                  "Right = $01)"),
                 ("$F7 / $F8", "buttons held"),
                 ("$3C", "selected weapon, 0 = none, 1-12"),
                 ("$3D", "its level, 0-3"),
                 ("$3B", "a per-weapon value from $FDCA; meaning not established"),
                 ("$45", "chips per use"),
                 ("$3E", "uses left = chips / $45, or $04AF for weapon 12"),
                 ("$4A / $4B", "attack / shield bar lengths"),
                 ("$4C / $4D", "chips, the dividend in $FD77"),
                 ("$4E / $4F", "the number printed after CHIP MAX"),
                 ("$52 / $53", "the player's map column / row"),
                 ("$0150-$015B", "the map row buffer, one quadrant mask per tile"),
                 ("$04A9-$04AB", "one bit per area; hides its entrance marker"),
                 ("$04AC-$04AE", "weapon levels, two bits each, weapon 1 in the low bits"),
                 ("$04AF", "weapon 12's count"),
                 ("$04B0", "keys held, bit k-1 for key k"),
                 ("$04D0-$04E7", "the palette, saved while the screen is up"),
                 ("$0176", "the weapon selected when the screen opened"),
                 ("$0177", "sprite 0's Y, saved"),
             )) + "</tbody></table>")

    p.append("<h2>Regions</h2>")
    for r in [x for x in rm.regions if x["id"] in STATUS_REGIONS]:
        p.append(f'<div class="card" id="{_h(r["id"])}">')
        p.append(f'<h3>{_h(r["name"])} '
                 f'<span class="tag" style="background:'
                 f'{KIND_COLOURS.get(r["kind"], DEFAULT_COLOUR)}">{_h(r["kind"])}</span> '
                 f'<span class="conf {r["confidence"]}">{_h(r["confidence"])}</span></h3>')
        p.append(f'<p class="meta"><code>{_h(r["id"])}</code> &middot; bank '
                 f'{r["prg_bank"]} ${r["cpu_addr"]:04X}-'
                 f'${r["cpu_addr"] + r["size"] - 1:04X} &middot; {r["size"]:,} bytes</p>')
        p.append(f'<p class="desc">{_h(r["description"])}</p></div>')
    return "".join(p)


def _sprite_palettes(rm):
    """The four sprite palettes, as RGB triples for colours 1-3. Two savestates (title and
    in-game) hold exactly bank 5 $B30A records 0-3 in sprite palette RAM, so those are used;
    colour 0 is transparent for sprites."""
    b5 = rm.prg_bank(5)
    return [[NES_RGB[b5[0x330A + 3 * p + c] & 0x3F] for c in range(3)] for p in range(4)]


def _chr_runs(rm):
    """Tile block id -> the tiles CHR holds from where that block is loaded onward.

    A load stream packs blocks back to back, so a large enemy whose metasprite indexes past
    its own block is reading the next block in the same stream. Blocks no stream loads get
    just their own tiles."""
    from tgl import enemy, gfx
    b5 = rm.prg_bank(5)
    bases = {2: 0x8024, 3: 0x8020}

    def tiles(k):
        bank, i = enemy.block_source(k)
        d = rm.prg_bank(bank)
        p = bases[bank] + 2 * i - 0x8000
        ptr = d[p] | d[p + 1] << 8
        if not 0x8000 <= ptr < 0xC000:          # ids with no block ($0000 / $FFFF)
            return b""
        return gfx.decode(d, ptr - 0x8000)[0]

    runs = {}
    specials = {b5[0x26A4 + 3 * r] | b5[0x26A5 + 3 * r] << 8 for r in range(13)}
    # Corridor art comes from bank 4 streams (command 7); without them a corridor boss
    # reading past its own block - Fleepa, for one - is drawn with holes.
    _, corr = enemy.area_spawns(rm.prg_bank(4))
    streams = [(b5, s) for s in [enemy.GFX_DEFAULT] + sorted(specials)]
    streams += [(rm.prg_bank(4), s) for s in sorted({x for v in corr.values() for x in v})]
    for data, s in streams:
        recs, _ = enemy.walk_gfx_stream(data, s)
        for i, (_, blk, _) in enumerate(recs):
            run = b"".join(tiles(b) for _, b, _ in recs[i:])
            if len(run) > len(runs.get(blk, b"")):
                runs[blk] = run
    return runs, tiles


def _assembled_svg(spr, chr_run: bytes, pals, px: int = 3) -> str:
    """One metasprite as the PPU would show it: 8x16 sprites, each the tile pair
    (t AND $FE, +1) out of ``chr_run``, flipped by attribute bits 6 and 7, coloured by
    attribute bits 0-1. Earlier sprites win, as in OAM. A tile the run does not reach is
    drawn as a dashed outline rather than guessed."""
    if not spr:
        return ""
    x0 = min(s[0] for s in spr)
    y0 = min(s[1] for s in spr)
    w = max(s[0] for s in spr) + 8 - x0
    h = max(s[1] for s in spr) + 16 - y0
    n = len(chr_run) // 16
    pix, missing = {}, []
    for dx, dy, t, a in reversed(spr):
        top = t & 0xFE
        if top + 1 >= n:
            missing.append((dx - x0, dy - y0))
            continue
        pal = a & 3
        for row in range(16):
            src = 15 - row if a & 0x80 else row
            tile = top + (src >= 8)
            lo = chr_run[16 * tile + (src & 7)]
            hi = chr_run[16 * tile + 8 + (src & 7)]
            for col in range(8):
                bit = col if a & 0x40 else 7 - col
                v = ((lo >> bit) & 1) | (((hi >> bit) & 1) << 1)
                if v:
                    pix[(dx - x0 + col, dy - y0 + row)] = pals[pal][v - 1]
    by_colour: dict[tuple, list[str]] = {}
    for (x, y), c in pix.items():
        by_colour.setdefault(c, []).append(f"M{x} {y}h1v1h-1z")
    out = [f'<svg viewBox="0 0 {w} {h}" width="{w * px}" height="{h * px}" '
           'style="image-rendering:pixelated;vertical-align:middle;margin:2px 6px 2px 0" '
           'xmlns="http://www.w3.org/2000/svg">']
    for c, d in by_colour.items():
        out.append(f'<path fill="rgb{tuple(c)}" d="{"".join(d)}"/>')
    for x, y in missing:
        out.append(f'<rect x="{x + .5}" y="{y + .5}" width="7" height="15" fill="none" '
                   'stroke="currentColor" stroke-opacity=".5" stroke-dasharray="1 1" '
                   'stroke-width=".5"/>')
    out.append("</svg>")
    return "".join(out)


def _enemies_page(rm, out=None):
    import sys
    from collections import Counter
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
    from tgl import enemy, gfx, worldmap

    b5, b7 = rm.prg_bank(5), rm.prg_bank(7)
    bases = {2: 0x8024, 3: 0x8020}

    def block_tiles(k):
        bank, i = enemy.block_source(k)
        d = rm.prg_bank(bank)
        p = bases[bank] + 2 * i - 0x8000
        ptr = d[p] | d[p + 1] << 8
        return bank, ptr, gfx.decode(d, ptr - 0x8000)[0]

    from tgl import metasprite as msp
    b6 = rm.prg_bank(6)
    mptrs = msp.pointers(b7)
    frames, pieces = {}, {}
    allb = {k: rm.prg_bank(k) for k in range(8)}
    for row in msp.object_map_rm(rm):
        pieces[row["type"]] = sorted({i for v in row["pieces"].values() for i in v})
        ids = set(row["ids"])
        for v in row["tables"].values():
            ids |= set(v)
        frames[row["type"]] = sorted(i for i in ids if 0 < i < len(mptrs)
                                     and msp.parse(b7, mptrs[i]))
    runs, _ = _chr_runs(rm)
    pals = _sprite_palettes(rm)
    fit = total = 0
    ptrs = enemy.script_pointers(b5)
    walks = {p: enemy.walk_script(b5, p) for p in set(ptrs)}
    spawned = Counter()
    for p in ptrs:
        for e in walks[p][0]:
            if e[0] in ("spawn", "formation"):
                spawned[e[1]] += 1
    recs, _ = worldmap.records(b5)
    rooms = Counter(worldmap.fields(r).get("script") for r in recs if r["b"][0] != 0x80)

    p = ["<h1>Enemies</h1>",
         '<p class="sub">127 object types, each with hit points, attack, a death type and a '
         "tile block of its own art; 47 spawn scripts that the labyrinth's rooms name; and "
         "a loader that decompresses enemy art into CHR RAM as rooms are entered.</p>"]

    p.append("<h2>How a fight is decided</h2>")
    p.append('<div class="note">An object lives in one of 24 slots, its fields at '
             "<code>$0500 + $18 &times; field + slot</code>. <code>$0500</code> is the type; "
             "bank 6 dispatches behaviour on it, and bit 7 is set once <code>$CFA0</code> has "
             "filled four fields from the per-type tables. Slots 0-4 are the player's side: "
             "<code>$D348</code> tests only those against everything else, skipping any whose "
             "<code>$0578</code> has bit 7 set and requiring the collision class the caller "
             "names. <code>$D364</code> overlaps two boxes, each the position &plusmn; a "
             "half-size looked up by <em>metasprite id</em> in <code>$C174</code>/"
             "<code>$C201</code>. On a hit <code>$D30E</code> subtracts each side's "
             "<strong>attack</strong> (<code>$05A8</code>) from the other's <strong>hit "
             "points</strong> (<code>$0590</code>), clamping at 0, and at 0 <code>$D32A</code> "
             "turns the object into its <strong>death type</strong>. The player is treated "
             "differently: the damage is divided by the player's own <code>$0590</code> "
             "first.</div>")

    p.append(_boss_section(rm, _enemy_names()))
    p.append(_stage_boss_section(rm, out))
    p.append("<h2>Every type</h2>")
    p.append('<p class="sub">From <code>$D02C</code> (flags), <code>$D0AB</code> (HP), '
             "<code>$D12A</code> (attack), <code>$E00D</code>/<code>$E08C</code> (score), "
             "<code>$D441</code> (death) and <code>$CFC4</code> "
             "(art). The art is the tile block the type names, decoded with the codec &mdash; "
             "the tiles, not assembled into a sprite. &ldquo;In scripts&rdquo; counts the "
             "spawn scripts that create the type.</p>")
    ename = _enemy_names()
    rows = []
    for t in range(1, 128):
        v = enemy.per_type(b7, t)
        art = ""
        if v["gfx"] is not None and 0 < v["gfx"] < 0x80:
            bank, ptr, tiles = block_tiles(v["gfx"])
            run = runs.get(v["gfx"], tiles)
            shots = []
            if t in msp.PIECED:
                build, poses, what = msp.PIECED[t]
                a86 = msp.spawn_attr(allb, t)
                for pose in poses:
                    parts = build(allb, a86, pose)
                    ids = ", ".join(str(q[1]) if q[0] == "ms" else "single" for q in parts)
                    shots.append(f'<span title="{_h(what)} {(lambda x: f"${x >> 8:02X}:{x & 0xFF}" if t in (0x48, 0x49) else x)(pose)}: {ids}">'
                                 + _assembled_svg(msp.emit_parts(b7, parts), run, pals)
                                 + "</span>")
                hw = (" &mdash; checked against a savestate, 41/41 sprites" if t in (0x40, 0x41)
                      else " &mdash; checked against a savestate, 40/40 sprites (the Grimgrin "
                           "fight: state $1F, frame 4)" if t in (0x48, 0x49)
                      else " &mdash; read from the code, not yet checked against a savestate")
                plabel = ((lambda x: f"${x >> 8:02X}:{x & 0xFF}") if t in (0x48, 0x49) else str)
                shots.append('<br><span class="meta">drawn in pieces'
                             + (f" ({_h(what)} {', '.join(plabel(x) for x in poses)})"
                                if what else "") + hw + "; the parts:</span><br>")
            elif t in msp.UNDRAWN:
                shots.append(f'<span class="meta">drawn in pieces: {_h(msp.UNDRAWN[t])}'
                             "</span><br>")
            elif pieces.get(t):
                shots.append('<span class="meta">also draws metasprite'
                             f'{"s" * (len(pieces[t]) > 1)} '
                             + ", ".join(str(i) for i in pieces[t])
                             + " on top through <code>$CC34</code> &mdash; not composed "
                             "here, so the pictures below are parts</span><br>")
            for i in frames.get(t, [])[:8]:
                m = msp.parse(b7, mptrs[i])
                used = [x for x in m["tiles"] if x != 0xFF]
                total += 1
                fit += all(x % 2 == 0 for x in used) and max(used) + 2 <= len(tiles) // 16
                shots.append(f'<span title="metasprite {i}">'
                             + _assembled_svg(msp.emit(m), run, pals) + "</span>")
            art = ("".join(shots) + "<br>" if shots else "") + (
                f'<span class="meta">block <code>${v["gfx"]:02X}</code> &rarr; bank {bank} '
                f'<code>${ptr:04X}</code></span><br>' + _tiles_svg(tiles, per_row=16, px=14))
        elif v["gfx"] is not None and v["gfx"] >= 0x80:
            art = '<span class="meta">per object (<code>$07B8,X</code>)</span>'
        if t in msp.UNDRAWN and msp.UNDRAWN[t] not in art:
            art += (f'<span class="meta">drawn in pieces: {_h(msp.UNDRAWN[t])}</span>')
        pts = enemy.score(b7, v["score_class"])
        rows.append(f'<tr><td><code>${t:02X}</code>'
                    + (f'<br><strong>{_h(ename[t])}</strong> <a href="#boss-behaviour">behaviour</a>'
                       if t in ename else '')
                    + f'</td><td class="mono">{v["hp"]}</td>'
                    f'<td class="mono">{"per object" if pts is None else pts}</td>'
                    f'<td class="mono">{v["attack"]}</td>'
                    f'<td><code>${v["flags"]:02X}</code></td>'
                    f'<td><code>${v["death"]:02X}</code></td>'
                    f'<td class="mono">{spawned.get(t, "")}</td><td>{art}</td></tr>')
    p.append('<div style="overflow-x:auto"><table><thead><tr><th>Type</th><th>HP</th>'
             "<th>Score</th>"
             "<th>Attack</th><th>Flags</th><th>Death</th><th>In scripts</th><th>Assembled, and the block it comes from</th>"
             f"</tr></thead><tbody>{''.join(rows)}</tbody></table></div>")
    p.append('<div class="note"><strong>Assembled from the ROM, and checked.</strong> Each '
             "picture is a metasprite the type's behaviour code assigns (bank 6, and the banks "
             "its far calls reach, through <code>$0548</code>), drawn the way <code>$CC46</code>/<code>$CDD7</code> draw it: "
             "8&times;16 sprites, each the tile pair <code>t AND $FE</code> and the next, "
             "relative to the base tile where the type's block was loaded; mirrored records "
             "drawn twice; flips by attribute bits 6 and 7. Colours are bank 5 "
             "<code>$B30A</code> records 0-3, which is exactly what sprite palette RAM holds in "
             f"both savestates. <strong>{fit} of {total}</strong> type/metasprite pairs shown use "
             "only even tiles inside the type's own block. The rest either reach into the "
             "block its load stream packs next (bosses; drawn from that run) or were "
             "attributed through a subroutine several handlers share (dashed outlines mark "
             "tiles the run does not reach). <strong>Against hardware:</strong> "
             "<code>parse-metasprites.py --verify</code> predicts every live object's sprites "
             "from RAM and finds each multi-sprite shape drawn that frame whole in the "
             "in-game savestate's OAM &mdash; tiles, placement and attributes.</div>")
    p.append('<div class="note warn"><strong>Not established.</strong> Which type is which '
             "enemy by name; what each <code>$0620</code> drawing flag (from <code>$D1A9</code>) "
             "does; the "
             "meaning of the individual flag bits beyond bit 7 and the collision classes. "
             "Types <code>$76-$7F</code> have no art entry: <code>$CFC4</code> ends at type "
             "<code>$75</code>, and a lookup past it would read the flags table.</div>")

    p.append("<h2>Spawn scripts</h2>")
    p.append('<p class="sub">A labyrinth room with byte 1 bit 3 set names a script '
             "(<code>$57</code>); <code>$A480</code> finds it through <code>$A4C7</code> and "
             "bank 7 <code>$F78F</code> runs it a step at a time. <strong>formation</strong> "
             "<em>type &times; count / interval</em> creates a type-<code>$29</code> spawner "
             "(bank 6 <code>$9A19</code>) that makes <em>count</em> of the type, one every "
             "<em>interval</em> frames; <strong>wait</strong> is in units of 60 frames. All 47 "
             "are used by the map.</p>")
    items = []
    for i, ptr in enumerate(ptrs, 1):
        ev, _, how = walks[ptr]
        parts = []
        for e in ev:
            if e[0] == "formation":
                parts.append(f"formation <code>${e[1]:02X}</code>{_tn(e[1])} &times; {e[2]} / {e[3]}")
            elif e[0] == "spawn":
                parts.append(f"spawn <code>${e[1]:02X}</code>{_tn(e[1])}")
            elif e[0] in ("delay", "wait"):
                parts.append(f"wait {e[1]}")
            elif e[0] == "jump":
                parts.append(f'<span class="conf lead">jump ${e[1]:04X}?</span>')
            else:
                parts.append("end")
        items.append(f"<tr><td>{i}</td><td><code>${ptr:04X}</code></td>"
                     f'<td class="mono">{rooms.get(i, 0)}</td><td>{" &rarr; ".join(parts)}</td>'
                     "</tr>")
    p.append("<table><thead><tr><th>Id</th><th>At</th><th>Rooms</th><th>Steps</th></tr>"
             f"</thead><tbody>{''.join(items)}</tbody></table>")
    p.append('<div class="note warn"><strong>Five scripts do not end cleanly.</strong> They '
             "finish <code>[byte] 01 02</code>, which the interpreter reads as a long wait "
             "followed by command 1, a jump &mdash; whose two operand bytes are the next "
             "script's <code>02</code> and first byte. Either that wait never runs out in "
             "play, or this reading misses something. Marked <em>jump ?</em> above.</div>")

    p.append("<h2>The corridors</h2>")
    p.append('<div class="note">Enemies in the 21 vertically corridors come from two '
             "places. <strong>Waves</strong>: bank 4's screen-data command 2, with bit 1 of its "
             "operand set (<code>$E733</code>), points <code>$66</code>/<code>$67</code> at a "
             "spawn script in bank 4 and sets <code>$7F = 4</code> &mdash; the same format and "
             "the same interpreter as the labyrinth's, except that a wait counts frames in "
             "which <code>$A0</code> bit 2 is set, which <code>$E98F</code> does when a new "
             "background row comes in. So waves are keyed to <em>distance scrolled</em>, not "
             "time. Command 7 (<code>$E85E</code>) loads the area's enemy art the same way "
             "the labyrinth does, from bank 4. <strong>Ground objects</strong>: each new "
             "row is 16 metatile ids in <code>$04C0</code> (<code>$E8AB</code>); bank 5 "
             "<code>$83B3</code> draws each from five bytes and writes the fifth back, and "
             "<code>$89FB</code> spawns an object for any cell whose fifth byte has a high "
             "nibble, from the lists bank 5 <code>$803C</code> names &mdash; so turrets and "
             "the like are placed in the scenery itself.</div>")
    b4 = rm.prg_bank(4)
    a_scripts, a_streams = enemy.area_spawns(b4)
    from tgl import screen as sc
    g4 = sc.walk(b4)
    fences = sorted(set(g4["starts"]) | set(g4["pool"])
                    | set().union(*a_scripts.values()) | set().union(*a_streams.values()))
    rows = []
    for area in range(1, 22):
        for s in sorted(a_scripts.get(area, ())):
            ev, _, how = enemy.walk_script(b4, s, stop=next((f for f in fences if f > s),
                                                            0xC000))
            kinds = []
            for e in ev:
                if e[0] in ("spawn", "formation") and e[1] not in kinds:
                    kinds.append(e[1])
            art = ""
            for g in sorted(a_streams.get(area, ())):
                for _, blk, _ in enemy.walk_gfx_stream(b4, g)[0]:
                    if blk:
                        art += f"<code>${blk:02X}</code> "
            rows.append(f"<tr><td>{area}</td><td><code>${s:04X}</code></td>"
                        f"<td>{len(ev)}</td><td>"
                        + " ".join(f"<code>${k:02X}</code>" for k in kinds)
                        + ("" if how == "end" else " <em>(loops)</em>" if how == "jump"
                           else " <em>(runs on into other data)</em>")
                        + f"</td><td>{art}</td></tr>")
    p.append("<table><thead><tr><th>Area</th><th>Script</th><th>Steps</th>"
             "<th>Types spawned, in order of first appearance</th><th>Blocks loaded</th>"
             f"</tr></thead><tbody>{''.join(rows)}</tbody></table>")
    p.append('<div class="note"><strong>The checks.</strong> Corridors 1-21 name exactly one '
             "script each; areas <em>n</em> and <em>n</em>+10 share graphics streams, the "
             "same pairing the keys follow. The scripts and streams are pairwise disjoint, "
             "and all five scripts that end on a jump jump back into themselves. "
             "<strong>139 of 144</strong> (corridor, spawned type) pairs find the type's art block "
             "in that corridor's own load streams; the five that do not may be relying on art "
             "left loaded from before. <strong>Correction:</strong> the four huge "
             "&ldquo;terminal triggers&rdquo; that end bank 4's blocks are not trigger data "
             "&mdash; three are exactly the first two bytes of the spawn script or graphics "
             "stream that follows. Corridor 16's script runs on into the next block after its "
             "last wave; where it really ends is not established.</div>")

    p.append("<h2>Loading enemy art</h2>")
    p.append('<div class="note">Enemy tiles are decompressed into CHR RAM as a room is '
             "entered. A <em>load stream</em> is <code>[flags | slot][block][tile]</code> "
             "records, bit 7 ending it. Bank 7 <code>$E99F</code> takes one record per pass: "
             "it evicts whatever was in <code>slot</code> (objects still using it become type "
             "<code>$28</code>), has <code>$D7F9</code> decode <code>block</code> to tile "
             "<code>tile</code> &mdash; bank 3 below <code>$40</code>, bank 2 above &mdash; "
             "and records the block in <code>$0480</code>,slot and the tile in "
             "<code>$0490</code>,slot. An enemy whose block is not in <code>$0480</code> "
             "waits (<code>$CF5F</code>); when it is, <code>$0490</code> becomes its base "
             "tile. <strong>The check:</strong> in every stream, each record's tile is the "
             "previous one's plus that block's decoded length in tiles &mdash; the codec, "
             "the streams and the loader agree.</div>")
    rs, _ = enemy.walk_gfx_stream(b5, enemy.GFX_DEFAULT)
    rows = []
    for slot, blk, tile in rs:
        bank, ptr, tiles = block_tiles(blk)
        rows.append(f"<tr><td>{slot}</td><td><code>${blk:02X}</code></td>"
                    f"<td>bank {bank} <code>${ptr:04X}</code></td>"
                    f"<td><code>${tile:02X}</code></td><td>{len(tiles) // 16}</td>"
                    f"<td>{_tiles_svg(tiles, per_row=16, px=22)}</td></tr>")
    p.append('<p class="sub">The default stream, bank 5 <code>$A497</code>:</p>')
    p.append("<table><thead><tr><th>Slot</th><th>Block</th><th>Source</th><th>Tile</th>"
             f"<th>Tiles</th><th></th></tr></thead><tbody>{''.join(rows)}</tbody></table>")

    p.append("<h2>Regions</h2>")
    for r in [x for x in rm.regions if x.get("source") == ENEMY_SOURCE]:
        p.append(f'<div class="card" id="{_h(r["id"])}">')
        p.append(f'<h3>{_h(r["name"])} '
                 f'<span class="tag" style="background:'
                 f'{KIND_COLOURS.get(r["kind"], DEFAULT_COLOUR)}">{_h(r["kind"])}</span> '
                 f'<span class="conf {r["confidence"]}">{_h(r["confidence"])}</span></h3>')
        p.append(f'<p class="meta"><code>{_h(r["id"])}</code> &middot; bank '
                 f'{r["prg_bank"]} ${r["cpu_addr"]:04X}-'
                 f'${r["cpu_addr"] + r["size"] - 1:04X} &middot; {r["size"]:,} bytes</p>')
        p.append(f'<p class="desc">{_h(r["description"])}</p></div>')
    return "".join(p)


STATUS_COLOURS = {"confirmed": "#38c172", "consistent": "#4fb0f2", "rom-differs": "#f2704f",
                  "unchecked": "#8a94a6", "inconclusive": "#ecc94b"}


def _status_tag(s: str) -> str:
    return (f'<span class="tag" style="background:{STATUS_COLOURS[s]}">{_h(s)}</span>')


def _external_page(rm):
    from collections import Counter
    ext = _external()
    facts = ext["facts"]
    p = ["<h1>Outside sources</h1>",
         '<p class="sub">What is known about the game from outside the ROM &mdash; its '
         "manual, for a start &mdash; kept one claim at a time, each next to what the ROM "
         "says about it.</p>"]
    p.append('<div class="note"><strong>An outside claim is a lead until the ROM backs '
             "it.</strong> A manual describes the game its writers meant to ship, in words "
             "chosen for players; the ROM is the game. So every entry here carries a status, "
             "and <em>unchecked</em> means exactly that. Claims are paraphrased, not copied. "
             "The source file is <code>annotations/external.json</code>, which the build "
             "validates.</div>")

    counts = Counter(f["status"] for f in facts)
    p.append(_stats([(s, str(counts.get(s, 0))) for s in EXTERNAL_STATUSES]))
    p.append('<p class="meta">' + " &middot; ".join(
        f'{_status_tag(s)} {_h(ext["statuses"][s])}' for s in EXTERNAL_STATUSES) + "</p>")

    p.append("<h2>Sources</h2>")
    for s in ext["sources"]:
        n = sum(1 for f in facts if f["source"] == s["id"])
        p.append(f'<div class="card"><h3>{_h(s["title"])}</h3>'
                 f'<p class="meta"><code>{_h(s["id"])}</code> &middot; {_h(s["publisher"])} '
                 f"&middot; {n} facts</p>"
                 f'<p class="desc">{_h(s["form"])}</p>'
                 f'<p class="desc">{_h(s["notes"])}</p></div>')

    # ------------------------------------------------ what the manual named in the ROM
    names = next((f.get("weapon_names") for f in facts if f.get("weapon_names")), None)
    items = next((f.get("item_icons") for f in facts if f.get("item_icons")), None)
    if names or items:
        ic = dict(_icons(rm))["items"]
        p.append("<h2>Names the manual gave the ROM</h2>")
        p.append('<p class="sub">The manual pictures every weapon and item. Bank 2 '
                 "<code>$8E0C</code> holds eighteen icons, drawn straight from the ROM "
                 "below, and they match the manual's pictures one for one &mdash; which "
                 "names the ROM's weapon numbers. The ROM's order is not the manual's.</p>")
        rows = []
        for i in range(18):
            label = (names[i] if names and i < 12 else (items or {}).get(str(i), ""))
            what = (f"weapon {i + 1} (<code>$3C</code> = {i + 1})" if i < 12
                    else "item, in the reward list")
            rows.append(f"<tr><td>{i}</td><td>{_icons_svg([ic[i]], px=2)}</td>"
                        f"<td><strong>{_h(label)}</strong></td><td>{what}</td></tr>")
        p.append("<table><thead><tr><th>Icon</th><th></th><th>Manual name</th>"
                 f"<th>In the ROM</th></tr></thead><tbody>{''.join(rows)}</tbody></table>")

    # ------------------------------------------------------------------- the facts
    p.append("<h2>Every claim</h2>")
    topics = []
    for f in facts:
        if f["topic"] not in topics:
            topics.append(f["topic"])
    for topic in topics:
        p.append(f"<h3>{_h(topic)}</h3>")
        rows = []
        for f in (x for x in facts if x["topic"] == topic):
            rows.append(f'<tr id="{_h(f["id"])}"><td>{_status_tag(f["status"])}</td>'
                        f'<td><p class="desc" style="margin:0">{_h(f["claim"])}</p>'
                        f'<p class="meta" style="margin:4px 0 0">{_h(f["source"])}, '
                        f'p. {_h(f["pages"])}</p></td>'
                        f'<td><p class="desc" style="margin:0">'
                        f'{_h(f["rom"]) or "<em>Not looked for yet.</em>"}</p></td></tr>')
        p.append('<table><thead><tr><th style="width:110px">Status</th>'
                 '<th style="width:40%">The source says</th><th>The ROM says</th></tr>'
                 f"</thead><tbody>{''.join(rows)}</tbody></table>")
    return "".join(p)


def _corridors_page(rm):
    """Generic corridor mechanics: the stage encoding, how it is decoded, spawns, scroll."""
    import sys
    from collections import Counter
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
    from tgl import screen as sc

    b4 = rm.prg_bank(4)
    g = sc.walk(b4)
    recs = g["records"]
    census = Counter(c for _, c, _ in recs)
    W = lambda a: b4[a - 0x8000] | b4[a - 0x7FFF] << 8
    speeds = Counter()
    for a, c, _ in recs:
        if c == 0:
            v = W(a + 1)
            speeds[(v & 0x7FFF, bool(v & 0x8000))] += 1
    parts = sc.pool_parts(b4, recs)
    kinds = Counter(max(m["parts"], key=lambda q: q[1])[2] for m in parts)
    decoded = sum(m["end"] - m["addr"] for m in parts)
    trig = [W(a + 1 + n) for a, c, n in recs if c != 3]
    trig = [t for t in trig if t < sc.TERMINAL_TRIGGER]
    regions = [r for r in rm.regions if r.get("source") == SCREEN_SOURCE]

    p = ["<h1>Corridors</h1>",
         '<p class="sub">How the vertically scrolling stages work, for every corridor alike: '
         "how a stage is encoded, how the game decodes it a row at a time, what makes enemies "
         "appear and what sets the scroll speed. Everything here comes from bank 4's data and "
         "the bank 7 code that reads it.</p>"]
    p.append(_stats([("corridors", "21 (+ the opening, 0)"), ("records", f"{len(recs):,}"),
                     ("row tables", str(kinds["rowtable"])),
                     ("overlay structures", str(kinds["structure"])),
                     ("longest stage", f"{max(trig):,} rows")]))

    p.append('<p class="desc"><strong>Each corridor, with its structures drawn:</strong> ' + " &middot; ".join(
        f'<a href="{_corridor_page_name(c)}">{c}</a>' for c in CORRIDOR_PAGES) + "</p>")
    from tgl import corridor as cr
    _b3 = rm.prg_bank(3)
    _rows = []
    for c in CORRIDOR_PAGES:
        if c == 21:
            ts = []
            for r in sorted([x for x in cr.records(rm.prg_bank(4), 21) if x["cmd"] == 5],
                            key=lambda x: x["row"]):
                t = rm.prg_bank(4)[r["addr"] + 1 - 0x8000]
                if t not in ts:
                    ts.append(t)
            cell = ", ".join(f"<code>${t:02X}</code>{_tn(t)}" for t in ts) + " (a gauntlet, by command 5)"
        else:
            t = _b3[0x9151 - 0x8000 + c]
            cell = (f"<code>${t:02X}</code>" + (f" <strong>{_h(_boss_label(c, t))}</strong>"
                                                if _boss_label(c, t) else ""))
        _rows.append(f'<tr><td><a href="{_corridor_page_name(c)}">{c}</a></td><td>{cell}</td></tr>')
    p.append("<table><thead><tr><th>Corridor</th><th>Boss type (bank 3 <code>$9151</code>)</th></tr>"
             f"</thead><tbody>{''.join(_rows)}</tbody></table>")

    # ------------------------------------------------------------------ overview
    p.append('<h2 id="overview">Where a corridor comes from</h2>')
    p.append('<div class="note">Entering corridor <em>c</em> (<code>$51</code>) loads three '
             "things. <strong>Its tileset</strong>: scene 1 and then scene "
             "<code>$EF55</code>[c] (bank 5, the same scene system the labyrinth uses &mdash; "
             "background tiles, eight metatile sets, palettes). <strong>Its music</strong>: "
             "<code>$EF2A</code>[c]. <strong>Its stage</strong>: <code>$EF9B</code> switches to "
             "bank 4 and calls its only entry, <code>$8000</code>, which returns the block "
             "address from the 25-entry table at <code>$8013</code>, indexed by c + 2. The "
             "block is an <em>event stream</em>, and it is the whole stage: nothing else in "
             "the ROM says what a corridor looks like or what attacks in it.</div>")

    # ------------------------------------------------------------------ loop
    p.append('<h2 id="loop">How a stage is decoded: one row at a time</h2>')
    p.append('<ol class="desc">'
             "<li><strong>Scroll</strong> (<code>$E530</code>, every frame): the screen moves "
             "by the current speed <code>$B8</code>/<code>$B9</code>, in 1/256 pixel per frame; "
             "the whole pixels this frame land in <code>$B7</code>.</li>"
             "<li><strong>Count pixels</strong> (<code>$E69B</code>): <code>$AF</code> adds them "
             "up, and every <strong>16 pixels</strong> &mdash; one metatile row &mdash; it rolls "
             "over and the <strong>row counter</strong> <code>$B0</code>/<code>$B1</code> goes up "
             "by one (<code>$E6B3</code>). The row counter is the stage's clock: every event "
             "is keyed to it.</li>"
             "<li><strong>Fire events</strong> (<code>$E6CE</code>): while the row counter "
             "equals the pending trigger <code>$B2</code>/<code>$B3</code>, the next record's "
             "command runs (dispatched through <code>$E6F3</code>) and <code>$E89D</code> "
             "reads the trigger after it. Several records can share a row.</li>"
             "<li><strong>Build the new row</strong> (<code>$E8AB</code>): 16 metatile ids "
             "from the background strip into <code>$04C0</code>, then each of the eight "
             "overlay slots writes its structure's next row over them.</li>"
             "<li><strong>Draw it and spawn from it</strong>: bank 5 <code>$83B3</code> draws "
             "the 16 metatiles (five bytes each) and writes each one's fifth byte back into "
             "<code>$04C0</code>; bank 5 <code>$89FB</code> then spawns a ground object for "
             "every cell whose fifth byte has a high nibble (below).</li>"
             "<li><strong>Tick the waves</strong>: <code>$E98F</code> sets <code>$A0</code> bit "
             "2, which is what a corridor spawn script's waits count; <code>$E655</code> "
             "clears it next frame.</li></ol>")

    # ------------------------------------------------------------------ stream
    p.append('<h2 id="stream">The event stream</h2>')
    p.append('<p class="desc">A block starts with a two-byte trigger (the row its first record '
             "fires on, normally 0). Every record is then "
             "<code>[command][operands][next trigger lo][next trigger hi]</code>: each record "
             "carries the row at which the record <em>after</em> it fires, so triggers never "
             "decrease within a block &mdash; one of the checks the parser relies on. Command 3 "
             "jumps (a block is a graph, not a list); the stream simply stops being read when "
             "the scroll stops, because the row counter stops.</p>")
    rows = [
        (0, "2", "<strong>scroll speed</strong>: target <code>$BA</code>/<code>$BB</code>; "
                 "with bit 7 of the high byte, also the current speed at once"),
        (1, "2", "<strong>background</strong>: pointer to a row table, into <code>$B4</code>/"
                 "<code>$B5</code>; restarts the strip (<code>$A1</code> = 0)"),
        (2, "1 or 3", "<strong>wave script</strong>: bits 0-1 into <code>$60</code>; with bit 1, a "
                      "pointer to a bank 4 spawn script (<code>$66</code>/<code>$67</code>, "
                      "<code>$7F</code> = 4), started at once"),
        (3, "2", "<strong>jump</strong>: continue at the target, whose first two bytes are a "
                 "fresh trigger"),
        (4, "2", "<strong>palettes</strong>: pointer to a palette list, applied by "
                 "<code>$D92D</code>"),
        (5, "0 (1 in corridor 21)", "<strong>boss phase</strong>: <code>$70</code> = 1; "
                 "corridor 21 names the boss type (<code>$72</code>) here, the others take it "
                 "from bank 3 <code>$9151</code>[c]. Used more than once per corridor, so it is "
                 "not only the final boss &mdash; which fights each use starts is not read"),
        (6, "variable", "<strong>overlays</strong>: place up to n structures into the eight "
                        "overlay slots (below)"),
        (7, "2", "<strong>enemy art</strong>: waits for the previous load, then a graphics-load "
                 "stream into <code>$28</code>/<code>$29</code>"),
        (8, "pairs", "<strong>palette slots</strong>: <code>[slot][palette]</code> pairs into "
                     "<code>$0199</code>+slot while the slot is below 8"),
        (9, "2", "<strong>jump while <code>$70</code></strong>: command 3, taken only during "
                 "the boss phase"),
    ]
    p.append("<table><thead><tr><th>Cmd</th><th>Operands</th><th>Effect</th><th>Uses</th>"
             "</tr></thead><tbody>" + "".join(
                 f"<tr><td>{c}</td><td class=\"mono\">{o}</td><td>{e}</td>"
                 f"<td class=\"mono\">{census.get(c, 0)}</td></tr>" for c, o, e in rows)
             + "</tbody></table>")
    p.append('<p class="meta">&ldquo;Uses&rdquo; counts records across all 25 blocks. Command 8 '
             "is never used. A typical opening, corridor 1's, at row 0: palettes (4), row table "
             "(1), speed <code>$0100</code> (0), enemy art (7), wave script (2); then a run of "
             "overlay placements (6) as it scrolls; and near the end a new target speed of "
             "<code>$0080</code> &mdash; the scroll eases down to half a pixel per frame "
             "&mdash; then boss art (7) and the boss phase (5).</p>")

    # ------------------------------------------------------------------ background
    p.append('<h2 id="background">The background: a repeating strip, with structures on top'
             "</h2>")
    p.append('<div class="note"><strong>The strip.</strong> A row table is <code>[rows lo]'
             "[rows hi][count]</code>. <code>$E8AB</code> takes row <code>$A1</code> &mdash; "
             "counting 0 to count&minus;1 and round again &mdash; as 16 metatile ids at rows + "
             "16 &times; <code>$A1</code>. So a corridor's floor is a short loop of rows (one to a "
             "handful), repeated for as long as the stage runs, and a command 1 can switch to "
             "another strip mid-stage. A metatile id is the labyrinth's: set (bits 5-7) and "
             "metatile (bits 0-4) in the scene's eight sets.</div>")
    p.append('<div class="note"><strong>Overlays.</strong> Everything that is not floor &mdash; '
             "walls, buildings, craters, bridges &mdash; is a structure written over the strip "
             "by one of <strong>eight overlay slots</strong> (<code>$0400</code>-"
             "<code>$045F</code>, one byte per slot per field). Each new row, every active slot "
             "writes its structure's next row at its column; after the last row it can repeat, "
             "shifted sideways, and then goes idle (column <code>$80</code>).</div>")
    p.append("<h3>A command 6 record</h3>")
    p.append("<table><thead><tr><th>Byte</th><th>Present when</th><th>Meaning</th></tr></thead>"
             "<tbody>"
             "<tr><td>flags</td><td>always</td><td>bits 0-2 the slot; bits 4-7 below</td></tr>"
             "<tr><td>delay</td><td>bit 7 clear</td><td>rows to wait before starting "
             "(<code>$0430</code>); bit 7 set means 0</td></tr>"
             "<tr><td>repeat gap</td><td>bits 7 and 5 clear</td><td>rows between repeats "
             "(<code>$0408</code>); otherwise the delay again</td></tr>"
             "<tr><td>x step</td><td>bit 6 clear</td><td>columns to shift by on each repeat "
             "(<code>$0438</code>); bit 6 set means 0</td></tr>"
             "<tr><td>repeats</td><td>bit 5 clear</td><td>how many times to draw it "
             "(<code>$0410</code>); bit 5 set means once</td></tr>"
             "<tr><td>column</td><td>always</td><td>where it starts (<code>$0400</code>); "
             "0-15 on screen, beyond that off to the side</td></tr>"
             "<tr><td>data</td><td>always</td><td>bit 4 clear: a pointer to a structure; bit 4 "
             "set: <code>[pointer][width][height]</code> inline, the rows elsewhere</td></tr>"
             "</tbody></table>")
    p.append('<p class="desc"><strong>A structure</strong> is <code>[width][height]</code> '
             "and then its rows, read by <code>$E90F</code> as codes: <code>$00 n</code> skips "
             "n columns (the floor shows through), <code>$01</code> ends the row early, and any "
             "other byte is a metatile id written at the current column. A row is done once "
             "<em>width</em> ids have been written. A slot moving off either edge "
             "(column <code>$20</code>-<code>$EF</code>) is switched off.</p>")

    # ------------------------------------------------------------------ scroll
    p.append('<h2 id="scroll">Scroll speed</h2>')
    p.append('<div class="note">The current speed is <code>$B8</code>/<code>$B9</code>, a '
             "16-bit number of <strong>1/256 pixel per frame</strong>. Every frame "
             "<code>$E66A</code> moves it <strong>2/256 towards the target</strong> "
             "<code>$BA</code>/<code>$BB</code> &mdash; so changes of speed are smooth ramps, "
             "128 frames per pixel-per-frame &mdash; and only command 0 sets the target. With bit "
             "7 of its high byte set, command 0 sets the current speed too, with no ramp. A speed "
             "of 0 (used four times, two of them at once) halts the scenery, and since rows then "
             "stop coming, so does the event stream. Rows arrive every 16 &times; 256 &divide; "
             "speed frames: at <code>$0100</code>, one pixel per frame, a row every 16 "
             "frames.</div>")
    sp = sorted(speeds.items(), key=lambda kv: (kv[0][0], kv[0][1]))
    p.append("<table style=\"width:auto\"><thead><tr><th>Speed</th><th>Pixels per frame</th>"
             "<th>How</th><th>Records</th></tr></thead><tbody>" + "".join(
                 f"<tr><td class=\"mono\">${v:04X}</td><td class=\"mono\">{v / 256:g}</td>"
                 f"<td>{'at once (bit 7)' if now else 'ramped'}</td><td class=\"mono\">{n}</td>"
                 "</tr>" for (v, now), n in sp) + "</tbody></table>")

    # ------------------------------------------------------------------ spawns
    p.append('<h2 id="spawns">What makes enemies appear</h2>')
    p.append('<ul class="desc">'
             "<li><strong>Waves</strong> &mdash; command 2 with bit 1 starts a spawn script in "
             "bank 4, run by the same interpreter as the labyrinth's (<code>$F78F</code>): "
             "spawn a type, spawn a formation (a type-<code>$29</code> spawner that releases "
             "<em>count</em> of a type every <em>interval</em>), wait, jump, end. In a corridor "
             "a wait counts <em>rows</em>, not frames: it only ticks when <code>$A0</code> bit 2 "
             "says a new row came in &mdash; so waves stay pinned to the scenery whatever the "
             "speed. See <a href=\"enemies.html\">Enemies</a> for the scripts.</li>"
             "<li><strong>Ground objects</strong> &mdash; placed by the scenery itself. A "
             "metatile's fifth byte has a high nibble on cells that carry something; when "
             "<code>$89FB</code> sees one in the new row, it looks up that nibble in the spawn "
             "list of the metatile's set (<code>$803C</code>[the set's list number]) and spawns "
             "that object type at the cell's column. So whatever row or structure puts such a "
             "metatile on screen also places its object &mdash; no spawn script is involved."
             "</li>"
             "<li><strong>Bosses</strong> &mdash; command 5 sets <code>$70</code> = 1. Bank 3 "
             "<code>$9184</code> then runs the boss phase: it spawns the boss type "
             "(<code>$9151</code>[corridor], or command 5's operand in corridor 21) and waits for "
             "it; the score counted for the TGL game's rewards is taken here, and the boss "
             "clock runs while it lives. Command 9 is the stream's only way to test "
             "<code>$70</code>.</li>"
             "<li><strong>The art they need</strong> &mdash; command 7 queues a graphics-load "
             "stream (<code>$E99F</code> decompresses its blocks into sprite CHR); an object "
             "whose block has not arrived yet waits (<code>$CF5F</code>).</li></ul>")

    # ------------------------------------------------------------------ data
    p.append('<h2 id="data">Bank 4, decoded</h2>')
    p.append('<div class="note">Bank 4 is 100% claimed: the 25 event streams, and the data they '
             f"point at &mdash; {kinds['rowtable']} row tables and {kinds['rows']} groups of "
             f"background rows, {kinds['structure']} structures, {kinds['overlay']} runs of "
             f"inline overlay rows and {kinds['palettes']} palette lists, {decoded:,} bytes "
             "&mdash; plus the bank's spawn scripts and graphics streams (tools/parse-enemies.py). "
             "<strong>CORRECTION:</strong> the data half was claimed as a lead with its contents "
             "not established; reading the handlers that consume it decodes all but 30 bytes, "
             "and every decoded piece lands inside it, none outside. Four pieces overlap on "
             "purpose (inline overlays pointing into rows) and are claimed as shared. What is "
             "left: an unused row table and its row, two unused 1 &times; 2 structures, one byte, "
             "a never-matching trigger, and the bank's closing fill.</div>")
    p.append('<div class="note warn"><strong>Not established.</strong> What bit 0 of '
             "<code>$60</code> does (command 2). How the overlay column maps to the screen when "
             "the playfield is wider than 16 metatiles. Nothing here has been checked against a "
             "savestate taken in a corridor beyond the tileset (CHR 141/142, sets 6/6) and "
             "Fleepa.</div>")
    by = Counter(r["kind"] for r in regions)
    p.append(f'<details><summary>All {len(regions)} bank 4 regions from '
             f"tools/parse-screen.py ({', '.join(f'{n} {k}' for k, n in by.items())})</summary>"
             "<table><thead><tr><th>CPU</th><th>Bytes</th><th>Name</th><th>Confidence</th></tr>"
             "</thead><tbody>" + "".join(
                 f'<tr><td><a href="bank4.html#{_h(r["id"])}"><code>${r["cpu_addr"]:04X}</code>'
                 f'</a></td><td class="mono">{r["size"]}</td><td>{_h(r["name"])}</td>'
                 f'<td>{_h(r["confidence"])}</td></tr>' for r in regions) +
             "</tbody></table></details>")
    return "".join(p)


CORRIDOR_PAGES = range(0, 23)         # 0 the opening flight; 1-21 the stages; 22 the final corridor


def _corridor_page_name(c: int) -> str:
    return f"corridor-{c:02d}.html"


def _png_uri(img, scale: int = 2) -> str:
    import base64
    import io
    from PIL import Image
    if scale != 1:
        img = img.resize((img.width * scale, img.height * scale), Image.NEAREST)
    buf = io.BytesIO()
    img.save(buf, format="PNG", optimize=True)
    return "data:image/png;base64," + base64.b64encode(buf.getvalue()).decode()


def _corridor_page(rm, c: int, out: Path | None = None) -> str:
    """One corridor: its tileset, background strips and every structure it places."""
    import sys
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
    from tgl import corridor as cr

    b3, b4, b5, b7 = (rm.prg_bank(k) for k in (3, 4, 5, 7))
    recs = cr.records(b4, c)
    seq = cr.scenes(b7, c)
    slots = cr.palette_slots(b5, b4, seq, recs)
    art = cr.Art(rm, seq, slots, NES_RGB)
    pl = cr.placements(b4, recs)
    tables = cr.row_tables(b4, recs)
    rows_end = max([r["row"] for r in recs if r["row"] < 0x0800] or [0])
    speeds = [(r["row"], cr._w(b4, r["addr"] + 1)) for r in sorted(recs, key=lambda r: r["row"])
              if r["cmd"] == 0]
    song = b7[cr.MUSIC - 0xC000 + c]
    boss = b3[0x9151 - 0x8000 + c] if c != 21 else None
    title = ("Corridor 0 &mdash; the opening flight" if c == 0 else
             "Corridor 22 &mdash; the final corridor" if c == 22 else f"Corridor {c}")
    gauntlet = []
    if c == 21:                        # $E7AF: command 5 in area 21 carries the boss type
        seen = set()
        for r in sorted(recs, key=lambda r: r["row"]):
            if r["cmd"] == 5 and r["addr"] not in seen:
                seen.add(r["addr"])
                gauntlet.append((r["row"], b4[r["addr"] + 1 - 0x8000]))

    prev_ = f'<a href="{_corridor_page_name(c - 1)}">&larr; corridor {c - 1}</a>' if c > 0 else ""
    next_ = (f'<a href="{_corridor_page_name(c + 1)}">corridor {c + 1} &rarr;</a>'
             if c + 1 in CORRIDOR_PAGES else "")
    p = [f'<p class="meta"><a href="corridors.html">Corridors</a> &middot; {prev_} '
         f"{'&middot; ' if prev_ and next_ else ''}{next_}</p>",
         f"<h1>{title}</h1>",
         '<p class="sub">Everything this corridor&rsquo;s event stream draws: its background '
         "strips and every structure it places, in its own tiles and palettes. How the stream "
         'works is on the <a href="corridors.html">Corridors</a> page.</p>']
    uniq = {}
    for d in pl:
        uniq.setdefault((d["data"], d["w"], d["h"], d["inline"]), []).append(d)
    p.append(_stats([("tileset", f"scenes {seq[0]}, {seq[1]}"), ("music", f"song {song}"),
                     ("records", str(len(recs))), ("background strips", str(len(tables))),
                     ("structures", str(len(uniq))), ("placements", str(len(pl))),
                     ("last event", f"row {rows_end:,}")]))
    sp = ", ".join(f"row {r}: ${v & 0x7FFF:04X} ({(v & 0x7FFF) / 256:g} px/frame"
                   f"{', at once' if v & 0x8000 else ''})" for r, v in speeds)
    p.append(f'<p class="desc"><strong>Scroll speed:</strong> {sp or "never set"}. '
             + (f"<strong>Boss type</strong> (bank 3 <code>$9151</code>[{c}]): "
                f'<a href="enemies.html"><code>${boss:02X}</code>'
                f'{" " + _h(_boss_label(c, boss)) if _boss_label(c, boss) else ""}</a>. ' if boss is not None else
                "<strong>Bosses</strong> (named by each command 5's operand, bank 4 "
                "<code>$E7AF</code>): " + ", ".join(
                    f'row {r}: <code>${t:02X}</code> {_h(_enemy_names().get(t, "?"))}'
                    for r, t in gauntlet) + ". ")
             + f"Stream: bank 4 <code>${cr.screen.entry_pointers(b4)[c - cr.screen.FIRST_AREA]:04X}"
             "</code>.</p>")
    p.append('<p class="meta">Colours are the palette slots after row 0 &mdash; the scenes\' '
             "lists, then the stream's command 4/8 records at row 0; a later command 4 can change "
             "them. Checked on corridor 15's savestate: all 8 slots predicted exactly. Pictures "
             "are drawn the way the screen shows them, <strong>the structure's first row at the "
             "bottom</strong>: new rows enter at the top and scroll down (checked on the same "
             "savestate &mdash; the background rows and the 1 &times; 2 pillars stack that way). "
             "Dark cells are columns a structure skips, where the floor shows through.</p>")

    # ---- the whole stage, simulated row by row
    stage, sim = cr.stage_image(rm, c, NES_RGB)
    full = f"stage-{c:02d}.png"
    if out is not None:
        stage.save(out / full, optimize=True)
    fl = cr.film(stage)
    fl = fl.resize((fl.width // 2, fl.height // 2))
    film_name = f"stage-{c:02d}-film.png"
    if out is not None:
        fl.save(out / film_name, optimize=True)
    p.append('<h2 id="stage">The whole stage</h2>')
    p.append(f'<p class="desc">{len(sim["rows"]):,} rows, from row {sim["start"]} to '
             f'{sim["start"] + len(sim["rows"]) - 1:,}, cut into columns of 120 rows: read '
             "each column from the bottom up, left to right &mdash; row 0 is at the bottom of "
             f'the first. <a href="{full}">The stage as one image</a> (256 &times; '
             f"{stage.height:,}, full size, bottom to top).</p>")
    p.append(f'<a href="{full}"><img src="{film_name}" alt="corridor {c}, the whole '
             'stage" style="max-width:100%;height:auto"></a>')
    p.append('<p class="meta">Background only &mdash; no enemies, ground objects or bosses. '
             "Simulated the way <code>$E6CE</code> and <code>$E8AB</code> build it: at each row "
             "the records whose trigger has come fire, then the strip's next row goes down and "
             "each active overlay slot writes its structure's next row over it, with its delay, "
             "repeats, gap, sideways step and edge cut-off. Palette changes (commands 4 and 8) "
             "take effect at their row. Command 9 is taken once a command 5 has started the "
             "boss phase. The picture stops 16 rows after the last record fires; the game keeps "
             "repeating the strip until the boss is beaten. <strong>Checked</strong> on "
             "corridor 15's savestate, stopped at row 41: the 13 settled rows on screen match "
             "the simulation cell for cell, the newest row is caught mid-write (each cell holds "
             "the new row or the one it replaces), and one cell in column 0 differs.</p>")

    p.append('<h2 id="strips">Background strips</h2>')
    for t in tables:
        img = art.strip(t["ids"])
        p.append(f'<div class="card"><h3>Row table <code>${t["table"]:04X}</code> &mdash; '
                 f'{t["count"]} row{"s" * (t["count"] != 1)}, from row {t["row"]}</h3>'
                 f'<p class="meta">Rows at <code>${t["rows"]:04X}</code>, repeated bottom to top '
                 f'for as long as the table is in force.</p>'
                 f'<img src="{_png_uri(img)}" alt="background strip ${t["table"]:04X}" '
                 'style="image-rendering:pixelated;max-width:100%;height:auto"></div>')

    p.append('<h2 id="structures">Structures</h2>')
    for (data, w, h, inline), uses in sorted(uniq.items(), key=lambda kv: min(u["row"] for u in kv[1])):
        rows = cr.cells(b4, data, w, h)
        img = art.structure(rows)
        head = (f"inline rows at <code>${data:04X}</code>" if inline
                else f"structure <code>${uses[0]['structure']:04X}</code>")
        trs = "".join(
            f"<tr><td class=\"mono\">{u['row']}</td><td class=\"mono\">{u['slot']}</td>"
            f"<td class=\"mono\">{u['column']}</td><td class=\"mono\">{u['delay']}</td>"
            f"<td class=\"mono\">{u['repeats'] if u['repeats'] else 256}</td>"
            f"<td class=\"mono\">{u['gap']}</td>"
            f"<td class=\"mono\">{u['step'] - 256 if u['step'] > 127 else u['step']}</td></tr>"
            for u in sorted(uses, key=lambda u: (u["row"], u["slot"])))
        p.append(f'<div class="card"><h3>{w} &times; {h} &mdash; {head}</h3>'
                 f'<div style="display:flex;gap:16px;flex-wrap:wrap;align-items:flex-start">'
                 f'<img src="{_png_uri(img)}" alt="{w} by {h} structure" '
                 'style="image-rendering:pixelated;max-width:100%;height:auto">'
                 '<table style="width:auto"><thead><tr><th>Row</th><th>Slot</th><th>Column</th>'
                 '<th>Delay</th><th>Repeats</th><th>Gap</th><th>Step</th></tr></thead>'
                 f"<tbody>{trs}</tbody></table></div></div>")
    p.append('<p class="meta">Row: the stage row the command 6 record fires on. Delay: rows '
             "before the first copy. Repeats: copies drawn (0 in the data means 256). Gap: rows "
             "between copies. Step: columns each copy moves sideways.</p>")
    return "".join(p)


def _pad_svg(v: int, px: int = 2, note: str = "") -> str:
    """An NES pad with the buttons of byte v held (bit 7 A ... bit 0 Right, as $D626 reads)."""
    on, off = "var(--accent, #e0457b)", "var(--line, #9993)"
    c = lambda bit: on if v & bit else off
    return (f'<svg viewBox="0 0 64 26" width="{64 * px}" xmlns="http://www.w3.org/2000/svg" '
            f'role="img" aria-label="{_h(note)}"><rect x=".5" y=".5" width="63" height="25" '
            'rx="5" fill="none" stroke="currentColor" stroke-opacity=".35"/>'
            f'<rect x="8" y="5" width="6" height="6" fill="{c(0x08)}"/>'
            f'<rect x="8" y="15" width="6" height="6" fill="{c(0x04)}"/>'
            f'<rect x="3" y="10" width="6" height="6" fill="{c(0x02)}"/>'
            f'<rect x="13" y="10" width="6" height="6" fill="{c(0x01)}"/>'
            '<rect x="8" y="10" width="6" height="6" fill="currentColor" fill-opacity=".15"/>'
            f'<rect x="24" y="14" width="7" height="3" rx="1.5" fill="{c(0x20)}"/>'
            f'<rect x="33" y="14" width="7" height="3" rx="1.5" fill="{c(0x10)}"/>'
            f'<circle cx="48" cy="15" r="4" fill="{c(0x40)}"/>'
            f'<circle cx="57" cy="12" r="4" fill="{c(0x80)}"/>'
            '<text x="48" y="7" font-size="5" text-anchor="middle" fill="currentColor">B</text>'
            '<text x="57" y="5" font-size="5" text-anchor="middle" fill="currentColor">A</text>'
            "</svg>")


def _demo_page(rm):
    """The attract-mode demo: how it starts, the state it builds, and the input it invents."""
    from tgl import disasm

    b0, b7 = rm.prg_bank(0), rm.prg_bank(7)

    def listing(bank, data, base, start, end, marks=None):
        a, out = start, []
        while a < end:
            i = disasm.decode(data, a - base, a)
            note = (marks or {}).get(a, "")
            out.append(f"${a:04X}  {i.text():<18}" + (f"; {note}" if note else ""))
            a += i.size
        return "<pre>" + _h("\n".join(out)) + "</pre>"

    def stores(data, base, start, end):
        """(target, value) for every LDA #imm ... STA abs/zp in a straight run."""
        a, acc, out = start, None, []
        while a < end:
            i = disasm.decode(data, a - base, a)
            if i.mnemonic == "LDA" and i.mode == "imm":
                acc = i.operand
            elif i.mnemonic in ("STA",) and i.mode in ("zp", "abs") and acc is not None:
                out.append((i.operand, acc))
            elif i.mnemonic not in ("STA",):
                if i.mnemonic != "LDA":
                    pass
            a += i.size
        return out

    names = {0x47: ("maximum life", "$47"), 0x04AC: ("weapon levels 1-4", "$04AC"),
             0x04AD: ("weapon levels 5-8", "$04AD"), 0x04AE: ("weapon levels 9-12", "$04AE"),
             0x4A: ("attack", "$4A"), 0x4B: ("shield", "$4B"), 0x46: ("chip-maximum level", "$46"),
             0x6B: ("fire rate", "$6B")}
    normal = dict(stores(b0, 0x8000, 0x80D4, 0x8107))
    normal.setdefault(0x04AC, 0)
    normal.setdefault(0x04AD, 0)
    normal.setdefault(0x04AE, 0)
    normal.setdefault(0x46, 0)
    normal.setdefault(0x6B, 0)
    demo = dict(stores(b0, 0x8000, 0x8113, 0x8137))

    def show(k, v):
        if k in (0x04AC, 0x04AD, 0x04AE):
            return f"${v:02X} &mdash; " + ("every weapon level " + str(v & 3) if v and
                                          len({(v >> s) & 3 for s in (0, 2, 4, 6)}) == 1
                                          else "none owned" if not v else "mixed")
        return f"{v} (${v:02X})"

    p = ["<h1>Demo</h1>",
         '<p class="sub">Leave the title screen alone and the game plays itself. It is not a '
         "recording: the game builds a powered-up state, picks a random corridor, and feeds "
         "the ship button presses from a small table, held for random lengths of time.</p>"]
    p.append(_stats([("patterns", "31"), ("held for", "24-40 frames"), ("corridors", "0-15"),
                     ("lasts", "about 2 min")]))

    p.append('<h2 id="start">How it starts</h2>')
    p.append('<div class="note">Not on a timer: <strong>the title music starts it.</strong> The '
             "title loop (bank 0 <code>$835A</code>) returns as soon as <code>$0300</code> is "
             "non-zero, and song 1, the title theme, sets it itself: command <code>$94</code> "
             "&mdash; &ldquo;set global flag&rdquo;, which ORs its operand into "
             "<code>$0300</code> (<code>$93DA</code>) &mdash; stands at <code>$9D06</code>, at "
             "the end of the first channel's melody, just before its jump back to the start. "
             "The title's own countdown (<code>$F0</code>/<code>$F1</code>) leads somewhere "
             "else: to the story screen, &ldquo;LONG AGO&hellip;&rdquo;, and back.</div>")
    p.append('<ol class="desc">'
             "<li>The title loop returns to the reset path, which calls the game setup, bank 0 "
             "<code>$805B</code> (entry <code>$8003</code>) &mdash; the same routine a real new "
             "game uses.</li>"
             "<li>With Start <em>not</em> held (<code>$F7</code> bit 4) and outside the TGL game "
             "(<code>$30</code> bit 1), the setup builds the demo state and sets <code>$30</code> "
             "bit 7, the demo flag.</li>"
             "<li><code>$EB18</code> starts the game in a random corridor: "
             "<code>$51</code> = <code>$F9D1</code> AND <code>$0F</code>, so 0-15, where 0 is the "
             "opening flight.</li>"
             "<li>Every frame the ship's input is replaced (below).</li></ol>")

    p.append('<h2 id="state">The state it builds</h2>')
    p.append('<p class="desc">Bank 0 <code>$8107-$8145</code>. The values are read from the '
             "ROM's own <code>LDA #</code> operands as this page is built; &ldquo;new game&rdquo; "
             "is what the same routine leaves when Start is held.</p>")
    rows = "".join(f"<tr><td>{_h(names[k][0])}</td><td><code>{names[k][1]}</code></td>"
                   f"<td class=\"mono\">{show(k, normal.get(k, 0))}</td>"
                   f"<td class=\"mono\"><strong>{show(k, v)}</strong></td></tr>"
                   for k, v in demo.items() if k in names)
    p.append("<table><thead><tr><th>What</th><th>RAM</th><th>New game</th><th>Demo</th></tr>"
             f"</thead><tbody>{rows}"
             "<tr><td>selected weapon</td><td><code>$3C</code></td><td class=\"mono\">none</td>"
             "<td class=\"mono\"><strong>random 0-11</strong> (<code>$F9D1</code> AND "
             "<code>$0F</code>, 12-15 &rarr; 1)</td></tr>"
             "<tr><td>Power Chips</td><td><code>$4C</code>/<code>$4D</code></td>"
             "<td class=\"mono\">0</td><td class=\"mono\"><strong>full</strong> "
             "(<code>$815F</code>)</td></tr>"
             "<tr><td>demo flag</td><td><code>$30</code> bit 7</td><td class=\"mono\">clear</td>"
             "<td class=\"mono\"><strong>set</strong></td></tr></tbody></table>")
    p.append(listing(0, b0, 0x8000, 0x8107, 0x8176, {
        0x8107: "Start held? then a real new game", 0x810F: "the TGL game? likewise",
        0x8137: "random weapon", 0x8141: "the demo flag", 0x8143: "... ORed into $30",
        0x816B: "random", 0x8170: "$F4: where the pattern table starts"}))

    p.append('<h2 id="input">The input it invents</h2>')
    p.append('<div class="note"><strong>Neither recorded keypresses nor an AI.</strong> '
             "<code>$DAE1</code> (fixed-bank entry <code>$C02D</code>, called by the player's "
             "handler, bank 3 <code>$8CF3</code>) runs every frame. With <code>$30</code> bit 7 "
             "set it counts a hold timer <code>$F2</code> down; when it runs out it draws a new "
             "one, <code>$F9D1</code> AND <code>$0F</code> + <code>$18</code> &mdash; 24 to 40 "
             "frames &mdash; steps <code>$F4</code> = (<code>$F4</code> AND <code>$1F</code>) + 1 "
             "and loads the pattern <code>$DB32</code>,<code>$F4</code> into <code>$F3</code>. "
             "Then, every frame, it writes <code>$F3</code> into all four controller bytes: "
             "<code>$F7</code>/<code>$F8</code> (held) and <code>$F5</code>/<code>$F6</code> (just "
             "pressed) &mdash; so the fire buttons count as freshly pressed on every frame. The "
             "real controller has already been read by then; only its Start button matters "
             "(<code>$F493</code>).</div>")
    p.append(listing(7, b7, 0xC000, 0xDAE1, 0xDB22, {
        0xDAE1: "not the demo: straight to the direction", 0xDAE5: "the demo's own countdown",
        0xDAED: "time up: back to the title", 0xDAF0: "hold timer", 0xDAF4: "random ...",
        0xDAF9: "... + $18 (+ carry): 24-40 frames", 0xDAFD: "next pattern, 1-32",
        0xDB06: "the pattern", 0xDB0B: "into both pads, held and new", 0xDB15: "d-pad to $32"}))
    cells = []
    for y in range(1, 33):
        v = b7[0xDB32 + y - 0xC000]
        label = "+".join(n for bit, n in ((0x80, "A"), (0x40, "B"), (0x20, "Select"),
                                          (0x10, "Start"), (0x08, "Up"), (0x04, "Down"),
                                          (0x02, "Left"), (0x01, "Right")) if v & bit)
        odd = y == 32
        cells.append(f'<figure style="margin:0;text-align:center{";opacity:.75" if odd else ""}">'
                     f"{_pad_svg(v, 2, label)}<figcaption class=\"meta\">{y}: {_h(label)}"
                     f"{'<br>(reads $DB52)' if odd else ''}</figcaption></figure>")
    p.append('<h3>The 32 patterns, in order</h3>')
    p.append('<div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(140px,1fr));'
             f'gap:10px">{"".join(cells)}</div>')
    p.append('<p class="meta">Entries 1-31 are <code>$DB33-$DB51</code>, and every one holds A '
             "and B &mdash; the gun and the selected weapon &mdash; with a direction or none. The "
             "index runs 1 to 32, so <code>$DB32</code> itself is never read, and entry 32 is "
             "<code>$DB52</code>: the first byte of the tile decoder, the opcode "
             "<code>$A5</code>, which as buttons is A + Select + Down + Right. Select opens "
             "nothing, because <code>$F493</code> skips the pause and status-screen check "
             "during the demo. The starting entry is random (<code>$F4</code> = "
             "<code>$F9D1</code> AND <code>$1F</code>, bank 0 <code>$8170</code>), and "
             "<code>$F9D1</code> mixes the frame counter with RAM and ROM bytes, so no two "
             "demos play alike.</p>")
    dirs = [b7[0xDB22 + k - 0xC000] for k in range(16)]
    grid = {}
    for k, d in enumerate(dirs):
        if d not in grid:
            grid[d] = k
    arrow = {0: "&#8601;", 1: "&#8592;", 2: "&#8598;", 3: "&#8595;", 4: "&middot;",
             5: "&#8593;", 6: "&#8600;", 7: "&#8594;", 8: "&#8599;"}
    p.append('<p class="desc">Last, <code>$DB15</code> turns the d-pad into a direction for the '
             "ship, <code>$32</code> = <code>$DB22</code>[d-pad], for the demo and a player "
             "alike: a 3 &times; 3 grid, 4 the centre, opposite presses cancelling.</p>")
    p.append('<table style="width:auto"><tbody>' + "".join(
        "<tr>" + "".join(f'<td class="mono" style="text-align:center">{arrow[d]} {d}</td>'
                         for d in row) + "</tr>" for row in ((2, 5, 8), (1, 4, 7), (0, 3, 6)))
             + "</tbody></table>")

    p.append('<h2 id="end">How it ends</h2>')
    p.append('<ul class="desc">'
             "<li><strong>Its countdown runs out</strong> &mdash; <code>$F0</code>/<code>$F1</code>, "
             "set up with <code>$F0</code> = <code>$1C</code>: at most "
             "<code>$1C</code> &times; 256 frames, about two minutes (<code>$DAED</code>).</li>"
             "<li><strong>The stage ends</strong> &mdash; any stage change with the demo flag set "
             "(<code>$EBA2</code>).</li>"
             "<li><strong>A real Start press</strong> (<code>$F4A3</code>).</li></ul>"
             '<p class="desc">Each is <code>JMP $FF4A</code>: back into the reset path and '
             "the title screen.</p>")
    p.append('<div class="note warn"><strong>Not established.</strong> Everything here is read '
             "from the code; no savestate has been taken during a demo. Whether a demo ship can "
             "die, and what happens then, is not read.</div>")

    p.append('<h2 id="regions">Regions</h2>')
    for r in [x for x in rm.regions if x["id"] in DEMO_REGIONS]:
        p.append(_region_card(rm, r))
    return "".join(p)


ENDING_STEPS = [
    ("1. The boss dies", "bank 3 <code>$92EE</code> &rarr; <code>$931E</code> &rarr; "
     "<code>$9355</code>",
     "The boss phase <code>$70</code> waits at <code>$92EE</code> until the object in the boss "
     "slot no longer has type <code>$72</code>. In a corridor (<code>$30</code> bit 6) "
     "<code>$9355</code> plays song <code>$2F</code>, far-calls bank 6 <code>$8003</code>, and "
     "runs eight explosions (positions from <code>$93F2</code>, sound <code>$23</code>, four "
     "frames each). <code>$9387</code> adds two to <code>$70</code>."),
    ("2. The stage-end flag", "bank 3 <code>$93A3</code>-<code>$93EA</code>",
     "<code>$73</code> counts 90 frames, then song <code>$1F</code> and the victory song "
     "(<code>$1B</code> in a corridor, <code>$1A</code> in the labyrinth) play and the code waits "
     "for <code>$0300</code> to clear. In a corridor it then sets <code>$A0</code> bit 0 "
     "(<code>$93E8</code>). <strong>Corridor 21 is the exception:</strong> it only does this "
     "when the boss is type <code>$4D</code> (<code>$93B4</code>-<code>$93BC</code>); for the "
     "other five bosses of the gauntlet it just clears <code>$70</code> and returns."),
    ("3. The frame loop notices", "bank 7 <code>$E659</code> &rarr; <code>$EB18</code>",
     "The scroll step clears <code>$A0</code> bit 2 and, if bit 0 is set, "
     "<code>JMP $EB18</code>. With the player alive that reaches <code>$EB78</code>; in a "
     "corridor (<code>$30</code> bit 6) and not in the demo, <code>$EB9C</code> falls to "
     "<code>$EBFE</code>, which clears <code>$70</code> and, because <code>$30</code> bits 5-6 "
     "are set, goes to <code>$EC54</code> and then <code>$ECBD</code>."),
    ("4. Which corridor ended", "bank 7 <code>$ECBD</code>",
     "<code>$51</code> = 0 &rarr; <code>$ECE7</code> (the opening flight). 1-20 &rarr; "
     "<code>$ECE4</code>: mark it cleared (<code>$EFBA</code>) and run the stage-clear routine "
     "<code>$F506</code>. <strong>21</strong> &rarr; <code>$ECC7</code>: <code>$F506</code>, "
     "far call bank 0 <code>$8012</code> (&rarr; <code>$88F5</code>, a starfield of blank tiles "
     "and star tiles from the script at <code>$88B7</code>), then far call bank 2 "
     "<code>$801B</code> (&rarr; <code>$8836</code>, a wordless scene: see below) and "
     "<code>INC $51</code> &rarr; <strong>22</strong>, loaded through <code>$EC94</code>. "
     "<strong>22</strong> &rarr; <code>$ECE1</code>: <code>$F506</code> first, and it never "
     "returns, so corridor 22 is never marked cleared."),
    ("5. Stage clear, for 22", "bank 7 <code>$F506</code>-<code>$F5DE</code>",
     "Corridors 0 and 22 skip the clear fanfare (<code>$F50A</code>/<code>$F50C</code>). The "
     "scroll target goes to 0 and the code loops until the speed is 0. "
     "<code>$F4A7</code> gives no key for corridors above 10, so 22 takes "
     "<code>$F544</code> and goes to <code>$F5DE</code>."),
    ("6. The ship leaves", "bank 7 <code>$F5DE</code>-<code>$F66B</code>",
     "Slot 0 becomes type 5 with metasprite 1. Corridors 0 and 22 start it at velocity 0 with "
     "<code>$0638</code> = 1 and accelerate it toward y = 0 (<code>$F648</code>, accel "
     "<code>$20</code>) until it leaves the screen; every other corridor starts it at "
     "velocity &minus;2."),
    ("7. Final score", "bank 7 <code>$F667</code>-<code>$F6AB</code>",
     "Only for <code>$51</code> = 22 (corridor 0 goes to <code>$F659</code>, the labyrinth). "
     "It prints &ldquo;YOUR FINAL SCORE&rdquo; at PPU <code>$2086</code>, a <code>0</code> tile at "
     "<code>$20CE</code> and the six score digits at <code>$20C8</code> "
     "(<code>$E118</code>), then far-calls bank 2 <code>$8021</code>."),
    ("8. The ending routine", "bank 2 <code>$8A69</code>-<code>$8AFF</code>",
     "<code>LDX #$FF / TXS</code> throws the stack away, so nothing below it ever returns. "
     "<code>$30</code> is cleared. <strong>A normal game:</strong> loads tile block 4 of bank 1 "
     "(<code>$D7F9</code>), writes attribute bytes (<code>$D5CC</code> items at "
     "<code>$8A88</code>-<code>$8ABF</code>), blits a 10 &times; 13 tile picture from "
     "<code>$8B05</code> to PPU <code>$21F1</code> (<code>$D99C</code>), copies 22 sprites from "
     "<code>$8B87</code> into OAM and 25 palette bytes from <code>$8BDF</code> to "
     "<code>$0180</code>. <strong>A TGL game</strong> (<code>$30</code> bit 1 before it was "
     "cleared) takes <code>$8A3D</code>: attributes, the word CONGRATULATIONS at "
     "<code>$210C</code>, a white backdrop colour and no picture. Both then run "
     "<code>$EDB7</code>, start song <code>$0F</code> and far-call bank 0 <code>$8015</code>. "
     "<strong>The two endings are drawn below</strong>, from running this code."),
    ("9. The credits", "bank 0 <code>$8915</code> &rarr; <code>$8927</code>",
     "Eight credit screens after MISSION COMPLETE, each held for the seconds in "
     "<code>$8BB2</code> (<code>$F0</code> counts them), then it waits for Start "
     "(<code>$F5</code> bit 4) and draws a tenth screen: PASSWORD TGL. After that "
     "<code>$899F</code> loops forever (<code>$89AE</code>-<code>$89B3</code>), animating two "
     "sprites. <strong>Nothing leaves this loop; only the reset button does.</strong>"),
]


def _ending_page(rm, out=None):
    """What happens when the final boss is beaten, from the boss routine to the last screen."""
    b3 = rm.prg_bank(3)
    boss_song = " ".join(f"${b3[0x9168 - 0x8000 + c]:X}" for c in range(23))
    p = ["<h1>The ending</h1>",
         '<p class="sub">From the final boss&rsquo;s last hit to the screen the game stops on. '
         "Every step is read from the code and linked to the next by an address; the whole chain "
         "is unchecked on hardware.</p>",
         '<div class="note"><strong>Corrects earlier notes.</strong> This project said the ending '
         "follows corridor 21. It follows <strong>corridor 22</strong>: after corridor 21 a "
         "cutscene plays, <code>$51</code> becomes 22 (bank 7 <code>$ECDC</code>), and the "
         "final boss, It (type <code>$4F</code>, <code>$9151[22]</code>), is fought in a short "
         "corridor of its own. The boss-fight songs at bank 3 <code>$9168</code> have 23 "
         f"entries, 0-22 &mdash; one per corridor including that one: {boss_song}.</div>",
         "<table><thead><tr><th>Step</th><th>Where</th><th>What it does</th></tr></thead><tbody>"]
    for step, where, what in ENDING_STEPS:
        p.append(f"<tr><td><strong>{step}</strong></td><td>{where}</td><td>{what}</td></tr>")
    p.append("</tbody></table>")
    if out is not None:
        from tgl import ending
        bg, full, facts = ending.build(rm, NES_RGB)
        out.mkdir(parents=True, exist_ok=True)
        full.save(out / "ending-picture.png", optimize=True)
        bg.save(out / "ending-picture-bg.png", optimize=True)
        p.append('<h2 id="picture">The ending picture</h2>')
        p.append('<p class="sub">Rebuilt from the ROM exactly as bank 2 <code>$8A69</code> '
                 "builds it: tile block 4 of bank 1 (109 tiles) in pattern table 1, the 10 &times; "
                 "13 tile frame at <code>$8B05</code> placed at tile column 17, row 15, "
                 "attribute bytes from the <code>$8A88</code> fills, 25 palette bytes from "
                 "<code>$8BDF</code>, and the 22 sprites at <code>$8B87</code>.</p>")
        p.append('<p><img src="ending-picture.png" width="512" height="480" alt="The ending '
                 'picture: a framed portrait, a planet and stars" '
                 'style="image-rendering:pixelated;max-width:100%;height:auto"></p>')
        p.append('<p class="meta">Left out of the picture: sprites 0 and 1 (Y = <code>$F8</code>, '
                 "off screen as copied; the credits routine at <code>$8998</code> moves "
                 "sprites at <code>$02F0-$02FF</code>) and everything else on the screen, which "
                 'is taken as blank. <a href="ending-picture-bg.png">Background only</a>.</p>')
        p.append('<div class="note warn"><strong>Checked by fit, not by hardware.</strong> '
                 "The background reads pattern table 1 only because every tile the frame names "
                 "(<code>$B0-$ED</code>, border <code>$F2-$F9</code>) lies inside block 4's "
                 "range <code>$8F-$FB</code>; nothing here read <code>$2000</code>. That the "
                 "result is a coherent portrait is the evidence. Tile <code>$20</code>, the "
                 "frame's empty cells, is drawn blank.</div>")
    if out is not None and (out / "ending-normal.png").exists():
        p.append('<h2 id="endings">Normal ending and TGL ending</h2>')
        p.append('<p class="sub">The game checks <code>$30</code> bit 1, the TGL flag, once, at '
                 "bank 2 <code>$8A69</code>, and clears <code>$30</code> straight after, so "
                 "everything past that point &mdash; the credits included &mdash; is the same for "
                 "both. The difference is the screen it draws first. Both images are the screen "
                 "when the routine far-calls the credits, from running the ROM code (below).</p>")
        p.append('<table><thead><tr><th>Normal game</th><th>TGL game</th></tr></thead><tbody><tr>'
                 '<td><img src="ending-normal.png" width="384" alt="Normal ending: final score, '
                 'portrait, planet and stars" style="image-rendering:pixelated;max-width:100%">'
                 '</td><td><img src="ending-tgl.png" width="384" alt="TGL ending: final score and '
                 'CONGRATULATIONS on black" style="image-rendering:pixelated;max-width:100%">'
                 "</td></tr><tr><td>YOUR FINAL SCORE, the portrait frame, the planet and stars, "
                 "25 palette bytes from <code>$8BDF</code>, song <code>$0F</code>.</td>"
                 "<td>YOUR FINAL SCORE and CONGRATULATIONS on black: <code>$8A3D</code> writes "
                 "only attributes and the text, sets <code>$0181</code> to white "
                 "(<code>$30</code>), and skips the picture, the sprites and the palette copy. "
                 "The last glyph, tile <code>$5B</code>, draws as a full stop with the font "
                 "loaded at that point, so the word ends &ldquo;CONGRATULATIONS.&rdquo;</td>"
                 "</tr></tbody></table>")
    if out is not None and (out / "cutscene-film.png").exists():
        p.append('<h2 id="cutscene">The scene after corridor 21</h2>')
        p.append('<p class="sub">Bank 2 <code>$8836</code>, run for 689 frames (11.5 seconds) from '
                 "<code>$ECCA</code> to the <code>INC $51</code> at <code>$ECDC</code>. The code "
                 "draws a starfield (the script at bank 0 <code>$88B7</code>), loads the planet's "
                 "tiles and the ship's (<code>$F6E5</code>, <code>$F717</code>), then "
                 "steps a phase counter <code>$0638</code> (+<code>$40</code> a frame, one step "
                 "per four frames): the ship eases toward y = 0 (steps 0-15), moves down "
                 "slightly (16-31), turns through eight metasprites <code>$88A6</code> "
                 "(32-63), then at 64-127 spawns explosions (type 7, sounds <code>$22</code>/"
                 "<code>$23</code>) and flashes the backdrop <code>$32</code> two frames in "
                 "seven; from step 96 it erases the planet's tiles in a shuffled order "
                 "(<code>$88AE</code>), and from step 128 accelerates the ship up the screen "
                 "until it leaves.</p>")
        p.append('<p><img src="cutscene-film.png" width="780" alt="24 frames of the scene" '
                 'style="max-width:100%;height:auto"></p>')
        p.append('<p><img src="cutscene.gif" width="512" height="480" alt="The scene, animated" '
                 'style="image-rendering:pixelated;max-width:100%;height:auto"></p>')
        p.append('<div class="note warn"><strong>Run, not recorded.</strong> These pictures come '
                 "from <code>tools/render-ending.py</code>, which runs the ROM&rsquo;s own code on "
                 "a small NES model (<code>tools/tgl/cpu.py</code>: no cycle accuracy, no IRQ, no "
                 "audio, one scroll value per frame) starting from a savestate of corridor 15, "
                 "with <code>$51</code>, <code>$30</code>, the stage-clear state and the "
                 "palette of corridor 21's last row put in. Sprites and tiles are what the "
                 "code made of the savestate's RAM and CHR. The savestate is not in the "
                 "repository, so the images are committed rather than built. The layout of "
                 "the scene (what moves when) is the code's; exact pixels, colours and "
                 "timing are the model's and have not been compared with hardware.</div>")
    p.append('<div class="note warn"><strong>Not established.</strong> What the cutscene at bank 2 '
             "<code>$8836</code> shows beyond a ship animating over stars (it is wordless and "
             "was only skimmed). What sprites 0 and 1 are (they start off screen). "
             "Corridor 22&rsquo;s "
             "music is song <code>$19</code>, read from <code>$EF2A[22]</code> at "
             "<code>$EF40</code> (the code does read it; nothing else says it is meant). The "
             "wordless cutscene&rsquo;s timing.</div>")
    p.append('<h2 id="regions">Regions</h2>')
    for r in [x for x in rm.regions if _is_ending(x)]:
        p.append(_region_card(rm, r))
    return "".join(p)


def _labyrinth_rooms(rm) -> str:
    """How a room is encoded, and where the entrances, key doors, items and minibosses are."""
    import sys
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
    from tgl import labyrinth as lab
    from tgl import worldmap as wm

    b5, b7 = rm.prg_bank(5), rm.prg_bank(7)
    recs, _ = wm.records(b5)
    ext = _external()
    facts = ext["facts"] if ext else []
    names = next((f.get("weapon_names") for f in facts if f.get("weapon_names")), [])
    icons = next((f.get("item_icons") for f in facts if f.get("item_icons")), {})

    def item(i):
        if i is None:
            return "&mdash;"
        n = names[i] if i < 12 and i < len(names) else icons.get(str(i))
        return f"{_h(n)} <span class=\"meta\">({i})</span>" if n else \
            f"<span class=\"meta\">value {i}, not an icon &mdash; not established</span>"

    pos = lambda d: f"{d['col']}, {d['row']}"
    specials = lab.special_rooms(b5, b7, recs)
    import importlib.util
    mods = {}
    for n in ("parse-structs", "render-labyrinth"):
        spec = importlib.util.spec_from_file_location(
            n.replace("-", "_"), Path(__file__).resolve().parents[1] / f"{n}.py")
        mods[n] = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mods[n])
    rl, ps = mods["render-labyrinth"], mods["parse-structs"]
    areas, grid = rl.room_areas(recs), lab.grid(recs)
    build = lambda r: ps.build_room(b5, rl.room_ram(recs, grid, r, areas[(r["row"], r["col"])]))
    items = lab.item_rooms(b5, recs, build)
    bosses = lab.miniboss_rooms(b5, recs)
    loops = lab.loop_rooms(recs)
    doors = lab.key_doors(recs)
    msgs = []
    for i in range(21):
        a = b5[0x160F + 2 * i] | b5[0x1610 + 2 * i] << 8
        s, k = [], a
        while b5[k - 0x8000] and len(s) < 400:
            c = b5[k - 0x8000]
            s.append(" " if c in (1, 0x0D) else chr(c) if 32 <= c < 127 else "")
            k += 1
        msgs.append(" ".join("".join(s).replace("[", ".").replace("<", ",")
                             .replace("^", '"').replace("]", "!").replace(";", ";").split()))

    p = ['<h2 id="rooms">How a room is encoded</h2>',
         '<p class="sub">The labyrinth is one 24 &times; 24 grid of map records in bank 5 '
         "(<code>$8A6E</code>), walked 24 to a row by <code>$80F5</code>. A record is "
         "<code>(byte 0 AND $0F) + 1</code> bytes, and its first three bytes say what the "
         "rest holds.</p>"]
    p.append("<table><thead><tr><th>Byte</th><th>Bits</th><th>Meaning</th><th>Read by</th>"
             "</tr></thead><tbody>"
             "<tr><td rowspan=4>0</td><td>0-3</td><td>length &minus; 1; <code>$80</code> "
             "exactly is an empty cell</td><td><code>$8103</code></td></tr>"
             "<tr><td>4</td><td>a room-layout pointer is present</td><td><code>$8243</code>"
             "</td></tr>"
             "<tr><td>5-6</td><td>room kind: <code>$00</code> plain, <code>$20</code> item "
             "(with a sub-id), <code>$40</code> miniboss (with a sub-id), <code>$60</code> "
             "loop gate</td><td><code>$8121</code> &rarr; <code>$5D</code></td></tr>"
             "<tr><td>7</td><td><strong>a special screen, not a room</strong> &mdash; "
             "corridor entrances, shops, messages, the progress recorder; every opening into "
             "it gets a key door</td><td><code>$EC5B</code>, <code>$82DD</code></td></tr>"
             "<tr><td rowspan=3>1</td><td>0-2</td><td>the key that reveals the cell on the "
             "status-screen map, and the key a door into it needs</td><td><code>$8860</code>, "
             "<code>$82DD</code></td></tr>"
             "<tr><td>3</td><td>the room has enemies (a spawn script follows)</td>"
             "<td><code>$8121</code> &rarr; <code>$57</code></td></tr>"
             "<tr><td>4-7</td><td>open exits S, E, W, N (bits 4-7)</td><td><code>$82DD</code>"
             ", <code>$8071</code></td></tr>"
             "<tr><td>2</td><td>all</td><td>bit 7 clear: the labyrinth <strong>area</strong> "
             "(low nibble), loaded into <code>$50</code> on entering (<code>$EEE0</code>). "
             "Bit 7 set: a <strong>corridor entrance</strong>, the low seven bits its number. "
             "In a special screen without bit 7: the screen type</td><td><code>$EECC</code>, "
             "<code>$EE1D</code></td></tr>"
             "<tr><td>3&hellip;</td><td></td><td>in this order, each only if its flag says so: "
             "the <strong>sub-id</strong> (kinds <code>$20</code>/<code>$40</code> &rarr; "
             "<code>$5E</code>), the <strong>spawn script</strong> id (byte 1 bit 3 &rarr; "
             "<code>$57</code>, 0 read as 1), the two-byte <strong>layout pointer</strong> "
             "(byte 0 bit 4)</td><td><code>$8121</code>, <code>$8243</code></td></tr>"
             "</tbody></table>")
    p.append('<div class="note"><strong>Drawing a room</strong> (<code>$8155</code>, then '
             "<code>$8243</code>): the area picks a <em>structure</em> &mdash; a pattern tiled "
             "over the 16 &times; 12 cell buffer, plus four overlay pieces &mdash; and a <em>door "
             "set</em>, whose last four pieces wall off each exit that is closed or leads to an "
             "empty cell. The record's layout then goes on top: one of 19 room shapes filled "
             "with a metatile, plus up to seven runs of other metatiles. The sub-id is also the "
             "room's <strong>flag</strong> in the bit array at <code>$04A0</code> "
             "(<code>$EFE0</code> tests, <code>$EFE9</code> sets): a taken item or a beaten "
             "miniboss stays gone. <strong>Checks:</strong> all 370 non-empty records are "
             "exactly as long as their flags say; the room rebuilt from the ROM matches the "
             "labyrinth savestate's screen in 191 of 192 cells, to the pixel.</div>")

    # ---------------------------------------------------------------- annotated map
    kinds = {}
    for d in specials:
        kinds[(d["row"], d["col"])] = ("E", "#e8b84a") if "corridor" in d else \
            {1: ("P", "#8fd18f"), 2: ("$", "#f07dd8"), 6: ("$", "#f07dd8"),
             3: ("?", "#9ec7ff")}.get(d["screen"], ("S", "#ccc"))
    for d in items:
        kinds[(d["row"], d["col"])] = ("I", "#5fe0e0")
    for d in bosses:
        kinds[(d["row"], d["col"])] = ("M", "#ff6b5e")
    for d in loops:
        kinds[(d["row"], d["col"])] = ("L", "#c0a0ff")
    svg = ['<svg viewBox="0 0 2400 1800" style="position:absolute;inset:0;width:100%;'
           'height:100%" xmlns="http://www.w3.org/2000/svg" font-family="ui-monospace,'
           'monospace" font-weight="700">']
    for d in doors:
        r, c = d["row"], d["col"]
        x, y = c * 100 + 50, r * 75 + 37.5
        dx, dy = {"N": (0, -37), "S": (0, 37), "W": (-50, 0), "E": (50, 0)}[d["side"]]
        svg.append(f'<rect x="{x + dx - 7}" y="{y + dy - 7}" width="14" height="14" '
                   f'fill="#ffd21f" stroke="#000" stroke-width="2"/>')
    for (r, c), (ch, col) in kinds.items():
        label = ch
        d = next((s for s in specials if (s["row"], s["col"]) == (r, c)), None)
        if d and "corridor" in d:
            label = str(d["corridor"])
        svg.append(f'<circle cx="{c * 100 + 50}" cy="{r * 75 + 37.5}" r="22" fill="{col}" '
                   f'stroke="#000" stroke-width="3"/><text x="{c * 100 + 50}" '
                   f'y="{r * 75 + 46}" font-size="{24 if len(label) > 1 else 26}" '
                   f'text-anchor="middle">{_h(label)}</text>')
    svg.append("</svg>")
    p.append('<h2 id="where">Where everything is</h2>')
    p.append('<div style="position:relative;width:100%;aspect-ratio:4/3">'
             '<img src="labyrinth-map-half.png" alt="The labyrinth with its rooms marked" '
             'style="position:absolute;inset:0;width:100%;height:100%">' + "".join(svg) +
             "</div>")
    p.append('<p class="meta">Numbers: corridor entrances. <strong>I</strong> item room, '
             "<strong>M</strong> miniboss, <strong>L</strong> loop gate, <strong>$</strong> "
             "shop, <strong>?</strong> message, <strong>P</strong> progress recorder. Yellow "
             f"squares: the {len(doors)} key doors, on the side of the room they are in. "
             "Special screens are drawn as a new game meets them &mdash; every corridor still "
             "sealed.</p>")

    # ---------------------------------------------------------------- entrances
    ents = sorted((d for d in specials if "corridor" in d), key=lambda d: d["corridor"])
    p.append('<h2 id="entrances">Corridor entrances</h2>')
    p.append('<div class="note">A corridor entrance is a record with byte 0 bit 7 (a special '
             "screen) and byte 2 bit 7; the low seven bits are the corridor. The records "
             "carry the numbers <strong>1 to 21, each exactly once</strong>. On entering, "
             "<code>$EE1D</code> chooses the screen: while the corridor is uncleared (bit "
             "c&minus;1 of <code>$04A9</code>, <code>$EFAC</code>) it is screen 8, the sealed "
             "gate &mdash; <code>$9F44</code> shows <em>Corridor</em> and the number and sets "
             "out two type-<code>$35</code> objects, the two halves of the seal; corridor 21's "
             "is screen 0, a bare gate, until corridors 1-10 are all cleared. A room change "
             "with no exit direction (<code>$A4</code> = 4) inside an entrance screen starts "
             "the corridor (<code>$EC5B</code> &rarr; <code>$EC8C</code>: <code>$51</code> = "
             "byte 2 AND <code>$7F</code>); what sets that on the gate is not read yet. Once "
             "cleared the entrance becomes screen 5, which also sets "
             "out a reward item, <code>$EF40</code>[corridor]. The status-screen map marks an "
             "entrance while its corridor is uncleared (<code>$C07B</code>).</div>")
    p.append("<table><thead><tr><th>Corridor</th><th>Map (x, y)</th><th>Key to enter</th>"
             "<th>Seal hint</th><th>Reward once cleared</th></tr></thead><tbody>" + "".join(
                 f"<tr><td>{d['corridor']}</td><td>{pos(d)}</td><td>{d['key'] or 'none'}</td>"
                 f"<td class=\"desc\">{_h(msgs[10 + d['corridor']]) if 2 <= d['corridor'] <= 10 else ('fire at the gate (message 2)' if d['corridor'] == 1 else '')}</td>"
                 f"<td>{item(d['reward'])}</td></tr>" for d in ents) + "</tbody></table>")
    p.append('<p class="meta">Seal hints are dialogue messages 12-20 (corridors 2-10), '
             "given by message screens; each seal is its own piece of code, not read yet. "
             "Corridor 4's is the one the ROM shows plainly: the shop controllers call "
             "<code>$A2E7</code>, which looks for the player walking back and forth in the "
             "move history, and then show message 11 and set bit 3 of <code>$04B1</code>. "
             "Whether a cleared corridor's reward can be taken more than once is not "
             "established.</p>")

    # ---------------------------------------------------------------- key doors
    p.append('<h2 id="doors">Key doors</h2>')
    p.append('<div class="note"><strong>Where:</strong> <code>$82DD</code> looks at each of '
             "the room's open exits in turn, and if <em>this</em> record's byte 0 or the "
             "<em>neighbour's</em> has bit 7 set &mdash; either side is a special screen &mdash; "
             "it writes a door (metatile 8) into that opening of the cell buffer: row 3 column "
             "7 (north), row 7 column 2 (west), row 7 column 13 (east), row 10 column 7 "
             "(south). <strong>Which key:</strong> the same pass stores the neighbour's byte 1 "
             "AND 7 in <code>$58-$5B</code> (N W E S). So <strong>every door into a special "
             "screen needs that screen's key</strong>, and the doors out of it need the keys "
             "of the rooms around it. <strong>Opening:</strong> bank 3 <code>$8FF5</code> "
             "lets the player through when the key is 0 or bit k&minus;1 of <code>$04B0</code> "
             "&mdash; the key inventory &mdash; is set; <code>$9045</code> otherwise holds "
             "them at the edge of the screen. The dialogue calls these the rooms' "
             "&ldquo;Warp panel&rdquo; doors.</div>")
    by_key = {}
    for d in doors:
        by_key[d["key"]] = by_key.get(d["key"], 0) + 1
    p.append(_stats([(f"key {k}" if k else "no key", str(n)) for k, n in sorted(by_key.items())]))

    # ---------------------------------------------------------------- items
    p.append('<h2 id="items">Items</h2>')
    p.append('<div class="note"><strong>Item rooms</strong> are kind <code>$20</code> '
             "records that are rooms (byte 0 bit 7 clear). <code>$A3BB</code> takes the "
             "sub-id; the item is <code>$A377</code>[sub-id], an icon number. The room's "
             "layout puts <strong>metatile 6</strong> where the item stands &mdash; it looks "
             "like the block tile, metatile 4, but its fifth byte is <code>$10</code>, and "
             "when the rows are drawn that nibble spawns entry 1 of spawn list "
             "<code>$AF61</code>: type <code>$31</code>, the item object, which "
             "<code>$84CB</code> gives icon <code>$55</code>. Taking it (bank 2 "
             "<code>$8669</code>) sets the sub-id's flag, and from then on <code>$A425</code> "
             "turns metatile 6 into floor before the room is drawn. The dialogue: &ldquo;I "
             "put some weapons in these boxes.&rdquo; <strong>Check:</strong> rebuilding "
             "every room from the ROM, metatile 6 occurs <strong>exactly once in each of the "
             f"{len(items)} item rooms and in no other room</strong>.</div>")
    cells = lambda d: ", ".join(f"({i % 16}, {i // 16})" for i in d["cells"]) or "&mdash;"
    p.append("<table><thead><tr><th>Map (x, y)</th><th>Sub-id</th><th>Item</th>"
             "<th>Cell (column, row)</th></tr></thead><tbody>" + "".join(
                 f"<tr><td>{pos(d)}</td><td>{d['sub']}</td><td>{item(d['item'])}</td>"
                 f"<td class=\"mono\">{cells(d)}</td></tr>" for d in items) +
             "</tbody></table>")
    shops = [d for d in specials if d["screen"] in (2, 6)]
    p.append('<h3>The round creature&rsquo;s shops</h3>')
    p.append('<p class="desc">Special screens 2 and 6. Screen 6 (<code>$A076</code>) sells one '
             "ware from <code>$A067</code> + 3 &times; <code>$A377</code>[sub-id]: "
             "[price lo][price hi][icon]. Screen 2 (<code>$9FE9</code>) lays out three from "
             "<code>$A04E</code> + 5 &times; <code>$A377</code>[sub-id]: [price lo][price hi] "
             "and three values given to the three type-<code>$33</code> wares; its message "
             "says only one can be bought. Once bought (flag set) either becomes screen 7, "
             "&ldquo;Any luck?&rdquo;. Prices are in Power Chips.</p>")
    p.append("<table><thead><tr><th>Map (x, y)</th><th>Screen</th><th>Key</th><th>Price</th>"
             "<th>Wares</th></tr></thead><tbody>" + "".join(
                 f"<tr><td>{pos(d)}</td><td>{d['screen']}</td><td>{d['key'] or 'none'}</td>"
                 f"<td class=\"mono\">{d['price']}</td><td>{'; '.join(item(w) for w in d['wares'])}"
                 "</td></tr>" for d in shops) + "</tbody></table>")

    # ---------------------------------------------------------------- minibosses
    p.append('<h2 id="minibosses">Minibosses</h2>')
    p.append('<div class="note"><strong>Miniboss rooms</strong> are kind <code>$40</code>. '
             "<code>$A663</code> tests the sub-id's flag and, while it is clear, reads a "
             "three-byte record at <code>$A6A3 + $A682</code>[sub-id]: the boss's object type "
             "(into <code>$72</code>) and a graphics-load stream (<code>$28</code>/"
             "<code>$29</code>), then sets <code>$70 = 1</code> &mdash; the same boss phase "
             "the corridors use (bank 3 <code>$9184</code>), which spawns type "
             "<code>$72</code> and waits for it. The flag is set when it is beaten, so it "
             "does not come back. Sub-ids run 11-32; 13 records serve the 22 rooms.</div>")
    p.append("<table><thead><tr><th>Map (x, y)</th><th>Sub-id</th><th>Object type</th>"
             "<th>Graphics stream</th></tr></thead><tbody>" + "".join(
                 f"<tr><td>{pos(d)}</td><td>{d['sub']}</td><td><a href=\"enemies.html\">"
                 f"<code>${d['type']:02X}</code>{_tn(d['type'])}</a></td><td><code>${d['stream']:04X}</code>"
                 "</td></tr>" for d in bosses) + "</tbody></table>")

    # ---------------------------------------------------------------- the rest
    p.append('<h2 id="other">Other special screens, and loop gates</h2>')
    cnt = {}
    for d in specials:
        cnt[d["screen"]] = cnt.get(d["screen"], 0) + 1
    p.append("<table><thead><tr><th>Screen</th><th>What it is</th><th>Records</th></tr>"
             "</thead><tbody>" + "".join(
                 f"<tr><td>{s}</td><td>{_h(t)}</td><td class=\"mono\">{cnt.get(s, 0)}</td>"
                 "</tr>" for s, t in lab.SCREENS.items()) + "</tbody></table>")
    mscreens = sorted((d for d in specials if d["screen"] == 3), key=lambda d: d["message"])
    p.append('<p class="desc"><strong>Messages</strong> (screen 3, <code>$9FC4</code>): a type-'
             "<code>$34</code> object shows dialogue message number <em>sub-id</em>.</p>")
    p.append("<table><thead><tr><th>Map (x, y)</th><th>Message</th><th>Text</th></tr></thead>"
             "<tbody>" + "".join(
                 f"<tr><td>{pos(d)}</td><td>{d['message']}</td><td class=\"desc\">"
                 f"{_h(msgs[d['message']][:220])}{'&hellip;' if len(msgs[d['message']]) > 220 else ''}"
                 "</td></tr>" for d in mscreens) + "</tbody></table>")
    p.append('<p class="desc"><strong>The progress recorder</strong> (screen 1, '
             "<code>$9FB6</code>): message 4, &ldquo;Do you want me to record your "
             "progress?&rdquo;, and it keeps the map position (<code>$52</code>/<code>$53</code> "
             "&rarr; <code>$7C</code>/<code>$7D</code>) &mdash; where a password game "
             "resumes.</p>")
    p.append('<p class="desc"><strong>Loop gates</strong> (kind <code>$60</code>, '
             f"{len(loops)} rooms, <code>$A3DB</code>): every move pushes its direction onto a "
             "ten-deep history at <code>$04F0</code>. Entering one of these rooms adds up the "
             "latest moves as (x, y) steps from <code>$A41B</code>; if any run of them sums to "
             "zero &mdash; the player walked a loop back into this room &mdash; the room's "
             "metatiles 4 and 5 become 3, opening its blocks.</p>")
    return "".join(p)


def _metatiles_svg(chr_tiles, b5, ptr, base, pals, backdrop, px=2, per_row=16):
    """32 metatiles of one set window, as the PPU draws them: four tiles each (TL TR BL BR
    = bytes 0-3, $FF blank), coloured by attribute (byte 4 AND 3, via $0199), colour 0 the
    backdrop. A tile the scenes never load is drawn as a dashed outline."""
    runs: dict[tuple, list[str]] = {}
    missing = []
    w, h = per_row * 17 - 1, (32 // per_row) * 17 - 1
    for i in range(32):
        a = ptr + 5 * i - 0x8000
        if a + 5 > len(b5):
            break
        t4, attr = list(b5[a:a + 4]), b5[a + 4]
        pal = pals[attr & 3]
        ox, oy = (i % per_row) * 17, (i // per_row) * 17
        for k, t in enumerate(t4):
            tx, ty = ox + (k % 2) * 8, oy + (k // 2) * 8
            if t == 0xFF:
                continue
            tile = chr_tiles.get((t + base) & 0xFF)
            if tile is None:
                missing.append((tx, ty))
                continue
            for y in range(8):
                x = 0
                while x < 8:
                    v = ((tile[y] >> (7 - x)) & 1) | (((tile[8 + y] >> (7 - x)) & 1) << 1)
                    run = 1
                    while x + run < 8 and (((tile[y] >> (7 - x - run)) & 1)
                                           | (((tile[8 + y] >> (7 - x - run)) & 1) << 1)) == v:
                        run += 1
                    c = backdrop if v == 0 else pal[v - 1]
                    runs.setdefault(c, []).append(f"M{tx + x} {ty + y}h{run}v1h-{run}z")
                    x += run
    out = [f'<svg viewBox="0 0 {w} {h}" width="{w * px}" style="max-width:100%;height:auto;'
           'image-rendering:pixelated" xmlns="http://www.w3.org/2000/svg">']
    for c, d in runs.items():
        out.append(f'<path fill="rgb{tuple(c)}" d="{"".join(d)}"/>')
    for x, y in missing:
        out.append(f'<rect x="{x + .5}" y="{y + .5}" width="7" height="7" fill="none" '
                   'stroke="currentColor" stroke-opacity=".4" stroke-width=".5" '
                   'stroke-dasharray="1 1"/>')
    out.append("</svg>")
    return "".join(out)


def _labyrinth_page(rm):
    import sys
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
    from tgl import scene as sc

    b5 = rm.prg_bank(5)
    pal = lambda i: [NES_RGB[b5[0x330A + 3 * i + k] & 0x3F] for k in range(3)]
    backdrop = NES_RGB[0x0F]

    def slots(seq):
        out = [None] * 8
        for s in seq:
            i = sc.scene(b5, s)[2]
            if i == 0xFF:
                continue
            _, _, pl, _ = sc.nt_record(b5, i)
            for k, v in enumerate(sc.palette_list(b5, pl)):
                if v != 0xFF:
                    out[k] = v
        return out

    p = ["<h1>Labyrinth</h1>",
         '<p class="sub">The whole labyrinth drawn from the ROM; how a room is encoded; where '
         'the <a href="#entrances">corridor entrances</a>, <a href="#doors">key doors</a>, '
         '<a href="#items">items</a> and <a href="#minibosses">minibosses</a> are; and every '
         "area&rsquo;s metatiles &mdash; the 16&times;16 blocks rooms are built from.</p>"]
    p.append('<div class="note"><strong>How an area gets its look.</strong> Labyrinth area '
             "<em>n</em> is <strong>scene <em>n</em> + 5</strong> (bank 7 <code>$EEE0</code> "
             "stores <code>$50 + 5</code> in <code>$5C</code>), loaded after the common "
             "scenes 0 and 32 by bank 5 <code>$ACA9</code>. A scene is three bytes at "
             "<code>$AD91</code>: a <strong>tile list</strong> (blocks decompressed into "
             "background CHR), a <strong>set record</strong> (up to eight metatile windows "
             "into <code>$0460</code>) and a <strong>palette list</strong>. A room cell's byte "
             "picks set = bits 5-7 and metatile = bits 0-4; a metatile is four tile numbers and "
             "a fifth byte whose low bits choose the palette and whose high nibble names a "
             "ground object. Areas 1-2, 3-4, 5-6, 7-8 and 9-10 share scene data, so this page "
             "draws six tilesets.</div>")
    p.append('<div class="note"><strong>Checked against a labyrinth savestate</strong> (area 0): '
             "replaying scenes 0, 32, a special room and 5 rebuilds the background pattern "
             "table <strong>159 of 159</strong> tiles; the eight set pointers match "
             "<strong>8 of 8</strong>; all eight palette slots match; and <strong>all 192</strong> "
             "cells of the room on screen are metatiles of the live sets. "
             "<code>tools/parse-scenes.py --verify</code> repeats the set and room checks.</div>")

    p.append('<h2 id="map">The whole labyrinth</h2>'
             '<p class="sub">All 24 &times; 24 map cells, every room drawn the way the game '
             "draws it &mdash; structure, door set and exit walls, then the room layout &mdash; "
             "with its area's tiles, metatiles and palettes. Background only: no objects, no "
             'key doors. <a href="labyrinth-map.png">Full size</a> (6144 &times; 4608, one '
             "pixel per pixel).</p>"
             '<a href="labyrinth-map.png"><img src="labyrinth-map-half.png" '
             'alt="The whole labyrinth, every room rendered" style="width:100%;height:auto">'
             "</a>"
             '<div class="note">Drawn by <code>tools/render-labyrinth.py</code>, which '
             "<code>build.py</code> runs. A room takes its area from byte 2's low nibble when "
             "byte 0 bit 7 is clear &mdash; what <code>$EEE0</code> loads into <code>$50</code> "
             "on entering it. A record with byte 0 bit 7 is a <em>special screen</em> (see below): "
             "it keeps the area already loaded (<code>$EC12</code>), so it is drawn with its "
             "neighbours' area, plus scene <code>$10</code> + its screen type, through the room "
             "drawer's special path &mdash; as a new game meets it, every corridor sealed. "
             "<strong>CORRECTION:</strong> the first version of this map drew those 58 records "
             "as ordinary rooms. <strong>Against hardware:</strong> <code>--verify</code> "
             "renders the labyrinth savestate's room from the ROM and from the savestate's own "
             "nametable, CHR RAM and palette RAM: 191 of 192 cells identical to the pixel, the "
             "other under an object. No savestate stands in a special screen, so those are "
             "unchecked.</div>")
    p.append(_labyrinth_rooms(rm))

    groups: list[tuple[list[int], tuple]] = []
    for area in range(11):
        key = sc.scene(b5, sc.LAB_FIRST_SCENE + area)
        for g in groups:
            if g[1] == key:
                g[0].append(area)
                break
        else:
            groups.append(([area], key))

    for areas, (tl, sr, nt) in groups:
        seq = sc.area_scenes(areas[0])
        chr_tiles = sc.background_chr(rm, seq)
        sl = slots(seq)
        pals = [pal(sl[k]) if sl[k] is not None else [backdrop] * 3 for k in range(4)]
        sets = sc.effective_sets(b5, seq)
        names = ", ".join(str(a) for a in areas)
        p.append(f'<h2 id="area{areas[0]}">Area{"s" if len(areas) > 1 else ""} {names}</h2>')
        blocks = []
        for s in seq:
            i = sc.scene(b5, s)[0]
            if i != 0xFF:
                blocks += [f"bank {bk} block {bl} &rarr; tile <code>${t:02X}</code>"
                           for t, bk, bl in sc.tile_list(b5, i, s)]
        sw = "".join(
            f'<span class="sw" style="background:rgb{NES_RGB[c & 0x3F]};color:'
            f'{"#000" if sum(NES_RGB[c & 0x3F]) > 340 else "#fff"}">{c:02X}</span>'
            for k in range(4) if sl[k] is not None
            for c in b5[0x330A + 3 * sl[k]:0x330D + 3 * sl[k]])
        p.append(f'<p class="meta">Scenes {", ".join(map(str, seq))} &middot; tile list {tl}, '
                 f"set record {sr}, palette record {nt} &middot; background palettes "
                 f"{', '.join(str(sl[k]) for k in range(4))}</p>")
        p.append(f'<p class="meta">Loads: {"; ".join(blocks)}</p>')
        p.append(f'<div style="display:flex;flex-wrap:wrap;gap:3px;margin:8px 0">{sw}</div>')
        for n in sorted(sets):
            lst, base, ptr = sets[n]
            src = next(s for s in reversed(seq) if sc.scene(b5, s)[1] != 0xFF and any(
                e[0] == n for e in sc.set_record(b5, sc.scene(b5, s)[1])[1]))
            p.append(f'<div class="card"><h4>Set {n} &mdash; cell bytes '
                     f'<code>${n << 5:02X}-${(n << 5) | 31:02X}</code></h4>'
                     f'<p class="meta">window <code>${ptr:04X}</code> &middot; tile base '
                     f"<code>${base:02X}</code> &middot; object list {lst} &middot; from scene "
                     f"{src}</p>"
                     + _metatiles_svg(chr_tiles, b5, ptr, base, pals, backdrop) + "</div>")

    p.append('<div class="note warn"><strong>Not established.</strong> Which of a window&rsquo;s '
             "32 metatiles any room actually uses &mdash; a window can run past real data, and "
             "those entries draw as noise. Tiles no scene here loads are dashed outlines; some "
             "may come from other loads (a special room&rsquo;s tile list overwrote "
             "<code>$D0-$FD</code> in the savestate). What decides the labyrinth area as you "
             "walk: only leaving a corridor or entering a password is known to set "
             "<code>$50</code>.</div>")

    p.append("<h2>Regions</h2>")
    for r in [x for x in rm.regions if x.get("source") == SCENE_SOURCE]:
        p.append(f'<div class="card" id="{_h(r["id"])}">')
        p.append(f'<h3>{_h(r["name"])} <span class="tag" style="background:'
                 f'{KIND_COLOURS.get(r["kind"], DEFAULT_COLOUR)}">{_h(r["kind"])}</span> '
                 f'<span class="conf {r["confidence"]}">{_h(r["confidence"])}</span></h3>')
        p.append(f'<p class="meta"><code>{_h(r["id"])}</code> &middot; bank {r["prg_bank"]} '
                 f'${r["cpu_addr"]:04X}-${r["cpu_addr"] + r["size"] - 1:04X} &middot; '
                 f'{r["size"]:,} bytes</p>')
        p.append(f'<p class="desc">{_h(r["description"])}</p></div>')
    return "".join(p)


def build_site(rm, out: Path) -> list[str]:
    written: list[str] = []

    pages = {"index.html": _index(rm)}
    for n in range(rm.meta["prg_bank_count"]):
        pages[f"bank{n}.html"] = _bank_page(rm, n)
    if any(r["kind"] == "text" for r in rm.regions):
        pages["text.html"] = _text_page(rm)
    if any(r["kind"] == "graphics" for r in rm.regions):
        pages["graphics.html"] = _graphics_page(rm)
    if any(r["kind"] == "music" for r in rm.regions):
        pages["sound.html"] = _sound_page(rm)
    if any(r["id"] in PASSWORD_REGIONS for r in rm.regions):
        pages["password.html"] = _password_page(rm)
    if any(r.get("source") == SCENE_SOURCE for r in rm.regions):
        pages["labyrinth.html"] = _labyrinth_page(rm)
    if _external():
        pages["external.html"] = _external_page(rm)
    if any(r.get("source") == ENEMY_SOURCE for r in rm.regions):
        pages["enemies.html"] = _enemies_page(rm, out)
    if any(r["id"] in STATUS_REGIONS for r in rm.regions):
        pages["status.html"] = _status_page(rm)
    if any(r.get("source") == SCREEN_SOURCE for r in rm.regions):
        pages["corridors.html"] = _corridors_page(rm)
        for c in CORRIDOR_PAGES:
            pages[_corridor_page_name(c)] = _corridor_page(rm, c, out)
    if any(r["id"] in DEMO_REGIONS for r in rm.regions):
        pages["demo.html"] = _demo_page(rm)
    if any(_is_ending(r) for r in rm.regions):
        pages["ending.html"] = _ending_page(rm, out)

    # Guard: every region must get a card on some page. A region that is annotated and then
    # not shown anywhere is invisible to every reader, and nothing else notices.
    for r in rm.regions:
        target = ("graphics.html" if r["kind"] == "graphics"
                  else "sound.html" if r["kind"] == "music"
                  else f'bank{r["prg_bank"]}.html' if r["segment"] == "prg" else "index.html")
        if f'id="{r["id"]}"' not in pages[target]:
            raise AnnotationError(f'{r["id"]} has no card on {target}')

    # Guard: every page must be reachable from the overview. A generated page that nothing
    # links to is a page nobody will ever open, and until this check existed one shipped.
    # Reachable, not necessarily linked directly: the corridor pages hang off corridors.html.
    reach, todo = {"index.html"}, ["index.html"]
    while todo:
        body = pages[todo.pop()]
        for name in pages:
            if name not in reach and f'href="{name}' in body:
                reach.add(name)
                todo.append(name)
    for name in pages:
        if name not in reach:
            raise AnnotationError(f"{name} is not reachable from index.html")

    for name, body in pages.items():
        title = (rm.meta["title"] if name == "index.html"
                 else f'Text - {rm.meta["title"]}' if name == "text.html"
                 else f'Graphics - {rm.meta["title"]}' if name == "graphics.html"
                 else f'Sound - {rm.meta["title"]}' if name == "sound.html"
                 else f'Password - {rm.meta["title"]}' if name == "password.html"
                 else f'Status screen - {rm.meta["title"]}' if name == "status.html"
                 else f'Enemies - {rm.meta["title"]}' if name == "enemies.html"
                 else f'Outside sources - {rm.meta["title"]}' if name == "external.html"
                 else f'Labyrinth - {rm.meta["title"]}' if name == "labyrinth.html"
                 else f'Demo - {rm.meta["title"]}' if name == "demo.html"
                 else f'Ending - {rm.meta["title"]}' if name == "ending.html"
                 else f'Corridors - {rm.meta["title"]}' if name == "corridors.html"
                 else f'Corridor {int(name[9:11])} - {rm.meta["title"]}'
                 if name.startswith("corridor-")
                 else f'PRG bank {name[4:-5]} - {rm.meta["title"]}')
        (out / name).write_text(_doc(rm, title, name, body), encoding="utf-8")
        written.append(name)
    return written
