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
- **Bank 4 is per-area screen data.** 25 pointers at `$8013`, indexed by the area number in
  `$51` (bounded by `CPY #$15` at `$F2E2`), reached from `$EF9B`. Its entry point returns a
  pointer instead of running code, which is why a control-flow trace found 19 bytes of it.
  The blocks are a command stream walked through `($BC)` and dispatched by the 10-entry
  table at `$E6F3` — resolved, bounded by the table ending where handler 0 begins.
- **The reset path verifies the mapper.** `$FF23-$FF43` loops Y from 6 down to 0: select
  bank Y, `CPY $BFFF`, and fall through only if the bank answered with its own number.
  On a mismatch it fetches a code from `$FF3A,Y`, stores it at `$0180`, calls `$DED2` and
  spins at `JMP $FF37` forever. The seven `$BFFF` bytes are annotated one per bank.

## Named so far, and nowhere to write it down

There is no RAM map yet. These came out of the code read so far and should go into one as
soon as it exists: `$04` (live PRG bank), `$05` (the DMC timer's rate index, reloaded into `DMC_FREQ` by the IRQ
handler and tuned between `$81` and `$89` to land the raster split), `$10`/`$11` (saved A/Y across a far call), `$12`/`$13` (the far-call inline
pointer), `$26` (`PPUSTATUS` snapshot taken in NMI), `$2B` (frame counter, incremented in
NMI and read by the IRQ handler), `$2F` (branched on at `$FF53` in the boot path), `$30`
(bit 4 tested in NMI), `$FC` (added to `$0200` in NMI), `$FE` (`PPUMASK` shadow).

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

1. **Find bank 0's tile blocks.** The title screen is 18 of 512 tiles explained, so a whole
   tileset is unaccounted for and bank 0 is where it is. The partition test is the tool: a
   real table makes every block's decoded length land on the next pointer. Do not accept a
   candidate that only produces plausible-looking tiles. Bank 0 is now 79% documented, so
   the search space is much smaller than it was.
2. **Find the graphics decompressor.** It has to write into the `$0100` queue, and no scan
   so far has found a reader of the three tile pointer tables. Worth trying from the other
   end: a savestate taken *during* a load would have the block pointer live in zero page.
3. **Read the ten screen-data command handlers** and parse bank 4's blocks. Bank 4 is still
   0.4% documented, and that is 16 KB behind one format — the largest single unknown left.
4. **Resolve the remaining inline jump tables** (bank 5 `$9F2F`, `$A1C1`) into
   `dispatch.json`. The entry count must come from each caller, never from dividing a gap.
5. Identify what each of the 21 sound commands actually does, and which song id is which
   piece of music. The names in `tools/tgl/sound.py` are read off the handlers' stores.
6. Explain the second header byte of a tile block, and the three bank 1 blocks whose output
   is exactly 3 bytes over a whole number of tiles (`$89E4`, `$9A89`, `$A60C`).
7. Start a RAM map. Page 3 is now almost entirely sound state and should go in first:
   `$0300-$0307` driver globals, `$0308-$0317` the APU shadow, `$0319+7f+c` the channel
   fields.
