; The 16-byte iNES container header. Not part of the cartridge - it is
; metadata the dumper added, and the NES never reads it.
.org $0000
        .byte   $4E,$45,$53,$1A,$08,$00,$21,$00,$00,$00,$00,$00,$00,$00,$00,$00
