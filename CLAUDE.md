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
- `tools/parse-map.py` — walks bank 5's world map (`tools/tgl/worldmap.py`) into
  `annotations/regions/77-bank5-map.json`. `--grid` draws it, `--areas` lists the 21
  entrances. Generated.
- `tools/parse-enemies.py` — claims the enemy per-type tables, spawn scripts and
  graphics-load streams into `annotations/regions/80-enemies.json`, printing four checks.
  `--types` and `--scripts` decode them. Generated; `tools/tgl/enemy.py` holds the formats.
- `tools/parse-scenes.py` — claims bank 5's scene tables, tile lists, metatile set records
  and metatile data into `annotations/regions/78-scenes.json`. `--areas` lists each
  labyrinth area's scene; `--verify STATE` checks a savestate's sets and room. Generated;
  `tools/tgl/scene.py` holds the format and the hardware checks. `docs/labyrinth.html`
  draws every area's metatiles.
- `tools/find-tables.py` — claims byte tables whose extent their own readers fix, into
  `annotations/regions/75-tables.json`. `--list` shows every candidate. Generated. **Read
  its header before trusting a number from it** — the rule only holds for reads in the same
  routine.
- `tools/parse-metasprites.py` — walks the metasprite table into
  `annotations/regions/70-metasprites.json`. `--id N` draws one as a grid, `--dump` lists
  all 140 entries. Generated; `tools/tgl/metasprite.py` holds the format.
- `tools/parse-structs.py` — walks bank 5's structure records into
  `annotations/regions/66-structs.json`. Generated.
- `tools/render-labyrinth.py` — draws the whole labyrinth, every room, into
  `docs/labyrinth-map.png` (and `-half`); `build.py` runs it. `--verify STATE` renders a
  savestate's room both from the ROM and from its own nametable/CHR/palette RAM and compares
  pixels (labyrinth state: 191/192 cells identical, the miss under an object). A room's area
  is byte 2's low nibble when byte 0 bit 7 is clear (`$EEE0` on entry via `$EC5B`); bit-7
  records are special screens (see below), drawn with their neighbours' area plus scene
  `$10` + screen type through the special path, as a new game meets them (unchecked).
  Background only: no objects, no key doors. `tools/tgl/labyrinth.py` holds the room rules.
- `tools/parse-text.py` — parses the dialogue script and the screen scripts into
  `annotations/regions/30-text.json`. `--dump` prints the decoded text. Generated; do not
  hand-edit.
- `annotations/external.json` — **knowledge from outside the ROM** (the manual so far), one
  paraphrased claim per fact, each with a status — `confirmed`, `consistent`,
  `rom-differs`, `unchecked`, `inconclusive` — and what the ROM says. The build validates it
  and draws `docs/external.html`. **An outside claim is a lead until the ROM backs it**;
  never cite one as a finding without its status.
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
  - **Three record sets, not one — CORRECTION.** `$80EC` is set 0; `$810B` (set 1, entered
    at `$8153` with Y = `$1F`) puts eight glyphs in sprite tiles `$08-$0F`; `$8134` (set 2,
    `$8158`, Y = `$48`) is the password screen's a-z, ! ?, umlaut dots and slashed zero. The
    font continues to `$8E0B` (31 more glyphs). Hardware: set 0 41/41 title and in-game,
    set 1 8/8 labyrinth, set 2 32/32 password.
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
  bank 3 `$8022` + `$8040` (6 + **48** — CORRECTION, it said 47: `$D7F9` reads
  `base + 2 × id` with bank 3's base `$8020`, so ids 16-63 are `$8040-$809F` and the 48th names
  the lead block `$A3F2`); `$FFFF` and `$0000` words are ids with no block.
  - **Three independent checks, and none of them was tuned.** *The partition:* a block's
    decoded length ends exactly on the next pointer — 21/22 in bank 1, 29/29 in bank 2,
    50/50 in bank 3. The terminator rule came from four blocks and then predicted the other
    ninety-seven. *The escape is forced:* brute-forcing all 256 values against that test
    leaves exactly ONE survivor for 14 of bank 1's blocks, and it is header byte 1 every
    time. *Hardware:* decoding out of the ROM reproduces **398 of the 512 tiles** of an
    in-game savestate's live CHR, byte for byte, 16 more being blank.
  - **The second header byte is a MIRROR escape — CORRECTION**, it was recorded here as not
    understood. Read off the decoder, bank 7 `$DB52` (NMI-driven, a byte budget per frame;
    `$DC5A` loads the header into `$09`/`$0A`; `$D7F9` = `$C042` arms it with block in A and
    bank in Y). The mirror byte is followed by a pointer: decoding continues there with every
    byte **bit-reversed** until the mirror byte recurs, whose pointer is then skipped. Run
    count 0 = 256. The three "3 bytes over" blocks were mirror references read as literals;
    implemented, every block in banks 0-3 is whole tiles.
  - **Bank 0's table is `$8030`, two entries — CORRECTION** to "no table in bank 0". Named
    by `$D842`/`$D84A`, the per-bank table bases. `$8BBB` and `$8D90` end exactly on
    `$917C` (sound tick) and match a title savestate **38/38 and 128/128**: title screen 18 →
    181 of 512 tiles. `$8BB2-$8BB9` before it is an 8-entry table of waits in seconds
    (`$8959`, `CPY #$08`, `LDY #$3C`); `$8BBA` is one byte unexplained.
  - **CORRECTION to the earlier lead.** This file said 1,046 of 8,192 live CHR bytes were in
    the ROM verbatim with sources in bank 0 `$8CDA-$9195`. The shape was right and the size
    was badly wrong: a verbatim byte search can only ever find a block's *literal* sections,
    never a run section. The bank 0 attribution is also unreliable — `savestate.py --chr`
    reports the first occurrence of a window anywhere in the file, not the producing block.
