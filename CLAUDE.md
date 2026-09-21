# Working notes for this project

Read `NES-RE-PLAYBOOK.md` first. It is the method; this file is only what is specific to
The Guardian Legend and to how this repository is wired.

## The one rule

A claim about the ROM must be checked against the ROM. Mark leads as leads, in the
annotation, not in conversation. State corrections as corrections — never quietly edit a
wrong finding away.

## How the repository is wired

- `annotations/rom.json` — hand-authored cartridge metadata: sizes, mapper, the per-bank
  record, the vectors, the open threads. Everything else is derived from it.
- `annotations/regions/*.json` — hand-authored, one region per claim, loaded in filename
  order. Each region declares the SHA-1 of its own bytes.
- `tools/tgl/model.py` — the loader and every check. Nothing else is allowed to decide
  what a byte's CPU address is.
- `tools/tgl/disasm.py` — the 6502 opcode table, the instruction decoder and a
  recursive-descent tracer. Carried over unchanged from the Yoshi project; the opcode
  table is cartridge-independent.
- `tools/tgl/site.py` — `docs/` generation. The presentation half is the Yoshi project's;
  the page set is not.
- `tools/build.py` — validate, print coverage, write `docs/`. `--check` writes nothing,
  `--gaps` lists the largest unclaimed stretches.
- `tools/whereis.py` — address ↔ file offset ↔ bank, the region or gap it lands in, and a
  mini-disassembly. `--bytes "4C DE FE"` says which bank really holds a byte sequence.
- `tools/trace-code.py` — the seeded trace, carrying the live bank. `--runs`, `--gaps`,
  `--leads`, `--calls`, `--inline`, `--illegal`, `--risky`, `--seeds`, and
  `--assumptions`, which prints what the answer rests on. **Read that last one before
  citing a coverage figure from it.**
- `tools/gen-code-regions.py` — turns the trace into `annotations/regions/20-traced.json`.
  **That file is generated; a hand edit to it is lost on the next run.** To say more about
  a stretch than the trace can, claim it in a hand-authored file — the generator subtracts
  everything already claimed before it emits, so a hand-written region always wins.
- `tools/reassemble.py` — **the gate.** Writes `disasm/`, assembles it back against one
  shared label table and refuses unless the image is the ROM byte for byte.
  `tools/tgl/asm.py` is the assembler behind it; read its header before citing the check.
- `tools/savestate.py` — reads an FCEUX `.fcs`, lists its chunks, diffs the live CHR RAM
  against the ROM (`--chr`) and rebuilds the font through the expander's own arithmetic to
  check it against hardware (`--font`). **The savestate is not in this repo** — it is the
  user's file. Point the tool at wherever it lives.
- `tools/decompress-gfx.py` — decodes the tile blocks and checks them against a
  savestate's live CHR (`--verify`). `tools/tgl/gfx.py` holds the codec, the pointer tables
  and, in its header, the three checks behind it. **Read that header before citing any
  figure from this tool.** `tools/gen-gfx-regions.py` turns the block chain into
  `annotations/regions/45-gfx-blocks.json`; that file is generated, like `20-traced.json`.
- `tools/parse-sound.py` — walks every music and sound-effect track into
  `annotations/regions/50-sound.json`. `--dump` lists the songs, `--song N` decodes one
  event by event. Generated; do not hand-edit. `tools/tgl/sound.py` holds the format, the
  command table and what is NOT established.
- `tools/password.py` — decodes a password the way bank 3 does, and explains the TGL back
  door. `--selftest` round-trips its own encoder against its own decoder, which is
  self-consistency and **not** hardware; the header says so.
- `tools/parse-screen.py` — walks bank 4's per-area screen data into
  `annotations/regions/60-screen.json`. `--block N` prints one entry block record by
  record. Generated; do not hand-edit. `tools/tgl/screen.py` holds the format.
- `tools/parse-metasprites.py` — walks the metasprite table into
  `annotations/regions/70-metasprites.json`. `--id N` draws one as a grid, `--dump` lists
  all 140 entries. Generated; `tools/tgl/metasprite.py` holds the format.
- `tools/parse-structs.py` — walks bank 5's structure records into
  `annotations/regions/66-structs.json`. Generated.
- `tools/parse-text.py` — parses the dialogue script and the screen scripts into
  `annotations/regions/30-text.json`. `--dump` prints the decoded text. Generated; do not
  hand-edit.
- `annotations/dispatch.json` — hand-resolved control flow the trace cannot follow: the
  inline-argument call registry, the rejects from the scan that found it, and an
  `unresolved` list. **An empty `unresolved` list would be a weaker statement than it
  sounds** — it says every table the file knows about is resolved, not that every table is
  in the file.
