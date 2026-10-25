; PRG bank 7 - the fixed bank: vectors, bank switching, the far-call trampoline, the inline-argument helpers
; $C000-$FFFF
; The fixed window. UxROM wires the last bank here and nothing can move it.
.org $C000


; ---- bank7.code_C000 (code) $C000-$C002, 3 bytes
L7_C000:
        jmp     L7_FEDE

; ---- bank7.code_C003 (code) $C003-$C005, 3 bytes
L7_C003:
        jmp     L7_D705

; ---- bank7.code_C006 (code) $C006-$C008, 3 bytes
L7_C006:
        jmp     L7_D76F

; ---- bank7.code_C009 (code) $C009-$C00B, 3 bytes
L7_C009:
        jmp     L7_FD53

; ---- bank7.code_C00C (code) $C00C-$C00E, 3 bytes
L7_C00C:
        jmp     L7_FD67

; ---- bank7.code_C00F (code) $C00F-$C011, 3 bytes
L7_C00F:
        jmp     L7_D4C1

; ---- bank7.code_C012 (code) $C012-$C014, 3 bytes
L7_C012:
        jmp     L7_D4ED

; ---- bank7.code_C015 (code) $C015-$C017, 3 bytes
L7_C015:
        jmp     L7_D534

; ---- bank7.code_C018 (code) $C018-$C01A, 3 bytes
L7_C018:
        jmp     L7_E445

; ---- bank7.code_C01B (code) $C01B-$C01D, 3 bytes
L7_C01B:
        jmp     L7_D4FD

; ---- bank7.code_C01E (code) $C01E-$C020, 3 bytes
L7_C01E:
        jmp     L7_D64C

; ---- bank7.code_C021 (code) $C021-$C023, 3 bytes
L7_C021:
        jmp     L7_FFD1

; ---- bank7.code_C024 (code) $C024-$C026, 3 bytes
L7_C024:
        jmp     L7_FF8B

; ---- bank7.code_C027 (code) $C027-$C029, 3 bytes
L7_C027:
        jmp     L7_EA8C

; ---- bank7.code_C02A (code) $C02A-$C02C, 3 bytes
L7_C02A:
        jmp     L7_DFB1

; ---- bank7.code_C02D (code) $C02D-$C02F, 3 bytes
L7_C02D:
        jmp     L7_DAE1

; ---- bank7.code_C030 (code) $C030-$C032, 3 bytes
L7_C030:
        jmp     L7_D852

; ---- bank7.code_C033 (code) $C033-$C035, 3 bytes
L7_C033:
        jmp     L7_DF8C

; ---- bank7.code_C036 (code) $C036-$C038, 3 bytes
L7_C036:
        jmp     L7_D5F8

; ---- bank7.code_C039 (code) $C039-$C03B, 3 bytes
L7_C039:
        jmp     L7_D6C0

; ---- bank7.code_C03C (code) $C03C-$C03E, 3 bytes
L7_C03C:
        jmp     L7_D6E0

; ---- bank7.code_C03F (code) $C03F-$C041, 3 bytes
L7_C03F:
        jmp     L7_D6F7

; ---- bank7.code_C042 (code) $C042-$C044, 3 bytes
L7_C042:
        jmp     L7_D7F9

; ---- bank7.code_C045 (code) $C045-$C047, 3 bytes
L7_C045:
        jmp     L7_D7C3

; ---- bank7.code_C048 (code) $C048-$C04A, 3 bytes
L7_C048:
        jmp     L7_CCBF

; ---- bank7.code_C04B (code) $C04B-$C04D, 3 bytes
L7_C04B:
        jmp     L7_D6D3

; ---- bank7.code_C04E (code) $C04E-$C050, 3 bytes
L7_C04E:
        jmp     L7_E24B

; ---- bank7.code_C051 (code) $C051-$C053, 3 bytes
L7_C051:
        jmp     L7_E1CD

; ---- bank7.code_C054 (code) $C054-$C056, 3 bytes
L7_C054:
        jmp     L7_D865

; ---- bank7.code_C057 (code) $C057-$C059, 3 bytes
L7_C057:
        jmp     L7_DFBC

; ---- bank7.code_C05A (code) $C05A-$C05C, 3 bytes
L7_C05A:
        jmp     L7_E213

; ---- bank7.code_C05D (code) $C05D-$C05F, 3 bytes
L7_C05D:
        jmp     L7_D92D

; ---- bank7.code_C060 (code) $C060-$C062, 3 bytes
L7_C060:
        jmp     L7_EDE5

; ---- bank7.code_C063 (code) $C063-$C065, 3 bytes
L7_C063:
        jmp     L7_EDF4

; ---- bank7.code_C066 (code) $C066-$C068, 3 bytes
L7_C066:
        jmp     L7_EFE9

; ---- bank7.code_C069 (code) $C069-$C06B, 3 bytes
L7_C069:
        jmp     L7_F726

; ---- bank7.code_C06C (code) $C06C-$C06E, 3 bytes
L7_C06C:
        jmp     L7_D5CC

; ---- bank7.code_C06F (code) $C06F-$C071, 3 bytes
L7_C06F:
        jmp     L7_D576

; ---- bank7.code_C072 (code) $C072-$C074, 3 bytes
L7_C072:
        jmp     L7_E1C3

; ---- bank7.code_C075 (code) $C075-$C077, 3 bytes
L7_C075:
        jmp     L7_E498

; ---- bank7.code_C078 (code) $C078-$C07A, 3 bytes
L7_C078:
        jmp     L7_EFC7

; ---- bank7.code_C07B (code) $C07B-$C07D, 3 bytes
L7_C07B:
        jmp     L7_EFAC

; ---- bank7.code_C07E (code) $C07E-$C080, 3 bytes
L7_C07E:
        jmp     L7_D99C

; ---- bank7.code_C081 (code) $C081-$C083, 3 bytes
L7_C081:
        jmp     L7_D9ED

; ---- bank7.code_C084 (code) $C084-$C086, 3 bytes
L7_C084:
        jmp     L7_E453

; ---- bank7.code_C087 (code) $C087-$C089, 3 bytes
L7_C087:
        jmp     L7_E522

; ---- bank7.code_C08A (code) $C08A-$C08C, 3 bytes
L7_C08A:
        jmp     L7_ED51

; ---- bank7.code_C08D (code) $C08D-$C08F, 3 bytes
L7_C08D:
        jmp     L7_CBE8

; ---- bank7.code_C090 (code) $C090-$C092, 3 bytes
L7_C090:
        jmp     L7_CBFC

; ---- bank7.code_C093 (code) $C093-$C095, 3 bytes
L7_C093:
        jmp     L7_CC34

; ---- bank7.code_C096 (code) $C096-$C098, 3 bytes
L7_C096:
        jmp     L7_CDB4

; ---- bank7.code_C099 (code) $C099-$C09B, 3 bytes
L7_C099:
        jmp     L7_CE88

; ---- bank7.code_C09C (code) $C09C-$C09E, 3 bytes
L7_C09C:
        jmp     L7_CD12

; ---- bank7.code_C09F (code) $C09F-$C0A1, 3 bytes
L7_C09F:
        jmp     L7_CD46

; ---- bank7.code_C0A2 (code) $C0A2-$C0A4, 3 bytes
L7_C0A2:
        jmp     L7_CD99

; ---- bank7.code_C0A5 (code) $C0A5-$C0A7, 3 bytes
L7_C0A5:
        jmp     L7_CD7A

; ---- bank7.code_C0A8 (code) $C0A8-$C0AA, 3 bytes
L7_C0A8:
        jmp     L7_CF5F

; ---- bank7.code_C0AB (code) $C0AB-$C0AD, 3 bytes
L7_C0AB:
        jmp     L7_CF68

; ---- bank7.code_C0AE (code) $C0AE-$C0B0, 3 bytes
L7_C0AE:
        jmp     L7_CFA0

; ---- bank7.code_C0B1 (code) $C0B1-$C0B3, 3 bytes
L7_C0B1:
        jmp     L7_D229

; ---- bank7.code_C0B4 (code) $C0B4-$C0B6, 3 bytes
L7_C0B4:
        jmp     L7_D22C

; ---- bank7.code_C0B7 (code) $C0B7-$C0B9, 3 bytes
L7_C0B7:
        jmp     L7_D230

; ---- bank7.code_C0BA (code) $C0BA-$C0BC, 3 bytes
L7_C0BA:
        jmp     L7_D266

; ---- bank7.code_C0BD (code) $C0BD-$C0BF, 3 bytes
L7_C0BD:
        jmp     L7_D276

; ---- bank7.code_C0C0 (code) $C0C0-$C0C2, 3 bytes
L7_C0C0:
        jmp     L7_D279

; ---- bank7.code_C0C3 (code) $C0C3-$C0C5, 3 bytes
L7_C0C3:
        jmp     L7_D281

; ---- bank7.code_C0C6 (code) $C0C6-$C0C8, 3 bytes
L7_C0C6:
        jmp     L7_D294

; ---- bank7.code_C0C9 (code) $C0C9-$C0CB, 3 bytes
L7_C0C9:
        jmp     L7_D297

; ---- bank7.code_C0CC (code) $C0CC-$C0CE, 3 bytes
L7_C0CC:
        jmp     L7_D33F

; ---- bank7.code_C0CF (code) $C0CF-$C0D1, 3 bytes
L7_C0CF:
        jmp     L7_D29F

; ---- bank7.code_C0D2 (code) $C0D2-$C0D4, 3 bytes
L7_C0D2:
        jmp     L7_D2BB

; ---- bank7.code_C0D5 (code) $C0D5-$C0D7, 3 bytes
L7_C0D5:
        jmp     L7_D2C5

; ---- bank7.code_C0D8 (code) $C0D8-$C0DA, 3 bytes
L7_C0D8:
        jmp     L7_D39B

; ---- bank7.code_C0DB (code) $C0DB-$C0DD, 3 bytes
L7_C0DB:
        jmp     L7_CF05

; ---- bank7.code_C0DE (code) $C0DE-$C0E0, 3 bytes
L7_C0DE:
        jmp     L7_EDB7

; ---- bank7.code_C0E1 (code) $C0E1-$C0E3, 3 bytes
L7_C0E1:
        jmp     L7_EFE0

; ---- bank7.code_C0E4 (code) $C0E4-$C0E6, 3 bytes
L7_C0E4:
        jmp     L7_DA8B

; ---- bank7.code_C0E7 (code) $C0E7-$C0E9, 3 bytes
L7_C0E7:
        jmp     L7_DA1D

; ---- bank7.code_C0EA (code) $C0EA-$C0EC, 3 bytes
L7_C0EA:
        jmp     L7_F9D1

; ---- bank7.code_C0ED (code) $C0ED-$C0EF, 3 bytes
L7_C0ED:
        jmp     L7_EDD1

; ---- bank7.code_C0F0 (code) $C0F0-$C0F2, 3 bytes
L7_C0F0:
        jmp     L7_F9E9

; ---- bank7.code_C0F3 (code) $C0F3-$C0F5, 3 bytes
L7_C0F3:
        jmp     L7_FA17

; ---- bank7.code_C0F6 (code) $C0F6-$C0F8, 3 bytes
L7_C0F6:
        jmp     L7_F97E

; ---- bank7.code_C0F9 (code) $C0F9-$C0FB, 3 bytes
L7_C0F9:
        jmp     L7_F982

; ---- bank7.code_C0FC (code) $C0FC-$C0FE, 3 bytes
L7_C0FC:
        jmp     L7_F85D

; ---- bank7.code_C0FF (code) $C0FF-$C101, 3 bytes
L7_C0FF:
        jmp     L7_F863

; ---- bank7.code_C102 (code) $C102-$C104, 3 bytes
L7_C102:
        jmp     L7_F8CE

; ---- bank7.code_C105 (code) $C105-$C107, 3 bytes
L7_C105:
        jmp     L7_FA4B

; ---- bank7.code_C108 (code) $C108-$C10A, 3 bytes
L7_C108:
        jmp     L7_FA5B

; ---- bank7.code_C10B (code) $C10B-$C10D, 3 bytes
L7_C10B:
        jmp     L7_F9AE

; ---- bank7.code_C10E (code) $C10E-$C110, 3 bytes
L7_C10E:
        jmp     L7_F9BA

; ---- bank7.code_C111 (code) $C111-$C113, 3 bytes
L7_C111:
        jmp     L7_FA6B

; ---- bank7.code_C114 (code) $C114-$C116, 3 bytes
L7_C114:
        jmp     L7_F865

; ---- bank7.code_C117 (code) $C117-$C119, 3 bytes
L7_C117:
        jmp     L7_FA96

; ---- bank7.code_C11A (code) $C11A-$C11C, 3 bytes
L7_C11A:
        jmp     L7_FAB7

; ---- bank7.code_C11D (code) $C11D-$C11F, 3 bytes
L7_C11D:
        jmp     L7_FADE

; ---- bank7.code_C120 (code) $C120-$C122, 3 bytes
L7_C120:
        jmp     L7_FB12

; ---- bank7.code_C123 (code) $C123-$C125, 3 bytes
L7_C123:
        jmp     L7_FB64

; ---- bank7.code_C126 (code) $C126-$C128, 3 bytes
L7_C126:
        jmp     L7_FB52

; ---- bank7.code_C129 (code) $C129-$C12B, 3 bytes
L7_C129:
        jmp     L7_FB76

; ---- bank7.code_C12C (code) $C12C-$C12E, 3 bytes
L7_C12C:
        jmp     L7_FCD5

; ---- bank7.code_C12F (code) $C12F-$C131, 3 bytes
L7_C12F:
        jmp     L7_FCE7

; ---- bank7.code_C132 (code) $C132-$C134, 3 bytes
L7_C132:
        jmp     L7_FD0E

; ---- bank7.code_C135 (code) $C135-$C137, 3 bytes
L7_C135:
        jmp     L7_FD77

; ---- bank7.code_C138 (code) $C138-$C13A, 3 bytes
L7_C138:
        jmp     L7_FDAA

; ---- bank7.code_C13B (code) $C13B-$C13D, 3 bytes
L7_C13B:
        jmp     L7_FDF8

; ---- bank7.code_C13E (code) $C13E-$C140, 3 bytes
L7_C13E:
        jmp     L7_FE3D

; ---- bank7.code_C141 (code) $C141-$C143, 3 bytes
L7_C141:
        jmp     L7_FE57

; ---- bank7.code_C144 (code) $C144-$C146, 3 bytes
L7_C144:
        jmp     L7_FE63

; ---- bank7.code_C147 (code) $C147-$C149, 3 bytes
L7_C147:
        jmp     L7_FE79

; ---- bank7.code_C14A (code) $C14A-$C14C, 3 bytes
L7_C14A:
        jmp     L7_E655

; ---- bank7.code_C14D (code) $C14D-$C14F, 3 bytes
L7_C14D:
        jmp     L7_FF4A

; ---- bank7.code_C150 (code) $C150-$C152, 3 bytes
L7_C150:
        jmp     L7_FF5D

; ---- bank7.code_C153 (code) $C153-$C155, 3 bytes
L7_C153:
        jmp     L7_E0F9

; ---- bank7.code_C156 (code) $C156-$C158, 3 bytes
L7_C156:
        jmp     L7_DB52

; ---- bank7.code_C159 (code) $C159-$C15B, 3 bytes
L7_C159:
        jmp     L7_EA68

; ---- bank7.code_C15C (code) $C15C-$C15E, 3 bytes
L7_C15C:
        jmp     L7_E66A

; ---- bank7.code_C15F (code) $C15F-$C161, 3 bytes
L7_C15F:
        jmp     L7_FFDC

; ---- bank7.code_C162 (code) $C162-$C164, 3 bytes
L7_C162:
        jmp     L7_FE88

; ---- bank7.code_C165 (code) $C165-$C167, 3 bytes
L7_C165:
        jmp     L7_D385

; ---- bank7.code_C168 (code) $C168-$C16A, 3 bytes
L7_C168:
        jmp     L7_FECC

; ---- bank7.code_C16B (code) $C16B-$C16D, 3 bytes
L7_C16B:
        jmp     L7_F493

; ---- bank7.code_C16E (code) $C16E-$C170, 3 bytes
L7_C16E:
        jmp     L7_D950

; ---- bank7.code_C171 (code) $C171-$C173, 3 bytes
L7_C171:
        jmp     L7_D53F

; ---- bank7.tbl_C174 (data) $C174-$C200, 141 bytes
; Hitbox half-width, by metasprite id
        .byte   $04,$0C,$0A,$08,$06,$08,$0A,$0C,$0A,$06,$04,$02,$01,$01,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$14,$0A,$06,$06,$06,$06,$FF,$02,$0E
        .byte   $0E,$10,$00,$00,$00,$02,$08,$04,$0C,$08,$10,$06,$04,$06,$08,$10
        .byte   $06,$08,$0A,$0C,$0C,$0A,$08,$03,$FF,$FF,$FF,$0A,$0A,$20,$10,$10
        .byte   $18,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$FF,$FF,$FF,$FF
        .byte   $06,$20,$0C,$00,$0C,$0C,$14,$14,$14,$0C,$0C,$03,$03,$03,$03,$05
        .byte   $06,$0E,$00,$FF,$FF,$FF,$08,$00,$00,$0C,$00,$0C,$0A,$18,$07,$00
        .byte   $00,$00,$00,$0A,$07,$0C,$00,$00,$00,$06,$0E,$18,$00,$14,$14,$0A
        .byte   $0E,$00,$10,$10,$00,$00,$00,$00,$0C,$00,$00,$08,$0A

; ---- bank7.tbl_C201 (data) $C201-$C28C, 140 bytes
; Hitbox half-height, by metasprite id
        .byte   $08,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0A,$06,$04,$02,$01,$01,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$0A,$14,$06,$06,$06,$06,$FF,$0C,$0C
        .byte   $0C,$10,$00,$00,$00,$02,$04,$08,$08,$0C,$1E,$0C,$0C,$08,$06,$10
        .byte   $06,$08,$0A,$0C,$04,$08,$0C,$05,$FF,$FF,$FF,$05,$05,$10,$10,$10
        .byte   $20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$FF,$FF,$FF,$FF
        .byte   $0C,$20,$10,$00,$0A,$04,$08,$04,$08,$0C,$0C,$0C,$0C,$0C,$0C,$08
        .byte   $20,$06,$00,$FF,$FF,$FF,$04,$00,$00,$08,$00,$10,$10,$0E,$18,$00
        .byte   $00,$00,$00,$07,$06,$07,$00,$00,$00,$06,$0E,$10,$00,$10,$10,$28
        .byte   $08,$00,$18,$20,$00,$00,$00,$00,$18,$00,$00,$08

; ---- bank7.tbl_C28D (pointer_table) $C28D-$C318, 140 bytes
; Metasprite pointers, low bytes
        .byte   $10,$46,$5F,$68,$71,$83,$8C,$95,$B0,$BF,$C6,$CD,$D2,$D7,$E6,$EF
        .byte   $F8,$00,$12,$1B,$23,$2B,$36,$42,$4C,$52,$58,$5F,$66,$6F,$74,$7A
        .byte   $8D,$A0,$B9,$C6,$D3,$D9,$DE,$E8,$F2,$FC,$34,$51,$60,$67,$6D,$78
        .byte   $78,$7F,$86,$8D,$94,$9F,$AE,$BD,$C2,$C2,$C2,$C2,$CB,$D2,$D2,$D2
        .byte   $02,$41,$50,$5F,$6E,$83,$8A,$91,$9C,$A2,$A8,$AE,$B4,$B4,$B4,$B4
        .byte   $B4,$DE,$03,$13,$21,$32,$4F,$62,$71,$84,$90,$9C,$A2,$A8,$A8,$AE
        .byte   $B6,$C4,$CC,$CC,$CC,$CC,$CC,$E3,$F5,$FD,$05,$05,$29,$47,$5A,$68
        .byte   $68,$68,$68,$70,$7E,$91,$9A,$9A,$9A,$9A,$A1,$B4,$D3,$EE,$F6,$11
        .byte   $1D,$30,$67,$A3,$D6,$E1,$E7,$02,$5B,$90,$C1,$D0

; ---- bank7.tbl_C319 (pointer_table) $C319-$C3A5, 141 bytes
; Metasprite pointers, high bytes
        .byte   $DC,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4
        .byte   $C4,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5
        .byte   $C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C6,$C6,$C6,$C6,$C6,$C6
        .fill   16,$C6
        .fill   18,$C7
        .fill   24,$C8
        .fill   21,$C9
        .byte   $CA,$CA,$CA,$CA,$CA,$CA,$CA,$CA,$CB,$CB,$CB,$CB,$CB,$CB