- **The decompressor was in traced code all along** (`$DB52`), unrecognised; the note that
  said it was not found is superseded by the two entries above. Its callers are how enemy
  graphics get loaded — see the enemy entry.
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
  as its **grid index** — `$88F2` is `LDA $16 / STA $0411,X`, and `$880F` builds `$16` as
  column + 10 × row. **The grid is 64 characters**, seven rows of ten: A-Z, 0-3, a-z, 4-9,
  ! and ? (tiles `$81-$9A` are a-z, drawn under a row of `$AE` dots, so on screen they
  carry umlauts). A is 0, T is 19, `0` is 26, `a` is 30, `4` is 56, `?` is 63.
  - **CORRECTION.** This file said "A-Z then 0-9" and that the nametable confirmed it; only
    three of the seven rows had been read, which put 4-9 at 30-35. The manual's handwritten
    passwords, full of umlauted letters, prompted the re-read.
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
  - **Every payload is typeable** — 64 characters fill six bits. **CORRECTION:** this file
    said most were not and floated a lead that the seed exists to dodge untypeable fields;
    both came from the 36-character misreading. `password.py --selftest` round-trips 2000
    random passwords; it still tests only self-consistency. The manual's handwritten
    passwords are too ambiguous to check the decoder: 6 of 1,536 readings pass, which is
    chance.
  - **The payload, read off `$85B0` and `$8473`:** index i lands at `$0439 + i`; 0-16 →
    `$04A0-$04B0` (corridor flags, weapon levels, Enemy Eraser count, keys), 17 → max life
    `$47` (high 5 bits) and `$6B`, 18/19 → attack/shield, 20/21 → score, 22 checksum, 23
    unread. `$83AE` is the encoder. `$8473` was untraced because the trace thought `$887F`
    never returns — it leaves by `PLA / PLA / JMP $8516` (`returns_via_stack` in
    `dispatch.json`).
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
- **Bank 5's room drawing is decoded — CORRECTION to "structure records chain".** Bank 5
  `$8155` fills a **16 × 12 tile buffer at `$0740`**, and `$A749` picks three pointers first:
  a **structure** (`$A7B0`, 13), a **door set** (`$A7CA`, 12) and an **item list** (`$A7E2`,
  10). Labyrinth rooms use entry `2 × $50`; when `$30` bit 5 or 6 is set, `$A7A7[$51]`,
  door set 11 and `$A7E2[2 × $51]`.
  - A structure is `[list offset][dest][w][h][pattern]` and the pattern is **tiled** over the
    whole buffer (rows repeat until the column wraps, rows until `CPX #$C0`) — a 1 × 1
    structure is a floor. The list offset names four `[length][item]`s drawn by `$8379`,
    or lands on a `$00` for none.
  - A door set is eight `[length][item]`s: four always, then one per exit N W E S, drawn
    when the exit is closed or the neighbour is empty — the walls across unused openings.
  - An item (`$A6EB`) is `[dest][w][h][tiles]`, `$00` transparent; width bit 7 = one tile
    repeated, height bit 7 = a pointer to the tiles instead. Item lists are `$0000`-ended
    pointers to bare items. Then the room layout goes on top (`$8243`).
  - **Checks:** all 48 length bytes agree with their items, and `$A7F6-$ACA8` is partitioned
    exactly (two sharings folded: a tile slice, and the empty list `$A916` being list 3's
    terminator). **Hardware:** `parse-structs.py --verify` rebuilds the labyrinth savestate's
    room and matches **191/192** cells against the nametable (the miss is under an object);
    without the west-exit wall it is 156.
  - The old reading chained through byte 0 while `next == 4 + w×h`; that worked only
    because list offsets usually point just past the pattern and length-headed items look
    like records. It left `$A8A6-$A938` unexplained — door set 11 and the item lists.
    `$A7A7`'s offsets select `$A897`/`$A8A0`, not `$AA8A` as its annotation said.
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
- **A table's length is often stated by its reader.** When one routine reads two tables
  with the same index register, **the distance between their bases is the length of the
  earlier one**. Bank 7 `$CFAB-$CFBD` is four `LDA abs,Y` six bytes apart reading `$D02C`,
  `$D0AB`, `$D12A`, `$D1A9` — so the first three are 127 entries each, with no argument
  about the bytes needed. `tools/find-tables.py` applies this and claims 85 tables.
  - **"Same routine" is the whole rule.** Two bases read by unrelated code bound nothing.
    A first version took the nearest base anywhere in the bank and "bounded" bank 5
    `$B30C` at 3,315 bytes — the rest of the gap. Reads must now be within 24 bytes of
    each other, and a candidate containing another candidate's base is clipped there.
  - It claims **extents, not meanings**, and it cannot bound the last table in a group.