- `disasm/` and `docs/` — generated. Never hand-edit; the tools overwrite them.

What the build enforces, so you do not have to remember it: every region's SHA-1, no
overlaps, no region straddling a bank boundary, `codec` mandatory on graphics regions, a
CPU address that matches what the bank maps, an id ending in four hex digits matching that
address, the three vectors matching the bytes at `$FFFA`, and every region getting a card on
some page of the site. Coverage percentages are computed, never typed.

**What the reassembly check proves, and what it does not.** All 131,088 bytes rebuild from
the region map and all 1,792 control-flow targets resolve to instruction starts inside code
regions. Do not read more into that than it says — each of these was confirmed by breaking
the map on purpose:

| Corruption | Caught by |
| --- | --- |
| a code region starting one byte early | the instruction-start check, *not* byte-exactness |
| a code region ending mid-instruction | the instruction-boundary check |
| a code region relabelled as data | an undefined label in the listing |
| two equal-sized code regions swapped | the SHA-1 |
| …with their SHA-1s forged to match too | **only the id-vs-address check** — it rebuilds exactly |

That last row is the one to remember: **byte-exactness alone cannot catch a wrong
instruction-start address, and it cannot catch two regions trading places.** Disassembling
and reassembling is faithful at any alignment. The byte comparison is the floor; the
structural checks do the work.

The opcode table is **not** independently verified: `asm.py` is `disasm.py`'s table
inverted, so an error there cancels between the two directions and the round trip passes.
The inversion is asserted to be a bijection over the 151 documented opcodes, which catches
a table typo that made two mnemonic/mode pairs collide, and nothing more.

One check exists on purpose and will look strange: the loader asserts iNES byte 5 is
**zero**. That is the CHR RAM fact, and everything about how graphics have to be found here
depends on it, so it is asserted rather than assumed.

## Cartridge facts already established

Do not re-derive these; do check anything that depends on them.

- **Mapper 2, UxROM.** Eight PRG banks of 16 KB. `$8000-$BFFF` takes the selected bank;
  `$C000-$FFFF` is wired to the last bank, bank 7, and cannot be switched out. There is no
  PRG mode to establish, unlike the MMC1 cartridges this toolchain came from — the window
  follows from the bank number and `model.py` derives it rather than reading it from the
  annotation.
- **An address in `$8000-$BFFF` exists in all seven switchable banks** and is not an answer
  on its own. Always carry the bank. Use `whereis.py --bytes` on any outside report.
- **CHR is RAM.** iNES byte 5 is `$00` and the file size confirms it: `16 + 131072 =
  131088` with nothing over. No byte of this file is a tile until code uploads it. Per the
  playbook, finding the uploaders *is* the graphics problem; the cheap first question about
  an unclaimed block is not "what points at it" but "what routines write to `$2007`?"
- **Mirroring is vertical and fixed.** iNES byte 6 bit 0 is 1, and mapper 2 has no
  mirroring register, so unlike on MMC1 this cannot change during play.
- **Bank switching is `LDA $FFF2,Y` / `STA $FFF2,Y`** — the table at `$FFF2-$FFF9` holds
  `$80`-`$87`, and the routine writes back the byte it just read so the value on the bus
  and the value in the ROM agree. Recognising the idiom instantly is worth a lot.
  - `$D705` — switch to the bank in **A** (not Y: it opens `STA $04` and only then copies
    `$04` into Y to index the table). Callers reach it as `TYA / JSR $D705` or `PLA /
    JSR $D705`, which is what makes the `PHA` … `PLA` save-and-restore idiom work.
  - `$D714`, `$D721`, `$D72E`, `$D73B`, `$D748`, `$D755`, `$D762` — switch to bank 0, 1, 2,
    3, 4, 5, 6 respectively, no register needed.
  - `$D76F` — the **far-call trampoline**, called as `JSR $D76F` followed by three inline
    bytes: bank, target low, target high. It pops the return address, advances it past the
    three bytes and pushes it back, pushes the caller's bank, then falls into `$D790`, which
    reads the three inline bytes through `($12)`, pushes the target as a fake return
    address, switches to the bank and `RTS`es into it. When the target returns, `$D788`
    picks up again and `$D79C` switches back to the caller's bank. A far call is the one
    reference in this ROM that no grep for an operand will ever surface. **When a routine is
    understood, follow its far calls before writing it up.**
  - `$04` is the live-bank shadow byte. Every one of the eight routines writes it.
