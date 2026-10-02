"""A small harness that RUNS this cartridge's own code, for rendering sequences that are
too stateful to reconstruct by reading - the ending and its cutscene.

What it is: a 6502 interpreter (the documented opcodes; ``disasm.OPCODES`` supplies the
decode), the NES memory map with UxROM's bank latch (any write to ``$8000-$FFFF`` selects the
bank in its low three bits - this game writes back the byte it read, so the value is right),
a PPU register and memory model (``$2000/$2001/$2002/$2003/$2004/$2005/$2006/$2007``,
OAM DMA ``$4014``, vertical mirroring, palette mirrors), an NMI at the start of every frame,
and a renderer that draws the nametable, CHR RAM, palette and OAM the code leaves behind.

What it is NOT, and what that means for anything drawn with it:

* **Not cycle-accurate.** Instruction cycles are the base counts; page-crossing and the
  like are ignored. A frame is 29,781 cycles with the NMI first. Timing-sensitive code
  (the DMC IRQ sprite-0 split) is not run: no IRQ is ever delivered.
* **No PPU rendering pipeline.** Nothing is rendered per scanline; a frame is drawn from
  the state at its end, with one scroll value. A mid-frame scroll split is ignored, and
  sprite 0 never hits (``$2002`` bit 6 stays clear).
* **No audio, no controller:** ``$4000-$4017`` writes are ignored except ``$4014``;
  ``$4016/$4017`` read 0 (nothing pressed).
* **Starting state comes from a savestate**, so anything the sequence reads that the
  savestate holds differently from a real run (palette RAM from another stage, CHR RAM
  that the code would have loaded earlier) is the savestate's.

Every result drawn from it is therefore *what this ROM code does from that state under
these simplifications*, not a recording of hardware.
"""

from __future__ import annotations

from . import disasm

OPS = disasm.OPCODES
CYC_BASE = {"imp": 2, "acc": 2, "imm": 2, "zp": 3, "zpx": 4, "zpy": 4, "abs": 4, "abx": 4,
            "aby": 4, "izx": 6, "izy": 5, "ind": 5, "rel": 2}
RMW = {"ASL", "LSR", "ROL", "ROR", "INC", "DEC"}
STORES = {"STA", "STX", "STY"}
CYC_FRAME = 29781


class StopRun(Exception):
    pass