- **Bank 5 `$B30A` is 36 palettes of three colours — CORRECTION, it was 37.** `$B2E4` states
  the layout (`X = A × 3` into `$0181,Y`; colour 0 is the backdrop `$0180`). The old bound —
  "every byte a legal colour for 111 bytes" — swallowed the first three bytes of set record
  6 at `$B376`. The real bound: every palette list in the ROM (`$D92D` walks up to 8, `$FE`
  ends, `$FF` skips) uses indices 0-35. Sprite palettes 0-3 match two savestates.
- **Scenes: how an area or corridor gets its tiles, metatiles and palettes.** Bank 5 `$ACA9`
  loads scene A from `$AD91 + 3A` (39 scenes): a tile list (`$AE06`, blocks decompressed to
  background CHR), a metatile-set record (`$AE24`, `[count]` + `[set|list<<4][tile base][ptr]`,
  loaded by `$AD1A` into `$0460-$047F`) and a palette record (`$AE50`). A set is a window of 32
  metatiles × 5 bytes; a room cell's byte is set (bits 5-7) + metatile (bits 0-4).
  - **Labyrinth area n = scene n + 5**, after the common scenes 0 and 32; areas 1-2, 3-4,
    5-6, 7-8, 9-10 share data. Corridors: scene 1 then `$EF55[c]`; special rooms 16-31.
  - **Hardware (labyrinth savestate, area 0):** background CHR **159/159**, set pointers
    **8/8**, palette slots **8/8**, room cells **192/192** metatiles of the live sets.
    Corridor savestate: CHR 141/142, sets 6/6.
  - **CORRECTION:** the old lead "`$B379`'s six block pointers" is set record 6 at `$B376`;
    its targets are metatiles. Tables, lists and records partition `$AD91-$AF1B` exactly.