- **Every bank opens with a table of `JMP` instructions at its window base.** Per the
  playbook that table is the complete inventory of cross-bank entries, so resolving every
  one of them and checking the count closes is the next structural step. Counts, from
  scanning for consecutive `$4C`: banks 0-6 give 9, 5, 12, 10, 1, 20, 7, and bank 7 gives
  124 from `$C000`. **The bank 7 figure is a raw count of consecutive `$4C` bytes and is not
  established as the table's length** — a run of `JMP`s can end by running into code that
  happens to start with one. Bank 4's single entry is the odd one out and is unexplained.
- **Two more calling conventions put data in the instruction stream**, and both were found
  by enumerating a class rather than chasing sites. A scan for `PLA / STA $zp / PLA /
  STA $zp+1` — a routine taking its own return address as a pointer — finds eleven matches,
  six real and five byte-scan false positives, all listed in `annotations/dispatch.json`
  with the reason for each rejection:
  - `$D576` and `$D53F` queue **one** inline PPU-string item per call — not a run.
    `$D57C-$D584` looks like a loop over items and is a loop waiting for room: `$D7C3`
    never touches `$16`/`$17`, so re-entering re-tests the same bytes. Block length is
    `(first byte & $7F) + 3` below `$C0` and 9 at or above; `$D53F` is two bytes shorter
    because it takes the PPU address from `$18`/`$19` instead of the stream. All 32 blocks
    resume on a legal opcode. **This was published as an unresolved variable-length stream
    first; the correction is in `annotations/dispatch.json`, not edited away.**
  - `$D5CC` takes exactly four inline bytes — the one member with a constant length, read
    off the `ADC #$04` at `$D5EC` and confirmed by the four `LDA ($16),Y` before it.
  - `$D6B0` (and per-bank copies at `$9F12` in bank 5 and `$85F6` in bank 6) is an inline
    **jump table**: entry k is the two little-endian bytes at `ret+2k` holding target−1, and
    the caller picks it with `Y = 2k`. Two bytes earlier, `$D6AE` / `$9F10` / `$85F4` is
    `ASL A / TAY` — the same routine entered with the index in A instead.
- **Every traced call into the switchable window happens under exactly one live bank.**
  2,810 traced control-transfer sites and not one resolves to two banks. A site in the fixed
  bank is walked once per live bank that reaches it, so a `JSR $8000` there could legitimately
  land in several; none does. `reassemble.py` prints the figure on every run, and if it ever
  stops being zero that is a finding, not a bug.
- **A routine that cannot return is computed, not assumed.** 26 reached routines have no
  reachable `RTS`, and the walk stops at the 5 call sites that enter one. Without it the
  trace decoded the bytes after a far call to bank 0 `$8015` — an endless display loop — as
  instructions, when a pointer built at `$8AC8`/`$8ACC` names them as data.
- **There are three text formats, and they do not share a character map.**
  - **Inline PPU strings** after `JSR $D576`/`$D53F` — 32 of them, in the instruction
    stream, handled by the tracer.
  - **The dialogue script**, bank 5 `$9639-$9F0F` — 20 messages behind a 21-entry pointer
    table at `$960F`, read by `LDA $960F,Y` / `LDA $9610,Y` at `$8476` with the index from
    `$0620,X`. `$00` ends a message, `$01` a screenful, `$0D` a line. The messages
    **partition** the block end to end, which is the check that carries it.
  - **Screen scripts** for the renderer at bank 0 `$8495` — `[col][count][chars]`, `$FF`
    ends a row and adds `$20` to the PPU address, `$FE` ends the script, and **bit 7 of the
    count repeats one character** (a run-length fill). Three blocks confirmed, each with
    its `LDA #lo / STA $16` call site read by hand.
  - **The three disagree about punctuation, and the font explains why.** See the font entry
    below: the tile index a glyph lands on is chosen per screen by an upload record table,
    so `$5C` really is a comma on the title screen and `$3C` really is one in the dialogue.
- **`BNE x / BEQ y` back to back is unconditional**, so the second branch's fall-through is
  unreachable. There are 38 such pairs, and at bank 5 `$82D7` the bytes being jumped over
  are a table that `$82B9 LDA $82D9,Y` reads.
- **The PPU write taxonomy is CLOSED, and it is one queue.** 31 `STA $2007` sites and 18
  `STA $2006` sites in the whole file, all in bank 7, all traced — and a byte scan of the
  whole ROM finds exactly the same ones, so nothing is hiding in untraced code. Everything
  goes through a queue staged at `$0100`: `[count][ppu_hi][ppu_lo][data]`, with the count
  byte's top two bits selecting the type — under `$80` a run with increment 1, `$80-$BF`
  the same with increment 32, `$C0+` an attribute read-modify-write. 24 producers.
