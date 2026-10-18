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
                        + " &mdash; are alive but never drawn: their handler "
                          + ("<code>$A8D8</code> (the cannons, types <code>$36</code>/"
                             "<code>$37</code>)" if c == 0 else
                             "<code>$B851</code> (the eyes, types <code>$7E</code>/"
                             "<code>$7F</code>)")
                          + " updates hit boxes and fires, and never calls the sprite drawer."
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


def _item_box_section(rm) -> str:
    """When a defeated enemy leaves an item box, and what is in it (bank 1 $8176)."""
    b1, b7 = rm.prg_bank(1), rm.prg_bank(7)
    thr = list(b1[0x219:0x219 + 8])
    steps, acc = [], 0
    for t in thr:
        acc = t if t else 256
        steps.append(acc)
    first = list(b1[0x221:0x221 + 8])
    rot = list(b1[0x229:0x229 + 4])
    death = lambda t: b7[0xD441 - 0xC000 + t]
    weight = lambda t: b1[0x23D + t]
    groups = {}
    for t in range(1, 0x78):                      # the table ends where bank 1's boss code begins
        if death(t) == 8 and weight(t):
            groups.setdefault(weight(t), []).append(t)
    effects = {0x14: "+40 life", 0x15: "+500 chips and +16 life", 0x16: "+10 chips and +8 life",
               0x0C: "life filled to its maximum", 0x0B: "+16 life, +20 Enemy Eraser uses and the "
               "Eraser counted as owned (only offered when it already is)"}
    o = ['<h2 id="item-boxes">When an enemy leaves an item box</h2>',
         '<p class="sub">It is not luck. Every enemy killed adds a <strong>weight</strong> to one '
         "counter, and a box is released each time the counter reaches the next step of a fixed "
         "schedule. The contents are fixed by the step too. Bank 1 <code>$8176</code> does it, "
         "called from the explosion handler (bank 6 <code>$975F</code>) on the first frame of "
         "a type-<code>$08</code> explosion.</p>"]
    o.append("<h3>The rules</h3><ol>"
             "<li>An enemy whose death type (<code>$D441</code>) is <code>$08</code> becomes that "
             "explosion; 77 types do, and all but five of them have a weight, so they are the ones "
             "that can count. Types that die into "
             "<code>$07</code> (bosses such as <code>$45</code> and <code>$46</code>) never do.</li>"
             "<li>The dead type's weight comes from <code>$823D[type]</code>, 0 meaning it does "
             "not count. The counter <code>$43</code> goes up one at a time, up to that weight, and "
             "stops the moment it equals the current step's threshold "
             "(<code>$8219[$42]</code>); any weight left over is lost.</li>"
             "<li>At the threshold the explosion turns into a box (<code>$0788</code> set). "
             "<strong>In the labyrinth</strong> the box needs a free cell: <code>$8006</code> reads "
             "the room's cell map (<code>$0400</code>) at the grid-snapped position and "
             "<code>$822D[cell]</code> says whether it may; if not, the counter is put back one "
             "so the next kill tries again. In a corridor there is no check.</li>"
             "<li>The box takes the next step's contents, <code>$42</code> goes up by one, and "
             "after step 7 (or when the counter wraps past 255) <code>$42</code> and "
             "<code>$43</code> restart. <code>$42</code>-<code>$44</code> are cleared only when a "
             "game begins, so the schedule carries on from room to room and corridor to "
             "corridor.</li></ol>")
    rows = []
    names = {0x14: "$14", 0x15: "$15", 0x16: "$16"}
    for i in range(8):
        c = first[i]
        what = (", then ".join(f"<code>${r:02X}</code> ({effects.get(r, '?')})" for r in rot[:1])
                if c == 0 else f"<code>${c:02X}</code> ({effects.get(c, '?')})")
        if c == 0:
            what = ("rotates by <code>$44</code> through " + ", ".join(
                f"<code>${r:02X}</code>" for r in rot) + f": {effects[rot[0]]}; {effects[rot[1]]}; "
                f"{effects[rot[2]]}; {effects[rot[3]]}, or <code>$0C</code> when the Eraser is not owned")
        rows.append(f"<tr><td>{i + 1}</td><td class=\"mono\">{steps[i]}</td><td>{what}</td></tr>")
    o.append("<h3>The schedule (weighted kills, then contents)</h3>"
             "<table><thead><tr><th>Box</th><th>Counter reaches</th><th>Contents</th></tr></thead>"
             f"<tbody>{''.join(rows)}</tbody></table>")
    o.append('<p class="meta">So a box comes after 50, 80, 100, 140, 180, 220, 230 and 256 weighted '
             "kills, and the cycle repeats every 256: boxes at 306, 336, 356, &hellip;. Each pickup "
             "is applied by bank 2 <code>$86BC</code>; the values <code>$0B</code>-<code>$0C</code> "
             "are the labyrinth item icons of the same numbers (weapon 12 and the Energy Tank), "
             "and <code>$14</code>-<code>$16</code> exist only as box contents.</p>")
    rows = "".join(f"<tr><td class=\"mono\">{w}</td><td>" + ", ".join(f"<code>${t:02X}</code>" for t in ts)
                   + "</td></tr>" for w, ts in sorted(groups.items()))
    o.append("<h3>What each kill is worth</h3><p class=\"sub\">Weight by object type, from "
             "<code>$823D</code>. The table is read for types 0-<code>$77</code>; "
             "bank 1's boss code begins at <code>$82B5</code>, which is where type "
             "<code>$78</code> would be.</p>"
             "<table><thead><tr><th>Weight</th><th>Types</th></tr></thead>"
             f"<tbody>{rows}</tbody></table>")
    o.append('<div class="note"><strong>Run, not just read.</strong> The routine was run on the NES '
             "model (<code>tools/tgl/cpu.py</code>) over repeated kills of a weight-1 type: boxes at "
             "exactly 50, 80, 100, 140, 180, 220, 230 and 256 kills with contents "
             "<code>$14 $15 $16 $14 $14 $15 $15 $15</code>, the next cycle at 306&hellip; and "
             "<code>$0C</code> as the eighth box of the second cycle; a weight-16 type gives the "
             "first box on the fourth kill. The pickups were run on the real routine from life 32: "
             "<code>$14</code> +40 life; <code>$15</code> +500 chips and +16 life; "
             "<code>$16</code> +10 chips and +8 life; <code>$0C</code> full life; "
             "<code>$0B</code> +16 life and 20 Eraser uses. <strong>How a box opens (run in the labyrinth):</strong> "
             "touching a closed box does nothing; the ship's shots open it (the handler records its item in "
             "<code>$56</code> and uploads the icon), and touching the open box adds the item and removes it "
             "&mdash; item 6 gave weapon 6. A corridor box was not tried. <strong>Not established:</strong> "
             "the weights' extent past type <code>$77</code>, and the labyrinth's "
             "cell-category table <code>$822D</code> beyond what it blocks. Nothing here was "
             "played on hardware.</div>")
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
           "Direction numbers are 0-15 in 22.5&deg; steps; 0/4/8/12 are right/down/left/up (corrected: this said down/right/up/left; the routine that turns a direction into a velocity was run and the player's own upward shot is 12).</div>",
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


RAM_JSON = Path(__file__).resolve().parents[2] / "annotations" / "ram.json"
RAM_STATUSES = ("confirmed", "checked", "lead")


def _ram_data():
    """annotations/ram.json, validated: addresses parse and lie in RAM, statuses are known."""
    if not RAM_JSON.exists():
        return None
    import json as _json
    d = _json.loads(RAM_JSON.read_text(encoding="utf-8"))
    for e in d["entries"]:
        a = int(e["addr"].lstrip("$"), 16)
        b = int(e["end"].lstrip("$"), 16) if "end" in e else a
        if not (0 <= a <= b < 0x800):
            raise AnnotationError(f'ram.json entry {e["name"]}: {e["addr"]}-{e.get("end", "")} '
                                  "is not inside $0000-$07FF")
        if e["status"] not in RAM_STATUSES:
            raise AnnotationError(f'ram.json entry {e["name"]}: unknown status {e["status"]}')
    for e in d["object_fields"] + d.get("sound_fields", []):
        if e["status"] not in RAM_STATUSES:
            raise AnnotationError(f'ram.json field {e["name"]}: unknown status {e["status"]}')
    return d


def _topic_pages(rm):
    """(filename, nav label, blurb, count text) for each topic page that has content.

    The outside-sources page is the one topic with no regions: it is about what is known
    from OUTSIDE the ROM, so it counts facts."""
    out = []
    for fname, label, select, blurb in TOPICS:
        n = len(select(rm.regions))
        if n:
            out.append((fname, label, blurb, f"{n:,} regions"))
    ramd = _ram_data()
    if ramd:
        out.append(("ram.html", "RAM map",
                    "What the console's 2 KB of RAM holds: every byte the traced code touches, "
                    "which banks use it, and what is known about the named ones.",
                    f'{len(ramd["entries"])} entries'))
    out.append(("gameloop.html", "Game loop",
                "What one 1/60 second of a corridor and of the labyrinth does, in order and with "
                "timings: the NMI, pads, objects, HUD, stage step, spawn scripts and the frame sync - "
                "and what runs only every Nth frame or every room.",
                "9 sections"))
    out.append(("rendering.html", "Rendering",
                "Mirroring, the NMI, the sprite-0 split that parks the HUD at the bottom, and how "
                "corridors and the labyrinth scroll.",
                "6 sections"))
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


def _subweapon_section(rm) -> str:
    """How the A-button weapons work (bank 3 $8E3C, bank 6 $8616-$8C6F and its tables)."""
    b6, b7 = rm.prg_bank(6), rm.prg_bank(7)
    ext = _external() or {"facts": []}
    names = next((f.get("weapon_names") for f in ext["facts"] if f.get("weapon_names")),
                 None) or [""] * 12

    def tab(base, w, lv):                      # a by-level table: [(lv - 1) * 11 + (w - 1)]
        return b6[base - 0x8000 + (lv - 1) * 11 + (w - 1)]

    def speed(v):                              # px per frame for a $0698 speed class
        return 120 * (8 if v & 0x80 else 1) * (4 if v & 0x40 else 1) * (v & 0x3F) / 256

    cost = lambda w, lv: b7[0xFDD7 - 0xC000 + 3 * (w - 1) + lv - 1]
    slots = lambda w: b7[0xFDCA - 0xC000 + w]
    paid_at_fire = lambda w: bool(b6[0x879A - 0x8000 + w] & 0x80)

    def trio(f):
        return " / ".join(str(f(lv)) for lv in (1, 2, 3))

    def attack(w):
        if w == 9:
            return "1 per frame"
        if w in (10, 11):
            return "gun &times; 2 / 4 / 8"
        if all(tab(0x8701, w, lv) == 0 for lv in (1, 2, 3)):
            return "gun"
        return trio(lambda lv: tab(0x8701, w, lv) or "gun")

    def hp(w):
        return trio(lambda lv: tab(0x8722, w, lv) or "&infin;")

    def flags(w):
        return " ".join(f"{tab(0x8764, w, lv):02X}" + ("*" if tab(0x8764, w, lv) & 0x20 else "")
                        for lv in (1, 2, 3))

    how = {
        1: "One object (slot 4) flying straight the way the ship faces (up in a corridor) at "
           + trio(lambda lv: f"{speed(tab(0x8743, 1, lv)):.1f}") + " px/frame; a twin pair of "
           "bullets at levels 1 and 2, a 32 &times; 32 diamond at level 3. The level changes its "
           "speed, size and how much it can take, not its damage (the gun's).",
        2: "Two objects (slots 3 and 4), fired at the facing direction +5 and +11: 112&deg; "
           "either side, so backwards and outwards (in a corridor, 22.5&deg; below horizontal to "
           "the left and the right). Speed " + trio(lambda lv: f"{speed(tab(0x8743, 2, lv)):.1f}")
           + " px/frame. Takes two of the four object slots.",
        3: "A very fast straight shot (" + trio(lambda lv: f"{speed(tab(0x8743, 3, lv)):.0f}")
           + " px/frame) that is off the screen in a few frames. In a corridor its heading is "
           "taken from the D-pad at the moment of firing (<code>$8837[$32]</code>): left held "
           "up-left, otherwise up, right held up-right (read from the code, not run).",
        4: "One object that orbits the ship, centred 16 px above it in a corridor, on a path "
           "about 45 px across; at levels 2 and 3 it goes round twice as fast, and level 3 is "
           "32 &times; 32. It never wears out and stays until the chips run out.",
        5: "Thrown forward, rises, then falls back (<code>$0668</code> = <code>$FE</code> is the "
           "y it accelerates toward) for 60 frames, then bursts: a ring of 32 &times; 32 blasts "
           "sweeping out for " + trio(lambda lv: tab(0x8743, 5, lv)) + " frames (level 1, 2, 3). "
           "It has no hit box in flight (the box is only refreshed during the burst).",
        6: "A slow shot that does not wear out above level 1 (hit points 128 at level 1): "
           + trio(lambda lv: f"{speed(tab(0x8743, 6, lv)):.1f}") + " px/frame, a 16-wide sprite "
           "at level 1 and 32 &times; 32 at levels 2 and 3, with a high attack.",
        7: "Two homing missiles (slots 3 and 4). Every 8 / 4 / 1 frames (level 1, 2, 3) each turns "
           "one step of 16 toward its target, the next live enemy in slot order (the second "
           "missile skips the first's target); with no target it circles the ship. Speed class "
           + trio(lambda lv: f"{speed(tab(0x8743, 7, lv)):.1f}") + " px/frame.",
        8: "A spinner: a 12 or 32 px blast circling a point that drifts forward at about half a "
           "pixel a frame, radius about 30 px. It never wears out and goes on until it leaves "
           "the screen; the chips are paid once, at the throw.",
        9: "<strong>Corridors only</strong> (the first frame removes it when <code>$30</code> bit "
           "6 is clear). A beam that grows up the screen at 6 / 10 / 8 px/frame to a box about "
           "190 px tall (6, 6 and 48 px wide), then slides off; about 40 frames, whether or not A "
           "is held. Damage is 1 a frame at every level (the table's attack is overwritten by "
           "<code>$FDF8</code>); at level 1 it is live only on alternate frames.",
        10: "Exists only while A is held: a 10 &times; 6 blade 24 to 40 px ahead of the ship, "
            "sliding in and out. Damage is the gun's attack doubled once per level.",
        11: "Exists only while A is held: two 12 &times; 12 blades either side of the ship, "
            "sliding out 16 to 32 px and back. Damage as the Saber's. Takes two object slots.",
        12: "No object lives on: a press (a fresh one, not held) flashes the screen, costs one of "
            "the <code>$04AF</code> uses and turns every enemy slot whose collision flags bit 6 "
            "is clear into the explosion type <code>$08</code> (the original type kept in "
            "<code>$0740</code>, as in an ordinary death).",
    }
    rows = []
    for w in range(1, 13):
        if w == 12:
            rows.append(f"<tr><td>12 {_h(names[11])}</td><td colspan=\"4\">the Eraser count "
                        "(<code>$04AF</code>), one per press</td><td>none</td>"
                        f"<td>1, removed at once</td><td>{how[12]}</td></tr>")
            continue
        rows.append(
            f"<tr><td>{w} {_h(names[w - 1])}</td>"
            f"<td class=\"mono\">{trio(lambda lv: cost(w, lv))}</td>"
            f"<td class=\"mono\">{attack(w)}</td><td class=\"mono\">{hp(w)}</td>"
            f"<td class=\"mono\">{flags(w)}</td>"
            f"<td>{'at the throw' if paid_at_fire(w) else 'every 60 frames while it lives'}</td>"
            f"<td class=\"mono\">{'1' if slots(w) == 3 else '2'}</td>"
            f"<td>{how[w]}</td></tr>")
    o = ['<h2 id="subweapons">The A-button weapons</h2>',
         '<p class="sub">Select a weapon on the status screen and hold A. Each of the twelve has '
         "its own handler in bank 6, but they share one set-up and one set of per-level tables. "
         "What they do, measured by running the real code, is below.</p>",
         "<h3>The mechanics they share</h3><ol>"
         "<li><strong>Spawning</strong> (bank 3 <code>$8E3C</code>): with a weapon selected "
         "(<code>$3C</code>) and A held, every free object slot from <code>$3B</code>+1 to 4 gets "
         "an object of type <code>$03</code> at the ship, carrying the ship's facing in "
         "<code>$0788</code>. The main gun owns slots 1 to <code>$3B</code>. "
         "<code>$3B</code> is 3 for most weapons (the weapon gets slot 4 only) and 2 for Back "
         "Fire, Area Blaster and Cutter Laser (slots 3 and 4, two objects), which also leaves "
         "the gun just two bullets while they are selected.</li>"
         "<li><strong>First frame</strong> (bank 6 <code>$866B</code>): it needs "
         "<code>$3E</code> (uses left) above 0, or it removes itself; plays the weapon's sound; "
         "sets sprite, palette, attack, durability, speed class and collision flags from "
         "the tables at <code>$8784-$8764</code>; and for the Grenade, Fireball and Repeller "
         "pays the chip cost <code>$45</code> at once (bit 7 of <code>$879A</code>).</li>"
         "<li><strong>Every frame</strong> (<code>$8616</code>): the other weapons pay "
         "<code>$45</code> chips each time <code>$3F</code> counts down to 0 (reloaded with 60, "
         "or 120 when two objects both count it), so they cost chips by the second for as long "
         "as the object is alive; when the chips left no longer cover one use "
         "(<code>$3E</code> = 0) the object, or both objects, are removed. Durability "
         "(<code>$8722</code>) is real hit points that enemy contact wears down; 0 in the table "
         "means <code>$FF</code> is put back every frame, so it never wears out.</li>"
         "<li><strong>Cost and level</strong>: chips per use are "
         "<code>$FDD7</code>[3 &times; weapon + level] (the first table), the level comes from "
         "<code>$04AC-$04AE</code> and the weapon's power on the status screen.</li></ol>"]
    o.append("<table><thead><tr><th>Weapon</th><th>Chips per use (level 1 / 2 / 3)</th>"
             "<th>Attack</th><th>Hit points</th><th>Collision flags</th><th>Chips charged</th>"
             "<th>Slots</th><th>What it does</th></tr></thead><tbody>"
             + "".join(rows) + "</tbody></table>")
    o.append('<p class="meta">Attack &ldquo;gun&rdquo; is the ship&rsquo;s own attack '
             "(<code>$05A8</code>, from the Gun item); hit points &infin; means it never wears "
             "out. <strong>Collision flags</strong> are the weapon&rsquo;s <code>$0578</code>: an "
             "enemy test hits a player-side object only if its flags share a bit with the test's "
             "mask, and ordinary enemies test <code>$30</code> while the stage's fixed targets "
             "(the cannons <code>$36</code>/<code>$37</code> and eyes <code>$7E</code>/"
             "<code>$7F</code> among them) call <code>$C0CF</code>, which tests <code>$20</code> "
             "only. A star marks flags with bit 5: those weapons <em>can</em> hurt the stage "
             "bosses; the others (Back Fire, Wave Attack level 1, Bullet Shield, "
             "Repeller level 1 and Hyper Laser level 1) pass through them. Read from the "
             "code, not played.</p>")
    o.append('<p><img src="subweapons.png" width="1408" style="max-width:100%;height:auto" '
             'alt="Paths of the eleven weapons at levels 1, 2 and 3, drawn over time"></p>')
    o.append('<p class="meta">Each cell overlays the weapon&rsquo;s sprites every four frames in a '
             "corridor (white cross = the ship); rows are levels 1, 2, 3. Nothing else is on "
             "screen, so the Area Blaster circles with nothing to chase.</p>")
    o.append('<div class="note"><strong>Run, not just read.</strong> Every weapon at every level '
             "was run on the NES model (<code>tools/tgl/cpu.py</code>, with a pad) from a corridor "
             "savestate after calling the ROM's own <code>$FD77</code> to set the level and cost: "
             "the object counts, chip charges (by the second or at the throw, and the stop when "
             "chips cannot cover a use), lifetimes, speeds, paths and the table values above are "
             "what the code did. The Area Blaster was also run among the savestate's real "
             "enemies: its two missiles chose different ones and steered onto them. The Hyper "
             "Laser was run with <code>$30</code> bit 6 cleared and removes itself at once; the "
             "Eraser, with enemies on screen, turned them into explosions and used one of "
             "<code>$04AF</code>. Pictures are from <code>tools/render-subweapons.py</code>. "
             "<strong>Not established:</strong> the corridor only was run, so the labyrinth "
             "shapes and facing are read from the code; the Wave Attack's D-pad steering was "
             "not run; what flag bits 2 and 3 do (one enemy-shot type tests bit 2); "
             "whether Eraser kills count towards item boxes. What the weapons do to the "
             "labyrinth's cells is on <a href=\"labyrinth.html#cells\">the labyrinth page</a>. "
             "Not played on hardware.</div>")
    return "".join(o)