- **Bank 5 `$8A6E-$960E` is the WORLD MAP**, and finding it needed a different search. No traced code references it and **no pointer table anywhere in the
  ROM points into it** — a scan for runs of four or more consecutive in-range 16-bit values
  returned 34 runs, every one a false positive inside an unrelated table. What found it was
  scanning for code that **builds the address as immediates**: `$808F` does
  `LDA #$6E / STA $16 / LDA #$8A / STA $17` and calls `$80F5`; `$882D` builds the same
  address into `$1A`/`$1B`. **Add that to the toolkit — a pointer that is never stored in a
  table is invisible to every table scan.**
  - **A record is `(first byte AND $0F) + 1` bytes.** `$8103` is
    `LDA ($16),Y / AND #$0F / SEC / ADC $16` — the `SEC` is the plus one.
  - `$80F5` is a **seek**: `$15` counts columns to `CMP #$18` then rolls into a row counter
    `$14`, so the stream is **24 records per row**, and it stops when (`$14`,`$15`) reaches
    the (`$18`,`$19`) the caller wants.
  - **CORRECTION — the map is 24 × 24 = 576 records, `$8A6E-$91E9`, not 807 in 34 rows.**
    The old proof, "807 records land exactly on `$960F`", is one a walk over arbitrary data
    passes about one time in four. `$91EA-$933F` is **19 room shapes** of 18 bytes (1bpp,
    `$8042` computes `$91EA + 18 × n`, `$8278` shifts them into rows 2-10 of the `$0740`
    buffer) and `$9340-$960E` is **79 room layouts**, `[shape | count<<5][tile]` + count ×
    `[tile][pos][mask|dir]` (`$8243`/`$82A3`, steps from `$82D9`). The layout chain lands
    on `$960F` exactly and holds all 67 layouts the map points at.
  - **`$882D` draws it on the status screen**, rows 0-23 only (`CMP #$18` on `$14`), as
    **background tiles covering 2×2 cells each**: `$891F` ORs a quadrant bit (1/2 even row,
    4/8 odd, doubled for an odd column) into a 12-byte row buffer at `$0150`, flushed as 12
    tiles every second row. **Hardware sprites mark area entrances only**, at
    `column × 4 + $10`, `row × 4 + $3B`, tile `$01`; bank 2 `$8998` blinks one more at
    (`$52`, `$53`) — the player's column and row, which `$8071` steps as you walk.
  - **A record's bytes.** Byte 0: low nibble = length − 1, `$80` exactly = empty. Byte 1:
    low three bits name the **key** that reveals the cell — `$8860` tests bit (k−1) of
    `$04B0`, the key inventory that bank 7 `$F547` fills on pickup. Byte 2: bit 7 marks an
    **area entrance**, low seven bits the area number; its marker shows while the area's
    `$04A9` bit is clear (`$C07B`), and area 21's only once areas 1-10 are all flagged.
  - **CORRECTION.** This file said every qualifying cell becomes a hardware sprite, that
    byte 0 bit 7 means "drawn on the map", and that byte 1 is a progress flag "which hides
    the map until you have been somewhere". Reading `$891F` and the rest of the status
    screen showed all three wrong.
  - **The checks that carry it:** the records with byte 0 `$82` and byte 2 bit 7 set carry
    area numbers **1 to 21, each exactly once**, all in rows 0-23. The key each needs
    repeats with period ten — areas 1-10 need 0,1,2,3,4,4,5,5,6,7 and 11-20 need
    1,1,2,3,4,4,5,5,6,7 — and drawn by key the map falls into solid zones, not noise.
    `parse-map.py --grid` prints the key per cell; `docs/status.html` draws it.
  - **The rest of the record** (`$8121`, `$8243`): byte 0 bit 4 = layout pointer present,
    bits 5-6 = room kind (`$5D`; `$20`/`$40` carry a sub-id `$5E`, `$40` rooms go to
    `$A663`); byte 1 bit 3 = the room has enemies. Then, in order: sub-id, spawn script id
    (`$57`), layout pointer. **All 370 non-empty records are exactly as long as those flags
    say**, and 211 rooms name script ids 1-47, every one of the 47.
  - **Not established:** bit 7 of byte 0 beyond the entrance test; what `$5E` selects
    through `$A377`; 12 layouts nothing points at.