- **The font: 45 glyphs, 1bpp, SEVEN bytes each, bank 2 `$8BF8-$8D32`.** 315 = 45 × 7, and
  the seven is why every tile-shaped test missed it — playbook §7's exact case. The expander
  is bank 2 `$806C`: seven source bytes into rows 0–6 of the low bit plane, row 7 and the
  whole high plane zeroed, source += 7, destination += `$10`. Six records at `$80EC` drive
  it, `[count][dest][src]`, `$FF`-terminated. Glyph order is `0-9 ▼ ; , - . ? @ A-Z ▲ ▦`.
  - **This is what fixes the encoding, and it is per screen.** The records put 10 glyphs at
    `$1300` (digits at ASCII `$30`) and 27 at `$1400` (`@` then A-Z at `$40`) — so letters
    and digits *are* ASCII, stated by the ROM rather than read out of English. The four
    single-glyph records patch `$5B`, `$5C`, `$5D`, `$5E` individually, which is exactly why
    screens disagree there.
  - **Confirmed against hardware**: expanding those 41 glyphs from the ROM and diffing them
    against the live CHR RAM of a title-screen savestate gives 41 of 41 exact.
  - **Two corrections.** `$5D` is a **hyphen**, not the `!` this project read from context;
    `$5E` is a grid block, not a double quote. Both hold for the title screen's record set
    only — the dialogue loads a different one, proved by `$3C`.
- **One other confirmed CHR write.** Bank 7 `$E3CC` queues 5 bytes at PPU `$1FF9` — inside
  tile `$FF` of pattern table 1 — from the mask tables at `$E3F9` and `$E401`: a status
  meter redrawing part of a character tile.
- **The tile codec is FOUND. A block toggles between two modes and picks its own toggle
  byte.** A block is `[escape][unknown]`, decoding starts in literal mode, the escape
  switches into a run section of `[value][count]` pairs, the escape switches back, and
  **two escape bytes in a row — an empty section, in either mode — end the block.** That one
  rule covers both shapes in the data: `literals ESC ESC` and `ESC pairs… ESC ESC`. The
  compressor picks a byte absent from the block's literal data, so the escape is per block
  (`$01` and `$02` are common; `$A4`, `$ED` and `$FD` also occur). Compression is 1.08x —
  a run packer, not an LZ. 101 blocks in banks 1, 2 and 3: 36,961 ROM bytes → 39,753 bytes
  = 2,485 tiles. Pointer tables: bank 1 `$8010` (22), bank 2 `$8024` + `$8042` (13 + 21),
  bank 3 `$8022` + `$8040` (6 + 47); `$FFFF` and `$0000` words separate the groups.
  - **Three independent checks, and none of them was tuned.** *The partition:* a block's
    decoded length ends exactly on the next pointer — 21/22 in bank 1, 29/29 in bank 2,
    50/50 in bank 3. The terminator rule came from four blocks and then predicted the other
    ninety-seven. *The escape is forced:* brute-forcing all 256 values against that test
    leaves exactly ONE survivor for 14 of bank 1's blocks, and it is header byte 1 every
    time. *Hardware:* decoding out of the ROM reproduces **398 of the 512 tiles** of an
    in-game savestate's live CHR, byte for byte, 16 more being blank.
  - **The second header byte is NOT understood.** Always greater than the escape, often by
    one; nothing in the decode uses it.
  - **CORRECTION to the earlier lead.** This file said 1,046 of 8,192 live CHR bytes were in
    the ROM verbatim with sources in bank 0 `$8CDA-$9195`. The shape was right and the size
    was badly wrong: a verbatim byte search can only ever find a block's *literal* sections,
    never a run section. The bank 0 attribution is also unreliable — `savestate.py --chr`
    reports the first occurrence of a window anywhere in the file, not the producing block.
- **Bank 0's tiles are still not found, and neither is the decompressor.** The same hardware
  check against a *title-screen* savestate reproduces only 18 of 512 tiles, so the title
  tiles are elsewhere — bank 0 holds tile-shaped data and **no pointer table in it passes the
  partition test**; a scan of every offset in bank 0 gave runaway decodes and a few
  unconfirmable candidates around `$8BBB`. The code that runs the codec has not been found
  either: the output must reach the `$0100` queue, but no reader of these tables has turned
  up, and an absolute-indexed load from the table addresses finds nothing outside bank 4.
