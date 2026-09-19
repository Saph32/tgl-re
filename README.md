# tgl-re

A byte-by-byte reverse engineering of the NES game **The Guardian Legend**, mapper 2
(UxROM), 131,088 bytes, SHA-1 `d00d73c7764a4c3513892b97afb939f30e522245`.

The goal is to account for every byte of the ROM image and say, with evidence, what each
one is. There are two outputs:

- **`docs/rom.json`** — the machine-readable map: every region with its file offset, size,
  PRG bank, CPU address, kind, confidence, SHA-1 and the evidence for it.
- **`docs/index.html`** — the same map for humans: an overview and one page per PRG bank,
  with pages for graphics, sound and level data to come as those are decoded.

The ROM itself is **not** in this repository — it is copyrighted material. Put your own
copy of `Guardian Legend, The.nes` in the project root; the build refuses to run if its
SHA-1 does not match.

## Building

```bash
python tools/build.py
```

Requires Python 3.10 or later. Nothing else.

```bash
python tools/build.py --check            # validate the annotations, write nothing
python tools/build.py --gaps             # the largest stretches nobody has claimed yet
python tools/whereis.py FEDE             # what is at this address, and where in the file
python tools/whereis.py 8000 --bank 5    # an address in the switchable window
python tools/whereis.py --bytes "4C DE FE"   # which bank really holds these bytes
python tools/trace-code.py --assumptions # the code trace, and what its answer rests on
python tools/gen-code-regions.py         # regenerate the traced code regions
python tools/reassemble.py               # rebuild the ROM from the map; write disasm/
python tools/trace-code.py --inline      # calls with inline argument data
python tools/savestate.py STATE.fcs --font   # check the font against a savestate
python tools/decompress-gfx.py               # the tile blocks, decoded
python tools/decompress-gfx.py --verify STATE.fcs   # against a savestate's live CHR
python tools/parse-sound.py --dump           # every song, track by track
python tools/parse-sound.py --song 7         # one song, decoded event by event
```

`tools/trace-code.py --assumptions` prints what the trace's coverage figure depends on,
including the call sites where "a JSR returns with the live bank unchanged" is doing real
work. Read it before citing a number from it.

## What the cartridge is

Eight 16 KB PRG banks and no CHR ROM at all. UxROM puts whichever bank the latch selects
at `$8000-$BFFF` and wires the last one, bank 7, permanently at `$C000-$FFFF`. So:

- **An address in `$8000-$BFFF` does not identify a byte.** It exists in seven banks at
  once. Every tool here carries the bank alongside the address, and `whereis.py --bytes` is
  what settles the bank when an outside report gives you only an address.
- **There is no tile data in this file, as stored.** iNES byte 5 is zero, so the board
  carries CHR RAM and every tile the PPU draws was uploaded from PRG by code. The tile
  codec is decoded (see below); the code that runs it has still not been found.
- **Bank switching is bus-conflict-free.** The eight values `$80`-`$87` sit at
  `$FFF2-$FFF9` and the switch routines read a byte from that table and write it straight
  back to the address it came from, so the value written and the value the ROM drives are
  the same byte by construction.
- **The reset path checks the mapper before it trusts it.** Banks 0 to 6 each hold their
  own number in their last byte at `$BFFF`, and the loop at `$FF23-$FF43` selects each bank
  in turn and hangs forever if one does not answer with its own number.

## How to trust anything here

Prose is not checked by anything, so as much as possible is made mechanical and run on
every build:

- every region declares the SHA-1 of its own bytes, so a mis-stated offset cannot survive;
- regions may not overlap, and may not straddle a PRG bank boundary;
- named fields may declare their literal bytes, checked the same way;
- the loader re-derives the mapper number and both size figures from the header;
- graphics regions must declare a codec, because a raw block run through a decompressor
  produces plausible noise rather than an error;
- every region must get a card on some page of the site, so nothing can be annotated and
  then quietly not shown;
- coverage percentages are computed, never typed;
- and the whole ROM is rebuilt from the region map and compared byte for byte.