- **The status screen (Select during play).** `$D626` reads the pads with `ROL`, so A is
  bit 7 and Right bit 0; `$D678` keeps `$F7`/`$F8` held and `$F5`/`$F6` newly pressed.
  Bank 7 `$E4B3`: new Start pauses, new Select goes to `$E4EE`, which calls bank 5 `$801B`
  → `$84CB` (open), `$8021` → `$8937` each frame until Start/Select, `$801E` → `$8711`
  (close).
  - **Icons, uncompressed, in bank 2.** `$81B2` (slot `$8003`) uploads icon A from
    `$8E0C + 64A`: 18 icons, four 2bpp tiles each, 0-11 the weapons. The extent is the
    highest index any caller passes (17, in bank 3's reward list) and lands exactly on
    `$928C`. `$8212` (slot `$8006`) builds **key** icons from 8 × 32 bytes of low plane at
    `$92AC` and one shared high plane at `$928C` — ending exactly where the gap does.
    Rendered, all 26 are clean pictures.
  - **Slots** `$8690`: 20 × `[ppu lo][ppu hi][attr lo][tile]` — keys 1-7, a zero slot 7,
    weapons 1-12. The tiles match where the uploaders put the art, and each attribute byte
    matches its slot's position. `$85DA` gives the palette per weapon level —
    **CORRECTION:** the trace had decoded it as a `BRK` after an always-taken
    `LDA #$20 / BNE`.
  - **Weapon names, from the manual's pictures** (`annotations/external.json`): the 12
    weapon icons match the manual one for one, so `$3C` 1-12 = MultiBullets, Back Fire, Wave
    Attack, Bullet Shield, Grenade, Fireball, Area Blaster, Repeller, Hyper Laser, Saber
    Laser, Cutter Laser, Enemy Eraser; icons 12-17 = Energy Tank, **Blue** Lander, Gun, Shield,
    Consecutive firing, **Red** Lander — CORRECTION, 13 and 17 were swapped: the two are one
    picture in different colour indices, and the effects in bank 2 `$86BC` (13: max life +8;
    17: chip maximum `$46`) and the reward screen's palette both say 13 is blue. So "EE" / `$04AF` is the Enemy Eraser's stock.
  - **Weapons.** Cursor `$3C` (0 none, 1-12), five to a row; `$FD77` puts its level (two
    bits each in `$04AC-$04AE`) in `$3D` and skips unowned ones. Chips per use:
    `$45 = [$FDD3 + 3 × weapon + level]`, 11 × 3 bytes that fill `$FDD7-$FDF7` exactly;
    weapon 12 is counted in `$04AF` instead. `$3E` = chips / `$45`, the uses left.
  - **Also bounded:** bank 3 `$817A`, 73 `[threshold][icon]` pairs for "YOU GOT ITEM",
    fixed by `CPX #$92`, thresholds non-decreasing, icons all 0-17.
- **Enemies.** 24 object slots, field f of slot s at `$0500 + $18f + s`; slots 0-4 are the
  player's side and `$EA8C` allocates 5-23. `$CFA0` fills four fields from per-type tables
  six bytes apart: `$D02C` → `$0578` collision flags, `$D0AB` → `$0590` **hit points**,
  `$D12A` → `$05A8` **attack**, `$D1A9` → `$0620`. `$D30E` subtracts each side's attack
  from the other's HP; at 0 `$D32A` sets the type to `$D441[type]`, the death type.
  Hitboxes are **by metasprite id**: `$C174` half-width, `$C201` half-height.
  - **Art:** `$CFC4[type − $0E]` names the tile block holding a type's tiles. Load streams
    `[flags|slot][block][tile]` are run by `$E99F`, which decodes through `$D7F9` and keeps
    `$0480`/`$0490` as the loaded block and tile per slot; `$CF5F` makes an enemy wait for
    its block. **Checks:** all 54 graphics ids name real blocks, and in every stream each
    tile position is the previous plus that block's decoded length — 19 of 19.
  - **Spawn scripts**, bank 5 `$A525`, pointers `$A4C7` (47), run by `$F78F`: `<3` =
    command via the inline table `$F7C9` (0 wait, 1 jump, 2 end — now in `dispatch.json`);
    else spawn a type, or with bit 7 a **formation** `[type|$80][count][interval]` carried
    by a type-`$29` spawner (bank 6 `$9A19`). They cover `$A525-$A662` byte for byte.
    **Five end `[byte] 01 02`**, read as a long wait then a jump into the next script —
    open.
  - **Special rooms** (kind `$40`): `$A682[sub-id]` with sub-ids 11-32 — `$A682+11` is
    exactly where code ends — into 13 `[type→$72][stream]` records at `$A6A3`, whose
    seven streams end exactly on code at `$A6EB`.
  - **Assembled.** `$87`, the base tile the metasprite drawer adds, is `$06C8,X`, set from
    `$0490` — so a metasprite's relative tiles index the type's block. Sprites are **8×16**
    (`$8711` sets PPUCTRL bit 5; flips are −x−8 at `$CE0A` and −y−16 at `$CE39`), and
    `metasprite.emit` follows the drawer exactly. `$0620` (from `$D1A9`) is **drawing
    flags**, tested bit by bit at `$CBE8`. The four live sprite palettes in both savestates
    are exactly `$B30A` records 0-3. **Checks:** 133 of 149 type/metasprite pairs use only
    even tiles inside the type's block (the rest are bosses reading the next block, or
    shared-subroutine attributions); `parse-metasprites.py --verify` finds every
    multi-sprite object drawn that frame whole in the in-game savestate's OAM (3 of 3;
    the other three are not drawn that frame). `docs/enemies.html` draws them.
  - **The scrolling areas** get enemies two ways. *Waves:* bank 4 command 2 with bit 1
    set (`$E733`) starts a spawn script **in bank 4** (`$66`/`$67`, `$7F = 4`), same
    interpreter, but a wait counts frames with `$A0` bit 2 set — `$E98F` sets it when a new
    background row comes in, `$E655` clears it — so waves follow the scroll. Command 7
    (`$E85E`) loads the area's art from bank 4 streams. *Ground objects:* each new row is 16
    metatile ids in `$04C0` (`$E8AB`); bank 5 `$83B3` draws a metatile from 5 bytes and
    writes the 5th back, and `$89FB` spawns from the `$803C` lists for any cell whose 5th
    byte has a high nibble. **Checks:** areas 1-21 name one script each; 23 scripts and 27
    streams are pairwise disjoint; all 5 jump-ending scripts loop into themselves; 139 of
    144 (area, spawned type) pairs have their art in that area's streams. Area 16's script
    runs into the next block (`$B011`) — end not established. `parse-enemies.py --areas`.
  - **CORRECTION to bank 4:** the four "terminal triggers" ($1100, $270F, $3700, $3800) are
    not trigger data. A block's last record has no trigger; `$E89D` reads the next two bytes
    anyway, and three of the four are exactly the first bytes of a spawn script or graphics
    stream. The walker no longer claims them, and bank 4 is now **100%** claimed.
  - `find-tables.py` was nondeterministic (it iterated a set of tuples holding strings);
    fixed by sorting.
  - **Tracer change:** `JSR $D705` with A unknown now continues in the fixed bank with the
    live bank unknown, instead of stopping. That traced `$E9AA-$EA67`, the loader.