def _gun_section(rm) -> str:
    """How the chip total shapes the main gun's shot (bank 7 $E213, bank 6 $8490)."""
    b6, b7 = rm.prg_bank(6), rm.prg_bank(7)
    speed = list(b6[0x47C:0x480])
    even = list(b6[0x480:0x484])
    odd = list(b6[0x484:0x488])
    even_v = list(b6[0x488:0x48C])
    odd_v = list(b6[0x48C:0x490])
    hw = lambda i: b7[0xC174 - 0xC000 + i]
    hh = lambda i: b7[0xC201 - 0xC000 + i]
    px = []
    for v in speed:
        mult = (8 if v & 0x80 else 1) * (4 if v & 0x40 else 1) * (v & 0x3F)
        px.append(120 * mult / 256)
    ranges = ("under 100", "100 to 199", "200 to 2,047", "2,048 and over")
    rows = []
    for t in range(4):
        a, b = even_v[t], odd_v[t]
        rows.append(
            f"<tr><td>{t}</td><td>{ranges[t]}</td><td class=\"mono\">{px[t]:.2f}</td>"
            f"<td><code>${a:02X}</code> / <code>${b:02X}</code> "
            f"(hit box {hw(a) * 2} &times; {hh(a) * 2} / {hw(b) * 2} &times; {hh(b) * 2} px)</td></tr>")
    o = ['<h2 id="gun">The main gun and your chips</h2>',
         '<p class="sub">The shot you fire with B is not fixed: its speed and its look depend '
         "on how many chips you hold, in four tiers. <strong>Chips are not spent</strong> on "
         "it - they only decide the tier. (The sub-weapons on A do spend them, and spending, or "
         "picking chips up, can move you between tiers.)</p>",
         "<ol><li>Every time the chip total changes, bank 7 <code>$E213</code> (called from the "
         "spend routine bank 6 <code>$8B8F</code> and the pick-up routine <code>$FCE7</code>) "
         "puts a tier in <code>$3A</code>: 0 below 100 chips, 1 from 100, 2 from 200, 3 from "
         "2,048.</li>"
         "<li>Holding B counts <code>$33</code> down from <code>$39</code> (the fire-rate "
         "delay) and, when it runs out, the player's handler (bank 3 <code>$8E04</code>) puts "
         "an object of type <code>$02</code> in the first free slot of slots 1 to "
         "<code>$3B</code>, heading the way the ship faces (always up in a corridor).</li>"
         "<li>The type-<code>$02</code> handler (bank 6 <code>$8490</code>), on its first "
         "frame, stores <code>$847C[$3A]</code> in <code>$0698</code>, the speed class that "
         "<code>$F8CE</code> turns into a velocity: bit 7 multiplies by 8, bit 6 by 4, the low "
         "six bits repeat the addition. The speed is <strong>fixed at the moment of "
         "firing</strong>; a shot already in flight keeps it.</li>"
         "<li>Every frame the handler picks the metasprite from <code>$3A</code> too, and "
         "<strong>alternates</strong> between two rows of a table on odd and even frames "
         "(<code>$8488</code> for a shot flying up or down, <code>$8480</code> for sideways). "
         "The hit box follows the metasprite (<code>$C174</code>, <code>$C201</code>), so it "
         "flickers with it. Damage is the ship's attack from the Gun item "
         "(<code>$05A8</code>, <code>$FD4B</code>) and does not depend on chips.</li></ol>"]
    o.append("<table><thead><tr><th>Tier</th><th>Chips</th><th>Speed (px/frame)</th>"
             "<th>Metasprites for a shot flying up, even / odd frame</th></tr></thead>"
             f"<tbody>{''.join(rows)}</tbody></table>")
    o.append('<p class="meta">A shot flying sideways uses <code>$8480</code> instead '
             f"({' '.join(f'${v:02X}' for v in even)} / {' '.join(f'${v:02X}' for v in odd)}), "
             "the same shapes turned a quarter. Speed is 120/256 pixel per frame times the "
             "class (8 &times; 1, 4 &times; 3, 8 &times; 2, 8 &times; 3).</p>")
    o.append('<p><img src="gun-tiers.png" width="768" alt="The main gun\'s shot at 50, 150, '
             '500 and 3,000 chips, two frames each"></p>')
    o.append('<p class="meta">Each tier, two consecutive frames (top row, bottom row). A bigger '
             "tier adds a second pellet beside the first on one of the two frames and moves "
             "the pair further apart (8, 16 and 32 pixels), so the stream reads as a wider "
             "beam; the pellet is the same sprite tile in every tier.</p>")
    o.append('<div class="note"><strong>Run, not just read.</strong> <code>$E213</code> was '
             "called at chip totals from 0 to 6,000 (the tier steps at exactly 100, 200 and "
             "2,048), and B was held on the NES model (<code>tools/tgl/cpu.py</code>, now with "
             "a controller) from a corridor savestate at 50, 150, 500 and 3,000 chips: the new "
             "shots carry <code>$81</code>, <code>$43</code>, <code>$82</code>, <code>$83</code> "
             "and move 3.75, 5.62, 7.5 and 11.25 pixels a frame, with the metasprites above, "
             "and shots already flying kept the old speed while their sprite changed at once. "
             "The picture is from <code>tools/render-gun.py</code>. Tier 3 needs a chip "
             "capacity of 2,400 or more (<code>$46</code> at 8 or higher). "
             "<strong>Not established:</strong> how the sideways shapes look (the labyrinth was "
             "not run) and what else <code>$3B</code> does in the damage routine. Not played on "
             "hardware.</div>")
    return "".join(o)


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

    # ---- the score bonus: thresholds from the ROM's init bytes and the $DF3D stepping rules
    b0 = rm.prg_bank(0)
    i0 = bytes(b0).find(bytes([0xA9, 0x03, 0x8D, 0x7E, 0x01]))
    thr = [0, 0, b0[i0 + 1]]                       # $017C, $017D, $017E as bank 0 $80B1 sets them
    steps, digits = [], []
    for _ in range(8):
        steps.append(thr[0] * 1_000_000 + thr[1] * 100_000 + thr[2] * 10_000)
        digits.append(" ".join(map(str, thr)))
        if thr[0]:
            thr[0] += 1
        elif thr[1] == 0:
            thr[2], thr[1] = 0, 1
        elif thr[1] == 1:
            thr[1] = 5
        else:
            thr[1], thr[0] = 0, 1
    p.append('<h2 id="score-bonus">The score bonus</h2>')
    p.append('<p class="sub">At certain scores the game adds <strong>8 to maximum life</strong> '
             "and refills it - the same effect as the Energy Tank item. The scores are not "
             "in a table: a counter in the code produces them.</p>")
    p.append("<table><thead><tr><th>Award</th><th>Score</th><th>Threshold digits "
             "<code>$017C $017D $017E</code> that must be reached</th></tr></thead><tbody>"
             + "".join(f"<tr><td>{n}</td><td class=\"mono\">{v:,}</td><td>"
                       f"<code>{digits[n - 1]}</code></td></tr>"
                       for n, v in enumerate(steps[:4], 1))
             + "<tr><td>5, 6, &hellip;</td><td class=\"mono\">2,000,000, 3,000,000, "
               "&hellip;</td><td>(n 0 0): one more in <code>$017C</code> each time</td></tr>"
             "</tbody></table>")
    p.append("<p>How it works: after every score add (<code>$DFB1</code>), bank 7 "
             "<code>$DF3D</code> compares the top three score digits "
             "(<code>$0170-$0172</code>; the score is kept in tens, so <code>$0172</code> is "
             "the 10,000s digit) with the threshold in <code>$017C-$017E</code>. At or above it "
             "it plays song <code>$31</code> (<code>$DF8C</code>), <strong>refills the chips to "
             "CHIP MAX</strong> (<code>$4C/$4D</code> := <code>$4E/$4F</code>, then a zero add "
             "through <code>$FCE7</code> redraws the counter and the gun tier), adds 8 to "
             "<code>$47</code>, capped at <code>$FF</code>, sets <code>$48</code> equal to it and "
             "redraws the HUD (<code>$DFA1</code>, <code>$E424</code>), then steps the threshold: "
             "<code>0 0 3</code> &rarr; <code>0 1 0</code> &rarr; <code>0 5 0</code> &rarr; "
             "<code>1 0 0</code>, and from there <code>$017C</code> goes up by one. Bank 0 "
             "<code>$80A5-$80B3</code> starts it at <code>0 0 3</code> when a game begins. No "
             "award in a demo (<code>$30</code> bit 7); a score overflow sets every digit to 9 "
             "and <code>$017C</code> to <code>$FF</code>, which ends them.</p>")
    p.append('<div class="note"><strong>Confirmed.</strong> The owner reported a bonus at '
             "500,000, which is the third award. The routine was also run on the NES model "
             "(<code>tools/tgl/cpu.py</code>) at chosen scores: +8 at exactly 30,000, 100,000, "
             "500,000, 1,000,000, 2,000,000 and 3,000,000, and at none of 29,990, 99,990, "
             "499,990, 999,990 or 1,999,990. The 30,000 and 100,000 awards, and the idea "
             "that it is a counter and not a table, are from the code and that run; they "
             "have not been played on hardware.</div>")

    p.append(_gun_section(rm))
    p.append(_subweapon_section(rm))

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
                 ("$47 / $48", "maximum / current life; the score bonus adds 8 to both"),
                 ("$0170-$0175", "the score, six digits, in tens (a fixed 0 is printed after)"),
                 ("$017C-$017E", "the next score-bonus threshold, three digits"),
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
    p.append(_item_box_section(rm))
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
                parts.append(f'<span class="conf lead">jump ${e[1]:04X}, outside the scripts</span>')
            else:
                parts.append("end")
        items.append(f"<tr><td>{i}</td><td><code>${ptr:04X}</code></td>"
                     f'<td class="mono">{rooms.get(i, 0)}</td><td>{" &rarr; ".join(parts)}</td>'
                     "</tr>")
    p.append("<table><thead><tr><th>Id</th><th>At</th><th>Rooms</th><th>Steps</th></tr>"
             f"</thead><tbody>{''.join(items)}</tbody></table>")
    p.append('<div class="note warn"><strong>Five scripts do not end cleanly &mdash; run, not just read.</strong> '
             "Ids 16, 24, 28, 32 and 38 (<strong>28 rooms</strong>) finish <code>[byte] 01 02</code>. The byte after "
             "a formation is always read as its delay, so <code>[byte]</code> is <strong>not</strong> a spawn "
             "(though it equals a type other scripts spawn singly: <code>$70</code>, <code>$54</code>, "
             "<code>$73</code>): it is a wait of <strong>112, 112, 84, 115 and 30 seconds</strong> in the "
             "labyrinth. Then command 1 jumps to (<code>02</code>, the next script's first byte): "
             "<code>$6F02</code>, <code>$7202</code>, <code>$9002</code>, <code>$F002</code>, <code>$6502</code>. "
             "Running the interpreter on the NES model: scripts 28 and 32 jump into ROM (bank 5 map data, fixed-bank "
             "code) and read it as script, spawning a stream of junk formations and objects from then on; "
             "scripts 16, 24 and 38 jump into <code>$6000-$7FFF</code>, where this cartridge has nothing. A "
             "console returns open bus there; if that is the pointer's high byte (what the 6502 fetched last) "
             "the interpreter spawns that type &mdash; <code>$6F</code>, <code>$72</code>, <code>$65</code> "
             "&mdash; once per wait, for ever. <em>Lead:</em> the open-bus value is an inference, and nothing "
             "here is checked on hardware. <code>tools/run-spawn-script.py</code> reproduces it.</div>")

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
             "<strong>Corridor 16's script is misread by the game.</strong> Its last records are "
             "<code>A0 04 5A</code>, <code>E3 0F 28</code>, <code>96 EA 05</code>, <code>64</code>, "
             "<code>64</code>, <code>02</code>. A delay byte of <code>$80</code> or more is taken by the "
             "interpreter as the next spawn, so <code>$96</code> (a delay of 150, if the author meant one) "
             "starts a formation of type <code>$16</code>, <strong>234</strong> of them, one every 5 frames, and "
             "the rest runs on: a single <code>$64</code>, a wait of 258 rows, a <code>$04</code> just before "
             "the boss. Neither <code>$16</code> nor <code>$64</code> has its art block loaded by this "
             "corridor (two of the five misses below), so such an object is never drawn, waits "
             "<strong>768 frames</strong> (<code>$CF5F</code>) and is removed. On the model that keeps "
             "<strong>14-16 of the 19 enemy slots</strong> full from row 951 on, starving the real "
             "formations (<code>$20</code> &times; 4, <code>$63</code> &times; 15). The boss (row 1,330) still "
             "gets a slot, at once in three trials, because the allocator also reuses slots marked dying. "
             "Read with <code>$96</code> as a delay the script ends with command 2 exactly where the next "
             "structure begins. Run on the corridor-15 savestate, so art and speed differ from corridor 16's own; "
             "not checked on hardware. "
             "<strong>139 of 144</strong> (corridor, spawned type) pairs find the type's art block "
             "in that corridor's own load streams. <strong>Correction:</strong> the other five were thought to "
             "rely on art left loaded from before. They do not: a corridor start leaves only its own streams' "
             "blocks in the 16 slots (run on the real loader), so those objects are never drawn. "
             "Corridor 16's two are explained above. <strong>Corridor 12</strong> loads corridor 1's streams "
             "(<code>$9D43</code>, <code>$9D55</code>: blocks <code>$20</code> <code>$1F</code> ...) but its script also "
             "spawns <code>$63</code> and <code>$64</code>, whose blocks <code>$25</code> and <code>$22</code> only "
             "corridors 2 and 11's <code>$A048</code> loads (which holds all four): <strong>14 of the 64 objects it "
             "spawns are invisible</strong> (10 &times; <code>$63</code>, 4 &times; <code>$64</code>), each for 768 "
             "frames (measured 7,718 and 3,081 frames against 7,680 and 3,072). <strong>Corridor 7</strong> spawns one "
             "<code>$1E</code> (block <code>$12</code>, which no corridor stream loads) among 107 objects: invisible "
             "for 768 frames. Likely a wrong stream pointer in corridor 12 and a stray type in corridor 7 &mdash; "
             "a lead; the data cannot say what the author meant. <strong>Correction:</strong> the four huge "
             "&ldquo;terminal triggers&rdquo; that end bank 4's blocks are not trigger data "
             "&mdash; three are exactly the first two bytes of the spawn script or graphics "
             "stream that follows. Corridor 16's script runs on into the next block after its "
             "last wave; where it really ends is not established.</div>")

    p.append('<h2 id="dissolve">The squares before a boss</h2>')
    p.append('<div class="note">Enemies that turn into <strong>squares</strong> just before a boss are not a '
             "scripted effect. Almost every corridor (not 7, 17, 22) has a second graphics stream (screen-data "
             "command 7) <strong>0 to 30 rows before its boss command</strong> that loads the boss's art "
             "into slots the stage's ordinary enemies were using (corridor 5: row 465, stream "
             "<code>$AAE2</code>, slots 12-14; the boss command is at row 470). For every record "
             "<code>$E9C3</code> reads the slot's old block, zeroes the slot, and walks slots 5-23: "
             "any object whose art block (<code>$CFB6[type]</code>, via <code>$CF4C</code>) equals the evicted "
             "block gets its type overwritten with <strong><code>$28</code></strong>. Type <code>$28</code> "
             "(bank 6 <code>$9972</code>; hit points 0, death type 0, flags <code>$C0</code>) is a 16-step "
             "dissolve: metasprite 121 &mdash; the squares, tiles <code>$01</code>/<code>$03</code> "
             "flickering and then <code>$05</code>, <code>$07</code> &mdash; for about 32 frames, then "
             "metasprite 55 for about 10, then it is gone (42 frames in all, measured). Enemies of "
             "other blocks are untouched, and so is an object with no art block. A second effect "
             "follows at the boss command: phase 1 (<code>$917F</code>-<code>$9216</code>) reads "
             "<code>$913A[corridor]</code>; bit 7 (set for every corridor but 7, 17, 21 and 22) turns every "
             "remaining non-spawner object into an explosion (type <code>$08</code>) and bit 3 stops the "
             "spawn script. <strong>Checked</strong> on the owner's <code>fade</code> savestate (corridor 5, row "
             "467: four <code>$A8</code> objects with metasprite 121, slot 12 empty, slots 13-14 holding "
             "<code>$41</code>/<code>$35</code>) and on the real corridor loader with a <code>$1A</code> "
             "(block <code>$3C</code>) and a <code>$59</code> (block <code>$1E</code>) placed in slots: "
             "each became <code>$28</code> on the frame after its block was evicted; a control object was "
             "unchanged. NES model; not checked on hardware.</div>")
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


