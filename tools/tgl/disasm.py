"""A 6502 disassembler and code tracer.

Ported from the Yoshi project (tools/yoshi/disasm.py), which took it from Dr. Mario and
Solar Jetman before that; the opcode table and the tracer are cartridge-independent.

The Guardian Legend's difference from Yoshi is the mapper. UxROM banks PRG 16 KB at a
time into $8000-$BFFF and leaves $C000-$FFFF permanently on the last bank, so unlike
MMC1 there is no PRG mode to establish: every bank 0-6 is a $8000 window and bank 7 is a
$C000 window, always. A Bank instance therefore still needs its base said out loud, but
the value follows from the bank number rather than from traced code.

The tracer is the interesting half: given entry points it follows control flow to work
out which bytes are reachable as code, which is how regions of kind ``code`` get their
extents instead of us guessing them.
"""

from __future__ import annotations

from dataclasses import dataclass

# Addressing modes: operand size and how to format it.
MODES = {
    "imp": (0, lambda a, pc: ""),
    "acc": (0, lambda a, pc: "A"),
    "imm": (1, lambda a, pc: f"#${a:02X}"),
    "zp": (1, lambda a, pc: f"${a:02X}"),
    "zpx": (1, lambda a, pc: f"${a:02X},X"),
    "zpy": (1, lambda a, pc: f"${a:02X},Y"),
    "izx": (1, lambda a, pc: f"(${a:02X},X)"),
    "izy": (1, lambda a, pc: f"(${a:02X}),Y"),
    "abs": (2, lambda a, pc: f"${a:04X}"),
    "abx": (2, lambda a, pc: f"${a:04X},X"),
    "aby": (2, lambda a, pc: f"${a:04X},Y"),
    "ind": (2, lambda a, pc: f"(${a:04X})"),
    "rel": (1, lambda a, pc: f"${(pc + 2 + (a - 256 if a > 127 else a)) & 0xFFFF:04X}"),
}

_TABLE = """
BRK imp;ORA izx;KIL imp;SLO izx;NOP zp ;ORA zp ;ASL zp ;SLO zp ;PHP imp;ORA imm;ASL acc;ANC imm;NOP abs;ORA abs;ASL abs;SLO abs
BPL rel;ORA izy;KIL imp;SLO izy;NOP zpx;ORA zpx;ASL zpx;SLO zpx;CLC imp;ORA aby;NOP imp;SLO aby;NOP abx;ORA abx;ASL abx;SLO abx
JSR abs;AND izx;KIL imp;RLA izx;BIT zp ;AND zp ;ROL zp ;RLA zp ;PLP imp;AND imm;ROL acc;ANC imm;BIT abs;AND abs;ROL abs;RLA abs
BMI rel;AND izy;KIL imp;RLA izy;NOP zpx;AND zpx;ROL zpx;RLA zpx;SEC imp;AND aby;NOP imp;RLA aby;NOP abx;AND abx;ROL abx;RLA abx
RTI imp;EOR izx;KIL imp;SRE izx;NOP zp ;EOR zp ;LSR zp ;SRE zp ;PHA imp;EOR imm;LSR acc;ALR imm;JMP abs;EOR abs;LSR abs;SRE abs
BVC rel;EOR izy;KIL imp;SRE izy;NOP zpx;EOR zpx;LSR zpx;SRE zpx;CLI imp;EOR aby;NOP imp;SRE aby;NOP abx;EOR abx;LSR abx;SRE abx
RTS imp;ADC izx;KIL imp;RRA izx;NOP zp ;ADC zp ;ROR zp ;RRA zp ;PLA imp;ADC imm;ROR acc;ARR imm;JMP ind;ADC abs;ROR abs;RRA abs
BVS rel;ADC izy;KIL imp;RRA izy;NOP zpx;ADC zpx;ROR zpx;RRA zpx;SEI imp;ADC aby;NOP imp;RRA aby;NOP abx;ADC abx;ROR abx;RRA abx
NOP imm;STA izx;NOP imm;SAX izx;STY zp ;STA zp ;STX zp ;SAX zp ;DEY imp;NOP imm;TXA imp;XAA imm;STY abs;STA abs;STX abs;SAX abs
BCC rel;STA izy;KIL imp;AHX izy;STY zpx;STA zpx;STX zpy;SAX zpy;TYA imp;STA aby;TXS imp;TAS aby;SHY abx;STA abx;SHX aby;AHX aby
LDY imm;LDA izx;LDX imm;LAX izx;LDY zp ;LDA zp ;LDX zp ;LAX zp ;TAY imp;LDA imm;TAX imp;LAX imm;LDY abs;LDA abs;LDX abs;LAX abs
BCS rel;LDA izy;KIL imp;LAX izy;LDY zpx;LDA zpx;LDX zpy;LAX zpy;CLV imp;LDA aby;TSX imp;LAS aby;LDY abx;LDA abx;LDX aby;LAX aby
CPY imm;CMP izx;NOP imm;DCP izx;CPY zp ;CMP zp ;DEC zp ;DCP zp ;INY imp;CMP imm;DEX imp;AXS imm;CPY abs;CMP abs;DEC abs;DCP abs
BNE rel;CMP izy;KIL imp;DCP izy;NOP zpx;CMP zpx;DEC zpx;DCP zpx;CLD imp;CMP aby;NOP imp;DCP aby;NOP abx;CMP abx;DEC abx;DCP abx
CPX imm;SBC izx;NOP imm;ISC izx;CPX zp ;SBC zp ;INC zp ;ISC zp ;INX imp;SBC imm;NOP imp;SBC imm;CPX abs;SBC abs;INC abs;ISC abs
BEQ rel;SBC izy;KIL imp;ISC izy;NOP zpx;SBC zpx;INC zpx;ISC zpx;SED imp;SBC aby;NOP imp;ISC aby;NOP abx;SBC abx;INC abx;ISC abx
"""

