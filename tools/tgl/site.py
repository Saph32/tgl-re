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
     lambda rs: [r for r in rs if r["id"] in ENEMY_REGIONS],
     "127 object types with hit points, attack and art; 47 spawn scripts; and the loader "
     "that decompresses enemy tiles as rooms are entered."),
    ("status.html", "Status screen",
     lambda rs: [r for r in rs if r["id"] in STATUS_REGIONS],
     "Select during play: the world map, seven keys, twelve weapons and what each one costs "
     "to fire."),
]

PASSWORD_REGIONS = ("bank3.data_8513", "bank0.text_8BA3", "bank0.text_8B80")
ENEMY_REGIONS = ("bank5.tbl_803C",
                 "bank5.tbl_82D9",
                 "bank5.data_A497",
                 "bank5.tbl_A4C7",
                 "bank5.data_A525",
                 "bank5.tbl_A68D",
                 "bank5.tbl_A6A3",
                 "bank5.data_A6CA",
                 "bank7.tbl_C174",
                 "bank7.tbl_C201",
                 "bank7.tbl_CFC4",
                 "bank7.tbl_D02C",
                 "bank7.tbl_D0AB",
                 "bank7.tbl_D12A",
                 "bank7.tbl_D1A9",
                 "bank7.tbl_D441")
STATUS_REGIONS = ("bank5.map_8A6E", "bank5.tbl_8690", "bank5.tbl_85DA", "bank5.tbl_87E4",
                  "bank2.gfx_8E0C", "bank2.gfx_928C", "bank2.gfx_92AC", "bank3.tbl_817A",
                  "bank7.tbl_EFD8", "bank7.tbl_FDCA", "bank7.tbl_FDD7")


