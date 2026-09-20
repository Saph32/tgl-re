#!/usr/bin/env python3
"""The password system: decode one, encode one, and the TGL back door.

    python tools/password.py TGL              # what the ROM does with it
    python tools/password.py ABCD...          # decode a 32-character password
    python tools/password.py --selftest       # encode/decode round trip

Where it lives
--------------
Bank 3, and the password screen runs with bank 3 live - which the savestate confirms, its
mapper latch reading $83. The entry grid is drawn A-Z then 0-9 then FR / BA / END, and a
character is stored as its **grid index**: `$88F2` does `LDX $17 / LDA $16 / STA $0411,X`,
so A is 0, T is 19, Z is 25, '0' is 26 and '9' is 35. The field is 32 characters at
`$0411-$0430`.

How a password decodes, read off $8516
--------------------------------------
1. **A seed comes out of the last two characters.** `$8519` builds
   `($0430 << 2) | ($042F >> 4)`, adds `$1D`, and keeps it in `$19`.
2. **Four characters become three bytes.** `$85BB` copies four characters to `$0403`, masks
   each with `AND #$3F` - six bits, which is exactly enough for the 36-character set - and
   shifts them together into three bytes.
3. **Each byte is XORed with the seed, and the seed counts down.** `$854D` does
   `EOR $19 / DEC $19`, so every output byte uses a different key. Index `$17` is skipped
   by the `CPX #$17 / BEQ` two instructions earlier.
4. Eight groups of four give **24 bytes** at `$011E-$0135`. That buffer is the PPU write
   queue's staging area, borrowed while the password screen is up.
5. **The checksum.** `$859B` adds `$011E-$0133` and `$0135`, and compares the total with
   `$0134`. A mismatch takes `$8578: SEC / RTS` - carry set, password rejected. A match
   copies the buffer to `$0438` and returns with carry clear.

The TGL back door
-----------------
`$857A` runs *before* the checksum. It compares the first three characters against the
three bytes at **`$8513`**, which are `13 06 0B` - grid indices 19, 6, 11, which is T, G, L
- and then requires every character from index 3 to `$1F` to be zero. On a match it sets
`$2F = 0` and `$30 = 2` and returns carry clear, skipping the checksum entirely.

`$30` is the game-mode byte. Bank 0 `$8BA3` holds a screen script that reads
**"PASSWORD TGL"**, right after one reading "IREM CORPORATION" - so the back door leads to
a developer screen, not to an in-game state a normal password could express.

**A consequence, stated because the code says so and not because it was tried:** a blank
character and the letter A are both the byte 0 - the savestate shows the untouched field is
all `$00`, and A's grid index is 0. So "TGL" followed by any number of A's is the same 32
bytes as "TGL" followed by blanks, and the check cannot tell them apart.

What is NOT established
-----------------------
What `$30 = 2` actually makes the game do beyond selecting a mode; the meaning of the 24
decoded bytes (which ones are area, weapons, chips); why byte index `$17` is exempt from the
XOR; and whether a real in-game password round-trips - `--selftest` only shows the encoder
and decoder here agree with each other, which is self-consistency and not hardware.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tgl.model import load
from tgl.password import (ALPHABET, BUFFER, FIELD, FIELD_LEN,
                          TGL_CONST, XOR_EXEMPT, decode, encode, to_indices)

ROOT = Path(__file__).resolve().parent.parent


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("password", nargs="?", help="up to 32 characters from the grid")
    ap.add_argument("--selftest", action="store_true",
                    help="encode then decode, and check they agree")
    args = ap.parse_args()

    rm = load(ROOT)
    b3 = rm.prg_bank(3)
    tgl = list(b3[TGL_CONST - 0x8000:TGL_CONST - 0x8000 + 3])
    print(f"bank 3 ${TGL_CONST:04X} holds "
          + " ".join(f"{x:02X}" for x in tgl)
          + " = " + "".join(ALPHABET[x] for x in tgl)
          + "  (read by LDA $8513,Y at $857C)")

    if args.selftest:
        import random
        random.seed(7)
        bad = tested = 0
        for _ in range(2000):
            # Driven from the CHARACTER side, which is always expressible. Driving it from
            # the payload side tests nothing: six-bit fields run 0-63, the grid has 36
            # characters, and a random payload almost never encodes. An earlier version of
            # this check did exactly that and skipped all 500 of its cases while reporting
            # "0 disagreements" - the number was true and meaningless.
            text = "".join(random.choice(ALPHABET) for _ in range(FIELD_LEN))
            chars = to_indices(text)
            payload, _ = decode(chars)
            again = encode(payload, (chars[FIELD_LEN - 2], chars[FIELD_LEN - 1]))
            tested += 1
            bad += again != text
        print(f"\nround trip over {tested} random passwords: {bad} disagreements")
        print("decode then encode returns the original characters. This is the two "
              "directions here agreeing with each other - self-consistency, NOT hardware, "
              "and not a password a real save produced.")
        return 0

    if not args.password:
        ap.print_help()
        return 0

    chars = to_indices(args.password)
    print(f"\nentered: {args.password.upper()!r} -> "
          + " ".join(f"{c:02X}" for c in chars[:8]) + " ...")

    if chars[:3] == tgl and not any(chars[3:]):
        print("\n*** THE BACK DOOR ***")
        print("$857A matches the first three characters against $8513 and then requires "
              "every character from index 3 to $1F to be zero. This password takes that "
              "arm: it sets $2F = 0 and $30 = 2 and returns carry clear, skipping the "
              "checksum entirely. $30 is the game-mode byte, and bank 0 $8BA3 carries a "
              'screen script reading "PASSWORD TGL".')
        return 0

    out, ok = decode(chars)
    print("\ndecoded 24 bytes at $011E:")
    for r in range(0, 24, 8):
        print(f"  ${BUFFER + r:04X}: " + " ".join(f"{x:02X}" for x in out[r:r + 8]))
    print(f"\nchecksum byte $0134 = ${out[0x16]:02X}, sum of $011E-$0133 plus $0135 = "
          f"${(sum(out[:0x16]) + out[0x17]) & 0xFF:02X}  ->  "
          + ("ACCEPTED (carry clear, copied to $0438)" if ok
             else "REJECTED ($8578: SEC / RTS)"))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
