"""The password system: the character grid, the decode and the TGL back door.

python tools/password.py TGL              # what the ROM does with it
    python tools/password.py ABCD...          # decode a 32-character password
    python tools/password.py --selftest       # encode/decode round trip

Where it lives
--------------
Bank 3, and the password screen runs with bank 3 live - which the savestate confirms, its
mapper latch reading $83. A character is stored as its **grid index**: `$88F2` does
`LDX $17 / LDA $16 / STA $0411,X`, and `$880F-$8839` builds `$16` as column + 10 x row
from the cursor sprite's position. The field is 32 characters at `$0411-$0430`.

**The grid is 64 characters, seven rows of ten** - read off the password savestate's
nametable: A-J / K-T / U-Z 0-3 / a-j / k-t / u-z 4-7 / 8 9 ! ? then FR, BA, END. The
lowercase letters are tiles `$81-$9A` (`$9B` is !, `$9C` is ?) and every lowercase row is
drawn with a row of `$AE` - two dots - above it, so on screen they read as a-umlaut,
b-umlaut and so on. 64 is exactly what the six-bit fields hold.

**CORRECTION.** This file said the grid was "A-Z then 0-9", 36 characters, with '9' at
index 35, and the site drew a four-row grid. The savestate showed seven rows all along; only
the first three were read. The mistake put digits 4-9 at 30-35 when they are 56-61, and it
manufactured a puzzle - "most six-bit payloads are not typeable" - that does not exist:
with 64 characters, every payload is. What prompted the re-read was the game's manual,
whose former owner wrote passwords full of umlauted lowercase letters
(`docs/external.html`).

How a password decodes, read off $8516
--------------------------------------
1. **A seed comes out of the last two characters.** `$8519` builds
   `($0430 << 2) | ($042F >> 4)`, adds `$1D`, and keeps it in `$19`.
2. **Four characters become three bytes.** `$85BB` copies four characters to `$0403`, masks
   each with `AND #$3F` - six bits, exactly the 64-character grid - and
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

What the 24 bytes are
---------------------
Read off bank 3 ``$85B0``, which copies buffer index i to ``$0439 + i``, and ``$8473``,
which the password screen's caller (``$8323``, only when ``$2F`` is non-zero) runs to turn
it into game state:

* **indices 0-16** -> ``$04A0-$04B0`` by ``LDY #$11 / LDA $0438,Y / STA $049F,Y``: the
  corridor flags ``$04A9-$04AB``, the weapon levels ``$04AC-$04AE``, the Enemy Eraser count
  ``$04AF`` and the keys ``$04B0`` among them; bit 7 of ``$04AE`` and ``$04B0`` is cleared.
  The low four bits of ``$04A8`` become ``$46``, bit-reversed.
* **index 17** -> high five bits to ``$47``, the maximum life (0 means 255); low three bits
  to ``$6B``.
* **index 18, 19** -> attack ``$4A`` and shield ``$4B``, through ``$8443``.
* **index 20, 21** -> the six score digits ``$0170-$0175``, each byte split by ``$8502``
  into hundreds, tens and units, with two more high bits each taken from ``$04AB``.
* **index 22** is the checksum; **index 23**, the byte the XOR skips, is added into the
  checksum and read by nothing in ``$8473``.

``$83AE`` is the other direction - it copies ``$04A0-$04B0`` back into ``$0439`` and packs
the rest - so bank 3 builds passwords as well as reading them.

What is NOT established
-----------------------
What ``$30 = 2`` actually makes the game do beyond selecting a mode; what ``$04A0-$04A8``,
``$46`` and ``$6B`` hold; why index 23 is exempt from the XOR and unused; and whether a
real in-game password round-trips - ``--selftest`` only shows the encoder and decoder here
agree with each other, which is self-consistency and not hardware.
"""

from __future__ import annotations

TGL_CONST = 0x8513        # bank 3; the three bytes 13 06 0B
FIELD = 0x0411            # 32 characters
FIELD_LEN = 0x20
BUFFER = 0x011E           # 24 decoded bytes, $011E-$0135
XOR_EXEMPT = 0x17         # the one index $854D does not XOR

# The on-screen grid read left to right, top to bottom: ten to a row, seven rows. The
# lowercase letters are the umlauted ones on screen.
ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123abcdefghijklmnopqrstuvwxyz456789!?"
assert len(ALPHABET) == 64


def to_indices(text: str) -> list[int]:
    out = []
    for c in text:
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
    """The inverse of `decode`, for a given pair of seed characters.

    Every payload is typeable: a six-bit field runs 0-63 and the grid has 64 characters.
    CORRECTION: this used to say most payloads were not, from the 36-character misreading
    of the grid, and floated a lead that the seed existed to dodge untypeable fields.
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