; ---- bank7.sprite_C3A6 (graphics) $C3A6-$CBE7, 2114 bytes
; Metasprites: 115 records, 53 offset tables
        .byte   $E8,$F0,$F0,$F0,$F8,$F0,$00,$F0,$08,$F0,$10,$F0,$E8,$00,$F0,$00
        .byte   $F8,$00,$00,$00,$08,$00,$10,$00,$E8,$10,$F0,$10,$F8,$10,$00,$10
        .byte   $08,$10,$10,$10,$F0,$F0,$F8,$F0,$00,$F0,$08,$F0,$F0,$00,$F8,$00
        .byte   $00,$00,$08,$00,$F8,$F0,$00,$F0,$F8,$00,$00,$00,$F4,$F8,$FC,$F8
        .byte   $04,$F8,$F0,$E8,$F8,$E8,$00,$E8,$08,$E8,$F0,$F8,$F8,$F8,$00,$F8
        .byte   $08,$F8,$F0,$08,$F8,$08,$00,$08,$08,$08,$EC,$F8,$F4,$F8,$FC,$F8
        .byte   $04,$F8,$0C,$F8,$E8,$F8,$F0,$F8,$F8,$F8,$00,$F8,$08,$F8,$10,$F8
        .byte   $FC,$F0,$FC,$00,$F8,$D8,$00,$D8,$F8,$E8,$00,$E8,$F8,$F8,$00,$F8
        .byte   $F8,$08,$00,$08,$F8,$18,$00,$18,$F8,$F0,$00,$F0,$F0,$00,$F8,$00
        .byte   $00,$00,$08,$00,$F8,$F0,$FF,$F0,$F0,$00,$F8,$00,$FF,$00,$07,$00
        .byte   $06,$3A,$C4,$04,$04,$02,$06,$06,$02,$00,$40,$00,$00,$40,$40,$FA
        .byte   $F0,$02,$F0,$F2,$00,$FA,$00,$02,$00,$05,$55,$C4,$0A,$0E,$08,$0C
        .byte   $10,$08,$05,$55,$C4,$12,$16,$FF,$14,$18,$08,$04,$DA,$C3,$48,$4C
        .byte   $4A,$4E,$08,$F6,$F0,$FE,$F0,$F6,$00,$FE,$00,$06,$00,$05,$79,$C4
        .byte   $40,$44,$42,$46,$FF,$08,$05,$79,$C4,$36,$3A,$38,$3C,$3E,$08,$06
        .byte   $3A,$C4,$2C,$2C,$2A,$2E,$2E,$2A,$00,$40,$00,$00,$40,$40,$F8,$F7
        .byte   $00,$F7,$F0,$07,$F8,$07,$00,$07,$08,$07,$06,$A4,$C4,$1C,$1C,$1A
        .byte   $1E,$1E,$1A,$00,$40,$00,$00,$40,$40,$02,$F2,$C3,$20,$20,$00,$40
        .byte   $02,$F2,$C3,$22,$22,$00,$40,$01,$E4,$C3,$24,$08,$01,$E4,$C3,$26
        .byte   $08,$01,$E4,$C3,$28,$08,$F2,$F0,$FA,$F0,$02,$F0,$FA,$00,$02,$00
        .byte   $05,$DC,$C4,$50,$52,$56,$54,$58,$08,$05,$DC,$C4,$5A,$5C,$60,$5E
        .byte   $62,$08,$04,$DA,$C3,$64,$68,$66,$6A,$08,$04,$DA,$C3,$6C,$70,$6E
        .byte   $72,$08,$F8,$F0,$00,$F0,$08,$F0,$F8,$00,$00,$00,$05,$08,$C5,$74
        .byte   $78,$7C,$76,$7A,$08,$04,$DA,$C3,$7E,$82,$80,$84,$08,$04,$DA,$C3
        .byte   $86,$8A,$88,$8C,$08,$04,$DA,$C3,$8E,$6C,$90,$92,$00,$40,$00,$00
        .byte   $04,$DA,$C3,$64,$68,$94,$96,$08,$EC,$F8,$0C,$F8,$02,$3E,$C5,$74
        .byte   $74,$08,$FC,$E8,$FC,$08,$02,$48,$C5,$74,$74,$08,$02,$F2,$C3,$00
        .byte   $02,$08,$02,$F2,$C3,$00,$00,$00,$40,$02,$F2,$C3,$02,$04,$40,$00
        .byte   $02,$F2,$C3,$02,$02,$40,$00,$FC,$0B,$01,$6D,$C5,$00,$0A,$02,$16
        .byte   $C4,$00,$02,$08,$08,$CA,$C3,$00,$02,$04,$00,$06,$08,$0A,$0C,$00
        .byte   $00,$00,$40,$00,$00,$00,$00,$08,$CA,$C3,$00,$02,$04,$00,$0C,$0A
        .byte   $08,$06,$00,$00,$00,$40,$40,$40,$40,$40,$08,$CA,$C3,$00,$02,$02
        .byte   $00,$00,$02,$02,$00,$00,$00,$40,$40,$80,$80,$C0,$C0,$F8,$F8,$F0
        .byte   $00,$E8,$10,$03,$B3,$C5,$34,$34,$2E,$08,$F8,$00,$F0,$10,$F8,$10
        .byte   $03,$C0,$C5,$2C,$32,$30,$00,$40,$40,$F8,$00,$F8,$10,$02,$CF,$C5
        .byte   $36,$2E,$08,$01,$E4,$C3,$74,$08,$02,$F2,$C3,$74,$74,$08,$FC,$F4
        .byte   $FC,$FC,$02,$E4,$C5,$74,$74,$08,$F4,$F8,$04,$F8,$02,$EE,$C5,$74
        .byte   $74,$08,$FC,$F0,$FC,$00,$02,$F8,$C5,$74,$74,$08,$F4,$B0,$F4,$C0
        .byte   $FC,$C0,$F4,$D0,$FC,$D0,$04,$D0,$F4,$E0,$FC,$E0,$04,$E0,$F4,$F0
        .byte   $FC,$F0,$04,$F0,$0C,$F0,$14,$F0,$1C,$F0,$EC,$00,$F4,$00,$FC,$00
        .byte   $04,$00,$0C,$00,$14,$00,$1C,$00,$F4,$10,$FC,$10,$04,$10,$19,$02
        .byte   $C6,$00,$02,$04,$06,$08,$0A,$38,$3A,$3C,$0C,$0E,$10,$12,$14,$16
        .byte   $18,$1A,$1C,$1E,$20,$22,$24,$26,$28,$2A,$08,$04,$DA,$C3,$00,$02
        .byte   $06,$04,$00,$00,$40,$40,$FC,$F0,$FC,$00,$02,$5C,$C6,$76,$76,$00
        .byte   $80,$02,$F2,$C3,$76,$78,$08,$04,$F0,$C3,$76,$78,$78,$76,$00,$00
        .byte   $40,$40,$02,$F2,$C3,$68,$68,$00,$C0,$02,$F2,$C3,$6A,$6A,$00,$C0
        .byte   $02,$F2,$C3,$6C,$6C,$00,$C0,$02,$F2,$C3,$6E,$6E,$00,$C0,$04,$D2
        .byte   $C3,$00,$02,$02,$00,$00,$00,$40,$40,$06,$2E,$C4,$12,$12,$0C,$0E
        .byte   $0E,$0C,$00,$40,$00,$00,$40,$40,$06,$2E,$C4,$10,$10,$08,$0A,$0A
        .byte   $08,$00,$40,$00,$00,$40,$40,$01,$E4,$C3,$00,$08,$03,$E2,$C3,$04
        .byte   $02,$00,$40,$00,$40,$03,$E2,$C3,$00,$02,$04,$08,$F0,$D0,$F8,$D0
        .byte   $00,$D0,$08,$D0,$E0,$F0,$E8,$F0,$10,$F0,$18,$F0,$E0,$00,$18,$00
        .byte   $E0,$10,$E8,$10,$F0,$10,$F8,$10,$00,$10,$08,$10,$10,$10,$18,$10
        .byte   $E8,$20,$F0,$20,$F8,$20,$00,$20,$08,$20,$10,$20,$18,$D2,$C6,$00
        .byte   $02,$02,$00,$0A,$0C,$0C,$0A,$12,$12,$1A,$4C,$4E,$20,$20,$1E,$1C
        .byte   $1A,$50,$52,$54,$26,$24,$22,$00,$00,$40,$40,$00,$00,$40,$40,$00
        .byte   $40,$00,$00,$00,$00,$40,$40,$40,$40,$00,$00,$00,$40,$40,$40,$F8
        .byte   $E0,$00,$E0,$F0,$F0,$F8,$F0,$00,$F0,$08,$F0,$06,$35,$C7,$08,$08
        .byte   $0E,$10,$10,$0E,$00,$40,$00,$00,$40,$40,$06,$35,$C7,$2C,$2C,$2E
        .byte   $30,$30,$2E,$00,$40,$00,$00,$40,$40,$06,$35,$C7,$36,$36,$38,$3A
        .byte   $3A,$38,$00,$40,$00,$00,$40,$40,$06,$35,$C7,$46,$46,$48,$4A,$4A
        .byte   $48,$00,$40,$00,$00,$40,$40,$E8,$00,$F0,$00,$F8,$00,$03,$7D,$C7
        .byte   $14,$16,$18,$08,$03,$7D,$C7,$32,$34,$18,$08,$03,$7D,$C7,$40,$42
        .byte   $44,$08,$E8,$E0,$F0,$E0,$02,$98,$C7,$04,$06,$08,$02,$98,$C7,$28
        .byte   $2A,$08,$02,$98,$C7,$3C,$3E,$08,$02,$F2,$C3,$06,$04,$08,$04,$DA
        .byte   $C3,$00,$02,$04,$06,$08,$E8,$D8,$F0,$D8,$F8,$D8,$E0,$E8,$E8,$E8
        .byte   $F0,$E8,$F8,$E8,$E0,$F8,$E8,$F8,$F0,$F8,$F8,$F8,$E0,$08,$E8,$08
        .byte   $F0,$08,$F8,$08,$F0,$18,$F8,$18,$91,$BC,$C7,$00,$02,$04,$06,$08
        .byte   $0A,$0C,$0E,$10,$12,$14,$16,$18,$1A,$1C,$20,$22,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$0C,$E8,$C3
        .byte   $24,$26,$28,$FF,$2A,$2C,$2E,$FF,$30,$32,$FF,$FF,$08,$FC,$E8,$EC
        .byte   $F8,$F4,$F8,$FC,$F8,$04,$F8,$0C,$F8,$FC,$08,$07,$13,$C8,$04,$00
        .byte   $02,$06,$02,$00,$08,$00,$00,$00,$00,$40,$40,$00,$05,$00,$C4,$16
        .byte   $18,$14,$18,$16,$00,$00,$00,$40,$40,$F8,$F0,$00,$F0,$E8,$F8,$F0
        .byte   $F8,$08,$F8,$10,$F8,$F8,$00,$00,$00,$08,$3F,$C8,$04,$04,$00,$02
        .byte   $02,$00,$06,$06,$00,$40,$00,$00,$40,$40,$00,$40,$06,$0A,$C4,$08
        .byte   $0A,$0C,$0C,$0A,$08,$00,$00,$00,$40,$40,$40,$08,$3F,$C8,$12,$12
        .byte   $0E,$10,$10,$0E,$14,$14,$00,$40,$00,$00,$40,$40,$00,$40,$08,$CA
        .byte   $C3,$02,$04,$06,$08,$00,$0C,$0E,$10,$08,$08,$CA,$C3,$02,$04,$06
        .byte   $12,$0A,$0C,$0E,$14,$08,$02,$16,$C4,$16,$18,$08,$02,$16,$C4,$16
        .byte   $1A,$08,$02,$16,$C4,$00,$02,$08,$04,$DA,$C3,$04,$06,$08,$0A,$08
        .byte   $0A,$1A,$C4,$00,$FF,$02,$04,$06,$08,$0A,$0C,$0E,$10,$08,$04,$F0
        .byte   $C3,$00,$02,$04,$06,$08,$04,$F0,$C3,$02,$04,$04,$02,$00,$00,$40
        .byte   $40,$F0,$D8,$F8,$D8,$F0,$E8,$F8,$E8,$00,$E8,$08,$E8,$06,$D7,$C8
        .byte   $00,$02,$04,$06,$08,$0A,$08,$F0,$E8,$F8,$E8,$00,$E8,$08,$E8,$04
        .byte   $ED,$C8,$0C,$0E,$10,$12,$08,$04,$F0,$C3,$14,$16,$18,$1A,$08,$0C
        .byte   $E8,$C3,$FF,$02,$00,$FF,$0A,$08,$06,$04,$12,$10,$0E,$0C,$08,$F8
        .byte   $E0,$00,$E0,$F8,$F0,$00,$F0,$F0,$00,$F8,$00,$00,$00,$08,$00,$F0
        .byte   $10,$08,$10,$0A,$15,$C9,$00,$02,$04,$06,$0C,$08,$0A,$10,$0E,$12
        .byte   $08,$E0,$F0,$E8,$F0,$F0,$F0,$F8,$F0,$E0,$00,$E8,$00,$F0,$00,$F8
        .byte   $00,$88,$37,$C9,$02,$04,$06,$08,$0A,$0C,$0E,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$02,$0A,$1A,$C4,$10,$12,$14,$16,$18,$1A,$FF,$1C,$FF
        .byte   $FF,$08,$F4,$F8,$FC,$F8,$04,$F8,$FC,$08,$04,$68,$C9,$0E,$10,$12
        .byte   $0C,$08,$F8,$F8,$00,$F8,$FC,$08,$03,$78,$C9,$02,$02,$00,$00,$40
        .byte   $00,$F0,$F8,$F8,$F8,$00,$F8,$08,$F8,$FC,$08,$05,$87,$C9,$04,$06
        .byte   $08,$0A,$0C,$08,$02,$F2,$C3,$00,$00,$00,$C0,$08,$CA,$C3,$00,$02
        .byte   $02,$00,$04,$06,$06,$04,$00,$00,$40,$40,$00,$00,$40,$40,$02,$F2
        .byte   $C3,$00,$00,$40,$00,$E8,$D8,$F0,$D8,$F8,$D8,$E0,$E8,$E8,$E8,$F0
        .byte   $E8,$F8,$E8,$E0,$F8,$E8,$F8,$E8,$08,$F0,$08,$F8,$08,$8C,$BB,$C9
        .byte   $04,$02,$00,$0C,$0A,$08,$06,$0C,$0A,$04,$02,$00,$40,$40,$40,$40
        .byte   $40,$40,$40,$C0,$C0,$C0,$C0,$C0,$04,$F0,$C3,$1C,$1E,$20,$22,$08
        .byte   $04,$F0,$C3,$00,$02,$02,$00,$00,$00,$40,$40,$F8,$C8,$F8,$D8,$F0
        .byte   $E8,$F8,$E8,$F0,$F8,$F8,$F8,$F0,$08,$F8,$08,$88,$01,$CA,$00,$02
        .byte   $00,$04,$02,$06,$08,$0A,$08,$08,$CA,$C3,$00,$02,$02,$00,$04,$06
        .byte   $06,$04,$00,$00,$40,$40,$00,$00,$40,$40,$0C,$A6,$C3,$0C,$0E,$10
        .byte   $10,$0E,$0C,$12,$14,$FF,$FF,$14,$12,$00,$00,$00,$40,$40,$40,$00
        .byte   $00,$00,$00,$40,$40,$F0,$D0,$F8,$D0,$E8,$E0,$F0,$E0,$F8,$E0,$E0
        .byte   $F0,$E8,$F0,$F0,$F0,$F8,$F0,$E8,$00,$F0,$00,$F8,$00,$F0,$10,$F8
        .byte   $10,$8E,$4B,$CA,$00,$02,$04,$06,$08,$0A,$0C,$0E,$10,$12,$14,$16
        .byte   $18,$1A,$08,$F8,$B8,$00,$B8,$08,$B8,$F0,$C8,$F8,$C8,$00,$C8,$08
        .byte   $C8,$F0,$D8,$F8,$D8,$00,$D8,$08,$D8,$E8,$F0,$F0,$E8,$F8,$E8,$00
        .byte   $E8,$08,$E8,$10,$F0,$E8,$F8,$F0,$F8,$08,$F8,$10,$F8,$15,$79,$CA
        .byte   $00,$02,$04,$06,$08,$0A,$0C,$0E,$10,$12,$14,$1A,$18,$16,$16,$18
        .byte   $1A,$1E,$1C,$1C,$1E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .byte   $40,$40,$40,$00,$00,$00,$40,$40,$00,$00,$E0,$D0,$E0,$E0,$E8,$E0
        .byte   $03,$D0,$CA,$2C,$2E,$30,$08,$E8,$D0,$E8,$E0,$02,$DD,$CA,$32,$34
        .byte   $48,$0C,$A6,$C3,$24,$22,$20,$20,$22,$24,$2A,$28,$26,$26,$28,$2A
        .byte   $40,$40,$40,$00,$00,$00,$40,$40,$40,$00,$00,$00,$12,$A6,$C3,$3E
        .byte   $22,$20,$20,$22,$3E,$40,$3C,$3C,$3C,$3C,$40,$2A,$44,$42,$42,$44
        .byte   $2A,$40,$40,$40,$00,$00,$00,$40,$00,$00,$00,$00,$00,$40,$40,$40
        .byte   $00,$00,$00,$F8,$88,$F8,$98,$00,$98,$F8,$A8,$00,$A8,$E8,$B8,$F0
        .byte   $B8,$F8,$B8,$00,$B8,$08,$B8,$10,$B8,$E8,$C8,$F0,$C8,$F8,$C8,$00
        .byte   $C8,$08,$C8,$10,$C8,$E8,$D8,$F0,$D8,$F8,$D8,$00,$D8,$08,$D8,$10
        .byte   $D8,$E8,$E8,$10,$E8,$19,$29,$CB,$00,$02,$04,$06,$08,$0A,$0C,$0E
        .byte   $10,$0C,$0A,$12,$14,$16,$16,$14,$12,$18,$1A,$1C,$1C,$1A,$18,$1E
        .byte   $1E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$40,$00,$00,$00,$40
        .byte   $40,$40,$00,$00,$00,$40,$40,$40,$00,$40,$0C,$E8,$C3,$20,$22,$22
        .byte   $20,$24,$26,$26,$24,$28,$2A,$2A,$28,$00,$00,$40,$40,$00,$00,$40
        .byte   $40,$00,$00,$40,$40,$F0,$E8,$F8,$E8,$00,$E8,$08,$E8,$E8,$F8,$F0
        .byte   $F8,$F8,$F8,$00,$F8,$E8,$08,$F0,$08,$F8,$08,$0B,$AB,$CB,$2C,$2E
        .byte   $30,$32,$34,$36,$38,$3A,$3C,$3E,$40,$08,$08,$CA,$C3,$00,$04,$06
        .byte   $FF,$02,$FF,$FF,$FF,$08,$08,$CA,$C3,$00,$02,$04,$06,$08,$0A,$0C
        .byte   $0E,$08

; ---- bank7.code_CBE8 (code) $CBE8-$CF2A, 835 bytes
L7_CBE8:
        lda     $0620,X
        and     #$01
        beq     L7_CBF2
        jsr     L7_CC88
L7_CBF2:
        lda     $0620,X
        and     #$02
        beq     L7_CBFC
        jsr     L7_CCEB
L7_CBFC:
        lda     $0518,X
        sta     $84
        lda     $0530,X
        sta     $85
        lda     $06C8,X
        sta     $87
        lda     $0560,X
        tay
        lda     $0620,X
        and     #$04
        beq     L7_CC1F
        lda     $05D8,X
        bmi     L7_CC1F
        tya
        eor     #$80
        tay
L7_CC1F:
        lda     $0620,X
        and     #$08
        beq     L7_CC2F
        lda     $0608,X
        bmi     L7_CC2F
        tya
        eor     #$40
        tay
L7_CC2F:
        sty     $86
        lda     $0548,X
L7_CC34:
        tay
        beq     L7_CC44
        lda     $C28D,Y
        sta     $88
        lda     $C319,Y
        sta     $89
        jsr     L7_CC46
L7_CC44:
        clc
        rts
L7_CC46:
        ldy     #$00
        lda     ($88),Y
        beq     L7_CC87
        bpl     L7_CC67
        and     #$7F
        pha
        lda     $86
        eor     #$40
        sta     $86
        pla
        jsr     L7_CC67
        lda     $86
        eor     #$40
        sta     $86
        ldy     #$00
        lda     ($88),Y
        and     #$7F
L7_CC67:
        sta     $8F
        iny
        lda     ($88),Y
        sta     $8A
        iny
        lda     ($88),Y
        sta     $8B
        iny
        sty     $8D
        tya
        clc
        adc     $8F
        sta     $8E
        lda     #$00
        sta     $8C
L7_CC80:
        jsr     L7_CDD7
        dec     $8F
        bne     L7_CC80
L7_CC87:
        rts
L7_CC88:
        lda     $05C0,X
        clc
        adc     $0758,X
        sta     $0758,X
        lda     $05D8,X
        bmi     L7_CCA7
        adc     $0518,X
        sta     $0518,X
        bcs     L7_CCA4
        cmp     #$D0
        bcs     L7_CCB0
        rts
L7_CCA4:
        jmp     L7_CCB0
L7_CCA7:
        adc     $0518,X
        sta     $0518,X
        bcc     L7_CCB0
        rts
L7_CCB0:
        lda     $0620,X
        and     #$10
        bne     L7_CCBB
        pla
        pla
        sec
        rts
L7_CCBB:
        pla
        pla
        pla
        pla
L7_CCBF:
        lda     $0500,X
        and     #$7F
        sta     $0740,X
        lda     #$00
        sta     $0500,X
        sta     $0518,X
        sta     $0758,X
        sta     $0770,X
        sta     $05C0,X
        sta     $05F0,X
        sta     $05D8,X
        sta     $0608,X
        sta     $06C8,X
        sta     $06B0,X
        sta     $0728,X
        rts
L7_CCEB:
        lda     $05F0,X
        clc
        adc     $0770,X
        sta     $0770,X
        lda     $0608,X
        bmi     L7_CD06
        adc     $0530,X
        sta     $0530,X
        bcs     L7_CD03
        rts
L7_CD03:
        jmp     L7_CCB0
L7_CD06:
        adc     $0530,X
        sta     $0530,X
        bcc     L7_CD0F
L7_CD0E:
        rts
L7_CD0F:
        jmp     L7_CCB0
L7_CD12:
        ldy     #$00
        sty     $11
        sta     $10
        lda     $0518,X
        cmp     $0668,X
        beq     L7_CD0E
        bcs     L7_CD34
        lda     $05C0,X
        clc
        adc     $10
        sta     $05C0,X
        lda     $05D8,X
        adc     $11
        sta     $05D8,X
        rts
L7_CD34:
        lda     $05C0,X
        sec
        sbc     $10
        sta     $05C0,X
        lda     $05D8,X
        sbc     $11
        sta     $05D8,X
        rts
L7_CD46:
        ldy     #$00
        sty     $11
        sta     $10
        lda     $0530,X
        cmp     $0680,X
        beq     L7_CD0E
        bcs     L7_CD68
        lda     $05F0,X
        clc
        adc     $10
        sta     $05F0,X
        lda     $0608,X
        adc     $11
        sta     $0608,X
        rts
L7_CD68:
        lda     $05F0,X
        sec
        sbc     $10
        sta     $05F0,X
        lda     $0608,X
        sbc     $11
        sta     $0608,X
        rts
L7_CD7A:
        clc
        adc     $0650,X
        sta     $0650,X
        bcc     L7_CD94
        inc     $0638,X
        sty     $10
        lda     $0638,X
        cmp     $10
        bcc     L7_CD94
        lda     #$00
        sta     $0638,X
L7_CD94:
        lda     $0638,X
        tay
        rts
L7_CD99:
        lda     #$00
        sta     $0638,X
        sta     $0650,X
        rts
L7_CDA2:
        jsr     L7_D534
        lda     $83
        and     #$FE
        sta     $83
        lda     #$04
        sta     $82
        lda     #$FC
        sta     $81
        rts
L7_CDB4:
        lda     $83
        and     #$7D
        sta     $83
        and     #$01
        bne     L7_CDC3
        lda     #$04
        sta     $80
        rts
L7_CDC3:
        lda     $82
        cmp     #$04
        bne     L7_CDD1
        lda     $83
        ora     #$80
        sta     $83
        lda     #$00
L7_CDD1:
        sec
        sbc     #$04
        sta     $80
        rts
L7_CDD7:
        lda     $83
        and     #$02
        bne     L7_CE1B
        stx     $38
        ldx     $80
        lda     #$F8
        sta     $0200,X
        ldy     $8E
        lda     ($88),Y
        sta     $91
        lda     $86
        and     #$E3
        eor     $91
        sta     $0202,X
        ldy     $8D
        lda     ($88),Y
        cmp     #$FF
        beq     L7_CE19
        adc     $87
        sta     $0201,X
        bit     $86
        ldy     $8C
        lda     ($8A),Y
        bvc     L7_CE0F
        eor     #$FF
        sec
        sbc     #$07
L7_CE0F:
        clc
        bmi     L7_CE2A
        adc     $85
        sta     $0203,X
        bcc     L7_CE31
L7_CE19:
        ldx     $38
L7_CE1B:
        inc     $8C
        inc     $8C
        inc     $8D
        lda     $91
        and     #$08
        bne     L7_CE29
        inc     $8E
L7_CE29:
        rts
L7_CE2A:
        adc     $85
        sta     $0203,X
        bcc     L7_CE19
L7_CE31:
        iny
        lda     $86
        asl     A
        lda     ($8A),Y
        bcc     L7_CE3E
        eor     #$FF
        sbc     #$0F
        clc
L7_CE3E:
        bmi     L7_CE46
        adc     $84
        bcc     L7_CE4A
        bcs     L7_CE19
L7_CE46:
        adc     $84
        bcc     L7_CE19
L7_CE4A:
        sta     $0200,X
        inc     $8C
        inc     $8C
        inc     $8D
        lda     $91
        and     #$08
        bne     L7_CE5B
        inc     $8E
L7_CE5B:
        lda     $83
        and     #$01
        bne     L7_CE71
        txa
        clc
        adc     #$04
        sta     $80
        bne     L7_CE85
        lda     $83
        ora     #$82
        sta     $83
        bne     L7_CE85
L7_CE71:
        txa
        sec
        sbc     #$04
        sta     $80
        cmp     #$04
        bcs     L7_CE85
        lda     $83
        ora     #$80
        sta     $83
        lda     #$FC
        sta     $80
L7_CE85:
        ldx     $38
        rts
L7_CE88:
        lda     $83
        and     #$01
        bne     L7_CEDC
        ldx     $80
        lda     $83
        bpl     L7_CE99
        lda     #$00
        jmp     L7_CEC5
L7_CE99:
        lda     $82
        beq     L7_CEB8
        lda     #$F8
L7_CE9F:
        cpx     $82
        bcs     L7_CEAC
        sta     $0200,X
        inx
        inx
        inx
        inx
        bne     L7_CE9F
L7_CEAC:
        cpx     $81
        bcs     L7_CEB2
        ldx     $81
L7_CEB2:
        lda     $81
        cmp     #$FC
        beq     L7_CEC3
L7_CEB8:
        lda     #$F8
L7_CEBA:
        sta     $0200,X
        inx
        inx
        inx
        inx
        bne     L7_CEBA
L7_CEC3:
        lda     $80
L7_CEC5:
        sta     $82
        lda     $83
        and     #$84
        beq     L7_CEFE
        cmp     #$04
        bne     L7_CEFE
        lda     $26
        and     #$20
        bne     L7_CEFE
        lda     #$FC
        sta     $81
        rts
L7_CEDC:
        lda     $83
        and     #$80
        beq     L7_CEE9
        lda     $80
        sta     $81
        jmp     L7_CEFE
L7_CEE9:
        ldx     #$04
        lda     #$F8
L7_CEED:
        sta     $0200,X
        cpx     $80
        beq     L7_CEFA
        inx
        inx
        inx
        inx
        bne     L7_CEED
L7_CEFA:
        lda     #$FC
        sta     $81
L7_CEFE:
        lda     $83
        eor     #$01
        sta     $83
L7_CF04:
        rts
L7_CF05:
        lda     $83
        and     #$02
        bne     L7_CF04
        stx     $38
        ldx     $80
        lda     #$F8
        sta     $0200,X
        lda     $87
        sta     $0201,X
        lda     $86
        sta     $0202,X
        lda     $85
        sta     $0203,X
        lda     $84
        sta     $0200,X
        jmp     L7_CE5B

; ---- bank7.code_CF2B (code) $CF2B-$CF4B, 33 bytes
        lda     $83
        and     #$02
        bne     $CF04
        stx     $38
        ldx     $80
        lda     $84
        sta     $0200,X
        lda     $85
        sta     $0203,X
        lda     $87
        sta     $0201,X
        lda     $86
        sta     $0202,X
        jmp     $CE5B

; ---- bank7.code_CF4C (code) $CF4C-$CFC3, 120 bytes
L7_CF4C:
        and     #$7F
        tay
        cmp     #$0E
        bcc     L7_CF5C
        lda     $CFB6,Y
        bpl     L7_CF5B
        lda     $07B8,X
L7_CF5B:
        rts
L7_CF5C:
        lda     #$00
        rts
L7_CF5F:
        lda     $0500,X
        and     #$7F
        tay
        lda     $CFB6,Y
L7_CF68:
        stx     $10
        ldx     #$00
L7_CF6C:
        cmp     $0480,X
        beq     L7_CF8D
        inx
        cpx     #$10
        bne     L7_CF6C
        ldx     $10
        dec     $0758,X
        bne     L7_CF8A
        dec     $0770,X
        lda     $0770,X
        cmp     #$FD
        bne     L7_CF8A
        jsr     L7_CCBF
L7_CF8A:
        pla
        pla
        rts
L7_CF8D:
        lda     #$00
        sta     $0770,X
        sta     $0758,X
        lda     $0490,X
        ldx     $10
        sta     $06C8,X
        sta     $07E8,X
L7_CFA0:
        lda     $0500,X
        ora     #$80
        sta     $0500,X
        and     #$7F
        tay
        lda     $D02C,Y
        sta     $0578,X
        lda     $D0AB,Y
        sta     $0590,X
        lda     $D12A,Y
        sta     $05A8,X
        lda     $D1A9,Y
        sta     $0620,X
        rts

; ---- bank7.tbl_CFC4 (data) $CFC4-$D02B, 104 bytes
; The tile block holding each type's art
        .byte   $14,$13,$16,$16,$16,$16,$1B,$1B,$3A,$3A,$42,$42,$3C,$37,$37,$12
        .byte   $12,$12,$3B,$3D,$00,$41,$2A,$2A,$2A,$FF,$00,$00,$FF,$00,$FF,$40
        .byte   $40,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$43,$43,$20,$1F,$21,$49,$44,$34,$1C,$1C,$00,$00,$2A,$2A
        .byte   $04,$45,$15,$15,$17,$3E,$3E,$26,$26,$26,$1A,$1E,$29,$29,$29,$05
        .byte   $00,$4B,$1E,$27,$3D,$25,$22,$48,$2E,$2E,$28,$32,$3F,$33,$38,$2B
        .byte   $2D,$23,$30,$24,$06,$19,$1D,$4C

; ---- bank7.tbl_D02C (data) $D02C-$D0AA, 127 bytes
; Enemy collision flags, by type
        .byte   $4A,$14,$30,$30,$80,$80,$CA,$C0,$80,$CA,$C8,$04,$04,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00,$5A,$5A,$00,$00,$00,$50,$50,$50
        .byte   $00,$00,$4E,$5A,$5A,$5A,$5A,$00,$C0,$DA,$04,$00,$00,$5A,$5A,$5A
        .byte   $C0,$6A,$6A,$6A,$CA,$6A,$62,$72,$6A,$5A,$5A,$6A,$6A,$7A,$52,$7A
        .byte   $5A,$5A,$10,$10,$00,$5A,$5A,$5A,$5A,$5A,$7A,$7A,$5A,$5A,$00,$5A
        .byte   $00,$00,$00,$50,$50,$50,$50,$50,$50,$10,$50,$50,$50,$50,$50,$00
        .byte   $10,$10,$00,$00,$10,$40,$10,$10,$10,$00,$50,$00,$00,$00,$50,$40
        .byte   $50,$10,$00,$10,$00,$62,$72,$00,$00,$00,$C2,$CA,$7A,$7A,$7A

; ---- bank7.tbl_D0AB (data) $D0AB-$D129, 127 bytes
; Enemy hit points, by type
        .byte   $7A,$00,$01,$01,$00,$00,$00,$00,$00,$00,$00,$01,$01,$04,$04,$04
        .byte   $18,$20,$30,$50,$E0,$E0,$10,$10,$20,$30,$08,$FF,$01,$01,$03,$06
        .byte   $80,$08,$80,$0E,$0C,$10,$14,$00,$00,$00,$04,$01,$10,$0A,$10,$14
        .byte   $00,$04,$04,$00,$00,$00,$04,$08,$80,$20,$10,$06,$08,$40,$10,$0A
        .byte   $05,$08,$08,$14,$04,$09,$10,$06,$38,$58,$18,$18,$0C,$0F,$10,$88
        .byte   $18,$20,$28,$20,$30,$02,$04,$06,$06,$08,$04,$07,$10,$0D,$12,$0E
        .byte   $04,$0C,$01,$04,$08,$30,$04,$40,$10,$08,$18,$10,$01,$08,$30,$20
        .byte   $18,$20,$01,$40,$20,$08,$20,$01,$01,$01,$80,$01,$20,$20,$18

; ---- bank7.tbl_D12A (data) $D12A-$D1A8, 127 bytes
; Enemy attack, by type
        .byte   $18,$02,$01,$01,$00,$00,$00,$00,$00,$00,$00,$20,$20,$18,$08,$0A
        .byte   $20,$40,$58,$80,$08,$08,$60,$60,$60,$70,$08,$18,$10,$10,$30,$50
        .byte   $20,$18,$00,$30,$10,$24,$50,$00,$00,$00,$10,$20,$10,$30,$40,$60
        .byte   $00,$01,$01,$01,$00,$01,$20,$20,$01,$40,$20,$01,$01,$80,$10,$00
        .byte   $08,$10,$10,$30,$20,$0C,$10,$30,$40,$60,$20,$20,$20,$30,$18,$20
        .byte   $10,$18,$0C,$18,$20,$30,$40,$60,$20,$10,$18,$28,$38,$30,$40,$18
        .byte   $08,$10,$04,$03,$05,$20,$10,$08,$08,$40,$10,$20,$01,$04,$10,$10
        .byte   $18,$10,$20,$18,$18,$08,$18,$01,$01,$01,$FF,$01,$01,$01,$20