- **Terminology — CORRECTION.** What this file and the tools called "areas 1-21" are the
  **corridors** (`$51`): the vertically scrolling shooter stages, entered from the
  labyrinth ("Corridor No.2" in the dialogue). The **labyrinth** has its own **areas**,
  `$50`, 0-10, which the HUD prints after AREA (bank 7 `$E169`: `$50` in the labyrinth, `$51`
  when `$30` bit 1 is set). Leaving corridor n sets `$50` to n, folding 11-20 onto 1-10 and
  capping 21 at 10 (`$F2A0`) — corridors n and n+10 belong to labyrinth area n, which is the
  period-ten key pattern. Generated text now says corridor; `tools/tgl/screen.py` keeps the
  old variable names under a note.
- **The labyrinth savestate** (`...zakkythegoatragon...labyrinth.fcs`, saved uncompressed —
  `savestate.py` now reads that too) checked, all against hardware:
  - the HUD reads `AREA 0  X 8 Y12` = `$50`, `$52`, `$53`; the live room pointer `$E4` =
    `$8E4C` is exactly the map walk's row 12 column 8 record, whose "enemies, script 1" is
    the live `$57 = 1`, and slot 23 is a type-`$29` spawner of type `$0F`, script 1's
    first formation;
  - `$0480`/`$0490` are the default load stream `$A497`, loader mid-way through its last
    record; the type-`$0F` enemies' base tile `$80` is where block `$13` went;
  - **the room**: layout `$95D9` decoded from the ROM puts metatile 3 in 17 cells and 9 in
    one, and the nametable has `14 16 / 15 17` and `10 12 / 11 13` in exactly those cells —
    metatiles read from the live set pointer `$0460` = `$AF1C`, 5 bytes each. Floor is set
    3 metatile 16 (`$70`). The one odd cell is metatile 10 where an object stands;
  - **map byte 1 bits 7/6/5/4 = openings N/W/E/S** (`$82DD` against `$E0`/`$E2`/`$E6`/`$E8`,
    built by `$8071` from row±1, column±1); the room's `$B8` = open N, E, S, walled W,
    as on screen. Byte 0 bit 7 puts a key door in an opening (code only).
  - CHR 393/512 from the ROM; OAM: the player and a 2-sprite object found whole.
  - Metatile sets come from records `[count]` + `[set|list<<4][tile base][ptr]` via the
    pointer table `$AE24` (loader `$AD1A`); the first record, `$AF1C`, points at itself.
- **Bank 0 screens found in the gaps.** `$84F7` is the **title-screen picture** (a screen
  script, 30 rows of tiles `$80-$F6`; `$8485` builds PPU `$2000` + pointer), matching the
  title savestate's nametable **360/360**. `$89F9-$8BB1` is the **ending**: MISSION
  COMPLETE and eight credit screens rendered in sequence by `$8927` at PPU `$2220` (the
  renderer leaves `$16/$17` past each `$FE`), timed by the **9-entry** table `$8BB2`. At the
  last screen `$899F` waits for Start, reads `$8BBA` and renders a tenth, **PASSWORD TGL**
  (`$8BA3`) — the game shows its own back door. The credits name COMPILE and the staff.
  **CORRECTIONS:** `$8BBA` was "unexplained"; `bank0.text_8B80` was the middle of the ninth
  screen, whose script starts at `$8B67`; `$8600` was never a head.
- **Tracer: branches after `LDA/LDX/LDY #imm` are decided** (`LDA #$01 / BNE` is a jump).
  Found when the weapon handler tables (bank 6 `$8653` ×12, `$86E7` ×13, dispatching on
  `$3C`) traced `$879A` and the fall-through at `$87DA` decoded a table.