- **Bank 0 is the sound bank, and seven soft channels compete for four hardware ones.**
  Entry slots `$8000` -> `$97A0` (init), `$8006` -> `$97CC` (play sound A) and `$8009` ->
  `$917C` (the per-frame tick the NMI calls). Per-channel state is a structure of arrays:
  field *f* of channel *c* is at `$0319 + 7f + c`. `$97E4` copies nine fields out of a song
  header; fields 7/8 are the stream pointer, field 6 is the hardware channel wanted, and
  `$0306` is the busy mask over the four, driven by the mask tables at `$9771`/`$9775`.
  Channels 5→0 run per frame unless channel 6 is active, which then runs *instead*. Output
  is a 16-byte APU shadow at `$0308-$0317`, flushed by `LDA $0308,X / STA $4000,X`; `$FF`
  in a shadow byte means "skip this register".
  - **Stream format.** `$00-$7F` note (optional duration byte); `$80-$94` one of 21
    commands via the table at `$932C` (handler address minus one, registered in
    `dispatch.json`); `$E0-$FF` repeat the previous note with that duration, `$E0` taking a
    literal byte and `$E1-$FF` indexing the duration table. **A track ends at `$82`/`$84`
    or at `$80`, an unconditional jump — 83 of the 132 tracks end on a loop jump and never
    reach an `$82` at all.**
  - **Tables.** Songs `$9B04` (72), commands `$932C` (21), periods `$985A-$9931` (108,
    base `$9840`), durations `$9942-$995F` (30), pitch envelopes `$9961`→`$9969-$99AC`,
    volume envelopes `$99AD`→`$99C5-`. Three of those are bounded by the same argument as
    `$E6F3`: the table ends exactly where its own first target begins.
  - **Three checks.** All 132 tracks reach an unconditional terminator (a wrong operand
    length desynchronises and runs into the next track). The command holes are **counted**:
    `$95-$AF` would index past the table, `$B0-$DF` would advance the pointer by zero, and
    **zero bytes of either occur**. The duration census gives exactly `$E1-$FE` = indices
    1-30, and the table has exactly 30 entries.
- **The DMC is a timer, not a voice — there is no sampled audio in this ROM.** Bank 6
  `$802A` writes `$4010 = $81`, `$4011 = $00`, `$4012 = $FF`, `$4013 = $01`: a 17-byte
  sample at `$FFC0` whose bytes are **all zero**. The IRQ is the point. `$DCF3`
  acknowledges with `$4015 = $0F`, polls sprite 0 via `BIT $2002` against the frame counter
  `$2B`, and restarts the timer from `$05`, walking that rate index between `$81` and `$89`
  to converge on the split. That is what `$05` is for.
- **Bank 4 is per-area screen data, and it is now 99.6% claimed.** 25 pointers at `$8013`,
  indexed by the area number in `$51`, reached from `$EF9B`. **CORRECTION:** this file used
  to say `$51` is "bounded by `CPY #$15` at `$F2E2`". It is not — that instruction is
  `CPY #$15 / BNE`, an *equality test for area 21*, the same test bank 4's command 5 handler
  makes. It bounds nothing. The table's count rests on the structural argument alone: entry
  2 points at `$8045`, the byte immediately after the table. Its entry point returns a pointer instead of running code, which is why a
  control-flow trace found 19 bytes of it.
  - **A record is `[command][operands][next trigger lo][next trigger hi]`**, run by `$E5BD`
    and dispatched through `$E6F3`. **The trigger is a scroll position** — `$E6CE` compares
    it against the running counter `$B0`/`$B1` and fires the record only on a match. So a
    block is an event list keyed to how far the screen has scrolled.
  - **It is a graph, not a list.** Command 3 jumps unconditionally and command 9 does the
    same conditionally on `$70`, so a linear read stops at the first command 3 with live
    bytes ahead. Following the jumps finds **52 block starts** where the table names 25.
  - **Command 5 takes one operand in area 21 and none elsewhere** — `$E79F` compares `$51`
    with `#$15` and the miss path does a bare `DEY`. Runtime state deciding a byte count;
    parseable only because each block's area is known. Command 8 occurs **zero** times.
  - **Three checks.** The walk meets no byte that is not one of the ten commands. **Triggers
    never decrease** within a block — 476 transitions across 25 blocks, and one wrong
    operand length would break it. And the terminator falls out of the data: triggers split
    into 209 values at or below `$0791` and exactly four above (`$1100`, `$270F`, `$3700`,
    `$3800`), a gap of 2,415, each sitting where an unguarded walk runs off.
  - **The pool is a lead.** 7,639 bytes the stream points at rather than reads, with 212
    pointers in from commands 1, 2, 4, 6 and 7. Extent claimed, contents not.