def _rendering_page(rm):
    """How the picture is made: mirroring, the NMI, the sprite-0 split, and both kinds of scrolling."""
    b7 = rm.prg_bank(7)
    hdr = rm.rom[:16] if hasattr(rm, "rom") else b""
    flags6 = hdr[6] if len(hdr) > 6 else 0x21
    dmc = (428, 380, 340, 320, 286, 254, 226, 214, 190, 160, 142, 128, 106, 84, 72, 54)
    CYC_LINE, VBL = 113.67, 2273

    def line_of(cycles):
        return (cycles - VBL) / CYC_LINE

    rows = "".join(
        f"<tr><td class=\"mono\">${0x80 + i:02X}</td><td class=\"mono\">{dmc[i]}</td>"
        f"<td class=\"mono\">{136 * dmc[i]:,}</td><td class=\"mono\">{line_of(136 * dmc[i]):.0f}</td>"
        f"<td>{'before the hit: the IRQ waits for it' if line_of(136 * dmc[i]) < 192 else 'after the hit: late'}"
        "</td></tr>" for i in (7, 8, 9))
    o = ["<h1>Rendering</h1>",
         '<p class="sub">How the picture is made and how it scrolls: the cartridge\'s mirroring, '
         "what the NMI does every frame, the sprite-0 split that parks the HUD at the bottom of the "
         "screen, the corridors' vertical scroll and the labyrinth's room-to-room scroll.</p>",
         '<div class="note"><strong>In short.</strong> Mirroring is <strong>vertical</strong>, fixed by '
         "the board, so the two real nametables sit side by side ($2000, $2400) and $2800 and $2C00 "
         "are copies of them. Every frame is cut in two at scanline 192: <strong>above</strong> it "
         "the playfield is drawn with whatever scroll the game wants; at a sprite-0 hit the game "
         "rewrites the PPU address so that <strong>below</strong> it the HUD is drawn from the bottom "
         "of nametable 1, unscrolled. The playfield is 256 &times; 192; a corridor scrolls it "
         "vertically through nametable 0 and redraws one 16-pixel row ahead of it; the labyrinth keeps "
         "one room in nametable 0 and scrolls to the next with both tables.</div>"]

    # ---------------------------------------------------------------- mirroring
    o.append('<h2 id="mirroring">Mirroring</h2>')
    o.append(f"<p>iNES byte 6 is <code>${flags6:02X}</code>: bit 0 is 1, so <strong>vertical "
             "mirroring</strong>. Mapper 2 has no mirroring register, so this never changes. It "
             "means <code>$2000</code> and <code>$2800</code> are one table (NT0) and "
             "<code>$2400</code> and <code>$2C00</code> the other (NT1): two 32 &times; 30 tables "
             "side by side, each repeated below.</p>")
    o.append("<table><thead><tr><th>PPU address</th><th>Table</th><th>How the game uses it</th></tr>"
             "</thead><tbody>"
             "<tr><td class=\"mono\">$2000-$23FF</td><td>NT0</td><td>The playfield: the corridor "
             "(all of it), the labyrinth's room at rest, and one of the two rooms during a scroll.</td></tr>"
             "<tr><td class=\"mono\">$2400-$27FF</td><td>NT1</td><td>The HUD in rows 24-29, always; "
             "the neighbouring room during a horizontal scroll; the status screen.</td></tr>"
             "<tr><td class=\"mono\">$2800-$2BFF</td><td>NT0 again</td><td>Written to, on purpose "
             "(see below).</td></tr>"
             "<tr><td class=\"mono\">$2C00-$2FFF</td><td>NT1 again</td><td>Never used.</td></tr>"
             "</tbody></table>")
    o.append("<p><strong>The game relies on it, in two ways</strong> (the note in "
             "<code>rom.json</code> said this was not checked):</p><ul>"
             "<li><strong>Horizontal scrolling needs two tables side by side.</strong> The labyrinth's "
             "east and west scrolls (<code>$A8</code> counting 0&ndash;252 with the table bit "
             "<code>$A9</code>) run across the join between <code>$2000</code> and "
             "<code>$2400</code>. With horizontal mirroring those would be one table over another and "
             "the scroll would wrap onto itself.</li>"
             "<li><strong>The $2800 alias.</strong> The corridor engine thinks of its world as two "
             "stacked screens: <code>$AB</code> flips each time the row counter wraps "
             "(<code>$E98F</code>-area code, bank 7 <code>$EACC</code>/<code>$E6B9</code>), and while it "
             "is 1 the row address is moved up by <code>$0800</code>. With vertical mirroring "
             "<code>$2800</code> <em>is</em> NT0, so the same 30 rows are simply reused. Counted on the "
             "NES model over 120 corridor frames: 768 PPU writes to <code>$2000-$23FF</code>, "
             "<strong>216 to <code>$2800-$2BFF</code></strong>, 62 to <code>$2400-$27FF</code> (the "
             "HUD); over the labyrinth's north scroll, 864 to <code>$2800-$2BFF</code>, and none "
             "there for the east scroll. The scroll code toggles the vertical table bit "
             "<code>$A7</code> the same way, which is invisible for the same reason.</li></ul>")

    # ---------------------------------------------------------------- registers and NMI
    o.append('<h2 id="nmi">The registers and the NMI</h2>')
    o.append("<p>The game never writes the PPU's scroll or control registers from game code. It keeps "
             "<strong>shadow</strong> values and one routine copies them at the end of every NMI. "
             "Bank 7 <code>$DC75</code>, in order:</p><ol>"
             "<li>Render off: <code>$FE &amp;= $E7</code> then <code>$2001</code>.</li>"
             "<li>Count the frame (<code>$2B</code>), read <code>$2002</code> into <code>$26</code>, "
             "<strong>sprite DMA</strong> from <code>$0200</code>.</li>"
             "<li><code>$4015 = $1F</code>: starts the DMC timer that will raise the split's IRQ "
             "(below).</li>"
             "<li><code>$DD54</code>: the PPU writes &mdash; first one pending background row (the "
             "scroll engine's, below), then the generic queue at <code>$0100</code> (a run of tiles, "
             "increment 1 or 32, or an attribute edit); and <code>$DEC9</code>: the palette shadow "
             "<code>$0180</code> to <code>$3F00</code>/<code>$3F10</code> when <code>$017F</code> is "
             "non-zero.</li>"
             "<li>If <code>$30</code> bit 4 is set (a scrolling stage), <strong>write tile "
             "<code>$FE</code> into column 0 of the row under scanline 192</strong> &mdash; the "
             "split's target (below).</li>"
             "<li><code>$D68B</code>: <code>$2000 = $FF</code>, <code>$2005 = $FD</code> "
             "(horizontal), <code>$2005 = $FC</code> (vertical).</li>"
             "<li>Render on: <code>$FE = ($FE &amp; $E7) | $A3</code> &mdash; <code>$A3</code> is "
             "0 while the screen is blanked (fades, loading) and <code>$18</code> otherwise.</li>"
             "<li>Sound tick (bank 0 <code>$8009</code>), then the random state is stirred.</li></ol>")
    o.append("<table><thead><tr><th>Shadow</th><th>Meaning</th></tr></thead><tbody>"
             "<tr><td class=\"mono\">$FF</td><td>PPUCTRL. In play it is <code>$B0</code>/<code>$B1</code>: "
             "NMI on, 8 &times; 16 sprites, background and sprites from the "
             "<strong>second</strong> and <strong>first</strong> pattern table respectively (sprite "
             "0's tile <code>$FF</code> in an 8 &times; 16 sprite is read from the table its low bit "
             "selects, the second); bits 0-1 are the nametable, forced each NMI to <code>$A2</code>.</td></tr>"
             "<tr><td class=\"mono\">$A2</td><td>Nametable select = <code>$A7</code> (vertical bit) "
             "&times; 2 + <code>$A9</code> (horizontal bit), built by <code>$D507</code>.</td></tr>"
             "<tr><td class=\"mono\">$A6 $A7</td><td>The vertical scroll the game wants, 0-239, and its "
             "table bit. <code>$FC</code> is <code>$A6</code> as copied for the NMI.</td></tr>"
             "<tr><td class=\"mono\">$A8 $A9</td><td>The horizontal scroll and its table bit; "
             "<code>$FD</code> is its copy.</td></tr>"
             "<tr><td class=\"mono\">$FE $A3</td><td>PPUMASK and the part of it that says rendering is on.</td></tr>"
             "</tbody></table>")

    # ---------------------------------------------------------------- split screen
    o.append('<h2 id="split">The split screen</h2>')
    o.append("<p>The status bar is part of the same frame, not a separate layer. The frame is "
             "<strong>192 scan lines of playfield</strong> and <strong>48 lines of HUD</strong>.</p>")
    o.append("<ol><li><strong>Sprite 0 is a marker.</strong> OAM entry 0 is set by bank 7 "
             "<code>$D51E</code> to y = <code>$BF</code> (191), tile <code>$FF</code>, attributes "
             "<code>$20</code> (behind the background), x = 0. With 8 &times; 16 sprites that is "
             "tiles <code>$FE</code> and <code>$FF</code> of the second pattern table; "
             "<code>$FE</code>'s high plane is all ones, so it is a solid block. It sits in "
             "scan lines 192 and down.</li>"
             "<li><strong>The background gives it something to hit.</strong> A solid background tile "
             "<code>$FE</code> in column 0 at scan line 192. In the labyrinth that tile is part of the "
             "room: the blank row written after the 12 room rows (bank 7 <code>$F03D</code>, "
             "<code>$16</code> = <code>$C0</code>) starts with <code>$FE</code>, row 24 of the table. "
             "In a corridor the picture scrolls, so the NMI rewrites the marker every frame at the row "
             "that is under line 192 for the current <code>$FC</code> (<code>$DCA2-$DCD2</code>); the "
             "ones it leaves behind scroll away out of sight below the window.</li>"
             "<li><strong>The split.</strong> When sprite 0 hits (<code>$2002</code> bit 6, at line "
             "192, because the top half of the sprite is solid), bank 7 <code>$DD21</code> runs: "
             "<code>$2006</code> &larr; <code>$27</code>, <code>$00</code> (the PPU address becomes "
             "<strong>nametable 1, tile row 24, column 0, fine y 2</strong>, immediately), "
             "<code>$2000</code> &larr; <code>$FF</code> with the nametable bits forced to 1, "
             "<code>$2001</code> with the sprite bit cleared, and <code>$2005</code> &larr; 0, 0 (which "
             "also clears fine x). The rest of the frame is NT1 from row 24: the HUD, unscrolled, with no "
             "sprites. The next NMI puts everything back.</li>"
             "<li><strong>The HUD</strong> is NT1 rows 24-29 (the 192 &divide; 8 = 24 rows above it are "
             "the playfield): row 24 blank, 25 \"SC &hellip; CHIP &hellip; SHOT\", 26 the life "
             "meter, 27 \"AREA &hellip; X &hellip; Y\", then two blank rows. Row 24 being blank is why "
             "a couple of lines of timing slack at the join cost nothing.</li></ol>")
    o.append("<h3>Who does the split</h3><p>Two routines can, and either may: the <strong>main "
             "thread</strong> waits for the hit in its frame-sync routine (<code>$DA9A</code>, the "
             "<code>BIT $2002 / BVC</code> loop at <code>$DAB6</code>) and calls <code>$DD21</code>; "
             "and the <strong>DMC interrupt</strong> (IRQ vector <code>$DCF3</code>) does it from the "
             "middle of the game logic. The IRQ exists because the main thread is usually busy, and "
             "this board has no scanline counter. The DMC channel is only a timer: bank 6 "
             "<code>$802A</code> loads a 17-byte all-zero sample (<code>$4012 = $FF</code> &rarr; "
             "<code>$FFC0</code>, <code>$4013 = 1</code>, <code>$4010</code> with the IRQ bit "
             "set), and the NMI restarts it each frame (<code>$4015 = $1F</code>). It ends after "
             "17 &times; 8 = 136 sample periods, and the IRQ handler acknowledges it "
             "(<code>$4015 = $0F</code>), spins on <code>$2002</code> until the hit "
             "(giving up if the frame counter moves) and runs <code>$DD21</code>.</p>")
    o.append("<p><strong>Tuning.</strong> The rate index in <code>$05</code> (low nibble of "
             "<code>$4010</code>) is walked up one step whenever the IRQ turns out to be late (the hit "
             "has already happened, <code>$DD15</code>) and capped at <code>$89</code>. The periods "
             "below are the NTSC DMC table, which is <strong>outside knowledge, not in the ROM</strong>; "
             "the frame starts 2,273 cycles of vblank before line 0 and the hit is at line 192.</p>")
    o.append("<table><thead><tr><th>$4010 (low nibble)</th><th>Period (CPU cycles)</th>"
             "<th>IRQ after the NMI</th><th>Scan line</th><th></th></tr></thead><tbody>" + rows +
             "</tbody></table>")
    o.append("<p>So it starts at <code>$87</code> (set by <code>$EDE8</code>, late), is walked to "
             "<code>$89</code> and stays: the IRQ arrives about 21 lines early and waits. That is the "
             "arithmetic of the table, not a run: the NES model delivers no IRQ, so in every run here "
             "the main-thread path did the split.</p>")

    # ---------------------------------------------------------------- corridors
    o.append('<h2 id="corridor">Corridors: vertical scrolling</h2>')
    o.append("<p>A corridor does not scroll sideways (<code>$A8</code> stayed 0 in the run; a stage is 16 "
             "metatiles = 256 pixels wide). Its picture lives only in <strong>NT0</strong>: 30 tile "
             "rows = 15 metatile rows = 240 lines, of which 192 show.</p><ul>"
             "<li><strong>Speed.</strong> <code>$B8/$B9</code> is the speed in 1/256 pixel a frame "
             "(<code>$0180</code> = 1.5 in the run), moved 2/256 a frame toward the target "
             "<code>$BA/$BB</code> that the stage's commands set. Bank 7 <code>$E530</code> subtracts "
             "it from <code>$B6/$A6</code>: <code>$A6</code> <strong>counts down</strong>, so the "
             "picture moves down the screen and new rows appear at the <strong>top</strong>; when it "
             "passes 0 it wraps to 239 (<code>sbc #$0F</code> on the borrow) and <code>$A7</code> "
             "toggles.</li>"
             "<li><strong>A row every 16 pixels.</strong> <code>$AF</code> adds the pixels moved; at 16 "
             "(<code>$E69B</code>) the next row is built (<code>$E8AB</code>: 16 metatile ids, then "
             "bank 5 <code>$83B3</code> turns them into 32 + 32 tiles and 8 attribute bytes in "
             "<code>$0130</code>, <code>$0150</code> and <code>$04E8</code>) and the row counter "
             "<code>$B0/$B1</code> (the stage clock) goes up. <code>$AE</code> counts the 15 rows "
             "down, 14 to 0 and round again; <code>$EACC</code> turns it into the PPU address "
             "<code>$2000 + $40 &times; $AE</code> in <code>$AC/$AD</code> (plus <code>$0800</code> "
             "while <code>$AB</code> is 1) and the attribute address in <code>$AA</code>.</li>"
             "<li><strong>Two NMIs per row.</strong> <code>$A5</code> is the hand-off: 1 makes the next "
             "NMI write the attribute bytes and the first tile row, 2 makes the one after write the "
             "second tile row (<code>$DD54</code>). Ground objects created from the row take its "
             "PPU address with them (bank 5 <code>$8A42</code>: <code>$AC/$AD</code> into the object's "
             "own <code>$05C0/$05D8</code>), which is how a cannon patches its own background tiles later.</li>"
             "<li><strong>Where the new rows go.</strong> Not onto the visible rows: into the hidden 48 "
             "lines the window does not show. Measured: the row being written is 4 to 6 tile rows above "
             "the top of the window (for example row pair 2-3 while the window starts at row 7.75), "
             "so a row is written about three metatile rows before it scrolls into view.</li>"
             "<li><strong>The HUD</strong> is NT1 rows 24-29 and the marker is rewritten every frame "
             "(above), so the marker row runs ((192 + <code>$A6</code>) mod 240) / 8.</li></ul>")
    o.append('<p><img src="scroll-corridor.png" width="780" style="max-width:100%;height:auto" '
             'alt="Both nametables, the visible window and the screen, in a corridor"></p>')
    o.append('<p class="meta">A corridor frame: NT0 (left) full of stage, NT1 (right) empty but for the '
             "HUD in its bottom rows (green); the red outline is the 192 lines on screen; the yellow "
             "marks are the <code>$FE</code> tiles in column 0 (the live one and the trail below the "
             "window). The right-hand picture is the NES model's frame; the coloured block at its "
             "lower left is sprite 0, which the model does not switch off at the split as the real "
             "PPU does.</p>")

    # ---------------------------------------------------------------- labyrinth
    o.append('<h2 id="labyrinth">The labyrinth: one room at a time</h2>')
    o.append("<p>A room is 16 &times; 12 metatiles = 256 &times; 192, exactly the playfield, so at rest "
             "<code>$A6</code>, <code>$A8</code>, <code>$A7</code> and <code>$A9</code> are all 0 and "
             "the room is in <strong>NT0 rows 0-23</strong>. Bank 7 <code>$F03D</code> draws it a row at "
             "a time (two tile rows a frame, 13 frames), then one blank row with the marker. Everything "
             "that edits the room later (the blocks shots break, "
             "<a href=\"labyrinth.html#cells\">Shooting the room</a>) writes to NT0 at the room's own "
             "position, so the room has to be in NT0 when it stops.</p>")
    o.append("<p>Moving to a neighbouring room is a <strong>scroll of exactly one screen</strong> "
             "(<code>$A4</code> is the exit: 0 north, 2 west, 6 east, 8 south; <code>$F09A</code> "
             "chooses the routine). Measured on the NES model from the savestate, with the real "
             "game code running:</p>")
    o.append("<table><thead><tr><th>Exit</th><th>Scroll</th><th>Steps</th><th>The new room is drawn "
             "into</th></tr></thead><tbody>"
             "<tr><td>East (<code>$F0C2</code>)</td><td><code>$A8</code> 0 &rarr; 252, +4 a frame; "
             "table bit <code>$A9</code> 0, the window moving from NT0 into NT1</td><td>64 frames"
             "</td><td><strong>NT1</strong>, rows 0-24, two rows a frame in the 13 frames "
             "<em>before</em> the scroll starts</td></tr>"
             "<tr><td>West (<code>$F0E8</code>)</td><td><code>$A8</code> 252 &rarr; 0, &minus;4 a "
             "frame, with <code>$A9</code> = 1: the window starts on NT1's right edge (4 pixels of "
             "NT1, the rest wrapped round to NT0) and moves left across it</td><td>64 frames</td>"
             "<td>NT1 again, 13 frames before the scroll</td></tr>"
             "<tr><td>North (<code>$F169</code>)</td><td><code>$A6</code> 236 &rarr; 48 "
             "(counting down, &minus;4), <code>$A7</code> 1</td><td>48 frames</td><td><strong>NT0</strong>, "
             "into the rows the window is about to uncover: rows 29, 28, &hellip; 6, a metatile row "
             "(two tile rows) every 16 pixels, wrapping at the top of the table</td></tr>"
             "<tr><td>South (<code>$F10D</code>)</td><td><code>$A6</code> 0 &rarr; 192 "
             "(counting up, +4)</td><td>48 frames</td><td>NT0, rows 24-29 and then 0-17, wrapping at "
             "the bottom</td></tr></tbody></table>")
    o.append("<p>During all four the ship is moved against the scroll's 4 pixels a frame (bank 7 "
             "<code>$F0C2</code> and its vertical twin), so it crosses to the opposite edge of "
             "the new room as the room slides in (east: ship x 242 &rarr; 18; west: 16 &rarr; 237). "
             "<strong>Correction:</strong> this said 3 pixels a frame for all four. The vertical "
             "exits are exactly 3 (north: y 14 &rarr; 158; south: 177 &rarr; 33, 48 frames), but the "
             "horizontal arm subtracts 3 with a carry left over from unused shifts, so the ship moves "
             "<strong>alternately 3 and 4</strong> (3.5 on average, measured &minus;3, &minus;4, &minus;3, "
             "&minus;4 &hellip;). The horizontal arm is explained routine by routine on the "
             "<a href=\"bank7.html\">bank 7 page</a> (<code>$F09A</code>-<code>$F268</code>).</p>")
    o.append("<h3>Putting the room back in NT0</h3><p>When the scroll ends the new room is on screen but "
             "not where later code expects it, so it is <strong>re-homed</strong> without a visible "
             "jump, with the display switched between identical pictures. After an <strong>east or "
             "west</strong> scroll the new room is the whole of NT1 (<code>$A9</code> = 1, "
             "<code>$A8</code> = 0), so it is <strong>drawn again into NT0</strong> from the room buffer "
             "(<code>$EFF3</code> with A = $20 at <code>$F1DA</code>: a redraw, not a copy, which the "
             "text used to call a copy; 13 frames, hidden) and <code>$A9</code> goes back to 0. After a <strong>north or south</strong> "
             "scroll the new room straddles the wrap of NT0, so it is first <strong>drawn whole "
             "into NT1</strong> (13 frames), the display flips to NT1 at scroll (0, 0), it is drawn "
             "whole into NT0, and the display flips back. Run on the model, east exit: NT1 filled up to "
             "frame 32, the scroll 33-95, at 96 <code>$A8</code> wraps to 0 and <code>$A9</code> = 1, "
             "NT0 filled 97-109, <code>$A9</code> = 0 at 112. West: NT1 filled to frame 27, scroll "
             "28-94, NT0 filled 95-106, <code>$A9</code> = 0 at 107. North: scroll to frame 73, NT1 "
             "filled 75-85, <code>$A9</code> = 1 at 87, NT0 filled 88-100. South: the same shape. Then "
             "the cell map is rebuilt (<code>$8006</code>) and the ship placed (<code>$F269</code>).</p>")
    o.append('<p><img src="scroll-lab-rest.png" width="780" style="max-width:100%;height:auto" '
             'alt="The labyrinth at rest"></p>')
    o.append('<p><img src="scroll-lab-north.png" width="780" style="max-width:100%;height:auto" '
             'alt="The labyrinth part-way through a scroll north"></p>')
    o.append('<p><img src="scroll-lab-east.png" width="780" style="max-width:100%;height:auto" '
             'alt="The labyrinth part-way through a scroll east"></p>')
    o.append('<p class="meta">At rest (first), half-way north (second: the window, in red, has wrapped '
             "round the bottom of NT0; the old room is the upper part of NT0, the new one is being "
             "drawn below it) and half-way east (third: the window straddles NT0 and NT1). The "
             "yellow mark in NT0 column 0 is the room's own row-24 marker.</p>")

    # ---------------------------------------------------------------- status screen
    o.append('<h2 id="status">The status screen</h2>')
    o.append("<p>Select opens it (bank 7 <code>$E4EE</code>; bank 5 <code>$84CB</code>). It needs no "
             "split: it sets <code>$A2 = 1</code> and <code>$FC = $B4</code> (180) and draws its "
             "map, icons and text into NT1. Scrolling NT1 down by 180 lines puts its last 7.5 rows "
             "&mdash; the HUD &mdash; at the top of the screen and rows 0-17 below, so the "
             "HUD stays visible over the new screen with nothing to switch. Sprite 0 is not used "
             "(<code>$30</code> bit 4 is clear). The room is in NT0 the whole time, untouched.</p>")
    o.append('<p><img src="scroll-status.png" width="780" style="max-width:100%;height:auto" '
             'alt="The status screen: NT1 shown with a vertical scroll of 180"></p>')

    # ---------------------------------------------------------------- limits
    o.append('<div class="note"><strong>Checked, and not.</strong> Everything above about registers and '
             "addresses is from the code; the measurements (scroll values by frame, which rows are "
             "written, the alias counts, the transitions' frame counts, the status screen's state, the "
             "HUD rows) are from running the real code on the NES model (<code>tools/tgl/cpu.py</code>) "
             "from the owner's corridor and labyrinth savestates, and the pictures from "
             "<code>tools/render-scroll.py</code>. <strong>Not established:</strong> any of it on "
             "hardware; the IRQ path (the model delivers no IRQ, and the DMC period table is outside "
             "knowledge); the exact scan line the split lands on within the hit line (the HUD begins "
             "on a blank row, so it does not matter on screen); what the vertical re-homing draws in "
             "NT1 first; what the inline PPU fills at <code>$F0A8</code>-<code>$F0C1</code> do in the "
             "horizontal scroll; and the other scrolling screens (the title, the ending, the "
             "password screen) were not looked at.</div>")
    return "".join(o)