That last one needs a caveat stated up front, because it is easy to over-read: **the byte
comparison alone cannot catch a wrong instruction-start address.** Disassembling and
reassembling is faithful at whatever alignment you start from, so a region beginning one
byte early rebuilds perfectly and prints a listing that reads fine. What catches it is a
separate check — a code region's first byte must be one the trace begins an instruction at
— along with a third, that every control-flow target resolves to an instruction start
inside a code region. Both were confirmed to fail when they should by breaking the map on
purpose, as were the checks for a region ending mid-instruction, a code region relabelled
as data, and two same-sized regions trading places.

Every region also carries a **confidence**: *confirmed* means the claim was checked
against the bytes or against code that executes; *lead* means it is a hypothesis worth
recording and nothing more.

## Where the method comes from

`NES-RE-PLAYBOOK.md` is the method, written from a completed 256 KB cartridge. Read it
before starting and again when stuck. `CLAUDE.md` is what is specific to this ROM and this
repository.

## State of play

Early. The container is documented — the iNES header, the interrupt vectors, the bank table
and the boot-time bank check — and a seeded code trace, seeded from the three vectors and
every bank's opening `JMP` table, accounts for most of what is claimed so far.
`docs/index.html` prints the real figure; it is not typed anywhere.

The signal worth watching is the illegal-opcode count the tracer prints. It is zero across
11,462 instruction starts, and it got there by finding real mechanisms rather than by
tuning: an entry-table alias for the far-call trampoline, three inline-argument calling
conventions, and the fact that two complementary branches back to back are unconditional.
Each of those was a place the trace was decoding data as code and reporting coverage for
it. The last one it caught was a typo in this project's own `annotations/rom.json`.

**Zero illegal opcodes says the trace stayed on the rails everywhere it went. It says
nothing about where it did not go.** Bank 4 is at 20 bytes of 16,384.

The font is decoded and confirmed against hardware: 45 glyphs, 1bpp at seven bytes each,
expanded into tiles by bank 2 `$806C`. Rebuilding the 41 glyphs the ROM's own record table
uploads and diffing them against the live CHR RAM of an FCEUX savestate gives 41 of 41
exact. `docs/graphics.html` draws them.

**The tile codec is decoded too.** A block is `[escape][unknown]` followed by a stream that
toggles between two modes: literal bytes, and run sections of `[value][count]` pairs. The
escape is the toggle, and two escape bytes in a row — an empty section — end the block. The
compressor picks a byte that does not occur in the block's own literal data, so the escape
differs per block. 101 blocks in banks 1, 2 and 3 turn 36,961 ROM bytes into 2,485 tiles.

Three things check it, and they are independent. Each block's decoded length ends *exactly*
on the next pointer in its bank's table, for 100 of the 101 blocks — the terminator rule was
worked out on four of them and then predicted the rest. Brute-forcing all 256 possible
escape values against that test leaves exactly one survivor for 14 of bank 1's blocks, and
it is the block's own first byte every time. And decoding these blocks out of the ROM
reproduces **398 of the 512 tiles** of an in-game savestate's live CHR RAM, byte for byte.

What that leaves: the *title screen* is only 18 of 512 tiles explained, so bank 0 holds a
tileset whose pointer table has not been found; the second header byte is not understood;
and the decompressor itself is still missing.

**The sound driver is decoded.** Bank 0 is the sound bank: seven soft channels compete for
the four hardware ones through a busy mask, and the winner's registers go into a 16-byte APU
shadow that the NMI flushes. 72 songs sit behind a pointer table, 132 tracks, 4,639 notes.
A track is notes and durations with 21 commands mixed in, and it ends either by stopping the
channel or by jumping back to its loop point — 83 of the 132 do the latter and never reach a
stop command at all. `docs/sound.html` has the format, the command table and every song.

Two ranges of stream byte would break the driver if they occurred: one indexes past the
21-entry command table, the other advances the stream pointer by zero. Walking all 132
tracks meets 810 command bytes and **none** of them is in either range, which is the check
that the format is right rather than merely plausible.

**There is no sampled audio.** The DMC is set up once, pointed at a 17-byte "sample" whose
bytes are all zero. It is a timer: the IRQ it raises polls sprite 0 and re-tunes its own
rate to land a mid-frame raster split.

The game's on-screen text is decoded — 32 strings in six banks, plain ASCII, listed at
`docs/text.html` with the PPU address each one is written to. None of it is a block of text
sitting in the ROM: every string is written inline after the `JSR` that prints it, so all of
them were found by the code trace rather than by searching for text.