- **The password system, and the TGL back door.** Bank 3 runs the password screen (the
  savestate's latch reads `$83`). The field is 32 characters at `$0411-$0430`, each stored
  as its **grid index** — `$88F2` is `LDA $16 / STA $0411,X`, and the grid is A-Z then 0-9,
  so A is 0, T is 19, `0` is 26. The savestate's nametable confirms that layout row by row.
  - **Decode** (`$8516`): a seed from the last two characters, `($0430 << 2) | ($042F >> 4)
    + $1D`; then four characters at a time masked `AND #$3F` and shifted into three bytes;
    each output byte XORed with the seed, which decrements per byte. Eight groups give 24
    bytes at `$011E-$0135` — the PPU queue's staging area, borrowed. Index `$17` is exempt
    from the XOR and **why is not established**.
  - **Checksum** (`$859B`): `$011E-$0133` plus `$0135` compared with `$0134`. Mismatch →
    `$8578 SEC / RTS`, rejected. Match → copied to `$0438`, carry clear.
  - **The back door** (`$857A`, *before* the checksum): the first three characters against
    the three bytes at bank 3 `$8513` = `13 06 0B` = **T, G, L**, then every character from
    index 3 to `$1F` must be zero. On a match it sets `$2F = 0`, `$30 = 2` and returns carry
    clear, **skipping the checksum**. Bank 0 `$8BA3` is a screen script reading
    **"PASSWORD TGL"**, right after "PRODUCED BY / IREM / CORPORATION".
  - **A blank and the letter A are the same byte** — A's grid index is 0 and an untouched
    field is all `$00` in the savestate — so "TGL" plus any number of A's is byte-identical
    to "TGL" plus blanks. Stated from the code; not tried on hardware.
  - **Not every payload is typeable, and that broke a check.** A six-bit field runs 0-63
    and the grid has 36 characters, so most 24-byte payloads have no password.
    `password.py --selftest` originally round-tripped from the *payload* side, skipped all
    500 cases on its "?" guard, and reported "0 disagreements" — true and meaningless. It
    now runs from the character side: 2000 random passwords decode and re-encode to
    themselves. **A lead:** the seed comes from the last two characters, so the encoder gets
    to choose it, and searching seeds until every field lands under 36 would explain why the
    seed exists at all.
  - `docs/password.html` carries the grid, a bit-packing diagram and a decoder transcribed
    into the page, which self-checks against vectors from `tgl/password.py` on load.
- **Bank 6 is object behaviour, behind a SPLIT dispatch table.** `$8210` reads the object
  type from `$0500,X`, `$8213` filters type 0, `$8215` masks `AND #$7F` for 128 slots, and
  `$821E` does `LDA $815D,Y / PHA / LDA $80DE,Y / PHA / RTS` — target minus one.
  - **Low bytes at `$80DE`, high bytes at `$815D`, 128 each.** Not the interleaved shape
    every other table here uses, which is why a 16-bit pointer scan read it as nonsense
    ($9B9A, $9C9C — those were pairs of adjacent *high* bytes).
  - **The halves overlap by one byte on purpose.** `$80DE + 127 = $815D`, both `low[127]`
    and `high[0]`; `high[0]` is never read because type 0 is filtered two instructions
    earlier.
  - **Checks:** all 120 in-bank targets start on a documented opcode, the seven others
    point at `$C048` in the fixed bank (legal, not garbage), and seeding all 127 readable
    entries took bank 6 from **5.4% to 82.5% traced with the illegal-opcode count still
    zero**.
  - A byte scan for this idiom across the whole ROM finds **exactly one** site. That closes
    the class for tables spelled this way and nothing else.
- **Bank 5's two inline jump tables are resolved**, and the way they were bounded is worth
  copying. Both are `JSR $9F10` with the table inline after it.
  - **`$A1C4`, 10 entries — the caller says so.** `$A1A2` does `LDA ($E4),Y / AND #$7F /
    SEC / SBC #$01 / STA $15 / CMP #$0A / BCC`, so the index is 0-9 and can be nothing else.
  - **`$9F32`, 9 entries — the caller says nothing.** `$51` reaches `$9F10` with no mask and
    no compare. The count is structural: entry 8 targets `$9F44`, which a tenth entry would
    reach. That method was *checked* on `$A1C4`, where the structural answer (10) and the
    code answer (10) agree.
  - **And then the trace confirmed both independently.** After seeding them, `gen-code-regions`
    leaves gaps of **exactly 18 and 20 bytes** where the tables sit — 9×2 and 10×2 — with
    traced code on both sides and the illegal-opcode count still zero.
- **Bank 5's structure records are decoded.** A record is `[next][dest][width][height]
  [tiles]` and the consumer is bank 5 `$8155`: it blits `width × height` tiles into a
  **16-wide, 192-byte buffer at `$0740`** (wrapping on `TXA / AND #$0F`, ending on
  `CPX #$C0`, so 16 × 12), then `$81A4` reads byte 0 as an offset and calls `$8379` when the
  byte there is non-zero. So byte 0 chains, and **a screen is several structures blitted
  over each other**.
  - Reached by `$A78E` reading `$A7A7,Y` with Y = `$51` for a byte *offset*, then
    `$A792`/`$A797` reading a pointer at `$A7B0` + that offset.
  - **The terminator is the record's own two size claims agreeing**, `next == 4 + w×h`.
    That is not a preference: chaining through byte 0 alone walks `$AC0D`'s chain past
    `$AC99` (12×1, sixteen bytes, ending exactly at `$ACA8`) straight into `$ACA9`, which
    is *traced code*, and reads it as a 10×101 record. The self-consistency rule stops
    there by itself.
  - 13 of the 21 distinct targets start a chain: **48 links, 801 bytes, disjoint, colliding
    with nothing**. **CORRECTION** to what the previous commit said — it recorded "the pool
    is not partitioned", which was true only of the byte-0-alone rule.
  - **Still open:** the other eight targets, contiguous at `$A8A6-$A938`, fail the test.
    They are selected by table entries the area path never reaches (only offsets `$16` and
    `$18` occur), so whatever reads them has not been found.