LOOP_PROFILE_JSON = Path(__file__).resolve().parents[2] / "annotations" / "loop-profile.json"
# state file name -> (short label, one line on what is going on); the order is the table's
LOOP_STATES = [
    ("ingame", "calm", "corridor 15: 3 enemies and a few shots"),
    ("more1", "more1", "corridor 3: 13 enemies and 2 more objects"),
    ("more2", "more2", "corridor 4: 15 enemies of one kind, scrolling at 3.5 px/frame"),
    ("more3", "more3", "corridor 5: 11 enemies; the boss (Zibzub) arrives during the run"),
    ("more4", "more4", "corridor 8, the boss fight: Grimgrin, 8 objects of type $2A, 7 explosions, 63 sprites"),
]
# object types the project can name; everything else is left as its number
LOOP_TYPE_NAMES = {0x01: "the ship", 0x02: "the gun's bullet", 0x03: "an A-button weapon",
                   0x08: "an explosion", 0x09: "a hit spark", 0x29: "the formation spawner",
                   0x23: "Zibzub, a boss", 0x49: "Grimgrin (second form), a boss"}


def _loop_profile():
    """annotations/loop-profile.json (tools/profile-loop.py's output) keyed by LOOP_STATES' short names."""
    import json as _json

    if not LOOP_PROFILE_JSON.exists():
        return None
    raw = _json.loads(LOOP_PROFILE_JSON.read_text(encoding="utf-8"))
    out = {}
    for name, r in raw.items():
        for key, label, _ in LOOP_STATES:
            if key in name:
                out[label] = r
    return out if len(out) == len(LOOP_STATES) else None


def _loop_timing(rm) -> str:
    """The measured durations of every step of the corridor loop, from the profile file."""
    prof = _loop_profile()
    if prof is None:
        return ""
    FRAME = 29781
    labels = [lab for _, lab, _ in LOOP_STATES]
    desc = {lab: d for _, lab, d in LOOP_STATES}

    def cell(st, key=None, nmi=False):
        v = prof[st]["nmi"] if nmi else prof[st]["phases"].get(key)
        if not v:
            return "<td class=\"mono\">&mdash;</td>"
        return (f"<td class=\"mono\">{v['median']:,}<br><span class=\"meta\">max {v['max']:,}</span></td>")

    steps = [
        ("NMI", "<code>$DC75</code>", None, "everything the NMI does, including the sound tick"),
        ("1", "<code>$F493</code>", "pads", "read the pads, check for pause"),
        ("2", "bank 6 <code>$81FB</code>", "objects", "the object loop: every live slot's handler"),
        ("2a", "&nbsp;&nbsp;of which: the loop's own dispatch", "obj_overhead",
         "walking 24 slots and the sprite allocator, whatever is in them"),
        ("2b", "<code>$CE88</code>", "finish", "hide leftover sprites, check the player's death"),
        ("3", "<code>$E0F9</code>", "hud", "the HUD meter and score (idle: 72; more while the meter moves "
                                            "or the score changes)"),
        ("4", "<code>$DB52</code>", "decomp", "the tile decompressor (idle: 244)"),
        ("5", "bank 3 <code>$917F</code>", "boss", "boss and stage state (a no-op unless a boss)"),
        ("6", "<code>$E655</code> without a new row", "stage_idle", "speed, scroll step"),
        ("6a", "<code>$E655</code> building a row", "stage_row",
         "stream records, row ids, tiles, ground objects (about every 10th frame)"),
        ("7", "<code>$E995</code>", "loader", "art loader and spawn script"),
        ("&sum;", "steps 1 to 7", "logic", "all the logic, with the NMI and any waiting taken out"),
        ("8", "<code>$DA9A</code>", "wait", "idle: the frame sync's wait (23 = it did not wait at all; max = the longest wait)"),
    ]
    rows = ""
    for num, where, key, what in steps:
        cells = "".join(cell(st, key, nmi=key is None) for st in labels)
        strong = ' style="font-weight:bold"' if num == "&sum;" else ""
        rows += (f"<tr{strong}><td class=\"mono\">{num}</td><td>{where}</td>{cells}<td>{what}</td></tr>")
    head = "".join(f"<th>{lab}</th>" for lab in labels)
    states_rows = ""
    for _, lab, d in LOOP_STATES:
        i = prof[lab]["info"]
        mix = ", ".join(f"{n} &times; <code>{t}</code>" for t, n in
                        sorted(i["types"].items(), key=lambda kv: -kv[1]))
        states_rows += (f"<tr><td class=\"mono\">{lab}</td><td>{d}</td><td>{mix}</td>"
                        f"<td class=\"mono\">{i['sprites']}</td>"
                        f"<td class=\"mono\">{i['speed'] / 256:.1f}</td></tr>")
    o = ["<h3 id=\"timing\">Five stages, measured</h3><p>The first column is the calm corridor used so far; the "
         "other four are the owner's savestates of busier moments (<code>more1</code> to "
         "<code>more4</code>). Each was run for 900 frames on the NES model with the ship held "
         "invulnerable (<code>tools/profile-loop.py</code>; the data is "
         "<code>annotations/loop-profile.json</code>).</p>"
         "<table><thead><tr><th>State</th><th>What is going on (at the start)</th><th>Objects</th>"
         "<th>Sprites on screen</th><th>Scroll (px/frame)</th></tr></thead><tbody>" + states_rows +
         "</tbody></table>"]
    o.append("<h3>How long each step takes</h3><p>CPU cycles per loop iteration (29,781 to a frame): "
             "the <strong>median</strong> with the <strong>worst</strong> below it. Times are net: the "
             "NMI, which interrupts whichever step it lands in, is taken out of that step and shown on its "
             "own row.</p>"
             "<table><thead><tr><th>#</th><th>Step</th>" + head + "<th>What</th></tr></thead><tbody>"
             + rows + "</tbody></table>")
    # budget
    brow = ""
    for lab in labels:
        r = prof[lab]
        fr = r["frames_run"]
        lg = r["phases"]["logic"]
        nm = r["nmi"]
        brow += (f"<tr><td class=\"mono\">{lab}</td>"
                 f"<td class=\"mono\">{lg['median']:,} ({100 * lg['median'] / FRAME:.0f}%)</td>"
                 f"<td class=\"mono\">{lg['p90']:,} ({100 * lg['p90'] / FRAME:.0f}%)</td>"
                 f"<td class=\"mono\">{lg['max']:,} ({100 * lg['max'] / FRAME:.0f}%)</td>"
                 f"<td class=\"mono\">{nm['median']:,}</td>"
                 f"<td class=\"mono\">{r['iterations']} / {fr}<br><span class=\"meta\">"
                 f"{60 * r['iterations'] / fr:.1f} a second</span></td>"
                 f"<td class=\"mono\">{r['overrun_iterations']}</td><td class=\"mono\">{r['late_frames']}</td>"
                 f"<td class=\"mono\">{fr - r['split_frames']}</td></tr>")
    o.append("<h3>How much of the frame it is, and what happens when it is not enough</h3>"
             "<table><thead><tr><th>State</th><th>Logic, median</th><th>90th percentile</th><th>Worst</th>"
             "<th>NMI, median</th><th>Iterations / frames</th><th>Iterations longer than a frame</th>"
             "<th>Late frames</th><th>Frames the main thread missed the split</th></tr></thead><tbody>"
             + brow + "</tbody></table>")
    o.append("<ul><li><strong>Late frame:</strong> the NMI arrived while the logic was still running. The "
             "loop was not at its sync, so that NMI had only the <em>previous</em> iteration's sprites, "
             "scroll and row to put on the screen: the picture repeats and then jumps. When the loop "
             "reaches the sync with the NMI already counted (<code>$2B</code> non-zero) "
             "<code>$DA9A</code> skips both waits and the next iteration starts at once, short, so "
             "<strong>the game's own speed holds</strong> while the picture is irregular (the first four "
             "states keep 59.9 iterations a second).</li>"
             "<li><strong>The loop falls behind</strong> only when the logic takes most of a frame all "
             "the time: in <code>more4</code> the object loop alone is about 26,500 cycles, the logic with "
             "a new row up to 36,660, and 52 of 900 frames pass without an iteration finishing: "
             "56.5 a second, about 6% slower than the screen.</li>"
             "<li><strong>The split.</strong> When the logic runs past scan line 192 the main thread cannot "
             "do the HUD split in its sync, and that is what the DMC interrupt is for (it ran the "
             "split from the middle of the logic on the console). The NES model has no IRQ, so the "
             "'missed' column counts frames in which the model would have left the HUD unsplit: "
             "a measure of how often the IRQ does the job, not of lost frames.</li></ul>")
    # handlers
    agg = {}
    for lab in labels:
        for t, h in prof[lab]["handlers"].items():
            a = agg.setdefault(t, {"calls": 0, "max": 0, "meds": {}})
            a["calls"] += h["n"]
            a["max"] = max(a["max"], h["max"])
            a["meds"][lab] = h["median"]
    nm = _enemy_names()
    hrows = ""
    for t, a in sorted(agg.items(), key=lambda kv: -max(kv[1]["meds"].values())):
        n = int(t[1:], 16)
        name = LOOP_TYPE_NAMES.get(n) or nm.get(n) or "an enemy or effect (not named)"
        cells = "".join(
            f"<td class=\"mono\">{a['meds'][lab]:,}</td>" if lab in a["meds"] else "<td class=\"mono\">&mdash;</td>"
            for lab in labels)
        hrows += (f"<tr><td class=\"mono\">{t}</td><td>{name}</td>{cells}"
                  f"<td class=\"mono\">{a['max']:,}</td></tr>")
    o.append("<h3>What an object costs</h3><p>Cycles for one call of a type's handler (median per call, "
             "net of the NMI), in every state where the type was present, and the worst call seen. "
             "The object loop's time is these added up over the live slots, plus about 75-90 for the "
             "loop itself; a type with no cost in a state was not alive there.</p>"
             "<table><thead><tr><th>Type</th><th>What</th>" + head + "<th>Worst</th></tr></thead><tbody>"
             + hrows + "</tbody></table>")
    o.append("<p>Reading it: the <strong>ship</strong> is the dearest ordinary object (about 2,250: its "
             "step, the pad, the cell and weapon logic, and its own sprites), the <strong>bosses</strong> "
             "are in another class (Grimgrin 9,170 a call, Zibzub 5,670), an ordinary enemy costs "
             "between about 450 and 2,100 (most <strong>600 to 1,400</strong>), a controller or the "
             "spawner <strong>70 to 500</strong>, an explosion about <strong>680</strong>. Fifteen of "
             "<code>$5F</code> enemies (960 each) alone are 14,400 cycles.</p>")
    return "".join(o)