; ---- bank7.tbl_D1A9 (data) $D1A9-$D228, 128 bytes
; Per-type value copied to $0620
        .byte   $20,$03,$13,$13,$00,$00,$00,$00,$00,$00,$00,$13,$13,$13,$03,$03
        .byte   $03,$03,$03,$03,$02,$01,$1B,$1B,$03,$03,$13,$13,$13,$03,$03,$03
        .byte   $13,$13,$00,$03,$00,$00,$00,$13,$00,$00,$13,$13,$1F,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00,$10,$13,$1B,$00,$00,$00,$1B,$00
        .byte   $01,$01,$1B,$13,$1B,$0B,$00,$03,$03,$03,$00,$00,$00,$00,$13,$03
        .byte   $03,$03,$03,$03,$03,$00,$00,$00,$00,$13,$03,$03,$03,$03,$0B,$13
        .byte   $13,$1B,$13,$13,$13,$03,$1B,$11,$1B,$13,$11,$11,$13,$13,$17,$13
        .byte   $03,$03,$03,$03,$03,$13,$11,$00,$00,$00,$00,$00,$00,$00,$00,$00

; ---- bank7.code_D229 (code) $D229-$D265, 61 bytes
L7_D229:
        lda     $0548,X
L7_D22C:
        tay
        lda     $0518,X
L7_D230:
        clc
        adc     $C201,Y
        bcc     L7_D238
        lda     #$FF
L7_D238:
        sta     $0728,X
        lda     $0518,X
        sec
        sbc     $C201,Y
        bcs     L7_D246
        lda     #$00
L7_D246:
        sta     $0710,X
        lda     $0530,X
        clc
        adc     $C174,Y
        bcc     L7_D254
        lda     #$FF
L7_D254:
        sta     $06F8,X
        lda     $0530,X
        sec
        sbc     $C174,Y
        bcs     L7_D262
        lda     #$00
L7_D262:
        sta     $06E0,X
        rts

; ---- bank7.code_D266 (code) $D266-$D275, 16 bytes
L7_D266:
        pha
        lda     $0548,X
        tay
        pla
        adc     $0518,X
        bcs     L7_D273
        lda     #$00
L7_D273:
        jmp     L7_D230

; ---- bank7.code_D276 (code) $D276-$D278, 3 bytes
L7_D276:
        jsr     L7_D229

; ---- bank7.code_D279 (code) $D279-$D280, 8 bytes
L7_D279:
        lda     #$04
        jsr     L7_D348
        bcs     L7_D2AA
        rts

; ---- bank7.code_D281 (code) $D281-$D293, 19 bytes
L7_D281:
        jsr     L7_D229
        ldy     #$00
        lda     $0500
        cmp     #$81
        bne     L7_D292
        jsr     L7_D364
        bcs     L7_D2AA
L7_D292:
        clc
        rts

; ---- bank7.code_D294 (code) $D294-$D296, 3 bytes
L7_D294:
        jsr     L7_D229

; ---- bank7.code_D297 (code) $D297-$D29E, 8 bytes
L7_D297:
        lda     #$30
        jsr     L7_D348
        bcs     L7_D2AA
        rts

; ---- bank7.code_D29F (code) $D29F-$D2A9, 11 bytes
L7_D29F:
        jsr     L7_D229
        lda     #$20
        jsr     L7_D348
        bcs     L7_D2AA
        rts

; ---- bank7.code_D2AA (code) $D2AA-$D2BA, 17 bytes
L7_D2AA:
        sty     $6E
        lda     $0500,Y
        and     #$7F
        sta     $6D
        lda     $0500,X
        and     #$7F
        sta     $6C
        rts

; ---- bank7.code_D2BB (code) $D2BB-$D2C6, 12 bytes
L7_D2BB:
        bcc     L7_D32A
        lda     #$20
        jsr     L7_D852
        jmp     L7_D2C7
L7_D2C5:
        bcc     L7_D32A

; ---- bank7.code_D2C7 (code) $D2C7-$D2CA, 4 bytes
L7_D2C7:
        ldy     $6E
        bne     L7_D30E

; ---- bank7.code_D2CB (code) $D2CB-$D2D0, 6 bytes
        lda     $48
        cmp     $49
        bne     L7_D2FD

; ---- bank7.code_D2D1 (code) $D2D1-$D2DB, 11 bytes
        lda     $05A8,X
        beq     L7_D30A
        tay
        lda     #$38
        jsr     L7_D852

; ---- bank7.code_D2DC (code) $D2DC-$D2E7, 12 bytes
        lda     $0590
        jsr     L7_F9AE
        and     #$FF
        bne     L7_D2E8
        lda     #$01

; ---- bank7.code_D2E8 (code) $D2E8-$D2EE, 7 bytes
L7_D2E8:
        eor     #$FF
        sec
        adc     $48
        bcs     L7_D2FB

; ---- bank7.code_D2EF (code) $D2EF-$D2FA, 12 bytes
        lda     $49
        bne     L7_D2F9
        lda     $D442
        sta     $0500
L7_D2F9:
        lda     #$00

; ---- bank7.code_D2FB (code) $D2FB-$D2FC, 2 bytes
L7_D2FB:
        sta     $48

; ---- bank7.code_D2FD (code) $D2FD-$D309, 13 bytes
L7_D2FD:
        lda     $0578
        ora     #$C0
        sta     $0578
        lda     #$0F
        sta     $0788

; ---- bank7.code_D30A (code) $D30A-$D30D, 4 bytes
L7_D30A:
        ldy     #$00
        beq     L7_D31C

; ---- bank7.code_D30E (code) $D30E-$D31B, 14 bytes
L7_D30E:
        lda     $0590,Y
        sec
        sbc     $05A8,X
        bcs     L7_D319
        lda     #$00
L7_D319:
        sta     $0590,Y

; ---- bank7.code_D31C (code) $D31C-$D329, 14 bytes
L7_D31C:
        lda     $0590,X
        sec
        sbc     $05A8,Y
        bcs     L7_D327
        lda     #$00
L7_D327:
        sta     $0590,X

; ---- bank7.code_D32A (code) $D32A-$D33E, 21 bytes
L7_D32A:
        lda     $0590,X
        bne     L7_D33E
        lda     $0500,X
        and     #$7F
        sta     $0740,X
        tay
        lda     $D441,Y
        sta     $0500,X
L7_D33E:
        rts

; ---- bank7.code_D33F (code) $D33F-$D347, 9 bytes
L7_D33F:
        sta     $0180
        lda     #$03
        sta     $017F
        rts

; ---- bank7.code_D348 (code) $D348-$D363, 28 bytes
L7_D348:
        ldy     #$04
        sta     $6F
L7_D34C:
        lda     $0500,Y
        bpl     L7_D35F
        lda     $0578,Y
        bmi     L7_D35F
        and     $6F
        beq     L7_D35F
        jsr     L7_D364
        bcs     L7_D363
L7_D35F:
        dey
        bpl     L7_D34C
        clc
L7_D363:
        rts

; ---- bank7.code_D364 (code) $D364-$D384, 33 bytes
L7_D364:
        lda     $06F8,Y
        cmp     $06E0,X
        bcc     L7_D384
        lda     $06F8,X
        cmp     $06E0,Y
        bcc     L7_D384
        lda     $0728,Y
        cmp     $0710,X
        bcc     L7_D384
        lda     $0728,X
        cmp     $0710,Y
        bcc     L7_D384
L7_D384:
        rts

; ---- bank7.code_D385 (code) $D385-$D39A, 22 bytes
L7_D385:
        lda     #$00
        asl     $0590,X
        rol     A
        asl     $0590,X
        rol     A
        asl     $0590,X
        rol     A
        asl     $0590,X
        rol     A
        sta     $0740,X
        rts

; ---- bank7.code_D39B (code) $D39B-$D3A8, 14 bytes
L7_D39B:
        bcc     L7_D384
        ldy     $6E
        bne     L7_D3A9
        lda     $05A8
        pha
        lda     #$00
        beq     L7_D3C4

; ---- bank7.code_D3A9 (code) $D3A9-$D3B4, 12 bytes
L7_D3A9:
        cpy     $3B
        bcc     L7_D3B5
        beq     L7_D3B5
        lda     $41
        and     #$07
        bne     L7_D384

; ---- bank7.code_D3B5 (code) $D3B5-$D3C3, 15 bytes
L7_D3B5:
        lda     #$39
        jsr     L7_D852
        lda     $05A8,Y
        pha
        cmp     #$06
        bcc     L7_D3C4
        lda     #$05

; ---- bank7.code_D3C4 (code) $D3C4-$D3D4, 17 bytes
L7_D3C4:
        sta     $05A8,Y
        lda     $0740,X
        sta     $15
        jsr     L7_D2C7
        ldy     $6E
        pla
        sta     $05A8,Y

; ---- bank7.code_D3D5 (code) $D3D5-$D3EF, 27 bytes
        lda     $0590,X
        bne     L7_D3F0
        lda     $15
        beq     L7_D3F0
        dec     $15
        dec     $0590,X
        lda     $0740,X
        ora     #$80
        sta     $0500,X
        lda     $15
        sta     $0740,X

; ---- bank7.code_D3F0 (code) $D3F0-$D412, 35 bytes
L7_D3F0:
        ldy     $6E
        beq     L7_D41D
        cpy     $3B
        beq     L7_D413
        bcc     L7_D413
        lda     $3C
        cmp     #$09
        beq     L7_D41D
        lda     $06E0,Y
        adc     $06F8,Y
        ror     A
        sta     $15
        lda     $0710,Y
        adc     $0728,Y
        ror     A
        jmp     L7_D425

; ---- bank7.code_D413 (code) $D413-$D41C, 10 bytes
L7_D413:
        lda     #$19
        sta     $0578,Y
        lda     #$09
        sta     $0500,Y

; ---- bank7.code_D41D (code) $D41D-$D440, 36 bytes
L7_D41D:
        lda     $0530,Y
        sta     $15
        lda     $0518,Y
L7_D425:
        sta     $14
        jsr     L7_FA5B
        bcs     L7_D440
        lda     #$08
        sta     $0500,Y
        lda     $15
        sta     $0530,Y
        lda     $14
        sta     $0518,Y
        lda     #$00
        sta     $0740,Y
L7_D440:
        rts

; ---- bank7.tbl_D441 (data) $D441-$D4C0, 128 bytes
; What each type becomes at 0 HP
        .byte   $00,$04,$0A,$06,$00,$00,$00,$00,$00,$00,$00,$08,$08,$08,$08,$08
        .byte   $08,$08,$08,$08,$08,$08,$08,$08,$07,$07,$08,$08,$08,$08,$08,$08
        .byte   $08,$08,$08,$07,$07,$07,$07,$08,$00,$00,$08,$08,$08,$07,$07,$07
        .byte   $30,$B1,$B2,$00,$00,$00,$30,$30,$30,$08,$08,$30,$30,$07,$08,$08
        .byte   $07,$07,$08,$08,$08,$07,$07,$07,$07,$07,$30,$30,$07,$07,$08,$07
        .fill   38,$08
        .byte   $30,$08,$08,$08,$08,$08,$07,$30,$30,$30

; ---- bank7.code_D4C1 (code) $D4C1-$D69A, 474 bytes
L7_D4C1:
        jsr     L7_D4E3
        lda     $2002
L7_D4C7:
        lda     #$00
        sta     $A3
        lda     $FE
        and     #$E7
L7_D4CF:
        sta     $FE
        sta     $2001
        rts
L7_D4D5:
        lda     #$18
        sta     $A3
        lda     $FE
        ora     #$18
        sta     $FE
        sta     $2001
        rts
L7_D4E3:
        lda     $FF
        and     #$7F
L7_D4E7:
        sta     $FF
        sta     $2000
        rts
L7_D4ED:
        jsr     L7_D68B
        jsr     L7_D4D5
L7_D4F3:
        lda     $FF
        ora     #$80
        sta     $FF
        sta     $2000
        rts
L7_D4FD:
        lda     #$00
        sta     $A6
        sta     $A7
        sta     $A8
        sta     $A9
L7_D507:
        lda     $A8
        sta     $FD
        lda     $A6
        sta     $FC
        lda     $FF
        and     #$FC
        lsr     A
        ora     $A7
        asl     A
        ora     $A9
        and     #$03
        sta     $A2
        rts
L7_D51E:
        sta     $0200
        lda     #$FF
        sta     $0201
        lda     #$20
        sta     $0202
        lda     #$00
        sta     $0203
        ldx     #$04
        bne     L7_D536
L7_D534:
        ldx     #$00
L7_D536:
        lda     #$F8
L7_D538:
        sta     $0200,X
        inx
        bne     L7_D538
        rts
L7_D53F:
        pla
        sta     $16
        pla
        sta     $17
L7_D545:
        jsr     L7_D591
        bcc     L7_D550
        jsr     L7_D7C3
        jmp     L7_D545
L7_D550:
        pha
        jsr     L7_D6E0
        stx     $10
        tax
        pla
        sec
        sbc     #$03
        sta     $11
        lda     ($16),Y
        sta     $0100,X
        lda     $19
        sta     $0101,X
        lda     $18
        sta     $0102,X
        iny
        inx
        inx
        inx
        jsr     L7_D5AF
        jmp     L7_D58A
L7_D576:
        pla
        sta     $16
        pla
        sta     $17
L7_D57C:
        jsr     L7_D591
        bcc     L7_D587
        jsr     L7_D7C3
        jmp     L7_D57C
L7_D587:
        jsr     L7_D5A5
L7_D58A:
        lda     $17
        pha
        lda     $16
        pha
        rts
L7_D591:
        ldy     #$01
        lda     ($16),Y
        bpl     L7_D59F
        asl     A
        bpl     L7_D59E
        lda     #$09
        bne     L7_D5A2
L7_D59E:
        lsr     A
L7_D59F:
        clc
        adc     #$03
L7_D5A2:
        jmp     L7_D6C0
L7_D5A5:
        pha
        jsr     L7_D6E0
        stx     $10
        tax
        pla
        sta     $11
L7_D5AF:
        lda     ($16),Y
        sta     $0100,X
        iny
        inx
        dec     $11
        bne     L7_D5AF
        ldx     $10
        jsr     L7_D6F7
        dey
        tya
        adc     $16
        sta     $16
        lda     $17
        adc     #$00
        sta     $17
        rts
L7_D5CC:
        pla
        sta     $16
        pla
        sta     $17
        ldy     #$01
        lda     ($16),Y
        sta     $15
        iny
        lda     ($16),Y
        sta     $19
        iny
        lda     ($16),Y
        sta     $18
        iny
        lda     ($16),Y
        sta     $14
        jsr     L7_D5F8
        lda     $16
        clc
        adc     #$04
        sta     $16
        bcc     L7_D5F5
        inc     $17
L7_D5F5:
        jmp     L7_D58A
L7_D5F8:
        lda     $15
        clc
        and     #$7F
        adc     #$03
        jsr     L7_D6D3
        jsr     L7_D6E0
        tay
        lda     $15
        sta     $0100,Y
        and     #$7F
        sta     $10
        lda     $19
        sta     $0101,Y
        lda     $18
        sta     $0102,Y
        lda     $14
L7_D61B:
        sta     $0103,Y
        iny
        dec     $10
        bne     L7_D61B
        jmp     L7_D6F7
L7_D626:
        lda     #$01
        sta     $4016
        lda     #$00
        sta     $4016
        ldx     #$08
L7_D632:
        lda     $4016
        lsr     A
        rol     $F5
        lsr     A
        rol     $00
        lda     $4017
        lsr     A
        rol     $F6
        lsr     A
        rol     $01
        dex
        bne     L7_D632
        rts
L7_D648:
        pla
        jmp     L7_D64F
L7_D64C:
        jsr     L7_D626
L7_D64F:
        lda     $00
        sta     $02
        lda     $01
        sta     $03
        lda     $F5
        pha
        lda     $F6
        pha
        jsr     L7_D626
        pla
        cmp     $F6
        bne     L7_D648
        pla
        cmp     $F5
        bne     L7_D64F
        lda     $00
        cmp     $02
        bne     L7_D64F
        lda     $01
        cmp     $03
        bne     L7_D64F
        ldx     #$01
L7_D678:
        ldy     $F7,X
        lda     $F5,X
        ora     $00,X
        sta     $F7,X
        tya
        eor     $F7,X
        and     $F7,X
        sta     $F5,X
        dex
        bpl     L7_D678
        rts
L7_D68B:
        lda     $FF
        sta     $2000
        lda     $FD
        sta     $2005
        lda     $FC
        sta     $2005
        rts

; ---- bank7.code_D69B (code) $D69B-$D6AD, 19 bytes
        stx     $01
        ldx     #$00
        stx     $00
        sta     ($00,X)
        inc     $00
        bne     $D6A1
        inc     $01
        cpy     $01
        bcs     $D6A1
        rts

; ---- bank7.code_D6AE (code) $D6AE-$D841, 404 bytes
L7_D6AE:
        asl     A
        tay
L7_D6B0:
        pla
        sta     $00
        pla
        sta     $01
        iny
        iny
        lda     ($00),Y
        pha
        dey
        lda     ($00),Y
        pha
        rts
L7_D6C0:
        pha
        clc
        adc     $21
        cmp     #$51
        bcs     L7_D6D1
        cmp     #$31
        bcc     L7_D6D1
        lda     $A5
        bne     L7_D6D1
        clc
L7_D6D1:
        pla
L7_D6D2:
        rts
L7_D6D3:
        jsr     L7_D6C0
        bcc     L7_D6D2
        pha
        jsr     L7_D7C3
        pla
        jmp     L7_D6D3
L7_D6E0:
        sta     $25
        lda     $21
        pha
        lda     $20
        sta     $24
        lda     #$00
        sta     $20
        pla
        cmp     $21
        beq     L7_D6F6
        lda     #$00
        sta     $24
L7_D6F6:
        rts
L7_D6F7:
        lda     $25
        clc
        adc     $21
        sta     $21
        lda     $24
        adc     #$01
        sta     $20
        rts
L7_D705:
        sta     $04
        tya
        pha
        ldy     $04
        lda     $FFF2,Y
        sta     $FFF2,Y
        pla
        tay
        rts
L7_D714:
        pha
        lda     #$00
        sta     $04
        lda     $FFF2
        sta     $FFF2
        pla
        rts
L7_D721:
        pha
        lda     #$01
        sta     $04
        lda     $FFF3
        sta     $FFF3
        pla
        rts
L7_D72E:
        pha
        lda     #$02
        sta     $04
        lda     $FFF4
        sta     $FFF4
        pla
        rts
L7_D73B:
        pha
        lda     #$03
        sta     $04
        lda     $FFF5
        sta     $FFF5
        pla
        rts
L7_D748:
        pha
        lda     #$04
        sta     $04
        lda     $FFF6
        sta     $FFF6
        pla
        rts
L7_D755:
        pha
        lda     #$05
        sta     $04
        lda     $FFF7
        sta     $FFF7
        pla
        rts
L7_D762:
        pha
        lda     #$06
        sta     $04
        lda     $FFF8
        sta     $FFF8
        pla
        rts
L7_D76F:
        sta     $10
        sty     $11
        pla
        sta     $12
        clc
        adc     #$03
        tay
        pla
        sta     $13
        adc     #$00
        pha
        tya
        pha
        lda     $04
        pha
        jsr     L7_D790
        sta     $10
        sty     $11
        pla
        jmp     L7_D79C
L7_D790:
        ldy     #$03
        lda     ($12),Y
        pha
        dey
        lda     ($12),Y
        pha
        dey
        lda     ($12),Y
L7_D79C:
        sta     $04
        tay
        lda     $FFF2,Y
        sta     $FFF2,Y
        lda     $10
        ldy     $11
        rts
L7_D7AA:
        lda     $FF
        bpl     L7_D7C2
        sta     $2000
        lda     $2B
L7_D7B3:
        cmp     $2B
        beq     L7_D7B3
        lda     $FF
        pha
        and     #$7F
        sta     $FF
        sta     $2000
        pla
L7_D7C2:
        rts
L7_D7C3:
        txa
        pha
        tya
        pha
L7_D7C7:
        jsr     L7_DB52
        lda     $FE
        and     #$18
        bne     L7_D7EC
        jsr     L7_D7AA
        pha
        jsr     L7_DD54
        lda     #$05
L7_D7D9:
        pha
        jsr     L7_DB52
        jsr     L7_DD54
        pla
        sec
        sbc     #$01
        bne     L7_D7D9
        pla
        sta     $FF
        sta     $2000
L7_D7EC:
        lda     $0B
        ora     $A5
        ora     $20
        bne     L7_D7C7
        pla
        tay
        pla
        tax
        rts
L7_D7F9:
        sta     $15
        sty     $14
        tya
        and     #$0F
        tay
        lda     $04
        pha
        lda     $15
        asl     A
        adc     $D842,Y
        pha
        lda     $D84A,Y
        adc     #$00
        pha
        lda     $14
        pha
        lda     $0B
        beq     L7_D81B
        jsr     L7_D7C3
L7_D81B:
        pla
        sta     $06
        jsr     L7_D705
        pla
        sta     $15
        pla
        sta     $14
        ldy     #$00
        lda     ($14),Y
        sta     $0C
        iny
        lda     ($14),Y
        sta     $0D
        lda     $18
        sta     $0E
        lda     $19
        sta     $0F
        lda     #$02
        sta     $0B
        pla
        jmp     L7_D705

; ---- bank7.tbl_D842 (data) $D842-$D849, 8 bytes
; Table, 8 bytes
        .byte   $30,$10,$24,$20,$03,$48,$40,$00

; ---- bank7.tbl_D84A (data) $D84A-$D851, 8 bytes
; Table, 8 bytes (structural extent)
        .byte   $80,$80,$80,$80,$80,$80,$80,$C0

; ---- bank7.code_D852 (code) $D852-$D8E0, 143 bytes
L7_D852:
        sta     $10
        lda     $04
        pha
        lda     $10
        pha
        jsr     L7_D714
        pla
        jsr     L0_8006
        pla
        jmp     L7_D705
L7_D865:
        pha
        lda     #$09
        jsr     L7_D6D3
        jsr     L7_D6E0
        stx     $10
        tax
        lda     $19
        and     #$0F
        ora     #$C0
        sta     $0100,X
        lda     $18
        sta     $0101,X
        tya
        sta     $0106,X
        pla
        tay
        and     #$03
        beq     L7_D8A1
        lda     $D8E0,Y
        sta     $0102,X
        lda     $D8E1,Y
        sta     $0103,X
        lda     $D8E2,Y
        sta     $0104,X
        lda     $D8E3,Y
        jmp     L7_D8BD
L7_D8A1:
        tya
        sta     $0102,X
        cpy     #$20
        bne     L7_D8B1
        sta     $0103,X
        sta     $0104,X
        beq     L7_D8BD
L7_D8B1:
        iny
        tya
        sta     $0104,X
        iny
        tya
        sta     $0103,X
        iny
        tya
L7_D8BD:
        sta     $0105,X
        lda     $18
        and     #$02
        lsr     A
        tay
        lda     $18
        and     #$40
        beq     L7_D8CE
        iny
        iny
L7_D8CE:
        lda     $EB00,Y
        sta     $0108,X
        lda     $EB04,Y
        and     $17
        sta     $0107,X
        ldx     $10
        jmp     L7_D6F7

; ---- bank7.tbl_D8E1 (data) $D8E1-$D92C, 76 bytes
; 2x2 tile groups for $C054
        .byte   $F9,$FA,$F7,$F6,$F0,$F9,$F5,$F7,$F8,$F5,$F9,$FA,$F6,$F8,$F0,$F9
        .byte   $82,$83,$91,$90,$82,$83,$91,$90,$91,$90,$92,$93,$91,$90,$92,$93
        .byte   $D7,$D9,$F7,$F9,$9A,$9B,$96,$97,$9E,$9F,$9C,$9D,$98,$99,$9C,$9D
        .byte   $B6,$B7,$B4,$B5,$6A,$6B,$6C,$6D,$BF,$DF,$CF,$EF,$EB,$EC,$ED,$EE
        .byte   $B5,$B6,$C5,$C6,$D7,$D8,$E7,$E8,$F7,$F8,$F7,$F8

; ---- bank7.code_D92D (code) $D92D-$D939, 13 bytes
L7_D92D:
        ldy     #$00
L7_D92F:
        lda     ($18),Y
        cmp     #$FE
        beq     L7_D942
        bcs     L7_D93D
        jsr     L7_D76F

; ---- bank7.inline_D93A (data) $D93A-$D93C, 3 bytes
; Far-call argument at $D93A
        .byte   $05,$17,$80

; ---- bank7.code_D93D (code) $D93D-$DB21, 485 bytes
L7_D93D:
        iny
        cpy     #$08
        bne     L7_D92F
L7_D942:
        lda     #$0F
        sta     $0180
        lda     #$03
        ora     $017F
        sta     $017F
        rts
L7_D950:
        ldy     #$00
        sty     $15
L7_D954:
        lda     $0181,Y
        cmp     $04D0,Y
        beq     L7_D991
        inc     $15
        cmp     #$0F
        bne     L7_D969
        lda     $04D0,Y
        and     #$0F
        bpl     L7_D98E
L7_D969:
        and     #$0F
        sta     $10
        lda     $04D0,Y
        and     #$0F
        cmp     $10
        beq     L7_D97C
        lda     $0181,Y
        jmp     L7_D988
L7_D97C:
        lda     $0181,Y
        cmp     $04D0,Y
        bcs     L7_D988
        adc     #$10
        bne     L7_D98E
L7_D988:
        sbc     #$10
        bcs     L7_D98E
        lda     #$0F
L7_D98E:
        sta     $0181,Y
L7_D991:
        iny
        cpy     #$18
        bne     L7_D954
        lda     #$03
        sta     $017F
        rts
L7_D99C:
        txa
        pha
        sty     $1B
        lda     #$00
        sta     $1A
L7_D9A4:
        lda     $1B
        cmp     #$C0
        bcs     L7_D9E8
        adc     #$08
        sta     $1B
        lda     $15
        clc
        adc     #$03
        jsr     L7_D6D3
        jsr     L7_D6E0
        tax
        lda     $15
        sta     $11
        sta     $0100,X
        lda     $19
        sta     $0101,X
        lda     $18
        sta     $0102,X
        ldy     $1A
L7_D9CD:
        lda     ($16),Y
        sta     $0103,X
        iny
        bne     L7_D9D7
        inc     $17
L7_D9D7:
        inx
        dec     $11
        bne     L7_D9CD
        sty     $1A
        jsr     L7_D6F7
        jsr     L7_DA1D
        dec     $14
        bne     L7_D9A4
L7_D9E8:
        pla
        tax
        ldy     $1B
        rts
L7_D9ED:
        lda     $15
        beq     L7_DA0F
        bmi     L7_DA02
L7_D9F3:
        inc     $18
        lda     $18
        and     #$03
        bne     L7_D9FC
        iny
L7_D9FC:
        dec     $15
        bne     L7_D9F3
        beq     L7_DA0F
L7_DA02:
        lda     $18
        and     #$03
        bne     L7_DA09
        dey
L7_DA09:
        dec     $18
        inc     $15
        bne     L7_DA02
L7_DA0F:
        lda     $14
        beq     L7_DA1C
        bmi     L7_DA4E
L7_DA15:
        jsr     L7_DA1D
        dec     $14
        bne     L7_DA15
L7_DA1C:
        rts
L7_DA1D:
        lda     $18
        clc
        adc     #$20
        sta     $18
        bcc     L7_DA28
        inc     $19
L7_DA28:
        cmp     #$C0
        bcc     L7_DA43
        lda     $19
        and     #$03
        ora     #$08
        cmp     #$0B
        bcc     L7_DA43
        eor     $19
        sta     $19
        lda     $18
        and     #$1F
        sta     $18
        ldy     #$C0
        rts
