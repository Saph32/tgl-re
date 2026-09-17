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
- **There is no tile data in this file.** iNES byte 5 is zero, so the board carries CHR
  RAM and every tile the PPU draws was uploaded from PRG by code. Finding those uploaders
  is the whole graphics problem, and none has been found yet.
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
- coverage percentages are computed, never typed.

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
