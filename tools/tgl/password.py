"""The password system: the character grid, the decode and the TGL back door.

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

TGL_CONST = 0x8513        # bank 3; the three bytes 13 06 0B
FIELD = 0x0411            # 32 characters
FIELD_LEN = 0x20
BUFFER = 0x011E           # 24 decoded bytes, $011E-$0135
XOR_EXEMPT = 0x17         # the one index $854D does not XOR

# A-Z then 0-9, which is the on-screen grid read left to right, top to bottom.
ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"


def to_indices(text: str) -> list[int]:
    out = []
    for c in text.upper():
        if c in " _":
            out.append(0)
            continue
        if c not in ALPHABET:
            raise SystemExit(f"{c!r} is not on the password grid ({ALPHABET})")
        out.append(ALPHABET.index(c))
    return out + [0] * (FIELD_LEN - len(out))


def decode(chars: list[int]) -> tuple[list[int], bool]:
    """The ROM's own arithmetic. Returns (24 bytes, checksum ok)."""
    seed = ((chars[0x1F] << 2) | (chars[0x1E] >> 4)) + 0x1D
    seed &= 0xFF
    out: list[int] = []
    for g in range(8):
        a, b, c, d = (chars[4 * g + i] & 0x3F for i in range(4))
        # $85CF onward: four six-bit values shifted together into three bytes.
        bits = (a << 18) | (b << 12) | (c << 6) | d
        trio = [(bits >> 16) & 0xFF, (bits >> 8) & 0xFF, bits & 0xFF]
        for k, v in enumerate(trio):
            idx = 3 * g + k
            if idx != XOR_EXEMPT:
                v ^= seed
                seed = (seed - 1) & 0xFF
            out.append(v & 0xFF)
    total = 0
    for i in range(0x16):                       # $011E-$0133
        total = (total + out[i]) & 0xFF
    total = (total + out[0x17]) & 0xFF          # + $0135
    return out, total == out[0x16]              # == $0134


def encode(payload: list[int], seed_chars: tuple[int, int] = (0, 0)) -> str:
    """The inverse of `decode`. Returns "?" for any six-bit field the grid cannot express.

    **Not every 24-byte payload is typeable.** A six-bit field runs 0-63 but the grid has
    only 36 characters, so a payload whose packed form lands in 36-63 anywhere has no
    password at this seed. That is almost all random payloads - which is worth knowing,
    because a round trip driven from the payload side silently tests nothing. Drive it from
    the character side instead, as `--selftest` now does.

    A LEAD, not established: the seed comes from the last two characters, which means the
    game gets to CHOOSE it. Searching seeds until every field falls under 36 would be a
    natural reason for the seed to exist at all. Nothing here checks that.
    """
    seed = ((seed_chars[1] << 2) | (seed_chars[0] >> 4)) + 0x1D
    seed &= 0xFF
    enc = []
    for idx, v in enumerate(payload):
        if idx != XOR_EXEMPT:
            v ^= seed
            seed = (seed - 1) & 0xFF
        enc.append(v & 0xFF)
    chars = []
    for g in range(8):
        x, y, z = enc[3 * g:3 * g + 3]
        bits = (x << 16) | (y << 8) | z
        chars += [(bits >> 18) & 0x3F, (bits >> 12) & 0x3F,
                  (bits >> 6) & 0x3F, bits & 0x3F]
    return "".join(ALPHABET[c] if c < len(ALPHABET) else "?" for c in chars)