L7_DA43:
        lda     $18
        and     #$60
        bne     L7_DA4D
        tya
        adc     #$08
        tay
L7_DA4D:
        rts
L7_DA4E:
        jsr     L7_DA56
        inc     $14
        bne     L7_DA4E
        rts
L7_DA56:
        lda     $18
        sec
        sbc     #$20
        sta     $18
        bcs     L7_DA80
        lda     $19
        and     #$03
        ora     #$08
        cmp     #$08
        beq     L7_DA6D
        dec     $19
        bne     L7_DA86
L7_DA6D:
        lda     $18
        sbc     #$40
        sta     $18
        lda     $19
        eor     #$0B
        sta     $19
        tya
        and     #$07
        ora     #$F8
        tay
        rts
L7_DA80:
        and     #$60
        cmp     #$60
        bcc     L7_DA8A
L7_DA86:
        tya
        sbc     #$08
        tay
L7_DA8A:
        rts
L7_DA8B:
        tya
        pha
        ldy     #$01
        jsr     L7_FFD1
        jsr     L7_D64C
        pla
        tay
        lda     $F5
        rts
L7_DA9A:
        lda     $2B
        bne     L7_DADC
        php
        pla
        and     #$04
        bne     L7_DAD8
        sei
        lda     $FE
        and     #$10
        beq     L7_DAD7
L7_DAAB:
        bit     $2002
        bvc     L7_DAB6
        lda     $2B
        bne     L7_DAD7
        beq     L7_DAAB
L7_DAB6:
        bit     $2002
        bvc     L7_DAB6
        jsr     L7_DD21
        lda     $4015
        bmi     L7_DAD2
        inc     $05
        lda     $05
        cmp     #$8A
        bne     L7_DACD
        dec     $05
L7_DACD:
        lda     $05
        sta     $4010
L7_DAD2:
        lda     #$0F
        sta     $4015
L7_DAD7:
        cli
L7_DAD8:
        lda     $2B
        beq     L7_DAD8
L7_DADC:
        lda     #$00
        sta     $2B
        rts
L7_DAE1:
        lda     $30
        bpl     L7_DB15
        dec     $F1
        bne     L7_DAF0
        dec     $F0
        bne     L7_DAF0
        jmp     L7_FF4A
L7_DAF0:
        dec     $F2
        bne     L7_DB0B
        jsr     L7_F9D1
        and     #$0F
        adc     #$18
        sta     $F2
        lda     $F4
        and     #$1F
        sta     $F4
        inc     $F4
        tay
        lda     $DB32,Y
        sta     $F3
L7_DB0B:
        lda     $F3
        sta     $F7
        sta     $F8
        sta     $F5
        sta     $F6
L7_DB15:
        lda     $F7
        ora     $F8
        and     #$0F
        tay
        lda     $DB22,Y
        sta     $32
        rts

; ---- bank7.tbl_DB22 (data) $DB22-$DB31, 16 bytes
; D-pad to direction ($32)
        .byte   $04,$07,$01,$04,$03,$06,$00,$03,$05,$08,$02,$05,$04,$07,$01,$04

; ---- bank7.tbl_DB32 (data) $DB32-$DB51, 32 bytes
; Demo: the button patterns the attract mode holds
        .byte   $C2,$C6,$C0,$CA,$C6,$C1,$C2,$C1,$C4,$C5,$C8,$C6,$C0,$C9,$C5,$C2
        .byte   $C4,$C0,$C5,$C2,$CA,$C4,$C0,$C1,$C0,$C5,$C1,$CA,$C9,$C0,$C5,$C9

; ---- bank7.code_DB52 (code) $DB52-$DF9D, 1100 bytes
L7_DB52:
        lda     $04
        pha
        lda     $06
        jsr     L7_D705
        lda     $0B
        lsr     A
        bcs     L7_DB65
        lsr     A
        bcc     L7_DB76
        jsr     L7_DC5A
L7_DB65:
        lda     $A5
        beq     L7_DB6D
        lda     #$2D
        bne     L7_DB6F
L7_DB6D:
        lda     #$4D
L7_DB6F:
        sec
        sbc     $21
        beq     L7_DB76
        bcs     L7_DB79
L7_DB76:
        jmp     L7_DC55
L7_DB79:
        pha
        clc
        adc     #$03
        jsr     L7_D6E0
        tax
        pla
        sta     $12
        sta     $13
        ldy     #$00
        lda     $0B
        and     #$20
        bne     L7_DC08
L7_DB8E:
        lda     ($0C),Y
        iny
        cmp     $09
        bne     L7_DBAD
        lda     $0B
        eor     #$80
        sta     $0B
        lda     ($0C),Y
        cmp     $09
        bne     L7_DB8E
        lda     #$00
        sta     $0B
        lda     $13
        sec
        sbc     $12
        jmp     L7_DC27
L7_DBAD:
        cmp     $0A
        bne     L7_DBCE
        lda     $0B
        eor     #$40
        sta     $0B
        and     #$40
        beq     L7_DBCA
        lda     ($0C),Y
        pha
        iny
        lda     ($0C),Y
        sta     $0D
        pla
        sta     $0C
        ldy     #$00
        beq     L7_DB8E
L7_DBCA:
        iny
        iny
        bne     L7_DB8E
L7_DBCE:
        bit     $0B
        bvc     L7_DBEC
        asl     A
        ror     $10
        asl     A
        ror     $10
        asl     A
        ror     $10
        asl     A
        ror     $10
        asl     A
        ror     $10
        asl     A
        ror     $10
        asl     A
        ror     $10
        asl     A
        ror     $10
        lda     $10
L7_DBEC:
        bit     $0B
        bmi     L7_DBFB
        sta     $0103,X
        inx
        dec     $12
        beq     L7_DC25
        jmp     L7_DB8E
L7_DBFB:
        sta     $07
        lda     $0B
        eor     #$20
        sta     $0B
        lda     ($0C),Y
        iny
        sta     $08
L7_DC08:
        lda     $07
L7_DC0A:
        sta     $0103,X
        inx
        dec     $08
        beq     L7_DC18
        dec     $12
        bne     L7_DC0A
        beq     L7_DC25
L7_DC18:
        lda     $0B
        eor     #$20
        sta     $0B
        dec     $12
        beq     L7_DC25
        jmp     L7_DB8E
L7_DC25:
        lda     $13
L7_DC27:
        ldx     $21
        sta     $0100,X
        clc
        adc     #$03
        sta     $25
        lda     $0F
        sta     $0101,X
        lda     $0E
        sta     $0102,X
        lda     $13
        pha
        jsr     L7_D6F7
        pla
        clc
        adc     $0E
        sta     $0E
        bcc     L7_DC4B
        inc     $0F
L7_DC4B:
        tya
        clc
        adc     $0C
        sta     $0C
        bcc     L7_DC55
        inc     $0D
L7_DC55:
        pla
        jsr     L7_D705
        rts
L7_DC5A:
        ldy     #$00
        lda     ($0C),Y
        sta     $09
        iny
        lda     ($0C),Y
        sta     $0A
        lda     #$01
        sta     $0B
        lda     $0C
        clc
        adc     #$02
        sta     $0C
        bcc     L7_DC74
        inc     $0D
L7_DC74:
        rts
L7_DC75:
        pha
        txa
        pha
        tya
        pha
        lda     $FE
        and     #$E7
        sta     $FE
        sta     $2001
        inc     $2B
        lda     $2002
        sta     $26
        lda     #$00
        sta     $2003
        lda     #$02
        sta     $4014
        lda     $2002
        lda     #$1F
        sta     $4015
        jsr     L7_DD54
        jsr     L7_DEC9
        lda     $30
        and     #$10
        beq     L7_DCD3
        lda     $0200
        cmp     #$F8
        beq     L7_DCD3
        sec
        adc     $FC
        bcs     L7_DCB8
        cmp     #$F0
        bcc     L7_DCBA
L7_DCB8:
        sbc     #$F0
L7_DCBA:
        and     #$F8
        sta     $BE
        lda     #$08
        asl     $BE
        rol     A
        asl     $BE
        rol     A
        sta     $2006
        lda     $BE
        sta     $2006
        lda     #$FE
        sta     $2007
L7_DCD3:
        jsr     L7_D68B
        jsr     L7_DD48
        lda     $04
        pha
        jsr     L7_D714
        jsr     L0_8009
        pla
        jsr     L7_D705
        tsx
        txa
        adc     $2A
        rol     A
        sta     $2A
        pla
        tay
        pla
        tax
        pla
        rti
L7_DCF3:
        pha
        lda     #$0F
        sta     $4015
        lda     $2B
        bit     $2002
        bvs     L7_DD15
L7_DD00:
        bit     $2002
        bvs     L7_DD0B
        cmp     $2B
        beq     L7_DD00
        bne     L7_DD13
L7_DD0B:
        jsr     L7_DD21
L7_DD0E:
        lda     $05
        sta     $4010
L7_DD13:
        pla
        rti
L7_DD15:
        inc     $05
        lda     $05
        cmp     #$8A
        bne     L7_DD0E
        dec     $05
        bne     L7_DD0E
L7_DD21:
        lda     #$27
        sta     $2006
        lda     #$00
        sta     $2006
        lda     $FF
        and     #$FC
        ora     #$01
        sta     $FF
        sta     $2000
        lda     $FE
        and     #$EF
        sta     $FE
        sta     $2001
        lda     #$00
        sta     $2005
        sta     $2005
        rts
L7_DD48:
        lda     $FE
        and     #$E7
        ora     $A3
        sta     $FE
        sta     $2001
        rts
L7_DD54:
        lda     $A0
        bpl     L7_DD5B
        jsr     L7_D507
L7_DD5B:
        lda     $FF
        and     #$FC
        ora     $A2
        sta     $FF
        lda     $A5
        bne     L7_DD6A
        jmp     L7_DE0C
L7_DD6A:
        tay
        and     #$01
        beq     L7_DDC1
        iny
        tya
        and     #$03
        sta     $A5
        lda     $AD
        ora     #$03
        sta     $2006
        lda     $AA
        sta     $2006
        ldy     #$00
        lda     $04E8
        sta     $2007
        lda     $04E9
        sta     $2007
        lda     $04EA
        sta     $2007
        lda     $04EB
        sta     $2007
        lda     $04EC
        sta     $2007
        lda     $04ED
        sta     $2007
        lda     $04EE
        sta     $2007
        lda     $04EF
        sta     $2007
        lda     $AD
        sta     $2006
        lda     $AC
        sta     $2006
        ldy     #$00
        beq     L7_DDD3
L7_DDC1:
        lda     #$00
        sta     $A5
        lda     $AD
        sta     $2006
        lda     $AC
        ora     #$20
        sta     $2006
        ldy     #$20
L7_DDD3:
        clc
L7_DDD4:
        lda     $0130,Y
        sta     $2007
        lda     $0131,Y
        sta     $2007
        lda     $0132,Y
        sta     $2007
        lda     $0133,Y
        sta     $2007
        lda     $0134,Y
        sta     $2007
        lda     $0135,Y
        sta     $2007
        lda     $0136,Y
        sta     $2007
        lda     $0137,Y
        sta     $2007
        tya
        adc     #$08
        tay
        and     #$1F
        bne     L7_DDD4
L7_DE0C:
        lda     $20
        bne     L7_DE11
        rts
L7_DE11:
        ldx     #$00
        stx     $21
L7_DE15:
        lda     $0100,X
        inx
        tay
        bmi     L7_DE1F
        jmp     L7_DEA9
L7_DE1F:
        and     #$7F
        tay
        asl     A
        bpl     L7_DEA2
        lsr     A
        and     #$0F
        ora     #$20
        pha
        ora     #$03
        stx     $23
        ldy     $0105,X
        tax
        stx     $2006
        sty     $2006
        lda     $2007
        lda     $2007
        sta     $22
        stx     $2006
        sty     $2006
L7_DE47:
        lda     $2007
        lda     $2007
        stx     $2006
        sty     $2006
        cmp     $22
        sta     $22
        bne     L7_DE47
        ldx     $23
        and     $0107,X
        ora     $0106,X
        sta     $2007
        pla
        tay
        sta     $2006
        lda     $0100,X
        sta     $2006
        lda     $0101,X
        cmp     #$FF
        beq     L7_DE96
        sta     $2007
        lda     $0102,X
        sta     $2007
        sty     $2006
        lda     $0100,X
        adc     #$20
        sta     $2006
        lda     $0103,X
        sta     $2007
        lda     $0104,X
        sta     $2007
L7_DE96:
        txa
        adc     #$08
        tax
L7_DE9A:
        dec     $20
        beq     L7_DEA1
        jmp     L7_DE15
L7_DEA1:
        rts
L7_DEA2:
        lda     $FF
        ora     #$04
        sta     $2000
L7_DEA9:
        lda     $0100,X
        sta     $2006
        inx
        lda     $0100,X
        sta     $2006
        inx
L7_DEB7:
        lda     $0100,X
        sta     $2007
        inx
        dey
        bne     L7_DEB7
        lda     $FF
        sta     $2000
        jmp     L7_DE9A
L7_DEC9:
        lda     $017F
        beq     L7_DF3B
        cmp     #$02
        beq     L7_DEE4
L7_DED2:
        ldy     #$00
        ldx     #$3F
        stx     $2006
        sty     $2006
        ldx     #$04
        cmp     #$03
        beq     L7_DEF2
        bne     L7_DEF0
L7_DEE4:
        lda     #$3F
        sta     $2006
        lda     #$10
        sta     $2006
        ldy     #$0C
L7_DEF0:
        ldx     #$02
L7_DEF2:
        clc
L7_DEF3:
        lda     $0180
        sta     $2007
        lda     $0181,Y
        sta     $2007
        lda     $0182,Y
        sta     $2007
        lda     $0183,Y
        sta     $2007
        lda     $0180
        sta     $2007
        lda     $0184,Y
        sta     $2007
        lda     $0185,Y
        sta     $2007
        lda     $0186,Y
        sta     $2007
        tya
        adc     #$06
        tay
        dex
        bne     L7_DEF3
        lda     #$3F
        sta     $2006
        stx     $2006
        stx     $2006
        stx     $2006
        stx     $017F
L7_DF3B:
        rts
L7_DF3C:
        rts
L7_DF3D:
        lda     $017C
        bmi     L7_DF3C
        ldy     #$03
        sec
L7_DF45:
        lda     $016F,Y
        sbc     $017B,Y
        dey
        bne     L7_DF45
        bcc     L7_DF3C
        lda     $017C
        bne     L7_DF7D
        lda     $017D
        bne     L7_DF64
        lda     #$00
        sta     $017E
        inc     $017D
        bne     L7_DF80
L7_DF64:
        cmp     #$01
        bne     L7_DF6F
        lda     #$05
        sta     $017D
        bne     L7_DF80
L7_DF6F:
        cmp     #$05
        bne     L7_DF7D
        lda     #$00
        sta     $017D
        inc     $017C
        bne     L7_DF80
L7_DF7D:
        inc     $017C
L7_DF80:
        lda     $30
        and     #$04
        bne     L7_DF89
        jsr     L7_DF8C
L7_DF89:
        jmp     L7_DF3D
L7_DF8C:
        lda     #$31
        jsr     L7_D852
        lda     $4E
        sta     $4C
        lda     $4F
        sta     $4D
        lda     #$00
        jsr     L7_D76F

; ---- bank7.inline_DF9E (data) $DF9E-$DFA0, 3 bytes
; Far-call argument at $DF9E
        .byte   $06,$E6,$FC

; ---- bank7.code_DFA1 (code) $DFA1-$DFB0, 16 bytes
        lda     $47
        clc
        adc     #$08
        bcc     L7_DFAA
        lda     #$FF
L7_DFAA:
        sta     $47
        sta     $48
        jmp     L7_E424

; ---- bank7.code_DFB1 (code) $DFB1-$DFCE, 30 bytes
L7_DFB1:
        ldy     $0740,X
        lda     $E00D,Y
        bpl     L7_DFBC
        lda     $07D0,X
L7_DFBC:
        sta     $10
        lda     $30
        and     #$80
        bne     L7_E00C
        lda     $10
        jsr     L7_DFCF
        inc     $40
        jsr     L7_DF3D
L7_DFCE:
        rts

; ---- bank7.code_DFCF (code) $DFCF-$E00C, 62 bytes
L7_DFCF:
        sta     $10
        asl     A
        clc
        adc     $10
        asl     A
        adc     #$06
        tay
        stx     $10
        lda     $017C
        bmi     L7_DFCE
        ldx     #$05
        clc
L7_DFE3:
        lda     $E08C,Y
        adc     $0170,X
        cmp     #$0A
        bcc     L7_DFEF
        sbc     #$0A
L7_DFEF:
        sta     $0170,X
        dey
        dex
        bpl     L7_DFE3
        bcc     L7_E00A
        lda     #$09
        ldy     #$05
L7_DFFC:
        sta     $0170,Y
        dey
        bpl     L7_DFFC
        jsr     L7_DF8C
        lda     #$FF
        sta     $017C
L7_E00A:
        ldx     $10
L7_E00C:
        rts

; ---- bank7.tbl_E00D (data) $E00D-$E08C, 128 bytes
; Score class, by type
        .byte   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$02,$02,$02
        .byte   $02,$02,$06,$04,$05,$06,$06,$05,$0F,$10,$06,$03,$02,$06,$07,$08
        .byte   $09,$06,$09,$0D,$0F,$0F,$0F,$FF,$00,$00,$05,$02,$FF,$0D,$0D,$0D
        .byte   $00,$00,$00,$00,$00,$00,$07,$09,$06,$07,$06,$05,$06,$07,$08,$07
        .byte   $0C,$0E,$06,$05,$03,$0C,$0E,$0D,$0F,$10,$0D,$0D,$0B,$0C,$06,$11
        .byte   $04,$05,$03,$07,$07,$07,$08,$09,$09,$05,$07,$08,$09,$09,$09,$03
        .byte   $06,$05,$02,$03,$04,$07,$05,$05,$06,$06,$07,$05,$06,$04,$09,$02
        .byte   $07,$04,$06,$06,$06,$05,$07,$00,$00,$00,$08,$0A,$07,$07,$06,$06

; ---- bank7.tbl_E08D (data) $E08D-$E0F8, 108 bytes
; Score values: 18 classes x 6 digits
        .byte   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00
        .byte   $00,$06,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$01,$07,$00,$00
        .byte   $00,$00,$02,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00,$05,$00
        .byte   $00,$00,$00,$00,$08,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$02
        .byte   $00,$00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$08,$00,$00,$00,$00
        .byte   $01,$00,$00,$00,$00,$00,$01,$05,$00,$00,$00,$00,$02,$00,$00,$00
        .byte   $00,$00,$03,$00,$00,$00,$00,$00,$04,$00,$00,$00

; ---- bank7.code_E0F9 (code) $E0F9-$E161, 105 bytes
L7_E0F9:
        jsr     L7_E30C
        lda     $40
        beq     L7_E10D
        lda     $41
        and     #$07
        bne     L7_E10D
        jsr     L7_E110
        lda     #$00
        sta     $40
L7_E10D:
        inc     $41
        rts
L7_E110:
        lda     #$27
        sta     $19
        lda     #$22
        sta     $18
L7_E118:
        lda     #$09
        jsr     L7_D6C0
        bcs     L7_E15E
        jsr     L7_D6E0
        tay
        stx     $10
        lda     #$00
        sta     $11
        tax
        lda     #$06
        sta     $0100,Y
        lda     $19
        sta     $0101,Y
        lda     $18
        sta     $0102,Y
        clc
L7_E13A:
        lda     $11
        bne     L7_E14B
        lda     $0170,X
        ora     $11
        sta     $11
        bne     L7_E14E
        lda     #$20
        bne     L7_E150
L7_E14B:
        lda     $0170,X
L7_E14E:
        adc     #$30
L7_E150:
        sta     $0103,Y
        iny
        inx
        cpx     #$06
        bne     L7_E13A
        ldx     $10
        jsr     L7_D6F7
L7_E15E:
        rts
L7_E15F:
        jsr     L7_D576

; ---- bank7.inline_E162 (text) $E162-$E168, 7 bytes
; "AREA" at $E162
        .byte   $04,$27,$62,$41,$52,$45,$41

; ---- bank7.code_E169 (code) $E169-$E1A2, 58 bytes
        lda     #$27
        sta     $19
        lda     #$66
        sta     $18
        lda     $30
        and     #$02
        beq     L7_E17C
        lda     $51
        jmp     L7_E1CD
L7_E17C:
        lda     $50
        jsr     L7_E1CD
        lda     #$6B
        sta     $18
        lda     $52
        jsr     L7_E1D3
        lda     #$58
        sta     $0103,Y
        jsr     L7_D6F7
        lda     #$6F
        sta     $18
        lda     $53
        jsr     L7_E1D3
        lda     #$59
        sta     $0103,Y
        jmp     L7_D6F7

; ---- bank7.code_E1A3 (code) $E1A3-$E1C2, 32 bytes
L7_E1A3:
        sty     $12
        ldy     #$00
        sty     $10
        sty     $11
        sec
L7_E1AC:
        sbc     #$64
        bcc     L7_E1B4
        inc     $10
        bcs     L7_E1AC
L7_E1B4:
        adc     #$64
L7_E1B6:
        sbc     #$0A
        bcc     L7_E1BE
        inc     $11
        bcs     L7_E1B6
L7_E1BE:
        adc     #$0A
        ldy     $12
        rts

; ---- bank7.code_E1C3 (code) $E1C3-$E1D2, 16 bytes
L7_E1C3:
        lda     #$27
        sta     $19
        lda     #$39
        sta     $18
        lda     $3E
L7_E1CD:
        jsr     L7_E1D3
        jmp     L7_D6F7

; ---- bank7.code_E1D3 (code) $E1D3-$E212, 64 bytes
L7_E1D3:
        pha
        lda     #$06
        jsr     L7_D6D3
        jsr     L7_D6E0
        tay
        pla
        jsr     L7_E1A3
        adc     #$2F
        sta     $0105,Y
        lda     $10
        bne     L7_E1F7
        lda     #$20
        sta     $0103,Y
        lda     $11
        bne     L7_E1FE
        lda     #$20
        bne     L7_E200
L7_E1F7:
        adc     #$30
        sta     $0103,Y
        lda     $11
L7_E1FE:
        adc     #$30
L7_E200:
        sta     $0104,Y
        lda     #$03
        sta     $0100,Y
        lda     $19
        sta     $0101,Y
        lda     $18
        sta     $0102,Y
        rts

; ---- bank7.code_E213 (code) $E213-$E24A, 56 bytes
L7_E213:
        lda     $4C
        sta     $16
        lda     $4D
        sta     $17
        bne     L7_E22F
        lda     $16
        cmp     #$64
        bcs     L7_E227
        lda     #$00
        beq     L7_E239
L7_E227:
        cmp     #$C8
        bcs     L7_E237
        lda     #$01
        bne     L7_E239
L7_E22F:
        cmp     #$08
        bcc     L7_E237
        lda     #$03
        bne     L7_E239
L7_E237:
        lda     #$02
L7_E239:
        sta     $3A
        lda     $4C
        sta     $16
        lda     $4D
        sta     $17
        lda     #$2F
        sta     $18
        lda     #$27
        sta     $19

; ---- bank7.code_E24B (code) $E24B-$E30B, 193 bytes
L7_E24B:
        txa
        pha
        lda     #$07
        jsr     L7_D6D3
        jsr     L7_D6E0
        tax
        lda     #$04
        sta     $0100,X
        lda     $19
        sta     $0101,X
        lda     $18
        sta     $0102,X
        lda     #$30
        sta     $0103,X
        sta     $0104,X
        lda     #$20
        sta     $0105,X
        sta     $0106,X
        lda     #$01
        sta     $10
        sec
        ldy     #$0A
L7_E27C:
        lda     $16
        sbc     #$E8
        sta     $16
        lda     $17
        sbc     #$03
        sta     $17
        bcc     L7_E29D
        inc     $0103,X
        dey
        bne     L7_E27C
        lda     #$39
        sta     $0103,X
        sta     $0105,X
        sta     $0106,X
        bne     L7_E304
L7_E29D:
        lda     $16
        adc     #$E8
        sta     $16
        lda     $17
        adc     #$03
        sta     $17
        lda     $0103,X
        cmp     #$30
        bne     L7_E2B8
        dec     $10
        lda     #$20
        sta     $0103,X
        sec
L7_E2B8:
        lda     $16
        sbc     #$64
        sta     $16
        lda     $17
        sbc     #$00
        sta     $17
        bcc     L7_E2CB
        inc     $0104,X
        bcs     L7_E2B8
L7_E2CB:
        lda     $16
        adc     #$64
        sta     $16
        lda     $10
        bne     L7_E2DE
        lda     $0104,X
        cmp     #$30
        beq     L7_E2E4
        inc     $10
L7_E2DE:
        inx
        lda     #$30
        sta     $0104,X
L7_E2E4:
        sec
        lda     $16
L7_E2E7:
        sbc     #$0A
        bcc     L7_E2F0
        inc     $0104,X
        bcs     L7_E2E7
L7_E2F0:
        adc     #$3A
        sta     $16
        lda     $10
        bne     L7_E301
        lda     $0104,X
        cmp     #$30
        beq     L7_E302
        inc     $10
L7_E301:
        inx
L7_E302:
        lda     $16
L7_E304:
        sta     $0104,X
        pla
        tax
        jmp     L7_D6F7

; ---- bank7.code_E30C (code) $E30C-$E3F8, 237 bytes
L7_E30C:
        lda     $49
        sta     $15
        beq     L7_E31D
        sec
        sbc     #$01
        tay
        lsr     A
        lsr     A
        lsr     A
        sta     $15
        inc     $15
L7_E31D:
        lda     $49
        cmp     $48
        beq     L7_E356
        php
        lda     #$FF
        bcs     L7_E32A
        lda     #$01
L7_E32A:
        clc
        adc     $49
        sta     $14
        sta     $17
        sta     $16
        beq     L7_E345
        sec
        sbc     #$01
        tay
        lsr     A
        lsr     A
        lsr     A
        sta     $17
        inc     $17
        tya
        and     #$07
        sta     $16
L7_E345:
        lda     $17
        cmp     $15
        bne     L7_E34E
        jmp     L7_E3BE
L7_E34E:
        lda     #$16
        jsr     L7_D6C0
        bcc     L7_E357
        plp
L7_E356:
        rts
L7_E357:
        lda     #$27
        sta     $19
        lda     #$40
        sta     $18
        lda     $14
        beq     L7_E36C
        sec
        sbc     #$01
        lsr     A
        lsr     A
        lsr     A
        clc
        adc     #$01
L7_E36C:
        jsr     L7_E1D3
        lda     $0104,Y
        cmp     #$20
        bne     L7_E377
        iny
L7_E377:
        lda     #$23
        sta     $0103,Y
        jsr     L7_D6F7
        lda     #$08
        jsr     L7_D6E0
        tay
        plp
        bcs     L7_E38D
        lda     #$21
        pha
        bne     L7_E390
L7_E38D:
        lda     #$22
        pha
L7_E390:
        lda     $17
        jsr     L7_E406
        bcs     L7_E3A5
        lda     #$FF
        sta     a:$00FF,y
        inc     $24
        lda     $25
        clc
        adc     #$04
        sta     $25
L7_E3A5:
        lda     $15
        jsr     L7_E406
        bcs     L7_E3BA
        pla
        pha
        sta     a:$00FF,y
        inc     $24
        lda     $25
        clc
        adc     #$04
        sta     $25
L7_E3BA:
        pla
        jmp     L7_E3CC
L7_E3BE:
        plp
        lda     #$08
        jsr     L7_D6C0
        bcs     L7_E423
        lda     #$08
        jsr     L7_D6E0
        tay