def _topic_pages(rm):
    """(filename, nav label, blurb, region count) for each topic page that has regions."""
    out = []
    for fname, label, select, blurb in TOPICS:
        n = len(select(rm.regions))
        if n:
            out.append((fname, label, blurb, n))
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
                      f'<div class="n">{n:,} regions</div></a>')
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
    rows = msp.object_map(b6, b7)
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
        p.append(f'<tr><td><code>${r["type"]:02X}</code></td>'
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
GRID_ROWS = ("ABCDE FGHIJ", "KLMNO PQRST", "UVWXY Z0123", "  456 789")
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
                f'<div style="font-weight:600;font-size:16px">{c}</div>'
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
             "<strong>A is 0</strong>, T is 19, Z is 25, <code>0</code> is 26 and "
             "<code>9</code> is 35 &mdash; 36 values, which is why six bits is exactly "
             "enough. The layout below is read off the nametable of a savestate taken on "
             "the password screen, row by row.</div>")
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
    # Vectors are generated from random CHARACTERS, never from random payloads: a six-bit
    # field runs 0-63 and the grid has 36 characters, so most payloads are not typeable and
    # a payload-driven loop here would never terminate.
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
             'color:var(--fg);text-transform:uppercase" />'
             '<div id="out" style="margin-top:14px"></div>'
             '<p class="meta" id="selfcheck" style="margin-top:12px"></p></div>')
    p.append("<script>" + f"""
const AB={_json.dumps(pw.ALPHABET)}, TGL={_json.dumps(tgl)}, EXEMPT={pw.XOR_EXEMPT};
const VEC={_json.dumps(vectors)};
function idx(s){{const o=[];for(const c of s.toUpperCase()){{
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
  if(!ch){{out.innerHTML='<span class="meta">Only the 36 characters on the grid.</span>';return;}}
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

    p.append('<div class="note warn"><strong>Not established.</strong> What '
             "<code>$30 = 2</code> makes the game do. What the 24 decoded bytes mean "
             "&mdash; which are area, which are weapons, which are chips. Why byte index "
             "<code>$17</code> is exempt from the XOR. And whether a real in-game password "
             "round-trips: everything here is the ROM's arithmetic transcribed, checked "
             "against itself, never against a password a real save produced.</div>")
    return "".join(p)


KEY_COLOURS = ("#8a94a6", "#4fb0f2", "#ed64a6", "#38c172", "#ecc94b", "#f2704f", "#9d7cf8",
               "#38b2ac")


def _worldmap_svg(recs, cell=14):
    """Rows 0-23 of the world map as the status screen reveals them: one square per
    non-empty cell, coloured by the key that reveals it, area entrances numbered."""
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
             "covering two by two cells; hardware sprites mark only the area entrances and "
             "(blinking) you.</p>")
    p.append(f'<div class="card">{_worldmap_svg(recs)}<p class="meta">'
             + " ".join(f'<span style="color:{KEY_COLOURS[k]}">&#9632;</span> '
                        + ("no key" if k == 0 else f"key {k}") for k in range(8))
             + " &middot; numbered squares are area entrances</p></div>")
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
             "shown while the area's <code>$04A9</code> bit is clear, and area 21's only once "
             "areas 1-10 are all flagged &mdash; &ldquo;cleared&rdquo; is the obvious reading "
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
    for w in range(1, 12):
        c = [cost[3 * w + lv] for lv in (1, 2, 3)]
        rows.append(f"<tr><td>{w}</td><td>{_icons_svg([ic['items'][w - 1]], px=2)}</td>"
                    + "".join(f'<td class="mono">{x}</td>' for x in c)
                    + f'<td class="mono">{b7[0x3DCA + w]}</td></tr>')
    rows.append(f"<tr><td>12</td><td>{_icons_svg([ic['items'][11]], px=2)}</td>"
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


def _enemies_page(rm):
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

    p.append("<h2>Every type</h2>")
    p.append('<p class="sub">From <code>$D02C</code> (flags), <code>$D0AB</code> (HP), '
             "<code>$D12A</code> (attack), <code>$D441</code> (death) and <code>$CFC4</code> "
             "(art). The art is the tile block the type names, decoded with the codec &mdash; "
             "the tiles, not assembled into a sprite. &ldquo;In scripts&rdquo; counts the "
             "spawn scripts that create the type.</p>")
    rows = []
    for t in range(1, 128):
        v = enemy.per_type(b7, t)
        art = ""
        if v["gfx"] is not None and 0 < v["gfx"] < 0x80:
            bank, ptr, tiles = block_tiles(v["gfx"])
            art = (f'<span class="meta">block <code>${v["gfx"]:02X}</code> &rarr; bank {bank} '
                   f'<code>${ptr:04X}</code></span><br>'
                   + _tiles_svg(tiles, per_row=16, px=22))
        elif v["gfx"] is not None and v["gfx"] >= 0x80:
            art = '<span class="meta">per object (<code>$07B8,X</code>)</span>'
        rows.append(f'<tr><td><code>${t:02X}</code></td><td class="mono">{v["hp"]}</td>'
                    f'<td class="mono">{v["attack"]}</td>'
                    f'<td><code>${v["flags"]:02X}</code></td>'
                    f'<td><code>${v["death"]:02X}</code></td>'
                    f'<td class="mono">{spawned.get(t, "")}</td><td>{art}</td></tr>')
    p.append('<div style="overflow-x:auto"><table><thead><tr><th>Type</th><th>HP</th>'
             "<th>Attack</th><th>Flags</th><th>Death</th><th>In scripts</th><th>Art</th>"
             f"</tr></thead><tbody>{''.join(rows)}</tbody></table></div>")
    p.append('<div class="note warn"><strong>Not established.</strong> Which type is which '
             "enemy by name; what <code>$0620</code> (from <code>$D1A9</code>) is for; the "
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
                parts.append(f"formation <code>${e[1]:02X}</code> &times; {e[2]} / {e[3]}")
            elif e[0] == "spawn":
                parts.append(f"spawn <code>${e[1]:02X}</code>")
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
    for r in [x for x in rm.regions if x["id"] in ENEMY_REGIONS]:
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
    if any(r["id"] in ENEMY_REGIONS for r in rm.regions):
        pages["enemies.html"] = _enemies_page(rm)
    if any(r["id"] in STATUS_REGIONS for r in rm.regions):
        pages["status.html"] = _status_page(rm)

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
    for name in pages:
        if name != "index.html" and f'href="{name}"' not in pages["index.html"]:
            raise AnnotationError(f"{name} is not linked from index.html")

    for name, body in pages.items():
        title = (rm.meta["title"] if name == "index.html"
                 else f'Text - {rm.meta["title"]}' if name == "text.html"
                 else f'Graphics - {rm.meta["title"]}' if name == "graphics.html"
                 else f'Sound - {rm.meta["title"]}' if name == "sound.html"
                 else f'Password - {rm.meta["title"]}' if name == "password.html"
                 else f'Status screen - {rm.meta["title"]}' if name == "status.html"
                 else f'Enemies - {rm.meta["title"]}' if name == "enemies.html"
                 else f'PRG bank {name[4:-5]} - {rm.meta["title"]}')
        (out / name).write_text(_doc(rm, title, name, body), encoding="utf-8")
        written.append(name)
    return written