class Machine:
    def __init__(self, rm):
        self.banks = [rm.prg_bank(i) for i in range(8)]
        self.ram = bytearray(0x800)
        self.chr = bytearray(0x2000)
        self.nt = bytearray(0x800)
        self.pal = bytearray(32)
        self.oam = bytearray(256)
        self.bank = 0
        self.a = self.x = self.y = 0
        self.s = 0xFD
        self.p = 0x24
        self.pc = 0
        self.ctrl = self.mask = 0
        self.vbl = False
        self.w = 0
        self.vaddr = 0
        self.tmp = 0
        self.buf = 0
        self.oamaddr = 0
        self.scroll_x = self.scroll_y = 0
        self.cycles = 0
        self.frame = 0
        self.fc = 0                     # cycles into the current frame
        self.in_nmi = False
        self.spr0 = False
        self.scroll_log = [(0, 0, 0, 0)]
        self.chr_writes = 0
        self.nmi_vec = self.banks[7][0x3FFA] | self.banks[7][0x3FFB] << 8

    # ---------------------------------------------------------------- state in
    def load_savestate(self, st: dict):
        self.ram[:] = st["RAM"]
        self.nt[:] = st["NTAR"]
        self.pal[:] = st["PRAM"]
        self.oam[:] = st["SPRA"]
        self.chr[:] = st["CHRR"]
        ppur = st["PPUR"]
        self.ctrl, self.mask = ppur[0], ppur[1]
        self.bank = self.ram[0x04] & 7

    # ---------------------------------------------------------------- memory
    def read(self, a):
        if a < 0x2000:
            return self.ram[a & 0x7FF]
        if a >= 0xC000:
            return self.banks[7][a - 0xC000]
        if a >= 0x8000:
            return self.banks[self.bank][a - 0x8000]
        if a < 0x4000:
            r = a & 7
            if r == 2:
                v = (0x80 if self.vbl else 0) | (0x40 if self.spr0 else 0)
                if not self.in_nmi:             # the NMI handler's own read must not eat the
                    self.vbl = False            # flag a main-code wait loop is polling
                self.w = 0
                return v
            if r == 4:
                return self.oam[self.oamaddr]
            if r == 7:
                return self._ppu_read()
            return 0
        return 0

    def write(self, a, v):
        if a < 0x2000:
            self.ram[a & 0x7FF] = v
        elif a >= 0x8000:
            self.bank = v & 7
        elif a < 0x4000:
            r = a & 7
            if r == 0:
                self.ctrl = v
                self.tmp = (self.tmp & 0xF3FF) | (v & 3) << 10
                self.scroll_log.append((self.fc, self.scroll_x, self.scroll_y, v))
            elif r == 1:
                self.mask = v
            elif r == 3:
                self.oamaddr = v
            elif r == 4:
                self.oam[self.oamaddr] = v
                self.oamaddr = (self.oamaddr + 1) & 0xFF
            elif r == 5:
                if self.w == 0:
                    self.scroll_x = v
                    self.w = 1
                else:
                    self.scroll_y = v
                    self.w = 0
                self.scroll_log.append((self.fc, self.scroll_x, self.scroll_y, self.ctrl))
            elif r == 6:
                if self.w == 0:
                    self.tmp = (self.tmp & 0x00FF) | (v & 0x3F) << 8
                    self.w = 1
                else:
                    self.tmp = (self.tmp & 0xFF00) | v
                    self.vaddr = self.tmp
                    self.w = 0
            elif r == 7:
                self._ppu_write(self.vaddr, v)
                self.vaddr = (self.vaddr + (32 if self.ctrl & 4 else 1)) & 0x3FFF
        elif a == 0x4014:
            base = (v & 7) << 8
            for i in range(256):
                self.oam[(self.oamaddr + i) & 0xFF] = self.ram[base + i]

    def _nt_index(self, a):
        return ((a >> 10) & 1) * 0x400 + (a & 0x3FF)           # vertical mirroring

    def _pal_index(self, a):
        i = a & 0x1F
        return i & 0x0F if i & 3 == 0 else i

    def _ppu_write(self, a, v):
        a &= 0x3FFF
        if a < 0x2000:
            self.chr[a] = v
            self.chr_writes += 1
        elif a < 0x3F00:
            self.nt[self._nt_index(a & 0x2FFF)] = v
        else:
            self.pal[self._pal_index(a)] = v

    def _ppu_read(self):
        a = self.vaddr & 0x3FFF
        if a >= 0x3F00:
            v = self.pal[self._pal_index(a)]
            self.buf = self.nt[self._nt_index(a & 0x2FFF)]
        else:
            v, self.buf = self.buf, (self.chr[a] if a < 0x2000 else self.nt[self._nt_index(a & 0x2FFF)])
        self.vaddr = (self.vaddr + (32 if self.ctrl & 4 else 1)) & 0x3FFF
        return v

    # ---------------------------------------------------------------- stack
    def push(self, v):
        self.ram[0x100 + self.s] = v & 0xFF
        self.s = (self.s - 1) & 0xFF

    def pull(self):
        self.s = (self.s + 1) & 0xFF
        return self.ram[0x100 + self.s]

    # ---------------------------------------------------------------- CPU
    def _flags_nz(self, v):
        self.p = (self.p & 0x7D) | (v & 0x80) | (2 if v == 0 else 0)

    def step(self):
        pc = self.pc
        op = self.read(pc)
        mn, mode = OPS[op]
        cyc = CYC_BASE.get(mode, 2)
        read, write = self.read, self.write
        if mode == "imp" or mode == "acc":
            ea = None
            self.pc = pc + 1
        elif mode == "imm":
            ea = pc + 1
            self.pc = pc + 2
        elif mode == "rel":
            off = read(pc + 1)
            ea = (pc + 2 + (off - 256 if off > 127 else off)) & 0xFFFF
            self.pc = pc + 2
        elif mode == "zp":
            ea = read(pc + 1)
            self.pc = pc + 2
        elif mode == "zpx":
            ea = (read(pc + 1) + self.x) & 0xFF
            self.pc = pc + 2
        elif mode == "zpy":
            ea = (read(pc + 1) + self.y) & 0xFF
            self.pc = pc + 2
        elif mode == "abs":
            ea = read(pc + 1) | read(pc + 2) << 8
            self.pc = pc + 3
        elif mode == "abx":
            ea = ((read(pc + 1) | read(pc + 2) << 8) + self.x) & 0xFFFF
            self.pc = pc + 3
            if mn in STORES or mn in RMW:
                cyc += 1
        elif mode == "aby":
            ea = ((read(pc + 1) | read(pc + 2) << 8) + self.y) & 0xFFFF
            self.pc = pc + 3
            if mn in STORES:
                cyc += 1
        elif mode == "izx":
            z = (read(pc + 1) + self.x) & 0xFF
            ea = read(z) | read((z + 1) & 0xFF) << 8
            self.pc = pc + 2
        elif mode == "izy":
            z = read(pc + 1)
            ea = ((read(z) | read((z + 1) & 0xFF) << 8) + self.y) & 0xFFFF
            self.pc = pc + 2
            if mn in STORES:
                cyc += 1
        elif mode == "ind":
            ptr = read(pc + 1) | read(pc + 2) << 8
            ea = read(ptr) | read((ptr & 0xFF00) | ((ptr + 1) & 0xFF)) << 8
            self.pc = pc + 3
        else:
            raise StopRun(f"mode {mode}")
        if mn in RMW and mode not in ("acc", "imp"):
            cyc += 2

        a, p = self.a, self.p
        if mn == "LDA":
            self.a = v = read(ea)
            self._flags_nz(v)
        elif mn == "LDX":
            self.x = v = read(ea)
            self._flags_nz(v)
        elif mn == "LDY":
            self.y = v = read(ea)
            self._flags_nz(v)
        elif mn == "STA":
            write(ea, a)
        elif mn == "STX":
            write(ea, self.x)
        elif mn == "STY":
            write(ea, self.y)
        elif mn == "TAX":
            self.x = a
            self._flags_nz(a)
        elif mn == "TAY":
            self.y = a
            self._flags_nz(a)
        elif mn == "TXA":
            self.a = self.x
            self._flags_nz(self.a)
        elif mn == "TYA":
            self.a = self.y
            self._flags_nz(self.a)
        elif mn == "TSX":
            self.x = self.s
            self._flags_nz(self.x)
        elif mn == "TXS":
            self.s = self.x
        elif mn == "INX":
            self.x = (self.x + 1) & 0xFF
            self._flags_nz(self.x)
        elif mn == "INY":
            self.y = (self.y + 1) & 0xFF
            self._flags_nz(self.y)
        elif mn == "DEX":
            self.x = (self.x - 1) & 0xFF
            self._flags_nz(self.x)
        elif mn == "DEY":
            self.y = (self.y - 1) & 0xFF
            self._flags_nz(self.y)
        elif mn == "INC":
            v = (read(ea) + 1) & 0xFF
            write(ea, v)
            self._flags_nz(v)
        elif mn == "DEC":
            v = (read(ea) - 1) & 0xFF
            write(ea, v)
            self._flags_nz(v)
        elif mn in ("AND", "ORA", "EOR"):
            m = read(ea)
            self.a = v = a & m if mn == "AND" else a | m if mn == "ORA" else a ^ m
            self._flags_nz(v)
        elif mn == "ADC" or mn == "SBC":
            m = read(ea)
            if mn == "SBC":
                m ^= 0xFF
            r = a + m + (p & 1)
            ov = (~(a ^ m) & (a ^ r) & 0x80) != 0
            self.a = r & 0xFF
            self.p = (p & 0x3C) | (1 if r > 0xFF else 0) | (0x40 if ov else 0)
            self._flags_nz(self.a)
        elif mn in ("CMP", "CPX", "CPY"):
            reg = a if mn == "CMP" else self.x if mn == "CPX" else self.y
            m = read(ea)
            r = reg - m
            self.p = (p & 0x7C) | (1 if reg >= m else 0)
            self._flags_nz(r & 0xFF)
        elif mn == "BIT":
            m = read(ea)
            self.p = (p & 0x3D) | (m & 0xC0) | (2 if (a & m) == 0 else 0)
        elif mn in ("ASL", "LSR", "ROL", "ROR"):
            v = a if mode == "acc" else read(ea)
            c = p & 1
            if mn == "ASL":
                nc, v = v >> 7, (v << 1) & 0xFF
            elif mn == "LSR":
                nc, v = v & 1, v >> 1
            elif mn == "ROL":
                nc, v = v >> 7, ((v << 1) | c) & 0xFF
            else:
                nc, v = v & 1, (v >> 1) | (c << 7)
            self.p = (self.p & 0xFE) | nc
            self._flags_nz(v)
            if mode == "acc":
                self.a = v
            else:
                write(ea, v)
        elif mn == "JMP":
            self.pc = ea
        elif mn == "JSR":
            r = (pc + 2) & 0xFFFF
            self.push(r >> 8)
            self.push(r & 0xFF)
            self.pc = ea
            cyc = 6
        elif mn == "RTS":
            lo = self.pull()
            self.pc = ((lo | self.pull() << 8) + 1) & 0xFFFF
            cyc = 6
        elif mn == "RTI":
            self.p = (self.pull() & 0xEF) | 0x20
            lo = self.pull()
            self.pc = lo | self.pull() << 8
            cyc = 6
        elif mn in ("BEQ", "BNE", "BCS", "BCC", "BMI", "BPL", "BVS", "BVC"):
            f = {"BEQ": (2, 1), "BNE": (2, 0), "BCS": (1, 1), "BCC": (1, 0),
                 "BMI": (0x80, 1), "BPL": (0x80, 0), "BVS": (0x40, 1), "BVC": (0x40, 0)}[mn]
            if bool(p & f[0]) == bool(f[1]):
                self.pc = ea
                cyc += 1
        elif mn == "PHA":
            self.push(a)
            cyc = 3
        elif mn == "PLA":
            self.a = self.pull()
            self._flags_nz(self.a)
            cyc = 4
        elif mn == "PHP":
            self.push(p | 0x30)
            cyc = 3
        elif mn == "PLP":
            self.p = (self.pull() & 0xEF) | 0x20
            cyc = 4
        elif mn == "CLC":
            self.p = p & 0xFE
        elif mn == "SEC":
            self.p = p | 1
        elif mn == "CLI":
            self.p = p & 0xFB
        elif mn == "SEI":
            self.p = p | 4
        elif mn == "CLD":
            self.p = p & 0xF7
        elif mn == "SED":
            self.p = p | 8
        elif mn == "CLV":
            self.p = p & 0xBF
        elif mn == "NOP":
            pass
        elif mn == "BRK":
            raise StopRun(f"BRK at ${pc:04X} bank {self.bank}")
        else:
            raise StopRun(f"{mn} (opcode ${op:02X}) at ${pc:04X} bank {self.bank}")
        self.cycles += cyc
        return cyc

    # ---------------------------------------------------------------- frames
    def nmi(self):
        self.push(self.pc >> 8)
        self.push(self.pc & 0xFF)
        self.push(self.p & ~0x10)
        self.p |= 4
        self.pc = self.nmi_vec

    def run_frame(self, stops=(), trace=None):
        """One frame: vblank + NMI (run to its RTI), then the main code for the rest of the
        cycle budget. Returns the stop address reached, or None. The scroll registers are
        sampled at the end of the frame."""
        self.frame += 1
        budget = CYC_FRAME
        self.vbl = True
        self.spr0 = False
        self.fc = 0
        self.scroll_log = [(0, self.scroll_x, self.scroll_y, self.ctrl)]
        stopped = None
        if self.ctrl & 0x80:
            self.nmi()
            self.in_nmi = True
            for _ in range(40000):
                rti = self.read(self.pc) == 0x40
                budget -= self.step()
                self.fc = CYC_FRAME - budget
                if rti:
                    break
            else:
                self.in_nmi = False
                raise StopRun("NMI handler did not return")
            self.in_nmi = False
        hit_at = 2273 + 114 + (self.oam[0] + 1) * 113.67 if self.oam[0] < 0xEF else None
        while budget > 0:
            fc = self.fc = CYC_FRAME - budget
            if self.vbl and fc > 2273:                      # vblank lasts ~2273 cycles
                self.vbl = False
            if hit_at is not None and not self.spr0 and fc >= hit_at and self.mask & 0x18 == 0x18:
                self.spr0 = True
            if self.pc in stops:
                stopped = self.pc
                break
            if trace is not None:
                trace(self)
            budget -= self.step()
        self.vbl = False
        return stopped

    # ---------------------------------------------------------------- picture
    def render(self, rgb, scroll=True, bg=True, sprites=True):
        """The 256 x 240 picture from the state now: nametable + CHR RAM + palette + OAM."""
        from PIL import Image
        img = Image.new("RGB", (256, 240), rgb[self.pal[0] & 0x3F])
        px = img.load()
        bg_on, spr_on = bool(self.mask & 8) and bg, bool(self.mask & 0x10) and sprites
        bgbase = 0x1000 if self.ctrl & 0x10 else 0
        opaque = [[False] * 256 for _ in range(240)]
        if bg_on:
            log = self.scroll_log if scroll else [(0, 0, 0, self.ctrl)]
            for y in range(240):
                at = 2273 + 114 + y * 113.67
                e = log[0]
                for ent in log:
                    if ent[0] <= at:
                        e = ent
                _, sx, sy, cx = e
                if not scroll:
                    sx = sy = 0
                nx, ny = cx & 1, (cx >> 1) & 1
                wy = y + sy + ny * 240
                row = (wy // 8) % 60
                tnt = (row // 30) * 2
                trow = row % 30
                for x in range(256):
                    wx = x + sx + nx * 256
                    col = (wx // 8) % 64
                    tx = col % 32
                    ntbase = 0x400 * ((col // 32) & 1)               # vertical mirroring
                    n = self.nt[ntbase + trow * 32 + tx]
                    at = self.nt[ntbase + 0x3C0 + (trow // 4) * 8 + tx // 4]
                    pal = (at >> (((trow % 4) // 2) * 4 + ((tx % 4) // 2) * 2)) & 3
                    d = bgbase + 16 * n
                    fy, fx = wy % 8, wx % 8
                    v = ((self.chr[d + fy] >> (7 - fx)) & 1) | (((self.chr[d + 8 + fy] >> (7 - fx)) & 1) << 1)
                    if v:
                        px[x, y] = rgb[self.pal[4 * pal + v] & 0x3F]
                        opaque[y][x] = True
        if spr_on:
            tall = bool(self.ctrl & 0x20)
            sbase = 0x1000 if self.ctrl & 0x08 else 0
            for i in range(63, -1, -1):
                y, t, at, x = self.oam[4 * i:4 * i + 4]
                if y >= 0xEF:
                    continue
                pal = 16 + 4 * (at & 3)
                fh, fv, behind = at & 0x40, at & 0x80, at & 0x20
                h = 16 if tall else 8
                for yy in range(h):
                    sy_ = (h - 1 - yy) if fv else yy
                    if tall:
                        tile = (t & 0xFE) + (sy_ // 8)
                        base = 0x1000 if t & 1 else 0
                    else:
                        tile, base = t, sbase
                    d = base + 16 * tile + sy_ % 8
                    lo, hi = self.chr[d], self.chr[d + 8]
                    Y = y + 1 + yy
                    if Y >= 240:
                        break
                    for xx in range(8):
                        sx_ = (7 - xx) if fh else xx
                        v = ((lo >> (7 - sx_)) & 1) | (((hi >> (7 - sx_)) & 1) << 1)
                        X = x + xx
                        if v and X < 256 and not (behind and opaque[Y][X]):
                            px[X, Y] = rgb[self.pal[pal + v] & 0x3F]
        return img
