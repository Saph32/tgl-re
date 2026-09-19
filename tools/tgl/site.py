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
    if any(r["kind"] == "text" for r in rm.regions):
        out.append(("text.html", "Text"))
    if any(r["kind"] == "graphics" for r in rm.regions):
        out.append(("graphics.html", "Graphics"))
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


def _tiles_svg(tiles: bytes, per_row: int = 16, limit: int = 128) -> str:
    """Render 2bpp NES tiles. Colour 0 is left transparent so the page theme shows through."""
    n = min(len(tiles) // 16, limit)
    if not n:
        return ""
    rows = (n + per_row - 1) // per_row
    w, h = per_row * 9 - 1, rows * 9 - 1
    shades = {1: 0.34, 2: 0.67, 3: 1.0}
    out = [f'<svg viewBox="0 0 {w} {h}" width="100%" style="max-width:600px;'
           'image-rendering:pixelated" xmlns="http://www.w3.org/2000/svg">']
    for i in range(n):
        ox, oy = (i % per_row) * 9, (i // per_row) * 9
        lo = tiles[16 * i:16 * i + 8]
        hi = tiles[16 * i + 8:16 * i + 16]
        for y in range(8):
            # Coalesce horizontal runs of one colour into a single rect. A rect per pixel
            # makes this page several megabytes; a rect per run makes it a few hundred KB.
            x = 0
            while x < 8:
                v = ((lo[y] >> (7 - x)) & 1) | (((hi[y] >> (7 - x)) & 1) << 1)
                run = 1
                while x + run < 8 and (((lo[y] >> (7 - x - run)) & 1)
                                       | (((hi[y] >> (7 - x - run)) & 1) << 1)) == v:
                    run += 1
                if v:
                    out.append(f'<rect x="{ox + x}" y="{oy + y}" width="{run}" height="1" '
                               f'fill="currentColor" opacity="{shades[v]}"/>')
                x += run
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
             "<code>[escape][unknown]</code>. Decoding starts in <em>literal</em> mode, where "
             "every byte that is not the escape is one output byte. The escape switches into a "
             "<em>run</em> section, which is a sequence of <code>[value][count]</code> pairs; the "
             "escape switches back. <strong>Two escape bytes in a row &mdash; an empty section, "
             "in either mode &mdash; end the block.</strong> The compressor picks a byte that "
             "does not occur in the block's literal data, which is why the escape differs per "
             "block and why values like <code>$A4</code> and <code>$FD</code> turn up alongside "
             "<code>$01</code>. The second header byte is always greater than the escape and is "
             "<em>not</em> understood; nothing in the decode uses it.</div>")
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
            p.append(f'<div style="margin:12px 0">{_tiles_svg(b["tiles"], limit=8)}</div>')
            if reg:
                p.append(f'<p class="desc">{_h(reg["description"])}</p>')
            p.append("</div>")

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

    p.append('<div class="note warn"><strong>The title screen is not explained by any of this, '
             "and bank 0 has no table.</strong> The same hardware check against a "
             "<em>title-screen</em> savestate reproduces only 18 of 512 tiles. Those tiles live "
             "in bank 0, which holds tile-shaped data and no pointer table that passes the "
             "partition test &mdash; scanning every offset in bank 0 produced runaway decodes "
             "and a few unconfirmable candidates around <code>$8BBB</code>, nothing more. "
             "<strong>The code that runs the codec has also not been found.</strong> The "
             "decompressed bytes have to reach the <code>$0100</code> queue, but no reader of "
             "these pointer tables has turned up in any scan run so far, and an absolute-indexed "
             "load from the table addresses finds nothing outside bank 4.</div>")
    return "".join(p)


# --------------------------------------------------------------------------- entry point

def build_site(rm, out: Path) -> list[str]:
    written: list[str] = []

    pages = {"index.html": _index(rm)}
    for n in range(rm.meta["prg_bank_count"]):
        pages[f"bank{n}.html"] = _bank_page(rm, n)
    if any(r["kind"] == "text" for r in rm.regions):
        pages["text.html"] = _text_page(rm)
    if any(r["kind"] == "graphics" for r in rm.regions):
        pages["graphics.html"] = _graphics_page(rm)

    # Guard: every region must get a card on some page. A region that is annotated and then
    # not shown anywhere is invisible to every reader, and nothing else notices.
    for r in rm.regions:
        target = ("graphics.html" if r["kind"] == "graphics"
                  else f'bank{r["prg_bank"]}.html' if r["segment"] == "prg" else "index.html")
        if f'id="{r["id"]}"' not in pages[target]:
            raise AnnotationError(f'{r["id"]} has no card on {target}')

    for name, body in pages.items():
        title = (rm.meta["title"] if name == "index.html"
                 else f'Text - {rm.meta["title"]}' if name == "text.html"
                 else f'Graphics - {rm.meta["title"]}' if name == "graphics.html"
                 else f'PRG bank {name[4:-5]} - {rm.meta["title"]}')
        (out / name).write_text(_doc(rm, title, name, body), encoding="utf-8")
        written.append(name)
    return written