def _game_loop_page(rm):
    """What one frame of a corridor does: the main loop, the NMI, and what runs every Nth frame."""
    # (median first cycle, min, max) of each phase in a 400-frame corridor run on the NES model;
    # the frame is 29,781 cycles and starts with the NMI. Measured, not read: see the note.
    T = [
        ("NMI", "0", "&mdash;",
         "<code>$DC75</code>", "Render off; sprite DMA from <code>$0200</code>; the background row (or the "
         "<code>$0100</code> queue) written to the PPU; the sprite-0 marker tile; the scroll registers; "
         "render on; then the <strong>sound tick</strong>. Runs on its own, interrupting whatever the main "
         "thread was doing (always the frame sync, step 8).", "every frame"),
        ("1", "2,256", "1,973&ndash;4,095",
         "<code>$DA9A</code> returns; <code>$F493</code> &rarr; <code>$D64C</code>",
         "The frame sync ends (below) and the <strong>pads</strong> are read; a demo's Start ends it, otherwise "
         "Start pauses and Select opens the status screen.", "every frame"),
        ("2", "3,245", "2,962&ndash;5,084",
         "bank 6 <code>$81FB</code>", "The <strong>object loop</strong>: reset the sprite allocator, then run the "
         "handler of every live object slot 0-23 &mdash; the player first, then the enemies and shots. Each handler "
         "moves its object, draws it into <code>$0200</code>, makes its hit box and tests collision. Then the "
         "unused sprites are hidden and the player's death is checked.", "every frame"),
        ("3", "9,005", "7,032&ndash;11,024",
         "<code>$E0F9</code>", "The <strong>HUD</strong>: the life meter steps one toward the real life; the "
         "frame counter <code>$41</code> goes up; if the score changed, the score is redrawn on every 8th frame.",
         "every frame; the score every 8th"),
        ("4", "9,147", "7,104&ndash;11,613",
         "<code>$DB52</code>", "The <strong>tile decompressor</strong> fills the PPU queue with as many decoded "
         "bytes as it has room for, if a graphics block is loading.", "every frame, when loading"),
        ("5", "9,391", "7,348&ndash;11,857",
         "bank 3 <code>$917F</code>", "The <strong>stage and boss state machine</strong> (<code>$70</code>): "
         "returns at once unless a boss encounter is under way.", "every frame (usually a no-op)"),
        ("6", "9,452", "7,409&ndash;11,918",
         "<code>$E655</code>", "The <strong>stage step</strong>: speed, scroll, and &mdash; when 16 pixels "
         "have gone by &mdash; the next background row, the stream records that fire on it and the ground "
         "objects it holds.", "every frame; a new row about every tenth"),
        ("7", "9,819", "7,822&ndash;16,174",
         "<code>$E995</code>", "<strong>Art loader</strong> (<code>$E99F</code>) and <strong>spawn script</strong> "
         "(<code>$F78F</code>): load the next tile block, count the current wait, spawn what the script says.",
         "every frame"),
        ("8", "9,987", "7,990&ndash;16,355",
         "<code>$FF8B</code> &rarr; <code>$DA9A</code>", "The <strong>frame sync</strong>: spin until sprite 0 is hit, "
         "do the HUD split, then wait for the NMI. The logic is over; the frame's remaining time is spent here.",
         "every frame"),
        ("split", "24,227", "24,224&ndash;24,230", "<code>$DD21</code>", "Sprite 0 hits (scan line 192) and the "
         "split is done (<a href=\"rendering.html#split\">Rendering</a>).", "every frame"),
    ]
    rows = "".join(
        f"<tr><td class=\"mono\">{a}</td><td class=\"mono\">{b}</td><td class=\"mono\">{c}</td>"
        f"<td>{d}</td><td>{e}</td><td>{f}</td></tr>" for a, b, c, d, e, f in T)
    o = ["<h1>Game loop</h1>",
         '<p class="sub">What happens in one 1/60 second of a corridor, and then of the labyrinth: the order of '
         "the work, how long it takes, what the NMI does behind it, and what only happens every so many "
         'frames. <a href="#labyrinth-loop">Jump to the labyrinth.</a></p>',
         '<div class="note"><strong>In short.</strong> The game is one loop with a <strong>frame sync in the middle '
         "of it</strong>, plus an NMI that interrupts the sync. Per frame: the NMI puts last frame's sprites, "
         "the scroll and one background row on the screen and ticks the sound; the loop then reads the pads, runs "
         "every object's handler (which moves, draws and collides it), steps the HUD, the decompressor and the "
         "boss state, scrolls the stage and runs the spawn script, and finally waits &mdash; for sprite 0, to cut "
         "the screen in two, and then for the next NMI. On the NES model a calm corridor's logic takes about "
         "8,100 of the 29,781 cycles in a frame (27%), busy ones 10,000 to 18,000, and a boss fight "
         "<strong>28,800 (97%)</strong>, where the loop no longer has time to wait and the game runs at "
         "56 iterations a second. <a href=\"#timing\">The measurements.</a></div>"]

    # ---------------------------------------------------------------- the loop
    o.append('<h2 id="loop">The loop</h2>')
    o.append("<p>Bank 7 <code>$FF5D</code> sets the game up and then spins in <code>$FF7A</code>:</p>"
             "<pre>FF7A  JSR $E655        ; the stage step: speed, scroll, new row, stream records\n"
             "      LDY #$01\n"
             "      JSR $FF8B        ; one pass of the frame body (below)\n"
             "      JSR $D76F        ; far call: bank 3 $800F -&gt; $917F, the stage/boss routine\n"
             "      JMP $FF7A\n\n"
             "FF8B  ...\n"
             "FF8D  JSR $DA9A        ; FRAME SYNC: wait for sprite 0 (split), then for the NMI\n"
             "      JSR $F493        ; read the pads; pause / status screen\n"
             "      JSR $D76F        ; far call: bank 6 $8000 -&gt; $81FB, the object loop\n"
             "      JSR $E0F9        ; HUD meter, frame counter, score\n"
             "      JSR $DB52        ; tile decompressor\n"
             "      DEY / BNE $FF8D  ; Y passes</pre>")
    o.append("<p>The listing starts at the top of the loop, but a frame <em>starts</em> in the middle: the NMI "
             "arrives while the main thread is waiting in <code>$DA9A</code>, and that is where the pads, the "
             "objects, the HUD and the decompressor run, followed by the boss routine, the stage step and the "
             "loader, and then the wait again. <code>FF8B</code> with Y = n (reached through "
             "<code>$C024</code>) is the call that runs the game for n frames, with pads, objects, HUD and "
             "decompressor all still going: bank 0's GAME OVER loop uses it with Y = 1. "
             "<code>$FFD1</code> is the lighter wait that only syncs, which the labyrinth's room scrolls use.</p>")
    o.append(_loop_timing(rm))
    o.append("<h3>A calm frame as a timeline</h3><p>Where in the frame each step <em>starts</em>, in the calm "
             "corridor (the median of 400 frames; cycles after the start of the NMI; 29,781 to the frame, "
             "113.67 to a scan line, the first 2,273 are vblank). This is the order, and it is only "
             "meaningful while the loop keeps up; the durations above are what a step costs.</p>")
    o.append("<table><thead><tr><th>#</th><th>Starts at</th><th>Range</th><th>Where</th><th>What</th>"
             "<th>How often</th></tr></thead><tbody>" + rows + "</tbody></table>")
    o.append("<p>A frame in which a new row is built is longer: the row's 16 metatile ids and the tile expansion "
             "cost about 5,200 to 6,900 cycles (step 6a above), which is why the calm corridor's worst "
             "iterations end at 15,000 rather than 8,000.</p>")

    # ---------------------------------------------------------------- the NMI
    o.append('<h2 id="nmi">The NMI: what reaches the screen</h2>')
    o.append("<p>Everything the loop computes is invisible until the next NMI copies it. In order "
             "(<code>$DC75</code>; also <a href=\"rendering.html#nmi\">Rendering</a>): rendering off; "
             "frame counter <code>$2B</code> up; sprite DMA; DMC restart; <code>$DD54</code>, which "
             "writes the one pending background row (<code>$A5</code> says whether its first tile row, "
             "second tile row or neither goes this frame) and then the PPU queue at <code>$0100</code>; "
             "the palette upload; the sprite-0 marker; the scroll registers; rendering on; the "
             "<strong>sound tick</strong> (bank 0 <code>$917C</code>); and a stir of the random state "
             "(<code>$2A</code> is mixed with the stack pointer at that moment, which is as "
             "unpredictable as the instruction the NMI landed on). The NMI's own length varies "
             "(1,555 to 4,595 cycles over the five states, median about 2,100-2,300): the sound tick alone is about "
             "1,600, and a long queue or a row adds to it. <strong>Rendering is off while the NMI runs</strong> "
             "(step 1 above), so whatever runs past the end of vblank (2,273 cycles in the model; the 513 "
             "cycles of sprite DMA, which the model does not count, would come on top) blanks the top scan "
             "lines of that frame. In the model that is 29-53% of frames (262 to 478 of 900), by up to "
             "15 lines in the calm corridor and 20 in <code>more3</code>. This is arithmetic from the NMI's "
             "length, not something seen on a screen.</p>")
    o.append("<p><strong>Consequence: one frame of latency.</strong> Sprites built in step 2 are DMA'd at the "
             "<em>next</em> NMI and the scroll registers set in step 6 are written then too, so a "
             "background that moved this frame and the sprites that moved with it (ground objects are "
             "shifted by the same <code>$B7</code> the scroll step used) appear together, one frame after "
             "the logic.</p>")

    # ---------------------------------------------------------------- frame sync
    o.append('<h2 id="sync">The frame sync</h2>')
    o.append("<p><code>$DA9A</code> is two waits in one. If the NMI has already happened "
             "(<code>$2B</code> is non-zero) it just clears the flag and returns. Otherwise, unless the "
             "I flag is set (the IRQ already did it): with sprites enabled it spins on "
             "<code>$2002</code> bit 6 (<code>$DAB6</code>) &mdash; first making sure the flag is "
             "not left over from the last frame &mdash; until sprite 0 hits at scan line 192, runs the "
             "split (<code>$DD21</code>), adjusts the DMC timer's rate, and then waits for "
             "<code>$2B</code> to become non-zero, i.e. the NMI. So the spin ends at cycle "
             "24,227 and the rest, about 5,500 cycles, is a quiet wait. The DMC interrupt can "
             "perform the split earlier from the middle of the logic; on the NES model, which "
             "has no IRQ, the sync always did.</p>")

    # ---------------------------------------------------------------- pads
    o.append('<h2 id="pads">Reading the pads</h2>')
    o.append("<p><code>$D64C</code> reads both pads with <code>ROL</code> (A ends in bit 7, Right in bit 0) "
             "<strong>again and again until two consecutive reads agree</strong>, then keeps "
             "<code>$F7/$F8</code> (held) and <code>$F5/$F6</code> (pressed this frame). That is "
             "what a program has to do when the DMC channel is running, as this one's timer "
             "is. Then <code>$F493</code> checks the pause and status keys "
             "(<code>$E4B3</code>): a new Start waits in a loop (the objects do not run, the sound "
             "does); a new Select runs the status screen. The player's own handler turns the D-pad "
             "into <code>$32</code>, a 3 &times; 3 cell index, each frame (<code>$DAE1</code>, which in a "
             "demo overwrites the pads with its own patterns first).</p>")

    # ---------------------------------------------------------------- object loop
    o.append('<h2 id="objects">The object loop</h2>')
    o.append("<p>Bank 6 <code>$81FB</code>. There are 24 object slots (<a href=\"enemies.html\">Enemies</a>): "
             "0-4 the player and its shots, 5-23 everything else.</p><ol>"
             "<li><strong>Reset the sprite allocator</strong> (<code>$CDB4</code>: the first OAM entry to fill, "
             "<code>$80</code>, is normally entry 1 &mdash; entry 0 is the split's sprite 0).</li>"
             "<li><strong>For each slot in turn</strong> (<code>$35</code>) whose type "
             "<code>$0500+slot</code> is not 0, jump through the split dispatch table "
             "(<code>$80DE</code>/<code>$815D</code>) to that type's handler; it returns to "
             "<code>$8227</code>. <strong>The order flips every two frames:</strong> slots 0-4 always come "
             "first, then 5&rarr;23 for two frames, then 23&rarr;5 for two (the table at "
             "<code>$81DD</code>, chosen by bit 1 of the loop counter <code>$36</code>). Measured: "
             "<code>[0, 5, 6, 7, 8, 9, 23]</code>, <code>[0, 23, 9, 8, 7, 6, 5]</code>, the same again, then "
             "forward again. Its effect is that when sprites run out, the ones that lose are not always the "
             "same ones.</li>"
             "<li><strong>Finish</strong> (<code>$CE88</code>): sprites left over from the previous frame are "
             "hidden (y = <code>$F8</code>). <strong>Correction:</strong> this entry said the allocator's flag byte "
             "<code>$83</code> is flipped every frame. It is flipped (<code>$CEFE</code>, bit 0 = the fill "
             "direction: upward from OAM offset 4, or downward from <code>$FC</code>) only when the frame "
             "ran out of OAM (bit 7) or when the PPU's sprite-overflow flag (<code>$26</code> bit 5) was set. "
             "Run: in the calm corridor <code>$83</code> stays <code>$04</code> and the direction never "
             "changes; in the boss fight (63-64 sprites) it flips every frame (<code>$84</code>-<code>$87</code>) "
             "and the downward extent <code>$81</code> steps <code>$FC</code>, <code>$F4</code>, "
             "<code>$F0</code>, <code>$EC</code>. So the sprites that lose when a line holds more than 8 "
             "alternate only when that actually happens.</li>"
             "<li><strong>The player's death</strong> is decided here: the player's slot becomes the death "
             "object type 4 when a hit empties the life meter, and at the end of the loop, if the "
             "meter and <code>$2E</code> are all 0, the game goes to bank 0 <code>$81DD</code> (GAME OVER) "
             "(<a href=\"labyrinth.html#cells\">see the cell page</a>).</li></ol>")
    o.append("<p><strong>What a handler does</strong> varies by type (a hundred and twenty-seven of them), "
             "but nearly all follow one shape, and every step is a call into a shared routine in bank 7:</p><ol>"
             "<li><strong>First frame:</strong> bit 7 of the type is clear, so initialise: hit points, attack, "
             "collision flags and drawing flags are copied from the per-type tables "
             "(<code>$D02C</code>, <code>$D0AB</code>, <code>$D12A</code>, <code>$D1A9</code>; "
             "<code>$CFA0</code>), the type gets bit 7.</li>"
             "<li><strong>Move:</strong> a velocity, a spring toward a target "
             "(<code>$CD12</code>/<code>$CD46</code>), an aim at the player "
             "(<code>$F863</code>) or a script; ground objects also add the scroll step "
             "<code>$B7</code> so they stay on the background.</li>"
             "<li><strong>Draw:</strong> <code>$CBE8</code> &rarr; <code>$CC34</code> turns the object's "
             "metasprite id into hardware sprites in OAM at the allocator's cursor, one per "
             "pass of <code>$CDD7</code>, flipping and offsetting as the id says, from the position "
             "<code>$0518</code> (y), <code>$0530</code> (x).</li>"
             "<li><strong>Hit box:</strong> <code>$D229</code> makes a box from the position and the "
             "metasprite's half width and height (<code>$C174</code>, <code>$C201</code>).</li>"
             "<li><strong>Collide:</strong> an enemy tests its box against slots 4 down to 0 "
             "(<code>$D348</code>) &mdash; a shot or the ship counts only if its collision flags share a "
             "bit with the test's mask &mdash; and <code>$D2BB</code>/<code>$D2C5</code>/<code>$D39B</code> "
             "then take each side's attack from the other's hit points. The player's own "
             "overlap with enemies and their shots is therefore found in the <em>enemies'</em> handlers, "
             "up to five box tests per enemy per frame.</li>"
             "<li><strong>Die:</strong> at 0 hit points the type becomes <code>$D441[type]</code> "
             "&mdash; an explosion (<code>$08</code>, which is where the item box counter runs), "
             "a bigger one (<code>$07</code>) for bosses &mdash; and the handler for that type runs from "
             "the next frame.</li></ol>")
    o.append("<h3>The player (slot 0)</h3><p>Bank 3 <code>$8C98</code>, once per frame: build "
             "<code>$32</code> from the pad; in a corridor, steer: the ship's bank angle "
             "<code>$0680</code> (0-10) moves one step toward the D-pad's left or right and picks the "
             "sprite and flip (<code>$8EFD</code>/<code>$8F08</code>); the direction becomes a velocity "
             "(<code>$F8CE</code>) and the position is clamped to x 12-244, y 24-176; "
             "<strong>B</strong> counts <code>$33</code> down and spawns a bullet "
             "(<a href=\"status.html#gun\">the gun</a>); <strong>A</strong> spawns a weapon object "
             "(<a href=\"status.html#subweapons\">the weapons</a>); after a hit the ship "
             "spins for 15 frames and blinks (<code>$0788</code>, collision flags bits 7 and 6); the "
             "exhaust is drawn as a second piece whose frame follows the scroll speed.</p>")

    # ---------------------------------------------------------------- the rest
    o.append('<h2 id="stage">Stage, boss, scroll and spawns</h2>')
    o.append("<ul><li><strong>Boss and stage state</strong> (bank 3 <code>$917F</code>, after the "
             "decompressor): <code>$70</code> is 0 for nearly the whole stage and the routine "
             "returns at once. A stream record sets it to 1 at the boss's row: <strong>1</strong> "
             "turns the score into the stage's points gained, plays the warning (<code>$0300 = $40</code>, "
             "sound <code>$45</code>) and, when the corridor's flags (<code>$913A</code>) say so, blows "
             "up the ordinary enemies; <strong>2</strong> waits (<code>$73/$74</code>, in 64-frame ticks, "
             "beeping) and starts the boss music; <strong>3</strong> "
             "creates the boss object (<code>$72</code>) and remembers its slot; <strong>4</strong> "
             "watches it (every 64th frame, <code>$41 &amp; $3F</code>, the bonus ticks 10 down); "
             "<strong>5/6</strong> run the eight explosions, the victory song and set the stage-end flag "
             "<code>$A0</code> bit 0, which <code>$E655</code> sees on the next pass "
             "(<a href=\"ending.html\">Ending</a>).</li>"
             "<li><strong>Stage step</strong> (<code>$E655</code>): clears the step <code>$B7</code> "
             "and the new-row flag (<code>$A0</code> bit 2); if the stage-end flag is up, hands over to "
             "<code>$EB18</code>; otherwise ramps the speed <code>$B8/$B9</code> by 2/256 toward "
             "<code>$BA/$BB</code>, subtracts it from the scroll (<code>$E530</code>) and adds the "
             "whole pixels to <code>$AF</code>.</li>"
             "<li><strong>Every 16 pixels</strong> (<code>$AF</code> &ge; 16): finish the previous "
             "row's PPU writes (<code>$E5EB</code>), count the row (<code>$B0/$B1</code>, the stage "
             "clock), find its PPU address (<code>$EACC</code>), switch to bank 4 and "
             "<strong>fire every stream record whose trigger equals the row</strong> (<code>$E6CE</code>; "
             "speed changes, palettes, art loads, a wave script, the boss, the end), then "
             "build the row's 16 metatile ids (<code>$E8AB</code>, with the overlay structures over it), "
             "expand it to tiles and attributes (bank 5 <code>$83B3</code>), spawn the ground "
             "objects it holds (<code>$89FB</code>), arm the transfer (<code>$A5</code> = 1) and set "
             "the new-row flag. <a href=\"corridors.html\">Corridors</a> has what the records say.</li>"
             "<li><strong>Art loader and spawn script</strong> (<code>$E995</code>, every frame): "
             "<code>$E99F</code> advances the art-load stream by one tile block when the previous one "
             "has decoded; <code>$F78F</code> runs the current wave script. Its waits are counted "
             "in <strong>new rows</strong> while the stage scrolls (<code>$A0</code> bit 2 set by "
             "the row code: <code>$68</code> goes down one per row) and in <strong>seconds</strong> "
             "(<code>$69</code>, reloaded with 60) when the scroll has stopped &mdash; so waves follow the "
             "scroll, and a boss that stops it gets a clock instead.</li></ul>")

    # ---------------------------------------------------------------- sound
    o.append('<h2 id="sound">Sound</h2>')
    o.append("<p>Two halves. <strong>Starting</strong> a sound is immediate and happens in the game code, in "
             "whatever step caused it: <code>$D852</code> switches to bank 0, calls <code>$8006</code> "
             "(which loads the song or effect header into a free soft channel) and switches back. "
             "<strong>Playing</strong> is the tick, once per frame at the end of the NMI "
             "(bank 0 <code>$917C</code>, about 1,600 cycles): it steps each active channel's "
             "duration, reads the next note or command from its stream, runs the pitch and "
             "volume envelopes, and writes the APU shadow <code>$0308-$0317</code> to "
             "<code>$4000-$4015</code>. Notes therefore change on frame boundaries, never in between; a "
             "tick that finds <code>$0307</code> non-zero does nothing. "
             "(<a href=\"sound.html\">Sound</a>.)</p>")

    # ---------------------------------------------------------------- periodic
    o.append('<h2 id="periodic">Things that do not happen every frame</h2>')
    o.append("<table><thead><tr><th>Period</th><th>What</th><th>Driven by</th></tr></thead><tbody>"
             "<tr><td>16 scroll pixels (about 10 frames at the run's 1.5 px/frame: 38 new-row frames in "
             "400)</td><td>A new background row: stream records, row ids, tiles, ground objects</td>"
             "<td><code>$AF</code> overflow, bank 7 <code>$E69B</code></td></tr>"
             "<tr><td>2 NMIs per row</td><td>The row reaches the PPU in two halves</td>"
             "<td><code>$A5</code> 1 then 2, <code>$DD54</code></td></tr>"
             "<tr><td>every 8th frame, if the score changed</td><td>Score redrawn</td>"
             "<td><code>$41 &amp; 7</code>, <code>$40</code>, bank 7 <code>$E0F9</code></td></tr>"
             "<tr><td>every frame, one step</td><td>Life meter fills or drains toward the real life</td>"
             "<td><code>$49</code> &rarr; <code>$48</code>, <code>$E30C</code></td></tr>"
             "<tr><td>every 2 frames</td><td>The object loop's slot order flips</td>"
             "<td><code>$36</code> bit 1</td></tr>"
             "<tr><td>every 8th frame</td><td>Shots that wear out (the A-button weapons) take damage "
             "from the enemies they touch</td><td><code>$41 &amp; 7</code>, bank 7 <code>$D3A9</code></td></tr>"
             "<tr><td>every 60 frames (120 with two objects)</td><td>A running A-button weapon is charged "
             "its chips</td><td><code>$3F</code>, bank 6 <code>$8616</code></td></tr>"
             "<tr><td>the gun's delay (<code>$39</code> frames)</td><td>Next bullet</td>"
             "<td><code>$33</code>, bank 3 <code>$8E04</code></td></tr>"
             "<tr><td>every 64th frame in a boss fight</td><td>The stage bonus ticks down by 10</td>"
             "<td><code>$41 &amp; $3F</code>, bank 3 <code>$9305</code></td></tr>"
             "<tr><td>every new row, or every 60 frames when stopped</td><td>The spawn script's wait "
             "counts down</td><td><code>$68</code>/<code>$69</code>, bank 7 <code>$F78F</code></td></tr>"
             "<tr><td>per object, by its own counters</td><td>Enemy animation, firing, phases "
             "(<code>$CD7A</code> phase counters wrap at a type-specific limit)</td>"
             "<td>each handler</td></tr>"
             "<tr><td>every frame, but only a share of the budget</td><td>Tile decompression</td>"
             "<td>room in the PPU queue, <code>$DB52</code> (up to <code>$4D</code> bytes, "
             "<code>$2D</code> while a row is pending)</td></tr>"
             "</tbody></table>")

    # ================================================================ labyrinth
    L = [
        ("1", "2,168", "1,765&ndash;3,070", "pads (<code>$F493</code>)"),
        ("2", "3,157", "2,754&ndash;4,059", "object loop starts (<code>$81FB</code>)"),
        ("2'", "11,144", "7,152&ndash;12,502", "object loop ends (<code>$CE88</code>)"),
        ("3", "11,285", "7,356&ndash;12,643", "HUD (<code>$E0F9</code>)"),
        ("4", "11,560", "7,744&ndash;13,031", "decompressor (<code>$DB52</code>)"),
        ("5", "11,804", "7,988&ndash;13,275", "boss/stage state (<code>$917F</code>)"),
        ("6", "11,865", "8,049&ndash;13,336", "stage step (<code>$E655</code>): 34 cycles to the loader"),
        ("7", "11,899", "8,083&ndash;13,370", "art loader and spawn script (<code>$E995</code>)"),
        ("8", "12,045", "8,229&ndash;13,516", "frame sync (<code>$DA9A</code>)"),
        ("split", "24,227", "24,224&ndash;24,230", "sprite 0 hit and the HUD split (<code>$DD21</code>)"),
    ]
    lrows = "".join(f"<tr><td class=\"mono\">{a}</td><td class=\"mono\">{b}</td><td class=\"mono\">{c}</td>"
                    f"<td>{d}</td></tr>" for a, b, c, d in L)
    o.append('<h2 id="labyrinth-loop">The labyrinth\'s frame</h2>')
    o.append("<p>The loop does not know which mode it is in. <strong>Everything above runs in the "
             "labyrinth too, in the same order</strong>: NMI, sync, pads, object loop, HUD, decompressor, "
             "boss routine, stage step, loader. What changes is what some of those steps find to do.</p>")
    o.append("<h3>One frame, measured</h3><p>300 frames in the owner's labyrinth savestate "
             "(a room whose spawn script keeps making type-<code>$0F</code> enemies; no buttons held; "
             "<code>tools/trace-frame.py --state ...labyrinth.fcs</code>). The NMI takes the same work as in "
             "a corridor minus the marker tile (about 2,140 cycles).</p>"
             "<table><thead><tr><th>#</th><th>Starts at (median)</th><th>Range</th><th>Where</th></tr></thead>"
             f"<tbody>{lrows}</tbody></table>"
             "<p>The logic ends at about 12,000 cycles and never later than 13,516 (45% of the frame); "
             "there are no new-row spikes, and the load follows the <strong>number of enemies</strong> instead "
             "(the object loop ended at 9,350 in the first 60 frames and at 11,144 at the median of 300 as "
             "the room filled). In the traced frame the player's handler took about 1,600 cycles (2,150 "
             "while moving and firing), the type-<code>$29</code> spawner 530, each enemy 120 to 800, "
             "a bullet 900 and a block's blast 700. Nothing overran.</p>")
    o.append("<h3>What is different</h3><ul>"
             "<li><strong>The stage step is almost empty.</strong> With <code>$30</code> bit 6 clear, "
             "<code>$E655</code> clears <code>$B7</code> and the new-row flag, tests the stage-end flag "
             "(<code>$A0</code> bit 0, which here means <em>leave the room</em>) and jumps straight to the "
             "loader: no scroll, no rows, no stream records, no ground objects. There is no "
             "<code>E530</code> or <code>E6AC</code> in the trace.</li>"
             "<li><strong>The marker tile is not rewritten.</strong> The sprite-0 target is the room's own "
             "row 24 (<a href=\"rendering.html#split\">Rendering</a>), so the NMI skips that step "
             "(<code>$30</code> bit 4 is clear).</li>"
             "<li><strong>Spawn-script waits are in seconds.</strong> There are no rows to count, so "
             "<code>$F78F</code> counts <code>$69</code> down from 60 and takes one off the wait "
             "<code>$68</code> each time: waits are in whole seconds.</li>"
             "<li><strong>Shots read the room.</strong> Every bullet and weapon looks up the cell under its "
             "hit box each frame (bank 6 <code>$84E7</code>) and may break it "
             "(<a href=\"labyrinth.html#cells\">Shooting the room</a>); in a corridor that lookup always "
             "answers 0.</li></ul>")
    o.append("<h3>The player's step</h3><p>The same slot-0 handler (bank 3 <code>$8C98</code>) takes the "
             "labyrinth branch at <code>$8D03</code>, once a frame:</p><ol>"
             "<li><strong>Facing and sprite</strong> (<code>$8F53</code>/<code>$8F90</code>): the D-pad cell "
             "<code>$32</code> picks one of eight facings (<code>$8EF4</code> &rarr; <code>$0668</code>); the "
             "facing and the animation frame <code>$0638</code> choose the sprite's tile base "
             "(<code>$8F13</code>) and flip; after a hit the ship spins instead.</li>"
             "<li><strong>Velocity:</strong> <code>$F8CE</code> turns the facing into a velocity at speed class "
             "<code>$0698</code> = 3, <strong>1.4 pixels a frame</strong> (a corridor's is 5, 2.3). "
             "Measured: x 124 &rarr; 139 in 11 frames holding Right.</li>"
             "<li><strong>Move with the room's walls</strong> (<code>$8FB9</code> far-calls bank 6 "
             "<code>$826D</code>): it forms the target position, offset 8 down to the ship's feet "
             "(<code>$06B0</code>), reads the classes of the cells it would touch from "
             "<code>$0400</code>, and if any blocks (<code>$8425</code>: classes 4-10 and 14) it snaps to the "
             "edge of the blocked cell and keeps the other axis moving, so the ship <strong>slides along "
             "walls</strong>: holding Down+Right against a wall it went on at 1.0 pixel a frame along it. "
             "Fractions are kept in <code>$0758</code>/<code>$0770</code>.</li>"
             "<li><strong>What the cell under it is</strong> (<code>$8FBF</code>, only when the class "
             "<code>$6C</code> has changed since last frame): class 1 is the blue sphere (+20 chips, +2 life), "
             "class 2 the warp panel, which leaves the room if the key is held "
             "(<a href=\"labyrinth.html#cells\">Shooting the room</a>).</li>"
             "<li><strong>The room's edges</strong> (<code>$9045</code>): at y &lt; 16, y &ge; 176, x &lt; 14 "
             "or x &ge; 242 the ship is held at the edge &mdash; unless that exit is open "
             "(<code>$54</code> bits 7, 4, 6, 5 for N, S, W, E) <em>and</em> has no key door "
             "(<code>$58-$5B</code> is 8), in which case it sets the exit direction <code>$A4</code> "
             "(0 N, 2 W, 6 E, 8 S) and <code>$A0</code> bit 0.</li>"
             "<li><strong>Then the same as in a corridor:</strong> gun on B, weapon on A, hit flash "
             "(<code>$8DF5</code> on).</li></ol>")
    o.append("<h3>Leaving a room: the loop stops</h3><p>The exit flag is noticed at the top of the "
             "<em>next</em> loop pass, in <code>$E655</code>, which calls <code>$EB18</code>, and "
             "<code>$EB18</code> does not return until the new room is on screen. In between, "
             "<strong>nothing of the normal frame runs</strong>: measured on the NES model, from the frame "
             "that took the exit to the first frame whose object loop ran again, the loop was suspended for "
             "<strong>98 frames (east), 81 (north) and 81 (south)</strong>. The pads are not read (so the "
             "player cannot steer), no object handler runs (enemies and shots vanish), the HUD and boss "
             "routine do not run; the transition's own code does the work, waiting with "
             "<code>$FFD1</code> (a sync only) between steps, drawing the new room two tile rows a "
             "frame, moving the scroll, and drawing <em>only the ship</em> each frame "
             "(<code>$F258</code>: reset the allocator, the ship's sprite, finish). The NMI carries on: "
             "sprites, scroll, the sound tick. How the scroll itself works is on "
             "<a href=\"rendering.html#labyrinth\">Rendering</a>; the room is rebuilt from the ROM, which is "
             "why broken blocks come back.</p>")
    o.append("<h3>Rooms and frames</h3><table><thead><tr><th>Period</th><th>What</th></tr></thead><tbody>"
             "<tr><td>every frame</td><td>The ship's step above; the room's enemies and shots; the "
             "spawner (a type-<code>$29</code> object in slot 23) counting its interval</td></tr>"
             "<tr><td>every 60 frames</td><td>A spawn script's wait ticks down one second</td></tr>"
             "<tr><td>every 8th frame</td><td>Same as a corridor: the score redraw and the damage that "
             "wears out an A-button weapon</td></tr>"
             "<tr><td>every room change, 81&ndash;98 frames</td><td>The loop is suspended and the room "
             "scrolled in, rebuilt and re-homed</td></tr>"
             "<tr><td>never</td><td>A new background row, a scroll step or a stream record: those belong to "
             "corridors</td></tr></tbody></table>")

    # ---------------------------------------------------------------- limits
    o.append('<div class="note"><strong>Measured and read.</strong> The order, the cycle numbers, the slot '
             "order and the new-row share are from running the real code on the NES model "
             "(<code>tools/tgl/cpu.py</code>): the durations from five corridor savestates for 900 frames each "
             "(<code>tools/profile-loop.py</code>), the start-time timeline from the calm one for 400 "
             "(<code>tools/trace-frame.py</code>), the labyrinth frame from its savestate for 300, and the "
             "room-exit suspension from walking out of three exits (<code>$30</code> bit 7 cleared; "
             "the ship's life held at its maximum so a run does not end); the "
             "routines' roles are from reading them. The NES model is not cycle-accurate "
             "(instruction timing is the table's, no DMA stalls, no IRQ, DMC or APU), so cycle "
             "numbers are indicative, and a stage with more enemies, a boss or heavier effects will take "
             "longer than the five states measured here. A one-off 6.5-frame stall (192,000 cycles in a "
             "single iteration, in a handler that was drawing a tile rectangle) appeared in an earlier run of "
             "<code>more3</code> with a different life setting and did not come back; the routine "
             "that can do it is <code>$D7C3</code>, which makes any code that queues PPU data into a full "
             "queue spin until the NMI has drained it (a lead, not reproduced). "
             "<strong>Not established:</strong> the real hardware's frame budget; the "
             "sprite allocator's use of <code>$81</code>/<code>$82</code> in the hiding loop; what every "
             "one of the 127 handlers does each frame (only the shared steps); the west exit's "
             "suspension (only east, north and south were timed); shops and message screens, which are "
             "special rooms with their own handlers; and the other uses of <code>$FF8B</code> with "
             "Y &gt; 1.</div>")
    return "".join(o)