L7_E3CC:
        lda     #$05
        sta     $0100,Y
        lda     #$1F
        sta     $0101,Y
        lda     #$F9
        sta     $0102,Y
        ldx     $16
        lda     $E3F9,X
        sta     $10
        ldx     #$00
L7_E3E4:
        lda     $10
        and     $E401,X
        sta     $0103,Y
        iny
        inx
        cpx     #$05
        bne     L7_E3E4
        lda     $14
        sta     $49
        jmp     L7_D6F7

; ---- bank7.tbl_E3F9 (data) $E3F9-$E400, 8 bytes
; Meter fill masks
        .byte   $80,$C0,$E0,$F0,$F8,$FC,$FE,$FF

; ---- bank7.tbl_E401 (data) $E401-$E405, 5 bytes
; Meter row masks
        .byte   $EE,$FE,$FF,$FF,$EE

; ---- bank7.code_E406 (code) $E406-$E423, 30 bytes
L7_E406:
        and     #$FF
        beq     L7_E422
        cmp     #$19
        bcs     L7_E423
        adc     #$42
        sta     $0102,Y
        lda     #$27
        sta     $0101,Y
        lda     #$01
        sta     $0100,Y
        iny
        iny
        iny
        iny
        rts
L7_E422:
        sec
L7_E423:
        rts

; ---- bank7.code_E424 (code) $E424-$E444, 33 bytes
L7_E424:
        lsr     A
        lsr     A
        lsr     A
        beq     L7_E423
        cmp     #$19
        bcs     L7_E423
        pha
        lda     #$04
        jsr     L7_D6D3
        lda     #$04
        jsr     L7_D6E0
        tay
        pla
        jsr     L7_E406
        lda     #$22
        sta     a:$00FF,y
        jmp     L7_D6F7

; ---- bank7.code_E445 (code) $E445-$E452, 14 bytes
L7_E445:
        sta     $15
        lda     #$20
        sta     $14
        lda     #$00
        sta     $17
        lda     #$1E
        sta     $16

; ---- bank7.code_E453 (code) $E453-$E497, 69 bytes
L7_E453:
        lda     $17
        and     #$FE
        tay
        lda     $EAE3,Y
        ora     $15
        sta     $19
        lda     $17
        lsr     A
        lda     $EAE2,Y
        bcc     L7_E469
        ora     #$20
L7_E469:
        sta     $18
        lda     #$20
        sta     $15
        ldx     $17
L7_E471:
        jsr     L7_D5F8
        lda     $18
        clc
        adc     #$20
        sta     $18
        bcc     L7_E47F
        inc     $19
L7_E47F:
        inx
        cpx     $16
        bne     L7_E485
        rts
L7_E485:
        cpx     #$1E
        bcc     L7_E471
        ldx     #$00
        stx     $18
        lda     $19
        eor     #$08
        and     #$2C
        sta     $19
        jmp     L7_E471

; ---- bank7.code_E498 (code) $E498-$E4B2, 27 bytes
L7_E498:
        stx     $38
        tax
        asl     A
        jsr     L7_EFC7
        txa
        and     #$03
        tax
        inx
        lda     $04AC,Y
L7_E4A7:
        dex
        beq     L7_E4AE
        lsr     A
        lsr     A
        bpl     L7_E4A7
L7_E4AE:
        ldx     $38
        and     #$03
        rts

; ---- bank7.code_E4B3 (code) $E4B3-$E4DC, 42 bytes
L7_E4B3:
        lda     $F5
        and     #$10
        beq     L7_E4E3
        lda     #$46
        jsr     L7_D852
L7_E4BE:
        jsr     L7_E4DD
        lda     $F5
        and     #$30
        beq     L7_E4BE
        cmp     #$20
        beq     L7_E4EE
L7_E4CB:
        lda     #$47
        jsr     L7_D852
        ldy     #$1E
L7_E4D2:
        tya
        pha
        jsr     L7_E4DD
        pla
        tay
        dey
        bne     L7_E4D2
L7_E4DC:
        rts

; ---- bank7.code_E4DD (code) $E4DD-$E4E2, 6 bytes
L7_E4DD:
        jsr     L7_DA9A
        jmp     L7_D64C

; ---- bank7.code_E4E3 (code) $E4E3-$E4ED, 11 bytes
L7_E4E3:
        lda     $F5
        and     #$20
        beq     L7_E4DC
        lda     #$46
        jsr     L7_D852

; ---- bank7.code_E4EE (code) $E4EE-$E521, 52 bytes
L7_E4EE:
        lda     #$3E
        jsr     L7_D852
        lda     $30
        pha
        and     #$EF
        sta     $30
        lda     $04
        pha
        jsr     L7_D755
        jsr     L5_801B
L7_E503:
        jsr     L7_E4DD
        jsr     L5_8021
        lda     $F5
        and     #$30
        beq     L7_E503
        jsr     L5_801E
        jsr     L7_D762
        jsr     L6_8000
        pla
        jsr     L7_D705
        pla
        sta     $30
        jmp     L7_E4CB

; ---- bank7.code_E522 (code) $E522-$E52F, 14 bytes
L7_E522:
        lda     $A0
        pha
        lda     #$80
        sta     $A0
        jsr     L7_D507
        pla
        sta     $A0
        rts

; ---- bank7.code_E530 (code) $E530-$E55F, 48 bytes
L7_E530:
        lda     $B6
        sec
        sbc     $B8
        sta     $B6
        rol     A
        eor     #$01
        ror     A
        lda     #$00
        adc     $B9
        sta     $B7
        lda     $A6
        sec
        sbc     $B7
        php
        cmp     $A6
        beq     L7_E55E
        plp
        sta     $A6
        bcs     L7_E522
        lda     $A7
        eor     #$01
        sta     $A7
        lda     $A6
        sbc     #$0F
        sta     $A6
        bcs     L7_E522
L7_E55E:
        plp
        rts

; ---- bank7.code_E560 (code) $E560-$E5BC, 93 bytes
L7_E560:
        lda     #$00
        sta     $B8
        sta     $B9
        sta     $A5
        sta     $A1
        jsr     L7_D4FD
        lda     #$FF
        sta     $B0
        sta     $B1
        lda     #$0F
        sta     $AF
        lda     #$0D
        sta     $AE
        lda     #$01
        sta     $AB
        lda     $30
        ora     #$10
        sta     $30
        ldx     #$08
L7_E587:
        lda     #$80
        sta     $03FF,X
        dex
        bne     L7_E587
        ldy     #$00
        lda     ($18),Y
        sta     $B2
        iny
        lda     ($18),Y
        sta     $B3
        lda     $18
        clc
        adc     #$02
        sta     $BC
        lda     $19
        adc     #$00
        sta     $BD
        lda     $B2
        sec
        sbc     #$01
        sta     $B0
        lda     $B3
        sbc     #$00
        sta     $B1
        lda     #$00
        sta     $BA
        lda     #$02
        sta     $BB
        rts

; ---- bank7.code_E5BD (code) $E5BD-$E5EA, 46 bytes
L7_E5BD:
        jsr     L7_EE09
        jsr     L7_D7C3
L7_E5C3:
        lda     $B8
        pha
        lda     $B9
        pha
        lda     #$00
        sta     $B8
        lda     #$10
        sta     $B9
        jsr     L7_E530
        pla
        sta     $B9
        pla
        sta     $B8
        jsr     L7_E69B
        jsr     L7_E5EB
        lda     $AE
        cmp     #$0D
        bne     L7_E5C3
        lda     $AB
        bne     L7_E5C3
L7_E5EA:
        rts

; ---- bank7.code_E5EB (code) $E5EB-$E604, 26 bytes
L7_E5EB:
        ldx     $21
        cpx     #$31
        bcc     L7_E5F7
        jsr     L7_E605
        jmp     L7_E5EB
L7_E5F7:
        lda     $A5
        beq     L7_E5EA
        cmp     #$02
        beq     L7_E619
L7_E5FF:
        jsr     L7_E605
        jmp     L7_E5EB

; ---- bank7.code_E605 (code) $E605-$E618, 20 bytes
L7_E605:
        lda     $FE
        and     #$18
        bne     L7_E618
        jsr     L7_D7AA
        pha
        jsr     L7_DD54
        pla
        sta     $FF
        sta     $2000
L7_E618:
        rts

; ---- bank7.code_E619 (code) $E619-$E654, 60 bytes
L7_E619:
        ldx     $21
        cpx     #$0E
        bcs     L7_E5FF
        lda     $20
        pha
        lda     #$00
        sta     $20
        sta     $A5
        ldx     $21
        lda     #$20
        sta     $0100,X
        lda     $AD
        sta     $0101,X
        lda     $AC
        ora     #$20
        sta     $0102,X
        ldy     #$00
L7_E63D:
        lda     $0150,Y
        sta     $0103,X
        inx
        iny
        cpy     #$20
        bne     L7_E63D
        txa
        clc
        adc     #$03
        sta     $21
        pla
        adc     #$01
        sta     $20
        rts

; ---- bank7.code_E655 (code) $E655-$E669, 21 bytes
L7_E655:
        lda     #$00
        sta     $B7
        lda     $A0
        and     #$FB
        sta     $A0
        and     #$01
        beq     L7_E666
        jmp     L7_EB18
L7_E666:
        bit     $30
        bvc     L7_E6A6

; ---- bank7.code_E66A (code) $E66A-$E69A, 49 bytes
L7_E66A:
        jsr     L7_E530
        lda     $B9
        cmp     $BB
        bcc     L7_E681
        beq     L7_E677
        bcs     L7_E68F
L7_E677:
        lda     $B8
        cmp     $BA
        bcc     L7_E681
        beq     L7_E69B
        bcs     L7_E68F
L7_E681:
        lda     $B8
        adc     #$02
        sta     $B8
        lda     $B9
        adc     #$00
        sta     $B9
        bcc     L7_E69B
L7_E68F:
        lda     $B8
        sbc     #$02
        sta     $B8
        lda     $B9
        sbc     #$00
        sta     $B9

; ---- bank7.code_E69B (code) $E69B-$E6AB, 17 bytes
L7_E69B:
        lda     $AF
        clc
        adc     $B7
        sta     $AF
        cmp     #$10
        bcs     L7_E6AC
L7_E6A6:
        lda     $04
        pha
        jmp     L7_E995

; ---- bank7.code_E6AC (code) $E6AC-$E6C5, 26 bytes
L7_E6AC:
        sbc     #$10
        sta     $AF
        jsr     L7_E5EB
        inc     $B0
        bne     L7_E6B9
        inc     $B1
L7_E6B9:
        jsr     L7_EACC
        lda     $AB
        beq     L7_E6C6
        lda     $AD
        adc     #$08
        sta     $AD

; ---- bank7.code_E6C6 (code) $E6C6-$E6CD, 8 bytes
L7_E6C6:
        lda     $04
        pha
        jsr     L7_D748
L7_E6CC:
        ldy     #$00

; ---- bank7.code_E6CE (code) $E6CE-$E6EA, 29 bytes
L7_E6CE:
        lda     $B0
        cmp     $B2
        bne     L7_E6DA
        lda     $B1
        cmp     $B3
        beq     L7_E6EB
L7_E6DA:
        tya
        beq     L7_E6E8
        clc
        adc     $BC
        sta     $BC
        lda     $BD
        adc     #$00
        sta     $BD
L7_E6E8:
        jmp     L7_E8AB

; ---- bank7.code_E6EB (code) $E6EB-$E6F2, 8 bytes
L7_E6EB:
        lda     ($BC),Y
        iny
        sty     $16
        jsr     L7_D6AE

; ---- bank7.tbl_E6F3 (pointer_table) $E6F3-$E706, 20 bytes
; Screen-data command dispatch
        .byte   $06,$E7,$20,$E7,$32,$E7,$5F,$E7,$89,$E7,$9E,$E7,$B5,$E7,$5D,$E8
        .byte   $80,$E8,$92,$E8

; ---- bank7.code_E707 (code) $E707-$E720, 26 bytes
L7_E707:
        ldy     $16
        lda     ($BC),Y
        sta     $BA
        iny
        lda     ($BC),Y
        sta     $BB
        bpl     L7_E71E
        and     #$7F
        sta     $BB
        sta     $B9
        lda     $BA
        sta     $B8
L7_E71E:
        jmp     L7_E89D

; ---- bank7.code_E721 (code) $E721-$E732, 18 bytes
L7_E721:
        ldy     $16
        lda     ($BC),Y
        sta     $B4
        iny
        lda     ($BC),Y
        sta     $B5
        lda     #$00
        sta     $A1
        jmp     L7_E89D

; ---- bank7.code_E733 (code) $E733-$E75F, 45 bytes
L7_E733:
        ldy     $16
        lda     ($BC),Y
        and     #$03
        sta     $10
        lda     $60
        and     #$FC
        ora     $10
        sta     $60
        lda     ($BC),Y
        and     #$02
        beq     L7_E75D
        iny
        lda     ($BC),Y
        sta     $66
        iny
        lda     ($BC),Y
        sta     $67
        lda     #$01
        sta     $68
        sta     $69
        lda     #$04
        sta     $7F
L7_E75D:
        jmp     L7_E89D

; ---- bank7.code_E760 (code) $E760-$E789, 42 bytes
L7_E760:
        ldy     $16
L7_E762:
        lda     ($BC),Y
        sta     $18
        iny
        lda     ($BC),Y
        sta     $19
        ldy     #$00
        lda     ($18),Y
        sta     $B2
        sta     $B0
        iny
        lda     ($18),Y
        sta     $B3
        sta     $B1
        lda     $18
        clc
        adc     #$02
        sta     $BC
        lda     $19
        adc     #$00
        sta     $BD
        jmp     L7_E6CC

; ---- bank7.code_E78A (code) $E78A-$E79E, 21 bytes
L7_E78A:
        ldy     $16
        lda     ($BC),Y
        sta     $18
        iny
        lda     ($BC),Y
        sta     $19
        sty     $16
        jsr     L7_D92D
        ldy     $16
        jmp     L7_E89D

; ---- bank7.code_E79F (code) $E79F-$E7B5, 23 bytes
L7_E79F:
        ldy     $16
        lda     #$01
        sta     $70
        lda     $51
        cmp     #$15
        beq     L7_E7AF
        dey
        jmp     L7_E89D
L7_E7AF:
        lda     ($BC),Y
        sta     $72
        jmp     L7_E89D

; ---- bank7.code_E7B6 (code) $E7B6-$E85D, 168 bytes
L7_E7B6:
        ldy     $16
        lda     ($BC),Y
        bne     L7_E7BF
        jmp     L7_E89D
L7_E7BF:
        sta     $14
L7_E7C1:
        iny
        lda     ($BC),Y
        sta     $15
        iny
        and     #$07
        tax
        bit     $15
        bpl     L7_E7D5
        lda     #$00
        sta     $0430,X
        beq     L7_E7E4
L7_E7D5:
        lda     ($BC),Y
        iny
        sta     $0430,X
        lda     $15
        and     #$20
        bne     L7_E7E4
        lda     ($BC),Y
        iny
L7_E7E4:
        sta     $0408,X
        bit     $15
        bvc     L7_E7EF
        lda     #$00
        beq     L7_E7F2
L7_E7EF:
        lda     ($BC),Y
        iny
L7_E7F2:
        sta     $0438,X
        lda     $15
        and     #$20
        beq     L7_E7FF
        lda     #$01
        bne     L7_E802
L7_E7FF:
        lda     ($BC),Y
        iny
L7_E802:
        sta     $0410,X
        lda     ($BC),Y
        sta     $0400,X
        iny
        lda     $15
        and     #$10
        beq     L7_E82B
        lda     ($BC),Y
        sta     $0440,X
        iny
        lda     ($BC),Y
        sta     $0448,X
        iny
        lda     ($BC),Y
        sta     $0420,X
        iny
        lda     ($BC),Y
        sta     $0418,X
        jmp     L7_E854
L7_E82B:
        lda     ($BC),Y
        sta     $18
        iny
        lda     ($BC),Y
        sta     $19
        sty     $16
        ldy     #$00
        lda     ($18),Y
        sta     $0420,X
        iny
        lda     ($18),Y
        sta     $0418,X
        lda     $18
        clc
        adc     #$02
        sta     $0440,X
        lda     $19
        adc     #$00
        sta     $0448,X
        ldy     $16
L7_E854:
        jsr     L7_EA79
        dec     $14
        beq     L7_E89D
        jmp     L7_E7C1

; ---- bank7.code_E85E (code) $E85E-$E880, 35 bytes
L7_E85E:
        lda     $27
        beq     L7_E86B
        jsr     L7_E99F
        jsr     L7_D7C3
        jmp     L7_E85E
L7_E86B:
        ldy     $16
        lda     ($BC),Y
        sta     $28
        iny
        lda     ($BC),Y
        sta     $29
        lda     #$80
        sta     $27
        lda     #$04
        sta     $7E
        jmp     L7_E89D

; ---- bank7.code_E881 (code) $E881-$E892, 18 bytes
L7_E881:
        ldy     $16
L7_E883:
        lda     ($BC),Y
        tax
        cmp     #$08
        bcs     L7_E89D
        iny
        lda     ($BC),Y
        sta     $0199,X
        iny
        bne     L7_E883

; ---- bank7.code_E893 (code) $E893-$E89C, 10 bytes
L7_E893:
        ldy     $16
        lda     $70
        beq     L7_E89C
        jmp     L7_E762
L7_E89C:
        iny

; ---- bank7.code_E89D (code) $E89D-$E8AA, 14 bytes
L7_E89D:
        iny
        lda     ($BC),Y
        sta     $B2
        iny
        lda     ($BC),Y
        sta     $B3
        iny
        jmp     L7_E6CE

; ---- bank7.code_E8AB (code) $E8AB-$E8E0, 54 bytes
L7_E8AB:
        ldy     #$02
        lda     $A1
        cmp     ($B4),Y
        bcc     L7_E8B7
        lda     #$00
        sta     $A1
L7_E8B7:
        inc     $A1
        ldy     #$00
        sty     $19
        asl     A
        asl     A
        asl     A
        rol     $19
        asl     A
        rol     $19
        ldy     #$00
        adc     ($B4),Y
        sta     $18
        iny
        lda     ($B4),Y
        adc     $19
        sta     $19
        ldy     #$00
        ldx     #$00
L7_E8D6:
        lda     ($18),Y
        sta     $04C0,X
        iny
        inx
        cpx     #$10
        bne     L7_E8D6

; ---- bank7.code_E8E1 (code) $E8E1-$E973, 147 bytes
        ldx     #$00
        stx     $15
L7_E8E5:
        lda     $0400,X
        cmp     #$80
        bne     L7_E8EF
        jmp     L7_E969
L7_E8EF:
        lda     $0430,X
        beq     L7_E8FA
        dec     $0430,X
        jmp     L7_E969
L7_E8FA:
        lda     $0450,X
        sta     $18
        lda     $0458,X
        sta     $19
        ldy     #$00
        lda     $0420,X
        sta     $14
        lda     $0400,X
        tax
L7_E90F:
        lda     ($18),Y
        bne     L7_E91D
        iny
        txa
        clc
        adc     ($18),Y
        tax
        iny
        jmp     L7_E90F
L7_E91D:
        iny
        cmp     #$01
        beq     L7_E92E
        cpx     #$10
        bcs     L7_E929
        sta     $04C0,X
L7_E929:
        inx
        dec     $14
        bne     L7_E90F
L7_E92E:
        ldx     $15
        tya
        clc
        adc     $18
        sta     $0450,X
        lda     $19
        adc     #$00
        sta     $0458,X
        dec     $0428,X
        bne     L7_E969
        lda     $0410,X
        beq     L7_E954
        dec     $0410,X
        bne     L7_E954
L7_E94D:
        lda     #$80
        sta     $0400,X
        bne     L7_E969
L7_E954:
        lda     $0400,X
        clc
        adc     $0438,X
        sta     $0400,X
        cmp     #$20
        bcc     L7_E966
        cmp     #$F0
        bcc     L7_E94D
L7_E966:
        jsr     L7_EA73
L7_E969:
        inc     $15
        ldx     $15
        cpx     #$08
        beq     L7_E974
        jmp     L7_E8E5

; ---- bank7.code_E974 (code) $E974-$E98E, 27 bytes
L7_E974:
        jsr     L7_D755
        jsr     L5_8009
        jsr     L5_802A
        lda     #$01
        sta     $A5
        dec     $AE
        bpl     L7_E98F
        lda     #$0E
        sta     $AE
        lda     $AB
        eor     #$01
        sta     $AB

; ---- bank7.code_E98F (code) $E98F-$E994, 6 bytes
L7_E98F:
        lda     $A0
        ora     #$04
        sta     $A0

; ---- bank7.code_E995 (code) $E995-$E99E, 10 bytes
L7_E995:
        jsr     L7_E99F
        jsr     L7_F78F
        pla
        jmp     L7_D705

; ---- bank7.code_E99F (code) $E99F-$EA20, 130 bytes
L7_E99F:
        lda     $27
        bne     L7_E9A4
        rts
L7_E9A4:
        pha
        lda     $7E
        jsr     L7_D705
        pla
        bmi     L7_E9B0
        jmp     L7_EA21
L7_E9B0:
        ldy     $0B
        beq     L7_E9B7
        jmp     L7_EA4C
L7_E9B7:
        and     #$7F
        sta     $27
L7_E9BB:
        tay
        lda     ($28),Y
        and     #$7F
        and     #$0F
        tay
        lda     $0480,Y
        sta     $17
        beq     L7_E9E9
        lda     #$00
        sta     $0480,Y
        ldx     #$05
L7_E9D1:
        lda     $0500,X
        beq     L7_E9E4
        jsr     L7_CF4C
        beq     L7_E9E4
        cmp     $17
        bne     L7_E9E4
        lda     #$28
        sta     $0500,X
L7_E9E4:
        inx
        cpx     #$18
        bne     L7_E9D1
L7_E9E9:
        ldy     $27
        lda     ($28),Y
        sta     $10
        iny
        lda     ($28),Y
        sta     $17
        bne     L7_EA03
        dey
        lda     $10
        bmi     L7_EA47
        tya
        clc
        adc     #$82
        sta     $27
        bne     L7_EA4C
L7_EA03:
        iny
        lda     #$00
        sta     $19
        lda     ($28),Y
        asl     A
        rol     $19
        asl     A
        rol     $19
        asl     A
        rol     $19
        asl     A
        rol     $19
        sta     $18
        lda     $17
        jsr     L7_EA58
        inc     $27
        bne     L7_EA4C

; ---- bank7.code_EA21 (code) $EA21-$EA4B, 43 bytes
L7_EA21:
        lda     $0B
        bne     L7_EA4C
        lda     $27
        tay
        dey
        lda     ($28),Y
        sta     $17
        and     #$0F
        tax
        iny
        lda     ($28),Y
        sta     $0480,X
        iny
        lda     ($28),Y
        sta     $0490,X
        iny
        tya
        sta     $27
        bit     $17
        bmi     L7_EA47
        jmp     L7_E9BB
L7_EA47:
        lda     #$00
        sta     $27
L7_EA4B:
        rts

; ---- bank7.code_EA4C (code) $EA4C-$EA57, 12 bytes
L7_EA4C:
        lda     $FE
        and     #$18
        bne     L7_EA4B
        jsr     L7_D7C3
        jmp     L7_E99F

; ---- bank7.code_EA58 (code) $EA58-$EA67, 16 bytes
L7_EA58:
        cmp     #$40
        bcs     L7_EA61
        ldy     #$03
        jmp     L7_D7F9
L7_EA61:
        sbc     #$30
        ldy     #$02
        jmp     L7_D7F9

; ---- bank7.code_EA68 (code) $EA68-$EA72, 11 bytes
L7_EA68:
        ldx     #$01
L7_EA6A:
        jsr     L7_CCBF
        inx
        cpx     #$18
        bne     L7_EA6A
        rts

; ---- bank7.code_EA73 (code) $EA73-$EA78, 6 bytes
L7_EA73:
        lda     $0408,X
        sta     $0430,X

; ---- bank7.code_EA79 (code) $EA79-$EA8B, 19 bytes
L7_EA79:
        lda     $0440,X
        sta     $0450,X
        lda     $0448,X
        sta     $0458,X
        lda     $0418,X
        sta     $0428,X
        rts

; ---- bank7.code_EA8C (code) $EA8C-$EACB, 64 bytes
L7_EA8C:
        ldy     #$17
L7_EA8E:
        lda     $0500,Y
        beq     L7_EACA
        dey
        cpy     #$04
        bne     L7_EA8E
L7_EA98:
        iny
        lda     $0500,Y
        and     #$7F
        cmp     #$0B
        beq     L7_EAC1
        cmp     #$0C
        beq     L7_EAC1
        cmp     #$0D
        beq     L7_EAC1
        cpy     #$17
        bne     L7_EA98
L7_EAAE:
        lda     $0500,Y
        bpl     L7_EABA
        lda     $0578,Y
        and     #$02
        beq     L7_EAC1
L7_EABA:
        dey
        cpy     #$04
        bne     L7_EAAE
        sec
        rts
L7_EAC1:
        txa
        pha
        tya
        tax
        jsr     L7_CCBF
        pla
        tax
L7_EACA:
        clc
        rts

; ---- bank7.code_EACC (code) $EACC-$EAE1, 22 bytes
L7_EACC:
        lda     $AE
        asl     A
        tay
        and     #$1C
        asl     A
        ora     #$C0
        sta     $AA
        lda     $EAE2,Y
        sta     $AC
        lda     $EAE3,Y
        sta     $AD
        rts

; ---- bank7.tbl_EAE2 (data) $EAE2-$EAE2, 1 bytes
; Table, 1 bytes (structural extent)
        .byte   $00

; ---- bank7.tbl_EAE3 (data) $EAE3-$EAFF, 29 bytes
; Table, 29 bytes (structural extent)
        .byte   $20,$40,$20,$80,$20,$C0,$20,$00,$21,$40,$21,$80,$21,$C0,$21,$00
        .byte   $22,$40,$22,$80,$22,$C0,$22,$00,$23,$40,$23,$80,$23

; ---- bank7.tbl_EB00 (data) $EB00-$EB03, 4 bytes
; Table, 4 bytes
        .byte   $FC,$F3,$CF,$3F

; ---- bank7.tbl_EB04 (data) $EB04-$EB07, 4 bytes
; Table, 4 bytes (structural extent)
        .byte   $03,$0C,$30,$C0

; ---- bank7.code_EB08 (code) $EB08-$EB17, 16 bytes
L7_EB08:
        lda     #$78
        sta     $0530
        lda     #$90
        sta     $0518
        lda     #$04
        sta     $0668
        rts

; ---- bank7.code_EB18 (code) $EB18-$EB1C, 5 bytes
L7_EB18:
        lda     $0500
        bne     L7_EB78

; ---- bank7.code_EB1D (code) $EB1D-$EB2F, 19 bytes
        jsr     L7_E15F
        lda     $2F
        cmp     #$03
        bcs     L7_EB30
        lda     #$04
        ldx     #$09
L7_EB2A:
        sta     $04F0,X
        dex
        bpl     L7_EB2A

; ---- bank7.code_EB30 (code) $EB30-$EB46, 23 bytes
L7_EB30:
        lda     #$00
        sta     $2F
        jsr     L7_D755
        jsr     L7_EB08
        lda     #$04
        sta     $A4
        jsr     L5_802D
        lda     $30
        and     #$20
        bne     L7_EB60

; ---- bank7.code_EB47 (code) $EB47-$EB5F, 25 bytes
        lda     #$00
        sta     $50
        sta     $51
        sta     $77
        bit     $30
        bpl     L7_EB5A
        jsr     L7_F9D1
        and     #$0F
        sta     $51
L7_EB5A:
        jsr     L7_D4F3
        jmp     L7_EC94