- **Late gap work.**
  - Sound: command `$90` points at a **per-note sequence** (`$9534`; `00 lo hi` loops) —
    CORRECTION, it was "duty / flags"; `$8B` tables and jump-only continuations
    (`$B809`) are claimed by `parse-sound.py`; song entries whose header byte is `$00` run as
    code at pointer + 1 (`extra_seeds` in `dispatch.json`).
  - **Weapon stats by level**, bank 6: `$86AF` computes Y = level × 11 + weapon and reads four
    tables whose read bases (`$86F5`, `$8716`, `$8737`, `$8758`) sit **12 bytes before** the
    bytes actually read (`$8701`, `$8722`, `$8743`, `$8764`), since Y ≥ 12. CORRECTION:
    `find-tables.py` had claimed them at the bases, over the weapon jump table.
  - `find-tables.py` has a **second, weaker rule**: a gap whose first byte is a read base is
    claimed to the next base or the gap's end, as a **lead**. 140 regions, 1,210 bytes.
    **Coverage past 97.3% is mostly these leads** — accounted for, not understood.
  - Registering a jump table in `dispatch.json` does not claim its bytes; `73-weapon-tables`
    claims `$8653`, `$86E7` and bank 7 `$F7C9` by hand.
  - **The small gaps were mostly the overlap trick again**: a read base one byte before the
    data (the RTS ending the code), because Y starts at 1 (`$3D` weapon level, `$4A`/`$4B`,
    `$51`) or at a type number. `find-tables.py` cannot see these; read the handler.
  - **Corridor keys, bank 7 `$F6DB`**: corridors 1-10 award keys 1 2 3 4 0 5 0 6 7 0, and
    corridor n gives exactly the key labyrinth area n+1 needs — an independent check on the
    map's key pattern.
  - **Aiming, `$F863`**: 16 directions from `$F95E`, stepped by `tan` thresholds at `$F95B`.
  - `22-unreferenced-code.json` holds code nothing is known to reach (bank 0 `$95F9`, bank 3
    `$8B6B`, bank 7 `$CF2B`, `$D69B`), all leads. The DMC sample at `$FFC0` is claimed.
  - **Per-type tables sit after their handler's code.** `LDY $0500,X / LDA base,Y` with the
    base inside the handler, so only the handler's own types (from bank 6's dispatch) reach
    data: `$A5A0` ($5A-$5C), `$A766` ($50-$51), `$A3DA` ($55-$57), `$9031` ($24-$26) and more.
    `$FD4B` is the player's attack by `$4A` (1-4, capped at `$FD0E`).
  - Lead worth chasing: bank 0 `$8107-$8128` gives a powered-up start (life `$80`, every
    weapon level 2, `$4A`/`$4B` = 2) when `$F7` bit 4 and `$30` bit 1 are both clear — the
    conditions are read, the meaning is not.
- **Fleepa, and objects drawn in pieces (owner's savestate `...fish.fcs`, corridor 1's
  boss).** Slot 23 is type `$40`; bank 6's handler `$9081` is only a far call to bank 3
  `$952E`, which draws metasprite 131 and then more through `$CC34` (132/133 twice mirrored,
  123/25 by `$07B8`, 134/135 24 px lower) — **41/41 sprites** rebuilt from the ROM match OAM.
  **CORRECTION:** the enemies page showed type `$40` as metasprites 25 and 42 because
  `metasprite.reachable()` did not know inline arguments: it decoded `$9081`'s far-call bytes
  as instructions and ran into the next handler. It now skips inline arguments, follows far
  calls (105 types resolve, was 95), cuts tables at claimed regions, and lists `$CC34`
  pieces. **Every pieced type now has a composite** (`metasprite.PIECED`, drawn on
  `docs/enemies.html` in several poses): `$23` (body + 127, 40 px above), `$24`-`$26` (two
  arms 110 56 px below, spread by `$15`), `$2D`-`$2F` (frame body + blinking 124), `$40`/`$41`
  Fleepa, `$46` (136 + head 137/138), `$4C`/`$4D` (109 + itself flipped 32 px below), `$4F`
  (81 + two legs: claw 82 and a shaft of single sprites via `$CF05`), `$55`-`$57` (105 + 103/104).
  Pieces move `$84`/`$85` (y/x), `$86` and `$87`; bases are relative to `$07E8`, the block
  base `$CF8D` copies from `$06C8` at spawn. Only Fleepa is checked against hardware; `--verify`
  tries every pose for the rest. `$01` (player's exhaust) and `$35` (a two-part door at fixed
  screen positions) use absolute tiles and are listed, not drawn. The page's tile runs now
  follow bank 4's corridor streams too, so corridor bosses are no longer drawn with holes.
  Bank 3 `$9151` = boss type by corridor.