def _ram_page(rm):
    """The RAM map: hand-authored names (annotations/ram.json) beside a generated
    cross-reference of every access in the traced code (tools/tgl/ram.py)."""
    from tgl import ram as ramx
    d = _ram_data()
    x = ramx.build(rm)

    def num(sv):
        return int(sv.lstrip("$"), 16)

    named = set()
    for e in d["entries"]:
        named.update(range(num(e["addr"]), num(e.get("end", e["addr"])) + 1))

    def acc(a, b):
        hit = [(k, x[k]) for k in range(a, b + 1) if k in x]
        if not hit:
            return "&mdash;"
        r = sum(v["r"] for _, v in hit)
        w = sum(v["w"] for _, v in hit)
        m = sum(v["m"] for _, v in hit)
        banks = sorted({bk for _, v in hit for bk in v["banks"]})
        return (f'<span class="mono">{r}r {w}w {m}m</span><br><span class="meta">bank'
                f'{"s" if len(banks) > 1 else ""} {", ".join(map(str, banks))}</span>')

    def stat(st):
        return f'<span class="conf {"lead" if st == "lead" else ""}">{_h(st)}</span>'

    p = ["<h1>RAM map</h1>",
         '<p class="sub">The console has 2 KB of RAM and the game uses nearly all of it. Two '
         "things are on this page and they are kept apart: <strong>a cross-reference</strong> "
         "generated from every instruction in the traced code, and <strong>names</strong> written "
         "by hand, each with where the meaning was read. A byte with a cross-reference and no "
         "name is a to-do, not a mystery solved.</p>"]
    touched = len(x)
    cov = sum(1 for k in x if k in named)
    reads = sum(v["r"] for v in x.values())
    writes = sum(v["w"] for v in x.values())
    mods = sum(v["m"] for v in x.values())
    p.append(_stats([("addresses touched", f"{touched} of 2,048"),
                     ("accesses seen", f"{reads + writes + mods:,}"),
                     ("named entries", str(len(d["entries"]))),
                     ("touched bytes named", f"{cov} ({cov * 100 // touched}%)")]))
    p.append('<div class="note warn"><strong>How to read the counts.</strong> "5r 2w 1m" is five '
             "reads, two writes and one read-modify-write (INC, DEC, shifts) in the traced code. "
             "An indexed access (<code>LDA $0500,X</code>) is counted on the array's base only, "
             "so the object slots show on the field's first byte. Code the trace has not reached "
             "is not counted: <strong>no accesses is not evidence a byte is unused</strong>. "
             "Status: <em>confirmed</em> = read from the code that uses it; <em>checked</em> = "
             "also matched to a savestate or a run of the code; <em>lead</em> = a reading of "
             "some uses, not settled.</div>")

    p.append("<h2>The map</h2>")
    rows = []
    for rg in d["ranges"]:
        a, b = num(rg["from"]), num(rg["to"])
        t = sum(1 for k in x if a <= k <= b)
        nmd = sum(1 for k in x if a <= k <= b and k in named)
        rows.append(f"<tr><td><code>{rg['from']}-{rg['to']}</code></td><td><strong>"
                    f"{_h(rg['name'])}</strong></td><td>{_h(rg['what'])}</td>"
                    f'<td class="mono">{t} touched, {nmd} named</td></tr>')
    p.append("<table><thead><tr><th>Range</th><th>What</th><th>Notes</th><th>Coverage</th>"
             f"</tr></thead><tbody>{''.join(rows)}</tbody></table>")

    def table(title, anchor, lo, hi, intro=""):
        es = [e for e in d["entries"] if lo <= num(e["addr"]) <= hi]
        out = [f'<h2 id="{anchor}">{title}</h2>']
        if intro:
            out.append(f'<p class="sub">{intro}</p>')
        trs = []
        for e in es:
            a = num(e["addr"])
            b = num(e["end"]) if "end" in e else a
            rng = e["addr"] + (f"-{e['end']}" if "end" in e else "")
            trs.append(f"<tr><td><code>{rng}</code></td><td><code>{_h(e['name'])}</code></td>"
                       f"<td>{_h(e['what'])}</td><td>{stat(e['status'])}</td><td>{acc(a, b)}</td>"
                       f'<td class="meta">{_h(e["evidence"])}</td></tr>')
        out.append("<table><thead><tr><th>Address</th><th>Name</th><th>What it holds</th>"
                   "<th>Status</th><th>Accesses</th><th>Where it was read</th></tr></thead>"
                   f"<tbody>{''.join(trs)}</tbody></table>")
        return out

    p += table("Zero page", "zeropage", 0x00, 0xFF,
               "Fast scratch and the game's hottest state. The scratch bytes <code>$10-$19</code> "
               "are shared by everything and mean what the caller says.")
    for key, label in (("$30", "<code>$30</code> - game mode bits"),
                       ("$A0", "<code>$A0</code> - stage event bits")):
        rows = "".join(f'<tr><td>bit {b["bit"]}</td><td>{_h(b["what"])}</td><td>{stat(b["status"])}'
                       f'</td><td class="meta">{_h(b["evidence"])}</td></tr>'
                       for b in sorted(d["bits"][key], key=lambda b: -b["bit"]))
        p.append(f"<h3>{label}</h3><table><thead><tr><th>Bit</th><th>Meaning</th><th>Status</th>"
                 f"<th>Where it was read</th></tr></thead><tbody>{rows}</tbody></table>")
    p += table("Page 1: queue, stack and buffers", "page1", 0x100, 0x1FF,
               "The PPU write queue is staged from <code>$0100</code> upward and the stack "
               "grows down from <code>$01FF</code>; the password decoder, the score and the "
               "palette shadow live between them.")
    p += table("Page 2: OAM", "page2", 0x200, 0x2FF)
    p += table("Page 3: sound", "page3", 0x300, 0x3FF)
    p.append('<h3 id="soundfields">Sound channel fields</h3>')
    p.append('<p class="sub">Seven soft channels (0-6), 33 fields each, a structure of arrays: '
             "<strong>field f of channel c is at <code>$0319 + 7 f + c</code></strong>, so the "
             "state ends exactly at <code>$03FF</code>. The tick is bank 0 "
             "<code>$917C</code>; a song start copies nine header fields into fields 0-8.</p>")
    trs = []
    for f in d["sound_fields"]:
        base = 0x319 + 7 * f["f"]
        trs.append(f'<tr><td class="mono">{f["f"]}</td><td><code>${base:04X}</code></td>'
                   f"<td><code>{_h(f['name'])}</code></td><td>{_h(f['what'])}</td>"
                   f"<td>{stat(f['status'])}</td><td>{acc(base, base)}</td>"
                   f'<td class="meta">{_h(f["evidence"])}</td></tr>')
    p.append("<table><thead><tr><th>f</th><th>Channel 0</th><th>Name</th><th>What it holds</th>"
             "<th>Status</th><th>Accesses (base)</th><th>Where it was read</th></tr></thead>"
             f"<tbody>{''.join(trs)}</tbody></table>")
    p += table("Page 4: stage and progress state", "page4", 0x400, 0x4FF,
               "Entries here can overlap in time: the password screen's field "
               "(<code>$0411-$0430</code>) uses bytes the corridor overlay slots use in play.")

    p.append('<h2 id="objects">Pages 5-7: object slots</h2>')
    p.append('<p class="sub">24 slots; slots 0-4 are the player\'s side and <code>$EA8C</code> '
             "allocates 5-23. <strong>Field f of slot s is at <code>$0500 + $18 f + s</code></strong>. "
             "Handlers reuse the generic fields for their own purpose (a boss's "
             "<code>$0668</code> is a target y in one handler and an aim direction in "
             "another), which is why some descriptions say &ldquo;or&rdquo;.</p>")
    trs = []
    for f in d["object_fields"]:
        base = 0x500 + 0x18 * f["f"]
        trs.append(f'<tr><td class="mono">{f["f"]}</td><td><code>${base:04X}</code></td>'
                   f"<td><code>{_h(f['name'])}</code></td><td>{_h(f['what'])}</td>"
                   f"<td>{stat(f['status'])}</td><td>{acc(base, base)}</td>"
                   f'<td class="meta">{_h(f["evidence"])}</td></tr>')
    p.append("<table><thead><tr><th>f</th><th>Slot 0</th><th>Name</th><th>What it holds</th>"
             "<th>Status</th><th>Accesses (base)</th><th>Where it was read</th></tr></thead>"
             f"<tbody>{''.join(trs)}</tbody></table>")

    p.append('<h2 id="todo">The busiest unnamed bytes</h2>')
    p.append('<p class="sub">Touched by the traced code, in no entry above, most accesses first. '
             "These are what to read next.</p>")
    arts = {}
    for a in d.get("base_artifacts", []):
        for k in range(num(a["addr"]), num(a.get("end", a["addr"])) + 1):
            arts[k] = a
    un = sorted((k for k in x if k not in named and k not in arts and k < 0x500),
                key=lambda k: -(x[k]["r"] + x[k]["w"] + x[k]["m"]))[:40]
    trs = []
    for k in un:
        v = x[k]
        sites = ", ".join(f"{bk}:${pc:04X}" for bk, pc, _ in v["sites"][:3])
        trs.append(f'<tr><td><code>${k:04X}</code></td><td>{acc(k, k)}</td>'
                   f'<td class="meta">first sites (bank:addr) {sites}</td></tr>')
    p.append("<table><thead><tr><th>Address</th><th>Accesses</th><th>Where</th></tr></thead>"
             f"<tbody>{''.join(trs)}</tbody></table>")
    if arts:
        rows = "".join(f'<tr><td><code>${k:04X}</code></td><td>{acc(k, k)}</td><td>{a["reason"]}</td></tr>'
                       for k, a in sorted(arts.items()) if k in x)
        p.append('<h3>Counted but not bytes</h3><p class="sub">An indexed access names the base of an array, '
                 "and when the index starts at 1 the base is the byte <em>before</em> the data. These "
                 "addresses are touched only that way, so they are left out of the table above; each "
                 "line says what is really read.</p>"
                 "<table><thead><tr><th>Address</th><th>Accesses</th><th>What is really read</th></tr></thead>"
                 f"<tbody>{rows}</tbody></table>")
    p.append('<div class="note"><strong>Not covered.</strong> Pages 5-7 are all object-slot '
             "arrays, so they are described by field above rather than listed byte by byte. "
             "The sound engine's per-channel fields beyond <code>$0319</code>, most of the "
             "<code>$0400</code> page's tail and about half the zero page's scratch have no "
             "entry yet.</div>")
    return "".join(p)