; ---- bank7.code_EB60 (code) $EB60-$EB77, 24 bytes
L7_EB60:
        lda     $30
        and     #$02
        bne     L7_EB5A
        jsr     L7_F6F5
        jsr     L7_F717
        ldy     #$00
        lda     ($E4),Y
        bmi     L7_EB75
        jmp     L7_EC76
L7_EB75:
        jmp     L7_EC23

; ---- bank7.code_EB78 (code) $EB78-$EB8B, 20 bytes
L7_EB78:
        ldy     $A4
        cpy     #$04
        beq     L7_EB8C
        ldx     #$09
L7_EB80:
        lda     $04EF,X
        sta     $04F0,X
        dex
        bne     L7_EB80
        sty     $04F0

; ---- bank7.code_EB8C (code) $EB8C-$EB91, 6 bytes
L7_EB8C:
        lda     $A0
        and     #$02
        bne     L7_EBD4

; ---- bank7.code_EB92 (code) $EB92-$EBA4, 19 bytes
        lda     #$FF
        sta     $56
        jsr     L7_EA68
        jsr     L7_D755
        bit     $30
        bvc     L7_EBA5
        bpl     L7_EBFE
        jmp     L7_FF4A

; ---- bank7.code_EBA5 (code) $EBA5-$EBB9, 21 bytes
L7_EBA5:
        lda     $70
        beq     L7_EBBA
        lda     #$1F
        jsr     L7_D852
        ldy     $50
        lda     $EF16,Y
        jsr     L7_D852
        lda     #$00
        sta     $70

; ---- bank7.code_EBBA (code) $EBBA-$EBD3, 26 bytes
L7_EBBA:
        jsr     L5_802D
        jsr     L5_8015
        jsr     L5_8003
        jsr     L5_8030
        jsr     L7_F09A
        jsr     L7_ED44
        jsr     L5_8039
        lda     #$00
        jmp     L7_ED1D

; ---- bank7.code_EBD4 (code) $EBD4-$EBED, 26 bytes
L7_EBD4:
        lda     $A4
        cmp     #$04
        beq     L7_EBEE
        lda     $0578
        and     #$BF
        ora     #$80
        sta     $0578
        lda     #$80
        sta     $0788
        ldy     #$3C
        jsr     L7_FF8B

; ---- bank7.code_EBEE (code) $EBEE-$EBFD, 16 bytes
L7_EBEE:
        lda     #$00
        sta     $0500
        ldy     #$14
        jsr     L7_FF8B
        jsr     L7_EA68
        jsr     L7_D755

; ---- bank7.code_EBFE (code) $EBFE-$EC11, 20 bytes
L7_EBFE:
        lda     #$00
        sta     $70
        ldx     $A4
        lda     $E0,X
        sta     $18
        lda     $E1,X
        sta     $19
        lda     $30
        and     #$60
        bne     L7_EC54

; ---- bank7.code_EC12 (code) $EC12-$EC22, 17 bytes
L7_EC12:
        jsr     L7_EDD1
        lda     #$1F
        jsr     L7_D852
        jsr     L7_D4E3
        jsr     L7_F269
        jsr     L5_802D

; ---- bank7.code_EC23 (code) $EC23-$EC28, 6 bytes
L7_EC23:
        jsr     L7_EE1D
        jsr     L7_ED44

; ---- bank7.code_EC29 (code) $EC29-$EC37, 15 bytes
        lda     #$00
        sta     $0500
        sta     $36
        lda     #$BF
        jsr     L7_D51E
        jsr     L7_D76F

; ---- bank7.inline_EC38 (data) $EC38-$EC3A, 3 bytes
; Far-call argument at $EC38
        .byte   $06,$FF,$7F

; ---- bank7.code_EC3B (code) $EC3B-$EC4B, 17 bytes
        jsr     L7_D4FD
        jsr     L7_ED98
        lda     $51
        cmp     #$05
        beq     L7_EC4C
        lda     #$80
        jmp     L7_ED1D

; ---- bank7.code_EC4C (code) $EC4C-$EC53, 8 bytes
L7_EC4C:
        jsr     L7_F4B7
        lda     #$00
        jmp     L7_ED1D

; ---- bank7.code_EC54 (code) $EC54-$EC5A, 7 bytes
L7_EC54:
        cmp     #$20
        beq     L7_EC5B
        jmp     L7_ECBD

; ---- bank7.code_EC5B (code) $EC5B-$EC64, 10 bytes
L7_EC5B:
        cpx     #$04
        beq     L7_EC8C
        ldy     #$00
        lda     ($18),Y
        bmi     L7_EC12

; ---- bank7.code_EC65 (code) $EC65-$EC8B, 39 bytes
        jsr     L7_EDD1
        lda     #$1F
        jsr     L7_D852
        jsr     L7_D4E3
        jsr     L7_F269
        jsr     L5_802D
L7_EC76:
        jsr     L7_EEE0
        jsr     L7_ED44
        jsr     L7_D4FD
        lda     #$BF
        jsr     L7_D51E
        jsr     L7_ED98
        lda     #$80
        jmp     L7_ED1D

; ---- bank7.code_EC8C (code) $EC8C-$EC93, 8 bytes
L7_EC8C:
        ldy     #$02
        lda     ($18),Y
        and     #$7F
        sta     $51

; ---- bank7.code_EC94 (code) $EC94-$ECBC, 41 bytes
L7_EC94:
        lda     #$1F
        jsr     L7_D852
        jsr     L7_F282
        jsr     L7_EF6C
        lda     #$80
        sta     $0530
        lda     #$A0
        sta     $0518
        lda     #$BF
        jsr     L7_D51E
        jsr     L7_ED98
        ldy     $51
        lda     $EF2A,Y
        jsr     L7_D852
        lda     #$00
        beq     L7_ED1D

; ---- bank7.code_ECBD (code) $ECBD-$ECC6, 10 bytes
L7_ECBD:
        lda     $51
        beq     L7_ECE7
        cmp     #$15
        bcc     L7_ECE4
        bne     L7_ECE1

; ---- bank7.code_ECC7 (code) $ECC7-$ECCC, 6 bytes
        jsr     L7_F506
        jsr     L7_D76F

; ---- bank7.inline_ECCD (data) $ECCD-$ECCF, 3 bytes
; Far-call argument at $ECCD
        .byte   $00,$11,$80

; ---- bank7.code_ECD0 (code) $ECD0-$ECD5, 6 bytes
        jsr     L7_F6E5
        jsr     L7_F717

; ---- bank7.code_ECD6 (code) $ECD6-$ECD8, 3 bytes
        jsr     L7_D76F

; ---- bank7.inline_ECD9 (data) $ECD9-$ECDB, 3 bytes
; Far-call argument at $ECD9
        .byte   $02,$1A,$80

; ---- bank7.code_ECDC (code) $ECDC-$ECE0, 5 bytes
        inc     $51
        jmp     L7_EC94

; ---- bank7.code_ECE1 (code) $ECE1-$ECE3, 3 bytes
L7_ECE1:
        jsr     L7_F506

; ---- bank7.code_ECE4 (code) $ECE4-$ECE6, 3 bytes
L7_ECE4:
        jsr     L7_EFBA

; ---- bank7.code_ECE7 (code) $ECE7-$ECEF, 9 bytes
L7_ECE7:
        jsr     L7_F506
        lda     $30
        and     #$02
        bne     L7_ECF6

; ---- bank7.code_ECF0 (code) $ECF0-$ECF5, 6 bytes
        jsr     L7_EB08
        jmp     L7_EC23

; ---- bank7.code_ECF6 (code) $ECF6-$ECF8, 3 bytes
L7_ECF6:
        jsr     L7_D76F

; ---- bank7.inline_ECF9 (data) $ECF9-$ECFB, 3 bytes
; Far-call argument at $ECF9
        .byte   $03,$17,$80

; ---- bank7.code_ECFC (code) $ECFC-$ED07, 12 bytes
        ldy     $77
        inc     $77
        lda     $ED08,Y
        sta     $51
        jmp     L7_EC94

; ---- bank7.tbl_ED08 (data) $ED08-$ED1C, 21 bytes
; TGL game: corridor order
        .byte   $01,$0B,$0C,$02,$0D,$03,$0E,$04,$0F,$05,$10,$06,$11,$07,$12,$08
        .byte   $13,$09,$14,$0A,$15

; ---- bank7.code_ED1D (code) $ED1D-$ED2D, 17 bytes
L7_ED1D:
        sta     $0578
        bit     $0578
        bpl     L7_ED2E
        bit     $30
        bvs     L7_ED2E
        lda     #$3C
        jsr     L7_D852

; ---- bank7.code_ED2E (code) $ED2E-$ED43, 22 bytes
L7_ED2E:
        lda     #$40
        sta     $0788
        lda     #$01
        sta     $0500
        lda     $A0
        and     #$FC
        sta     $A0
        jsr     L7_E15F
        jmp     L7_D762

; ---- bank7.code_ED44 (code) $ED44-$ED50, 13 bytes
L7_ED44:
        ldy     #$03
L7_ED46:
        lda     a:$0058,y
        ora     #$30
        sta     a:$0058,y
        dey
        bpl     L7_ED46

; ---- bank7.code_ED51 (code) $ED51-$ED6D, 29 bytes
L7_ED51:
        lda     #$10
        sta     $19
        lda     #$00
        sta     $18
        ldy     #$00
L7_ED5B:
        lda     a:$0058,y
        and     #$0F
        cmp     #$08
        bne     L7_ED6A
        iny
        cpy     #$04
        bne     L7_ED5B
        rts
L7_ED6A:
        pha
        jsr     L7_D76F

; ---- bank7.inline_ED6E (data) $ED6E-$ED70, 3 bytes
; Far-call argument at $ED6E
        .byte   $02,$05,$80

; ---- bank7.code_ED71 (code) $ED71-$ED8D, 29 bytes
        pla
        sta     $10
        lda     #$10
        sta     $19
        lda     #$40
        sta     $18
        ldy     #$00
L7_ED7E:
        lda     a:$0058,y
        and     #$0F
        cmp     #$08
        beq     L7_ED92
        cmp     $10
        beq     L7_ED92
        jsr     L7_D76F

; ---- bank7.inline_ED8E (data) $ED8E-$ED90, 3 bytes
; Far-call argument at $ED8E
        .byte   $02,$05,$80

; ---- bank7.code_ED91 (code) $ED91-$ED91, 1 bytes
        rts

; ---- bank7.code_ED92 (code) $ED92-$ED97, 6 bytes
L7_ED92:
        iny
        cpy     #$04
        bne     L7_ED7E
        rts

; ---- bank7.code_ED98 (code) $ED98-$EDA0, 9 bytes
L7_ED98:
        jsr     L7_EDA1
        jsr     L7_EDE8
        jmp     L7_EDBD

; ---- bank7.code_EDA1 (code) $EDA1-$EDB6, 22 bytes
L7_EDA1:
        ldy     #$18
L7_EDA3:
        lda     $0180,Y
        sta     $04CF,Y
        lda     #$0F
        sta     $0180,Y
        dey
        bne     L7_EDA3
        lda     #$03
        sta     $017F
        rts

; ---- bank7.code_EDB7 (code) $EDB7-$EDBC, 6 bytes
L7_EDB7:
        jsr     L7_EDA1
        jsr     L7_EDF4

; ---- bank7.code_EDBD (code) $EDBD-$EDD0, 20 bytes
L7_EDBD:
        jsr     L7_D950
        lda     $15
        bne     L7_EDC5
        rts
L7_EDC5:
        lda     $FF
        bpl     L7_EDBD
        ldy     #$02
        jsr     L7_FFD1
        jmp     L7_EDBD

; ---- bank7.code_EDD1 (code) $EDD1-$EDE4, 20 bytes
L7_EDD1:
        ldy     #$18
L7_EDD3:
        lda     #$0F
        sta     $04CF,Y
        dey
        bne     L7_EDD3
        sta     $0180
        jsr     L7_EDBD
        sei
        jmp     L7_D4C7

; ---- bank7.code_EDE5 (code) $EDE5-$EDF3, 15 bytes
L7_EDE5:
        jsr     L7_D51E
L7_EDE8:
        lda     #$87
        sta     $05
        sta     $4010
        jsr     L7_EDF4
        cli
        rts

; ---- bank7.code_EDF4 (code) $EDF4-$EE08, 21 bytes
L7_EDF4:
        lda     $2002
        bmi     L7_EDF4
L7_EDF9:
        lda     $2002
        bpl     L7_EDF9
        jsr     L7_D4F3
        ldy     #$02
        jsr     L7_FFD1
        jmp     L7_D4D5

; ---- bank7.code_EE09 (code) $EE09-$EE14, 12 bytes
L7_EE09:
        ldy     #$07
L7_EE0B:
        lda     $EE15,Y
        sta     $0199,Y
        dey
        bpl     L7_EE0B
        rts

; ---- bank7.tbl_EE15 (data) $EE15-$EE1C, 8 bytes
; Table, 8 bytes (structural extent)
        .byte   $00,$55,$AA,$FF,$00,$55,$AA,$FF

; ---- bank7.code_EE1D (code) $EE1D-$EE21, 5 bytes
L7_EE1D:
        jsr     L7_EECC
        bpl     L7_EE56

; ---- bank7.code_EE22 (code) $EE22-$EE2C, 11 bytes
        and     #$7F
        tay
        lda     $EF40,Y
        sta     $55
        tya
        sta     $15

; ---- bank7.code_EE2D (code) $EE2D-$EE31, 5 bytes
        jsr     L7_EFAC
        bcs     L7_EE3C

; ---- bank7.code_EE32 (code) $EE32-$EE3B, 10 bytes
        bit     $30
        lda     #$05
        bvs     L7_EE6B
        lda     #$04
        bne     L7_EE6B

; ---- bank7.code_EE3C (code) $EE3C-$EE55, 26 bytes
L7_EE3C:
        lda     $15
        cmp     #$15
        bne     L7_EE52
        lda     $04AA
        ora     #$FC
        and     $04A9
        cmp     #$FF
        beq     L7_EE52
        lda     #$00
        beq     L7_EE6B
L7_EE52:
        lda     #$08
        bne     L7_EE6B

; ---- bank7.code_EE56 (code) $EE56-$EE6A, 21 bytes
L7_EE56:
        and     #$0F
        cmp     #$02
        beq     L7_EE60
        cmp     #$06
        bne     L7_EE6B
L7_EE60:
        pha
        lda     $5E
        jsr     L7_EFE0
        pla
        bcs     L7_EE6B
        lda     #$07

; ---- bank7.code_EE6B (code) $EE6B-$EE7F, 21 bytes
L7_EE6B:
        sta     $51
        ora     #$10
        sta     $5C
        jsr     L5_8000
        lda     #$00
        sta     $50
        lda     $30
        and     #$8F
        ora     #$20
        sta     $30

; ---- bank7.code_EE80 (code) $EE80-$EE82, 3 bytes
        jsr     L5_8003

; ---- bank7.code_EE83 (code) $EE83-$EE9C, 26 bytes
        lda     $51
        cmp     #$05
        bne     L7_EE9D
        ldx     #$37
        jsr     L7_EEB7
        ldx     #$72
        jsr     L7_EEB7
        ldx     #$7D
        jsr     L7_EEB7
        ldx     #$A7
        jsr     L7_EEB7

; ---- bank7.code_EE9D (code) $EE9D-$EEA7, 11 bytes
L7_EE9D:
        jsr     L5_8006
        lda     #$20
        jsr     L7_EFF3
        jsr     L5_8036

; ---- bank7.code_EEA8 (code) $EEA8-$EEB6, 15 bytes
        lda     #$35
        sta     $0505
        ldy     $51
        lda     $EF21,Y
        beq     L7_EEC3
        jmp     L7_D852

; ---- bank7.code_EEB7 (code) $EEB7-$EEC3, 13 bytes
L7_EEB7:
        lda     $0740,X
        cmp     #$08
        bne     L7_EEC3
        lda     #$0C
        sta     $0740,X
L7_EEC3:
        rts

; ---- bank7.pal_EEC4 (palette) $EEC4-$EECB, 8 bytes
; Palette-list-shaped table, no reader found
        .byte   $00,$01,$02,$03,$05,$06,$09,$0A

; ---- bank7.code_EECC (code) $EECC-$EEDF, 20 bytes
L7_EECC:
        lda     #$FF
        sta     $56
        jsr     L7_EE09
        jsr     L5_8015
        lda     #$00
        jsr     L5_8000
        ldy     #$02
        lda     ($E4),Y
        rts

; ---- bank7.code_EEE0 (code) $EEE0-$EEF3, 20 bytes
L7_EEE0:
        jsr     L7_EECC
        pha
        lsr     A
        lsr     A
        lsr     A
        lsr     A
        sta     $51
        pla
        and     #$0F
        sta     $50
        clc
        adc     #$05
        sta     $5C

; ---- bank7.code_EEF4 (code) $EEF4-$EF05, 18 bytes
        jsr     L5_8000
        lda     $30
        and     #$8F
        sta     $30
        jsr     L5_8003
        jsr     L5_8030
        jsr     L5_8006

; ---- bank7.code_EF06 (code) $EF06-$EF0D, 8 bytes
        lda     #$20
        jsr     L7_EFF3
        jsr     L5_8039

; ---- bank7.code_EF0E (code) $EF0E-$EF15, 8 bytes
        ldy     $50
        lda     $EF16,Y
        jmp     L7_D852

; ---- bank7.tbl_EF16 (data) $EF16-$EF20, 11 bytes
; Labyrinth music, by area
        .byte   $09,$07,$07,$02,$02,$07,$0D,$07,$02,$0D,$0E

; ---- bank7.tbl_EF21 (data) $EF21-$EF29, 9 bytes
; Special-screen sound, by screen type 0-8
        .byte   $10,$18,$18,$13,$10,$00,$18,$18,$12

; ---- bank7.tbl_EF2A (data) $EF2A-$EF3F, 22 bytes
; Corridor music, by corridor
        .byte   $1E,$15,$15,$04,$04,$05,$05,$0C,$0C,$08,$08,$15,$15,$04,$04,$05
        .byte   $05,$0C,$0C,$08,$08,$1C

; ---- bank7.tbl_EF40 (data) $EF40-$EF54, 21 bytes
; Corridor reward item, by corridor
        .byte   $19,$07,$09,$0C,$00,$0B,$06,$0A,$03,$06,$0B,$04,$08,$0F,$0D,$11
        .byte   $01,$09,$05,$0F,$0E

; ---- bank7.tbl_EF55 (data) $EF55-$EF6B, 23 bytes
; Corridor scene, by corridor
        .byte   $20,$21,$21,$22,$22,$23,$23,$24,$24,$26,$26,$21,$21,$22,$22,$23
        .byte   $23,$24,$24,$25,$25,$25,$20

; ---- bank7.code_EF6C (code) $EF6C-$EF83, 24 bytes
L7_EF6C:
        jsr     L7_EECC
        lda     #$01
        jsr     L5_8000
        ldy     $51
        lda     $EF55,Y
        sta     $5C
        jsr     L5_8000
        jsr     L7_D7C3
        jsr     L5_8036

; ---- bank7.code_EF84 (code) $EF84-$EF8E, 11 bytes
        ldy     #$06
L7_EF86:
        lda     $016F,Y
        sta     $04B8,Y
        dey
        bne     L7_EF86

; ---- bank7.code_EF8F (code) $EF8F-$EF92, 4 bytes
        lda     $47
        sta     $78

; ---- bank7.code_EF93 (code) $EF93-$EF9A, 8 bytes
        lda     $30
        and     #$9F
        ora     #$50
        sta     $30

; ---- bank7.code_EF9B (code) $EF9B-$EFA2, 8 bytes
        jsr     L7_D748
        lda     $51
        jsr     L4_8000

; ---- bank7.code_EFA3 (code) $EFA3-$EFA8, 6 bytes
        jsr     L7_E560
        jsr     L7_E5BD

; ---- bank7.code_EFA9 (code) $EFA9-$EFAB, 3 bytes
        jmp     L7_D755

; ---- bank7.code_EFAC (code) $EFAC-$EFB9, 14 bytes
L7_EFAC:
        sec
        sbc     #$01
        jsr     L7_EFC7
        and     $04A9,Y
L7_EFB5:
        clc
        bne     L7_EFB9
        sec
L7_EFB9:
        rts

; ---- bank7.code_EFBA (code) $EFBA-$EFC6, 13 bytes
L7_EFBA:
        sec
        sbc     #$01
        jsr     L7_EFC7
        ora     $04A9,Y
        sta     $04A9,Y
        rts

; ---- bank7.code_EFC7 (code) $EFC7-$EFD7, 17 bytes
L7_EFC7:
        pha
        and     #$07
        tay
        lda     $EFD8,Y
        sta     $10
        pla
        lsr     A
        lsr     A
        lsr     A
        tay
        lda     $10
        rts

; ---- bank7.tbl_EFD8 (data) $EFD8-$EFDF, 8 bytes
; Bit masks $01-$80
        .byte   $01,$02,$04,$08,$10,$20,$40,$80

; ---- bank7.code_EFE0 (code) $EFE0-$EFE8, 9 bytes
L7_EFE0:
        jsr     L7_EFC7
        and     $04A0,Y
        jmp     L7_EFB5

; ---- bank7.code_EFE9 (code) $EFE9-$EFF2, 10 bytes
L7_EFE9:
        jsr     L7_EFC7
        ora     $04A0,Y
        sta     $04A0,Y
        rts

; ---- bank7.code_EFF3 (code) $EFF3-$F000, 14 bytes
L7_EFF3:
        ldy     #$00
        sty     $AE
        sty     $16
        sta     $17
        sty     $B7
        lda     #$20
        sta     $AF

; ---- bank7.code_F001 (code) $F001-$F01E, 30 bytes
L7_F001:
        jsr     L7_E5EB
        jsr     L7_F03D
        lda     $17
        cmp     #$20
        bne     L7_F010
        jsr     L5_802A
L7_F010:
        lda     $AF
        clc
        adc     #$10
        sta     $AF
        inc     $AE
        lda     $AE
        cmp     #$0D
        bne     L7_F001

; ---- bank7.code_F01F (code) $F01F-$F024, 6 bytes
        lda     $17
        cmp     #$20
        bne     L7_F03A

; ---- bank7.code_F025 (code) $F025-$F027, 3 bytes
        jsr     L7_D5CC

; ---- bank7.fill_F028 (data) $F028-$F02B, 4 bytes
; Fill arguments: 32 blanks at PPU $2320
        .byte   $20,$23,$20,$20

; ---- bank7.code_F02C (code) $F02C-$F02E, 3 bytes
        jsr     L7_D5CC

; ---- bank7.fill_F02F (data) $F02F-$F032, 4 bytes
; Fill arguments: 64 blanks at PPU $2340
        .byte   $40,$23,$40,$20

; ---- bank7.code_F033 (code) $F033-$F035, 3 bytes
        jsr     L7_D5CC

; ---- bank7.fill_F036 (data) $F036-$F039, 4 bytes
; Fill arguments: 64 blanks at PPU $2380
        .byte   $40,$23,$80,$20

; ---- bank7.code_F03A (code) $F03A-$F03C, 3 bytes
L7_F03A:
        jmp     L7_D7C3

; ---- bank7.code_F03D (code) $F03D-$F045, 9 bytes
L7_F03D:
        jsr     L7_EACC
        lda     $AD
        ora     $17
        sta     $AD

; ---- bank7.code_F046 (code) $F046-$F04B, 6 bytes
        ldy     $16
        cpy     #$C0
        bne     L7_F082

; ---- bank7.code_F04C (code) $F04C-$F081, 54 bytes
        lda     #$00
        sta     $10
        lda     $AE
        and     #$01
        beq     L7_F05A
        lda     #$0F
        sta     $10
L7_F05A:
        ldy     #$1F
L7_F05C:
        lda     #$20
        sta     $0130,Y
        dey
        bpl     L7_F05C
        ldy     #$07
L7_F066:
        lda     $04E8,Y
        and     $10
        sta     $04E8,Y
        lda     #$00
        sta     $04C0,Y
        sta     $04C8,Y
        dey
        bpl     L7_F066
        lda     #$FE
        sta     $0130
        lda     #$03
        bne     L7_F097

; ---- bank7.code_F082 (code) $F082-$F08F, 14 bytes
L7_F082:
        ldx     #$00
L7_F084:
        lda     $0740,Y
        sta     $04C0,X
        iny
        inx
        cpx     #$10
        bne     L7_F084

; ---- bank7.code_F090 (code) $F090-$F099, 10 bytes
        sty     $16
        jsr     L5_8009
        lda     #$01
L7_F097:
        sta     $A5
        rts

; ---- bank7.code_F09A (code) $F09A-$F0A7, 14 bytes
L7_F09A:
        lda     $A4
        bne     L7_F0A1
        jmp     L7_F169
L7_F0A1:
        cmp     #$08
        bne     L7_F0A8
        jmp     L7_F10D

; ---- bank7.code_F0A8 (code) $F0A8-$F0AA, 3 bytes
L7_F0A8:
        jsr     L7_D5CC

; ---- bank7.fill_F0AB (data) $F0AB-$F0AE, 4 bytes
; Fill arguments: 6 bytes of $00 at PPU $1FEA
        .byte   $06,$1F,$EA,$00

; ---- bank7.code_F0AF (code) $F0AF-$F0B6, 8 bytes
        lda     #$24
        jsr     L7_EFF3
        jsr     L7_D5CC

; ---- bank7.fill_F0B7 (data) $F0B7-$F0BA, 4 bytes
; Fill arguments: 31 bytes of $FE at PPU $2301
        .byte   $1F,$23,$01,$FE

; ---- bank7.code_F0BB (code) $F0BB-$F0BD, 3 bytes
        jsr     L7_D5CC

; ---- bank7.fill_F0BE (data) $F0BE-$F0C1, 4 bytes
; Fill arguments: 31 bytes of $FE at PPU $2701
        .byte   $1F,$27,$01,$FE

; ---- bank7.code_F0C2 (code) $F0C2-$F10C, 75 bytes
L7_F0C2:
        ldy     #$01
        jsr     L7_FFD1
        lda     $A4
        cmp     #$02
        beq     L7_F0E8
        lda     $A8
        lsr     A
        lsr     A
        lsr     A
        lda     $0530
        sbc     #$03
        sta     $0530
        lda     $A8
        clc
        adc     #$04
        sta     $A8
        bcc     L7_F100
        inc     $A9
        jmp     L7_F100
L7_F0E8:
        lda     $A8
        lsr     A
        lsr     A
        lsr     A
        lda     $0530
        adc     #$03
        sta     $0530
        lda     $A8
        sec
        sbc     #$04
        sta     $A8
        bcs     L7_F100
        inc     $A9
L7_F100:
        jsr     L7_E522
        jsr     L7_F258
        lda     $A8
        bne     L7_F0C2
        jmp     L7_F1DA

; ---- bank7.code_F10D (code) $F10D-$F168, 92 bytes
L7_F10D:
        lda     $30
        ora     #$10
        sta     $30
        lda     #$0C
        sta     $AE
        lda     #$20
        sta     $17
        lda     #$00
        sta     $16
        sta     $0440
        jsr     L7_F204
        inc     $AE
L7_F127:
        ldy     #$01
        jsr     L7_FFD1
        lda     $A6
        and     #$0F
        bne     L7_F147
        jsr     L7_F204
        inc     $AE
        lda     $AE
        cmp     #$0F
        bne     L7_F147
        lda     #$00
        sta     $AE
        lda     $17
        eor     #$08
        sta     $17
L7_F147:
        lda     $0518
        sec
        sbc     #$03
        sta     $0518
        lda     $A6
        clc
        adc     #$04
        sta     $A6
        jsr     L7_E522
        jsr     L7_F258
        lda     $A6
        cmp     #$C0
        bne     L7_F127
        jsr     L7_F20A
        jmp     L7_F1B9

