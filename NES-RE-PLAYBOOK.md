# Reverse-engineering an NES ROM, byte by byte

A playbook for an AI agent starting a new cartridge from nothing. It is written from one completed
project — a 256 KB AxROM game taken to 99.99% of its bytes accounted for — and everything in it is a
lesson that cost something to learn. The game-specific facts are gone; what is left is the method, the
tools worth building, the idioms 6502 game code actually uses, and the ways this kind of work goes
wrong.

Read it once before starting, and again when you are stuck. The sections to read when stuck are
**"When a gap will not fall"** and **"How this work goes wrong"**.

---

## 0. The one rule

**A claim about the ROM must be checked against the ROM.**

Outside sources — wikis, guides, TAS pages, other people's disassemblies — describe *the game*. You are
documenting *a ROM image*. The two only meet where a claim has been put against the bytes. Keep the
distinction in the artefacts themselves, not just in your head: mark every external claim *Confirmed*,
*Lead*, or *Checked, absent*, and never let a lead be written into an annotation as though it were
established.

Two corollaries that matter more than they sound:

- **Accounting for a byte and understanding it are different claims.** A bank can reach 100% coverage
  with its main data format still undecoded. That is a fine state to be in. Say which one you are in,
  in the annotation, every time.
- **Corrections are stated, not quietly edited.** When a published finding turns out wrong, record it
  *as* a correction with what the mistake was. That history is worth more than a clean-looking
  document — it is the only thing that stops the next agent making the same inference.

---

## 1. Set the project up so the machine checks you

Do this before any analysis. Prose is not checked by anything; make the ground truth machine-verified
from day one.

### The annotation store

Hand-author JSON, generate everything else. One region per claim:

```json
{
  "id": "bank1.gfx_D3C5",
  "offset": 54229,
  "size": 960,
  "bank": 1,
  "cpu_addr": 54213,
  "kind": "graphics",
  "codec": "raw",
  "name": "...",
  "sha1": "db50271...",
  "description": "the evidence, including what has NOT been established"
}
```

`offset` is the absolute file offset, `cpu_addr` where the bytes are mapped when live, `kind` one of
code / graphics / table / text / music / data / padding, `codec` mandatory for graphics (see §7).

### What the build must enforce

- **Every region declares a SHA-1 of its own bytes.** A wrong offset cannot survive a rebuild.
- **Regions may not overlap.** This catches real errors constantly: a data block swallowing traced
  code, a table with a negative size, a mis-set outer limit.
- **Named fields may declare their literal bytes**, checked the same way.
- **A full regeneration must produce no diff.** If it does, something is non-deterministic, and that
  is a bug. Add a `--check` mode that validates and writes nothing.
- **Coverage percentages are computed, never typed.** A number in prose is not checked by anything.
  This project carried a stale figure in its own instructions long enough for it to be cited as the
  state of play while the generated file in the same commit said otherwise.

When the build refuses something, the build is usually right.

### The reassembly check — build this early

Generate assembler source (ca65 or similar) from your region map, reassemble it, and **refuse to write
unless the image is the ROM byte for byte.** This is not decoration. On its first two runs here it
threw out two wrong instruction-start addresses, one of them a hand-entered routine address.

A hand-entered address is an assertion nothing else checks. Seeding a tracer from a typo turns it into
claimed ground, and the disassembly will still read fine — 6502 has no alignment, so starting four
bytes early produces legal instructions that fall into the real routine.

### Generator ordering

Generators run in a fixed order and each excludes its own previous output when loading, or it sees its
last run as already-claimed ground and emits nothing. Later generators read earlier ones' output as
settled.

---

## 2. Know the cartridge before the code

Get these right first; every later number depends on them.

- **Mapper, bank size, bank count.** Choose your own bank numbering and *write down the conversion to
  every other numbering you will meet*. FCEUX's debugger numbers PRG banks in 16 KB units. If your ROM
  swaps 32 KB, one of your banks is two of its: `your bank N ↔ FCEUX 2N and 2N+1`. **The mismatch is
  silent** — a given address exists in every bank, so a mis-attributed debugger report looks perfectly
  reasonable. Verify the conversion once against a known file offset, then automate it.
- **CHR ROM or CHR RAM.** With CHR RAM, tiles are uploaded from PRG by code, and finding the *uploaders*
  is the whole graphics problem (§7).
- **Mirroring, and whether the mapper controls it.** One-screen mirroring means the same nametable
  address can be two different bytes depending on a latch bit. Two writes to the same nametable address
  are not necessarily a conflict — check the latch first. A status panel and a main view can live at
  overlapping addresses on different pages, composited by a mid-frame swap on a sprite 0 hit.