OPCODES = [tuple(e.split()) for row in _TABLE.strip().splitlines() for e in row.split(";")]
assert len(OPCODES) == 256

LEGAL = {
    "ADC", "AND", "ASL", "BCC", "BCS", "BEQ", "BIT", "BMI", "BNE", "BPL", "BRK", "BVC",
    "BVS", "CLC", "CLD", "CLI", "CLV", "CMP", "CPX", "CPY", "DEC", "DEX", "DEY", "EOR",
    "INC", "INX", "INY", "JMP", "JSR", "LDA", "LDX", "LDY", "LSR", "NOP", "ORA", "PHA",
    "PHP", "PLA", "PLP", "ROL", "ROR", "RTI", "RTS", "SBC", "SEC", "SED", "SEI", "STA",
    "STX", "STY", "TAX", "TAY", "TSX", "TXA", "TXS", "TYA",
}

# The 28 opcodes that decode to a LEGAL mnemonic but are NOT part of the documented 6502
# instruction set: the undocumented NOPs (which take operands, and so consume 1 or 2 bytes
# a reader would not expect) and the duplicate SBC at $EB. They matter twice over.
#
#  1. A byte scan or a linear decode that treats these as ordinary instructions will walk
#     through data without complaining, because "NOP $12,X" is a perfectly plausible decode
#     of two arbitrary bytes. Counting them as legal is how a trace that has left the rails
#     still reports that it stayed on them.
#  2. They collide with the documented encoding of the same mnemonic and mode - NOP imp is
#     $EA and also $1A, $3A, $5A, $7A, $DA and $FA - so an assembler built by inverting this
#     table cannot round-trip them. tools/yoshi/asm.py asserts the inversion is a bijection,
#     and that assertion only holds once these are excluded.
UNDOCUMENTED = frozenset({
    0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xFA,              # NOP implied
    0x80, 0x82, 0x89, 0xC2, 0xE2,                    # NOP immediate
    0x04, 0x44, 0x64,                                # NOP zero page
    0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4,              # NOP zero page,X
    0x0C,                                            # NOP absolute
    0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC,              # NOP absolute,X
    0xEB,                                            # SBC immediate, duplicate of $E9
})

DOCUMENTED = frozenset(op for op, (mnemonic, _mode) in enumerate(OPCODES)
                       if mnemonic in LEGAL and op not in UNDOCUMENTED)
assert len(DOCUMENTED) == 151, len(DOCUMENTED)


# Anything that ends a straight-line run of instructions.
TERMINATORS = {"RTS", "RTI", "JMP", "BRK", "KIL", "TRUNC"}
BRANCHES = {"BPL", "BMI", "BVC", "BVS", "BCC", "BCS", "BNE", "BEQ"}

HARDWARE = {
    0x2000: "PPUCTRL", 0x2001: "PPUMASK", 0x2002: "PPUSTATUS", 0x2003: "OAMADDR",
    0x2004: "OAMDATA", 0x2005: "PPUSCROLL", 0x2006: "PPUADDR", 0x2007: "PPUDATA",
    0x4000: "SQ1_VOL", 0x4001: "SQ1_SWEEP", 0x4002: "SQ1_LO", 0x4003: "SQ1_HI",
    0x4004: "SQ2_VOL", 0x4005: "SQ2_SWEEP", 0x4006: "SQ2_LO", 0x4007: "SQ2_HI",
    0x4008: "TRI_LINEAR", 0x400A: "TRI_LO", 0x400B: "TRI_HI",
    0x400C: "NOISE_VOL", 0x400E: "NOISE_LO", 0x400F: "NOISE_HI",
    0x4010: "DMC_FREQ", 0x4011: "DMC_RAW", 0x4012: "DMC_START", 0x4013: "DMC_LEN",
    0x4014: "OAMDMA", 0x4015: "APUSTATUS", 0x4016: "JOY1", 0x4017: "JOY2_FRAME",
}