; ---- bank7.code_F169 (code) $F169-$F1B8, 80 bytes
L7_F169:
        lda     $30
        ora     #$10
        sta     $30
        lda     #$0E
        sta     $AE
        lda     #$28
        sta     $17
        lda     #$B0
        sta     $16
L7_F17B:
        ldy     #$01
        jsr     L7_FFD1
        lda     $A6
        and     #$0F
        bne     L7_F195
        jsr     L7_E5EB
        jsr     L7_F03D
        lda     $16
        sec
        sbc     #$20
        sta     $16
        dec     $AE
L7_F195:
        lda     $0518
        clc
        adc     #$03
        sta     $0518
        lda     $A6
        sec
        sbc     #$04
        sta     $A6
        bcs     L7_F1AD
        lda     #$EC
        sta     $A6
        inc     $A7
L7_F1AD:
        jsr     L7_E522
        jsr     L7_F258
        lda     $A6
        cmp     #$30
        bne     L7_F17B

; ---- bank7.code_F1B9 (code) $F1B9-$F1C1, 9 bytes
L7_F1B9:
        lda     $30
        and     #$EF
        sta     $30
        jsr     L7_D5CC

; ---- bank7.fill_F1C2 (data) $F1C2-$F1C5, 4 bytes
; Fill arguments: 6 bytes of $00 at PPU $1FEA
        .byte   $06,$1F,$EA,$00

; ---- bank7.code_F1C6 (code) $F1C6-$F1D9, 20 bytes
        lda     #$24
        jsr     L7_EFF3
        lda     #$00
        sta     $A6
        sta     $A7
        sta     $A8
        lda     #$01
        sta     $A9
        jsr     L7_E522

; ---- bank7.code_F1DA (code) $F1DA-$F1EE, 21 bytes
L7_F1DA:
        lda     #$20
        jsr     L7_EFF3
        lda     #$00
        sta     $A8
        sta     $A9
        sta     $A6
        sta     $A7
        jsr     L7_E522
        jsr     L7_D5CC

; ---- bank7.fill_F1EF (data) $F1EF-$F1F2, 4 bytes
; Fill arguments: 32 blanks at PPU $2700
        .byte   $20,$27,$00,$20

; ---- bank7.code_F1F3 (code) $F1F3-$F1F5, 3 bytes
        jsr     L7_D5CC

; ---- bank7.fill_F1F6 (data) $F1F6-$F1F9, 4 bytes
; Fill arguments: 6 bytes of $FF at PPU $1FEA
        .byte   $06,$1F,$EA,$FF

; ---- bank7.code_F1FA (code) $F1FA-$F1FC, 3 bytes
        jsr     L7_D5CC

; ---- bank7.fill_F1FD (data) $F1FD-$F200, 4 bytes
; Fill arguments: 32 blanks at PPU $2400
        .byte   $20,$24,$00,$20

; ---- bank7.code_F201 (code) $F201-$F203, 3 bytes
        jmp     L5_8006

; ---- bank7.code_F204 (code) $F204-$F257, 84 bytes
L7_F204:
        jsr     L7_E5EB
        jsr     L7_F03D
L7_F20A:
        ldy     $0440
        lda     $AD
        sta     $0400,Y
        lda     $AC
        sta     $0401,Y
        lda     $0130
        sta     $0402,Y
        lda     $0150
        sta     $0403,Y
        cpy     #$08
        bcc     L7_F250
        lda     #$05
        jsr     L7_D6D3
        jsr     L7_D6E0
        tax
        lda     #$82
        sta     $0100,X
        lda     $03F8,Y
        sta     $0101,X
        lda     $03F9,Y
        sta     $0102,X
        lda     $03FA,Y
        sta     $0103,X
        lda     $03FB,Y
        sta     $0104,X
        jsr     L7_D6F7
L7_F250:
        tya
        clc
        adc     #$04
        sta     $0440
        rts

; ---- bank7.code_F258 (code) $F258-$F25F, 8 bytes
L7_F258:
        jsr     L7_CDB4
        ldx     #$00
        jsr     L7_D76F

; ---- bank7.fill_F260 (data) $F260-$F262, 3 bytes
; Far-call arguments: bank 3, target $8003
        .byte   $03,$02,$80

; ---- bank7.code_F263 (code) $F263-$F268, 6 bytes
        jsr     L7_CBFC
        jmp     L7_CE88

; ---- bank7.code_F269 (code) $F269-$F277, 15 bytes
L7_F269:
        ldy     $A4
        lda     $F278,Y
        sta     $0530
        lda     $F279,Y
        sta     $0518
        rts

; ---- bank7.tbl_F278 (data) $F278-$F278, 1 bytes
; Table, 1 bytes (structural extent)
        .byte   $78

; ---- bank7.tbl_F279 (data) $F279-$F281, 9 bytes
; Table, 9 bytes (structural extent)
        .byte   $90,$DC,$70,$80,$90,$28,$70,$78,$38

; ---- bank7.code_F282 (code) $F282-$F28F, 14 bytes
L7_F282:
        jsr     L7_EDD1
        jsr     L7_D4E3
        lda     $51
        beq     L7_F290
        cmp     #$16
        bne     L7_F2A0

; ---- bank7.code_F290 (code) $F290-$F29F, 16 bytes
L7_F290:
        lda     #$00
        sta     $0680
        jsr     L7_F6E5
        lda     #$BF
        sta     $0200
        jmp     L7_F452

; ---- bank7.code_F2A0 (code) $F2A0-$F2AD, 14 bytes
L7_F2A0:
        cmp     #$0B
        bcc     L7_F2A6
        sbc     #$0A
L7_F2A6:
        cmp     #$0B
        bcc     L7_F2AC
        lda     #$0A
L7_F2AC:
        sta     $50

; ---- bank7.code_F2AE (code) $F2AE-$F2B3, 6 bytes
        lda     $30
        and     #$02
        bne     L7_F290

; ---- bank7.code_F2B4 (code) $F2B4-$F2B8, 5 bytes
        lda     #$1D
        jsr     L7_D852

; ---- bank7.code_F2B9 (code) $F2B9-$F2D8, 32 bytes
        lda     #$00
L7_F2BB:
        sta     $0680
        jsr     L7_F6E5
        lda     $30
        ora     #$48
        sta     $30
        lda     #$00
        jsr     L5_8000
        lda     #$20
        sta     $5C
        jsr     L5_8000
        jsr     L7_D7C3
        jsr     L7_D748

; ---- bank7.code_F2D9 (code) $F2D9-$F2F5, 29 bytes
        lda     #$FF
        ldy     $0680
        beq     L7_F2ED
        ldy     $51
        cpy     #$15
        bne     L7_F2ED
        lda     #$2D
        jsr     L7_D852
        lda     #$FE
L7_F2ED:
        jsr     L4_8000
        jsr     L7_E560
        jsr     L7_E5BD

; ---- bank7.code_F2F6 (code) $F2F6-$F335, 64 bytes
        ldy     #$30
        lda     $0680
        beq     L7_F2FF
        ldy     #$C8
L7_F2FF:
        sty     $0518
        lda     #$80
        sta     $0530
        lda     #$00
        sta     $06C8
        lda     #$01
        sta     $0620
        lda     #$00
        sta     $0668
        lda     #$00
        sta     $0788
        lda     #$00
        sta     $05D8
        ldy     #$80
        lda     $0680
        beq     L7_F32C
        dec     $05D8
        ldy     #$C0
L7_F32C:
        sty     $05C0
        lda     #$05
        sta     $0500
        ldx     #$00

; ---- bank7.code_F336 (code) $F336-$F33D, 8 bytes
        jsr     L7_CD99
        lda     #$BF
        jsr     L7_EDE5

; ---- bank7.code_F33E (code) $F33E-$F34A, 13 bytes
L7_F33E:
        jsr     L7_E66A
        jsr     L7_CDB4
        ldx     #$00
        lda     $0680
        beq     L7_F3A7

; ---- bank7.code_F34B (code) $F34B-$F3A6, 92 bytes
        ldy     #$00
        lda     $51
        cmp     #$15
        bne     L7_F35A
        lda     #$C4
        sta     $05C0
        bne     L7_F36E
L7_F35A:
        ldy     $0638
        lda     #$60
        cpy     #$3C
        bcs     L7_F365
        lda     #$80
L7_F365:
        ldy     #$C8
        jsr     L7_CD7A
        cpy     #$60
        bcs     L7_F382
L7_F36E:
        lda     #$0C
        jsr     L7_F9AE
        lda     $F487,Y
        sta     $0560
        lda     $F47B,Y
        sta     $0548
        jmp     L7_F3FC
L7_F382:
        lda     #$08
        sta     $0788
        lda     #$40
        sta     $0560
        cpy     #$6C
        bcs     L7_F39F
        tya
        eor     #$FF
        adc     #$6D
        tay
        lda     $F46F,Y
        sta     $0548
        jmp     L7_F3F6
L7_F39F:
        lda     #$16
        sta     $0548
        jmp     L7_F3F6

; ---- bank7.code_F3A7 (code) $F3A7-$F3FB, 85 bytes
L7_F3A7:
        lda     $0638
        cmp     #$22
        bcs     L7_F3B2
        lda     #$30
        bne     L7_F3B4
L7_F3B2:
        lda     #$60
L7_F3B4:
        ldy     #$C8
        jsr     L7_CD7A
        lda     #$00
        sta     $0560
        lda     #$16
        cpy     #$0A
        bcc     L7_F3E7
        lda     #$01
        cpy     #$16
        bcs     L7_F3D0
        lda     $F465,Y
        jmp     L7_F3E7
L7_F3D0:
        cpy     #$46
        bcs     L7_F3E7
        tya
        sec
        sbc     #$0A
        tay
        lda     #$0C
        jsr     L7_F9AE
        lda     $F487,Y
        sta     $0560
        lda     $F47B,Y
L7_F3E7:
        sta     $0548
        lda     $0638
        cmp     #$40
        bcc     L7_F3F6
        lda     #$20
        sta     $0788
L7_F3F6:
        lda     $0788
        jsr     L7_CD12

; ---- bank7.code_F3FC (code) $F3FC-$F438, 61 bytes
L7_F3FC:
        jsr     L7_CBE8
        php
        bcs     L7_F420
        lda     #$00
        sta     $86
        lda     $0548
        cmp     #$0E
        bcs     L7_F420
        lda     $05D8
        bpl     L7_F420
        lda     $41
        and     #$02
        clc
        adc     #$32
        sta     $87
        lda     #$1D
        jsr     L7_CC34
L7_F420:
        inc     $41
        jsr     L7_CE88
        plp
        bcs     L7_F439
        jsr     L7_F493
        lda     $F7
        and     #$20
        bne     L7_F439
        ldy     #$01
        jsr     L7_FFD1
        jmp     L7_F33E

; ---- bank7.code_F439 (code) $F439-$F457, 31 bytes
L7_F439:
        jsr     L7_EDD1
L7_F43C:
        jsr     L7_D755
        lda     $30
        ldy     $0680
        bne     L7_F458
        and     #$F7
        sta     $30
        ldy     #$14
        jsr     L7_FFD1
        jsr     L7_D4E3
L7_F452:
        jsr     L7_F717
        jmp     L7_F705

; ---- bank7.code_F458 (code) $F458-$F46E, 23 bytes
L7_F458:
        and     #$E7
        sta     $30
        ldy     #$00
        sty     $06E0
        sty     $06F8
        and     #$02
        bne     L7_F46E
        jsr     L7_F6F5
        jmp     L7_F717
L7_F46E:
        rts

; ---- bank7.tbl_F46F (data) $F46F-$F47A, 12 bytes
; Table, 12 bytes (structural extent)
        .byte   $16,$15,$14,$13,$12,$11,$10,$0F,$0E,$04,$03,$02

; ---- bank7.tbl_F47B (data) $F47B-$F486, 12 bytes
; Table, 12 bytes
        .byte   $01,$02,$03,$04,$05,$06,$07,$06,$05,$04,$03,$02

; ---- bank7.tbl_F487 (data) $F487-$F492, 12 bytes
; Table, 12 bytes (structural extent)
        .byte   $00,$40,$40,$40,$40,$40,$40,$00,$00,$00,$00,$00

; ---- bank7.code_F493 (code) $F493-$F49C, 10 bytes
L7_F493:
        jsr     L7_D64C
        lda     $30
        bmi     L7_F49D
        jmp     L7_E4B3

; ---- bank7.code_F49D (code) $F49D-$F4A6, 10 bytes
L7_F49D:
        lda     $F5
        and     #$10
        beq     L7_F4A6
        jmp     L7_FF4A
L7_F4A6:
        rts

; ---- bank7.code_F4A7 (code) $F4A7-$F4B6, 16 bytes
L7_F4A7:
        ldy     $51
        beq     L7_F4B6
        cpy     #$0B
        bcc     L7_F4B3
        lda     #$00
        beq     L7_F4B6
L7_F4B3:
        lda     $F6DA,Y
L7_F4B6:
        rts

; ---- bank7.code_F4B7 (code) $F4B7-$F505, 79 bytes
L7_F4B7:
        lda     #$81
        sta     $0500
        lda     #$02
        sta     $07E8
        lda     #$03
        sta     $0620
        lda     #$F0
        sta     $05F0
        lda     #$50
        sta     $0548
        lda     #$00
        sta     $0608
        sta     $05C0
        sta     $06C8
        lda     #$FB
        sta     $05D8
        sta     $0668
        lda     #$20
        sta     $0560
        lda     #$70
        sta     $0530
        lda     #$C8
        sta     $0518
        jsr     L7_D762
L7_F4F5:
        ldy     #$01
        jsr     L7_FFD1
        jsr     L7_F493
        jsr     L6_8000
        lda     $07E8
        bne     L7_F4F5
        rts

; ---- bank7.code_F506 (code) $F506-$F512, 13 bytes
L7_F506:
        lda     #$17
        ldy     $51
        beq     L7_F513
        cpy     #$16
        beq     L7_F513
        jsr     L7_D852

; ---- bank7.code_F513 (code) $F513-$F535, 35 bytes
L7_F513:
        jsr     L7_D762
        lda     $60
        and     #$FC
        sta     $60
        lda     $A0
        and     #$FE
        sta     $A0
L7_F522:
        lda     #$00
        sta     $BA
        sta     $BB
        jsr     L7_E66A
        ldy     #$01
        jsr     L7_FF8B
        lda     $B8
        ora     $B9
        bne     L7_F522

; ---- bank7.code_F536 (code) $F536-$F546, 17 bytes
        jsr     L7_EA68
        lda     $30
        and     #$02
        bne     L7_F544
        jsr     L7_F4A7
        bne     L7_F547
L7_F544:
        jmp     L7_F5DE

; ---- bank7.code_F547 (code) $F547-$F565, 31 bytes
L7_F547:
        tay
        lda     $EFD7,Y
        ora     $04B0
        sta     $04B0
        lda     #$36
        jsr     L7_D852
        lda     #$15
        sta     $19
        lda     #$C0
        sta     $18
        ldy     $51
        lda     $F6DA,Y
        jsr     L7_D76F

; ---- bank7.inline_F566 (data) $F566-$F568, 3 bytes
; Far-call argument at $F566
        .byte   $02,$05,$80

; ---- bank7.code_F569 (code) $F569-$F59D, 53 bytes
        lda     #$30
        sta     $1B
        lda     #$40
        sta     $1A
L7_F571:
        lda     $1B
        sta     $19
        lda     $1A
        sta     $18
        lda     #$20
        sta     $16
        lda     #$00
        sta     $17
        jsr     L7_FAB7
        lda     $1B
        clc
        adc     #$10
        cmp     #$D0
        bcc     L7_F599
        lda     $1A
        adc     #$0F
        sta     $1A
        cmp     #$70
        bcs     L7_F59E
        lda     #$30
L7_F599:
        sta     $1B
        jmp     L7_F571

; ---- bank7.code_F59E (code) $F59E-$F5B0, 19 bytes
L7_F59E:
        lda     #$B0
        sta     $19
        lda     #$50
        sta     $18
        lda     #$5C
        sta     $16
        lda     #$00
        sta     $17
        jsr     L7_FAB7

; ---- bank7.code_F5B1 (code) $F5B1-$F5CB, 27 bytes
        lda     #$40
        sta     $19
        lda     #$50
        clc
        adc     $A6
        bcs     L7_F5C0
        cmp     #$F0
        bcc     L7_F5C2
L7_F5C0:
        sbc     #$F0
L7_F5C2:
        and     #$F0
        sta     $18
        jsr     L7_FA6B
        jsr     L7_D53F

; ---- bank7.inline_F5CC (text) $F5CC-$F5D8, 13 bytes
; " YOU GOT KEY" at $F5CC
        .byte   $0C,$20,$59,$4F,$55,$20,$47,$4F,$54,$20,$4B,$45,$59

; ---- bank7.code_F5D9 (code) $F5D9-$F5DD, 5 bytes
        ldy     #$28
        jsr     L7_FF8B

; ---- bank7.code_F5DE (code) $F5DE-$F611, 52 bytes
L7_F5DE:
        lda     #$05
        sta     $0500
        lda     #$01
        sta     $0548
        lda     #$00
        sta     $0560
        sta     $06C8
        sta     $0638
        sta     $05C0
        lda     $51
        beq     L7_F600
        cmp     #$16
        bne     L7_F605
        lda     #$00
L7_F600:
        inc     $0638
        bne     L7_F607
L7_F605:
        lda     #$FE
L7_F607:
        sta     $05D8
        sta     $0668
        lda     #$05
        sta     $0620

; ---- bank7.code_F612 (code) $F612-$F647, 54 bytes
L7_F612:
        ldy     #$01
        jsr     L7_FF8B
        jsr     L7_F493
        jsr     L7_CDB4
        ldx     #$00
        lda     $0638
        bne     L7_F648
        lda     $0518
        cmp     #$20
        bcs     L7_F630
        lda     #$0C
        jsr     L7_CD12
L7_F630:
        jsr     L7_CBE8
        bcs     L7_F638
        jmp     L7_F6C3
L7_F638:
        inc     $0638
        lda     #$00
        sta     $0518
        sta     $05C0
        sta     $05D8
        bne     L7_F6C3

; ---- bank7.code_F648 (code) $F648-$F654, 13 bytes
L7_F648:
        lda     #$20
        jsr     L7_CD12
        jsr     L7_CBE8
        bcc     L7_F6C3
        jsr     L7_CE88

; ---- bank7.code_F655 (code) $F655-$F666, 18 bytes
        lda     $51
        bne     L7_F667
L7_F659:
        lda     #$01
        sta     $0680
        jsr     L7_EDD1
        jsr     L7_D4E3
        jmp     L7_F43C

; ---- bank7.code_F667 (code) $F667-$F686, 32 bytes
L7_F667:
        cmp     #$16
        bne     L7_F6B2
        jsr     L7_EDD1
        jsr     L7_D534
        jsr     L7_D4E3
        lda     #$1F
        jsr     L7_D852
        jsr     L7_D4FD
        lda     #$20
        jsr     L7_E445
        jsr     L7_D7C3
        jsr     L7_D576

; ---- bank7.inline_F687 (text) $F687-$F699, 19 bytes
; "YOUR FINAL SCORE" at $F687
        .byte   $10,$20,$86,$59,$4F,$55,$52,$20,$46,$49,$4E,$41,$4C,$20,$53,$43
        .byte   $4F,$52,$45

; ---- bank7.code_F69A (code) $F69A-$F69C, 3 bytes
        jsr     L7_D576

; ---- bank7.inline_F69D (text) $F69D-$F6A0, 4 bytes
; "0" at $F69D
        .byte   $01,$20,$CE,$30

; ---- bank7.code_F6A1 (code) $F6A1-$F6AE, 14 bytes
        lda     #$20
        sta     $19
        lda     #$C8
        sta     $18
        jsr     L7_E118
        jsr     L7_D76F

; ---- bank7.inline_F6AF (data) $F6AF-$F6B1, 3 bytes
; Far-call argument at $F6AF
        .byte   $02,$20,$80

; ---- bank7.code_F6B2 (code) $F6B2-$F6C2, 17 bytes
L7_F6B2:
        lda     $30
        and     #$02
        bne     L7_F659
        jsr     L7_EDD1
        jsr     L7_D755
        lda     #$01
        jmp     L7_F2BB

; ---- bank7.code_F6C3 (code) $F6C3-$F6DA, 24 bytes
L7_F6C3:
        inc     $0788
        lda     $0788
        and     #$02
        clc
        adc     #$32
        sta     $87
        lda     #$1D
        jsr     L7_CC34
        jsr     L7_CE88
        jmp     L7_F612

; ---- bank7.tbl_F6DB (data) $F6DB-$F6E4, 10 bytes
; Key awarded by corridors 1-10
        .byte   $01,$02,$03,$04,$00,$05,$00,$06,$07,$00

; ---- bank7.code_F6E5 (code) $F6E5-$F6F4, 16 bytes
L7_F6E5:
        lda     #$00
        sta     $19
        sta     $18
        lda     #$05
        ldy     #$02
        jsr     L7_D7F9
        jmp     L7_D7C3

; ---- bank7.code_F6F5 (code) $F6F5-$F704, 16 bytes
L7_F6F5:
        lda     #$00
        sta     $19
        sta     $18
        lda     #$04
        ldy     #$02
        jsr     L7_D7F9
        jmp     L7_D7C3

; ---- bank7.code_F705 (code) $F705-$F716, 18 bytes
L7_F705:
        lda     #$07
        sta     $19
        lda     #$40
        sta     $18
        lda     #$0C
        ldy     #$02
        jsr     L7_D7F9
        jmp     L7_D7C3

; ---- bank7.code_F717 (code) $F717-$F771, 91 bytes
L7_F717:
        lda     #$06
        sta     $19
        lda     #$80
        sta     $18
        lda     #$06
        ldy     #$02
        jsr     L7_D7F9
L7_F726:
        lda     #$07
        sta     $19
        lda     #$60
        sta     $18
        ldy     $3C
        lda     $F77F,Y
        beq     L7_F74C
        bmi     L7_F745
        cmp     $3D
        lda     #$07
        bcs     L7_F76A
        lda     #$80
        sta     $18
        lda     #$0A
        bcc     L7_F76A
L7_F745:
        ldy     $3D
        lda     $F78B,Y
        bne     L7_F76A
L7_F74C:
        lda     $F772,Y
        beq     L7_F76F
        cpy     #$05
        bne     L7_F76A
        lda     #$80
        sta     $18
        ldy     #$02
        lda     #$0A
        jsr     L7_D7F9
        lda     #$07
        sta     $19
        lda     #$60
        sta     $18
        lda     #$08
L7_F76A:
        ldy     #$02
        jsr     L7_D7F9
L7_F76F:
        jmp     L7_D7C3

; ---- bank7.tbl_F772 (data) $F772-$F77E, 13 bytes
; Table, 13 bytes
        .byte   $00,$07,$0B,$0B,$07,$08,$07,$07,$07,$1E,$07,$07,$00

; ---- bank7.tbl_F77F (data) $F77F-$F78A, 12 bytes
; Table, 12 bytes
        .byte   $00,$02,$00,$00,$02,$00,$01,$00,$02,$FF,$00,$00

; ---- bank7.tbl_F78B (data) $F78B-$F78E, 4 bytes
; Table, 4 bytes (structural extent)
        .byte   $00,$1E,$1F,$20

; ---- bank7.code_F78F (code) $F78F-$F793, 5 bytes
L7_F78F:
        lda     $7F
        jsr     L7_D705

; ---- bank7.code_F794 (code) $F794-$F7B2, 31 bytes
        lda     $60
        and     #$02
        beq     L7_F7B0
        bit     $30
        bvc     L7_F7AC
        lda     $B8
        ora     $B9
        beq     L7_F7AC
        lda     $A0
        and     #$04
        bne     L7_F7B3
        beq     L7_F7B0
L7_F7AC:
        dec     $69
        beq     L7_F7B3
L7_F7B0:
        jmp     L7_F85C

; ---- bank7.code_F7B3 (code) $F7B3-$F7C5, 19 bytes
L7_F7B3:
        lda     #$3C
        sta     $69
        ldy     #$00
        dec     $68
        bne     L7_F7B0
L7_F7BD:
        lda     ($66),Y
        iny
        sty     $15
        cmp     #$03
        bcs     L7_F7F4

; ---- bank7.code_F7C6 (code) $F7C6-$F7C8, 3 bytes
        jsr     L7_D6AE

; ---- bank7.tbl_F7C9 (pointer_table) $F7C9-$F7CE, 6 bytes
; Spawn-script commands: 3 entries
        .byte   $CE,$F7,$D8,$F7,$EA,$F7

; ---- bank7.code_F7CF (code) $F7CF-$F7D8, 10 bytes
L7_F7CF:
        ldy     $15
        lda     ($66),Y
        sta     $68
        iny
        jmp     L7_F852

; ---- bank7.code_F7D9 (code) $F7D9-$F7EA, 18 bytes
L7_F7D9:
        ldy     $15
        lda     ($66),Y
        pha
        iny
        lda     ($66),Y
        sta     $67
        pla
        sta     $66
        ldy     #$00
        jmp     L7_F7BD

; ---- bank7.code_F7EB (code) $F7EB-$F7F3, 9 bytes
L7_F7EB:
        lda     $60
        and     #$FD
        sta     $60
        jmp     L7_F85C

; ---- bank7.code_F7F4 (code) $F7F4-$F804, 17 bytes
L7_F7F4:
        sta     $16
        lda     $60
        and     #$08
        beq     L7_F805
L7_F7FC:
        lda     $16
        bpl     L7_F843
        iny
        iny
        jmp     L7_F843

; ---- bank7.code_F805 (code) $F805-$F81B, 23 bytes
L7_F805:
        sty     $15
        lda     $16
        bmi     L7_F819
        jsr     L7_D762
        jsr     L7_FA5B
        lda     $7F
        jsr     L7_D705
        jmp     L7_F81C
L7_F819:
        jsr     L7_EA8C

; ---- bank7.code_F81C (code) $F81C-$F842, 39 bytes
L7_F81C:
        sty     $17
        ldy     $15
        bcs     L7_F7FC
        ldx     $17
        lda     $16
        bmi     L7_F82D
        sta     $0500,X
        bpl     L7_F843
L7_F82D:
        and     #$7F
        sta     $0548,X
        lda     ($66),Y
        iny
        sta     $0560,X
        lda     ($66),Y
        iny
        sta     $07A0,X
        lda     #$29
        sta     $0500,X

; ---- bank7.code_F843 (code) $F843-$F851, 15 bytes
L7_F843:
        lda     ($66),Y
        php
        iny
        plp
        bmi     L7_F7F4
        sta     $68
        bne     L7_F852
        iny
        jmp     L7_F7BD

; ---- bank7.code_F852 (code) $F852-$F85C, 11 bytes
L7_F852:
        tya
        clc
        adc     $66
        sta     $66
        bcc     L7_F85C
        inc     $67
L7_F85C:
        rts

; ---- bank7.code_F85D (code) $F85D-$F862, 6 bytes
L7_F85D:
        jsr     L7_F863
        jmp     L7_F8CE

; ---- bank7.code_F863 (code) $F863-$F885, 35 bytes
L7_F863:
        ldy     #$00
L7_F865:
        lda     #$00
        sta     $38
        lda     $0518,Y
        sec
        sbc     $0518,X
        sta     $10
        bcs     L7_F882
        lda     $38
        ora     #$04
        sta     $38
        lda     $10
        eor     #$FF
        adc     #$01
        sta     $10
L7_F882:
        bne     L7_F886
        inc     $10