- **Bus conflicts.** On AxROM-likes, bank switching is `STA $FFCB,Y` into a table that already holds the
  bank numbers. Recognising the idiom instantly is worth a lot.
- **What is identical in every bank.** Here, a 128-byte tail (boot stub, NMI stub, far-call trampoline,
  bank table) was byte-identical in all eight banks, and that fact explains the shape of the entire ROM.
- **Public entry points.** If every bank opens with a `JMP` table, that table *is* the complete
  inventory of cross-bank entries. Resolve every far call against it and check the count closes.

**Build `whereis.py` on day one.** Given an address plus a bank number (yours or the debugger's), it
prints the file offset, both bank numberings, the region or the gap it lands in, and disassembles a few
instructions. Give it a `--bytes "B1 FB 30 03"` option that says *which bank really has those bytes* —
when reading any external report, **always ask for the bytes at PC**; a four-byte sequence is usually
unique in the whole ROM and settles the bank when nothing else can.

---

## 3. The working loop

This produced hundreds of regions and never changed:

1. Trace code from every entry you can establish (§4).
2. Run `find-readers` on a bank: absolute-indexed reads whose base lands in unclaimed bytes.
3. Disassemble the sites it names.
4. Dump the bytes at each base.
5. **Keep only the tables whose shape the reader actually accounts for.**
6. Each new block should land on its neighbour with nothing over.

Bases where the gap *starts* at that exact address are the strongest hits — both edges are pinned. Do
those first.

**Entry counts come from base spacing, an index mask, a `CPY`/`CPX` bound, or a terminator the reader
branches on. Never from dividing a gap.** Dividing a gap by a record size and taking the quotient is
how you get a plausible wrong number; here it produced 340 "records", twelve of which were
byte-identical copies that nothing reads, while the real count was a field in a record already decoded
two bytes away.

---

## 4. Making code reachable

Static tracing stalls at exactly the places that hide the most bytes. Each of these is worth
implementing as a distinct seed source.

- **Reset and NMI vectors** — but note the NMI may go through a RAM vector (`JMP ($050A)`). No static
  trace follows that. Here it hid **a quarter of one bank**: eighteen vblank handlers, all in the bank
  that owns the vector, plus everything downstream. Find every routine that *installs* the vector and
  every call site that hands it an address — and expect variants: `JSR` sites, `JMP` sites, and one
  handler that stored the vector inline. Grepping for the obvious installer found three of eighteen.
- **Resume points, not calls.** A handler may end `PLP / LDX #$FF / TXS / JMP $xxxx` instead of `RTI`:
  it resets the stack and re-enters a mode body at a fixed address once a frame. Nothing `JSR`s or
  `JMP`s there, so those bytes sit in a gap looking like data.
- **Setup and body sit back to back.** A mode's setup routine ends by installing its vblank handler, and
  that handler's resume tail jumps to *the byte immediately after the install*. So: when a resume point
  is known, read the bytes before it; when an install site turns up in unclaimed bytes, the routine
  containing it is a mode entry.
- **The two check each other, and that is what makes the answer trustworthy.** Scan the bank for the
  install shape to get candidates; keep only those whose own run reaches exactly one resume tail. Here
  they agreed exactly — 18 candidates, 18 kept, one tail each, all 18 tails accounted for with none
  left over. Neither half alone works: scanning only *covered* code misses the handler whose install
  site sits inside a mode body that is itself only reachable through that same handler.
- **Dispatch tables**, resolved by hand and fed back into the tracer. Keep a registry file with an
  `unresolved` list — but know that an empty `unresolved` list is a **weaker statement than it sounds**:
  it says every table the file knows about is resolved. A five-entry split dispatch sitting in a gap,
  registered by nobody, was never unresolved — it was absent. **A gap whose first bytes are a run of
  plausible addresses is a table nobody registered**; the tell is a repeated high byte sitting where a
  low-byte array would end.
- **Far-call trampolines** — resolve `LDA #bank / LDY #offset / JSR $trampoline` into the target bank's
  entry table. A far call is the one reference in this ROM that **no grep for an operand will ever
  surface**. When a routine is understood, follow its far calls before writing it up.

**"Nothing reaches this" is a claim about the searcher, not the ROM.** This project published a list of
eight code blocks that "nothing calls", found by sweeping gaps, decoding them linearly and checking
every `JSR`, `JMP`, branch and fall-through in the bank. The half of that claim about them being
instructions was right. The reachability half was wrong **eight times out of eight**. If you must write
one down, **write down which mechanisms it was tested against**, so the next reader knows what to extend
instead of what to trust.

---

## 5. Idioms 6502 game code actually uses

Knowing these saves hours. Most "impossible" gaps are one of them.

- **Split pointer tables.** All the low bytes, then all the high bytes. A search for contiguous
  little-endian pairs misses every one — that is how this project once reported "there is no pointer
  table for the messages" while it sat immediately in front of the text.
- **Parallel arrays read with one index.** Sources, lengths, keys, values as separate arrays. **The
  order is not fixed** — one bank put its *lengths* first. **Nor is a pointer table in address order**:
  three blocks packed in address order were read by the table as 0, 2, 1, and a generator numbered them
  by address for the whole life of the file. Never infer an index from where a block sits; read the
  table.
- **N bases a fixed distance apart is N parallel arrays, and the distance is the entry count.** The
  cleanest instance here: five bases exactly 42 apart, reader indexed by the screen selector, 5 × 42 =
  210 = the gap. The roles then read straight off the code — two arrays a split pointer, one a length
  bounding a copy loop as `CPY`, the other two a second split pointer.
- **Far calls**: `LDA #bank / LDY #offset / JSR $FFAC`.
- **Bank switching** is `STA $bank_table,Y`.
- **Several banks each carry their own copy of the decompressor** rather than sharing one.
- **Blocks are bounded by the next pointer.** Nothing records lengths. Only safe when the result tiles
  exactly — check that it does, and say so in the description.
- **Sources are built from immediates, not operands.** A CHR loader may name none of the addresses it
  reads: each is an `LDA #lo / LDY #hi` pair handed to an uploader with a count in a register. A search
  for the address as an operand reports the block unreferenced — which this project published once.
  **When looking for who reads an address, search for the immediates as well as the operand.**
- **A record chain can be confirmed by the constant it lands on.** Walking variable-length records for
  exactly N screens arrived at an address the same routine loads as an immediate eight instructions
  later. A walk that ends on a constant the code names is not a boundary you have to argue for.
- **A tile number in a record is not always an index into a sheet.** Check whether anything is *added*
  to the tile byte between the record and OAM. One `ADC` decides whether the numbers mean anything
  absolute at all.
- **A handler that presets one byte and falls into its neighbour is the mirrored variant.** Two dispatch
  entries three bytes apart are one routine, not two, and the pair is usually one creature mounted two
  ways. Read a dispatch table with adjacent near-identical targets as pairs before counting distinct
  behaviours.
- **An animation is often the sprite id being stepped, not a frame table.** Grep for `INC`/`DEC` on the
  sprite-id RAM byte before writing adjacent records up as separate objects.
- **Two fields in one byte**, whenever a column of values is all multiples of a power of two. A column
  that never uses its low bits is a column that has been masked. **The tell is `AND` twice on one
  address** — `LDA ($10),Y / AND #$07 / TAX / LDA ($10),Y / AND #$F8`. `find-readers` will never surface
  it, because both reads are of the same address.
- **Records with no length field can still be exactly bounded, if they chain.** Sort by pointer, check
  each against the end of the one before, and the block should partition with no gap and no overlap. A
  chain that closes over thousands of bytes is not a coincidence you have to argue about.
- **When a record is reached by two pointers, the second is a boundary you did not have to argue for.**
- **A stride can be arithmetic rather than a constant** — `n*288` built as `n*9` shifted five times,
  `n*272` as `n*16 + n*256`. The arithmetic *is* the record size; dividing the gap by it gives the
  count. Check the division is exact and the last record ends where the next region starts.

### The one-below trap

**`find-readers` cannot see a table addressed from one byte below itself, and ROMs do this constantly.**
A 1-based table puts its base on the byte before it, which is usually the previous routine's `RTS` and
therefore claimed — so the base never appears in a gap and the table is never reported. **When a small
gap has no reader, try the address one below it as a base before concluding anything.** This cost this
project a *published negative*: a block was written up as "nothing reads it — no absolute-indexed load
in the ROM is based here", and the reader was `LDA base-1,Y`. Writing the idiom down five times did not
stop it happening a sixth; the check has to be run, not remembered.

### A one-byte gap beside a table is a missing entry

A dispatch was published as six handlers, leaving a one-byte gap immediately after it. There were seven.
The seventh was the only way into 164 bytes already claimed with a note that nothing appeared to reach
them. Both facts were in the map at once and the distance between them was one byte. Sweep every gap of
four bytes or less for one adjacent to a table; it is cheap.

### A dispatch table's *start* can be wrong, not just its length

Entries that do not decode at low indices may mean the table begins at a higher index. Two structural
facts settled it here: the unclaimed stretch began at exactly `base + first_index`, and its length was
exactly 2 × entry count with nothing over. **When a table's entries stop making sense, try moving its
first index before abandoning it.**

### To learn which values an array holds, dump the tables that write it

Not a survey of immediates — the values may never appear as an immediate anywhere in the ROM. Find the
sites that store into the RAM byte *from a table*, and dump those tables. That gives the set directly.

---

## 6. Tools worth building

Roughly in the order you will want them.

| Tool | What it does | Trap it must avoid |
| --- | --- | --- |
| `whereis` | address ↔ offset ↔ bank, region or gap, mini-disassembly | must accept both bank numberings and verify by bytes |
| `trace-code` | seeded control-flow trace | seeds must include vectors, entry tables, dispatch tables, resume points |
| `find-readers` | absolute-indexed reads based in unclaimed bytes | opcode list below; walk instructions, not bytes |
| `find-tables` | split-pointer shapes | contiguous pairs will find nothing |
| `find-entries` | install-site ↔ resume-tail pairing | must cross-check in both directions |
| `find-callargs` | register state at each call site | **once per path, not once per site** |
| `find-mirrors` | tile transforms between block pairs | — |
| `find-text` | encoding candidates | — |

### `find-readers`: the opcode list is the tool

It was built around `LDA`/`LDX`/`LDY`/`CMP` and treated as a complete inventory of a bank's table
readers for months. A collision table read as `ADC base,Y` / `SBC base,Y` was invisible the whole time.
Include `ADC`, `SBC`, `AND`, `ORA`, `EOR`, `INC`, `DEC`. Adding them took one bank from a handful of
candidate bases to 93 and another from 21 to 45.

**The failure mode to learn from is not that a base was missed — it is that the base was reported
anyway, by a plain `LDA` elsewhere, so the output looked complete while a whole class of reader was
absent from it.** A tool that gives the right answer for an incomplete reason gives you no signal that
it is incomplete. When a tool encodes a pattern, **write down which cases it covers next to the
output**, not just in the source.

It must also **walk instructions rather than scan bytes**: scanning finds `CMP $A502,Y` inside the
operand of `STA $02D9,X`. Dropping that class of false positive cut candidate lists by about a third.

### `find-callargs`: once per path

A call site with more than one predecessor **must be walked once per predecessor**. A linear tracker
sees the first branch arm's constants overwritten by the second's and reports only the second — which
is a real address, so the output looks complete. That is how one call site disappeared into its sibling
with no residue, and how an "all 16 call sites resolve" claim turned out to be a claim about the number
16.

The tool built to fix that bug under-reported on its own first two runs, twice, for two different
reasons: it did not follow `JSR` into callees, and it seeded only from code-region heads — and a region
is a contiguous run of traced bytes, not a routine, so anything entered through the bank's entry table
sits mid-region and is never reached. **Check a new tool against a bank whose answer you already know
before trusting it on one you do not.**

Printing `?` for a computed or memory-loaded argument is a result, not a failure. Note what the tool
cannot see (arguments passed in zero page, for instance) beside its output.

---

## 7. Graphics

- **To find graphics blocks, track the constants; do not search for the address.** The call shape is
  `LDA #lo / STA $04 / LDA #hi / LDX #len_lo / LDY #len_hi / JSR <rle>`, so the source appears nowhere
  as an operand. Walking each traced run and remembering the last immediate loaded into A, X, Y and the
  pointer bytes recovers all of it — that closed one bank from 73% to 99.97% in a single pass.
- **Track `STX` and `STY` into the pointer as well as `STA`.** One call writing its low byte with
  `LDX #$99 / STX $04` hid a 931-byte block. Worse, `STA`-only tracking does not merely skip such a call
  — it **carries the previous call's low byte into it and emits a plausible wrong address**. That is how
  a block at `$D546` was published as `$D5EA`, `$EA` being the previous call's low byte. Both halves
  were real bytes from real instructions, which is what let it survive. **The free tell went unchecked:
  the address did not start where the previous claimed region ended, and the right one did.** Treat a
  source that does not abut its predecessor as a warning.
- **A pointer is often built in one traced region and used in the next**, because a branch target split
  the run. A constant tracker that resets at region boundaries loses exactly those cases. Merge runs
  that touch before walking them.
- **Enumerate the bank's uploaders before believing a gap is unreachable.** The cheap first question
  about an unclaimed block is not "what points at it" but **"what routines in this bank write to
  `$2007`?"** One bank had three documented mechanisms and two undocumented ones within 200 bytes of the
  same code; grepping for `JSR` to the shared CHR-address setter found 38 sites in one command and every
  one was an upload of something.
- **Not all graphics are tile-shaped, and the tile-shaped tests are blind to the rest.** A 1bpp font at
  **seven** bytes per glyph sat unclaimed through every graphics pass: not a multiple of 16, not
  compressed, not reached by any known mechanism. What found it was sweeping gaps for stretches that
  *linearly decode with few illegal opcodes* and noticing one at 1%. The expander fixed the stride — it
  writes one zero byte, seven bytes from the pointer, then eight zeros, then advances the pointer by 7.
  **When a block will not divide by 16, ask what expands it before deciding it is not graphics.**
- **Blocks are not always handed a length.** Some are uploaded by a loop with a tile count in a
  register; some by a record stride computed from an index.
- **A found font is a way to check text decoded from context.** Punctuation codes inferred from wording
  were settled by pixels — four right, one wrong (a "second dash" was a trademark sign). **A code table
  derived from context should say so at each entry**, not once in a comment at the top, or nothing
  prompts a re-check when the font turns up.
- **A block of "new art" may be a flipped copy of the block in front of it, and drawing it cannot tell
  you.** A mirrored sprite looks like new art because that is what it looks like. Two blocks here were
  drawn, compared by eye *and by byte difference*, and written up twice before anyone reversed the bits.
  **688 of 960 bytes differ between a block and its own mirror**, which reads as "unrelated art". Run
  all four NES tile transforms over every uncompressed block pair in the ROM once; it is a cheap sweep
  and then it is done for good.
- **A picture the game shows you may be generated rather than stored.** A minimap here is built at
  runtime, one pixel per metatile, with its two bit planes coming from **two tables in two different
  banks**, reached through far-read helpers the routine copies into RAM first. Nothing names either
  block as an operand. **The tell is a routine that writes CHR RAM from a loop with no source pointer
  in sight**: ask what it is reading, not where the picture is.
- **Require a `codec` field on every graphics region and make the build refuse without one.** A raw
  block run through a decompressor produces plausible noise rather than an error, so a wrong default
  draws garbage and nothing complains. This happened here twice — the second time with a docstring
  recording the first time sitting in the same file. **When a past mistake is recorded as a comment
  rather than as a check, expect to make it again.**

---

## 8. Byte-stream formats (music, scripts, level commands)

- **Decode by reading each handler to its end, not by reading the jump table.** A handler with no
  terminator *falls through into another handler* and takes that one's operands. Assuming the table
  shape gives the operand count desynchronised every track using that command, and the parser then read
  a note byte as a jump address and reported a branch to nowhere — **a grammar problem that presents as
  a data problem.** Two more commands took an extra operand because a shared helper returns with one
  already in A.
- **Then prove the grammar by parsing everything with it.** Walk every stream head, follow calls and
  jumps, and require: all bytes covered, no gaps, no overlap, and **no byte reaching two different
  roles**. That last check is the one that catches an operand count that is wrong only sometimes.
  Re-run it on every build.

---

## 9. Verification, in order of strength

1. **It tiles.** Blocks filling a range end to end with no gaps were bounded correctly. This is evidence
   about *extent* and none at all about *use* or *count* — filler tiles just as well as data. **A
   declared count beats it whenever one exists.** Read the whole record your pointer came from before
   deriving a length from neighbours; the count field is often a couple of bytes away.
2. **It lands on a boundary.** An exact multiple of the element size; a table ending exactly where code
   begins.
3. **Two sources agree that were not derived from each other.** An array stride in one bank and a `CPX`
   bound in another. Three independent directions on the same number is close to proof — **but check
   the independence is real** (§10).
4. **Draw it.** Rendering decompressed tiles settled a codec in one look. A drawing verifies **only what
   it actually draws** — say which parts of the pipeline the picture exercised.
5. **No illegal opcodes** in traced code is strong evidence the trace stayed on rails.
6. **Diff against a savestate.** The strongest check available, because it is the hardware's own answer.
   An FCEUX `.fc8` is zlib after a 16-byte header; its chunks include CPU RAM, palette RAM, nametables,
   CHR RAM and the mapper latch. Reconstruct a structure from the ROM and diff it against the live one:
   a pattern table came out 4,093 of 4,096 bytes identical, and the three that differed named themselves
   as per-frame status meters. **It also finds missing steps rather than wrong ones**, which no amount
   of reading the disassembly will do — two conditional CHR uploads showed up purely as a run of
   differing tiles at a PPU address.

**A savestate is worth an afternoon.** Live RAM pins values the ROM never states. Grepping a savestate's
live palette RAM for three bytes found **one hit in the whole 256 KB**, twelve bytes into a record whose
remaining fields had been undecoded for months. Nothing in the ROM pointed at those bytes; no reader
search would ever have found them.

**A debugger breakpoint settles in one line what a week of static search will not.** The last two
breakthroughs in one bank both came that way. When you are down to "what reads this address", ask for a
read breakpoint rather than writing another tool.

---

## 10. How this work goes wrong

Every item below is a real published error from this project. They cluster into five shapes. Learn the
shapes; the instances are just proof.

### Shape 1 — a completeness claim that is really a claim about your mechanism

- "All N call sites resolve" was a claim about N, not about the sites.
- "Reached by none of the three mechanisms that explain everything else in this bank" — every word true,
  the conclusion worthless. There were two more uploaders in the same 200 bytes of code. **When a
  ruled-out list is that tidy, enumerate the mechanism class instead of extending the list.**
- 52 enemies documented exhaustively and called *the roster*. It was **one spawner's** roster: the
  dispatch loop had two arms and only one was ever followed. The missed arm held a creature that spawns
  on every level of the game. The mechanism missed was **the other half of a two-way branch in a routine
  already fully annotated, four instructions away.**
- "Nothing reaches this": published eight times, wrong eight times.

**The fix is a taxonomy, not another search.** A 6502 reaches a ROM byte in exactly three ways: an
absolute operand, an absolute-indexed load whose base lies within 255 bytes before the target, or an
indirect load through a zero-page pointer — and nothing else, since zero-page and stack modes cannot
address ROM. All three are **enumerable**, so the question is finite. Seven pattern searches felt weaker
than one taxonomy. **Prefer the taxonomy.**

### Shape 2 — the cross-reference, not the finding, was missing

This is the most expensive shape here, and it recurred at every scale.

- A pointer table's 25 "dead" entries pointed at a second record block — which the project was
  simultaneously carrying as an unexplained 781-byte gap. Both facts in the map at once, neither checked
  against the other.
- One annotation ended with "the thing to try next is: find what fills `$9D`/`$9E`". Another had said
  for months which instructions load them. **Both correct, neither citing the other.**
- A whole game mode was documented six times over as six unrelated things — a globe screen, meter tiles,
  an animated strip, a column-height table, a spawner, an item. One far call tied them together, and
  both ends were already annotated in detail.
- A forty-entry dispatch table was surveyed at last, and **seven of the forty had been documented for
  months** in a different file that nothing cited.

**Two cheap habits fix all of it. When an annotation names an address, read that address's annotation.
Before surveying a table, grep the prose for the addresses in it.** And when a routine is understood,
follow its far calls, because no grep will surface them.

### Shape 3 — identification by resemblance

- A tile block was published as towed-item pictures with "unmistakable crystal shapes" at the crystal
  IDs. It was a player animation and the shapes were thruster flames.
- Shaded spheres "very likely the star map"; column widths 1,1,2,2,3,3,4,3,3,2,2,1,1 "the outline of a
  circle". Both plausible, both wrong, both built by asking *"what could this be?"* instead of **"what
  reads it, and with what index?"** — and the second question was answerable from bytes already claimed.
- A manual named five creatures and **drew each one beside its name**. Two were guessed from what the
  words suggested about a shape and both were wrong — including one entry that argued *against* the
  correct name on the grounds that it "describes a cylinder, a rod and a bulb very exactly". It does. It
  was still the wrong creature. **A name that fits a shape exactly is not evidence about which shape it
  was given to, because the fit is judged by the same faculty that is looking for it.** When a source
  both names a thing and pictures it, the picture is the evidence and the name is decoration.

**Resemblance is a lead, never a confirmation. It sees what it is looking for.**

### Shape 4 — a drawing verifies only what it draws

- A map rendered with hand-picked colours and a 4:1 point-sampled downscale — one pixel in sixteen —
  presented as a check on the format. The format was right; the renderer destroyed every texture and
  used no attribute data at all. The one thing done right was **reporting the mismatch as unexplained
  instead of explaining it away**, which is what prompted the owner to send a savestate.
- Four metasprite frames drawn **bottom-aligned** and read as evidence the tile sheet was wrong. The
  records were symmetric about the origin; the correct layout was centre-aligned and drew a shell
  expanding away from the pod. **The moment more than one frame is shown, the alignment is a claim about
  the data and must be derived from the records.**
- An item drawn from an *enemy's* metasprite and an enemy's tile block, because two keyed tables were
  merged into one dict and the enemy half won. **The wrong pair is not a decode error**: it composes a
  real record out of real tiles and draws a coherent object. The only thing wrong with it is that it is
  a different object, so nothing looks broken.

### Shape 5 — a wrong model written down in prose, then copied

The item-drawing bug above had its rule **already written down twice**, in the two files that needed it.
Two paragraphs below the correct statement, the same section glossed it differently — calling a second
table "a fallback searched when the first misses", a sentence that contradicted the paragraph above it,
was never checked, and is exactly the model the tool implemented. **A section that states a mechanism
and then glosses it differently has published two claims, and nothing compares them.**

Then the sweep for that wrong model found it in four more places, three of them prose, and *still*
missed a third form of it — the owner had to report the same page twice. **When a wrong model is found
in code, grep the prose for it before closing the ticket.** One bad sentence had been copied,
paraphrased and templated into four files, and every copy read as independent confirmation of the
others.

### Assorted, each its own lesson

- **Two guesses propping each other up read exactly like corroboration.** A gap divided by a record size
  gave a count; a neighbouring table's entry count was cited as independent agreement — while the record
  count was cited to explain the table. Ask what would have to be true for each to be wrong *separately*.
- **Before citing a coincidence as evidence, ask how often it happens by chance.** Seven unassigned rows
  partitioned "exactly" into seven unassigned columns and the write-up said "nothing forced that to come
  out even". Something did: both multisets were drawn from a set with three distinct values, so a
  partition was near-guaranteed. The check had almost no power to discriminate and read as confirmation
  anyway. The same section recorded one row that did *not* fit and called it noise. **When a check
  throws up one disagreement, that is the check's answer, not its error bar.**
- **When a survey needs excuses for a third of its cases, the excuses are the finding.** 21 of 29 with
  three explanations was the model being wrong, not the data. Under the corrected model: 28 of 29.
- **A branch is worth reading out loud in the annotation** — "BCC is taken when X is below Y". A clamp
  was written up as doing the opposite of what it does; every other detail in the description was right,
  and the one inverted word was the one that says what the table is *for*. Prose about a comparison is
  the easiest thing here to get exactly backwards and the hardest to notice.
- **A claim about a 194-byte region made by looking at the start of it** gave a range that stopped a
  third of the way through and a special-value count wrong in both number and meaning. **Nothing checks
  a count in prose. Count it in code and paste the number.**
- **Generated sentences are claims too.** A templated explanation asserted that two overlapping blocks
  "deliberately overlap to save space, since both are blank rows". Nobody had checked it and it was
  false. A template that explains its own output will explain a wrong output just as fluently, and the
  confident wording is what stops anyone looking again.
- **Name a byte after all its readers, or say the name does not cover them.** A flag was named
  `soundOff` because three sites skip sound on it. It is the **attract-mode flag**; the other four
  readers have nothing to do with sound, and a whole 449-byte demo mode went unnoticed for the life of
  the project. A name that describes one subsystem stops anyone asking what else reads it.
- **Naming a block after the thing that selects it describes the pointer, not the data.** Three blocks
  were "screen data, format not decoded", named on the strength of a search routine. They were flight
  paths, five bytes a waypoint, and the decode took reading one routine once.
- **When two sources disagree about a byte, the disagreement is the finding.** One wiki called a pair
  health; another page called it fuel in its address table and health in another section, contradicting
  itself. What settled it was two instructions: something decrements the pair once a frame, and
  something else adds into it and clamps at a ceiling. A meter you spend per frame with a ceiling is a
  fuel tank. **Neither name was taken on authority, and the losing one is still written down in the
  annotation.**
- **An annotation that records a disagreement and resolves it in a subordinate clause has published an
  unchecked claim.** A byte was published as `maxFuel` while quoting, in the same entry, the source that
  called it weapon power — dismissed with *"which does not match a maximum"*. It does not match a
  maximum because it is not one. Six sites spend it per shot, refuse to fire when it is empty, refill it
  on a kill. **The evidence was in the file and was argued away in one clause.**
- **A block that will not draw is evidence about the sheet you chose, not about the data.** An animation
  was cut from 11 frames to 8 because the last three would not render; it switches tile set at frame 8,
  and the note had even said a different tile set was the likeliest explanation before discarding the
  frames anyway. **Correcting a right answer for a bad reason is still a regression. When a correction
  removes a finding, check it as hard as the finding.**
- **Before explaining away a count, ask what operation produces exactly that number.** 60 tiles beside
  64 looked like arithmetic that would not come out; it is 64 minus the two rows at each end that a
  mirror does not cover. Seven bytes a glyph looked like "not graphics"; it is a 1bpp font. Twice, a
  count that refused to divide evenly was the tell rather than the problem.
- **A displayed number that cannot be found as data is a field of a record.** Two stats were carried as
  "Checked, absent" after searches for thirteen consecutive bytes, thirteen bytes at every stride 1–32,
  ASCII digits, and an unordered multiset. All run correctly. They are bytes 8 and 11 of a 27-byte
  record reached through a pointer table, so **no stride exists to find** — and one of them is the top
  five bits of its byte. **Stop searching for the data and read the code that prints it**: the print
  site names the zero-page byte, and one `LDA $xx` backwards names the record field.
- **Before running a search, check what your own RAM map already says about the addresses in front of
  you.** An unnamed routine was carried as "what it does is not established" while the RAM map already
  named the two bytes it writes. Reading it that way took ten instructions and gave up the routine's
  name, two zero-page bytes and two record fields, with no new tool.
- **The RAM map and the disassembly are two halves of one document and nothing in the build compares
  them.** Three wrong RAM names survived for a long time while three routines answering them were
  already disassembled. It took an outside page naming one address to prompt the check.

---

## 11. When a gap will not fall

The last stretch is a different problem from the thousands of bytes before it. Up to ~99%, everything
falls to `find-readers` plus a disassembly. Below that, `find-readers` comes back empty and what remains
is small routines that decode cleanly, end on an `RTS` or a `JMP` into claimed ground, and are reached
by nothing static.

In order:

1. **Is the gap the head of a routine whose body is already claimed?** Two "orphans" here were a
   two-instruction preamble falling into the next region — the boundary was just where the trace began.
   Check whether the bytes *after* the gap are traced code.
2. **Try the address one below the gap as a table base.** (§5)
3. **Is a neighbouring table one entry short?** (§5)
4. **Enumerate every uploader / consumer in the bank**, not every pointer to the block. (§7)
5. **Search for the high byte as an immediate**, not as an operand. (§5)
6. **Run the taxonomy**: absolute operands anywhere in the ROM; indexed bases within 255 bytes before
   it; every indirect load through a zero-page pointer, with what that pointer can hold. This is finite
   — one bank had exactly fifteen indirect loads through two pointers, one of which could not even
   carry.
7. **Does it decode as code with few illegal opcodes?** A gap at 1% illegal is worth reading. But check
   the decode is *live*: if the only legal decode writes a read-only register and reads open bus, the
   code reading is dead rather than untested.
8. **Are both ends pinned by structure?** If the byte before is an `RTS` and the byte after is an entry
   in the bank's public table, the gap cannot be the head of the routine that follows.
9. **Set a read breakpoint.** (§9)
10. **When you stop, write a file that claims nothing and lists the mechanisms already tested, with the
    result of each.** Not an unreachability claim — a claim about the searches. The next agent then
    knows what to extend instead of what to trust.

---

## 12. Where coverage comes from, in practice

Six of eight banks here went from 70–86% to complete in a single session each, and **not one was a hard
bank.** Each was a single unresolved mechanism whose bytes had been scattered across the gap list
looking like a dozen separate problems:

| Bank | Went | Because |
| --- | --- | --- |
| 0 | 69.6 → 93.0% | the NMI RAM vector was resolved (18 handlers) |
| 1 | 76.9 → 99.98% | one screen tile loader read, from a debugger breakpoint |
| 2 | 86 → 99.9% | two more CHR uploaders in the same bank |
| 4 | 85.4 → 100% | five parallel arrays a fixed distance apart |
| 6 | 70.2 → 99.97% | two graphics loaders whose sources are immediates |
| 7 | 85.2 → 99.45% | one dispatch table's starting index corrected |

**So when a bank stalls with thousands of bytes left, do not grind the gap list. Ask what mechanism you
have not enumerated.** The gaps are usually one thing wearing many hats.

And when `find-readers` returns nothing with thousands of bytes unclaimed, that is not a dead end. It is
a statement: *the remaining data is not reached by an absolute-indexed load.* Which means it is reached
by a pointer built from immediates — and the way to find that is to walk the traced code tracking
constants, not to search for the address.

---

## 13. Writing the annotations

- Say what has **not** been established, in the annotation, not in conversation.
- Name the evidence, not the conclusion: "the reader's base is X + $86, and the stretch is 106 bytes =
  53 × 2" survives; "this is the object table" does not.
- Read comparisons out loud. Count things in code and paste the number.
- When you record a negative, **list the searches it is a negative about.**
- Every entry derived from context should say it was derived from context.
- Ship the corrections. A document with its own mistakes in it is worth more than a clean one, because
  the mistakes are the only part that transfers.

---

## The summary, if you read nothing else

1. Check every claim against the bytes; mark leads as leads.
2. Make the build enforce SHA-1s, non-overlap, and a byte-exact reassembly.
3. Find the mechanisms, not the bytes. A stalled bank is one unenumerated mechanism.
4. Entry counts come from the reader, never from dividing a gap.
5. A completeness claim is a claim about your search. Prefer a taxonomy to another pattern search.
6. When an annotation names an address, go read that address's annotation.
7. Resemblance is a lead. A drawing verifies only what it draws. A savestate is the hardware's answer.
8. State corrections; never quietly edit them away.