@dataclass
class Insn:
    addr: int
    size: int
    mnemonic: str
    mode: str
    operand: int | None
    raw: bytes

    @property
    def target(self) -> int | None:
        """The CPU address this instruction transfers control to, if it's a static jump."""
        if self.mode == "rel":
            off = self.operand - 256 if self.operand > 127 else self.operand
            return (self.addr + 2 + off) & 0xFFFF
        if self.mode == "abs" and self.mnemonic in ("JMP", "JSR"):
            return self.operand
        return None

    @property
    def illegal(self) -> bool:
        """Not one of the 151 documented opcodes.

        This deliberately counts the undocumented NOPs as illegal. They decode to a legal
        mnemonic and would otherwise let a linear decode walk through arbitrary data while
        reporting that it never met an illegal opcode - which is the exact signal the trace
        relies on to say it stayed on the rails.
        """
        return bool(self.raw) and self.raw[0] not in DOCUMENTED

    @property
    def undocumented(self) -> bool:
        """An opcode with a legal mnemonic that is not the documented encoding of it."""
        return bool(self.raw) and self.raw[0] in UNDOCUMENTED

    def text(self, symbols: dict[int, str] | None = None) -> str:
        if self.mode == "imp":
            return self.mnemonic
        name = None
        if symbols and self.operand is not None and self.mode in ("abs", "zp", "ind"):
            name = symbols.get(self.operand) or HARDWARE.get(self.operand)
        elif self.operand is not None and self.mode in ("abs", "abx", "aby"):
            name = HARDWARE.get(self.operand)
        if name:
            suffix = {"abx": ",X", "aby": ",Y"}.get(self.mode, "")
            return f"{self.mnemonic} {name}{suffix}"
        return f"{self.mnemonic} {MODES[self.mode][1](self.operand, self.addr)}".rstrip()


def decode(mem: bytes, index: int, addr: int) -> Insn:
    """Decode one instruction. ``mem[index]`` is the byte living at CPU address ``addr``."""
    op = mem[index]
    mnemonic, mode = OPCODES[op]
    n = MODES[mode][0]
    raw = mem[index : index + 1 + n]
    if len(raw) < 1 + n:
        # The last bytes of a bank can hold an instruction that runs off the end. That
        # cannot be real code, so report it as truncated rather than reading past.
        return Insn(addr, len(raw), "TRUNC", "imp", None, raw)
    operand = None
    if n == 1:
        operand = raw[1]
    elif n == 2:
        operand = raw[1] | (raw[2] << 8)
    return Insn(addr, 1 + n, mnemonic, mode, operand, raw)


class Bank:
    """A window of PRG mapped at ``base``, disassembled on demand.

    Yoshi banks 16 KB at a time: banks 0 and 1 are mapped at $8000 and bank 7 is fixed at
    $C000, so ``base`` is not optional in practice - passing the wrong one produces legal
    instructions with wrong operands and nothing complains.
    """

    def __init__(self, data: bytes, base: int = 0x8000):
        self.data = data
        self.base = base

    def __contains__(self, addr: int) -> bool:
        return self.base <= addr < self.base + len(self.data)

    def at(self, addr: int) -> Insn:
        return decode(self.data, addr - self.base, addr)

    def run(self, addr: int, limit: int = 512):
        """Disassemble straight-line from ``addr`` until a terminator or ``limit`` instructions."""
        while addr in self and limit > 0:
            insn = self.at(addr)
            yield insn
            if insn.mnemonic in TERMINATORS:
                return
            addr += insn.size
            limit -= 1

    def trace(self, entries: list[int], follow_calls: bool = True) -> dict:
        """Recursive-descent trace. Returns reachable byte addresses, call targets and leads.

        ``leads`` are indirect transfers (``JMP ($xxxx)``, ``RTS``-dispatch style code) that a
        static trace cannot follow; they are what a human has to resolve by hand.
        """
        covered: set[int] = set()
        calls: set[int] = set()
        leads: list[tuple[int, str]] = []
        seen: set[int] = set()
        work = [a for a in entries]

        while work:
            addr = work.pop()
            while True:
                if addr not in self or addr in seen:
                    break
                insn = self.at(addr)
                seen.add(addr)
                covered.update(range(addr, addr + insn.size))

                if insn.mnemonic == "JSR":
                    calls.add(insn.target)
                    if follow_calls:
                        work.append(insn.target)
                elif insn.mnemonic in BRANCHES:
                    work.append(insn.target)
                elif insn.mnemonic == "JMP":
                    if insn.mode == "abs":
                        addr = insn.target
                        continue
                    leads.append((addr, "JMP indirect"))
                    break
                elif insn.mnemonic in ("RTS", "RTI", "BRK", "KIL"):
                    break

                addr += insn.size

        return {"covered": covered, "calls": sorted(calls), "leads": leads, "starts": sorted(seen)}

    def listing(self, addr: int, count: int = 40, symbols: dict[int, str] | None = None) -> str:
        out = []
        for insn in self.run(addr, count):
            raw = " ".join(f"{b:02X}" for b in insn.raw)
            flag = "*" if insn.illegal else " "
            out.append(f"${insn.addr:04X}:{flag} {raw:<9} {insn.text(symbols)}")
        return "\n".join(out)