; ---- bank7.code_F886 (code) $F886-$F8A2, 29 bytes
L7_F886:
        lda     $0530,Y
        sec
        sbc     $0530,X
        sta     $11
        bcs     L7_F89F
        lda     $38
        ora     #$08
        sta     $38
        lda     $11
        eor     #$FF
        adc     #$01
        sta     $11
L7_F89F:
        bne     L7_F8A3
        inc     $11

; ---- bank7.code_F8A3 (code) $F8A3-$F8B4, 18 bytes
L7_F8A3:
        lda     $11
        cmp     $10
        bcc     L7_F8B5
        ldy     $10
        sty     $11
        sta     $10
        lda     $38
        ora     #$10
        sta     $38

; ---- bank7.code_F8B5 (code) $F8B5-$F8CD, 25 bytes
L7_F8B5:
        ldy     $11
        lda     $10
        jsr     L7_F9B6
        ldy     #$03
L7_F8BE:
        cmp     $F95A,Y
        bcc     L7_F8C6
        dey
        bne     L7_F8BE
L7_F8C6:
        tya
        ora     $38
        tay
        lda     $F95E,Y
        rts

; ---- bank7.code_F8CE (code) $F8CE-$F8EB, 30 bytes
L7_F8CE:
        and     #$0F
        sty     $38
        asl     A
        tay
        lda     #$00
        sta     $10
        sta     $11
        lda     $F986,Y
        sta     $12
        bpl     L7_F8E3
        dec     $10
L7_F8E3:
        lda     $F98E,Y
        sta     $13
        bpl     L7_F8EC
        dec     $11

; ---- bank7.code_F8EC (code) $F8EC-$F91C, 49 bytes
L7_F8EC:
        lda     $0698,X
        bpl     L7_F909
        asl     $12
        rol     $10
        asl     $12
        rol     $10
        asl     $12
        rol     $10
        asl     $13
        rol     $11
        asl     $13
        rol     $11
        asl     $13
        rol     $11
L7_F909:
        and     #$40
        beq     L7_F91D
        asl     $12
        rol     $10
        asl     $12
        rol     $10
        asl     $13
        rol     $11
        asl     $13
        rol     $11

; ---- bank7.code_F91D (code) $F91D-$F957, 59 bytes
L7_F91D:
        lda     $0698,X
        and     #$3F
        beq     L7_F958
        tay
        lda     #$00
        sta     $05C0,X
        sta     $05D8,X
        sta     $05F0,X
        sta     $0608,X
L7_F933:
        lda     $12
        clc
        adc     $05C0,X
        sta     $05C0,X
        lda     $10
        adc     $05D8,X
        sta     $05D8,X
        lda     $13
        clc
        adc     $05F0,X
        sta     $05F0,X
        lda     $11
        adc     $0608,X
        sta     $0608,X
        dey
        bne     L7_F933

; ---- bank7.code_F958 (code) $F958-$F95A, 3 bytes
L7_F958:
        ldy     $38
        rts

; ---- bank7.tbl_F95B (data) $F95B-$F95D, 3 bytes
; Aiming thresholds
        .byte   $AB,$6A,$32

; ---- bank7.tbl_F95E (data) $F95E-$F97D, 32 bytes
; Aiming: direction by flags and angle step
        .byte   $02,$03,$03,$04,$0E,$0D,$0D,$0C,$06,$05,$05,$04,$0A,$0B,$0B,$0C
        .byte   $02,$01,$01,$00,$0E,$0F,$0F,$00,$06,$07,$07,$08,$0A,$09,$09,$08

; ---- bank7.code_F97E (code) $F97E-$F981, 4 bytes
L7_F97E:
        lda     $F986,Y
        rts

; ---- bank7.code_F982 (code) $F982-$F985, 4 bytes
L7_F982:
        lda     $F98E,Y
        rts

; ---- bank7.tbl_F986 (data) $F986-$F9AD, 40 bytes
; Sine table: 120 x sin(11.25 degrees x k), k = 0-39
        .byte   $00,$17,$2D,$42,$54,$63,$6E,$75,$78,$75,$6E,$63,$54,$42,$2D,$17
        .byte   $00,$E9,$D3,$BE,$AC,$9D,$92,$8B,$88,$8B,$92,$9D,$AC,$BE,$D3,$E9
        .byte   $00,$17,$2D,$42,$54,$63,$6E,$75

; ---- bank7.code_F9AE (code) $F9AE-$F9B5, 8 bytes
L7_F9AE:
        sta     $10
        sty     $11
        lda     #$00
        beq     L7_F9BD

; ---- bank7.code_F9B6 (code) $F9B6-$F9BC, 7 bytes
L7_F9B6:
        sta     $10
        lda     #$00
L7_F9BA:
        sta     $11
        tya

; ---- bank7.code_F9BD (code) $F9BD-$F9D0, 20 bytes
L7_F9BD:
        ldy     #$08
L7_F9BF:
        asl     $11
        rol     A
        cmp     $10
        bcc     L7_F9CA
        sbc     $10
        inc     $11
L7_F9CA:
        dey
        bne     L7_F9BF
        tay
        lda     $11
        rts

; ---- bank7.code_F9D1 (code) $F9D1-$F9E8, 24 bytes
L7_F9D1:
        stx     $10
        rol     A
        adc     $2A
        eor     $8000,X
        adc     $0400,Y
        tsx
        eor     $0200,X
        ldx     $10
        adc     $2A
        sbc     $41
        sta     $2A
        rts

; ---- bank7.code_F9E9 (code) $F9E9-$FA16, 46 bytes
L7_F9E9:
        jsr     L7_F9D1
        sty     $10
        sta     $11
        cmp     #$20
        bcc     L7_F9F8
        cmp     #$E0
        bcc     L7_FA05
L7_F9F8:
        and     #$3F
        asl     A
        sta     $12
        lda     $11
        and     #$1F
        adc     #$20
        adc     $12
L7_FA05:
        sta     $0530,X
        ror     A
        tay
        adc     a:$0000,y
        sta     $2A
        lda     #$08
        sta     $0518,X
        ldy     $10
        rts

; ---- bank7.code_FA17 (code) $FA17-$FA4A, 52 bytes
L7_FA17:
        jsr     L7_F9E9
        ldy     $2A
        lda     $0200,Y
        adc     $2A
        rol     A
        sta     $11
        lda     $0530,X
        adc     $2A
        sta     $12
        lda     $11
        and     #$7F
        sta     $13
        lda     $12
        and     #$3F
        adc     $13
        adc     #$28
        cmp     #$B8
        bcc     L7_FA3F
        sbc     #$90
L7_FA3F:
        sta     $0518,X
        tay
        adc     $12
        adc     $0200,Y
        sta     $2A
        rts

; ---- bank7.code_FA4B (code) $FA4B-$FA5A, 16 bytes
L7_FA4B:
        sta     $0500,Y
        lda     $0530,X
        sta     $0530,Y
        lda     $0518,X
        sta     $0518,Y
        rts

; ---- bank7.code_FA5B (code) $FA5B-$FA6A, 16 bytes
L7_FA5B:
        ldy     #$05
L7_FA5D:
        lda     $0500,Y
        beq     L7_FA69
        iny
        cpy     #$18
        bne     L7_FA5D
        sec
        rts
L7_FA69:
        clc
        rts

; ---- bank7.code_FA6B (code) $FA6B-$FA95, 43 bytes
L7_FA6B:
        lda     $19
        lsr     A
        lsr     A
        lsr     A
        sta     $10
        lsr     A
        lsr     A
        sta     $11
        lda     #$08
        sta     $19
        lda     $18
        sta     $12
        and     #$F8
        asl     A
        rol     $19
        asl     A
        rol     $19
        ora     $10
        sta     $18
        lda     $12
        and     #$E0
        lsr     A
        lsr     A
        ora     $11
        ora     #$C0
        tay
        rts

; ---- bank7.code_FA96 (code) $FA96-$FB11, 124 bytes
L7_FA96:
        jsr     L7_FA5B
        bcs     L7_FAB7
        lda     $19
        and     #$F0
        ora     #$08
        sta     $0530,Y
        lda     $18
        and     #$F0
        ora     #$07
        sta     $0518,Y
        lda     #$00
        sta     $0740,Y
        lda     #$30
        sta     $0500,Y
L7_FAB7:
        lda     $19
        pha
        and     #$F0
        sta     $19
        lda     $18
        pha
        clc
        adc     $A6
        bcs     L7_FACA
        cmp     #$F0
        bcc     L7_FACC
L7_FACA:
        sbc     #$F0
L7_FACC:
        and     #$F0
        sta     $18
        jsr     L7_FA6B
        lda     $16
        jsr     L7_D865
        pla
        sta     $18
        pla
        sta     $19
L7_FADE:
        bit     $30
        bvs     L7_FB11
        lda     $18
        and     #$F0
        lsr     A
        sta     $10
        lda     $19
        lsr     A
        lsr     A
        lsr     A
        lsr     A
        lsr     A
        ora     $10
        tay
        bcs     L7_FB07
        lda     $15
        asl     A
        asl     A
        asl     A
        asl     A
        sta     $10
        lda     $0400,Y
        and     #$0F
        ora     $10
        jmp     L7_FB0E
L7_FB07:
        lda     $0400,Y
        and     #$F0
        ora     $15
L7_FB0E:
        sta     $0400,Y
L7_FB11:
        rts

; ---- bank7.code_FB12 (code) $FB12-$FB51, 64 bytes
L7_FB12:
        jsr     L7_FA5B
        bcs     L7_FB51
        lda     #$08
        sta     $0500,Y
        lda     #$00
        sta     $0740,Y
        lda     $14
        lsr     A
        sta     $0518,Y
        jsr     L7_F9D1
        sta     $10
        and     $14
        adc     $18
        sbc     $0518,Y
        sta     $0518,Y
        lda     $15
        lsr     A
        sta     $0530,Y
        lda     $10
        ror     A
        ror     A
        ror     A
        ror     A
        and     $15
        adc     $19
        sbc     $0530,Y
        sta     $0530,Y
        lda     #$22
        jsr     L7_D852
L7_FB51:
        rts

; ---- bank7.code_FB52 (code) $FB52-$FB63, 18 bytes
L7_FB52:
        lda     #$00
        sec
        sbc     $05C0,X
        sta     $05C0,X
        lda     #$00
        sbc     $05D8,X
        sta     $05D8,X
        rts

; ---- bank7.code_FB64 (code) $FB64-$FB75, 18 bytes
L7_FB64:
        lda     #$00
        sec
        sbc     $05F0,X
        sta     $05F0,X
        lda     #$00
        sbc     $0608,X
        sta     $0608,X
        rts

; ---- bank7.code_FB76 (code) $FB76-$FC26, 177 bytes
L7_FB76:
        ldy     $0668,X
        bmi     L7_FB85
        lda     $0500,Y
        cmp     $0680,X
        beq     L7_FB85
        sec
        rts
L7_FB85:
        lda     $0788,X
        cmp     $0620,X
        bcs     L7_FB93
        lda     $0530,Y
        sta     $0530,X
L7_FB93:
        lda     $0788,X
        bne     L7_FBD2
        lda     $0518,X
        jsr     L7_FCC3
        bcc     L7_FBAD
        jsr     L7_FCCD
        sta     $0518,X
        lda     #$02
        sta     $0788,X
        bne     L7_FBFE
L7_FBAD:
        sta     $0518,X
        sec
        bmi     L7_FBBD
        sbc     $0758,X
L7_FBB6:
        cmp     $0638,X
        bcc     L7_FC27
        bcs     L7_FBC5
L7_FBBD:
        lda     $0758,X
        sbc     $0518,X
        bcs     L7_FBB6
L7_FBC5:
        inc     $0788,X
        lda     $0518,X
        ldy     $05D8,X
        clc
        jmp     L7_FBEC
L7_FBD2:
        cmp     #$01
        bne     L7_FBFE
        lda     $0518,X
        jsr     L7_FCC3
        bcc     L7_FBE9
        jsr     L7_FCCD
        sta     $0518,X
        inc     $0788,X
        bne     L7_FBFE
L7_FBE9:
        sta     $0518,X
L7_FBEC:
        bmi     L7_FBF4
        sec
        sbc     $0638,X
        bcs     L7_FBF7
L7_FBF4:
        adc     $0638,X
L7_FBF7:
        sta     $0758,X
        jmp     L7_FC27
L7_FBFD:
        rts
L7_FBFE:
        lda     $0758,X
        jsr     L7_FCC3
        bcs     L7_FBFD
        sta     $0758,X
        lda     $0518,X
        jsr     L7_FCC3
        bcc     L7_FC24
        jsr     L7_FCCD
        cmp     $0758,X
        beq     L7_FC24
        ldy     $05D8,X
        bmi     L7_FC22
        bcs     L7_FC24
        sec
        rts
L7_FC22:
        bcs     L7_FBFD
L7_FC24:
        sta     $0518,X

; ---- bank7.code_FC27 (code) $FC27-$FCC2, 156 bytes
L7_FC27:
        lda     #$10
        sta     $17
        lda     $0758,X
        sta     $16
        ldy     $0518,X
        sty     $84
        cmp     $0518,X
        bcs     L7_FC44
        lda     #$F0
        sta     $17
        lda     $0518,X
        ldy     $0758,X
L7_FC44:
        clc
        adc     #$0F
        sta     $0728,X
        tya
        sta     $0710,X
        lda     $0530,X
        ldy     $0548,X
        beq     L7_FC68
        sta     $85
        lda     $84
        clc
        adc     #$08
        sta     $84
        lda     $16
        adc     #$08
        sta     $16
        jmp     L7_FC70
L7_FC68:
        lda     $0530,X
        sec
        sbc     #$04
        sta     $85
L7_FC70:
        lda     $0560,X
        sta     $86
        lda     $06C8,X
        sta     $87
L7_FC7A:
        lda     $0548,X
        bne     L7_FC85
        jsr     L7_CF05
        jmp     L7_FC88
L7_FC85:
        jsr     L7_CC34
L7_FC88:
        clc
        lda     $17
        bmi     L7_FC9B
        adc     $84
        sta     $84
        bcs     L7_FCA5
        cmp     $16
        bcc     L7_FC7A
        beq     L7_FC7A
        bcs     L7_FCA5
L7_FC9B:
        adc     $84
        sta     $84
        bcc     L7_FCA5
        cmp     $16
        bcs     L7_FC7A
L7_FCA5:
        lda     $0530,X
        sec
        sbc     $0650,X
        bcs     L7_FCB0
        lda     #$00
L7_FCB0:
        sta     $06E0,X
        lda     $0530,X
        clc
        adc     $0650,X
        bcc     L7_FCBE
        lda     #$FF
L7_FCBE:
        sta     $06F8,X
        clc
        rts

; ---- bank7.code_FCC3 (code) $FCC3-$FCD4, 18 bytes
L7_FCC3:
        clc
        adc     $05D8,X
        cmp     #$D0
        ldy     $05D8,X
        rts
L7_FCCD:
        bmi     L7_FCD2
        sbc     #$10
        rts
L7_FCD2:
        adc     #$0F
        rts

; ---- bank7.code_FCD5 (code) $FCD5-$FCE6, 18 bytes
L7_FCD5:
        lda     $B7
        clc
        bit     $30
        bvc     L7_FCE6
        adc     $0518,X
        sta     $0518,X
        bcs     L7_FCE6
        cmp     #$D0
L7_FCE6:
        rts

; ---- bank7.code_FCE7 (code) $FCE7-$FD4A, 100 bytes
L7_FCE7:
        clc
        adc     $4C
        sta     $4C
        bcc     L7_FCF2
        inc     $4D
        beq     L7_FCFD
L7_FCF2:
        sec
        lda     $4E
        sbc     $4C
        lda     $4F
        sbc     $4D
        bcs     L7_FD05
L7_FCFD:
        lda     $4E
        sta     $4C
        lda     $4F
        sta     $4D
L7_FD05:
        jsr     L7_FD77
        jsr     L7_E1C3
        jmp     L7_E213
L7_FD0E:
        ldy     $4A
        cpy     #$04
        bcc     L7_FD16
        ldy     #$04
L7_FD16:
        sty     $4A
        lda     $FD4A,Y
        sta     $05A8
        ldy     $4B
        bne     L7_FD2B
        lda     #$40
        sta     $05A8
        ldy     #$20
        bne     L7_FD33
L7_FD2B:
        cpy     #$07
        bcc     L7_FD31
        ldy     #$07
L7_FD31:
        sty     $4B
L7_FD33:
        sty     $0590
        lda     #$00
        cpy     #$05
        bcc     L7_FD3E
        lda     #$02
L7_FD3E:
        tay
        bit     $30
        bvc     L7_FD44
        iny
L7_FD44:
        lda     $FD4F,Y
        sta     $0698
        rts

; ---- bank7.tbl_FD4B (data) $FD4B-$FD52, 8 bytes
; Player attack by attack level, and a value by mode
        .byte   $01,$02,$03,$05,$03,$05,$41,$06

; ---- bank7.code_FD53 (code) $FD53-$FDC9, 119 bytes
L7_FD53:
        lda     $0788,X
        bne     L7_FD59
L7_FD58:
        rts
L7_FD59:
        pla
        pla
        dec     $0788,X
        lda     $0788,X
        lsr     A
        bcc     L7_FD58
        jmp     L7_CBFC
L7_FD67:
        clc
        adc     $48
        bcc     L7_FD6E
        lda     #$FF
L7_FD6E:
        cmp     $47
        bcc     L7_FD74
        lda     $47
L7_FD74:
        sta     $48
        rts
L7_FD77:
        lda     #$00
        sta     $45
        lda     $3C
        beq     L7_FD85
        sec
        sbc     #$01
        jsr     L7_E498
L7_FD85:
        sta     $3D
        ldy     $3C
        lda     $FDCA,Y
        sta     $3B
        tya
        beq     L7_FDC7
        lda     $3D
        beq     L7_FDC7
        lda     $04AF
        cpy     #$0C
        beq     L7_FDC7
        tya
        sta     $10
        asl     A
        adc     $10
        adc     $3D
        tay
        lda     $FDD3,Y
        sta     $45
L7_FDAA:
        sta     $10
        lda     #$FF
        ldy     $4D
        cpy     $45
        bcs     L7_FDC7
        bit     $10
        bpl     L7_FDC2
        tya
        lsr     A
        tay
        lda     $4C
        ror     A
        lsr     $10
        bcc     L7_FDC4
L7_FDC2:
        lda     $4C
L7_FDC4:
        jsr     L7_F9BA
L7_FDC7:
        sta     $3E
        rts

; ---- bank7.tbl_FDCA (data) $FDCA-$FDD6, 13 bytes
; Per-selection value copied to $3B
        .byte   $04,$03,$02,$03,$03,$03,$03,$02,$03,$03,$03,$02,$03

; ---- bank7.tbl_FDD7 (data) $FDD7-$FDF7, 33 bytes
; Use-chip cost: 11 weapons x 3 levels
        .byte   $01,$03,$0A,$01,$05,$28,$03,$07,$14,$03,$06,$1E,$02,$05,$14,$04
        .byte   $0C,$1E,$01,$08,$78,$03,$0A,$1E,$04,$06,$1E,$04,$08,$1E,$05,$0A
        .byte   $23

; ---- bank7.code_FDF8 (code) $FDF8-$FE21, 42 bytes
L7_FDF8:
        stx     $10
        tax
        lda     $FE22,X
        sta     $0548,Y
        lda     $FE23,X
        sta     $0638,Y
        lda     $FE24,X
        sta     $0650,Y
        lda     #$00
        sta     $0620,Y
        sta     $0560,Y
        lda     #$FF
        sta     $0590,Y
        lda     #$01
        sta     $05A8,Y
        ldx     $10
        rts

; ---- bank7.tbl_FE22 (data) $FE22-$FE3C, 27 bytes
; Beam style records: 9 x [metasprite][`$0638`][half-width]
        .byte   $00,$40,$03,$1A,$60,$08,$17,$F0,$18,$00,$20,$02,$00,$40,$02,$00
        .byte   $60,$02,$1A,$F0,$08,$00,$F0,$08,$00,$10,$08

; ---- bank7.code_FE3D (code) $FE3D-$FE56, 26 bytes
L7_FE3D:
        lda     #$22
        jsr     L7_FA4B
        lda     $17
        sta     $06C8,Y
        lda     $16
        sta     $05D8,Y
        txa
        sta     $0668,Y
        lda     $0500,X
        sta     $0680,Y
        rts

; ---- bank7.code_FE57 (code) $FE57-$FE62, 12 bytes
L7_FE57:
        lda     $0518,X
        sta     $0758,X
        lda     #$00
        sta     $0788,X
        rts

; ---- bank7.code_FE63 (code) $FE63-$FE78, 22 bytes
L7_FE63:
        clc
        ldy     $0680,X
        beq     L7_FE78
        dec     $0668,X
        bne     L7_FE78
        sta     $0668,X
        jsr     L7_F85D
        dec     $0680,X
        sec
L7_FE78:
        rts

; ---- bank7.code_FE79 (code) $FE79-$FE87, 15 bytes
L7_FE79:
        lda     #$00
        sta     $05C0,X
        sta     $05D8,X
        sta     $05F0,X
        sta     $0608,X
        rts

; ---- bank7.code_FE88 (code) $FE88-$FE95, 14 bytes
L7_FE88:
        lda     $50
        beq     L7_FE96
        clc
        adc     #$01
        lsr     A
        cmp     #$03
        beq     L7_FEB0
        bcs     L7_FEB1

; ---- bank7.code_FE96 (code) $FE96-$FEB0, 27 bytes
L7_FE96:
        tay
L7_FE97:
        lsr     $05A8,X
        bne     L7_FEA1
        lda     #$01
        sta     $05A8,X
L7_FEA1:
        lsr     $0590,X
        bne     L7_FEAB
        lda     #$01
        sta     $0590,X
L7_FEAB:
        iny
        cpy     #$03
        bne     L7_FE97
L7_FEB0:
        rts

; ---- bank7.code_FEB1 (code) $FEB1-$FECB, 27 bytes
L7_FEB1:
        tay
L7_FEB2:
        asl     $05A8,X
        bcc     L7_FEBC
        lda     #$FF
        sta     $05A8,X
L7_FEBC:
        asl     $0590,X
        bcc     L7_FEC6
        lda     #$FF
        sta     $0590,X
L7_FEC6:
        dey
        cpy     #$03
        bne     L7_FEB2
        rts

; ---- bank7.code_FECC (code) $FECC-$FEDD, 18 bytes
L7_FECC:
        lda     #$21
        jsr     L7_D852
        lda     $0590,Y
        sbc     #$14
        bcs     L7_FEDA
        lda     #$00
L7_FEDA:
        sta     $0590,Y
        rts

; ---- bank7.code_FEDE (code) $FEDE-$FEE2, 5 bytes
L7_FEDE:
        sei
        cld
        ldx     #$FF
        txs

; ---- bank7.code_FEE3 (code) $FEE3-$FEE7, 5 bytes
        lda     #$30
        sta     $2000

; ---- bank7.code_FEE8 (code) $FEE8-$FEF1, 10 bytes
        ldx     #$03
L7_FEEA:
        lda     $2002
        bpl     L7_FEEA
        dex
        bne     L7_FEEA

; ---- bank7.code_FEF2 (code) $FEF2-$FEFB, 10 bytes
        lda     #$0F
        sta     $4015
        lda     #$C0
        sta     $4017

; ---- bank7.code_FEFC (code) $FEFC-$FF18, 29 bytes
        lda     #$00
        tax
L7_FEFF:
        sta     $00,X
        sta     $0100,X
        sta     $0200,X
        sta     $0300,X
        sta     $0400,X
        sta     $0500,X
        sta     $0600,X
        sta     $0700,X
        dex
        bne     L7_FEFF

; ---- bank7.code_FF19 (code) $FF19-$FF22, 10 bytes
        lda     #$30
        jsr     L7_D4E7
        lda     #$06
        jsr     L7_D4CF

; ---- bank7.code_FF23 (code) $FF23-$FF39, 23 bytes
        ldy     #$06
L7_FF25:
        tya
        jsr     L7_D705
        cpy     $BFFF
        beq     L7_FF41
        lda     $FF3A,Y
        sta     $0180
        jsr     L7_DED2
L7_FF37:
        jmp     L7_FF37

; ---- bank7.bankcheck_codes_FF3A (data) $FF3A-$FF40, 7 bytes
; Bank-check failure codes
        .byte   $0F,$01,$06,$14,$0A,$31,$28

; ---- bank7.code_FF41 (code) $FF41-$FF43, 3 bytes
L7_FF41:
        dey
        bpl     L7_FF25

; ---- bank7.code_FF44 (code) $FF44-$FF49, 6 bytes
        jsr     L7_D762
        jsr     L6_800F

; ---- bank7.code_FF4A (code) $FF4A-$FF5C, 19 bytes
L7_FF4A:
        ldx     #$FF
        txs
        jsr     L7_D714
        jsr     L0_800C
        lda     $2F
        beq     L7_FF5D
        jsr     L7_D73B
        jsr     L3_800C

; ---- bank7.code_FF5D (code) $FF5D-$FF79, 29 bytes
L7_FF5D:
        ldx     #$FF
        txs
        lda     #$1F
        jsr     L7_D852
        jsr     L7_EDD1
        jsr     L7_D4C1
        jsr     L7_D714
        jsr     L0_8003
        jsr     L7_E110
        jsr     L7_D762
        jsr     L7_CDA2

; ---- bank7.code_FF7A (code) $FF7A-$FF84, 11 bytes
L7_FF7A:
        jsr     L7_E655
        ldy     #$01
        jsr     L7_FF8B
        jsr     L7_D76F

; ---- bank7.inline_FF85 (data) $FF85-$FF87, 3 bytes
; Far-call argument at $FF85
        .byte   $03,$0E,$80

; ---- bank7.code_FF88 (code) $FF88-$FF8A, 3 bytes
        jmp     L7_FF7A

; ---- bank7.code_FF8B (code) $FF8B-$FF97, 13 bytes
L7_FF8B:
        txa
        pha
L7_FF8D:
        tya
        pha
        jsr     L7_DA9A
        jsr     L7_F493
        jsr     L7_D76F

; ---- bank7.inline_FF98 (data) $FF98-$FF9A, 3 bytes
; Far-call argument at $FF98
        .byte   $06,$FF,$7F

; ---- bank7.code_FF9B (code) $FF9B-$FFA8, 14 bytes
        jsr     L7_E0F9
        jsr     L7_DB52
        pla
        tay
        dey
        bne     L7_FF8D
        pla
        tax
        rts

; ---- bank7.pad_FFA9 (padding) $FFA9-$FFBF, 23 bytes
; Fill: 23 x $FF
        .fill   23,$FF

; ---- bank7.dmc_FFC0 (data) $FFC0-$FFD0, 17 bytes
; DMC sample: 17 zero bytes (a timer, not a sound)
        .fill   17,$00

; ---- bank7.code_FFD1 (code) $FFD1-$FFDB, 11 bytes
L7_FFD1:
        lda     #$00
        sta     $2B
L7_FFD5:
        jsr     L7_DA9A
        dey
        bne     L7_FFD5
        rts

; ---- bank7.code_FFDC (code) $FFDC-$FFE3, 8 bytes
L7_FFDC:
        ldy     $50
        lda     $EF16,Y
        jmp     L7_D852

; ---- bank7.pad_FFE4 (padding) $FFE4-$FFF1, 14 bytes
; Fill: 14 x $FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

; ---- bank7.bank_table_FFF2 (data) $FFF2-$FFF9, 8 bytes
; PRG bank table (bus-conflict-free switch values)
        .byte   $80,$81,$82,$83,$84,$85,$86,$87

; ---- bank7.vectors_FFFA (vectors) $FFFA-$FFFF, 6 bytes
; 6502 interrupt vectors
        .byte   $75,$DC,$DE,$FE,$F3,$DC