- **Metasprites: objects are assembled from many sprite tiles, and the table is SPLIT.**
  Low bytes `$C28D`, high bytes `$C319`, 140 entries, indexed by an object's `$0548,X`.
  `$CC2F` reads it, `$CC46` draws. **This is the second split table in the ROM** — the first
  is bank 6's object dispatch — so when a 16-bit pointer scan returns nonsense here, try the
  split reading before dismissing the bytes.
  - A record is `[count][offsets lo][offsets hi][tiles…][attributes…]`; bytes 1-2 name a
    shared table of (x, y) pairs. `$CDD7` emits one hardware sprite per pass into `$0200`.
  - **Three compressions.** Bit 7 of the count = *draw twice, mirrored* (`$CC4A` flips
    attribute bit 6), so a symmetric enemy costs half the data. Tile numbers are **relative**
    — `$CE03` adds the object's base tile in `$87`, and `$FF` skips. The attribute array is
    **run-length coded**: `$CE23` advances only when bit 3 is clear, which is why **a
    record's length does not follow from its count** and must be simulated.
  - **Flipping is positional too**: `$CDFB` negates x and biases by 7, `$CE33` does y with
    15 — the sprite's own width and height minus one.
  - **The count is bounded by the data, not the code.** `$CC80` has no limit. Counts run
    1-25 then jump to 112/116/124, a gap of 87; those four are the only ones whose bytes
    collide with a claimed region, and one is entry 0, which `BEQ $CC44` proves is never
    read.
  - **141 entries, not 140 — CORRECTION.** The halves overlap by one byte: `$C28D + 140` is
    `$C319`, both `low[140]` and `high[0]`, and `high[0]` is never read. **That is the same
    trick bank 6 uses**, written up two entries above, and still missed here first time.
    Id 140 is a real eight-sprite record at `$CBDC`; id 141 gives an offset table in RAM.
    **141 entries → 115 distinct records, 2,114 bytes.**
  - **Which object wears which:** an object's id comes from its handler's `STA $0548,X`, and
    bank 6 dispatches on type, so walking the 127 handlers gives the map — **103 of 127
    resolve**. Most go through an *animation table* (`LDA table,Y`), so a type owns a cycle:
    type `$01` is 37, 38, 40, 38, 37, 37, 37, 23. With the 21 writers in banks 1, 2, 3 and 7
    added, **84 of 132 valid entries are reached**, 34 distinct records by nothing.
    `parse-metasprites.py --objects` prints it.
  - **Two limits on that map.** An animation table is bounded only by the first byte that is
    not a valid id — **weak**, because valid ids cover most byte values. And handlers share
    subroutines, so a store reached from several is attributed to all of them: correct as
    reachability, not evidence that each type uses it.
- **The reset path verifies the mapper.** `$FF23-$FF43` loops Y from 6 down to 0: select
  bank Y, `CPY $BFFF`, and fall through only if the bank answered with its own number.
  On a mismatch it fetches a code from `$FF3A,Y`, stores it at `$0180`, calls `$DED2` and
  spins at `JMP $FF37` forever. The seven `$BFFF` bytes are annotated one per bank.