- **What the labyrinth's rooms hold** (`tools/tgl/labyrinth.py`, `docs/labyrinth.html`).
  - **Byte 0 bit 7 = a special screen, not a room.** `$EC12` keeps the area, `$EE1D` picks
    screen type `$51` from byte 2 and loads scene `$10 + $51`; `$9F22` runs `$9F32[$51]`.
    Corridor entrance (byte 2 bit 7): screen 8 sealed gate (two type-`$35` halves — the
    "two-part door"), 5 once cleared with reward `$EF40[c]`, 0 for corridor 21 until 1-10
    are cleared. Otherwise byte 2's nibble: 1 progress recorder (message 4, keeps `$52/$53`
    in `$7C/$7D`), 3 message = sub-id (story 0-3, seal hints 12-20), 2/6 the round
    creature's shops (`$A04E`, `$A067`; prices in chips), 7 a shop after buying.
  - **Key doors** (`$82DD`): each open exit where either side has byte 0 bit 7 gets a door
    (metatile 8, fixed cells) and `$58-$5B` = the neighbour's key; `$8FF5` opens with key 0 or
    bit k-1 of `$04B0`. 176 doors.
  - **Items:** kind `$20` rooms; item `$A377[sub-id]` on the layout's metatile 6, whose fifth
    byte `$10` spawns list-`$AF61` entry 1 = type `$31`; the sub-id is its flag (`$04A0`
    array, `$EFE0`/`$EFE9`). **Check: metatile 6 is in each of the 34 item rooms exactly once
    and in no other room.** **Minibosses:** kind `$40`, `$A6A3 + $A682[sub-id]` = type +
    stream, boss phase `$70 = 1`. **Loop gates:** kind `$60`, `$A3DB` opens metatiles 4/5 when
    the last moves (`$04F0` history) sum to zero.
  - **CORRECTIONS:** `worldmap.KINDS` said "sub-id / special / entrance" for `$20/$40/$60`;
    `$A377` and `$EF40` said "what `$55` selects is not established"; the special-room
    records at `$A6A3` said `$72`'s use was not established; the first labyrinth map drew the
    58 special screens as rooms.
- **The TGL game: corridors only (owner's claim, CONFIRMED from the code).** `$30` bit 1.
  A new game (`$EB18`) starts corridor 0; at each corridor end `$ECE7` sends a normal game
  back to the labyrinth but the TGL game to bank 3 `$80A0` (YOU GOT ITEM), then
  `$51 = $ED08[$77++]` — 1, 11, 12, 2, 13, 3, … 10, 21, every corridor once — and after 21
  the ending. **Rewards by score:** corridor start copies the score to `$04B9` (`$EF86`), the
  boss turns it into points gained (bank 3 `$91A7`) and ticks 10 off every 64 frames of the
  fight (`$9305`); bank 6 `$805A` adds it to a running total `$04B3` and sets `$15` = total /
  10,000 displayed points. `$80E7` gives each `$817A` entry from `$76` on whose threshold ≤
  `$15`, via the pick-up routine `$86BC`, at most five a screen. **Scores are stored in tens**:
  the HUD prints a fixed 0 after the six digits (labyrinth savestate: `001684` → `16840`).
  `docs/password.html` tabulates all 73. Not played.
- **The sound test (owner's claim, CONFIRMED from the code).** Reset and power-on run bank 0
  `$8332` (entry `$800C`, from `$FF50`); `$8341` tests `$F7 == $C0` — A and B held, nothing
  else — and far-calls bank 3 `$801B` → `$822A`: SOUND TEST, sound number 1-71 at PPU `$20CD`,
  Right/Left step (wrapping), Down plays (`$C030`), Up silences (bank 0 `$97A0`). The one
  far call to it in the ROM. Not tried on hardware. `annotations/external.json` has it.
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
(the game-mode byte — bit 4 tested in NMI, set to 2 by the TGL back door), `$FC` (added to `$0200` in NMI), `$FE` (`PPUMASK` shadow). The status screen adds a batch — `$3B-$3E`, `$45`, `$4A-$4F`, `$52`/`$53`, `$04A9-$04B0`, `$F5-$F8` — tabled in `docs/status.html`.

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

1. **Name the enemy types.** The manual names nine (`docs/external.html`); a match by eye
   against `docs/enemies.html` is a lead. A savestate with known enemies on screen would
   settle it, and `parse-metasprites.py --verify` would check their shapes.
2. **The last 35 unclaimed bytes**, none with a reader found: bank 0 `$82BD` (8) and
   `$BF04` (3), bank 5 `$84C3` (8), bank 6 `$A9BA` (5) and `$B902` (2), bank 7 `$EEC4` (8)
   and `$EF6B` (1, one past `$EF55`'s 22 entries). Then the leads: `build.py` counts them,
   and past 97% most of the coverage is leads. Which rooms take the room drawer's special
   path (`$30` bits 5-6).
3. **The five bank 5 spawn scripts that end on a jump**, and corridor 16's.
4. **What `$55`, `$04A0-$04A8`, `$46` and `$6B` hold** — all now have known writers.
5. **The other `$16`/`$17` consumers** — `$C04B`, `$C006`, `$C07E` (a rectangle blit,
   `$D99C`).
6. Start a RAM map. The object slot fields are most of page 5.