def _cell_hit_section(rm) -> str:
    """What a shot does to the labyrinth's cells (bank 6 $8443-$85F0, bank 5 $8354-$83A4)."""
    b5, b6 = rm.prg_bank(5), rm.prg_bank(6)
    cls = [b5[0x3A5 + i] for i in range(14)]               # $83A5: buffer id -> class
    blocks = [b6[0x425 + i] for i in range(16)]            # $8425: class blocks movement
    reacts = [b6[0x513 + i] for i in range(16)]            # $8513: class a weapon reacts to
    rows = []
    what = {1: "the olive mound", 2: "the olive mound", 3: "the olive mound",
            4: "the red block", 5: "the blue sphere", 6: "a red block (the item room&rsquo;s "
            "block is id 6)", 7: "a red block (in no room)", 8: "the pyramid, the &ldquo;cover&rdquo; "
            "of a key door", 9: "the red-and-white wedge (every border wall)", 10: "the checkered "
            "floor", 11: "blank", 12: "the green wall", 13: "blank (in no room)", 0: "(nothing)"}
    effect = {8: "3 hits: class 8 &rarr; 7 &rarr; 6 &rarr; floor", 7: "2 hits: class 7 &rarr; 6 "
              "&rarr; floor", 6: "1 hit: floor, class 0", 5: "1 hit: becomes the blue sphere, "
              "class 1", 10: "4 hits: the warp panel, class 2", 9: "none: solid", 14: "none: solid"}
    for i in range(14):
        c = cls[i]
        e = effect.get(c, "") if reacts[c] else ""
        rows.append(f"<tr><td class=\"mono\">{i}</td><td>{what[i]}</td><td class=\"mono\">{c}</td>"
                    f"<td>{'blocks' if blocks[c] else 'free'}</td><td>{e or 'none'}</td></tr>")
    o = ['<h2 id="cells">Shooting the room</h2>',
         '<p class="sub">In the labyrinth some of a room&rsquo;s blocks give way to your shots: '
         "the olive mounds break, a red block turns into a blue sphere you can collect, and a "
         "key door&rsquo;s cover can be shot away to uncover its warp panel. All of it is bank 6 "
         "<code>$8523</code>, run by every weapon that moves through the room.</p>",
         "<h3>The cell map</h3><p>When a room is drawn, bank 5 <code>$8354</code> turns the "
         "room&rsquo;s 16 &times; 12 buffer into <strong>cell classes</strong>, one nibble a cell, "
         "in <code>$0400-$045F</code> (an even column in the high nibble). The class comes from "
         "the buffer value (<code>$838E</code>): a set-0 metatile id below <code>$20</code> goes "
         "through the table at <code>$83A5</code>, sets 1-4 are class 0, and sets 5-7 "
         "(<code>$A0</code> and up) class 9. Ids in the rooms: 1 to 6, 9 and 10 (and 8 "
         "wherever a key door is). Which classes stop the ship is the table at "
         "<code>$8425</code>; the ones a shot reacts to are the ones set in "
         "<code>$8513</code> (5-10 and 14).</p>",
         "<table><thead><tr><th>Id</th><th>Looks like (area 0)</th><th>Class</th><th>Ship</th>"
         "<th>When shot</th></tr></thead><tbody>" + "".join(rows) + "</tbody></table>",
         '<p><img src="cell-effects.png" width="1104" style="max-width:100%;height:auto" '
         'alt="Each shootable block and what it becomes"></p>',
         "<h3>How a shot reaches a cell</h3><ol>"
         "<li>Every frame, bank 6 <code>$84E7</code> (the gun's bullet, <code>$84E1</code>, and "
         "every weapon that moves through <code>$88C7</code> or <code>$84E1</code>) takes the "
         "<strong>centre of the object&rsquo;s hit box</strong> and looks up the cell class "
         "(<code>$8443</code>). In a corridor (<code>$30</code> bit 6) and below the playfield "
         "(y of <code>$C0</code> or more) the class is always 0.</li>"
         "<li>If <code>$8513</code> says the class matters, <code>$8523</code> runs. "
         "<strong>Whatever the class, the object loses 8 hit points</strong> (<code>$85E6</code>): a "
         "bullet (1 to 3) is gone on the first hit, a weapon that never wears out is not.</li>"
         "<li>The effect does not depend on which weapon or how hard: one hit is one hit. A "
         "<strong>solid block</strong> (classes 9 and 14) only costs the shot its hit points and "
         "plays sound <code>$21</code>. A <strong>mound</strong> steps down a class on each hit "
         "(sound <code>$20</code>) without changing its picture &mdash; ids 1, 2 and 3 look "
         "the same and only differ in how many hits they take &mdash; and the last hit draws the "
         "checkered floor (tiles <code>$1C-$1F</code>), sets class 0, plays <code>$23</code> and "
         "spawns a type-<code>$30</code> object, the blast that many enemies die into. The "
         "<strong>red block</strong> (id 4, class 5) turns at once into the blue sphere "
         "(tiles <code>$28-$2B</code>, class 1) with the same blast.</li>"
         "<li><strong>Shots do not always hit</strong>: only the hit box&rsquo;s centre is tested, so "
         "a shot that moves more than a cell (16 px) a frame can step over one. The "
         "<strong>Hyper Laser</strong> and the <strong>Grenade in flight</strong> never test "
         "cells (the grenade does when it bursts), and the Eraser has no object.</li></ol>",
         "<h3>The two things the ship does with a cell</h3><ul>"
         "<li><strong>Class 1, the sphere:</strong> stepping on it (bank 3 "
         "<code>$9015</code>) plays <code>$33</code>, adds <strong>20 chips</strong> "
         "(<code>$FCE7</code>) and <strong>2 life</strong> (<code>$FD67</code>) and turns it into "
         "the floor. So a red block is a small pick-up in a shell.</li>"
         "<li><strong>Class 2, the warp panel:</strong> stepping onto one (bank 3 "
         "<code>$8FBF</code>) leaves the room towards that side if the exit&rsquo;s key is 0 or "
         "held (<code>$8FF5</code>, bit k&minus;1 of <code>$04B0</code>), and does nothing "
         "otherwise.</li></ul>",
         "<h3>Do destroyed blocks come back?</h3><p><strong>Yes: nothing remembers them, and "
         "a room is built from the ROM every time it is entered.</strong> A broken block changes "
         "two things only, the class in <code>$0400</code> and the picture in nametable 0. The "
         "room-entry code (bank 7 <code>$EB18</code> &rarr; <code>$EBA5</code>, or "
         "<code>$EEE0</code>/<code>$EE1D</code> for a special screen) runs bank 5 "
         "<code>$8015</code> (the room's record), <code>$8003</code> (<code>$8155</code>: the "
         "16 &times; 12 buffer from the layout tables) and <code>$8006</code> (the cell map from "
         "that buffer, <code>$8354</code>), and none of them reads anything the shots wrote. "
         "The only flags the labyrinth keeps are the item rooms and minibosses "
         "(<code>$04A0-$04A8</code>), the cleared corridors (<code>$04A9-$04AB</code>) and the "
         "keys (<code>$04B0</code>).</p><ul>"
         "<li><strong>They come back</strong> every time the room is loaded: stepping through any "
         "exit, even straight back; coming back from a special screen, a shop or a corridor; and "
         "<strong>after a game over</strong>, since CONTINUE restarts the game "
         "(bank 0 <code>$829C</code> sets <code>$2F</code> = 2 and jumps to the game start, "
         "<code>$FF5D</code>), which loads rooms the usual way.</li>"
         "<li><strong>They stay broken</strong> for as long as you remain in the room: "
         "opening and closing the status screen (Select) leaves the cell map and nametable 0 "
         "exactly as they were, and Start&rsquo;s pause only waits.</li>"
         "<li><strong>Dying does not reload the room.</strong> The fatal hit (bank 7 "
         "<code>$D2C7</code>: only when the life meter <code>$49</code> is also 0) turns the "
         "ship into the death object and, when the object loop ends (bank 6 "
         "<code>$8239</code>) and <code>$2E</code>, <code>$48</code> and <code>$49</code> are all "
         "0, the game goes to bank 0 <code>$81DD</code>: GAME OVER, then &ldquo;CONTINUE  PUSH "
         "START&rdquo;. There is no respawn in the room.</li></ul>",
         "<h3>Key doors: blast through the cover</h3><p>The dialogue says it: &ldquo;To use the "
         "Warp panel, blast through the cover. You will also need the key for the "
         "panel.&rdquo; The cover is metatile 8 (class 10) in the exit&rsquo;s fixed cell. On "
         "entering a room <code>$ED44</code> sets the high nibble of each of "
         "<code>$58-$5B</code> to 3, and each hit takes 1 off it (sound <code>$20</code>); on "
         "the <strong>fourth hit</strong> the cover is replaced by the warp ring (tiles "
         "<code>$00-$03</code>, class 2) with the blast. The ring then needs the key as above. "
         "If an earlier door of the room (order N, W, E, S) needs a different key, the "
         "cover turns into the bracketed panel (tiles <code>$04-$07</code>) instead &mdash; "
         "also class 2; what that picture is for was not worked out. A weapon that hits every "
         "frame (the blades, the Bullet Shield) therefore opens a cover in four frames.</p>",
         '<div class="note"><strong>Run, not just read.</strong> On the labyrinth savestate '
         "(<code>$30</code> bit 6 clear) <code>$8523</code> was called for every class: "
         "5 &rarr; 1 and 6 &rarr; 0 with a blast, 7 &rarr; 6, 8 &rarr; 7, 9 and 14 unchanged, "
         "each costing the shot 8; a door (class 10, key byte <code>$3k</code>) took four hits "
         "and turned class 2, with the ring or the bracket tiles by the other doors&rsquo; keys. "
         "The savestate&rsquo;s own room has a column of three one-hit mounds above the "
         "ship: the gun clears the nearest one, MultiBullets, Fireball and Wave level 1 clear "
         "all three, Back Fire the two diagonals, Bullet Shield, Area Blaster and Repeller "
         "several around the ship, and Hyper Laser none; the sphere pick-up was run and gave "
         "+20 chips and +2 life. <strong>Run, continued:</strong> after the gun and "
         "MultiBullets cleared rocks, the ship was walked out of the north exit and back "
         "(the game ran <code>$EB18</code>, <code>$EBA5</code>, <code>$8155</code> and "
         "<code>$8354</code> each way): the room came back with all 15 of its rocks, the 13 "
         "left plus the two that were destroyed; running <code>$EEE0</code> on the savestate "
         "also restored one the owner had destroyed before saving it; the status screen "
         "was opened and closed with no change. The fatal hit was run through "
         "<code>$D2C5</code>: the ship became the death object and the game sat in bank 0, "
         "in the GAME OVER routine (the NES model then idles at the sprite-0 wait, so the "
         "text was not drawn). <strong>CONTINUE (run, the start-up code <code>$805B</code> with "
         "<code>$2F</code> = 2):</strong> in a normal game it puts you at the map position of "
         "your last progress record (<code>$7C</code>/<code>$7D</code>, (11, 12) if none) and keeps your "
         "score, items and the corridor seals; in a TGL game it restores the life you began the "
         "corridor with (<code>$78</code>) and clears the score. A password start clears the seals "
         "(they are not in the password). <strong>Not established:</strong> the return from a corridor "
         "was read, not run; the bracket picture&rsquo;s purpose, "
         "which tile block holds tiles <code>$00-$0F</code>, classes 3, 11-13 and 15, and the "
         "four bytes <code>$0777</code>, <code>$07B2</code>, <code>$07BD</code>, "
         "<code>$07E7</code> that <code>$82DD</code> sets to 8 with each door. Not played on "
         "hardware.</div>"]
    return "".join(o)


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
             "byte 2 AND <code>$7F</code>); an opened gate sets it when the ship touches the gap "
             "(<code>$A149-$A18F</code>, below). Once "
             "cleared the entrance becomes screen 5, which also sets "
             "out a reward item, <code>$EF40</code>[corridor]. The status-screen map marks an "
             "entrance while its corridor is uncleared (<code>$C07B</code>).</div>")
    p.append("<table><thead><tr><th>Corridor</th><th>Map (x, y)</th><th>Key to enter</th>"
             "<th>Seal hint</th><th>Reward once cleared</th></tr></thead><tbody>" + "".join(
                 f"<tr><td>{d['corridor']}</td><td>{pos(d)}</td><td>{d['key'] or 'none'}</td>"
                 f"<td class=\"desc\">{_h(msgs[10 + d['corridor']]) if 2 <= d['corridor'] <= 10 else ('fire at the gate (message 2)' if d['corridor'] == 1 else '')}</td>"
                 f"<td>{item(d['reward'])}</td></tr>" for d in ents) + "</tbody></table>")
    p.append('<h3 id="seals">How a seal is removed</h3>')
    p.append('<div class="note"><strong>Two locks, not one.</strong> Reaching a corridor entrance room needs the '
             "key door in front of it (the &ldquo;Warp panel&rdquo;, below). Inside, corridors "
             "<strong>1 to 10</strong> have a second lock, the <em>seal</em>: the two gate halves. Its state is "
             "<strong>one bit per corridor in <code>$04B1</code> (corridors 1-8) and <code>$04B2</code> "
             "(9, 10)</strong>: bit c&minus;1 set = seal removed. Corridors 11-20 have none (the gate removes itself "
             "at once, <code>$A1A6</code>). <strong>Where it is checked:</strong> the second gate half (slot 6, "
             "<code>$A19B</code>), 60 frames after the room loads, reads byte 2 of the room record, takes the "
             "corridor minus 1 as <code>$15</code>, and if the bit is clear runs one of ten routines from the "
             "inline table at <code>$A1C4</code>; a routine that finds its condition met branches to "
             "<code>$A245</code>, which ORs bit <code>$15</code> into the flag array. If the bit is already set "
             "the half sets the other half's open flag (<code>$0788</code>) and removes itself "
             "(<code>$A1AA</code>); the other half then slides the two sides apart (<code>$0638</code> counts "
             "up to <code>$1C</code>) and, once <code>$0638</code> reaches 16, a ship touching the gap "
             "(box <code>$74-$8C</code> &times; <code>$60-$78</code>) is pushed up and gets exit code "
             "<code>$A4</code> = 4, which starts the corridor. <strong>The flags are not in the password</strong> "
             "(it carries <code>$04A0-$04B0</code>) and the cleared bits in <code>$04A9</code> are a separate "
             "thing: a cleared corridor shows screen 5, an uncleared one the gate.</div>")
    seal_rows = [
        (1, "bit 0 of $04B1", "<code>$A21D</code>, box A (x 116-140, y 96-120): <strong>50 hits by the ship's "
         "shots</strong> (counter <code>$0680</code>; each hit turns the shot into a spark, type "
         "<code>$0A</code>, sound <code>$20</code>). The ship itself is ignored.", "50 hits: flag at frame 601 of continuous fire"),
        (2, "bit 1", "<code>$A25B</code>: <strong>the ship touches four zones</strong> (x 80-112 or 144-176, y 64-96 or "
         "128-160), one bit each in <code>$0680</code> until it is <code>$0F</code>; each touch spawns a spark "
         "(bank 1 <code>$8002</code>, sound <code>$23</code>).", "four zones: set; three: not. <strong>Also sets bit 0</strong> (note below)"),
        (3, "bit 2", "<code>$A1D8</code>: <strong>stay in the room for 20 seconds</strong> (<code>$A2F8</code> counts 60 frames "
         "into <code>$0680</code>; 20 or more).", "flag 1,329 frames after entry (60-frame delay + 1,200); not at 1,100"),
        (4, "bit 3", "<code>$A1DF</code> is a bare <code>RTS</code>: the gate can never remove it. "
         "<strong>The round creature does</strong>: the shop rooms (screens 2, 6, 7: <code>$A041</code>, "
         "<code>$A0A1</code>, <code>$9FCF</code>) call <code>$A2E7</code> on entry and, if it passes, set bit 3 "
         "(<code>$9FD8</code>), play sound <code>$3F</code> and show message 11.", "history 0,8,0,8,..: set in screens 2 and 7; broken history: not"),
        (5, "bit 4", "<code>$A256</code> = <code>$A21D</code> with box B (x 96-143, y 16-56, the corridor mouth above the gate): "
         "<strong>50 shot hits</strong> there.", "flag at frame 598 of fire from y = 100"),
        (6, "bit 5", "<code>$A1E0</code>: the first call stores the chip count <code>$4C</code> in <code>$0680</code>; "
         "<strong>any change of the low byte of the chips</strong> afterwards removes the seal (spending them with a "
         "weapon that costs chips, or finding some).", "one chip changed: set"),
        (7, "bit 6", "<code>$A217</code>: <code>$A2E7</code>, <strong>the last 7 room changes alternate</strong> between "
         "two opposite exits (exit codes N 0, W 2, E 6, S 8; each adjacent pair of the 10-entry history "
         "<code>$04F0</code> must sum to 8, six pairs).", "0,8,0,8,0,8,0: set; one pair broken: not"),
        (8, "bit 7", "<code>$A1F5</code>: <strong>weapon <code>$3C</code> = 0 (&ldquo;NO USE&rdquo;) and A newly pressed</strong> "
         "(<code>$F5</code>/<code>$F6</code> bit 7).", "NO USE + A: set; weapon 3 + A: not"),
        (9, "bit 0 of $04B2", "<code>$A21D</code>, box A: <strong>the ship itself overlaps the gate</strong> "
         "(hit slot <code>$6E</code> = 0; shots do not count).", "ship on the gate: set; shots at it: not"),
        (10, "bit 1 of $04B2", "<code>$A202</code>: <strong>hold B for 10 seconds</strong> (<code>$A2F8</code> as for 3; "
         "<code>$0680</code> is cleared whenever B is not held).", "hold B: flag 729 frames after entry (60 + 600); 500 frames: not"),
    ]
    p.append("<table><thead><tr><th>Corridor</th><th>Flag</th><th>What the code tests</th>"
             "<th>Run on the NES model</th></tr></thead><tbody>" + "".join(
                 f"<tr><td>{c}</td><td class=\"mono\">{f}</td><td class=\"desc\">{w}</td><td class=\"desc\">{t}</td></tr>"
                 for c, f, w, t in seal_rows) + "</tbody></table>")
    p.append('<div class="note"><strong>Corrections and a quirk.</strong> The table in the section above read these as '
             "&ldquo;its own piece of code, not read yet&rdquo;; they are the ten routines at <code>$A1C4</code>, "
             "and the hints, in the dialogue's own words, say the same things (messages 2 and 12-20). "
             "<code>$04B1</code> was first recorded as ten one-shot events; it is the seal flags. "
             "<strong>Corridor 2's &ldquo;touch everywhere&rdquo; also removes corridor 1's seal:</strong> in the "
             "pass that completes the fourth zone the spark spawned through bank 1 overwrites <code>$15</code> "
             "with 0, and the shared tail <code>$A245</code> sets bit <code>$15</code> = 0 before the next pass sets "
             "bit 1 (traced). For corridors 4, 6 and 7 the harness set the chip count and the move history "
             "directly; the other conditions were driven by the pad and the ship's position. "
             "Run from the labyrinth savestate through the real <code>$EE1D</code> room setup; not checked on "
             "hardware. A cleared corridor's reward may be taken again: not established.</div>")

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
    p.append(_cell_hit_section(rm))
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
    if _ram_data():
        pages["ram.html"] = _ram_page(rm)
    pages["rendering.html"] = _rendering_page(rm)
    pages["gameloop.html"] = _game_loop_page(rm)
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
                 else f'RAM map - {rm.meta["title"]}' if name == "ram.html"
                 else f'Rendering - {rm.meta["title"]}' if name == "rendering.html"
                 else f'Game loop - {rm.meta["title"]}' if name == "gameloop.html"
                 else f'Demo - {rm.meta["title"]}' if name == "demo.html"
                 else f'Ending - {rm.meta["title"]}' if name == "ending.html"
                 else f'Corridors - {rm.meta["title"]}' if name == "corridors.html"
                 else f'Corridor {int(name[9:11])} - {rm.meta["title"]}'
                 if name.startswith("corridor-")
                 else f'PRG bank {name[4:-5]} - {rm.meta["title"]}')
        (out / name).write_text(_doc(rm, title, name, body), encoding="utf-8")
        written.append(name)
    return written