## Named so far, and nowhere to write it down

There is no RAM map yet. These came out of the code read so far and should go into one as
soon as it exists: `$04` (live PRG bank), `$05` (the DMC timer's rate index, reloaded into `DMC_FREQ` by the IRQ
handler and tuned between `$81` and `$89` to land the raster split), `$10`/`$11` (saved A/Y across a far call), `$12`/`$13` (the far-call inline
pointer), `$26` (`PPUSTATUS` snapshot taken in NMI), `$2B` (frame counter, incremented in
NMI and read by the IRQ handler), `$2F` (branched on at `$FF53` in the boot path; set to 0 by the TGL back door), `$30`
(the game-mode byte — bit 4 tested in NMI, set to 2 by the TGL back door), `$FC` (added to `$0200` in NMI), `$FE` (`PPUMASK` shadow).

## Known limits of the searches run so far

Write these down rather than trusting them. `tools/trace-code.py --assumptions` is the
authoritative, up-to-date version of this list; what follows is what does not live there.

- The bank-switch inventory rests on a **byte scan**, not an instruction walk, for the
  three store opcodes (`8D`/`9D`/`99`) with an operand of `$FFF2`. It reports operand bytes
  as opcodes, so its false positives are real; there were none to discard here. Its false
  negatives would be a store to the latch through some address other than `$FFF2`, and
  since any address in `$8000-$FFFF` loads the latch on UxROM, **the scan is complete for
  writes through this table and complete for nothing else.** A second switching path
  written as, say, `STA $8000` would still be invisible.
- **The trace reaches 18.9% of PRG with zero illegal opcodes** across 11,462 instruction
  starts. Those are two different claims: the first is about where it went, the second
  about whether it stayed on the rails while it was there. The second says nothing at all
  about the first. Every mechanism the tracer models was added because that count was not
  zero — it went 96 → 57 → 17 → 2 → 1 → 0 — and the last one was a typo in this project's
  own `rom.json`, where the NMI vector was recorded as `$D275` when the bytes say `$DC75`.
  `model.py` now re-derives all three vectors from the bytes so that cannot recur.
- The negative "nothing else reads `$BFFF`" is **not** claimed. A full opcode-table byte
  scan for an absolute operand of `$BFFF` and for an absolute-indexed base anywhere in
  `$BF00-$BFFF` returned 127 sites, nearly all of them undocumented opcodes decoded out of
  data — exactly the false-positive class the playbook says a byte scan produces. Only an
  instruction walk over traced code can turn that list into an answer, and there is no
  trace yet. The one site confirmed by reading it is `CPY $BFFF` at `$FF29`.
- **No code has been traced.** There is no `trace-code.py`, no `find-readers.py`, no
  reassembly check. Everything claimed so far was read by hand from `whereis.py` listings.
  Until the reassembly check exists, **no claim about a region's extent has been
  machine-verified** — only its SHA-1, which says the bytes are the ones the writer meant,
  not that the boundaries are right.
- Nothing is known about `$6000-$7FFF`. iNES byte 8 is zero and bit 1 of byte 6 says no
  battery, but no traced code touches that range because no code has been traced.

## Next, in order

1. **Bank 5's three big gaps remain**: `$B30A` (3,317 B), `$8A6E` (2,977 B), `$AD91`
   (1,363 B). `$B30A` opens with three-byte records (`30 16 0F / 30 27 06 / 30 21 0F`) and
   `$03` occurs 502 times in it — worth a look. Also the eight `$A8A6-$A938` targets whose
   reader has not been found.
2. **Find bank 0's tile blocks.** The title screen is 18 of 512 tiles explained. The
   partition test is the tool: a real table makes every block's decoded length land on the
   next pointer.
3. **Bound bank 4's referenced pool.** 7,639 bytes with 212 pointers into them, extent
   claimed and contents not. Command 6's pointers go through `$E82B` and command 4's to
   `$D92D`.
4. **Find the graphics decompressor.** A savestate taken *during* a load would have the
   block pointer live in zero page.
5. **Bank 7 still has 2,676 unclaimed bytes at `$C174`**, right after the entry JMP table —
   the largest single gap in the fixed bank.
6. Identify what the 21 sound commands and the 10 screen commands actually do, and which
   song id is which piece of music. Both name lists are read off the handlers' stores.
7. Start a RAM map. Page 3 is almost entirely sound state; `$B0-$BD` is the screen-data
   interpreter's; `$0411-$0430` is the password field; `$0500,X` is the object type that
   bank 6 dispatches on.
