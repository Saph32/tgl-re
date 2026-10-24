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
- `tools/tgl/ram.py` + `annotations/ram.json` — **the RAM map** (`docs/ram.html`). `ram.py` decodes
  every traced instruction and cross-references every access to $0000-$07FF (read / write /
  modify, banks, first sites; an indexed access counts on its base). `ram.json` is hand-authored:
  one entry per named byte or range with a status (`confirmed`, `checked`, `lead`) and where the
  meaning was read, plus the object-slot fields and the bits of `$30` and `$A0`. The page shows the
  generated counts beside the names and lists the busiest unnamed bytes - the to-do list. **Absence
  of accesses is not evidence a byte is unused**: untraced code is not seen.
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
  meter redrawing part of a character tile. That is the LIFE METER's partial segment (see the HUD entry below).
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
  - **The pool is decoded — CORRECTION to "the pool is a lead".** Command 1 → a row table
    `[rows][count]` (`$E8AB` repeats the rows, 16 metatile ids each, row `$A1` cycling);
    command 6 → eight overlay slots (`$0400-$045F`) drawing structures `[w][h][rows]` over
    it, row codes `$00 n` skip / `$01` end / else a metatile (`$E90F`); command 4 → a palette
    list (`$D92D`). 13 row tables, 142 structures, 7 palette lists: every decoded piece lands
    in the pool; 30 bytes are left (an unused row table + row, two unused 1×2 structures,
    one byte, a never-matching trigger, fill). **Scroll:** speed `$B8/$B9` in 1/256 px/frame,
    ramped 2/256 per frame toward command 0's target `$BA/$BB` (bit 7 = at once); a row
    every 16 px (`$AF`), row counter `$B0/$B1` = the stage clock. `docs/corridors.html`.
    **Per corridor:** `tools/tgl/corridor.py` walks one corridor's block (records with the row
    each fires on), its placements, strips and palette slots, and draws them with PIL;
    `docs/corridor-00.html`…`-22.html` show every strip and structure. **Hardware (corridor 15
    savestate):** all 8 palette slots predicted exactly; new rows enter at the top — nametable
    rows 8→3 hold strip rows 0,1,2,3,4,0 upward and the 1×2 pillars stack row 1 over row 0 —
    so pictures put a structure's first row at the bottom. Metatile ids are ambiguous on
    screen (identical tiles, different ids), so screen checks compare tiles, not ids.
    **Whole stages:** `corridor.simulate` replays `$E6CE`/`$E8AB` row by row (records firing
    at their row, the strip, eight overlay slots with delay/repeats/gap/step/edge cut-off,
    command 9 taken after a command 5); `stage_image` draws it with palette changes at their
    rows; `docs/stage-NN.png` (+ `-film.png`, columns of 120 rows). **Hardware:** corridor 15
    at row 41 — the 13 settled screen rows equal the simulation cell for cell; the newest row
    is mid-write (each cell new or old); one column-0 cell differs, not established why.
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
    ends at `$B010` (see the corridor-16 entry below). `parse-enemies.py --areas`.
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
    built by `$8071` from row±1, column±1); the room's openings byte `$54` holds `$B8` = open N, E, S, walled W (bit 3 also set, unexplained),
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
  - ~~Lead: a powered-up start at bank 0 `$8107`~~ — **it is the demo's setup** (see the demo
    entry below).
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
  Fleepa, `$46` (136 + head 137/138), `$48`/`$49` Grimgrin (body 64, then $17/$15/$14 pieces - 41, 48/49/4A, 45/46/47 - the last two pairs mirrored; the eyes; **CORRECTION: it had no composite, so the page showed it without its eyes** - checked against the owner's `...grimgrin.fcs`, 40/40 sprites, state `$07A0` = `$1F`, frame 4), `$4C`/`$4D` (109 + itself flipped 32 px below), `$4F`
  (81 + two legs: claw 82 and a shaft of single sprites via `$CF05`), `$55`-`$57` (105 + 103/104).
  Pieces move `$84`/`$85` (y/x), `$86` and `$87`; bases are relative to `$07E8`, the block
  base `$CF8D` copies from `$06C8` at spawn. Only Fleepa is checked against hardware; `--verify`
  tries every pose for the rest. `$01` (player's exhaust) and `$35` (a two-part door at fixed
  screen positions) use absolute tiles and are listed, not drawn. The page's tile runs now
  follow bank 4's corridor streams too, so corridor bosses are no longer drawn with holes.
  Bank 3 `$9151` = boss type by corridor.
- **Boss behaviour (read from the code; only Fleepa's setup checked against a savestate).** Names from the owner (`external.json` fact `enemy-names`, status consistent): `$18`/`$19` Eyegore, `$23` Zibzub, `$24`-`$26` Clawbot, `$2D`-`$2F` Optomon, `$40`/`$41` Fleepa, `$45` Crawdaddy, `$46` Teramute, `$47` Glider, `$48`/`$49` Grimgrin, `$4C`/`$4D` Bombarder, `$4F` It (the final boss, corridor 22) - every one a corridor boss; the manual's nine names are all placed, Glider and It are not in the manual; only Fleepa is hardware-tied. Non-boss enemies are still unnamed. The
  boss type is `$9151[corridor]` (bank 3 `$91C3`) -> `$72`, spawned by bank 3 `$92E5`; each type's
  code is its bank 6 handler (the split table at `$80DE`/`$815D`), some of which only far-call
  into bank 3 or 1. There is **no shared boss engine**: each handler is its own state machine
  on the common object fields. The primitives: `$F863` (`$C0FF`) **aims at slot 0, the player**
  (16 directions, `$F95E`); `$F8CE` turns a direction (masked `AND #$0F`) into velocity;
  `$CD12`/`$CD46` (`$C09C`/`$C09F`) accelerate y/x toward a target held in `$0668`/`$0680`,
  a spring when the target is fixed; `$A325` (and `$A337` for y) moves one pixel toward the
  player's x; `$CD7A` is an animation/phase counter whose wrap times shots; `$F9D1` random;
  `$AD9A` just toggles `$6A` bit 0; `$FA5B`/`$FA4B` find a slot and spawn. `$0518` is y,
  `$0530` is x, y/x velocity `$05D8`/`$0608`. **Who follows the player:** `$45` (corridor 2) homes
  on the player's x (`LDA $0530` into `$0680`, accel 4) and fires `$F863`-aimed shots; `$23` (5)
  homes on x (accel 8) in a jump/gravity cycle and fires aim, aim+4, aim+12; `$40`/`$41` Fleepa
  (1, 12) creep 1 px per 2 frames toward the player's x on a vertical bounce, shots
  (`$27`) a counter cycling 8-15; `$24`-`$26` (14, 15, 20) creep toward the player's x via
  `$A325`, fire 0/8 alternately; `$48`/`$49` (18, 8) hover at a fixed point, aimed pairs. **Fixed
  or random, not following:** `$18`/`$19` (9, 10) fixed x, spawns alternating +/-32 offsets;
  `$2D`-`$2F` (11, 3, 16) spring about (128, 48) from an initial kick, shots up or down by
  relative y; `$47` (6) hovers at (128, 96), fixed-direction bursts at random pauses;
  `$4F` (index 22) random-wandering arms. **Teleporters:** `$46`/`$4C`/`$4D` (4, 13, 19)
  re-pick a random position every 120-frame cycle (blink in, attack, blink out, hidden) and
  re-aim once per cycle; `$46` sweeps a fan around that aim, `$4C`/`$4D` fire 16 shots.
  Corridors 7 and 17 list type `$06` (bank 6 `$A889`, a ground object that waits for scroll
  speed 0 and dies when types `$36`/`$37`/`$7E`/`$7F` are gone): a LEAD, not read through.
  **CORRECTION - corridor 22 exists, and corridor 21 is a boss gauntlet.** The owner said "It"
  is the final boss in a mini corridor after a cutscene; the code agrees: at the end of corridor
  21 `$ECC7` far-calls bank 0, then `$ECDC` does `INC $51` and `JMP $EC94`, loading corridor 22
  (`$F28C`/`$F5FA`/`$F667` all test `$51 == $16`). `$9151[22]` = `$4F` = It; the table's 23rd
  entry was the unexplained one. Corridor 21 never reads `$9151`: `$E79F` makes command 5's
  operand the boss type (`$72`), and its stream names, at rows 58/150/220/320/410/480, Fleepa,
  Zibzub, Clawbot (`$25`), Optomon (`$2F`), Grimgrin (`$48`), Bombarder (`$4D`). Corridor 22's
  stream is bank 4 table entry 24 (`$8511`, 11 records: a short starfield, scene `$EF55[22]` =
  32, command 5 at row 100); its music would be `$EF2A[22]` = `$EF40`'s first byte (song 25) - a
  LEAD, read past the table's end. Earlier text here said "after 21 the ending" and that the
  corridors are 1-21; both were wrong. Not traced: what follows corridor 22. **Whether a bullet steers is open:** type `$27`
  (`$A0C6`) can re-aim at the player when its `$07A0` timer reaches 0; which spawners use it is
  not worked out. Direction numbering 0/4/8/12 = right/down/left/up (CORRECTED, see the main-gun entry; it was down/right/up/left) was first read from `$F95E` against
  `$F986`; which way each boss's counter-driven fan points on screen is not checked.
  Fleepa savestate: `$0668` = `$10`, `$07A0` = `$0F`, entry timer 0, y 116 at velocity ~1.9 -
  what the bounce (+4 kick, `$10/256` accel) predicts (~114).
- **The ending (traced from the code; `docs/ending.html`).** The boss routine (bank 3 `$917F`,
  phase `$70`) waits at `$92EE` for the boss object to die, then in a corridor `$9355` plays song
  `$2F`, far-calls bank 6 `$8003`, runs eight explosions and counts 90 frames; song `$1F` and the
  victory song (`$1B`) play and `$93E8` sets `$A0` bit 0. **Corridor 21 sets it only for boss
  `$4D`**; the other five gauntlet bosses just clear `$70`. Bank 7 `$E659` (every scroll step)
  tests that bit and does `JMP $EB18`; with the player alive `$EB9C` falls to `$EBFE` and, via
  `$EC54`, to `$ECBD`, which branches on `$51`: 0 `$ECE7`, 1-20 mark cleared (`$EFBA`) and run
  the stage-clear routine `$F506`, 21 far-calls bank 0 `$8012` (`$88F5`, a starfield from the
  script at `$88B7`) and bank 2 `$801B` (`$8836`, a wordless ship animation) then `INC $51`,
  22 runs `$F506` and never returns. For 0 and 22 `$F506` skips the clear song, stops the
  scroll, takes no key (`$F4A7`), then `$F5DE` flies the ship off the top. For 22 only,
  `$F667` prints YOUR FINAL SCORE (PPU `$2086`, digits `$20C8`) and far-calls bank 2 `$8021`
  -> `$8A69`: `TXS` with `$FF` (no return), `$30` cleared; a normal game loads tile block 4 of
  bank 1, blits the 10 x 13 picture `$8B05` to PPU `$21F1`, copies the 22 sprites at `$8B87`
  and the palette `$8BDF`; a TGL game (`$30` bit 1) prints CONGRATULATIONS only (`$8A3D`); song
  `$0F`; far call bank 0 `$8015` -> `$8915`: MISSION COMPLETE and the credits, then PASSWORD TGL
  after Start, then `$899F` loops forever. Reset is the only exit. Bank 3 `$9168` (boss songs,
  23 entries: 3 3 3 6 6 3 3 6 3 6 3 $16 3 6 6 $16 3 $16 3 $16 3 6 6) also ends where corridor 22
  needs it to. `$EF2A[22]` is `$EF40`'s first byte, so corridor 22 plays song `$19`. **The picture is rendered** (`tools/tgl/ending.py`, `docs/ending-picture.png`): block 4 of
  bank 1 is 109 tiles at PPU `$18F0` = tiles `$8F-$FB` of pattern table 1; the frame's tiles all fall
  in that range, so the background reads table 1 (a fit, not a read of `$2000`); fills at
  `$8A88` are `[count][hi][lo][value]` runs (`$D5CC`); the frame lands at column 17, row 15.
  Result: a framed portrait of a woman with brown hair, a planet, stars and part of a ship -
  sprites 0/1 start off screen. **The cutscene and both endings were RUN**, not
  reconstructed: `tools/tgl/cpu.py` is a 6502 + NES-memory + PPU-register harness (no cycle
  accuracy, no IRQ/audio, one scroll value per frame) that executes the ROM's own code from a
  corridor savestate; `tools/render-ending.py --state ...` writes `docs/cutscene.gif`,
  `cutscene-film.png`, `ending-normal.png`, `ending-tgl.png` (needs the owner's savestate, so
  the images are committed, not built). **TGL vs normal ending (owner's claim, CONFIRMED):**
  `$30` bit 1 is tested once, at bank 2 `$8A69`, and `$30` is cleared right after, so only that
  screen differs: normal = portrait picture + sprites + the 25 palette bytes; TGL (`$8A3D`) =
  YOUR FINAL SCORE + CONGRATULATIONS. (tile `$5B` is a full stop) on black with `$0181` = white.
  The picture rebuilt by hand from the tables equals the run's, apart from the score text. The
  scene after corridor 21 (`$8836`): a planet with an alien core, the ship approaching, a
  barrage of explosions (backdrop flashing `$32`), the planet's tiles erased in a shuffled order
  (`$88AE`), the ship flying off. A harness lesson: the vblank flag must stay set ~2,273
  cycles or `$EDF4` hangs; `$F506` is not a subroutine that returns in every case, so runs
  start at `$ECCA`/`$F66B`. NOT established: any of this against hardware.
- **Static bosses made of the stage (owner's names; `docs/enemies.html#stage-bosses`).** The
  boss of corridor 0 is the **Defense System**, of corridors 7 and 17 the **Eyeball Growth** -
  exactly the three corridors whose `$9151` entry is `$06`. Type `$06` (bank 6 `$A889`) is an
  invisible controller: it waits for the scroll to stop (`$B8`/`$B9` = 0), counts live objects of
  types `$36`, `$37` (handler `$A8D8`, the cannons: animate by patching background tiles
  through `$AA21`, fire an aimed type `$2B` at phase 3) and `$7E`, `$7F` (handler `$B851`, the
  eyes: fire type `$27`/`$4E` aimed with `$F863` at `$07B8` + a random 0-31 frames; hit points x4
  once `$70` is set) and dies when none is left. The parts are ground objects spawned from the
  stage's own metatiles (`$89FB`: fifth byte high nibble -> the set's `$803C` list). **Rendered by
  running the real corridors**: `tools/tgl/bossrun.py` / `tools/render-bosses.py` load a corridor
  with `$EC94` called as a subroutine from a corridor savestate (return address = the savestate's
  own PC), keep `$0590`, `$47` and lives `$6B` topped up and capture 60 frames after `$70` = 4:
  `docs/boss-0.png`, `-7`, `-17` (+ `boss-objects.json`). Harness fixes this needed
  (`tools/tgl/cpu.py`): sprite-0 hit at the beam's cycle for OAM[0] (the raster-split wait at
  `$DAB6` spins on `$2002` bit 6), scroll writes logged by cycle so the HUD split renders, and the
  NMI handler's own `$2002` read must not clear the vblank flag a main-code wait is polling
  (`$EDF4` hung on it); for corridor 0 the run must start with bank 5 live, because `$F282` returns from its `$F290` branch without switching banks and `$EF6C` then calls `$8000` in the wrong bank, so the scene was never loaded (the first corridor 0 capture had corridor 15's tiles and sets, and spawned `$7D` instead of `$36`/`$37` - an artefact, now fixed). A corridor start runs a ~300-frame launch scene (`$F336`-`$F439`). The live corridor 0 frame matches the stage simulation (`docs/stage-00.png`) layout; 15 cannon objects `$36`/`$37` and the `$06` controller are alive at the capture. The eyes and cannons are never drawn as sprites: the sprites-only frames are empty.
- **The score bonus is a threshold counter, not a table (owner's example 500,000: CONFIRMED; `docs/status.html#score-bonus`).**
  Bank 7 `$DF3D` (after every score add, `$DFB1`) compares the top three score digits `$0170-$0172`
  (tens-scale: `$0172` = 10,000) with `$017C-$017E`; at or above it, `$DF8C` plays song `$31` and
  `$DFA1` adds 8 to max life `$47` (cap `$FF`), sets `$48` = `$47` and redraws the HUD. Bank 0
  `$80A5-$80B3` starts the threshold at (0,0,3); `$DF3D` steps it (0,0,3) -> (0,1,0) -> (0,5,0) ->
  (1,0,0) -> +1 in `$017C`: **30,000, 100,000, 500,000, then every 1,000,000.** Verified by calling
  the real routine at chosen scores on the harness. The same "+8 max life" is the Energy Tank item
  (`$86BC`, effect 13 - see the weapons entry; icon 12). No awards in a demo; an overflow (all 9s)
  sets `$017C` = `$FF` and stops them. In `annotations/external.json` as `score-bonus`.
- **Item boxes from defeated enemies (`docs/enemies.html#item-boxes`): a weighted kill counter, not
  chance.** The explosion handler (bank 6 `$975F`, type `$88` = `$08` initialised, original type in
  `$0740`) far-calls bank 1 `$8176`. `$823D[type]` is the kill's weight (0 = does not count; the table
  runs to type `$77`, bank 1's boss code starts at `$82B5`); `$43` counts up by the weight but stops
  the moment it equals `$8219[$42]` = 50, 80, 100, 140, 180, 220, 230, 256 (`$00` = wrap), leftover
  weight lost. Then the explosion becomes a box (`$0788`++): in the labyrinth only if the cell under it
  is free (bank 6 `$8435` reads the cell map at `$0400`, `$822D[cell]`; blocked -> `$43` back one), in a
  corridor always. `$42` steps on and wraps after the 8th; `$42`-`$44` are cleared only at game start
  (bank 0 `$8070-$8074`). Contents `$8221[$42]` = `$14 $15 $16 $14 $14 $15 $15`, step 8 rotates
  `$8229[$44 AND 3]` = `$15 $0C $0C $0B` (`$0B` becomes `$0C` unless `$04AE` bit 6, the Eraser,
  is set). Pick-up (bank 2 `$86BC`): `$14` +40 life; `$15` +500 chips +16 life; `$16` +10 chips +8
  life; `$0C` full life; `$0B` +16 life, +20 Eraser uses, sets `$04AE` bit 6. (Life is added by
  `$FD67`, chips by `$FCE7` capped at CHIP MAX; both read from the code.) **Verified by running the real
  routines on the harness**: drops at exactly 50/80/100/140/180/220/230/256 weight-1 kills, repeating at
  306...; the pick-up effects from life 32. Same sweep resolved `$6B` = fire-rate level (not lives:
  Consecutive Firing +1, cap 5, `$87CE[$6B]` -> `$39` shot delay) and `$46` = chip capacity level
  (`$87D4` table -> CHIP MAX). How the box is opened: RUN in the labyrinth - the ship's shots open it, touching it before that does nothing, touching it after collects the item (see the `$56` entry; a corridor box was not tried). NOT established: the cell-category table `$822D` beyond what blocks.
- **The main gun by chip tier (`docs/status.html#gun`).** Bank 7 `$E213` (after every change of the
  chip total: spend `$8B8F`, pick-up `$FCE7`) sets `$3A` = 0 under 100 chips, 1 at 100, 2 at 200, 3 at
  2,048. The player's handler (bank 3 `$8E04`) makes a type-`$02` object while B is held (`$33` counts
  down from `$39`, slots 1 to `$3B`); its handler (bank 6 `$8490`) stores `$847C[$3A]` = `$81 $43 $82
  $83` in `$0698`, the speed class `$F8CE` reads (3.75, 5.62, 7.5, 11.25 px/frame, fixed at firing) and
  alternates the metasprite every frame from `$8480`/`$8488` + `$3A`: tier 0 one pellet, tiers 1-3 a
  twin 8/16/32 px apart on alternate frames; hit box = the metasprite's. Damage does not depend on
  chips; the gun does not spend them. Run on the harness (which now has a held pad,
  `Machine.pad`; `tools/render-gun.py` needs the ingame savestate, image committed). **CORRECTION:**
  direction numbers 0/4/8/12 are right/down/left/up, not down/right/up/left (`$F8CE` run; the
  player's shot is 12 = up) - fixed in boss.py and the Enemies page; whether the bosses' own
  fans point as described there was never checked on screen.
- **The A-button weapons (`docs/status.html#subweapons`).** Bank 3 `$8E3C`: weapon selected (`$3C`) and A held
  -> a type-`$03` object in every free slot from `$3B`+1 to 4 (`$3B` = `$FDCA[$3C]`: 3, so slot 4 only; 2 for Back
  Fire, Area Blaster, Cutter Laser = two objects). Bank 6 `$866B` first frame: needs `$3E` > 0; tables `$8701`
  attack (0 = the gun's), `$8722` durability (0 = never wears out: `$FF` put back each frame), `$8743` `$0698`,
  `$8764` flags, `$8784` sprite, `$878F` palette, `$879A` sound (bit 7 = pay `$45` chips at once: Grenade,
  Fireball, Repeller); every other weapon pays when `$3F` hits 0 (60 frames, 120 for two objects), and is removed
  when `$3E` = 0. Per weapon (init table `$86E7`, run table `$8653`, index `$3C`): 1 straight shot, 2 two shots at
  facing +5/+11, 3 very fast shot steered by `$32` (D-pad cell, corridor), 4 orbiter, 5 lobbed burst (no hit box
  in flight), 6 slow fireball, 7 two homing missiles (next live enemy in slot order, turn every 8/4/1 frames),
  8 spinner, 9 beam (corridor only: `$30` bit 6; attack overwritten to 1 by `$FDF8`), 10/11 blades while A held
  (attack = gun x 2/4/8), 12 Eraser (`$8B9F`: every slot >= 5 with `$0578` bit 6 clear becomes type 8, one use of
  `$04AF`). Collision: an enemy test hits a player-side object only if `$0578 AND mask` is non-zero; ordinary
  enemies `$30`, the stage's fixed targets (`$36`/`$37`, `$7E`/`$7F`...) `$C0CF` = `$20` only. Run: every weapon x
  level on the harness, homing against real enemies, Eraser, Hyper Laser with bit 6 clear; `tools/render-subweapons.py`
  (needs the ingame savestate; image committed). **CORRECTION to the gun entry and the earlier harness runs:** the
  ingame savestate is a DEMO frame (`$30` bit 7), whose input overwrites the pad; the first gun run only worked
  because the demo holds A+B. The tools now clear the bit (the gun picture is unchanged). NOT established: the
  labyrinth shapes (only a corridor was run), the Wave Attack's steering, what the weapons do to cells
  (`$8513`/`$8523`), flag bits 2 and 3, whether Eraser kills count for item boxes.
- **What weapons do to labyrinth cells (`docs/labyrinth.html#cells`).** Bank 5 `$8354` builds `$0400-$045F`: 16 x 12
  nibbles, one *cell class* per 16 x 16 cell, from the room buffer through `$838E`/`$83A5` (set-0 id < `$20` ->
  1:8 2:7 3:6 4:5 5:1 6:4 7:4 8:10 9:9 10:0 11:2 12:14 13:0; sets 1-4 -> 0; sets 5-7 -> 9). A weapon's hit-box
  centre is looked up every frame (bank 6 `$84E7`/`$8443`; always class 0 in a corridor, `$30` bit 6); classes
  5-10 and 14 (`$8513`) run `$8523`, and any such hit costs the shot 8 hit points. Class 8/7 step down (sound
  `$20`), 6 -> floor `$1C-$1F` + a type-`$30` blast, 5 -> blue sphere `$28-$2B` (class 1) + blast, 9/14 solid, 10 = a
  key door's cover: the high nibble of `$58-$5B` (set to 3 by `$ED44` when a room loads) counts four hits, then warp
  ring `$00-$03` (class 2; bracket tiles `$04-$07` if an earlier door needs another key - purpose unknown). Ship side
  (bank 3): class 1 = +20 chips +2 life, class 2 = the warp panel, leaves with key 0 or `$04B0` bit k-1; `$8425`
  = classes that stop the ship (4-10, 14). Dialogue: "blast through the cover ... need the key for the panel".
  Hyper Laser and the grenade in flight never test cells; fast shots can skip a cell. Run: `$8523` per class on the
  labyrinth savestate, the gun and every weapon at the savestate room's rocks, the sphere pick-up. `tools/render-
  cells.py --state` (ring/bracket tiles come from live CHR, source of tiles `$00-$0F` not found). NOT established:
  the bracket's purpose, classes 3/11-13/15, `$0777/$07B2/$07BD/$07E7`.
  **Respawn (resolved): destroyed blocks come back whenever the room is loaded** - nothing stores them. A room entry
  (`$EB18` -> `$EBA5`, or `$EEE0`/`$EE1D`) rebuilds from the ROM: `$8015` record, `$8003` (`$8155`) buffer, `$8006`
  (`$8354`) cell map; run: walked out of the north exit and back, all rocks returned (also one the owner had broken before
  saving); the status screen and pause change nothing. Death does not reload the room: the fatal hit needs `$49` (life
  meter shown value, steps toward `$48`) = 0, bank 6 `$8239` then enters bank 0 `$81DD` (GAME OVER, then CONTINUE PUSH
  START, `$2F` = 2, then `$FF5D` the game start; for where CONTINUE puts you see the start-mode entry) - a restart. `$2E` is always 0 (only cleared). Corridor-return path read, not run.
- **The last four RAM leads (all settled; ram.json has no `lead` entries now).** **Sprite allocator `$80-$83`** (bank 7 `$CDA2-$CF05`, RUN on the calm and
  boss savestates): a two-ended fill of OAM - `$83` bit 0 = this frame's direction (0 upward from offset 4, 1 downward from `$FC`; offset 0 is sprite 0, never touched);
  `$80` next offset; `$82` the end of the last upward block, `$81` the start of the last downward one (the hiding loop `$CE88` clears the stale sprites between);
  bit 1 full, bit 7 wrapped (both cleared each frame at `$CDB4`); bit 2 set once at start-up (bank 6 `$8057` stores 4) and never cleared. **CORRECTION:** the Game loop page
  said `$83` is flipped at every frame's finish. It flips (`$CEFE`) only when the frame ran out of OAM or the PPU's sprite-overflow flag (`$26` bit 5) was set: calm = never
  (`$83` = `$04` throughout), boss fight (63-64 sprites) = every frame (`$84-$87`; `$81` walks `$FC, $F4, $F0, $EC`). **`$0318`**: a sticky OR of the channels' control
  bytes, cleared only by the silence routine; its only reader tests bit 5, which no song header (values 0-4, 6) or stream command (`$88` writes fields 16 and 17 only) ever sets
  - that branch (`$03E4 |= $40`) is dead; the old 'a channel muted all' was a guess. **`$5F`**: written once at game start and read nowhere - a whole-ROM byte scan finds one real
  instruction touching it (51 pairs, 50 inside data or operands, none through `($5E),Y`). **`$56`** is the id of the pickup box (type `$31`) that is currently OPEN, `$FF` none:
  the ship's shots open a box (the handler stores the item id and uploads its icon, `$85BA` / `$81B2`), touching it adds the item and releases `$56` (run: item 6 = weapon 6 gained,
  `$04AD` `0x40000` -> `0x41000`, box removed, `$56` back to `$FF`); the shop's type-`$33` items never touch it (CORRECTION: it was recorded as 'shop_item_standing'). So a box is
  opened by SHOOTING it and collected by touching - this settles 'how the box is opened' for the labyrinth (a corridor box was not tried).
- **Start modes and CONTINUE (`$2F`, `$7C/$7D`, `$78`; RUN on the model, `$805B` called with each mode).** `$2F` is set by the title menu (0 new game /
  1 second item, which boot `$FF53` sends to bank 3's password screen), by Start on "CONTINUE PUSH START" (2, `$82A6`; chips topped to `$FA` if lower) and by the
  progress recorder (3, `$A2E4`); a new game (`$EB18`) re-inits the move history only if it is below 3. The start-up code `$805B`: mode 0 = full new-game init (`$80D4`,
  position (11, 12) into `$52/$53` and `$7C/$7D`); **mode 2 in a normal game jumps to `$80C8`: `$52/$53` := `$7C/$7D` (the last progress record) and nothing else changes - score,
  items, keys and the corridor seals `$04B1/$04B2` all kept. Mode 2 in a TGL game: `$47` := `$78`, score cleared, seals cleared. Modes 1 and 3: `$04B1/$04B2` and the bonus
  threshold cleared** (the seals are not in the password), position from `$7C/$7D` (the password decode and the progress recorder write it). Resolves "where CONTINUE puts you".
  Also settled from the RAM leads (14 of 18 now confirmed, see ram.json): `$17F` palette upload 1/2/3 = BG / sprite / both (run), `$20` = pending queue entries, `$60` bit 1 = script
  running, bit 3 = spawning stopped, `$6C-$6F` = the movement test (`$6D` y-step cell, `$6E` x-step cell, `$6F` bits 7/6 = same row/column), `$0199` = attribute patterns (CORRECTION:
  not 'palette slot indices'). (The last four, `$56`, `$5F`, `$80-$83`, `$0318`, are settled in the entry below.)
- **The corridor start and its launch flight, bank 7 `$F282-$F46E` (`annotations/regions/26-corridor-launch.json`, 15 regions; the 'corridor start' task).**
  Entered by `JSR $EC99` from the corridor loader (`$EC8C` has just read the map record, so **bank 5 is live**). `$EDD1` FADES to black (target palette `$04D0-$04E7` + `$0180` = `$0F`, `$EDBD`
  steps `$D950` every 2 frames: 8 frames), rendering off. **Corridors 0 and 22 and EVERY TGL corridor take `$F290`: no flight** (load the ship's sprite sheet, bank 2 block 5 -> PPU `$0000`, sprite 0 y `$BF`, to `$F452`).
  Corridors 1-21 of a normal game: `$50` = the corridor folded onto 1-10 (`$F2A0`, 11-20 -> 1-10, 21 -> 10), sound `$1D`, `$0680` := A (**the MODE: 0 take-off; 1 landing, entered from the stage-clear code
  at `$F6BE` with A = 1 jumping to `$F2BB`**), `$30 |= $48`, bank 5 `$8000` with A = 0 and `$20` (the common scenes 0 and 32: a BLUE PANEL TUNNEL, the same for every corridor), wait,
  then bank 4's entry with A = `$FF` -> table entry 1 = **`$81ED`, the flight's screen-data block** (speed `$0600` at once = 6 px a frame, row table, palette list, overlays, no waves); `$FE` ->
  entry 0 = `$826D` only for mode 1 AND corridor 21 (sound `$2D`) - **CORRECTION: reached**, see the stage-clear entry (1,061-frame landing). The parser's 'area -2/-1' are these. **Ship:** slot 0 = type `$05`, x `$80`, mode 0: y `$30`,
  velocity +0.5 px a frame; mode 1: y `$C8`, -0.25. **Loop `$F33E`:** `$E66A` (scroll step + speed ramp), `$CDB4`, per-mode motion, `$CBE8` draws the ship, the exhaust flame (metasprite `$1D`, tile base
  `$32`/`$34` by `$41` bit 1) while rising, `$CE88`, `$F493` pads (a NEW Select opens the status screen even here), wait 1 frame. **Phase `$0638`** (`$CD7A`; steps `$30`/`$60` in mode 0, `$80`/`$60` in
  mode 1) picks the pose: mode 0: id 22 for phases 0-9, 22 -> 14 (`$F46F`) for 10-18, 4 3 2 for 19-21, then `$F47B[(phase-10) mod 12]` = 1 2 3 4 5 6 7 6 5 4 3 2 with attribute `$F487`, pose 1 from `$46`; thrust
  `$0788` = `$20` from phase `$40` (accelerates up through `$CD12`); mode 1 mirrors it (cycle for phases < `$60`; 1 2 3 4 then 14 ... 21 for `$60`-`$6B`; 22 from `$6C`; thrust 8). `$F9AE` is an 8-bit
  division (Y mod A). **The scene ends when the ship leaves the top (`$CBE8` carry): 318 frames in mode 0 (frames 26-344), then `$F717`/`$F705` load more sprite tiles and the routine returns to `$EC9C` -> `$EF6C`.**
  **Select HELD from before the scene starts exits at the first pass** (`$F7` bit 5, frame 26 in the run) - a hidden skip; a Select TAP opens the status screen. Mode 1's tail (`$F458`): `$30` bits 3-4 off,
  slot 0's hit-box x bytes zeroed, the labyrinth ship's sprite sheet (block 4) unless TGL. **Harness lesson (cost me a wrong result):** `JSR $8000` goes to the LIVE bank, so a corridor start run from a
  savestate must set bank 5 (as `$EC8C` does) - with the savestate's bank 6 the call far-called the ship's handler, bumped `$0680` (slot 0 field 16 = the mode!) and made every start look like mode 1; the
  full sweep (corridors 0-22, normal and TGL) with bank 5: `$0680` = 0 and the ship at y 48 for all of 1-21. Run on the model, not hardware; the corridor-21 landing and `$F717`/`$F705` are not read through.
- **The stage engine's front half, bank 7 `$E424-$E6F2` (`annotations/regions/27-stage-engine.json`, 22 regions; the 'continue exploring' task).** **CORRECTION found on the way:
  the score bonus ALSO REFILLS THE CHIPS.** `$DF8C` (score bonus, and the Energy Tank item 13 that calls it) copies CHIP MAX `$4E/$4F` into `$4C/$4D` and adds 0 through `$FCE7` (which clamps,
  redraws the counter and re-derives the gun tier), THEN adds 8 to max life; RUN: chips 10, max 500 -> 500. The Status page, `external.json` `score-bonus`, and `$4E` in ram.json say so now.
  **`$E445` (slot `$C018`) clears a nametable** (A = `$20` or `$24`, 30 rows of tile `$20`); **`$E453` (slot `$C084`) clears rows `$17`..`$16`-1** with fill `$14` and page `$15` (used for the first row's address only), and
  past row 29 it WRAPS to row 0 of the same table through the `$2800`/`$2C00` alias (the status screen clears rows 28, 29, 0-23); the queue only holds ~7 rows, so a whole table takes 15 frames. **`$E498`** = the 2-bit level
  of weapon A (0-11) from `$04AC-$04AE`. **Pause/status `$E4B3`:** Start = sound `$46`, wait for a NEW Start/Select, Start -> sound `$47` + 30 frames; Select (also from play) = `$46`, then `$E4EE`: sound `$3E`, bank 5
  `$801B` open, `$8021` per frame, `$801E` close, one bank 6 `$8000` (object loop) pass, `$47`, 30 frames (RUN, scripted pads). **Stage engine:** `$E530` scroll step (`$B7` = `$B9` + the borrow of `$B6 -= $B8`; `$A6 -= $B7`,
  wrap at 240 flips `$A7`); `$E560` start-up (speed 0, `$B0/$B1` = trigger - 1, `$AF` = `$0F`, `$AE` = `$0D`, `$AB` = 1, overlay slots `$0400-$0407` = `$80`, default target `$0200`); **`$E5BD` primes 15 rows** at 16 px a frame
  before a corridor scrolls (RUN: 15 passes); `$E5EB` waits for queue room and no half-sent row, `$E605` drains the queue from the main thread only while rendering is off (turning the NMI off for a moment, `$D7AA`),
  `$E619` appends a pending second tile row (`$A5` = 2) to the queue directly when the offset is under `$0E`; `$E655` stage step -> `$E66A` speed ramp +-2/256 per frame toward `$BA/$BB` -> `$E69B` `$AF` += `$B7` -> every 16 px
  `$E6AC` (queue room, `$B0/$B1`++, `$EACC` address, `$AB` adds 8 to `$AD`) -> bank 4 -> `$E6CE` trigger compare -> `$E6EB` dispatch (`$D6AE`, ten commands), else `$E8AB` builds the row; handlers return to `$E6CE` with Y = bytes consumed.
  NOT established: why the status screen's close calls one object-loop pass (lead), sound ids `$46 $47 $3E`, hardware.
- **The stage engine's back half, bank 7 `$E707-$EAE1` (`annotations/regions/28-stream-commands.json`, 25 regions).** The ten bank 4 stream commands, one region each: **0** `$E707` speed target (`$BA/$BB`; high-byte bit 7 =
  also set the speed `$B8/$B9` at once); **1** `$E721` row table `$B4/$B5`, `$A1` = 0; **2** `$E733` low two bits -> `$60`, bit 1 adds a bank 4 wave script (`$66/$67`, `$68 = $69 = 1`, `$7F = 4`); **3** `$E760` jump,
  and **it REBASES THE STAGE CLOCK**: the target block's first trigger goes into `$B2/$B3` AND the row counter `$B0/$B1`, so its first record fires on the same row (RUN: the launch flight's block loops with it every ~50 frames);
  **4** `$E78A` palette list -> `$D92D`; **5** `$E79F` `$70` = 1 (boss phase; one operand = boss type `$72` in corridor 21 only); **6** `$E7B6` overlay placement (flag byte: bits 0-2 slot, 7 no delay/gap, 6 no step, 5 single
  showing - its stored gap `$20` is never used -, 4 inline structure; then delay, gap, step, repeats, column, structure pointer or inline [ptr][w][h]); **7** `$E85E` art stream `$28/$29`, `$27` = `$80`, bank `$7E` = 4;
  **8** `$E881` attribute patterns `$0199+` (occurs in no block); **9** `$E893` the jump only when `$70` is set. All end at `$E89D` (next trigger -> `$B2/$B3`, back to `$E6CE` with Y = bytes used). **Row builder:** `$E8AB` strip
  row `$A1` -> `$04C0`; `$E8E1` the eight overlay slots (state `$0400,X` = column, `$80` free; delay `$0430`, gap `$0408`, step `$0438`, repeats `$0410`, width `$0420`, height `$0418`, rows left `$0428`, pointers
  `$0440/$0448` start and `$0450/$0458` working) draw a row each with codes `$00 n` / `$01` / id; off-edge (`$20-$EF`) or repeats exhausted frees the slot; `$E974` bank 5 `$8009` (-> `$83B3`) and `$802A` (-> `$89FB`),
  `$A5` = 1, `$AE` 14..0 with `$AB` toggled; `$E995` loader + spawn script. **Art-load stream (`$E99F`):** `$27` state (0 idle, bit 7 start); a record is evicted/started first (slot's old block cleared, objects using it
  turn to `$28`), decompressed (block < `$40` from bank 3, else bank 2 with id - `$30`), and only THEN written into `$0480/$0490`; a block-0 record is 2 bytes (evict only), bit 7 of byte 0 ends. **Allocator `$EA8C`
  (slot `$C027`): highest free slot 23 -> 5 first; if full, the LOWEST slot of type `$0B/$0C/$0D`, else the highest slot with type bit 7 and `$0578` bit 1 clear, else carry set** (RUN, 8 cases). `$EA68` removes objects 1-23.
  Not established: what types `$0B-$0D` are; the stream-engine detail beyond what `corridor.simulate` already matches on a savestate.
- **Stage clear, bank 7 `$F493-$F771` (`annotations/regions/29-stage-clear.json`, 25 regions; the '`$F506`' task).** `$F493` (slot `$C16B`): pads, then the pause (`$E4B3`) or, in a demo, a new Start leaves it (`$FF4A`).
  **`$F506` STAGE CLEAR**, called from `$ECBD` (corridor 21 `$ECC7`, 22 `$ECE1`, 0-20 `$ECE7`): sound `$17` (not in corridors 0/22), bank 6, `$60` low bits and `$A0` bit 0 cleared, then **the scroll is run down to a stop** (target 0, `$E66A` -2/256 a
  frame, one whole game-loop pass `$FF8B` each frame, so the fight goes on): speed/2 frames (19 in corridor 4, 1,264 in corridor 0). `$EA68` clears objects 1-23. **Key** (not TGL; `$F4A7`: corridors 1-10 = 1 2 3 4 0 5 0 6 7 0, else none): bit k-1 into `$04B0`, sound `$36`,
  the icon built at CHR `$15C0` (bank 2 slot `$8006`), a black 10 x 3 panel of metatile `$20` painted through `$FAB7` at x `$30-$C0`, y `$40-$60`, the icon cell `$5C`, text ' YOU GOT KEY', then 40 game-loop passes (RUN, picture checked). **The ship leaves (`$F5DE`):**
  slot 0 = type 5; normal corridors: phase 0 climbs at 2 px/frame off the top (85 frames from y 160), then phase 1 re-enters from the top and DIVES (thrust `$20` toward target `$0668` = `$FE`, off the bottom 57 frames later); corridors 0 and 22: phase 1
  at once, target 0, climbs off the top (51 frames). Then: corridor 0 and every TGL corridor: `$0680` = 1, fade, `$F43C` (no landing flight); **corridor 22: the final score screen** (fade, sprites hidden, sound `$1F`, nametable 0 blanked, 'YOUR FINAL SCORE', six digits via `$E118`
  at `$20C8` + a fixed '0', then bank 2 `$8021` = the ending, no return); others: fade, bank 5, A = 1, `JMP $F2BB` = the **landing flight** (352 frames; its RTS returns to the caller of `$F506`). **CORRECTION: corridor 21's clear reaches the landing too**, with sound `$2D` and
  bank 4 entry 0 (`$826D`): a landing 1,061 frames long (RUN) - the launch-flight entry called it unreached. `$F4B7` (from `$EC4C`, special screen type 5 = the cleared gate): a scripted type-`$81` ship entrance, loops until `$07E8` = 0 (420 frames in a corridor
  savestate; its real context and meaning are a LEAD). Sprite loaders: `$F6E5` bank 2 block 5 -> `$0000` (corridor ship), `$F6F5` block 4 (labyrinth ship), `$F705` block `$0C` -> `$0740`, **`$F717` the selected weapon's sprite tiles**: block 6 -> `$0680` always, then per weapon/level
  (RUN, all 13 x 4): MultiBullets/Bullet Shield/Repeller block 7 at `$0760` (level 3: block `$0A` at `$0780`), Fireball the same from level 2, Back Fire/Wave Attack `$0B`, Grenade `$0A@0780` + 8, Hyper Laser `$1E/$1F/$20` for levels 1-3, Eraser nothing. NOT established: the sound
  ids, what the type-`$81` ship does, hardware.
- **The spawn-script interpreter, bank 7 `$F78F-$F85C` (`annotations/regions/30-spawn-interpreter.json`, 12 regions; RUN with synthetic scripts through the real routine).** Called from `$E998` once per stage step; `$7F` = the script's bank
  (5 labyrinth, 4 corridor waves), `$66/$67` pointer, `$68` wait, `$60` bit 1 running / bit 3 spawning stopped. **Tick:** labyrinth or a stopped corridor = every 60 calls (`$69`); a scrolling corridor = every new row (`$A0` bit 2). A wait or delay of N = N ticks
  (**wait 0 = 256 ticks**). Items: 0 wait, 1 jump (**the next item is fetched in the same tick**), 2 end; >= 3 a spawn: plain = type only, in the LOWEST free slot from 5 (`$FA5B`, no reclaim); bit 7 = a formation, in `$EA8C`'s slot (HIGHEST free, reclaiming), stored as a type-`$29`
  spawner (`$0548` = the formation's type, `$0560` count, `$07A0` interval). The byte after a spawn is its DELAY unless it has bit 7 (then the next spawn, same tick); **delay 0 = skip the next byte and go on in the same tick**
  (no bank 5 script has one, one bank 4 script does). With spawning stopped (`$60` bit 3) or no slot, the item is dropped but its operands are skipped and the delay is kept. NOT established: hardware.
- **Aiming and direction-to-velocity, bank 7 `$F85D-$F9D0` (`annotations/regions/31-aiming.json`, 17 regions; RUN on the harness).** **`$F863` (slot `$C0FF`) = the direction from object X to slot Y (0, the player), 0-15 in 22.5-degree steps: 0 right, 4 down, 8 left, 12 up.**
  |dy| (flag 4 = target above) and |dx| (flag 8 = target left) from the objects' `$0518`/`$0530` (top-left, not centres), zero -> 1, the larger first (flag `$10` = more horizontal), ratio = smaller x 256 / larger by `$F9B6`, compared with `$F95B` `$AB $6A $32`
  (tan 33.75/22.5/11.25 x 256) -> step Y 3..0, index flags + Y into the 32-byte table `$F95E`. Out: A = direction, X kept, **Y = the table index (not preserved)**. RUN: 16 directions at every 22.5 degrees, a 910-point grid equal to an independent model, 529 offsets equal to nearest-of-16 by atan2, on top
  of the shooter -> 2. **`$F8CE` (slot `$C102`) direction -> velocity** (`$F85D`/slot `$C0FC` = aim then this): vector 120 x sin/cos from the table `$F986` (CORRECTION: it was 'an 8-byte table, meaning not established' + a 32-byte lead; it is a 32-entry sine, peak `$78`, plus the first 8 repeated so cosine = +8), scaled by
  `$0698` (bit 7 x8, bit 6 x4, low six bits = a multiplier added that many times; **count 0 leaves the velocity unchanged**): speed = 120 x scale x count / 256 px/frame - `$81` 3.75, `$43` 5.62, `$82` 7.5, `$83` 11.25, `$C1` 15, `$01` 0.47. `$F97E`/`$F982` (slots `$C0F6`/`$C0F9`) sine/cosine lookups, used by the
  orbiting weapon (bank 6 `$88A0`). `$F9AE` (slot `$C10B`): A = divisor, Y = dividend -> A quotient, Y remainder (8-bit); `$F9B6` the aiming ratio entry (Y x 256 / A; Y = A gives 255). The two aiming tables moved from `74-small-tables.json` into this file.
- **Drawing a room and one row band, bank 7 `$EFF3-$F099` (`annotations/regions/32-draw-room.json`, 15 regions; RUN from the labyrinth savestate).** **`$EFF3` draws a whole room** into the nametable whose high byte is in A (`$20` / `$24`): 13 bands, each = wait for queue room (`$E5EB`) + `$F03D`
  + (nametable 0 ONLY) bank 5 `$802A` = spawn the ground objects the band's metatiles name - so **a room's objects appear once, from the NT0 draw; the NT1 draw before a scroll spawns nothing** - then, for NT0, three fills blank rows 25-29 (`$2320` x32, `$2340` x64, `$2380` x64). **`$F03D` one band:** `$EACC` address, `$AD` OR `$17`;
  `$16` = the room-buffer offset (`$0740` + 16 a band): `$C0` = the BLANK ROW 24 (tiles `$20`, column 0 = `$FE` the solid split marker, the eight attribute bytes `$04E8` ANDed with `$10` = 0 for an even band index / `$0F` for odd, ids zeroed, `$A5` = 3); else copy 16 ids to `$04C0`, bank 5 `$8009` (-> `$83B3`) draws them,
  `$A5` = 1. RUN: 13 calls, `$16` 0..192; **with the room buffer rebuilt by bank 5 `$8003` the redraw matched the savestate's nametable 191/192 cells (the odd one under an object) and ALL 64 attribute bytes**; **the room buffer `$0740-$07FF` shares its page with the object fields, so it is garbage once play has begun** - a redraw from the stale buffer
  changed all 192 cells (the first test gave exactly that; the room-change scrolls redraw straight after a load, when it is fresh). Also: the harness must have bank 5 live for `$8009`/`$802A` (bank 6 gave wrong tiles and a clobbered `$16`). NOT established: hardware.
- **The random number, bank 7 `$F9D1-$FA4A` (`annotations/regions/33-random.json`, 3 regions; RUN).** **`$F9D1` (slot `$C0EA`) is not a generator with its own period; it is stirred by machine state:** A = ROL A (carry in), + `$2A`, EOR the byte at `$8000` + X (the LIVE bank's ROM), + `$0400,Y`, EOR `$0200` + the stack pointer, + `$2A`, - `$41` (frame counter) -> A and `$2A`; X, Y kept
  (the DMC IRQ stirs `$2A` too, `$DCE8`). RUN: 0 differences in 400 random states against a Python model; 3,000 frames of play gave all 256 values, a flat histogram. So **its result depends on the caller's A, carry, X, Y, bank and stack depth** - the same `$2A` gives different numbers from different callers. **`$F9E9`** (slot `$C0F0`) random x 32-223, y = 8 (enemies entering from the top);
  **`$FA17`** (slot `$C0F3`) random x 32-223, y 40-183 (Y clobbered). NOT established: behaviour on hardware (IRQ stirring), whether the demo's replay depends on this.
- **Beginning play, the key-door pictures and the fades, bank 7 `$ED1D-$EE14` (`annotations/regions/35-play-start-fades.json`, 15 regions; RUN).** **`$ED1D`** (jumped to by the room/corridor loaders, A = 0 or `$80`): A is stored in `$0578` and bit 7 plays sound `$3C` in the labyrinth only; slot 0 := type 1,
  `$0788` = `$40`, `$A0` bits 0-1 cleared, `$E15F` HUD labels, bank 6. **`$ED44` (room load): the key-door pictures.** The four exit bytes `$58-$5B` get high nibble 3 (cover hits; low nibble = key, 8 = no door); then bank 2's key-icon builder (`$8212`) is called for the FIRST exit whose key is not 8 -> background tiles `$00-$03`
  (PPU `$1000`), and for the first exit with a DIFFERENT key -> tiles `$04-$07` (`$1040`): at most two keys per room get a picture (RUN: `(4,5,3,8)` built 4 and 5, not 3; the CHR equals the icon built for that key alone). **This answers "source of tiles `$00-$07` not found"** in the cells entry: the ring/bracket are the key icons (the high plane is shared,
  the generic picture in a room with no key door has the same high plane) - an inference, not checked on screen. **Fades:** `$D950` steps the 24 palette bytes `$0181-$0198` toward `$04D0-$04E7` (equal: left; at `$0F`: jump to the target hue at its darkest; same hue and below the target: +`$10`; otherwise -`$10`, borrow -> `$0F`), `$EDBD` loops it every 2 frames (all at once if the NMI is off): **fade OUT `$EDD1`
  (slot `$C0ED`) = target `$0F`, 5 steps, 8 frames, then rendering off** (RUN); **fade IN `$ED98`** = save the live palette as the target, black it (`$EDA1`), switch on (`$EDE8`: DMC rate `$87`, `$EDF4` vblank sync, NMI on, 2 frames, rendering on), then the same loop (RUN: 5 steps, palette restored); `$EDB7` is the fade-in without the switch-on; `$EE09` loads the attribute patterns `$0199+` from `$EE15` (`00 55 AA FF` twice).
- **THE TRANSITION DISPATCHER, bank 7 `$EB08-$ED07` (`annotations/regions/36-transitions.json`, 35 regions; RUN through the real `$EB18`).** **`$EB18`** (JMP from the stage step `$E663` when `$A0` bit 0 is set, and at game start) does not return until the next room/corridor is up and begun (`$ED1D`). **Slot 0 type 0 = START OF A GAME:** `$E15F`, move history `$04F0-$04F9` := 4 if `$2F` < 3, `$2F` := 0, ship placed (`$EB08`: x `$78`, y `$90`, facing 4),
  `$A4` := 4, bank 5 `$802D` (-> `$8071`: applies the exit `$A4` to ($52,$53), 4 = no move, and builds the neighbour record pointers `$E0-$E8`, `$E4` = the room itself); `$30` bit 5 (CONTINUE/password into the labyrinth) -> labyrinth ship sprites, then the record at `$E4`: special (byte 0 bit 7) `$EC23` / ordinary `$EC76`; else **corridor 0** (`$51` = 0; a demo: random 0-15) via `$EC94`; TGL always the corridor. **Ship alive = a transition:** the exit `$A4` (0 N, 2 W, 6 E, 8 S, 4 into a corridor) is shifted into the move history (not 4);
  `$A0` bit 1 clear = **room change** (RUN, N and E): `$56` := `$FF`, objects cleared, (after a miniboss: sound `$1F` + the area music `$EF16[$50]`), bank 5 `$802D` (moves ($52,$53) a cell in direction `$A4`; CORRECTION: it was credited to `$8015`), `$8015` (reads the record at `$E4`), `$8003`, `$8030`, `F09A` (scroll, which calls `$8006`), `$ED44` key pictures, `$8039`, `$ED1D` (81 frames N, 98 E). **`$A0` bit 1 set = a WARP-STYLE EXIT
  (CORRECTION: not 'the player died')** - set by bank 3 `$9009` (warp panel + key, sound `$3B`) and bank 1 `$8057` (the gate's ship push): unless `$A4` = 4 a 60-pass ship flash (`$0788` = `$80`), then 20 passes, objects cleared, then by `$30` bits 5/6: **a special screen or a corridor gate** (`$EC12`/`$EC23`: fade out, sound `$1F`, `$F269`, `$802D`, `$EE1D`, `$ED44`, `$ED98` fade in, begin play WITH the jingle; screen type 5 = cleared gate -> `$F4B7`), **an ordinary room** (`$EC65`: ... `$EEE0`),
  **a corridor from its gate** (`$EC8C`: `$51` := byte 2 of the gate's record AND `$7F`, RUN: 5) -> **`$EC94` CORRIDOR LOAD**: sound `$1F`, `$F282` launch, `$EF6C` scene/stream, ship (128, 160), fade in, music `$EF2A[$51]`. **Stage end `$ECBD`** by `$51`: 0 `$ECE7`; 1-20 mark cleared (`$EFBA`) then `$ECE7`; 21 `$F506` + bank 0 `$8012` + `$F6E5/$F717` + bank 2 `$801B` + `$51`++ -> `$EC94`; 22 `$F506` (no return); `$ECE7`: `$F506`, then labyrinth (ship placed, `$EC23`) or, in TGL, bank 3 `$8018` (reward screen) and
  `$51` := `$ED08[$77++]`. Test paths used real map records ($8C09 = corridor 5's gate, $8E4C a room, $8DA0 a special record); the harness needs bank 5 live. NOT established: what `$F269` does, which exits use the warp-style path with `$A4` != 4, hardware.
- **Loading a special screen and an ordinary room, bank 7 `$EE1D-$EF15` (`annotations/regions/37-screen-loaders.json`, 17 regions; RUN on every kind of special record).** **`$EECC`** = the common start (`$56` := `$FF`, attribute patterns, bank 5 `$8015` reads the record at `$E4`, `$8000` with A = 0 loads common scene 0, returns byte 2). **`$EE1D` special screen:** byte 2 bit 7 = a corridor GATE (corridor = AND `$7F`; reward `$55` := `$EF40[c]`);
  `$EFAC` tests the cleared flag (carry CLEAR = cleared). **Cleared: type 5 if `$30` bit 6 is still set (just back from the corridor: the `$F4B7` ship entrance, and the gate's door cell at `$0740+$72` opened 8 -> `$0C`), else type 4** (the same gate on later visits - this is what 'screen 5' meant); **not cleared: type 8 (the sealed gate); corridor 21: type 8 only when `$04A9/$04AA` show 1-10 cleared (`($04AA|$FC)&$04A9 = $FF`), else type 0** (RUN: nothing 0, 1-9 0, 1-10 8, 1-10 + 21 4).
  Not a gate: byte 2 low nibble 1 and 3 keep their number, 2 and 6 (shops) become 7 once the item flag `$5E` in `$04A0..` is set. Then `$51` := type, `$5C` := `$10` + type (scene), `$8000`, `$50` := 0, `$30` := (`$30` & `$8F`) | `$20`, `$8003`, (type 5 door), `$8006`, `$EFF3` A = `$20`, `$8036` (-> `$A430`), `$0505` := `$35`, sound `$EF21[type]` = `$10 $18 $18 $13 $10 - $18 $18 $12`
  (**CORRECTION: that table was 'corridor sound, first 9 corridors', a lead - `$51` here is the screen TYPE**). **`$EEE0` ordinary room:** byte 2 high nibble -> `$51` (meaning not worked out), low nibble -> `$50` = the AREA, scene `$5C` = area + 5, `$8000`, `$30` & `$8F`, `$8003`, `$8030` (-> `$A3BB`), `$8006`, `$EFF3`, `$8039` (-> `$A462`), music `$EF16[$50]`.
  **CORRECTION found on the way: bank 5 `$802D` (-> `$8071`) is what MOVES ($52,$53) by the exit `$A4` (4 = stay) and builds the neighbour pointers `$E0-$E8`; `$8015` only reads the record at `$E4`** - the transition entry above had credited the move to `$8015`. NOT established: bank 5 `$A430`/`$A3BB`/`$A462`, what `$5E`-less screens do with the slot-5 type.
- **The corridor data loader and the flag helpers, bank 7 `$EF6C-$EFF2` (`annotations/regions/38-corridor-loader-flags.json`, 12 regions; RUN).** **`$EF6C`** (from `$EC9C`, after the launch flight): `$EECC` common start, bank 5 `$8000` with A = 1 (the corridors' common scene), then the corridor's scene `$EF55[$51]` (`$20 $21 $21 $22 $22 $23 $23 $24 $24 $26 $26 $21 $21 $22 $22 $23 $23 $24 $24 $25 $25 $25 $20`), decompressor wait, bank 5 `$8036`; **`$04B9-$04BE` := the score `$0170-$0175`**
  (the boss turns the difference into points gained), **`$78` := `$47`**, **`$30` := (`$30` & `$9F`) | `$50`**, bank 4 entry with A = `$51` (the block address -> `$18/$19`), `$E560`, `$E5BD`, back to bank 5 (RUN: scene `$23` for corridor 5; load at frame 373 of a start, stage engine at 382, filled by 390). **Flag helpers:** **`$EFC7`** (slot `$C078`) bit number n -> Y = n/8, A and `$10` = mask; **`$EFAC`** corridor c cleared? = bit c-1 of `$04A9-$04AB` (carry CLEAR = cleared; corridors 1-8 / 9-16 / 17-21 per byte), **`$EFBA`** mark cleared, **`$EFE0`** item flag n set? (array `$04A0`, carry CLEAR = set; the shop/item sub-id is the flag number), **`$EFE9`** set item flag n (RUN: all four).
- **Bank 5 room set-up, `$A3BB-$A496` (`annotations/regions/39-bank5-room-setup.json`, 12 regions; RUN on real item rooms, loop gates and set-ups).** **`$8036` = `$A430` AREA SET-UP** (from the corridor and special-screen loaders and from `$A462`): `$7E` = `$7F` = 5, `$27` := 0, **`$0740-$07FF` := 0** (the room buffer AND the tail of the object fields), the 16 loaded-block slots `$0480-$048F` := 0, `$60` &= `$F4`, and the decompressor armed with **block `$10` of bank 3 -> PPU `$0F80`** (sprite tiles `$F8`..; what it holds not drawn).
  **`$8039` = `$A462` ROOM ENEMY SET-UP:** `$A430`, kind `$40` -> `$A663` (miniboss), else `$27` := `$80` and `$28/$29` := `$A497` (the default 16-record art stream), and script id `$57` n -> `$66/$67` := the n-th pointer at `$A4C7` (id 0 = none), `$60` bit 1, `$68` = `$69` = 1 (RUN: 1 -> `$A525`, 5 -> `$A53C`, 16 -> `$A58D`, 47 -> `$A65C`). **`$8030` = `$A3BB` ROOM SPECIAL CASES:** `$56` := `$FF`; **item room (kind `$20`):** if the item flag `$5E` (the record's sub-id) is SET (`$EFE0`) the room buffer's metatile 6 becomes 1, so a taken item does not respawn (RUN);
  **loop gate (kind `$60`):** the move history `$04F0-$04F9` is walked NEWEST first, adding each move's displacement (table `$A41B`: x = N 0 W `$FF` none 0 E 1 S 0, y = N `$FF` ... S 1, two separate 8-bit sums) and **the gate opens (every metatile 4/5 -> 3) as soon as ANY stretch of the most recent moves returns to its start** - E then W, or a square, open it; E E N S W, N N S E W W and ten E do not; a history of all 4s opens it at once (RUN).
  **CORRECTION:** the loop-gate notes said the last moves 'sum to zero'; it is a 2-D displacement tested after every step. `$A425` finds the LAST cell holding metatile A (Y = position + 1, 0 = none).
- **The miniboss room set-up, bank 5 `$A663-$A68C` (`annotations/regions/40-miniboss-setup.json`, 2 regions; RUN for all 22 sub-ids).** Reached from `$A462` for room kind `$40`. The record's sub-id `$5E` is the miniboss's FLAG in the `$04A0` array (`$EFE0`): set = beaten = nothing happens, so it never returns. Otherwise `$72` := the type, `$28/$29` := the boss's art stream, `$27` := `$80`, **`$70` := 1 (boss phase), `$71` := 0** (a miniboss explodes nothing and does not stop spawns, unlike a corridor boss), from the 3-byte record at `$A6A3 + $A682[sub-id]`.
  Types by sub-id: `$1D` (11), `$58` (12 17 23 25 30), `$55` (13), `$1E` (14 16 19 21), `$56` (15), `$5A` (18), `$5B` (20), `$5D` (22), `$57` (24 26), `$5C` (27), `$1F` (28 29), `$5E` (31), `$47` (32 - Glider, a corridor boss type too). **The `$04A0` flag numbers are PARTITIONED:** items 1-10 and 33-57 (34 rooms), minibosses 11-32 (22), shops 58-67 (10), no overlap, 67 of 72 bits. NOT established: the miniboss types' names beyond `$47`.
- **Bank 5 position and record code, `$8042-$8154` (`annotations/regions/41-bank5-position.json`, 14 regions; RUN: 43 position/exit cases incl. every edge and corner, every record kind).** **`$8071` (slot `$802D`) MOVES THE POSITION:** Y = `$A4`/2, `$52` (column) += `$8067[Y]` (0 -1 0 +1 0 for N W none E S), `$53` (row) += `$806C[Y]` (-1 0 0 0 +1), then builds the five record pointers in ONE forward raster-order walk of the map with the SEEK `$80F5`
  (it only goes forward; stops when row/column counters `$14/$15` equal the target `$18/$19`; each step adds (first byte & `$0F`) + 1): **`$E0` N, `$E2` W, `$E4` the room, `$E6` E, `$E8` S**, the high byte 0 = outside the map. **`$8121` (slot `$8015`) reads the record at `$E4`:** `$5D` := byte 0 & `$60`; kinds `$20`/`$40` read the sub-id byte 3 into `$5E` (**kinds 0 and `$60` leave `$5E` stale**); byte 1 bit 3 -> `$57` := the script id (0 read as 1), else 0; `$55` := `$A377[$5E]` (the item for a sub-id).
  `$8042` (from `$826B`) = the room shape pointer `$91EA` + 18 x (A & `$1F`). The tables `$8067/$806C` replace two 5-byte generated claims. NOT established: nothing new open here; `$8155`+ (the room buffer builder) is still the generated card.
- **The room buffer builder, bank 5 `$8155-$8353` (slot `$8003`; `annotations/regions/42-bank5-room-buffer.json`, 23 regions; RUN: 302 rooms against an independent model).** `$8155` waits for the decompressor (`$C045`; a harness without NMIs must start at `$8158`), `$A749` picks the structure/door set/item list, then: **the structure's pattern is TILED** (rows across to column 16, `height` rows repeating, until `$C0`); its item group, the door set's four fixed items, then **the four WALLS (N W E S): item k is drawn ($A6EB) when the neighbour record's byte 0 has bit 7 set (empty or special) OR the opening bit (byte 1 bit 7/6/5/4) is clear**
  (special screens skip them, `$30` bit 5); the item list; the room's LAYOUT (`[shape|count<<5][tile]` + count x `[tile][pos][mask|dir]`: the 18-byte 1-bpp shape from `$8042` painted from row 2, then lines of up to 6 cells stepping -15/+1/+16/+17). **`$82DD` KEY DOORS: `$58-$5B` := 8, then for each open exit where (neighbour byte 0 OR own byte 0) has bit 7: key := the neighbour's byte 1 & 7, and metatile 8 is written to the four fixed cells `$0777`, `$07B2`, `$07BD`, `$07E7`** (rows/cols 3,7 / 7,2 / 7,13 / 10,7: the same cells `$EEB7` opens for a cleared gate) - **resolves the `$0777/$07B2/$07BD/$07E7` lead**.
  RUN: real `$8158` for every ordinary room and special screen (302) equalled `parse-structs.build_room` except exactly the door cells (131 doors: 83 rooms with 1, 19 with 2, 2 with 3, 1 with 4); **47 edge rooms have a neighbour pointer with high byte 0, so the real code reads ZERO PAGE for the neighbour's byte 0 (values with bit 7 set occurred) - harmless because an edge room has no opening there.** `$54` := byte 1 of the record, so **its bit 3 is the 'room has enemies' flag** (resolves 'bit 3 also set, unexplained'). NOT established: `$A749`, `$8379`, `$A6EB` internals beyond the format already documented.
- **Bank 5 cell classes and the 16-metatile drawer, `$8354-$8470` (`annotations/regions/43-bank5-cells-metatiles.json`, 10 regions; RUN).** **`$8354` (slot `$8006`)** packs the 192 buffer cells into the class map `$0400-$045F` (even column = high nibble) through **`$838E`**: A >= `$A0` -> 9, `$20-$9F` -> 0, set 0 -> `$83A5[id]` (14 entries `00 08 07 06 05 01 04 04 0A 09 00 02 0E 00`; ids 14-31 would read code but **no room contains one**); RUN: 312 rooms equal an independent model, all 256 ids exact. `$8379` draws a group of four `[length][item]`s (Y returned past them).
  **`$83B3` (slot `$8009`) DRAWS 16 METATILES** from `$04C0-$04CF` (cell 15 down to 0, `$AE` = the band index): the metatile's 5 bytes = set pointer (`$0460/$0468`) + 5 x (id & `$1F`), set = id >> 5, tile base `$0470[set]`; the 4 tiles (`$FF` -> `$20`, else + base) go to `$0130,2c`/`$0131` (top row) and `$0150,2c`/`$0151` (bottom row); **the 5th byte's low 3 bits pick an attribute pattern (`$0199`)** applied to the cell's QUADRANT of the attribute byte `$04E8 + c/2` (index = column parity + 2 x band parity, clear masks `$8469` = `FC F3 CF 3F`, quadrant masks `$846D` = `03 0C 30 C0`) - two bands build one attribute row; and **`$04C0+c` := (5th byte & `$F0`) | set**, the nibble the ground-object spawner reads.
  RUN: the 12 bands of the labyrinth savestate room reproduced its nametable (764 of 768 tiles, the 4 under the one object-covered cell) and all 6 attribute rows (48 bytes). Callers: the room band drawer `$F03D` and the corridor row builder `$E974`.
- **Bank 5 item drawer and structure picker, `$A6EB-$A7A6` (`annotations/regions/44-bank5-items-picker.json`, 12 regions; RUN).** **`$A6EB` draws ONE ITEM** `[dest][width][height][tiles]` into `$0740`: width bit 7 = one tile repeated, height bit 7 = the tiles are behind a pointer `[lo][hi]` (items share pictures), **tile `$00` is transparent**, each row starts at dest + 16 k (not under where X ended), **no horizontal clipping** (a wide item carries into the next row), stops at `$C0`; every item of every room passes through it, so the 302-room builder test is its test.
  **`$A749` picks the three lists:** ordinary room: structure `$A7B0[2 x area]`, door set `$A7CA[2 x area]`, item list = the EMPTY `$A916` (RUN: areas 0-10 -> structures `$A7F6 $AAD3 $AAD3 $AB6D $AB6D $AC07 $AC07 $AC01 $AC01 $AA8A $AA8A`); special screen (`$30` bits 5/6): item list `$A7E2[2 x type]`, door set 11 (`$A8A6`), structure `$A7B0[$A7A7[type]]` (11 = `$A897` for most, 12 = `$A8A0` for the shops 2/6/7); **types 5 and 8 (gates) whose corridor (record byte 2 & `$7F`) is 11-20 use item list `$A938` instead of `$A926`: the same gate without the seal items** (RUN: 3 and 21 -> `$A926`, 12 -> `$A938`). All results equal `parse-structs`' model.
- **The status screen's open and close, bank 5 `$84A9-$87E3` (`annotations/regions/46-bank5-status-screen.json`, 56 regions; RUN: `$84CB` then `$8711` on the labyrinth savestate, bank 5 live).** Called from bank 7 `$E500` (open, slot `$801B`) and `$E50F` (close, slot `$801E`), with the per-frame handler `$8937` (next stretch) between.
  **Open `$84CB`:** `SEI` (the I flag stays set until the close), rendering off, the 24 palette bytes saved to `$04D0-$04E7`, **`$84A9` clears nametable 1** (64 attribute bytes via `$D5CC`, then rows 28, 29, 0-23 via `$E453`; the HUD rows 24-27 are untouched), sprite 0's Y kept in `$0177`, all sprites hidden, `$FC` := `$B4` (line 180: the screen starts at the bottom rows 28-29 and wraps, so the 'KEY' row 29 sits over the key icons in rows 0-1), `$A2` := 1, palette list `$84C3`, sprite palette 3 colours 1-2 := `$16 $30` (the markers' red and white), **bank 2 block 3 (`$959F`, 15 tiles) -> PPU `$1010`: the map's QUADRANT TILES** (tile k fills the 4x4 quadrants named by its bits 1 TL, 2 TR, 4 BL, 8 BR), tile `$00` (`$1000`) := the frame line (inline string), 'KEY' at `$27B0`, then `$8805` draws the map, **12 weapon icons to `$1800-$1AFF`** (bank 2 `$81B2`, equal to the ROM icons in the run) and **7 key icons to `$1B00-$1CBF`** (`$8212`), bank 0 `$8034` writes **tiles `$CC`/`$CD`, the ATTACK/SHIELD level pips**, then the 20-slot loop over `$8690` (key held by `$04B0`, weapon level by `$E498`; level 0 or key missing draws blank `$20`, otherwise the slot tile through `$D865` with the attribute mask `$85DA[level]`; RUN with chosen keys and levels), labels NO/USE (row 14-15), EE + `$04AF` if the Eraser is owned, CHIP MAX + `$4E/$4F`, ATTACK/SHIELD with `$4A`/`$4B` pips (RUN: levels 2 and 3 gave 2 x `$CD`, 3 x `$CC`), WEAPON POWER, USE CHIP, `$89CB` (prints the weapon's power `$3D` and chips per use `$45`), PPUCTRL `$FF` := 8x8 sprites from table 1 (`$B1` -> `$99`), `$0176` := `$3C`, `$15` := 5, `$14` := 0 (the cursor handler's repeat counter and a spare, NOT arguments of `$8998`), bank 2 `$8998` (the blinking marker), `JMP $EDF4` (picture on, no `CLI`).
  **Close `$8711`:** `SEI`, rendering off, **`$86ED` refreshes the HUD's SHOT icon** (a 9-byte attribute-cell queue item at PPU `$273C`, `3C 3E / 3D 3F`, or blank for weapon 0; RUN through the NMI), **if `$3C` differs from `$0176`: objects 3 and 4 removed (`$CCBF`) and, unless `$30` bit 3, the new weapon's sprite tiles loaded (`$F726`)** (RUN: 3 -> 5 yes, 3 -> 3 neither), HUD uses-left, sprites hidden, nametable 1 cleared again (RUN: rows 0-23, 28, 29 = `$20`, attributes 0), PPUCTRL back to 8x16, **scene `$5C` reloaded through `$ACA9`** (a corridor, `$30` bit 6, also scene 1; otherwise `$ED51` rebuilds the key-door pictures in tiles `$00-$07` and bank 2 `$8153` reloads the eight glyphs in tiles `$08-$0F`: RUN, CHR `$1080-$10FF` equal to before), palette restored (RUN: equal), one bank 6 `$8000` object pass, then `LDA $0177 / JMP $EDE5` = sprite 0 Y, DMC rate, picture on and **`CLI`** (RUN: P `$24` after the open, `$21` after the close). Nametable 0 is untouched throughout (RUN: equal). **Refines** the status-screen note above: `$E515` runs a second bank 6 pass after the close, so there are two, not one. **CORRECTION (next entry):** `$89CB` is not the map's markers, and `$14/$15` are not `$8998`'s arguments. NOT established: the reason for the pass, `$ED51` in a room that has key doors vs the generic frame tile left in tile `$00` (observed: with no key door the frame tile stays), hardware.
- **The status screen's map, cursor and numbers, bank 5 `$8805-$89FA` (`annotations/regions/47-bank5-status-map.json`, 32 regions; RUN).** **CORRECTIONS to the open/close entry above:** `$89CB` is the weapon-power and chips-per-use printer (level `$3D` as an ASCII digit at `$2D3D`, `$45` as three digits at `$2D5B`), not 'the map's markers'; and `$15` := 5 / `$14` := 0 at the end of the open are the cursor handler's auto-repeat counter (read only at `$8946`), not arguments of bank 2 `$8998`.
  **`$8805` draws the map** (called from the open): wait for `$A5` = 0, the frame table `$87E4`, then a walk of the 24 x 24 records from `$8A6E` that builds **12 x 12 tiles**, each the OR of the quadrant bits of its 2 x 2 records (1 TL, 2 TR, 4 BL, 8 BR; the tile is the quadrant tile of bank 2 block 3) in a 12-byte buffer `$0150`, flushed as a 12-tile queue entry at PPU `$2C02` + `$20` a row (a zero becomes `$20`). A record counts when it is not `$80` and its key (byte 1 & 7) is 0 or held in `$04B0`. **Entrance markers are written in the same walk**: byte 0 bit 7 and byte 2 bit 7 set, corridor = byte 2 & `$7F`; shown while the corridor's cleared flag is clear (`$EFAC`), **except corridor 21, shown when corridors 1-10 are all cleared and NOT hidden once 21 is cleared** (RUN: flags `FF FF FF` left exactly that one); sprite x = column x 4 + `$10`, y = row x 4 + `$3B`, tile 1, attribute 3. RUN: tiles and sprites equal an independent model of the rule in 10 key/flag settings (0-20 markers).
  **`$8937` runs every frame** (from `$E506`): new press `$F5|$F6` loads the repeat counter `$15` with 20, a held direction decrements it and reloads 6 (RUN: moves at calls 0, 20, 26, 32, 38, 44); Right/Left/Up/Down (bits 0/1/3/2) move `$3C` through 0 (none) and 1-12 in rows of five (RUN: all 13 x 4 = the reading, e.g. Up 0->10 3->8 5->0, Down 8->3 10->0, Right 12->0, Left 0->12); sound `$3E`; `$FD77` sets `$3D`; a weapon with level 0 is skipped by moving again (RUN: owning 2, 5, 12, Right from 0 gave 2 5 12 0 2). Then the SHOT icon, uses left and `$89CB`, and always the bank 2 `$8998` marker blink, after which the code runs on into `$89CB` (so the numbers are reprinted every frame). NOT established: the ground-object spawner at `$89FB-$8A6D` (the next stretch), hardware.
- **The ground-object spawner, bank 5 `$89FB-$8A6D` (slot `$802A`; `annotations/regions/48-bank5-ground-objects.json`, 12 regions; RUN on synthetic row buffers).** Called after each 16-metatile band is drawn (`$E974`, `$EFF3`). y = (`$E8` + `$AF` - `$B7`) & `$FF`. Cells 15 down to 0 of `$04C0`: the high nibble (written back by `$83B3`) is the object number, the low nibble the metatile set; the set's list number is `$0478[set]` (from the scene's set records), the lists are `$803C` -> `$AF61 / $AF69 / $AF71` (8 bytes each, indexed by the nibble; 0 = none): `00 31 36 37 3C 75 76 7C / 7D 38 39 3A 3A 3B 3C 3D / 3F 7F 7E 7E 7A 05 03 00`. Each takes a slot from `$EA8C`; **no slot ends the whole routine, not just the cell**. Slot fields: type, y, x = 16 x cell + 8, field 8/9 = the PPU address of the cell's top-left tile (`$AD:$AC` + 2 x cell), field 10 = the band `$AE`, field 11 = the attribute address low (`$AA` + cell/2), field 17 (`$0698`) = the raw cell byte. RUN: types, slots (cell 15 got slot 23), x, tile and attribute addresses equal the reading; a full slot table changed nothing. Not run: the labyrinth savestate's own room spawned nothing (no such cells); the y formula there is the code's, unobserved. NOT established: what each type does (bank 6 handlers).
- **The special-screen object, bank 5 `$9F22-$A0F6` + `$A2B9-$A2F7` (slot `$8012`; `annotations/regions/49-bank5-screen-objects.json`, 29 regions; RUN through the real `$9F22` with X = 5).** Called by bank 6 `$9A12` for object type `$35`, which every special screen puts in slot 5 (`$EEA8`). First call (type bit 7 clear): `$CFA0` sets the bit and loads the per-type stats, then the inline table `$9F32` by screen type `$51`; later calls go to `$A0AE`. **Init by type:** 0 removes the object; **1 progress recorder** `$7C/$7D` := `$52/$53` and a type-`$34` message object (message 4) in slot 6; **2 shop 1** three type-`$33` items in slots 6-8 at cells `$65 $67 $69` (x `$58 $78 $98`, y `$68`), price and item ids from `$A04E` (`$55` x 5: 150, 1000, 400, 600, 2000 chips; ids `10 14 00 / 10 14 02 / 0D 0C 03 / 11 0C 04 / 06 0C 05`), then the seal-4 test (below) or message 8 in slot 9; **3 message** slot 5 becomes type `$34` with message = sub-id `$5E`; **4 and 5 and 8 first run the GATE BANNER `$9F88`** (bank 2 `$82C0`, a state machine on `$0788` until `$83`, 18 frames in the run, then 'the corridor number' = byte 2 & `$7F` at PPU `$2091`): 4 stops there, **5 then makes slot 5 a type-`$31` reward box at (`$80`, `$70`)**, 8 makes slots 5 and 6 the two type-`$B5` gate halves and jumps to the seal drivers `$A0F7`; **6 shop 2** one item at cell `$67`, price and item from `$A067` (`$55` x 3: 50/2, 100/6, 150/1, 500/7, 300/8), then the seal-4 test or message 7; **7** seal-4 test, else message 10. **Seal-4 test `$A2E7`** (the 'round creature' check): move-history entries 0-6 pairwise sum to 8 (RUN; entries 7-9 are not tested); pass sets `$04B1` bit 3, sound `$3F`, message 11. **Per frame:** shop 1 returns while all of slots 6-8 are occupied, shop 2 while slot 6 is; when one empties (RUN: emptied by hand) item flag `$5E` is set (so the next visit is type 7), the object is removed and slot 9 shows message 9. The recorder (`$A2B9`): `$3C` = 0 and a new A press removes slots 5-6 and far-calls bank 3 `$8009` (-> `$832D`, near the password encoder `$83AE`: presumably shows the password, a LEAD, not entered), after which `$A0` := 3, `$30` := `$20`, `$2F` := 3. NOT established: what removes the shop items on purchase (the type-`$33` handler, bank 6 `$99F1` -> bank 2), the item ids' names, field 17 values `$5C $D8 $DC`, bank 2 `$82C0`'s text routine, hardware.
- **The gate halves, the seal routines and the cell placer, bank 5 `$A0F7-$A376` (`annotations/regions/50-bank5-seals.json`, 29 regions).** Reads the code region by region and ties it to the seal behaviour RUN in the seal entry above (no new run this time: the claims here are the instruction-level reading of that run's code, not fresh measurements). Slot 5 (the doors, `$0620` = 0): once slot 6 sets its `$0788`, the offset `$0638` grows every 8 frames to `$1C`; two pieces (`$CC34`, metasprite `$8B`) at y `$6F`, x `$80` +/- offset; at offset >= 16 the ship in box A (`$A327[0]`) is pushed once (slot 0 `$05D8` := `$FD`, a sideways nudge by x, `$0668` := `$F8`, `$A4` := 4). Slot 6 (`$0620` = 1) counts `$07A0` 60 frames, then: corridor index >= 10 or bit already set in `$04B1/$04B2` -> release (`$0787,X` = slot 5's `$0788` := 1, sound `$3F`, remove self), else the ten-entry table `$A1C4` -> the conditions 3 (20 s, via the `$A2F8` seconds counter), 4 (nothing, set from `$9FD8`), 6 (chips change), 8 (`$3C` = 0 + A), 10 (B 10 s), 7 (move-history test), 1/5/9 (box hits, 50 shots; 9 = the ship) and 2 (four zones with sparks, bank 1 `$8003`), all ending in `$A245` (set the bit). Tables claimed: `$A2A9` (zones) and `$A327` (six hit boxes). `$A33F` places an object on a cell (used by the shops). The doors' `$86` values (`$E2` / `$22`) and what `$CC34` does with them were not read.
- **Bank 5's jump table, the dialogue fetch and the scene loader (`annotations/regions/51-bank5-scene-loader.json`, 36 regions; RUN).** **The table at `$8000` has 20 entries** (60 bytes, each its own region now): `$8000` scene `$ACA9`, `$8003` room buffer `$8155`, `$8006` cell classes `$8354`, `$8009` 16 metatiles `$83B3`, `$800C` dialogue select `$8471`, `$800F` dialogue fetch `$8483`, `$8012` screen object `$9F22`, `$8015` read record `$8121`, `$8018` palette copy `$B2E4`, `$801B/$801E/$8021` status open/close/frame, `$8024` object on cell `$A33F`, `$8027` set record `$AD1A`, `$802A` ground objects `$89FB`, `$802D` move `$8071`, `$8030` room special cases `$A3BB`, `$8033` HUD icon `$86ED`, `$8036` area set-up `$A430`, `$8039` enemy set-up `$A462`. **Dialogue:** `$8471` sets the object's pointer `$05C0/$05D8` := `$960F + 2 x $0620,X` (RUN: all 21), `$8483` advances it by `$0638,X`, returns the current character in `$15` and the next in `$14` and sets `$0638,X` = 1, i.e. one character per call (RUN: the first six fetches of every message equal the script). **Scene loader `$ACA9`** (RUN: all 39 scenes against an independent decode of the tables): record `$AD91 + 3A` = `[tile list][set record][palette record]` (`$FF` = none); a tile list (`$AE06`) is `[count]` x `[tile][bank][block]` -> the decompressor armed for PPU `$1000 + 16 x tile`, a block with bit 7 set being (`byte & $0F`) + (`$5C` & `$0F`); `$AD1A` loads `[count]` x `[set | list << 4][tile base][ptr]` into `$0478/$0470/$0460/$0468`; the palette record `$AE50` is `[flags][list ptr]` (+ 8 attribute-pattern bytes into `$0199` if flags bit 1) -> `$C05D`; `$B2E4` copies palette A to position Y. Bank 5 is now narrated end to end except the bank-5 generated `$A3BB-$A496` area set-up pieces already claimed in `39-`; NOT established: nothing new open in this stretch.
- **Bank 6, the object loop and the start-up (`$8000-$8269`; `annotations/regions/52-bank6-object-loop.json`, 26 regions; RUN).** **The jump table has 7 entries:** `$8000` object loop `$81FB`, `$8003` `$8BCE` (called by bank 3 `$935A`; unread), `$8006` cell lookup `$8435`, `$8009` player move `$826D`, `$800C` loop from slot 1 `$81F5` (the ending scene, bank 2 `$896A`), `$800F` reset init `$8015`, `$8012` TGL score `$805A`. **Reset init `$8015`** (called at `$FF47`): `$A5 $20 $017F $7E $7F $06` := 0, bank 0 `$8000` (sound init), the DMC timer registers, score digits `$0170-$0175` := 0, zero page `$0A-$F8` := 0, `$83` := 4. **TGL running score `$805A`** (bank 3 `$80D3`): six decimal digits `$04B3-$04B8` += `$04B9-$04BE` with a carry chain (RUN, 300 random sets), `$15` = first three digits as a number capped at 255, printed at `$2094` (three digits) and `$2097` (the other three plus a fixed 0). **The loop `$81FB`:** `$CDB4`, then slots 0-23; `$36` bit 1 set runs `$81DD` order (0-4, then 23 down to 5), so the enemies' order flips every two frames (RUN); per slot: type 0 skips, else the split table by `type & $7F` (return pushed first); `$CE88`. **Death check `$8232`:** slot 0 of type 4 with `$2E|$48|$49` = 0 starts **GAME OVER `$8247`** (type `$84`, objects 4-1 removed, sounds `$1F`, `$37`, `$A0` bit 0 cleared, far call bank 0 `$800F`; RUN to the far call) else it goes back to `$81` (the meter has not finished running down). Refines the earlier 'bank 0 `$81DD`' wording: the entry is bank 0 `$800F`. (bank 6 `$8003` = `$8BCE` is the enemy eraser, see the weapons 9-12 entry.)
- **The move with wall sliding, bank 6 `$826D-$8424` (slot `$8009`; `annotations/regions/53-bank6-move.json`, 23 regions + the blocking table `$8425`; RUN: 1,500 random states against an independent model, 0 differences).** New position: y = `$0518` + `$05D8` (+ fraction `$0758`+`$05C0`), x = `$0530` + `$0608` (+ `$0770`+`$05F0`); the probe y adds the foot offset `$06B0` (8). `$6F` bit 7 = same cell row, bit 6 = same cell column; both: accept (`$6C` := 0). Otherwise three class lookups in the class map `$0400` (index = row x 8 + column / 2, even column = high nibble, index >= `$60` = class 9): **`$6C` the diagonal cell (new row, new column), `$6D` the y-step cell (new row, old column), `$6E` the x-step cell (old row, new column)** (a copy of `$6C` when the column or row is unchanged). Blocking = `$8425[class]`: classes 4-10 and 14. None blocks: accept. Else y and x are first **snapped to the cell edge** (speed >= 0: OR `$0F`, negative: AND `$F0`, y with the foot offset; a zero speed counts as positive), then by case: same column -> x only if the diagonal blocks, else all; same row -> y only if it blocks, else all; a diagonal crossing compares |dy| and |dx| measured from the SNAPPED position and picks x only, y only, nothing or all from `$10/$11/$12` (diagonal / y-step / x-step blocked). The fractions `$0758/$0770` always advance, even when the move is blocked. **FINDING: `$12` is not the x-step cell.** `$8355-$835A` is `LDA $6E / LDA $8425,Y` with Y still `$6D` (no `TAY`), so `$12` = `$11`; a model that reads `$8425[$6E]` disagreed with the real routine in 9 of 1,500 states, the copy model in none. A move whose only blocker is the x-step cell is therefore treated as free in that respect. **The owner's GameFAQs 'walk through walls' report (`external.json` `wall-walk-glitch`, INCONCLUSIVE) has the right shape for this** - diagonal only, vertical walls only (the x-step cell lies across a vertical wall) - **but it was NOT reproduced:** the ship's real diagonal speed is 0.984 px per axis (read off the running player handler), at which x and y movement are equal at a crossing and the routine never enters a wall (140,160 one-frame moves, 0; about 1,300 runs of the real handler against solid walls and one-cell rock columns on the labyrinth savestate, 0); the model only enters walls at about 1.4 px per axis or more. A second cause (bank 3 `$8FB9-$9064` cell events and edge clamps) was not searched. Callers: the player (bank 3 `$8FB9`) and the ending scene; the `$6C-$6F` results are what the movement-test entry in `ram.json` names.
- **Bank 6 cell lookup, gun shot, weapon-hits-cell and the A-weapon wrapper, `$8435-$8652` (`annotations/regions/54-bank6-gun-cells.json`, 48 regions + 4 tables; RUN).** **`$8435` (slot `$8006`)** class under (x, y + foot): index = (y & `$F0`)/2 + x/32, high nibble for an even column, class 0 in a corridor or from y `$C0` (RUN: 1,500 random cases = the reading); `$8443` is the shared entry. Handlers: type 1 = far call bank 3 `$8000` (the player), type 4 = bank 3 `$8006` (the dying ship). **The gun shot (type 2, `$8490`)** copies the player's attack, takes speed class `$847C[tier]`, direction = `$0788,X` set by the firer (corridor: 12), `$C102` velocity, sound `$25`, alternates metasprite ids from `$8480` / `$8488` by frame, moves (`$CBE8`), collides (`$D229`), looks up the class under its hit box centre and, for classes in `$8513` (5-10, 14), runs `$8523`; removed at 0 hit points. **`$8523` per class** (Y = class): 14, 9 sound `$21`, damage only; 5 -> class 1 + tile `$28` + blast (`$FA96`); 6 -> floor tile `$1C` (attribute `$55`); 7, 8 -> class - 1 (`$FADE`); 10 the key-door cover: the point picks the door (x < `$40` W; x >= `$C0` E; else y < `$60` N, else S), `$58+Y` loses `$10` per hit (RUN: `$33 -> $23 -> $13 -> $03 -> $F3`, four hits) and on the fourth the class becomes 2 with **tile 0 (the room's first key picture, tiles `$00-$03`) or tile 4 (the second key's picture, `$04-$07`)** - **this resolves the 'bracket tiles `$04-$07`, purpose unknown' of the cells entry: they are the second key's picture, not a separate object** (RUN: doors (3,3,..) -> 0, (5,3,..) -> 4); a door with key 8 becomes floor. Every cell hit costs the shot 8 hit points. LATENT QUIRK: three doors (a, b, a) would draw the third with b's picture; no room has three distinct keys (all 302 checked). **The A-weapon wrapper (type 3, `$8616`):** `$879A[$3C]` bit 7 clear pays `$45` chips when `$3F` counts out (60 frames, or 120 for two objects; `$8606`: `$8B8F` spends, `$FDAA` recomputes the uses, `$E1C3` prints), removes the weapon objects at `$3E` = 0, durability 0 -> `$0590` := `$FF`, then the 12-entry table `$8653` by `$3C`. NOT established: the individual weapon routines (`$8653`/`$86E7` entries), `$8B9F` Eraser (described in the weapons entry only).
- **The A-button weapon objects, bank 6 `$866B-$8A99` (`annotations/regions/55-bank6-weapons.json`, 51 regions + 11 tables; RUN).** **First frame `$866B`:** type |= `$80`, drawing flags `$13`, `$3E` = 0 removes it, weapon 9 outside a corridor removes it, `$879A[weapon]` bit 7 = pay `$45` chips now (RUN: weapons 5, 6, 8 took 5 chips) and the low bits are the sound, palette `$878F`, metasprite `$8784`, then attack / lifetime (hit points `$FF` when 0) / speed class / flags from the four level tables at index 11 x (level-1) + (weapon-1) (RUN: **33 weapon x level combinations, 0 mismatches**), then the 13-entry table `$86E7`. **Per weapon:** **1 MultiBullets** direction (`$0788`, forced 12 in a corridor) to velocity; **2 Back Fire** two shots at facing +5 (slot 3) and +11 (slot 4) (RUN: facing 0/4/8/12 -> (5,11) (9,15) (13,3) (1,7)); **3 Wave Attack** in a corridor `$8837[$32]` = 11/12/13 by the pad column (RUN), in the labyrinth the facing; its direction is fixed at firing, there is no steering afterwards (CORRECTS the earlier 'steered by `$32`' wording); **4 Bullet Shield** stays on the player and its hit box circles at **radius 45** (sine x 3/8), 32 steps a turn at level 1, 16 at level 3 (RUN); **8 Repeller** flies along its direction while the hit box circles it at **radius 30** (RUN); both use `$8908` (draw and collide at an offset, restore, carry on a screen-edge wrap); **5 Grenade** lobs 60 frames (y speed kick `$FE`, `$CD12` pull), then a burst of `$0698` frames (12, 30, 60: RUN 11, 29, 59) whose hit box visits a ring of offsets from `$89DA` - a triangle of radius ~20, two squares of 12 and 24, and level 3's 48/24 diamonds (RUN: 3, 8, 16 distinct offsets) - and it hits nothing in flight; **6 Fireball** is weapon 1's code with the picture; **7 Area Blaster** two homing missiles: every 8 / 4 / 1 frames (level 1-3) the next suitable enemy slot after the current target (type bit 7 set, not `$31-$35`, `$0578` bits 7 and 2 clear, not the sibling's target) is aimed at (`$F865`) and the direction turns one step toward it (RUN: slot 3 took slot 6, slot 4 took 9, ignoring flagged slots and a box; both turned the right way). Pictures: tile base `$87DE[phase]` (phase 0-1 every second frame through `$CD7A`). NOT done here: weapon 9 (beam, `$8A9A`), 10 / 11 (blades, `$8AED`), 12 (`$8B9F`).
- **Weapons 9-12 and the enemy eraser, bank 6 `$8A9A-$8BEE` (`annotations/regions/56-bank6-weapons2.json`, 26 regions + 9 tables; RUN).** **9 Hyper Laser** (corridor only): parent slot 0, parent type `$81` (the beam `$FB76` ends when the ship is another type), y speed `$8ADD[level]` = -6 / -10 / -8, style record from `$FE22` by `$8AE3[level]` (0 / 3 / 6): metasprite `$00 / $1A / $17`, `$0638` `$40 / $60 / $F0`, half-width `$0650` **3 / 8 / 24** (matches the measured widths), attack **1**, hit points `$FF`; collision flags 8, then `$8AE9[level]` = `$18 / $38 / $3C` when `$8AE6[level] & $41` = 0: **level 1 hurts every other frame, levels 2 and 3 every frame** (RUN). **10 Saber Laser / 11 Cutter Laser** exist only while A is held; the hit box sits on a sine / cosine of radius 16 (32 on odd frames, one more 8 up in a corridor) in the player's facing (forced up in a corridor); the Cutter's slots 3 and 4 take facing -4 and +4: two blades at the sides (RUN: facing 12 -> (-16, 0) and (16, 0)); attack = the player's x 2, 4, 8 (RUN: 5 -> 10, 20, 40); collision through the orbit helper `$88C7`. **12 Enemy Eraser** (`$8B9F`): a new A press, sounds `$2F`, backdrop `$30`, 6 frames, **`$8BCE` (bank 6 slot `$8003`)**, backdrop `$0F`, `$04AF` and `$3E` -1 (RUN: 5 -> 4, 6 frames). **`$8BCE` turns every initialised slot 5-23 whose `$0578` bit 6 is clear into type 8 (an explosion) and remembers its type in `$0740,Y`** (RUN: immune and uninitialised slots untouched); bank 3 `$935A` calls it when a boss dies. This answers the open 'bank 6 `$8003` (`$8BCE`) unread' of the object-loop entry. `$8B8F` spends chips (`$4C/$4D` -= A, then `$E213`).
- **Bank 6 object handlers, types `$16`-`$19` (`$8BEF-$8D6F`; `annotations/regions/57-bank6-objects-16-19.json`, 22 regions + 4 tables; RUN with each type spawned alone in a corridor state, its art block marked loaded in `$0480` / `$0490`, `$41` stepped by hand).** **Method for the rest of the handlers:** a handler is run through the real object loop (`$81FB`) and its fields logged; helpers are named from the bank 7 slots (`$C08D` = `$CBE8` move and draw, `$C0C6` = `$D294` hit test as an ordinary enemy (mask `$30`), `$C0CF` = `$D29F` mask `$20` for fixed targets, `$C0D2` = `$D2BB` the consequences of a hit, `$C0D8` = `$D39B` the same for bosses, `$C0A8` = `$CF5F` the art wait, `$C0A5` = `$CD7A` the animation phase counter, `$C09C` = `$CD12` y spring toward `$0668`, `$C102` = `$F8CE`, `$C0FC` = `$F85D` aim and velocity, `$C12C` = `$FCD5` scroll carry, `$A1D8` = bank 6 picture setter: metasprite A, flip bits `$14`, tile offset `$15`). **`$16`:** appears at a random x at the top, stays fixed on the scrolling background (slides down with the scroll) until y reaches a random 32-159, then aims at the player (`$F85D`, speed class 6) and flies off with a seven-phase wing animation (metasprite `$1A` / `$19`, flip `$40`); hit points 16, attack 96 (RUN). **`$17`** is the same animation as a projectile moving in its `$0788` direction (summoner not found). **`$18` / `$19` Eyegore:** hit points are widened to 16 x the table (`$D385`: 32 -> `$0740` = 2, 48 -> 3), an entrance that decelerates from 1 px a frame to a stop near y 64 in about 128 frames (a spring about y 0), then a spring about y 96 swinging 64-128; every 32 frames a beam (type `$22`, bank 7 `$FE3D`, style record `$FE22 + $15`) at x boss - 24 + ((`$41` & `$7F`) / 2), and 16 frames later a summon at x +-32 of type `$16` (for `$18`) or `$27` (for `$19`) (RUN). The fight palettes are 2 and 0. NOT established: the beam type `$22` handler (`$A0A6`), the `$27` bullet, the `$D2BB` / `$D39B` damage rules in detail.
- **Bank 6 object type `$23`, ZIBZUB (`$8D70-$8E67`; `annotations/regions/58-bank6-object-23.json`, 20 regions + 3 tables; RUN 520 frames).** Hit points 14 x 16 = 224 (`$D385`), attack 48, art block `$41`. A random x, y = `$C0`, a 120-frame flickering wait (`$0788`), then a **bouncing jump cycle**: y spring target 251 with acceleration `$18` (gravity) and an initial y speed of -5, x pulled toward the player's x at 8/256 a frame (RUN: x 154 -> 213 in the first jump); a jump lasts about 107 frames with the apex near y 61 after ~55 frames; at y >= `$C0` the next jump starts (`$8D8D`). After the apex the mouth animation (3 phases of 4 frames: metasprite `$80 $80 $81`) reaches phase 2 and fires **one volley of three type-`$27` bullets** at the aim `$F863` (to the player) + 0, +4, +12 (RUN: directions 3, 7, 15 for an aim of 3), once per jump. A second piece, metasprite `$7F`, is drawn 40 px above the body and the hit box is raised by 48 px to cover it. Reaching a screen edge reverses the x speed (read, not seen). Confirms the earlier 'jump/gravity cycle, fires aim, aim+4, aim+12' note.
- **Bank 6 object types `$24` / `$25` / `$26`, CLAWBOT (`$8E68-$9079`; `annotations/regions/59-bank6-objects-24-26.json`, 28 regions + 3 tables; RUN type `$24` for 700 frames with its hit points forced down to reach the phases).** Hit points 12 / 16 / 20 (x 16), attack 16 / 36 / 80, art block `$2A`; per type palette `$9031` (3, 2, 0), claw animation step `$9034` (`$20 $40 $80`), bullet limit `$9037` (1, 1, 5). A random x, y = 40, 60 frames of flickering introduction, then the body creeps one pixel toward the player's x every second frame (RUN: 142 -> 162 in 40 frames) and two claw pieces (metasprite `$6E`, 56 px below the body) open and close in a 50-step cycle of `$0638` (spread 0, then 0 -> 15, 16, then closing; x = body +- (8 + spread)). **Phases, by hit points:** while the high part `$0740` is non-zero nothing changes; phase 0 -> 1 when the hit points fall under 20 (hit points := 100); phase 1 -> 2 at under 20 again: **two arm objects (type `$2C`, built by `$903A`, y +56, attack `$80`, hit points `$FF`) are released at the claws' x and the boss's hit points become 200** (RUN); in phase 2 a beam (type `$22`, style record `$FE22 + $12`, the boss's attack, y +24) every 72 frames at counter 28, and under 50 hit points the palette turns to 1. Bullets (type `$27`) fly horizontally, direction 0 or 8 chosen at random, only while the claw counter is under 26 and a multiple of 8 and the animation fraction is under the type's limit. In phases 0 and 1 the hit box is extended 64 px downward to cover the claws. NOT established: the arm object's handler (`$9742`), the beam handler (`$A0A6`), the `$27` bullet (`$A0C6`).
- **Bank 6 object types `$22` (beam piece) and `$27` (the bullet) and the picture setters (`$A0A6-$A26A`; `annotations/regions/60-bank6-objects-22-27.json`, 29 regions + 16 tables; RUN each bullet kind).** **Type `$22`:** collision flags `$4E`, hit points 128, attack copied from the shooter; each frame the beam machine `$FB76` (a chain of pieces between it and its parent) and a hit test against the player side (`$D279`, mask 4); removed when the parent is gone. **Type `$27` is a HOMING BULLET of eight kinds** (`$07A0` as the shooter left it: Zibzub sets 1, Eyegore `$19` 3 and so on). Per kind (tables `$A1EF-$A22F`): palette `1 1 3 2 2 2 3 1`, speed class `03 41 06 05 03 81 06 41`, **re-aim interval** `10 0A 08 08 10 05 09 10` frames, **turn step** `1 1 1 2 2 1 1 4`, hit points `1 2 24 12 16 1 1 1`, attack `4 8 48 64 24 4 4 6`, art block `39 35 36 02 04 35 39 2F` (found through the art wait entered at `$CF68`), picture mode `80 80 00 81 02 80 80 03`. Every interval the direction `$F863` to the player is compared with `$0788`: equal no change, 1-7 clockwise adds the step, 8-15 subtracts it, then `$F8CE` makes the velocity (RUN: heading down at a player to the lower right, kind 0 -> 3, kind 3 -> 2 then 0, kind 7 -> 0 within 16 frames). **This answers the open 'whether a bullet steers' lead: every kind steers toward the player, at kind-specific rates.** The picture: mode 0 metasprite `$19`, or `$37` heading straight with bit 7; mode 1 even directions only; mode 2 a metasprite per octant (`4B 19 1A 19 4B 7B 7B 7B`); mode 3 flicker (`$41 & 4`); flips by quadrant. `$07D0` is stored from `$A207` but not read by this handler (lead). Shared setters: `$A1D8` (metasprite A, flip bits `$14` over the palette's low two bits, tile offset `$15`) and `$A1E5 / $A1E7` (`$06C8` := offset + `$07E8`).
- **ENEMY STRENGTH SCALES WITH THE AREA (bank 7 `$FE88-$FECB`, slot `$C162`; `annotations/regions/62-bank7-stat-scaling.json`; RUN) - and the simple shots (bank 6 `$960C-$975E`; `annotations/regions/61-bank6-shots.json`, 23 regions + 3 tables; RUN).** **`$C162`** is called when most enemies are made. A := (`$50` + 1) / 2 with `$50` the labyrinth area, or in a corridor the corridor folded onto 1-10: **attack `$05A8` and hit points `$0590` are multiplied by 1/8 in area 0, 1/4 in areas 1-2, 1/2 in 3-4, 1 in 5-6, 2 in 7-8 and 4 in 9-10 (capped `$FF`, halvings never below 1)** (RUN: from 64: 8, 16, 32, 64, 128, 255). So the table values in `$D0AB / $D12A` are the area 5-6 values; this is the game's difficulty curve and explains why the same enemy type is weak early and strong late. (Bosses widen their hit points separately with `$D385`; whether they also call `$C162` was not checked per type.) **Shots:** `$0B` is aimed at the player when made (`$F85D`), speed class 3 or 5 when the player's shield `$4B` is 4 or more, fixed tile `$8A`, and bursts into an explosion (type 8) on a cell class in `$8513` (so on blocks in the labyrinth); `$0C` flies in the direction `$0788` the spawner gave; `$2B` is the same with a four-phase animation and sound `$40`; `$2A` is a lobbed fragment (y speed -2, spring target 254 with acceleration 20, x speed = `$0788`; a variant with art of its own is selected by `$0728` non-zero at creation); `$2C` is a slowly dropping object (the Clawbot's arms sink 0.19 px a frame). All use the hit test mask 4 (`$0B`, `$0C`) or `$30`. Allocator note: the slots of types `$0B-$0D` are the ones `$EA8C` takes back first.
- **Explosions, the kill score and the small timer / dissolve objects (bank 6 `$975F-$99F0`: `annotations/regions/63-bank6-explosions.json`, 38 regions + 10 tables; bank 7 `$DFB1-$E00C`: `64-bank7-kill-score.json`; RUN).** **Kill score `$DFB1`** (slot `$C02A`, called by the explosion): the class `$E00D[type]` (already claimed by `parse-enemies.py` with `$E08D`) gives the points; **types `$27` and `$2C` take the class from the object's own `$07D0`, so the bullet kinds' `$A207` values (3 5 8 7 8 6 6 6) are score classes worth 100-800 points and each Clawbot arm 4,000.** RUN: all 127 types equal the tables; nothing in a demo; `INC $40` counts kills; overflow caps at 999999 and sets `$017C`. Classes are worth 0, 10, 60, 100, 170, 200, 300, 500, 800, 1000, 2000, 4000, 8000, 10000, 15000, 20000, 30000, 40000 points; bosses: 8,000-40,000 (It 40,000). **Explosions:** a dead enemy's slot becomes type 8 (`$D441`) with its type kept in `$0740` and its collision flags left in `$0578`; **bit 4 of those old flags (the bosses' `$5A`) chooses the BIG burst: 16 phases of 2 frames with 22 flying pieces** (start phases `$98CB`, offsets `$98E1 / $98F7`, picture `$990D` growing 30 -> 33, 8 phases each; RUN 31 frames) instead of the small 6-phase burst (`$9919`, 23 frames); type 7 (the player's side) is 16 phases of 4 frames with 16 pieces (42 frames); sounds `$22` (type 8 with a remembered type), `$24` (type 7), `$23` (type `$30`); a type 8 with `$0740` = 0 (an enemy shot bursting on a block) is silent. The item-box far call (bank 1) is made only for a remembered type (RUN). **Type `$30`** (the blast of a broken block) rides the scroll (y += `$B7`) and is 12 frames. **Type `$09`** is an invisible countdown (`$0578` frames, then removed). **Type `$28`** (the dissolving squares) saves the old flags in `$0788`, runs 16 phases of metasprite `$79` then `$37` with tiles `01 03 ... 0F`, and adds four corner pieces at +-10 px for a big enemy. NOT done: the `$0788 != 0` explosion variant (`$9842-$98CA`: read, not seen; it turns into a type-`$32` object) and who makes `$09`.
- **THE PICK-UP EFFECTS, bank 2 `$86BC-$87EB` (slot `$8015`; `annotations/regions/65-bank2-pickups.json`, 27 regions + 5 tables; RUN for every item id from a fixed state).** Item ids (the icon numbers): **0-10 raise weapon id + 1 by one level** (two bits in `$04AC-$04AE`, masks `$87C6`, steps `$87CA`; **a weapon already at level 3 gives +1,792 chips instead**, capped at CHIP MAX), reloading the weapon's sprite tiles if it is the selected one; **11 the Enemy Eraser** (`$04AE` bit 6, stock `$04AF` + 20); **12 (Energy Tank icon) fills the life**; **13 (Blue Lander) = the score-bonus award: max life + 8, life and chips full, song `$31`**; **14 Gun** attack + 1 (capped at 4 by `$FD0E`); **15 Shield** + 1; **16 Consecutive Firing** fire rate + 1 up to 5 (shot delay `$87CE`: 12 5 4 3 2 1); **17 Red Lander** chip level + 1 up to 10 (CHIP MAX `$87D4`: 50 100 150 200 400 800 1200 1600 2400 4000 6000, a twelfth entry 30000 is never reached) and chips and life filled. **Every upgrade except 12, 13 and 17 also gives +16 life.** Box drops: 18-20 +40 life (20 plays `$30`), 21 +500 chips and +16 life (`$34`), 22 and up +10 chips and +8 life (`$33`). Sound table `$87BB` (`32 00 35 35 35 31 00 00 30 34 33` for ids 12-22). Confirms and completes the earlier 'effects' notes (the 'effect 13' and '17' wording, and the item-box contents). NOT done: the pick-up OBJECT code before it (`$84CB-$86BB`: the box, shop items and their door reveal) - the next stretch.
- **The item objects, bank 2 `$84CB-$86BB` (`annotations/regions/66-bank2-item-objects.json`, 42 regions + 2 tables) and the bank 6 stubs (`67-bank6-stubs.json`, 13 regions); RUN through the real object loop.** Types `$31` (box), `$32`, `$33` (shop item) all far-call bank 2 `$84CB` from bank 6 `$99F1`; type `$34` far-calls bank 2 `$8009` (= `$82C0`, the DIALOGUE display machine, also the gate banner), `$35` bank 5 `$8012`. **Box:** mode 1 (labyrinth) or 2 (`$30` bit 5/6: a gate's reward); `$0680` = the item (`$55`); hit points 4 - shooting it to 0 OPENS it (`$0668` = 1, `$56` := the item id so no other box opens meanwhile), uploads the item's icon to tiles `$5C-$5F` (PPU `$15C0`) and puts it in the cell; touching an OPEN box collects it (touching a closed one does nothing, RUN): the effect (`$86BC`), the cell becomes floor `$1C`, **mode 1 sets the item flag `$5E`** and scans the door cells; **mode 2** (the gate) opens at once and on collection does two sparks and scans the door cells. **Door cells (`$87EC`, 8 records [cell][class][attr][opening mask]): every cell of class 14 whose room opening is set becomes class 10 (inner) / 8 (outer) with picture `$14` - the cleared gate's 'open door' (metatile `$0C`, class 14) turns into the 4-shot cover in front of the warp panel (RUN: corridor 5's gate (7,2) 14 -> 10); class 14 exists nowhere else in the map.** **Shop item (`$33`):** prints its price under itself, uploads its icon to tile `$0698` (`$5C / $D8 / $DC`), touching it with enough chips (`$4D:$4C` >= `$0770:$0758`) pays, applies the item and removes itself (RUN: 4095 -> 3095). **ANSWER to 'what removes the other shop items': when one slot empties, the screen object (`$A0BF`) sets `$07A6-$07A8` := 1; every remaining item sees its `$07A0` flag, turns its cell to floor and removes itself (RUN: gone in 14 frames).** **QUIRK (model only, not tried on hardware): the flags are only set when Start is NOT held (`$A0CC`); with Start held on the purchase frame the other two items stay and can be bought as well (RUN: chips 4095 -> 3095 -> 2095).** Drops of id 20-22 are shown as background tiles `$2C / $24 / $28`. Type `$29` (formation spawner): count in `$0560`, interval `$07A0`, child type `$0548`; nothing while `$60` bit 3.
- **OPTOMON, object types `$2D` / `$2E` / `$2F` (bank 3 `$93FA-$952D`, reached from bank 6 `$907A` through bank 3 slot `$8012`; `annotations/regions/68-bank3-optomon.json`, 37 regions + 7 tables; RUN 700 frames each).** Hit points 10 / 16 / 20 (x 16), attack 48 / 64 / 96, score 10,000, art block `$40`. Intro: 120 flickering frames, then a **swing: an x spring about 128 (acceleration 18/256) and a y spring about 48 (32/256) from a kick of (4, 1): x swings 12-244, y bobs 43-52** (RUN, all three types). **Beams** (type `$22`, parent = the boss, y +24): the timer `$07A0` (40 / 32 / 68) only counts in the animation phases whose tile offset is under `$28`; the beam's speed 1 (type `$2E`: random 1 or 3) is negated when the boss is below the player, **so the beam always travels toward the player's row**; style records `$FE22 + 9 / 12 / 15` (half-width 2, `$0638` `$20 / $40 / $60`) - thin beams, longer for the later types. **Every 32 frames an aimed type-`$0B` shot** (RUN). The body is metasprite `$7E` / `$7D` over 8 phases with a second piece `$7C` flickering every four frames. Palettes 3 / 2 / 0. The CLAUDE 'springs about (128, 48) ... shots up or down' note is now read from the code and confirmed.
- **Ordinary enemies, first two: types `$0E` and `$0F` (bank 6 `$9A5C-$9C1C`; `annotations/regions/69-bank6-enemies-0e-0f.json`, 47 regions + 8 tables; RUN in the labyrinth state at areas 0, 3 and 9).** **The ordinary enemies take their strength from the AREA TIER, `($50 + 1) / 2` (`$9B0F`: 0 area 0, 1 areas 1-2, 2 areas 3-4, 3 areas 5-6, 4 areas 7-8, 5 areas 9-10), through their own per-type tables, not through `$FE88`.** Common template: appear on a random free cell (`$FA17` random x 32-223, y 40-183; a blocked cell removes the object and the type is restored from `$0740` so it tries again next frame), 40 frames of flickering arrival (`$FD53`: drawn every second frame, no AI, no hits), then the behaviour, a hit test with mask `$30` and `$D2BB`. Movement helper `$9B2A`: in the labyrinth the player's wall-sliding move `$826D`, in a corridor `$C08D` with removal off the screen. **`$0E`** wanders: a new random direction (`rand & 15`) every `$0668 + (rand & 63)` frames, at once when a wall blocks it; palette `00 00 00 01 02 03`, speed class `01 02 02 02 03 41`, interval `40 30 20 20 10 08`, attack `04 08 10 20 30 50`, hit points `01 02 06 0C 18 30` by tier (RUN: area 0 attack 4, 1 hit point, area 9 attack 80, 48 hit points); a two-picture flip animation. **`$0F`** rests (`50 3C 28 14 0A 01` frames by tier), then in phases of 40, 20, 20 frames lunges in one of the four straight directions nearest the player (aim + random 0-3, AND `$0C`) at speed class 3 and moves only in phase 2; attack (`$9AED` / 2) | 1 = 3, 5, 9, 17, 25, 41, the same hit points as `$0E` (RUN: short lunges of about 30 px). `$9B09-$9B0E` is an unreferenced fragment (lead).
- **Ordinary enemies, types `$10`-`$13`: the hoppers (bank 6 `$9C1D-$9D09`; `annotations/regions/69-bank6-enemies-10-13.json`, 42 regions + 4 tables; RUN in a corridor state at `$50` = 5, 0 and 9, player held at (100, 150)).** One handler for four types, art block `$16`, metasprite `$19`, speed class 1, no cell test (a corridor enemy). **Strength is NOT from a tier table: it uses the area scaling `$FE88` (`$C162`)**, so the table values are the area 5-6 ones: hit points 24 / 32 / 48 / 80, attack 32 / 64 / 88 / 128 (RUN: area 0 3 / 4 / 6 / 10 and 4 / 8 / 11 / 16; area 9 96 / 128 / 192 / 255 and 128 / 255 / 255 / 255). So there are two difficulty mechanisms among ordinary enemies: the tier tables (`$0E`, `$0F`) and `$FE88` (these, the bosses' shots). Placement: a random x 32-223, y 40-183 (`$FA17`) unless `$0728` is preset, 40 frames of flicker, then a **hop cycle**: gravity is the y spring `$C09C` with acceleration `$20` toward the fixed target `$0668` = `$FF` (a constant pull of 0.125 px/frame^2), the landing level is `$07A0`; when it is back at that level with a non-negative y speed the hop counter `$07B8` is incremented and the kick is `$C102` of a direction at speed class 1 with the y speed lowered by 3 + a random 0-31/256 (about -2.4 px/frame; RUN: 26 px up, 41 frames a hop). **The direction is 4 (down: no x part, so it stops any drift) unless (counter AND mask) = 0, when it is aimed at the player (`$F863`); masks by type `$10` `$11` `$12` `$13` = 3, 1, 0, 5**: aimed every 4th hop, every 2nd, every hop, and the 2nd and 8th of each 8 (RUN: the x drift and the landing level confirm it). An aimed hop also moves the landing level by `$9CF2[direction]` (-16..+16 px, 4 x the vertical part), so the enemy works its way to the player's height, 6-10 px a hop. Pictures: tile offset 8, 8, 4, 0 by phase (4 frames each) on the way up, 4 while falling. Palettes `01 02 00 03`. Hit test mask `$30`. **CORRECTION / refinement of the `$0E`/`$0F` entry above and the closing summary: an enemy that leaves the screen in a corridor (the `$C08D` carry) is not gone for good.** `$9B17` clears the slot and, since these types' drawing flags have no bit 4, puts the type back from `$0740`, so next frame it is made again at a random place with full hit points and a new introduction (RUN with a hopper pushed off x 255: back at (99, 165), 24 hit points, `$0788` = 40). The `$0E`/`$0F` region text says the same ("made again next frame"); the shorter wording in the summary above ("removes the enemy at the screen edge") was incomplete. NOT established: which stages spawn these types, hardware.
- **Ordinary enemies, types `$1D`-`$1F`: ground enemies that step toward the player (bank 6 `$9D0A-$9DF9`; `annotations/regions/69-bank6-enemies-1d-1f.json`, 46 regions + 3 tables; RUN in the labyrinth state, area 5, player held at (60, 60), 600 frames).** Collision flags `$50` (Eraser-immune, big burst), art block `$12`, hit points 1 / 3 / 6 x 16 (`$C165`) = 16 / 48 / 96, attack 16 / 48 / 80, palette `03 02 00`, speed class `01 02 03`. **No area scaling and no tier table: the same strength in every area** (RUN at areas 5 and 0). Random free cell (`$FA17` + the class test `$9A53`; a blocked cell removes and retries; unlike `$0E`/`$0F` a preset `$0728` is not honoured), 60 frames of flicker, then still for another 30 until the first decision. **Decision timer `$07A0`** (24-56 frames, halved for `$1F`): at zero the direction becomes the nearest of the four straight ones toward the player (`$F863` + 2, AND `$0C`) - **unless it is heading directly away from the player, in which case it turns at right angles** (0 -> 4, 4 -> 8, 8 -> 4, 12 -> 8) - and `$F8CE` sets the velocity. Types `$1E` and `$1F` also fire a type-`$0B` aimed shot at each decision (RUN: 10 and 11 shots in 600 frames; `$1D` none). A blocked move (`$826D`, class by `$8425`) does nothing until the timer is under 4, then turns a quarter turn left or right at random and sets a timer of 8-72. Two pictures (metasprites `$1F`, `$20`, every 8 frames). The hit test is `$C0C6` but the resolve is `$C0D8`, the boss rules. **CORRECTION: `$9B09-$9B0E`, listed above as an unreferenced fragment, has a caller** - `JSR $9B09` with A = 3 at `$9D9E`, in this handler's branch for type `$73` (flip the palette's bit 6 every 4th frame); no dispatch entry sends type `$73` here, so that branch is dead. The region's name and text are corrected in `69-bank6-enemies-0e-0f.json`. NOT established: which rooms spawn these types, hardware.
- **Ordinary enemies, types `$1A`, `$1C` and `$1B` (bank 6 `$9DFA-$9FB7`; `annotations/regions/69-bank6-enemies-1a-1c.json`, 87 regions + 6 tables; RUN in a corridor state, `$1B` also at the player's shield/attack levels 1/1, 4/2, 7/4 and with `$51` = 21).** All three have drawing flags `$13`: **leaving the screen removes them for good** (the `$0E`-`$13` types come back). **`$1A` (diver):** enters at a random x, y 8, y speed 3 down, x speed 1 px/frame toward the player's x at that moment; the y spring `$C09C` with acceleration 7 toward y = 0 turns it round: **it dives to about y 172 and climbs out of the top** (RUN: lowest point 171 at frame 106, gone at 158). Four-phase picture (tile offsets `00 04 08 04`, flip `00 00 00 80`). Area scaling `$FE88` (8 hit points, 8 attack at area 5); **in areas 9-10 its palette is 0 and its hit points are forced to 255 after the scaling**. **`$1C` (faller):** hit points 1, attack 16 scaled, y speed 4, the same x speed, metasprite `$37`, palette 3, a straight diagonal fall (its x spring is aimed at its own x, a no-op). **`$1B` is two things.** Made with `$0728` = 0 it is a **RING-MAKER**: it appears at (116, 32) with speed class `$81` (3.75 px/frame) and flies a closed loop, turning 22.5 degrees every tick (direction = tick count AND 15, `$C102`), leaving a stationary ORB (type `$1B` again, `$0728` = `$FF`, parent slot in `$0668`) on every tick the mask allows. **The ring is set by the player's own upgrades:** tick length `$9EDF[shield]` = 4, 5, 6, 7, 8, 8, 8 frames, orb mask `$9EE6[shield]` = `00 03 01 01 03 01 00` (orb when tick AND mask = 0), orb speed class `$9EED[attack]` = 3, 4, 5, 6. On the 16th tick the maker turns into the 16th orb and every orb of the lap (state 1: drawn, no movement, no hit test, until the parent's lap number changes) is **released: aimed at the player (`$F85D`) from its own place, hit points 1 and attack 24, both through `$FE88`, palette 0**, and flies straight (state 2, hit test mask `$30`). RUN: 16 orbs at shield 1 (ring about 75 px across, release at frame 63) and shield 7 (frame 127), 8 at shield 4; classes 3 and 6 at attack 1 and 4. **In corridor 21 (`$51` = 21) the loop is never closed**: the maker keeps laying laps for ever (RUN: tick 100 at frame 400). NOT established: who makes the standalone `$1B` (the code puts it at a fixed position, so a spawner's position is ignored), which stages use `$1A`/`$1C`, hardware. The next handler, `$20` at `$9FB8`, was not read here.
- **Ordinary enemies, types `$20`, `$62` and `$21` (bank 6 `$9FB8-$A091`; `annotations/regions/69-bank6-enemies-20-21.json`, 55 regions + 7 tables; RUN in a corridor state, area 5 and 0).** All three: drawing flags `$13` (gone for good off the screen), end in `JMP $9F4F` (move `$C08D`, hit test `$C0C6` mask `$30`, resolve `$C0D2`), a four-phase picture through `$A1D8`. **`$20`:** hit points 128, attack 32, art block `$3B`, **no area scaling**; enters at a random x, y 8 and sinks with only a y-speed FRACTION of (x AND `$3F`) + `$28` / 256 (0.16-0.41 px/frame; RUN 0.25: y 8 -> 131 in 500 frames), no sideways motion, no shots: a slow, tough obstacle. Metasprites `19 79 19 79`, tile offsets `00 04 00 06`, flips `00 00 40 00`, step `$30`. **`$62`:** hit points 1, attack 4 (both scaled), art block `$3D`; random x at the top, speed class `$41` (1.9 px/frame), **aimed once at the player (`$F85D`) and flies a straight line** (RUN: off the screen after 66 frames). **`$21`:** hit points 8, attack 24 scaled (RUN area 0: 1 / 3), art block `$3D`; not placed (the spawner's y is kept); alternates sides by toggling `$6A` (`$AD9A`): starts at x 96 moving left at 3 px/frame with the x spring (acceleration 14/256) targeting x 255, or x 160 moving right targeting x 0 - **it swings away, stops after about 55 frames, comes back and crosses the whole screen, leaving at the far side** (RUN: 160 -> 251 -> 1, gone at frame 148; mirrored from 96) - while the y spring (acceleration 8) bobs it about y 64; **fires an aimed type-`$0B` shot every 30 frames, the first after 20** (RUN: 5 shots in 148 frames). Pictures shared with `$62` (`$A01F`: metasprites `19 37 19 1A`, tile offsets `00 04 00 06`, flips `00 00 40 00`, step `$20`). NOT established: which stages spawn these, hardware. Next in bank 6: `$22` is in `60-bank6-objects-22-27.json`; the ordinary types before `$0E` and after `$27` remain.
- **Ordinary enemies, types `$14` and `$15`, type `$05`, and the creep helpers (bank 6 `$A26B-$A348`; `annotations/regions/69-bank6-enemies-14-15.json`, 46 regions + 3 tables; RUN in a corridor state).** **Type `$05` (the corridor ship) is just `JMP $C090`: drawn, nothing else**; its motion is done by the code that placed it. **`$14` and `$15` are a tough swinger:** hit points 224, attack 8, art block `$1B`, **no area scaling**; 60 frames of flicker; **always placed on a random cell** (`$FA17`; a given position or preset `$0728` is overwritten). `$14` picks an x target 48-80 px toward the middle of the screen from where it appeared, `$15` a y target 32-64 toward the middle (y under `$60` adds, else subtracts), and then the spring `$C09F` (x, `$14`) or `$C09C` (y, `$15`) with acceleration 16/256 pulls it. The springs are constant-acceleration, so the swing is **bang-bang: it swings between its start and the mirror image of the start about the target** (RUN: `$14` x 2-162 about target 82, period about 200 frames, y fixed at 92; `$15` y 9-121 about 65, x fixed at 160). Five-phase picture (metasprites `1A 1B 1C 1C 1B`, a flip on phase 4), a hit test `$C0C6`, and leaving the screen goes through `$9B17` (drawing flags 2 and 1 have no bit 4, so it is made anew, as for `$0E`-`$13`). Also described: `$A302` (palette, picture, 60-frame introduction), the move/hit tail `$A317`, and the **one-pixel creep toward the player's x (`$A325`) and y (`$A337`)** that Clawbot and other handlers call (byte-scan hits: eight and six sites in bank 6). `$A30F-$A316` stays in the unreferenced-code file as a lead. NOT established: which stages spawn `$14`/`$15`, hardware.
- **Cannons, types `$55`-`$57` (bank 6 `$A349-$A445`, with the fragment helpers `$AC9F-$ACE1` and `$AECF-$AEE7`; `annotations/regions/69-bank6-cannons-55-57.json`, 48 regions + 4 tables; RUN in the labyrinth state at area 5, player held at (60, 140), 1,500 frames each).** Collision flags `$50`, art block `$26`, hit points 2 / 4 / 6 x 16 = 32 / 64 / 96, attack 48 / 64 / 96, **no area scaling**, palette from the `$9DF4` table shared with `$1D`-`$1F` (`03 02 00`), body metasprite `$69` and a head piece (`$68`, or `$67` when firing) drawn with `$C093`. **A 539-frame cycle driven by `$07A0` through `$A3EA`: state 0 picks a random free cell (`$FA17` + `$9A53`; blocked = retry next frame), 1 = appearing (120 frames, drawn on every second frame, no fire, no hit), 2 = ACTIVE (239 frames: the timer `$A432` only counts on even `$41`), 3 = disappearing (60 frames, flicker), 4 = hidden (119 frames), then a new place** (RUN, same for all three). It creeps toward the player's y (`$A337`, 1 px a frame). **Fire:** in state 2 the head cycles ten phases (step `$04` / `$18` / `$30` = 64 / 10.7 / 5.3 frames a phase, head pictures `68 68 67 68 68 67 68 67 68 67`) and in the `$67` phases, on frames where `$41` AND the mask (`$0F`, `$03`, `$00`) is 0, it aims at the player (`$F863`) and throws a **type-`$2A` lobbed fragment** (RUN: every 16 frames within a firing phase for `$55`, every 4 for `$56`, every frame for `$57`; 16 / 36 / 36 fragments in 1,500 frames). The fragment is made 24 px above and 8 px left of the cannon, its x speed `$ACBA[aim direction]` (+0 or 1 at random; the table is about the cosine, -2..+1) in `$0788`, a random palette 0-3, metasprite `$37`, and **`$0728` = `$18`: that is the non-zero `$0728` that selects the fragment's own art variant, which answers the lead 'who sets the second variant of `$2A`'**. Only state 2 is hittable (`$C0C6`, resolved with the boss rules `$C0D8`). `$A337` creep and `$9B09` (palette flip every 8th frame) are shared. NOT established: which rooms hold these, hardware. `$58` and the tier-table cannons `$5A`-`$5C` follow in the same neighbourhood and use the same state machine.
- **The nest, type `$58` (bank 6 `$A446-$A4F7`; `annotations/regions/69-bank6-nest-58.json`, 38 regions + 3 tables; RUN in the labyrinth state at areas 0, 3 and 9, player held at (60, 140), 700 frames).** Collision flags `$50`, art block `$1A`, attack 32 (not scaled), hit points from the AREA TIER (`$9B0F`) table `$A501` = `04 04 07 0A 10 14` x 16 (RUN: 64, 112, 320 at areas 0 / 3 / 9), palette `$9ADB[tier]` (the type `$0E` table), hatching threshold `$A4FB[tier]` = `04 06 08 0A 10 10`. It uses the cannons' state machine `$A3EA` (random free cell, 120 frames appearing, active, 60 frames disappearing, 119 hidden) but **its active time is one pass of its own 35-phase animation (4 frames a phase): 139 frames** (RUN: states at 0 / 120 / 259 / 319 / 438, a 439-frame cycle). Pictures: metasprite `$34` with a tile set that alternates every 4 frames (phases 0-9 and 30-34), `$35`/`$36` for phases 10-11 and 28-29 (the picture bytes `35 36 35` at `$A4F8` are read through two overlapping bases that lie inside the code before them). It does not creep. **It HATCHES: in state 3, on the even values of the countdown below the threshold, with a free cell under it and a free slot, it makes a type-`$0E` wandering enemy at its own x and y + 8, with `$0728` = `$0E` so the wanderer keeps that position** (RUN: 1 / 3 / 7 wanderers per cycle at areas 0 / 3 / 9 = threshold / 2 - 1, two frames apart). Only state 2 is hittable (`$C0C6`, boss rules `$C0D8`). NOT established: which rooms hold nests, hardware. Next in the neighbourhood: `$5A`-`$5C` at `$A507`.
- **The labyrinth room-change scrolls, bank 7 `$F09A-$F268` (`annotations/regions/25-room-scroll.json`, 24 regions; the 'F169-F258' task).** `$F09A` (called by
  `JSR $EBC6`) dispatches on the exit `$A4`: 0 -> **north `$F169`**, 8 -> south `$F10D`, else the horizontal arm `$F0A8`; every arm ends in the shared tail and `JMP $8006` (bank 5
  `$8354`, the cell classes). **North:** `$30` bit 4 set (the NMI then moves the split marker with the scroll), `$AE` = 14, `$17:$16` = `$28B0` (`$16` is also the room-buffer
  offset of the band: `$B0` = band 11, the bottom, because the room enters from the top), every 16 px (`$A6` AND `$0F` = 0) wait for queue room (`$E5EB`) and draw a band (`$F03D`, net
  `$16` - 16), every frame ship y + 3, `$A6` - 4 (first step wraps 0 -> `$EC`, `$A7` flips), `$E522` (commit the scroll variables to the shadow registers; `$D507` derives `$A2`),
  `$F258` (the ship's frame only: `$CDB4`, bank 3 `$8F89` = the ship's ANIMATION step, `$CBFC` draw, `$CE88` finish) until `$A6` = `$30`: **48 frames, 12 bands**. RUN: ship y 14 -> 158,
  tail at frame 74, `JMP $8006` 29 frames later. **South:** the mirror, `$A6` 0 -> 192, ship y - 3 (177 -> 33), and each band goes through `$F204`, which also keeps a 2-deep record of column
  0 (`$AD:$AC`, `$0130`, `$0150`) at `$0400,Y` and re-queues it two calls later as a vertical 2-tile run (`$82`) - purpose a LEAD (observed addresses `$2300 $2340 $2380 $2800 ...`).
  **Horizontal:** thin the split tile, draw the incoming room into NT1, fill row 24 of NT0 and NT1 (cols 1-31) with the solid tile `$FE`, then `$A8` +/-4 for 64 frames; the ship moves **alternately 3 and
  4 px** (`SBC #3` with a leftover carry from unused `LSR`s; measured -3, -4, -3, -4 ..., 220 px), CORRECTING the Rendering page's "3 px a frame" (true of N/S only). **The `$1FEA` fills** (`$D5CC` writes
  `count` bytes: `06 1F EA 00` = 6 bytes): tile `$FE` is plane 0 `00`, plane 1 `FF` (solid colour 2); the fill zeroes plane-1 rows 2-7, leaving two opaque lines, and `06 1F EA FF` restores it
  (measured). Done for the whole horizontal scroll and, for N/S, from the end of the scroll to the re-home; WHY is a LEAD. **Re-home** (`$F1C6` N/S only, `$F1DA` shared): the room is drawn into NT1
  (`$EFF3` with A = `$24`), scroll zeroed with `$A9` = 1, commit, then drawn into NT0 (A = `$20`), scroll all 0, commit, blank `$2700` row (32 x `$20`), restore the tile, blank `$2400` row 0 - **a redraw from the
  buffer, not a copy** (CORRECTS the Rendering page). Helpers: `$FFD1` (slot `$C021`) waits Y frames; `$E522` (slot `$C087`) commits the scroll; `$E5EB` spins until the PPU queue offset `$21` < `$31`
  (its ~12,600 hits per exit are the spin); `$EFF3` draws a whole room into the nametable whose high byte is in A. West was not run (the savestate's west side is a wall); the east/north/south runs used
  the labyrinth savestate with the pad held (Up from y `$34`, x `$78`; Down; Right from y `$78`, x `$D8`).
- **The HUD's number printers and the life meter, bank 7 `$E169-$E3F8`, `$E406-$E423` (`annotations/regions/24-hud.json`; the 'HUD code at `$E24B-$E3CC`' task).**
  Eight regions replace the generated extent card. **`$E24B` (slot `$C04E`) prints any 16-bit value in `$17:$16` as up to four digits at PPU `$19:$18`**: left-justified,
  leading zeros blanked, **everything from 10,000 up shows 9999**; the shop uses it for prices (bank 2 `$851B`). **`$E213` (slot `$C05A`, also `$FD0B`)** sets the gun
  tier `$3A` from the chips (high byte >= 8 -> 3; else other non-zero high byte -> 2; low byte >= `$C8` -> 2, >= `$64` -> 1, else 0) and points the printer at `$272F` (row 25 after CHIP),
  falling through into it. `$E1A3` splits a byte into decimal digits, `$E1D3` queues a blank-suppressed 3-digit number (not committed), `$E1C3` (slot `$C072`) prints `$3E`, the uses left,
  at `$2739`, and `$E169` (entered by falling through from the label routine `$E15F`) draws row 27: area (`$50`, or `$51` in TGL), then `$52`/`$53` with the letters X/Y written over
  the hundreds cell (so 255 shows as X55). **`$E30C` is the LIFE METER** (called first by `$E0F9` every frame): `$49` (shown) steps one unit per frame toward `$48` (real); the bar is
  8-pixel tiles - count ((v-1)/8)+1, fill of the last (v-1) AND 7 - at row 26: tile `$23` (life icon), the tile COUNT as a number (not the life) at `$2740`, then bar tiles `$21` full /
  `$FF` the partial / `$22` empty from PPU `$2743`. Within a tile only the partial tile is redrawn: **5 bytes queued for PPU `$1FF9` (plane 1 rows 1-5 of tile `$FF`) = `$E3F9[fraction]`
  (80 C0 E0 F0 F8 FC FE FF) AND `$E401` (EE FE FF FF EE)**, i.e. the bar's end is drawn by editing CHR RAM; across a tile boundary it also queues the number, the new `$FF` tile and
  the old end tile (`$22` draining, `$21` filling) through `$E406`; no room in the queue = retry next frame. **RUN:** chip counts 0...65535 (all as listed on the page), life 160 -> 32 -> 112
  stepping one unit per frame (tile `$FF` bytes ee fe ff ff ee -> ec fc fc fc ec -> e8 f8 f8 f8 e8 -> e0 f0 f0 f0 e0 -> 80 x5), AREA/X/Y and SHOT rows. `$E424` (reached from the score bonus,
  `$DFAE`) draws the bar's new empty end tile when max life grows - not run. NOT established: `$E110` (the score row) and `$E0F9`'s other branches were not re-read here; hardware.
  Harness lesson: the HUD only redraws on a CHANGE, so a snapshot of a steady state shows stale text.
- **Object helpers, bank 7 `$FA5B-$FCE6` (`annotations/regions/23-object-helpers.json`; found as the largest stretch of traced code nothing explained).**
  Ten regions now replace the generated extent-only cards. **`$FA5B`** find a free slot (5-23; slot `$C108`). **`$FA4B`** (slot `$C105`, ~25 callers) creates a child: type A in slot Y (from `$FA5B`) at the position of object X (copies `$0530`/`$0518` only; RUN). **`$FA6B`** pixel position -> PPU address of the
  8x8 tile (`$2000 + 32(y/8) + x/8`) and attribute offset (slot `$C111`). **`$FA96` BREAK A BLOCK** (slot `$C117`; callers: the weapon-hits-cell code bank 6 `$854B`,
  bank 3 `$92B2`/`$9336`, bank 1 `$8159`): a type-`$30` blast at the cell centre (skipped if no slot), the new tiles queued through `$D865` with `$16`, then the class
  write. **`$FADE`** (slot `$C11D`) writes `$15` into the nibble of the class map `$0400` for the cell at (`$18`, `$19`) - labyrinth only, nothing when `$30` bit 6 is
  set; index = (y AND `$F0`)/2 | x/32, x bit 4 picks the nibble (set = low). RUN: class 0 -> 7 on exactly one cell, blast at (103, 136) from (100, 140), 9 bytes queued; corridor
  = no change. **`$FB12`** one type-`$08` explosion near a point jittered by a box, sound `$22` (slot `$C120`; bank 1 `$80D0` the boss-death barrage, bank 2 `$88EF` the planet
  cutscene); run 300x: y 83-116, x 104-136 for box 32 x 48 at (100, 128). **`$FB52`/`$FB64`** negate the y / x velocity (slots `$C126`/`$C123`; types `$52 $59` / `$5A $52`).
  **`$FB76`-`$FCC2` THE BEAM** (slot `$C129`; weapon 9 = Hyper Laser, bank 6 `$8AC4`, run table entry 9, and enemy type `$22`): a vertical chain of 16-pixel pieces between
  `$0518` and `$0758`, drawn with the object's metasprite (`$0548`) or single sprites (`$CF05`) and a hit box x +/- `$0650` (half-width 3, 8, 24 px at levels 1-3,
  measured), y from the smaller end to the larger + 15; its head/tail state machine (`$FB76`-`$FC26`: parent slot `$0668`, parent type `$0680`, phase `$0788`) is a LEAD.
  **`$FCD5`** (slot `$C12C`) adds the scroll step `$B7` to y in a corridor: ground objects, pickup boxes and types `$16 $63 $7A` stay fixed on the background (carry = off the
  bottom). Two corrections to the notes above: the bank 6 cell-hit entry's "6 -> floor + a type-`$30` blast" is exactly this routine, and `$D865` (the PPU redraw) is called from it.
- **Corridor seals: how corridors 1-10 are unlocked, and the RAM that holds it (`docs/labyrinth.html#seals`).** Two locks per entrance:
  the room's key door (`$04B0`, above) and the SEAL on the gate inside. **State: `$04B1` bits 0-7 = corridors 1-8, `$04B2` bits 0-1 = corridors
  9-10** (bit c-1 set = removed; set through `$C078`/`$EFC7`, A = n -> Y = n>>3, A = 1<<(n&7)); not in the password; corridors 11-20 have
  none. Screen 8 (`$9F44`) puts two type-`$35` halves in slots 5 and 6; slot 6's driver (`$A0F7` -> `$A192`, a 60-frame `$07A0` countdown,
  then `$A19B`) takes byte 2 of the room record minus 1 as `$15`, kills itself at once if `$15` >= 10, otherwise tests the bit
  (`$A1BA`): set -> `$0788` of slot 5 = 1 (opens: `$0638` counts to `$1C`, halves slide), slot 6 removed, sound `$3F`; clear -> the ten-entry inline table
  `$A1C4` (index `$15`), each routine RTSing unless its condition holds, then branching to `$A245` (ORs bit `$15`). The ten: **1** `$A21D`, box A (`$A327`
  table, x 116-140 y 96-120): 50 shot hits (`$0680` of slot 6; each hit makes the shot a type `$0A` spark; ship ignored, `$6E` = hit slot from `$D2AA`);
  **2** `$A25B`: the ship touches four zones (records `$A2A9` [mask][box][spark x][spark y], boxes 80-112/144-176 x 64-96/128-160), mask in `$0680` = `$0F`;
  **3** `$A1D8`: `$A2F8` counts 60 frames -> `$0680`, >= 20 s; **4** `$A1DF` bare RTS: set by the round creature's rooms (screens 2, 6, 7 call `$A2E7`
  on entry; pass -> `$9FD8`: bit 3, sound `$3F`, message 11); **5** `$A256` = `$A21D` with box B (x 96-143, y 16-56): 50 shot hits; **6** `$A1E0`:
  `$4C` (chips, low byte) differs from the value stored at the first call; **7** `$A217` = `$A2E7`: all 6 adjacent pairs of the move history `$04F0` sum to 8
  (exit codes N 0, W 2, E 6, S 8: 7 room changes alternating back and forth through one door); **8** `$A1F5`: `$3C` = 0 (NO USE) and A newly pressed
  (`$F5`/`$F6` bit 7); **9** `$A21D` with the ship itself (`$6E` = 0) on box A; **10** `$A202`: B held (`$F7`/`$F8` bit 6) for 10 s, `$0680` cleared when released. The
  hints are dialogue messages 2 and 12-20 (1-based; sub-id = message number). Once open and `$0638` >= 16, the ship in box A (`$A149`-`$A18F`) is pushed up and
  `$A4` = 4 (enter the corridor). **RUN** from the labyrinth savestate through the real `$EE1D` (`$E4` = the entrance record, bank 5): idle controls stay clear,
  each action sets exactly its bit (1: frame 601; 3: 1,329 frames after entry; 10: 729) except **QUIRK: corridor 2's completion also sets bit 0** - the spark
  far call (bank 1 `$8002`) clobbers `$15` to 0 in the pass that finishes the 4th zone and `$A245` runs once with it. For 4, 6, 7 the harness set `$4C` /
  `$04F0` directly. Corridor 21's gate (screen 0) needs `$04A9`/`$04AA` bits for 1-10 (cleared = boss beaten, a different flag). NOT checked on hardware;
  `$EE1D` ran with a fake `$E4`, not by walking in. Corrects the Labyrinth page ("each seal ... not read yet") and the first `ram.json` entry for `$04B1`.
- **The squares before a boss (owner's `fade` savestate; `docs/enemies.html#dissolve`).** Corridor 5, row 467 (still scrolling), four
  objects of type `$A8` = `$28` + bit 7, metasprite 121, slot 12 empty, slots 13/14 = `$41`/`$35`. **Trigger:** screen-data command 7 at
  row 465 starts stream `$AAE2` (slot 12 empty, 13 <- `$41`, 14 <- `$35`), five rows before the boss command (row 470). Per record
  `$E9C3` zeroes the slot and `$E9D1`-`$E9E7` converts every live object (slots 5-23) whose `$CFB6[type]` (via `$CF4C`) is the evicted block to
  type `$28`: the enemies that used the old art (`$1A`: block `$3C`, `$59`: block `$1E`) dissolve, others and art-less objects do not.
  Type `$28` (bank 6 `$9972`, hp 0, flags `$C0`): 16-step table (`$99C9` metasprite, `$99D9` base tile, `$99E9` piece offsets): metasprite 121
  with tiles 1/3 alternating, then 5, 7; then metasprite 55 (tiles 9, B, D, F) - ~32 + ~10 frames, 42 measured, then the slot is free. **Run:**
  the real corridor 5 loader with a `$1A` and a `$59` placed at row 464 turn to `$28` on the frames after slots 13 and 14 are evicted
  (5303 / 5312); a `$3F` control stays. 18 corridors (1-6, 8-16, 18-20) have such a pre-boss stream 0-30 rows before the
  boss command (usually 5-10; 12: 30; 3, 13, 14, 15: 0), corridor 21 loads several, 7, 17, 22 none. SEPARATE from it: the boss command (cmd 5 -> `$70` = 1) then runs `$91A0`: `$71` =
  `$913A[corridor]` (`88` for all but 7, 17 = `02`, 21 and 22 = `00`): bit 7 turns every non-spawner object with `$0578` bit 1 clear
  into an explosion (type `$08`, sound `$22`), bit 3 -> `$60` bit 3 (spawns stop). The dissolve is therefore the art swap's side
  effect, not a designed transformation; whether the designers meant it is not knowable. Pairs with the corridor-12 note above.
  NOT checked on hardware. (`$71` was already in `ram.json`.)
- **Corridors 7 and 12 spawn types whose art is never loaded - run on the real corridor loader (model).** The five
  "misses" of `parse-enemies.py --areas` were guessed to rely on art left loaded earlier. **CORRECTION: they do not.**
  A corridor start leaves only its own streams' blocks in the 16 slots `$0480` (bank 5 `$A442` clears them at area setup;
  observed: corridor 12 ends with `$39 $52 $18 $21 - $43` and nothing else), and `$CF5F` (reached through `$C0A8`, which every
  one of these handlers calls) makes an enemy without its block wait 768 frames, undrawn, then removes it (as for corridor 16).
  **Corridor 12** (script `$A233`): streams `$9D43`/`$9D55` are corridor 1's, loading `$20 $1F` (types `$42`, `$43`) but not
  `$25 $22` (types `$63` ×10 at row 350, `$64` ×4 at rows 150, 190, 500): **14 of its 64 spawned objects are invisible**,
  measured 7,718 / 3,081 frames with no art against 10 × 768 = 7,680 / 4 × 768 = 3,072. `$A048` (corridors 2 and 11) loads all
  four blocks. Corridors 1, 2, 11, 12 share scene 33; their stream pointers are 1 `$9D43`, 2 `$9EFD`+`$A048`, 11 `$A048`+`$A05D`,
  12 `$9D43`+`$9D55` - 12 repeats 1's, the other pairs (3/13 ... 10/20) share a stream. LEAD: a wrong pointer in corridor 12's
  block (`$A09F`: `43 9D`). The row-960 stream swaps slots 4/5 to `$43` (pre-boss art, 30 rows before its boss command, as
  corridor 1's `$9D55` is 5 rows before its) and the objects using the old blocks become type `$28` - by design, not a bug.
  **Corridor 7** (script `$B165`): one `$1E` (block `$12`: types `$1D`-`$1F`; no corridor stream loads it) among 107 objects, at
  row ~294, invisible for 768 frames (seen leaving between frames 3,400 and 4,000). Not explained: why the script has it; the
  data cannot say. **Harness lesson:** a corridor started from the `ingame` savestate keeps that savestate's objects (`$6D`,
  `$7B`) in the slots unless they are cleared - with them, corridor 7's slots filled with `$27` shots and the `$1E` spawn
  seemed to fail. NOT checked on hardware.
- **Corridor 16's spawn script (bank 4 `$AFDC`-`$B010`): the game misreads its own tail.** The walk ran into `$B011`, the next
  structure. Last bytes `A0 04 5A | E3 0F 28 | 96 EA 05 | 64 | 64 | 02`. The interpreter (`$F78F`) treats a byte >= `$80`
  after a spawn as the NEXT SPAWN, never a delay, so `96` is formation `$16` x `$EA` (234) every 5 frames, then
  delay `64`, spawn `$64`, delay 2, then command 0 with operand `00` = a wait of 258 rows, spawn `$04` at script row 1,309
  (the boss command 5 fires at stage row `0x532` = 1,330) and junk after. Read with `96` as a delay (150), the same bytes are
  delay `96`, formation `$6A` x 5 / `$64`, delay `64`, **end** - and `02` is exactly the last byte before `$B011`: the
  intended end. `$16` and `$64` are the two types in this script whose art block (`$3A`, `$22`) corridor 16's streams
  never load - the project's own "misses" list had flagged them. `$CF5F`: an enemy whose block is not in the 16 loaded-block
  slots (`$0480`) is not drawn, counts `$0758`/`$0770` down and is removed after **768 frames** (measured). Run on the
  model (corridor-15 savestate, so speed and art differ; script rows = rows scrolled): at row 951 the three formations
  spawn together, and from then **14-16 of the 19 enemy slots hold invisible type-`$16` objects**, so `$20` x 4 and `$63` x 15
  get one or two slots at a time; the spawner alone would need ~11,000 frames to finish its 234 (16 slots / 768 frames).
  The boss still got a slot immediately in 3 trials (the allocator `$EA8C` also reuses slots whose type has bit 7 set;
  not traced fully), and ghosts have no handler, so they cannot hurt. Same bug class as the five labyrinth scripts: the data
  is written for a different interpreter reading than the one in the ROM. NOT established: any of it on hardware, the
  delays of those five as the author meant them, corridor 16's own scroll speed, and whether the slot starvation is
  visible in play (the real formations are mostly missing in the model).
- **The five bank 5 spawn scripts that end `[byte] 01 02` - RUN (`tools/run-spawn-script.py`, the model).** Ids 16, 24,
  28, 32, 38 (28 rooms). Interpreter `$F78F`, read in full: after any spawn or formation the next byte is its delay
  (a bit-7 byte instead chains the next spawn), so `[byte]` is a WAIT - in seconds in the labyrinth (`$69` counts 60
  frames, `$68` seconds), `$70/$70/$54/$73/$1E` = 112/112/84/115/30 s - not the single spawn the data looks like
  (those values are types other scripts spawn on their own). Command 1 reads `lo hi`: lo is the script's own `02`,
  hi the next script's first byte, so the target is `$6F02/$7202/$9002/$F002/$6502`. Run: 28 and 32 land in ROM
  (bank 5 map data, fixed-bank code) and are interpreted as script - a long junk stream of formations and objects;
  16, 24, 38 land in `$6000-$7FFF`, nothing on this cartridge. **Open bus** there; if the value is the pointer high
  byte (the 6502's last fetch before `LDA ($66),Y`) the interpreter spawns that type once per wait for ever (`$6F`,
  `$72`, `$65` every ~111/114/101 s); with 0 it does nothing for 255 s. LEAD: the open-bus value is inferred, not
  checked on FCEUX or a console. Whether the author meant "formation, then a spawn" (the encoding looks like a script
  compiler dropping the formation's delay) is a guess. Corrects "read as a long wait... open". The line in
  `parse-enemies.py` about scripts that "end on a jump, back into itself" is about the corridor scripts of bank 4.
- **The last 34 unclaimed bytes (`annotations/regions/79-last-gaps.json`); the ROM is now 100.000% claimed.**
  Three are **palette lists** for the walker at bank 7 `$D92D` (entry `$C05D`, pointer in `$18/$19`): position Y
  0-7, value below `$FE`, far-calls bank 5 `$B2E4`, which copies palette A (of the 36 at `$B30A`) to `$0181 + 3Y`;
  `$FE` ends, `$FF` skips; positions 0-3 are background, 4-7 sprite palettes. **Bank 0 `$82BD`** = `08 09 0A 0B 00 01 02 03`,
  read at `$8321` after the title picture is drawn (`$8485`): HARDWARE, the title savestate's palette RAM holds exactly
  those 8 palettes (8 of 8; the password savestate's slots 0-3 too). **Bank 5 `$84C3`** = `05 0F 1F FF 00 01 02 03`, the status
  screen's, read from `$84EE` (code only, no savestate; slot 3 skipped). Found, as the world map was, by scanning for
  a pointer built from two immediates - no table points at them. **Bank 7 `$EEC4`** (`00 01 02 03 05 06 09 0A`) has
  the same shape and NO reader, and `$A9BA` (`FE 02 FF 01 00`, after the cannon handler's two-byte table),
  `$B902` (`78 64`, between two handlers) and bank 0 `$BF04` (`12 E9 82`: a note, a repeat, a track end, no
  header points at it) are leads. **Method note:** a byte scan for absolute operands finds nothing for the first two
  - the reader hid the address in immediates; scan for both.
- **Rendering: mirroring, the NMI, the split, scrolling (`docs/rendering.html`).** iNES byte 6 = `$21`: vertical
  mirroring, and the game RELIES on it: horizontal room scrolls cross `$2000`/`$2400`, and the corridor engine alternates its
  row writes between `$2000` and the `$2800` alias (`$AB`; 216 of ~1000 writes in 120 frames). NMI `$DC75`: render off,
  OAM DMA, `$4015=$1F`, `$DD54` (one pending row via `$A5` 1/2/3, then the `$0100` queue) + `$DEC9` palettes, the `$FE`
  marker if `$30` bit 4, `$D68B` (`$2000=$FF`, `$2005=$FD,$FC`), render on `|$A3`. **Split:** sprite 0 = y 191, tile `$FF`
  (8x16: tiles `$FE`/`$FF` of table 1, `$FE` solid), x 0, behind the BG; a solid BG tile `$FE` in column 0 at line 192
  (labyrinth: the room's row 24 via `$F03D`; corridor: written by the NMI at row ((192+`$A6`) mod 240)/8); on the hit
  `$DD21` loads `$2006=$2700` (NT1 row 24, fine y 2), forces NT1 in `$2000`, clears sprites in `$2001`, `$2005=0,0`: the
  HUD is NT1 rows 24-29 (24 blank, 25 SC/CHIP/SHOT, 26 meter, 27 AREA/X/Y). Done by the main thread (`$DAB6`) or by the
  DMC IRQ (`$DCF3`; 17-byte zero sample = 136 periods; `$05` walked `$87`->`$89`, +1 when late) - IRQ arithmetic only, the
  harness has none. **Corridor:** NT0 only, window 192 of 240 lines, `$A6` counts DOWN by `$B7` (speed `$B8/$B9`),
  wraps 0->239 with `$A7` toggling, a 16-px row every `$AF` overflow (`$AE` 14..0, `$EACC` -> `$AC/$AD`, written in two
  NMIs), 4-6 tile rows above the window top. **Labyrinth:** room = NT0 rows 0-23 at rest; exits (`$A4` 0/2/6/8 = N/W/E/S):
  E/W scroll `$A8` +/-4 a frame, 64 frames, new room drawn in NT1 first (W starts at `$A8`=252 with `$A9`=1), N/S `$A6`
  +/-4, 48 frames, new room drawn into the rows being uncovered; ship moves the other way (N/S exactly 3 px a frame; E/W alternately 3 and 4 - CORRECTED, see the room-scroll entry); then re-homed
  into NT0 (E/W: the room is REDRAWN into NT0 from the room buffer, not copied; N/S: draw to NT1, flip, draw to NT0, flip) because the cell-editing code (`$D865`)
  assumes NT0. **Status screen:** `$A2`=1, `$FC`=180, NT1, no split (HUD rows wrap to the top). All measured on the NES
  model (`tools/render-scroll.py --corridor ... --labyrinth ...`, images committed); no hardware. NOT established: the
  IRQ path run, `$F0A8-$F0C1` inline fills, the title/ending/password screens' scrolling.
  **CORRECTION:** the RAM-map lead `$AA-$AE` 'scroll helpers/velocity' was wrong: they are the row's attribute
  address, row table half, PPU address and row index.
- **The game loop (`docs/gameloop.html`; `tools/trace-frame.py --state ...ingame.fcs` reproduces it).** Bank 7 `$FF7A`:
  `E655` (stage step) -> `FF8B` once (`DA9A` frame sync, `F493` pads, bank 6 `$81FB` object loop, `E0F9` HUD,
  `DB52` decompressor) -> bank 3 `$917F` (boss/stage `$70`, a no-op unless a boss) -> loop. So a frame STARTS at the sync:
  NMI (0-~2,230 cycles, incl. the ~1,600-cycle sound tick) -> pads ~2,256 -> objects ~3,245 (slot 0-4 then 5-23, order
  flips every 2 frames by `$36` bit 1) -> `CE88` ~8,830 -> HUD ~9,005 -> decompressor -> `$917F` -> `E655` ~9,450 (a new
  row every 16 px: stream records, `E8AB`, tiles, ground objects ~5,000 cycles) -> `E995` loader + spawn script (waits count
  rows while scrolling, 60-frame seconds when stopped) -> sync ~9,990 -> spin on sprite 0 -> split at 24,227 -> NMI at
  29,781. 400 corridor frames on the NES model: logic ends at median 9,987 (max 16,355), 38 new-row frames, no overrun
  (NMI never already fired at `DA9A`). Sprites built in the loop and the scroll set in `E655` reach the screen at the NEXT
  NMI (one frame latency). Hit detection is in the ENEMIES' handlers (`D348`, slots 4..0, flags & mask). Periodic: HUD score
  every 8th frame (`$41&7`), weapon-object damage every 8th (`$D3A9`), boss bonus 64 (`$9305`), chip fee 60/120 (`$3F`).
  NOT established: hardware timing (model has no DMA stalls/IRQ), the allocator's hiding loop in detail (`$81`/`$82`; the flags are in the allocator entry), every handler.
  **Durations, five corridor states (`tools/profile-loop.py`, data in `annotations/loop-profile.json`, 900 frames each; the
  page's tables are built from that file):** calm (`ingame`) / more1 / more2 / more3 / more4 (the owner's busy savestates; more4
  = corridor 8 boss fight, Grimgrin `$49`, 63 sprites). Net of the NMI, medians: pads 989; object loop 6,143 / 13,127 / 15,210 / 8,119 /
  26,478 (loop's own dispatch 74-90); finish 141; HUD 72 idle; decompressor 244 idle; boss 61-104; stage step 195, or 5,200-6,900 when it
  builds a row; loader 168; logic total 8,138 / 15,289 / 18,325 / 10,146 / 28,780 (27% / 51% / 62% / 34% / 97% of 29,781). NMI 1,555-4,595
  (median ~2,100-2,300). Per handler call: ship ~2,250, Grimgrin 9,173, Zibzub 5,668, ordinary enemies 450-2,100, spawner/controllers 70-500,
  explosion ~680. Loop speed 59.9 iterations/s in the first four (late frames 0/71/266/33), 56.5 in more4 (848 of 900 frames, 887 late);
  an iteration over a frame makes `$DA9A` skip its waits so the next is short (the game's speed holds, the picture judders); the main
  thread misses the HUD split in 0/90/309/47/893 of 900 frames (on hardware the DMC IRQ does it). NMI is longer than vblank in
  29-53% of frames in the model (rendering is off meanwhile: top lines blank, arithmetic only). A one-off 192,000-cycle stall was seen once
  in an earlier more3 run with a different life hold and not reproduced (`$D7C3` spins until the NMI drains a full PPU queue: a lead).
  **Profiler lesson:** the life hold must be applied from the first frame and the HUD meter `$49` set equal to `$48`; the first runs let
  the ship die during settling and `$48` > `$47` made the meter animate, which skewed the numbers.
  **Labyrinth frame (same page, `#labyrinth-loop`):** the same loop and order; `$E655` skips scroll/rows/stream (34 cycles to
  `E995`), no marker rewrite, spawn waits in 60-frame seconds, shots look up cells. 300 frames: logic ends median ~12,000,
  max 13,516, load follows enemy count (no new-row spikes). Player (bank 3 `$8D03`): facing from `$32` -> `$0668`, speed class
  3 = 1.4 px/frame (corridor 5 = 2.3; measured), moves via far call bank 6 `$826D` (target cells from `$0400`, `$8425`
  blocks, snaps and slides along walls, foot offset `$06B0` = 8), cell events on class change (`$8FBF`: 1 sphere, 2 warp
  panel), room edges (`$9045`: y<16 / >=176, x<14 / >=242; exit if `$54` bit open and `$58-$5B` = 8 -> `$A4` 0/2/6/8 N/W/E/S
  + `$A0` bit 0). The exit is acted on at the next `E655` -> `$EB18`, which does not return until the new room is up: the
  loop is SUSPENDED (no pads, objects, HUD, boss routine; only the ship is drawn, `F258`) for 98 frames east, 81 north and
  81 south (measured).
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
  `$51 = $ED08[$77++]` — 1, 11, 12, 2, 13, 3, … 10, 21, every corridor once — and after 21 the
  cutscene and corridor 22 (see the boss entry; what follows 22 is not traced). **Rewards by score:** corridor start copies the score to `$04B9` (`$EF86`), the
  boss turns it into points gained (bank 3 `$91A7`) and ticks 10 off every 64 frames of the
  fight (`$9305`); bank 6 `$805A` adds it to a running total `$04B3` and sets `$15` = total /
  10,000 displayed points. `$80E7` gives each `$817A` entry from `$76` on whose threshold ≤
  `$15`, via the pick-up routine `$86BC`, at most five a screen. **Scores are stored in tens**:
  the HUD prints a fixed 0 after the six digits (labyrinth savestate: `001684` → `16840`).
  `docs/password.html` tabulates all 73. Not played.
- **The demo (attract mode), from the code.** The title song sets `$0300` (command `$94`,
  flag `$10`, at `$9D06`) after one pass of its melody; the title loop (`$835A`) returns, and
  the game setup bank 0 `$805B` without Start held builds a demo state at `$8107-$8145`: life
  `$80`, all weapons level 2, attack/shield 2, chip level 6 full, fire rate 2, random `$3C`,
  `$30` bit 7. `$EB18` picks corridor `$F9D1 AND $0F`. **Input is not recorded:** `$DAE1`
  (`$C02D`, from the player's handler) overwrites `$F5-$F8` each frame with `$DB33-$DB51`
  (31 patterns, all A+B plus a direction), stepping from a random start every 24-40 random
  frames; index 32 reads the decoder's first byte `$A5` (A+Select+Down+Right). Ends on the
  `$F0/$F1` timer (~`$1C` × 256 frames), the stage ending (`$EBA2`) or a real Start (`$F4A3`),
  each `JMP $FF4A`. Not checked on hardware.
- **The sound test (owner's claim, CONFIRMED from the code).** Reset and power-on run bank 0
  `$8332` (entry `$800C`, from `$FF50`); `$8341` tests `$F7 == $C0` — A and B held, nothing
  else — and far-calls bank 3 `$801B` → `$822A`: SOUND TEST, sound number 1-71 at PPU `$20CD`,
  Right/Left step (wrapping), Down plays (`$C030`), Up silences (bank 0 `$97A0`). The one
  far call to it in the ROM. Not tried on hardware. `annotations/external.json` has it.
- **The reset path verifies the mapper.** `$FF23-$FF43` loops Y from 6 down to 0: select
  bank Y, `CPY $BFFF`, and fall through only if the bank answered with its own number.
  On a mismatch it fetches a code from `$FF3A,Y`, stores it at `$0180`, calls `$DED2` and
  spins at `JMP $FF37` forever. The seven `$BFFF` bytes are annotated one per bank.

## Named so far

The RAM map exists: `annotations/ram.json`, drawn on `docs/ram.html` beside a generated
cross-reference. Add a name there (with its evidence and a status), not here. It now names 85% of the touched bytes (175 entries, 33 sound fields) and the page's "busiest unnamed bytes"
table is EMPTY: every touched byte below $0500 is named, or listed under "Counted but not bytes" (`base_artifacts`
in ram.json: an indexed access names a base, and with Y starting at 1 the base is the byte before the data - $016F,
$017B, $0136-$0137), or is a lead. The RAM map has no `lead` entries left; what remains is the object-slot fields. Worked out from the busiest unnamed list: the sound engine's whole channel
state (`$0319 + 7f + c`, 33 fields, ends exactly at `$03FF`; `$1C-$1F` its scratch; `$0300` is the
song-event register: a `$94` command ORs into it and a channel's end stores its song number), the
tile decompressor's state (`$09-$0F`), the PPU queue's cursor (`$21`, reserve `$25`), the art-load
stream (`$27-$29`), `$2A` the random state, the sprite allocator (`$80-$83`) and the scroll
registers. **CORRECTION:** `$FC` is the vertical and `$FD` the horizontal scroll shadow (`$D68B`
writes `$FD` first), so `$A6`/`$A7` are scroll Y and its nametable bit and `$A8`/`$A9` scroll X and
its; the older note that `$FC` is "added to `$0200` in NMI" was the raster-split IRQ adding the
vertical scroll to sprite 0's Y (`$DCB0`).

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

1. **Name the remaining (non-boss) enemy types.** The bosses are named (see the boss entry);
   the manual's nine names are all placed. A savestate with known enemies on screen would
   settle it, and `parse-metasprites.py --verify` would check their shapes.
2. **Leads, now that every byte is claimed (100.000%).** `build.py` counts them; past 97% most of the coverage is
   leads, i.e. accounted for, not understood. The last six gaps are in `79-last-gaps.json` (see the entry above);
   three are leads with no reader (bank 7 `$EEC4`, bank 6 `$A9BA` and `$B902`, bank 0 `$BF04`). Which rooms take
   the room drawer's special path (`$30` bits 5-6).
3. **Other bank 5/bank 4 script quirks** - none open here; see the corridor 7/12 and 16 entries.
4. **What `$55`, `$04A0-$04A8`, `$46` and `$6B` hold** — all now have known writers.
5. **The other `$16`/`$17` consumers** — `$C04B`, `$C006`, `$C07E` (a rectangle blit,
   `$D99C`).
6. The RAM map has no `lead` entries and an empty unnamed table; what is left is the object-slot fields and the rest of the allocator's hiding loop.
