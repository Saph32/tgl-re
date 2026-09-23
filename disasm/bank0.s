; PRG bank 0 - not yet established
; $8000-$BFFF
; The switchable window. Every address below exists in seven banks; only this
; one has these bytes at it, which is what the L0_ label prefix records.
.org $8000


; ---- bank0.code_8000 (code) $8000-$801A, 27 bytes
L0_8000:
        jmp     L0_97A0
L0_8003:
        jmp     L0_805B
L0_8006:
        jmp     L0_97CC
L0_8009:
        jmp     L0_917C
L0_800C:
        jmp     L0_8332
L0_800F:
        jmp     L0_81DD
L0_8012:
        jmp     L0_88F5
L0_8015:
        jmp     L0_8915
L0_8018:
        jmp     L0_8034

; ---- UNCLAIMED (gap) $801B-$802F, 21 bytes
        .fill   21,$FF

; ---- bank0.gfxtbl_8030 (pointer_table) $8030-$8033, 4 bytes
; Tile block pointers (2 entries)
        .byte   $BB,$8B,$90,$8D

; ---- bank0.code_8034 (code) $8034-$8036, 3 bytes
L0_8034:
        jsr     L7_C06F

; ---- bank0.inline_8037 (data) $8037-$8059, 35 bytes
; Queued PPU write at $8037
        .byte   $20,$1C,$C0,$7E,$7E,$7E,$7E,$7E,$3C,$08,$00,$80,$EC,$80,$EC,$EC
        .byte   $68,$30,$00,$BE,$BA,$00,$36,$0E,$0E,$0E,$00,$00,$BE,$00,$12,$0A
        .byte   $0A,$0E,$00

; ---- bank0.code_805A (code) $805A-$8151, 248 bytes
        rts
L0_805B:
        jsr     L7_C159
        ldx     #$00
        jsr     L7_C048
        txa
        sta     $0B
        sta     $27
        sta     $A5
        sta     $A0
        sta     $3C
        sta     $3E
        sta     $42
        sta     $43
        sta     $44
        sta     $70
        sta     $5F
        sta     $2E
        sta     $49
        lda     #$3C
        sta     $3F
        lda     #$04
        sta     $3B
        sta     $33
        ldy     $2F
        cpy     #$02
        bne     L0_80A3
        lda     $30
        and     #$02
        beq     L0_80C8
        lda     $78
        sta     $47
        ldy     #$06
        lda     #$00
L0_809C:
        sta     $016F,Y
        dey
        bne     L0_809C
        iny
L0_80A3:
        lda     #$00
        sta     $04B1
        sta     $04B2
        sta     $017C
        sta     $017D
        lda     #$03
        sta     $017E
        tya
        beq     L0_80D4
        lda     $30
        pha
        ora     #$04
        sta     $30
        lda     #$00
        jsr     L7_C057
        pla
        sta     $30
L0_80C8:
        lda     $7C
        sta     $52
        lda     $7D
        sta     $53
        lda     #$20
        bne     L0_8143
L0_80D4:
        ldy     #$13
L0_80D6:
        sta     $049F,Y
        dey
        bne     L0_80D6
        sta     $46
        sta     $6B
        sta     $4C
        sta     $4D
        lda     #$40
        sta     $47
        lda     #$00
        ldy     #$06
L0_80EC:
        sta     $016F,Y
        sta     $04B2,Y
        dey
        bne     L0_80EC
        lda     #$0B
        sta     $52
        sta     $7C
        lda     #$0C
        sta     $53
        sta     $7D
        lda     #$01
        sta     $4A
        sta     $4B
        lda     $F7
        and     #$10
        eor     #$10
        beq     L0_8143
        lda     $30
        and     #$02
        eor     #$02
        beq     L0_8143
        lda     #$80
        sta     $47
        lda     #$AA
        sta     $04AC
        sta     $04AD
        sta     $04AE
        lda     #$02
        sta     $4A
        sta     $4B
        lda     #$06
        sta     $46
        lda     #$02
        sta     $6B
        jsr     L7_C0EA
        and     #$0F
        cmp     #$0C
        bcc     L0_813F
        lda     #$01
L0_813F:
        sta     $3C
        lda     #$80
L0_8143:
        ora     $30
        sta     $30
        lda     #$03
        sta     $A0
        lda     $47
        sta     $48
        jsr     L7_C006

; ---- bank0.inline_8152 (data) $8152-$8154, 3 bytes
; Far-call argument at $8152
        .byte   $02,$17,$80

; ---- bank0.code_8155 (code) $8155-$8182, 46 bytes
        bit     $30
        bmi     L0_815F
        lda     $2F
        cmp     #$01
        bne     L0_8167
L0_815F:
        lda     $4E
        sta     $4C
        lda     $4F
        sta     $4D
L0_8167:
        lda     #$1C
        sta     $F0
        jsr     L7_C0EA
        and     #$1F
        sta     $F4
        lda     #$01
        sta     $F2
        lda     #$20
        jsr     L7_C018
        lda     #$24
        jsr     L7_C018
        jsr     L7_C06C

; ---- bank0.inline_8183 (data) $8183-$8186, 4 bytes
; Inline argument at $8183
        .byte   $40,$27,$C0,$00

; ---- bank0.code_8187 (code) $8187-$8189, 3 bytes
        jsr     L7_C06C

; ---- bank0.inline_818A (data) $818A-$818D, 4 bytes
; Inline argument at $818A
        .byte   $01,$23,$00,$FE

; ---- bank0.code_818E (code) $818E-$8190, 3 bytes
        jsr     L7_C06F

; ---- bank0.inline_8191 (text) $8191-$8195, 5 bytes
; "SC" at $8191
        .byte   $02,$27,$20,$53,$43

; ---- bank0.code_8196 (code) $8196-$8198, 3 bytes
        jsr     L7_C06F

; ---- bank0.inline_8199 (text) $8199-$819F, 7 bytes
; "SHOT" at $8199
        .byte   $04,$27,$35,$53,$48,$4F,$54

; ---- bank0.code_81A0 (code) $81A0-$81A2, 3 bytes
        jsr     L7_C06F

; ---- bank0.inline_81A3 (text) $81A3-$81AC, 10 bytes
; "0  CHIP" at $81A3
        .byte   $07,$27,$28,$30,$20,$20,$43,$48,$49,$50

; ---- bank0.code_81AD (code) $81AD-$81B4, 8 bytes
        lda     #$00
        jsr     L7_C12F
        jsr     L7_C006

; ---- bank0.inline_81B5 (data) $81B5-$81B7, 3 bytes
; Far-call argument at $81B5
        .byte   $05,$32,$80

; ---- bank0.code_81B8 (code) $81B8-$8207, 80 bytes
        lda     #$00
        sta     $A2
        lda     #$1F
        sta     $19
        lda     #$E0
        sta     $18
        lda     #$02
        ldy     #$02
        jsr     L7_C042
        lda     #$11
        sta     $19
        lda     #$00
        sta     $18
        lda     #$01
        ldy     #$02
        jsr     L7_C042
        jmp     L7_C045
L0_81DD:
        jsr     L7_C14A
        ldy     #$01
        jsr     L7_C024
        lda     $0500
        bne     L0_81DD
        bit     $30
        bpl     L0_81F1
        jmp     L7_C14D
L0_81F1:
        lda     #$0A
        jsr     L7_C030
        lda     #$00
        sta     $0300
L0_81FB:
        jsr     L7_C14A
        jsr     L7_C0E4
        and     #$10
        bne     L0_8216
        jsr     L7_C006

; ---- bank0.inline_8208 (data) $8208-$820A, 3 bytes
; Far-call argument at $8208
        .byte   $06,$FF,$7F

; ---- bank0.code_820B (code) $820B-$822F, 37 bytes
        jsr     L7_C153
        jsr     L7_C156
        lda     $0300
        beq     L0_81FB
L0_8216:
        jsr     L7_C0ED
        lda     $30
        and     #$EF
        sta     $30
        jsr     L7_C00F
        jsr     L7_C01B
        lda     #$20
        jsr     L7_C018
        jsr     L7_C015
        jsr     L7_C06C

; ---- bank0.inline_8230 (data) $8230-$8233, 4 bytes
; Inline argument at $8230
        .byte   $40,$23,$C0,$00

; ---- bank0.code_8234 (code) $8234-$8236, 3 bytes
        jsr     L7_C06F

; ---- bank0.inline_8237 (text) $8237-$8242, 12 bytes
; "GAME OVER" at $8237
        .byte   $09,$21,$4B,$47,$41,$4D,$45,$20,$4F,$56,$45,$52

; ---- bank0.code_8243 (code) $8243-$8284, 66 bytes
        bit     $30
        bvc     L0_8266
        lda     $51
        bne     L0_8266
        lda     $30
        and     #$02
        bne     L0_8266
        jsr     L0_82B0
        ldy     #$78
L0_8256:
        jsr     L7_C0E4
        and     #$10
        bne     L0_8260
        dey
        bne     L0_8256
L0_8260:
        jsr     L7_C0ED
        jmp     L7_C14D
L0_8266:
        lda     $30
        and     #$02
        sta     $30
        beq     L0_8282
        lda     $4D
        bne     L0_8282
        lda     $4C
        cmp     #$FA
        bcs     L0_8282
        lda     $46
        cmp     #$07
        bcc     L0_8282
        lda     #$FA
        sta     $4C
L0_8282:
        jsr     L7_C06F

; ---- bank0.inline_8285 (text) $8285-$829B, 23 bytes
; "CONTINUE  PUSH START" at $8285
        .byte   $14,$21,$A7,$43,$4F,$4E,$54,$49,$4E,$55,$45,$20,$20,$50,$55,$53
        .byte   $48,$20,$53,$54,$41,$52,$54

; ---- bank0.code_829C (code) $829C-$82BC, 33 bytes
        jsr     L0_82B0
L0_829F:
        jsr     L7_C0E4
        and     #$10
        beq     L0_829F
        lda     #$02
        sta     $2F
        jsr     L7_C0ED
        jmp     L7_C150
L0_82B0:
        lda     #$30
        sta     $0181
        lda     #$16
        sta     $0183
        jmp     L7_C0DE

; ---- UNCLAIMED (gap) $82BD-$82C4, 8 bytes
        .byte   $08,$09,$0A,$0B,$00,$01,$02,$03

; ---- bank0.code_82C5 (code) $82C5-$8311, 77 bytes
L0_82C5:
        jsr     L0_97A8
        sei
        jsr     L7_C00F
        lda     #$30
        sta     $FF
        sta     $2000
        lda     #$00
        sta     $0B
        sta     $27
        lda     #$12
        sta     $19
        lda     #$70
        sta     $18
        lda     #$01
        ldy     #$02
        jsr     L7_C042
        jsr     L7_C015
        lda     #$00
        sta     $0300
        sta     $A5
        ldy     #$10
        sty     $19
        sta     $18
        ldy     #$00
        jsr     L7_C042
        lda     #$18
        sta     $19
        lda     #$00
        sta     $18
        lda     #$01
        ldy     #$00
        jsr     L7_C042
        jsr     L7_C045
        jsr     L7_C006

; ---- bank0.inline_8312 (data) $8312-$8314, 3 bytes
; Far-call argument at $8312
        .byte   $02,$FF,$7F

; ---- bank0.code_8315 (code) $8315-$831C, 8 bytes
L0_8315:
        lda     #$20
        jsr     L7_C018
        jsr     L7_C06C

; ---- bank0.inline_831D (data) $831D-$8320, 4 bytes
; Inline argument at $831D
        .byte   $40,$23,$C0,$55

; ---- bank0.code_8321 (code) $8321-$8349, 41 bytes
        jsr     L0_8485
        lda     #$BD
        sta     $18
        lda     #$82
        sta     $19
        jsr     L7_C05D
        jmp     L7_C01B
L0_8332:
        jsr     L0_82C5
        jsr     L7_C063
        lda     #$00
        sta     $30
        sta     $2F
        jsr     L7_C01E
        lda     $F7
        cmp     #$C0
        bne     L0_834D
        jsr     L7_C006

; ---- bank0.inline_834A (data) $834A-$834C, 3 bytes
; Far-call argument at $834A
        .byte   $03,$1A,$80

; ---- bank0.code_834D (code) $834D-$837C, 48 bytes
L0_834D:
        lda     #$01
        jsr     L0_97CC
        lda     #$07
        sta     $F0
        lda     #$01
        sta     $F1
L0_835A:
        jsr     L7_C0E4
        and     #$10
        beq     L0_8364
        jmp     L0_8430
L0_8364:
        lda     $0300
        beq     L0_836A
        rts
L0_836A:
        dec     $F1
        bne     L0_835A
        dec     $F0
        bne     L0_835A
        jsr     L7_C0ED
        lda     #$20
        jsr     L7_C018
        jsr     L7_C06C

; ---- bank0.inline_837D (data) $837D-$8380, 4 bytes
; Inline argument at $837D
        .byte   $40,$23,$C0,$00

; ---- bank0.code_8381 (code) $8381-$8435, 181 bytes
        lda     #$20
        sta     $19
        lda     #$80
        sta     $18
        lda     #$86
        sta     $17
        lda     #$E8
        sta     $16
        jsr     L0_8495
        ldy     #$0D
L0_8396:
        lda     $8472,Y
        sta     $0180,Y
        dey
        bne     L0_8396
        lda     #$28
        sta     $FC
        jsr     L7_C0DE
        lda     #$00
        sta     $F2
        lda     #$02
        sta     $F0
        sta     $F3
        lda     #$07
        sta     $F1
L0_83B4:
        jsr     L7_C0E4
        and     #$10
        bne     L0_8421
        lda     $F0
        cmp     #$46
        bcc     L0_83CD
        jsr     L7_C0ED
        jsr     L0_8315
        jsr     L7_C063
        jmp     L0_835A
L0_83CD:
        dec     $F1
        bpl     L0_840F
        ldy     #$0F
        sty     $F1
        cmp     #$1E
        bcs     L0_83FF
        and     #$FC
        asl     A
        adc     #$C0
        sta     $18
        lda     #$23
        sta     $19
        lda     #$08
        sta     $15
        ldy     #$00
        lda     $F0
        and     #$02
        beq     L0_83F2
        ldy     #$03
L0_83F2:
        tya
        clc
        adc     $F2
        tay
        lda     $847F,Y
        sta     $14
        jsr     L7_C036
L0_83FF:
        inc     $F2
        lda     $F2
        cmp     #$03
        bcc     L0_83B4
        lda     #$00
        sta     $F2
        inc     $F0
        inc     $F0
L0_840F:
        lda     $F0
        cmp     #$1C
        bcs     L0_83B4
        dec     $F3
        bne     L0_83B4
        inc     $FC
        lda     #$03
        sta     $F3
        bne     L0_83B4
L0_8421:
        jsr     L7_C0ED
        jsr     L0_8315
        jsr     L0_8822
        jsr     L7_C063
        jmp     L0_8433
L0_8430:
        jsr     L0_8822
L0_8433:
        jsr     L7_C06F

; ---- bank0.inline_8436 (text) $8436-$8439, 4 bytes
; "3" at $8436
        .byte   $01,$23,$E9,$33

; ---- bank0.code_843A (code) $843A-$8461, 40 bytes
        jsr     L0_845B
L0_843D:
        jsr     L7_C0E4
        tay
        and     #$10
        bne     L0_8472
        tya
        and     #$2C
        beq     L0_843D
        lda     $2F
        eor     #$01
        sta     $2F
        jsr     L0_845B
        lda     #$33
        jsr     L0_97CC
        jmp     L0_843D
L0_845B:
        lda     $2F
        bne     L0_8469
        jsr     L7_C06F

; ---- bank0.inline_8462 (text) $8462-$8467, 6 bytes
; ":  " at $8462
        .byte   $83,$22,$86,$3A,$20,$20

; ---- bank0.code_8468 (code) $8468-$846B, 4 bytes
        rts
L0_8469:
        jsr     L7_C06F

; ---- bank0.inline_846C (text) $846C-$8471, 6 bytes
; "  :" at $846C
        .byte   $83,$22,$86,$20,$20,$3A

; ---- bank0.code_8472 (code) $8472-$8472, 1 bytes
L0_8472:
        rts

; ---- UNCLAIMED (gap) $8473-$8484, 18 bytes
        .byte   $0F,$0F,$0F,$00,$0F,$0F,$10,$0F,$0F,$30,$0F,$0F,$05,$0A,$0F,$5F
        .byte   $AF,$FF

; ---- bank0.code_8485 (code) $8485-$84F6, 114 bytes
L0_8485:
        lda     #$20
        sta     $19
        lda     #$00
        sta     $18
        lda     #$F7
        sta     $16
        lda     #$84
        sta     $17
L0_8495:
        ldy     #$00
L0_8497:
        lda     ($16),Y
        iny
        cmp     #$FE
        bcs     L0_84DA
        pha
        lda     ($16),Y
        iny
        sta     $15
        and     #$7F
        sta     $14
        clc
        adc     #$03
        jsr     L7_C04B
        jsr     L7_C03C
        tax
        lda     $14
        sta     $0100,X
        pla
        ora     $18
        sta     $0102,X
        lda     $19
        sta     $0101,X
L0_84C2:
        lda     ($16),Y
        sta     $0103,X
        iny
        inx
        dec     $14
        beq     L0_84D4
        bit     $15
        bpl     L0_84C2
        dey
        bne     L0_84C2
L0_84D4:
        jsr     L7_C03F
        jmp     L0_8497
L0_84DA:
        php
        tya
        clc
        adc     $16
        sta     $16
        bcc     L0_84E5
        inc     $17
L0_84E5:
        lda     $18
        clc
        adc     #$20
        sta     $18
        bcc     L0_84F0
        inc     $19
L0_84F0:
        plp
        beq     L0_84F6
        jmp     L0_8495
L0_84F6:
        rts

; ---- bank0.ppuscript_84F7 (data) $84F7-$86E7, 497 bytes
; PPU script at $84F7
        .byte   $06,$01,$25,$0C,$08,$80,$81,$82,$C2,$C2,$C2,$C1,$C0,$16,$01,$25
        .byte   $FF,$01,$01,$21,$0B,$0A,$83,$84,$85,$C2,$86,$20,$C5,$C5,$C4,$C3
        .byte   $19,$04,$21,$20,$20,$21,$FF,$06,$10,$25,$20,$21,$20,$87,$88,$89
        .byte   $8A,$8B,$8C,$CC,$CB,$CA,$C9,$C8,$C7,$1B,$01,$25,$FF,$0A,$0D,$8D
        .byte   $8E,$8F,$90,$91,$92,$D2,$D1,$D0,$CF,$CE,$CD,$21,$1E,$01,$25,$FF
        .byte   $06,$01,$21,$0A,$0C,$93,$94,$95,$96,$97,$98,$D8,$D7,$D6,$D5,$D4
        .byte   $D3,$1B,$01,$25,$FF,$0A,$0C,$99,$9A,$9B,$9C,$9D,$9E,$DE,$DD,$DC
        .byte   $DB,$DA,$D9,$FF,$02,$02,$25,$21,$0A,$0C,$9F,$A0,$A1,$A2,$A3,$A4
        .byte   $E4,$E3,$E2,$E1,$E0,$DF,$1B,$04,$21,$20,$20,$21,$FF,$05,$01,$25
        .byte   $0A,$0C,$A5,$A6,$A7,$A8,$A9,$AA,$EA,$E9,$E8,$E7,$E6,$E5,$FF,$0A
        .byte   $0F,$AB,$AC,$AD,$AE,$AF,$B0,$F0,$EF,$EE,$ED,$EC,$EB,$20,$25,$21
        .byte   $FF,$0A,$0D,$B1,$B2,$B3,$B4,$B5,$B6,$F6,$F5,$F4,$F3,$F2,$F1,$25
        .byte   $FF,$02,$02,$25,$21,$0B,$0A,$B7,$B8,$B9,$BA,$BB,$FB,$FA,$F9,$F8
        .byte   $F7,$19,$02,$25,$21,$FF,$05,$01,$25,$0C,$08,$BC,$BD,$BE,$BF,$FF
        .byte   $FE,$FD,$FC,$1B,$01,$25,$1F,$01,$25,$FF,$0B,$01,$21,$16,$01,$21
        .byte   $FF,$04,$01,$21,$08,$12,$00,$01,$02,$03,$04,$05,$06,$07,$08,$20
        .byte   $09,$0A,$01,$0A,$08,$0B,$54,$4D,$1E,$01,$25,$FF,$08,$10,$0C,$0D
        .byte   $0E,$0F,$10,$11,$12,$13,$14,$20,$15,$16,$0D,$16,$14,$17,$1C,$01
        .byte   $25,$FF,$03,$01,$25,$08,$10,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$22
        .byte   $20,$23,$23,$19,$23,$22,$24,$FF,$1B,$01,$25,$FF,$01,$01,$21,$0E
        .byte   $02,$42,$59,$18,$01,$25,$1E,$01,$21,$FF,$04,$18,$42,$52,$4F,$44
        .byte   $45,$52,$42,$55,$4E,$44,$20,$53,$4F,$46,$54,$57,$41,$52,$45,$20
        .byte   $49,$4E,$43,$5B,$FF,$02,$01,$25,$FF,$04,$17,$54,$4D,$20,$41,$4E
        .byte   $44,$20,$40,$31,$39,$38,$38,$20,$49,$52,$45,$4D,$20,$43,$4F,$52
        .byte   $50,$5B,$FF,$0B,$0D,$40,$31,$39,$38,$38,$20,$43,$4F,$5E,$50,$49
        .byte   $4C,$45,$FF,$0A,$0B,$4C,$49,$43,$45,$4E,$53,$45,$44,$20,$42,$59
        .byte   $FF,$04,$18,$4E,$49,$4E,$54,$45,$4E,$44,$4F,$20,$4F,$46,$20,$41
        .byte   $4D,$45,$52,$49,$43,$41,$20,$49,$4E,$43,$5B,$FF,$FF,$06,$14,$50
        .byte   $52,$45,$53,$53,$20,$53,$54,$41,$52,$54,$20,$54,$4F,$20,$42,$45
        .byte   $47,$49,$4E,$FF,$FF,$FF,$FF,$FF,$02,$04,$DD,$FF,$FF,$77,$0A,$04
        .byte   $DD,$BF,$EF,$77,$12,$04,$DD,$FB,$FE,$77,$1A,$04,$00,$00,$00,$00
        .byte   $FE

; ---- bank0.ppuscript_86E8 (data) $86E8-$8821, 314 bytes
; PPU script at $86E8
        .byte   $03,$1B,$4C,$4F,$4E,$47,$20,$41,$47,$4F,$5C,$41,$4E,$20,$41,$4C
        .byte   $49,$45,$4E,$20,$52,$41,$43,$45,$20,$53,$45,$4E,$54,$FF,$FF,$02
        .byte   $1C,$41,$20,$48,$55,$47,$45,$20,$57,$4F,$52,$4C,$44,$20,$48,$55
        .byte   $52,$54,$4C,$49,$4E,$47,$20,$54,$4F,$57,$41,$52,$44,$FF,$FF,$02
        .byte   $1D,$54,$48,$45,$20,$45,$41,$52,$54,$48,$5C,$4C,$4F,$41,$44,$45
        .byte   $44,$20,$57,$49,$54,$48,$20,$41,$20,$43,$41,$52,$47,$4F,$FF,$FF
        .byte   $02,$18,$4F,$46,$20,$4D,$59,$53,$54,$45,$52,$49,$4F,$55,$53,$20
        .byte   $4C,$49,$46,$45,$46,$4F,$52,$4D,$53,$5B,$FF,$FF,$03,$18,$59,$4F
        .byte   $55,$20,$4D,$55,$53,$54,$20,$42,$41,$54,$54,$4C,$45,$20,$59,$4F
        .byte   $55,$52,$20,$57,$41,$59,$FF,$FF,$02,$1B,$44,$45,$45,$50,$20,$57
        .byte   $49,$54,$48,$49,$4E,$20,$54,$48,$45,$20,$41,$4C,$49,$45,$4E,$20
        .byte   $57,$4F,$52,$4C,$44,$FF,$FF,$02,$16,$54,$4F,$20,$44,$45,$53,$54
        .byte   $52,$4F,$59,$20,$49,$54,$53,$20,$56,$49,$43,$49,$4F,$55,$53,$FF
        .byte   $FF,$02,$0C,$49,$4E,$48,$41,$42,$49,$54,$41,$4E,$54,$53,$5B,$FF
        .byte   $FF,$03,$17,$59,$4F,$55,$20,$41,$52,$45,$20,$54,$48,$45,$20,$47
        .byte   $55,$41,$52,$44,$49,$41,$4E,$20,$4F,$46,$FF,$FF,$02,$1C,$54,$48
        .byte   $45,$20,$45,$41,$52,$54,$48,$20,$41,$4E,$44,$20,$59,$4F,$55,$52
        .byte   $20,$53,$41,$47,$41,$20,$57,$49,$4C,$4C,$FF,$FF,$02,$1B,$42,$45
        .byte   $43,$4F,$4D,$45,$20,$54,$48,$45,$20,$47,$55,$41,$52,$44,$49,$41
        .byte   $4E,$20,$4C,$45,$47,$45,$4E,$44,$5B,$FE

; ---- bank0.code_8822 (code) $8822-$8835, 20 bytes
L0_8822:
        lda     #$22
        sta     $19
        lda     #$20
        sta     $18
        lda     #$36
        sta     $16
        lda     #$88
        sta     $17
        jsr     L0_8495
        rts

; ---- bank0.ppuscript_8836 (data) $8836-$88B6, 129 bytes
; PPU script at $8836
        .byte   $0E,$82,$20,$0C,$01,$21,$14,$01,$25,$FF,$04,$98,$20,$0A,$0B,$47
        .byte   $41,$4D,$45,$20,$53,$45,$4C,$45,$43,$54,$FF,$04,$98,$20,$08,$01
        .byte   $21,$12,$01,$25,$FF,$04,$98,$20,$08,$0B,$4E,$45,$57,$20,$47,$41
        .byte   $4D,$45,$20,$20,$21,$FF,$04,$98,$20,$06,$03,$25,$20,$21,$11,$01
        .byte   $25,$FF,$04,$98,$20,$08,$11,$50,$41,$53,$53,$57,$4F,$52,$44,$20
        .byte   $43,$4F,$4E,$54,$49,$4E,$55,$45,$FF,$04,$98,$20,$06,$01,$21,$FF
        .byte   $04,$98,$20,$09,$01,$21,$0D,$01,$21,$17,$01,$25,$FF,$04,$98,$20
        .byte   $10,$01,$25,$FF,$04,$98,$20,$04,$01,$21,$0E,$03,$25,$20,$21,$FF
        .byte   $FE

; ---- bank0.ppuscript_88B7 (data) $88B7-$88F4, 62 bytes
; PPU script at $88B7
        .byte   $08,$92,$20,$0A,$01,$21,$14,$01,$25,$FF,$08,$90,$20,$10,$01,$21
        .byte   $FF,$08,$90,$20,$16,$01,$21,$FF,$11,$01,$25,$FF,$FF,$0A,$8B,$20
        .byte   $0C,$01,$25,$12,$01,$21,$FF,$FF,$08,$8B,$20,$0F,$01,$21,$FF,$FF
        .byte   $08,$91,$20,$09,$01,$21,$10,$01,$21,$12,$01,$25,$FF,$FE

; ---- bank0.code_88F5 (code) $88F5-$8917, 35 bytes
L0_88F5:
        jsr     L0_82C5
        lda     #$80
        sta     $A6
        jsr     L7_C087
        jsr     L0_8822
        lda     #$21
        sta     $19
        lda     #$A0
        sta     $18
        lda     #$88
        sta     $17
        lda     #$B7
        sta     $16
        jmp     L0_8495
L0_8915:
        jsr     L7_C006

; ---- bank0.inline_8918 (data) $8918-$891A, 3 bytes
; Far-call argument at $8918
        .byte   $02,$FF,$7F

; ---- bank0.code_891B (code) $891B-$89F8, 222 bytes
        lda     #$00
        sta     $F0
        lda     #$89
        sta     $17
        lda     #$F9
        sta     $16
L0_8927:
        lda     #$22
        sta     $19
        lda     #$20
        sta     $18
        jsr     L0_8495
        lda     #$30
        sta     $04D9
L0_8937:
        ldy     #$0A
        jsr     L0_89B6
        jsr     L7_C16E
        lda     $15
        bne     L0_8937
        ldy     $F0
        cpy     #$08
        bcs     L0_899F
L0_8949:
        ldy     $F0
        inc     $F0
        cpy     #$01
        bne     L0_8959
        lda     #$54
        sta     $0200
        sta     $0204
L0_8959:
        lda     $8BB2,Y
L0_895C:
        pha
        ldy     #$3C
        jsr     L0_89B6
        pla
        sec
        sbc     #$01
        bne     L0_895C
        lda     #$0F
        sta     $04D9
L0_896D:
        ldy     #$03
        jsr     L0_89B6
        jsr     L7_C16E
        lda     $15
        bne     L0_896D
        ldx     #$0A
        lda     #$22
        sta     $19
        lda     #$20
        sta     $18
        lda     #$20
        sta     $14
        lda     #$10
        sta     $15
L0_898B:
        jsr     L7_C036
        lda     $18
        clc
        adc     #$20
        sta     $18
        bcc     L0_8999
        inc     $19
L0_8999:
        dex
        bne     L0_898B
        jmp     L0_8927
L0_899F:
        lda     $F0
        cmp     #$08
        bne     L0_89AE
        jsr     L7_C01E
        lda     $F5
        and     #$10
        bne     L0_8949
L0_89AE:
        ldy     #$01
        jsr     L0_89B6
        jmp     L0_899F
L0_89B6:
        tya
        pha
        inc     $41
        ldy     #$01
        lda     $41
        and     #$02
        beq     L0_89C4
        ldy     #$02
L0_89C4:
        sty     $0206
        lda     $41
        and     #$07
        bne     L0_89D7
        ldy     #$00
        jsr     L0_89E2
        ldy     #$04
        jsr     L0_89E2
L0_89D7:
        ldy     #$01
        jsr     L7_C021
        pla
        tay
        dey
        bne     L0_89B6
        rts
L0_89E2:
        lda     $0200,Y
        cmp     #$F8
        beq     L0_89F8
        lda     $0203,Y
        adc     #$FF
        sta     $0203,Y
        bcs     L0_89F8
        lda     #$F8
        sta     $0200,Y
L0_89F8:
        rts

; ---- bank0.ppuscript_89F9 (data) $89F9-$8A0F, 23 bytes
; PPU script at $89F9
        .byte   $02,$07,$4D,$49,$53,$53,$49,$4F,$4E,$FF,$FF,$04,$09,$43,$4F,$4D
        .byte   $50,$4C,$45,$54,$45,$5B,$FE

; ---- bank0.ppuscript_8A10 (data) $8A10-$8A34, 37 bytes
; PPU script at $8A10
        .byte   $02,$0B,$59,$4F,$55,$20,$41,$52,$45,$20,$54,$48,$45,$FF,$FF,$04
        .byte   $08,$47,$52,$45,$41,$54,$45,$53,$54,$FF,$FF,$07,$07,$50,$4C,$41
        .byte   $59,$45,$52,$5B,$FE

; ---- bank0.ppuscript_8A35 (data) $8A35-$8A74, 64 bytes
; PPU script at $8A35
        .byte   $04,$07,$50,$52,$4F,$47,$52,$41,$4D,$FF,$06,$0A,$41,$4E,$44,$20
        .byte   $45,$46,$46,$45,$43,$54,$FF,$FF,$02,$0D,$4A,$45,$4D,$49,$4E,$49
        .byte   $20,$48,$49,$52,$4F,$4E,$4F,$FF,$FF,$04,$08,$50,$41,$53,$53,$57
        .byte   $4F,$52,$44,$FF,$FF,$02,$08,$57,$41,$4F,$20,$49,$53,$45,$45,$FE

; ---- bank0.ppuscript_8A75 (data) $8A75-$8A92, 30 bytes
; PPU script at $8A75
        .byte   $04,$09,$4D,$41,$50,$20,$4D,$41,$4B,$45,$52,$FF,$FF,$02,$0E,$50
        .byte   $4F,$43,$48,$49,$20,$4E,$41,$4B,$41,$4D,$4F,$52,$49,$FE

; ---- bank0.ppuscript_8A93 (data) $8A93-$8AB7, 37 bytes
; PPU script at $8A93
        .byte   $04,$07,$47,$52,$41,$50,$48,$49,$43,$FF,$FF,$02,$0E,$4A,$41,$4E
        .byte   $55,$53,$20,$54,$45,$52,$41,$4D,$4F,$54,$4F,$FF,$02,$06,$59,$4F
        .byte   $52,$49,$4B,$49,$FE

; ---- bank0.ppuscript_8AB8 (data) $8AB8-$8AEB, 52 bytes
; PPU script at $8AB8
        .byte   $04,$05,$4D,$55,$53,$49,$43,$FF,$FF,$02,$06,$4D,$49,$59,$41,$4D
        .byte   $4F,$FF,$02,$05,$53,$48,$41,$4E,$54,$FF,$FF,$04,$0B,$45,$46,$46
        .byte   $45,$43,$54,$20,$49,$44,$45,$41,$FF,$FF,$02,$07,$53,$49,$4E,$5D
        .byte   $4B,$55,$4E,$FE

; ---- bank0.ppuscript_8AEC (data) $8AEC-$8B4C, 97 bytes
; PPU script at $8AEC
        .byte   $04,$09,$54,$45,$53,$54,$20,$50,$4C,$41,$59,$FF,$FF,$02,$08,$4D
        .byte   $49,$44,$4E,$49,$47,$48,$54,$FF,$03,$0D,$43,$4F,$4D,$4D,$41,$4E
        .byte   $44,$45,$52,$5D,$4E,$55,$49,$FF,$02,$0E,$4A,$41,$4E,$55,$53,$20
        .byte   $54,$45,$52,$41,$4D,$4F,$54,$4F,$FF,$02,$05,$4B,$55,$4E,$4E,$59
        .byte   $FF,$02,$06,$54,$41,$4E,$49,$44,$41,$FF,$02,$05,$53,$48,$41,$4E
        .byte   $54,$FF,$02,$03,$50,$41,$4C,$FF,$06,$06,$5B,$5B,$5B,$45,$54,$43
        .byte   $FE

; ---- bank0.ppuscript_8B4D (data) $8B4D-$8B66, 26 bytes
; PPU script at $8B4D
        .byte   $04,$08,$44,$49,$52,$45,$43,$54,$4F,$52,$FF,$FF,$02,$0B,$4D,$4F
        .byte   $4F,$20,$4E,$49,$49,$54,$41,$4E,$49,$FE

; ---- bank0.ppuscript_8B67 (data) $8B67-$8BA2, 60 bytes
; PPU script at $8B67
        .byte   $02,$0A,$43,$52,$45,$41,$54,$45,$44,$20,$42,$59,$FF,$07,$07,$43
        .byte   $4F,$5E,$50,$49,$4C,$45,$FF,$FF,$FF,$02,$0B,$50,$52,$4F,$44,$55
        .byte   $43,$45,$44,$20,$42,$59,$FF,$03,$04,$49,$52,$45,$4D,$FF,$05,$0B
        .byte   $43,$4F,$52,$50,$4F,$52,$41,$54,$49,$4F,$4E,$FE

; ---- bank0.text_8BA3 (text) $8BA3-$8BB1, 15 bytes
; "PASSWORD TGL" screen script
        .byte   $02,$0C,$50,$41,$53,$53,$57,$4F,$52,$44,$20,$54,$47,$4C,$FE

; ---- bank0.tbl_8BB2 (data) $8BB2-$8BBA, 9 bytes
; Credits: seconds per screen, 9 entries
        .byte   $0A,$0A,$05,$04,$04,$04,$06,$04,$01

; ---- bank0.gfx_8BBB (graphics) $8BBB-$8D8F, 469 bytes
; Tile block: 38 tiles
        .byte   $01,$03,$01,$00,$04,$0E,$01,$04,$02,$00,$08,$04,$01,$00,$03,$01
        .byte   $38,$7C,$EE,$C6,$01,$00,$08,$C6,$01,$00,$03,$C6,$04,$00,$08,$C6
        .byte   $01,$00,$03,$0C,$03,$1E,$01,$00,$08,$1E,$01,$00,$03,$1F,$02,$01
        .byte   $19,$18,$01,$00,$08,$18,$01,$00,$03,$01,$1E,$9F,$DB,$D9,$01,$00
        .byte   $08,$D9,$01,$00,$03,$30,$02,$B0,$02,$00,$08,$B0,$01,$00,$03,$60
        .byte   $03,$F0,$01,$00,$08,$F0,$01,$80,$03,$C6,$03,$E6,$01,$00,$08,$E6
        .byte   $01,$00,$03,$C0,$04,$00,$08,$C0,$01,$00,$03,$FE,$02,$C0,$02,$00
        .byte   $08,$C0,$01,$00,$03,$01,$F0,$F8,$DC,$CC,$01,$00,$08,$01,$CC,$04
        .byte   $01,$00,$05,$0A,$01,$00,$03,$0A,$02,$0E,$01,$0A,$02,$01,$00,$C6
        .byte   $C0,$01,$00,$04,$C6,$01,$00,$03,$C0,$01,$DE,$02,$C6,$05,$00,$04
        .byte   $C6,$01,$00,$03,$C6,$06,$12,$02,$00,$04,$61,$01,$00,$03,$33,$03
        .byte   $21,$01,$61,$02,$18,$02,$00,$04,$98,$01,$00,$03,$19,$01,$1F,$02
        .byte   $19,$01,$98,$02,$D9,$02,$00,$04,$D9,$01,$00,$03,$99,$01,$19,$02
        .byte   $99,$01,$D9,$02,$B0,$02,$00,$04,$B3,$01,$00,$03,$B1,$04,$B3,$02
        .byte   $90,$02,$00,$04,$0C,$01,$00,$03,$98,$03,$08,$01,$0C,$02,$01,$E6
        .byte   $F6,$01,$00,$04,$DE,$01,$00,$03,$F6,$02,$DE,$03,$CE,$01,$C0,$02
        .byte   $00,$04,$C0,$01,$00,$03,$C0,$08,$00,$04,$C0,$01,$00,$03,$C0,$01
        .byte   $FE,$02,$C0,$03,$CC,$02,$00,$04,$CC,$01,$00,$03,$CC,$06,$01,$0E
        .byte   $08,$0E,$08,$0E,$00,$00,$00,$0E,$08,$0E,$08,$0E,$00,$00,$00,$C6
        .byte   $C6,$EE,$7A,$32,$00,$00,$00,$C6,$C6,$EE,$7A,$32,$00,$00,$00,$C6
        .byte   $C6,$EE,$7C,$38,$00,$00,$00,$C6,$C6,$EE,$7C,$38,$00,$00,$00,$7F
        .byte   $7F,$01,$C0,$03,$00,$03,$7F,$02,$C0,$03,$00,$03,$98,$02,$D8,$03
        .byte   $00,$03,$98,$02,$D8,$03,$00,$03,$D9,$02,$01,$DB,$DF,$DE,$00,$00
        .byte   $00,$D9,$D9,$DB,$DF,$DE,$00,$00,$00,$B3,$B3,$B6,$36,$36,$00,$00
        .byte   $00,$B3,$B3,$B6,$36,$36,$00,$00,$00,$FC,$FC,$01,$06,$03,$00,$03
        .byte   $FC,$02,$06,$03,$00,$1D,$20,$01,$00,$05,$CE,$02,$C6,$03,$02,$03
        .byte   $CE,$02,$C6,$03,$02,$03,$C0,$03,$FE,$02,$00,$03,$C0,$03,$FE,$02
        .byte   $00,$03,$CC,$02,$01,$DC,$F8,$F0,$00,$00,$00,$CC,$CC,$DC,$F8,$F0
        .byte   $01,$00,$04,$01,$10,$28,$54,$28,$10,$00,$00,$00,$10,$38,$6C,$38
        .byte   $10,$00,$00,$01,$01

; ---- bank0.gfx_8D90 (graphics) $8D90-$917B, 1004 bytes
; Tile block: 128 tiles
        .byte   $18,$1C,$18,$00,$06,$18,$01,$0A,$18,$00,$06,$18,$01,$0A,$00,$00
        .byte   $01,$0A,$50,$82,$00,$0A,$00,$00,$01,$0A,$50,$82,$00,$0A,$00,$08
        .byte   $50,$0A,$54,$80,$04,$A0,$00,$08,$50,$0A,$54,$80,$04,$A0,$18,$00
        .byte   $04,$18,$01,$02,$04,$0A,$18,$00,$04,$18,$01,$02,$04,$0A,$15,$28
        .byte   $45,$80,$50,$8A,$51,$E2,$15,$28,$45,$80,$50,$8A,$51,$E2,$00,$00
        .byte   $41,$88,$15,$88,$51,$28,$00,$00,$41,$88,$15,$88,$51,$28,$00,$0A
        .byte   $41,$A0,$14,$22,$40,$22,$00,$0A,$41,$A0,$14,$22,$40,$22,$18,$00
        .byte   $04,$01,$02,$03,$02,$00,$04,$01,$02,$03,$02,$18,$31,$4F,$D5,$AE
        .byte   $55,$2E,$C5,$8A,$31,$4F,$D5,$AE,$55,$2E,$C5,$8E,$D5,$AA,$57,$AE
        .byte   $4D,$AA,$07,$AA,$D5,$AA,$57,$AE,$5D,$BA,$77,$EA,$50,$E2,$45,$AA
        .byte   $50,$A2,$54,$AA,$50,$E2,$45,$AA,$50,$A2,$54,$AA,$50,$80,$55,$A0
        .byte   $45,$AA,$55,$AA,$50,$80,$55,$A0,$45,$AA,$55,$AA,$54,$A0,$14,$A8
        .byte   $54,$AA,$44,$28,$54,$A0,$14,$A8,$54,$AA,$44,$28,$03,$0A,$01,$06
        .byte   $14,$12,$08,$0A,$07,$0E,$0D,$0E,$14,$1E,$3C,$3A,$11,$3A,$55,$1A
        .byte   $55,$8A,$14,$E8,$15,$3E,$55,$3A,$75,$EB,$55,$EB,$5F,$BA,$7D,$8E
        .byte   $15,$EE,$D5,$AA,$5F,$BA,$7D,$EE,$55,$EE,$D5,$AA,$55,$AA,$41,$92
        .byte   $65,$8A,$15,$EB,$55,$AA,$41,$92,$65,$8A,$15,$EB,$55,$A8,$D5,$AA
        .byte   $D5,$EE,$75,$2E,$55,$A8,$D5,$AA,$D5,$EE,$F5,$AE,$40,$AA,$45,$AB
        .byte   $45,$A9,$44,$AA,$40,$AA,$45,$AB,$47,$AB,$47,$AB,$14,$1A,$05,$27
        .byte   $31,$42,$57,$DE,$34,$3A,$75,$7F,$7F,$62,$77,$FF,$57,$A8,$D3,$A6
        .byte   $45,$F6,$57,$7A,$57,$AE,$DF,$AE,$5D,$FE,$57,$FA,$5D,$BA,$54,$8A
        .byte   $04,$AA,$25,$A0,$5D,$BB,$55,$AB,$65,$EA,$65,$A0,$D5,$AA,$F5,$EA
        .byte   $55,$6E,$55,$6E,$D5,$AA,$F5,$EA,$D5,$EE,$D5,$EE,$75,$2E,$F5,$A9
        .byte   $35,$99,$56,$99,$F5,$AE,$F7,$EB,$77,$FB,$75,$BA,$44,$8A,$55,$8D
        .byte   $C5,$64,$42,$C3,$45,$8B,$57,$8F,$C7,$E3,$85,$80,$54,$CE,$51,$6A
        .byte   $7C,$26,$55,$26,$75,$FF,$DD,$EF,$FD,$BF,$DD,$BE,$D5,$BA,$D6,$9A
        .byte   $54,$0E,$45,$E6,$D5,$BA,$D7,$BB,$75,$BE,$55,$FE,$75,$68,$55,$E8
        .byte   $56,$2A,$57,$EE,$F5,$E8,$D5,$E8,$D6,$AA,$D7,$EE,$77,$A9,$33,$9B
        .byte   $7F,$28,$01,$B2,$F7,$AF,$F5,$F8,$1E,$0F,$05,$A2,$5C,$AB,$D6,$18
        .byte   $00,$05,$18,$45,$AA,$CA,$F0,$C0,$00,$00,$02,$E3,$80,$18,$00,$04
        .byte   $40,$01,$00,$02,$40,$01,$00,$02,$04,$01,$00,$03,$18,$4D,$A2,$95
        .byte   $9E,$CD,$4E,$4D,$2A,$DD,$FA,$D5,$FE,$FD,$FE,$FD,$FA,$4F,$E6,$D2
        .byte   $CE,$45,$AE,$75,$AA,$4F,$E6,$D2,$CE,$45,$AE,$75,$AA,$57,$ED,$14
        .byte   $8E,$5C,$4A,$5D,$53,$57,$EF,$17,$8F,$DD,$CB,$DD,$D2,$78,$B8,$F0
        .byte   $70,$22,$A1,$40,$40,$68,$A8,$C0,$F0,$E2,$21,$C0,$C0,$00,$10,$00
        .byte   $40,$00,$03,$04,$48,$00,$10,$00,$40,$00,$03,$04,$48,$00,$03,$05
        .byte   $1A,$E0,$18,$00,$04,$18,$03,$05,$1A,$E0,$00,$00,$00,$AD,$26,$17
        .byte   $50,$51,$5A,$2F,$36,$FD,$6E,$7F,$7E,$77,$7A,$1F,$0E,$74,$BA,$54
        .byte   $9A,$D5,$A9,$96,$1A,$75,$BB,$55,$BB,$F7,$EB,$F5,$BB,$41,$AA,$CD
        .byte   $A4,$54,$A6,$DB,$AF,$D0,$BA,$DD,$BC,$5C,$AE,$D4,$A0,$C2,$40,$80
        .byte   $80,$80,$00,$80,$80,$40,$C0,$80,$84,$80,$00,$84,$80,$30,$20,$20
        .byte   $40,$40,$40,$80,$80,$30,$20,$20,$40,$42,$40,$80,$81,$18,$00,$0D
        .byte   $18,$04,$10,$90,$31,$28,$05,$14,$05,$0A,$0B,$04,$2F,$36,$1B,$1E
        .byte   $0D,$06,$0F,$03,$D4,$7A,$15,$09,$24,$CB,$5D,$8E,$D5,$FB,$D5,$F9
        .byte   $54,$BB,$7D,$BE,$D7,$EC,$77,$E2,$77,$3B,$19,$08,$D0,$E2,$FF,$2E
        .byte   $77,$3F,$9F,$83,$A0,$88,$85,$80,$80,$80,$C4,$C0,$A0,$88,$85,$80
        .byte   $80,$80,$C0,$C0,$18,$80,$0C,$18,$81,$80,$81,$80,$18,$00,$04,$18
        .byte   $20,$01,$02,$22,$0A,$C2,$20,$40,$01,$02,$04,$04,$02,$02,$01,$01
        .byte   $18,$00,$04,$18,$01,$03,$00,$01,$18,$00,$04,$18,$C5,$36,$99,$19
        .byte   $CD,$EF,$65,$3B,$DD,$EE,$77,$E7,$B1,$DB,$5D,$07,$47,$E0,$74,$FA
        .byte   $51,$98,$4D,$F6,$C0,$E0,$34,$9E,$77,$BA,$5F,$EF,$00,$40,$E0,$20
        .byte   $10,$D0,$58,$29,$00,$42,$20,$E0,$52,$B0,$38,$F9,$40,$40,$40,$20
        .byte   $20,$10,$28,$44,$40,$40,$44,$22,$21,$10,$28,$44,$01,$00,$08,$18
        .byte   $00,$05,$18,$52,$28,$80,$41,$82,$10,$04,$00,$1D,$0F,$14,$03,$01
        .byte   $00,$00,$00,$13,$09,$17,$02,$18,$00,$04,$18,$70,$2A,$54,$6A,$2D
        .byte   $A3,$19,$2C,$ED,$E7,$B5,$BA,$DD,$5F,$67,$33,$44,$8E,$16,$58,$45
        .byte   $E6,$F0,$14,$5C,$A6,$F1,$BB,$3E,$D9,$EF,$E8,$03,$00,$08,$41,$10
        .byte   $0E,$01,$0C,$23,$00,$00,$C0,$50,$9E,$1F,$63,$00,$E0,$1F,$00,$10
        .byte   $00,$C0,$6F,$00,$E0,$1F,$00,$00,$00,$C0,$FF,$03,$01,$18,$00,$06
        .byte   $18,$0C,$02,$18,$00,$06,$18,$08,$58,$A9,$67,$15,$01,$00,$00,$BB
        .byte   $C7,$A6,$78,$1A,$01,$00,$00,$21,$BB,$C7,$F5,$AC,$FD,$1B,$00,$DE
        .byte   $4F,$38,$08,$22,$9F,$04,$01,$82,$F9,$04,$1D,$BF,$E0,$C2,$FF,$7D
        .byte   $04,$FE,$FA,$42,$3F,$BD,$00,$1C,$92,$8D,$18,$18

; ---- bank0.code_917C (code) $917C-$932B, 432 bytes
L0_917C:
        lda     $0307
        beq     L0_9182
        rts
L0_9182:
        lda     $0301
        and     #$FE
        cmp     $0301
        sta     $0301
        beq     L0_91A3
        lda     #$00
        jsr     L0_97E4
        ldx     #$00
L0_9196:
        lda     $03E4,X
        ora     #$40
        sta     $03E4,X
        inx
        cpx     #$07
        bne     L0_9196
L0_91A3:
        jsr     L0_96A9
        ldy     #$05
        lda     $0301
        and     #$02
        ora     $031F
        beq     L0_91B3
        iny
L0_91B3:
        sty     $0302
L0_91B6:
        ldx     $0302
        lda     $0319,X
        bne     L0_91C1
        jmp     L0_9239
L0_91C1:
        tay
        lda     $03E4,X
        and     #$7F
        sta     $03E4,X
        lda     $0358,X
        and     #$01
        beq     L0_91DD
        lda     $0397,X
        clc
        adc     $039E,X
        sta     $039E,X
        bcc     L0_91F6
L0_91DD:
        dec     $0374,X
        bne     L0_91F6
        lda     $033C,X
        sta     $0374,X
        inc     $035F,X
        lda     $035F,X
        cmp     $0366,X
        bne     L0_91F6
        jsr     L0_92F7
L0_91F6:
        jsr     L0_95B2
        jsr     L0_964A
        lda     $0358,X
        bpl     L0_9204
        jsr     L0_92A7
L0_9204:
        jsr     L0_96BF
        lda     $0358,X
        and     #$20
        beq     L0_9239
        lda     $03C1,X
        clc
        adc     $03C8,X
        sta     $03C8,X
        bcc     L0_9239
        lda     $0320,X
        and     #$0F
        cmp     $03CF,X
        bne     L0_922E
        lda     $0358,X
        ora     #$02
        sta     $0358,X
        bne     L0_9239
L0_922E:
        lda     $0358,X
        and     #$FD
        sta     $0358,X
        dec     $0320,X
L0_9239:
        cpx     #$06
        beq     L0_9246
        dex
        stx     $0302
        bmi     L0_9246
        jmp     L0_91B6
L0_9246:
        lda     $0306
        ldx     #$30
        ldy     #$80
        lsr     A
        bcs     L0_9253
        stx     $0308
L0_9253:
        lsr     A
        bcs     L0_9259
        stx     $030C
L0_9259:
        lsr     A
        bcs     L0_925F
        sty     $0310
L0_925F:
        lsr     A
        bcs     L0_9265
        stx     $0314
L0_9265:
        ldx     #$0F
L0_9267:
        lda     $0308,X
        cmp     #$FF
        bcs     L0_9271
        sta     $4000,X
L0_9271:
        dex
        ldy     $0308,X
        bcc     L0_927E
        lda     $0307,X
        beq     L0_9282
        bmi     L0_9282
L0_927E:
        tya
        sta     $4000,X
L0_9282:
        dex
        bcs     L0_928F
        lda     $0308,X
        bmi     L0_928C
        lda     #$08
L0_928C:
        sta     $4000,X
L0_928F:
        dex
        lda     $0308,X
        cpx     #$08
        bne     L0_92A0
        tay
        bmi     L0_92A0
        and     #$0F
        beq     L0_92A0
        lda     #$FF
L0_92A0:
        sta     $4000,X
        dex
        bpl     L0_9267
        rts
L0_92A7:
        lda     $03D6,X
        beq     L0_92F6
        tay
        lda     $03B3,X
        sta     $1E
        lda     $03BA,X
L0_92B5:
        lsr     A
        ror     $1E
        dey
        bne     L0_92B5
        sta     $1F
        lda     $0358,X
        and     #$40
        bne     L0_92DA
        lda     $03B3,X
        clc
        adc     $1E
        sta     $03B3,X
        lda     $03BA,X
        adc     $1F
        sta     $03BA,X
        cmp     #$08
        bcs     L0_92EE
        rts
L0_92DA:
        lda     $03B3,X
        sec
        sbc     $1E
        sta     $03B3,X
        lda     $03BA,X
        sbc     $1F
        sta     $03BA,X
        bcc     L0_92EE
        rts
L0_92EE:
        lda     #$00
        sta     $03B3,X
        sta     $03BA,X
L0_92F6:
        rts
L0_92F7:
        lda     $034A,X
        sta     $1C
        lda     $0351,X
        sta     $1D
        ldy     #$FF
        iny
        ldx     $0302
        lda     ($1C),Y
        bmi     L0_930E
        jmp     L0_94C8
L0_930E:
        cmp     #$B0
        bcc     L0_9315
        jmp     L0_94C2
L0_9315:
        asl     A
        tax
        lda     #$93
        pha
        lda     #$02
        pha
        lda     $932D,X
        pha
        lda     $932C,X
        pha
        ldx     $0302
        iny
        lda     ($1C),Y
        rts

; ---- bank0.tbl_932C (pointer_table) $932C-$9355, 42 bytes
; Sound command dispatch
        .byte   $55,$93,$60,$93,$75,$93,$81,$93,$6F,$93,$85,$93,$96,$93,$B0,$93
        .byte   $A0,$93,$56,$94,$AC,$93,$13,$94,$E0,$93,$76,$94,$05,$94,$38,$94
        .byte   $9D,$94,$BD,$94,$89,$93,$CB,$97,$D9,$93

; ---- bank0.code_9356 (code) $9356-$95F8, 675 bytes
L0_9356:
        tax
        iny
        lda     ($1C),Y
        sta     $1D
        stx     $1C
        ldy     #$FF
        rts
L0_9361:
        clc
        adc     $0302
        tax
        iny
        lda     ($1C),Y
        dec     $0319,X
        bne     L0_9356
        iny
        rts
L0_9370:
        lda     $03DD,X
        sta     $0300
L0_9376:
        lda     #$00
        sta     $0319,X
        pla
        pla
        pla
        pla
        jmp     L0_9239
L0_9382:
        sta     $032E,X
        rts
L0_9386:
        sta     $0327,X
        rts
L0_938A:
        sta     $1E
        lda     $0320,X
        and     #$F0
        ora     $1E
        sta     $0320,X
        rts
L0_9397:
        beq     L0_939D
        clc
        adc     $0335,X
L0_939D:
        sta     $0335,X
        rts
L0_93A1:
        clc
        adc     $0302
        tax
        iny
        lda     ($1C),Y
        sta     $0319,X
        rts
L0_93AD:
        sta     $0319,X
        rts
L0_93B1:
        pha
        lda     $0320,X
        and     #$0F
        sta     $1E
        pla
        clc
        bpl     L0_93C5
        adc     $1E
        bcs     L0_93CD
        lda     #$00
        beq     L0_93CD
L0_93C5:
        adc     $1E
        cmp     #$10
        bcc     L0_93CD
        lda     #$0F
L0_93CD:
        sta     $1E
        lda     $0320,X
        and     #$F0
        ora     $1E
        sta     $0320,X
        rts
L0_93DA:
        ora     $0300
        sta     $0300
        rts
L0_93E1:
        sta     $1E
        and     #$3F
        sta     $03CF,X
        lda     $0358,X
        and     #$CD
        sta     $0358,X
        lda     #$00
        sta     $03C8,X
        iny
        lda     ($1C),Y
        sta     $03C1,X
        beq     L0_9405
        lda     $0358,X
        ora     #$20
        sta     $0358,X
L0_9405:
        rts
L0_9406:
        lda     $0358,X
        and     #$02
        bne     L0_9412
        lda     ($1C),Y
        jmp     L0_9356
L0_9412:
        iny
        rts
L0_9414:
        clc
        dec     $0389,X
        adc     $0389,X
        inc     $0389,X
        sta     $1E
        iny
        lda     ($1C),Y
        adc     #$00
        sta     $1F
        sty     $0303
        ldy     #$00
        lda     ($1E),Y
        ldy     $0303
        clc
        adc     $0335,X
        sta     $0335,X
        rts
L0_9439:
        sta     $0397,X
        lda     #$80
        sta     $039E,X
        lda     $0358,X
        and     #$FE
        sta     $0358,X
        lda     $0397,X
        beq     L0_9456
        lda     $0358,X
        ora     #$01
        sta     $0358,X
L0_9456:
        rts
L0_9457:
        sta     $1E
        asl     A
        beq     L0_9472
        lda     $03EB,X
        php
        clc
        adc     $1E
        and     #$0F
        plp
        bpl     L0_946A
        ora     #$80
L0_946A:
        bcc     L0_946E
        eor     #$80
L0_946E:
        sta     $03EB,X
        rts
L0_9472:
        lsr     A
        sta     $03EB,X
        rts
L0_9477:
        bmi     L0_9487
        beq     L0_9495
        sta     $03D6,X
        lda     $0358,X
        and     #$BF
        ora     #$80
        bmi     L0_9491
L0_9487:
        and     #$7F
        sta     $03D6,X
        lda     $0358,X
        ora     #$C0
L0_9491:
        sta     $0358,X
        rts
L0_9495:
        lda     $0358,X
        and     #$7F
        sta     $0358,X
        rts
L0_949E:
        sta     $03F2,X
        iny
        lda     ($1C),Y
        sta     $03F9,X
        ora     $03F2,X
        beq     L0_94B5
        lda     $0358,X
        ora     #$08
        sta     $0358,X
        rts
L0_94B5:
        lda     $0358,X
        and     #$F7
        sta     $0358,X
        rts
L0_94BE:
        sta     $0343,X
        rts
L0_94C2:
        lda     $036D,X
        jmp     L0_94CC
L0_94C8:
        sta     $036D,X
        iny
L0_94CC:
        jsr     L0_956F
        lda     ($1C),Y
        cmp     #$E0
        bcs     L0_94DB
        lda     $037B,X
        jmp     L0_94F1
L0_94DB:
        sec
        sbc     #$E0
        bne     L0_94E6
        iny
        lda     ($1C),Y
        jmp     L0_94F0
L0_94E6:
        sty     $0303
        tay
        lda     $9941,Y
        ldy     $0303
L0_94F0:
        iny
L0_94F1:
        sta     $0366,X
        sta     $037B,X
        tya
        clc
        adc     $1C
        sta     $034A,X
        lda     $1D
        adc     #$00
        sta     $0351,X
        lda     $033C,X
        sta     $0374,X
        lda     #$00
        sta     $035F,X
        sta     $03AC,X
        lda     $0319,X
        and     #$10
        beq     L0_951F
        lda     $0382,X
        bne     L0_9522
L0_951F:
        sta     $03A5,X
L0_9522:
        lda     $03E4,X
        ora     #$80
        sta     $03E4,X
        lda     $0358,X
        and     #$08
        beq     L0_956E
        lda     $03F9,X
L0_9534:
        sta     $1F
        lda     $03F2,X
        sta     $1E
        inc     $03F2,X
        bne     L0_9543
        inc     $03F9,X
L0_9543:
        ldy     #$00
        lda     ($1E),Y
        bne     L0_9558
        iny
        lda     ($1E),Y
        sta     $03F2,X
        iny
        lda     ($1E),Y
        sta     $03F9,X
        jmp     L0_9534
L0_9558:
        sta     $03EB,X
        lsr     A
        lsr     A
        lsr     A
        lsr     A
        lsr     A
        and     #$03
        sta     $1E
        lda     $0319,X
        and     #$FC
        ora     $1E
        sta     $0319,X
L0_956E:
        rts
L0_956F:
        sta     $03B3,X
        and     #$FF
        bne     L0_957A
        sta     $03BA,X
        rts
L0_957A:
        lda     $0343,X
        cmp     #$03
        bne     L0_9596
        lda     #$01
        sta     $03BA,X
        lda     $03B3,X
        cmp     #$11
        bcc     L0_958F
        adc     #$6F
L0_958F:
        sbc     $0335,X
        sta     $03B3,X
        rts
L0_9596:
        lda     $03B3,X
        clc
        adc     $0335,X
        sty     $0303
        asl     A
        tay
        lda     $9840,Y
        sta     $03B3,X
        lda     $9841,Y
        sta     $03BA,X
        ldy     $0303
        rts
L0_95B2:
        lda     $0320,X
        and     #$10
        beq     L0_95F2
        lda     $0327,X
        beq     L0_95F2
        asl     A
        tay
        lda     $99AB,Y
        sta     $1E
        lda     $99AC,Y
        sta     $1F
        ldy     $03A5,X
        jsr     L0_9627
        iny
        sta     $1E
        lda     $0320,X
        and     #$0F
        clc
        adc     $1E
        sbc     #$0E
        sta     $0305
        tya
        sta     $03A5,X
        lda     $0320,X
        and     #$F0
        bcc     L0_95EE
        ora     $0305
L0_95EE:
        sta     $0382,X
        rts
L0_95F2:
        lda     $0320,X
        sta     $0382,X
        rts

; ---- UNCLAIMED (gap) $95F9-$9626, 46 bytes
        .byte   $BD,$27,$03,$F0,$F4,$0A,$A8,$B9,$AB,$99,$85,$1E,$B9,$AC,$99,$85
        .byte   $1F,$BC,$A5,$03,$20,$27,$96,$C8,$85,$1E,$BD,$20,$03,$18,$65,$1E
        .byte   $E9,$1F,$B0,$02,$A9,$00,$9D,$82,$03,$98,$9D,$A5,$03,$60

; ---- bank0.code_9627 (code) $9627-$9770, 330 bytes
L0_9627:
        lda     ($1E),Y
        bmi     L0_962C
        rts
L0_962C:
        cmp     #$80
        bne     L0_9634
        dey
        lda     ($1E),Y
        rts
L0_9634:
        cmp     #$81
        bne     L0_9641
        tya
        iny
        sec
        sbc     ($1E),Y
        tay
        lda     ($1E),Y
        rts
L0_9641:
        cmp     #$82
        bne     L0_9649
        ldy     #$00
        lda     ($1E),Y
L0_9649:
        rts
L0_964A:
        lda     $03B3,X
        ora     $03BA,X
        beq     L0_96A8
        lda     $032E,X
        bmi     L0_96A8
        asl     A
        beq     L0_96A8
        and     #$7F
        tay
        lda     $995F,Y
        sta     $1E
        lda     $9960,Y
        sta     $1F
        ldy     $03AC,X
        jsr     L0_9627
        iny
        sta     $0305
        tya
        sta     $03AC,X
        clc
        lda     $0305
        beq     L0_96A8
        bpl     L0_9686
        adc     $03B3,X
        bcs     L0_9697
        ldy     #$00
        beq     L0_968D
L0_9686:
        adc     $03B3,X
        bcc     L0_9697
        ldy     #$FF
L0_968D:
        pha
        lda     $032E,X
        and     #$40
        beq     L0_969B
        pla
        tya
L0_9697:
        sta     $03B3,X
        rts
L0_969B:
        pla
        sta     $03B3,X
        tya
        eor     #$FF
        adc     $03BA,X
        sta     $03BA,X
L0_96A8:
        rts
L0_96A9:
        ldy     #$FF
        sty     $030B
        sty     $030F
        sty     $0313
        sty     $0317
        iny
        sty     $0306
        sty     $0318
L0_96BE:
        rts
L0_96BF:
        lda     $0318
        and     #$20
        beq     L0_96CF
L0_96C6:
        lda     $03E4,X
        ora     #$40
        sta     $03E4,X
        rts
L0_96CF:
        lda     $0319,X
        ora     $0318
        sta     $0318
        lda     $0319,X
        and     #$03
        beq     L0_96BE
        ldy     $0343,X
        lda     $9771,Y
        and     $0306
        bne     L0_96C6
        lda     $9775,Y
        and     $0306
        sta     $0306
        tya
        asl     A
        asl     A
        tay
        lda     #$FF
        sta     $030B,Y
        lda     $03B3,X
        ora     $03BA,X
        bne     L0_9715
        lda     $0358,X
        and     #$08
        beq     L0_9768
        lda     $0319,X
        and     #$02
        beq     L0_9768
        jmp     L0_9779
L0_9715:
        lda     $0319,X
        and     #$02
        beq     L0_971F
        jsr     L0_9779
L0_971F:
        lda     $0319,X
        and     #$01
        beq     L0_9768
        lda     $0382,X
        sta     $0308,Y
        lda     $032E,X
        sta     $0309,Y
        lda     $03B3,X
        sta     $030A,Y
        lda     $03E4,X
        bmi     L0_9751
        and     #$40
        bne     L0_9751
        lda     $0358,X
        bmi     L0_9751
        lda     $032E,X
        beq     L0_975C
        bmi     L0_975C
        and     #$40
        bne     L0_975C
L0_9751:
        lda     $0327,X
        and     #$F8
        ora     $03BA,X
        sta     $030B,Y
L0_975C:
        ldy     $0343,X
        lda     $9771,Y
        ora     $0306
        sta     $0306
L0_9768:
        lda     $03E4,X
        and     #$BF
        sta     $03E4,X
        rts

; ---- bank0.snd_9771 (data) $9771-$9778, 8 bytes
; Hardware channel masks
        .byte   $01,$02,$04,$08,$FE,$FD,$FB,$F7

; ---- bank0.code_9779 (code) $9779-$9859, 225 bytes
L0_9779:
        lda     $0306
        and     #$08
        bne     L0_979F
        lda     $0306
        ora     #$08
        sta     $0306
        lda     $0382,X
        sta     $0314
        lda     $03EB,X
        sta     $0316
        lda     $03E4,X
        bpl     L0_979F
        lda     $0327,X
        sta     $0317
L0_979F:
        rts
L0_97A0:
        lda     #$00
        sta     $0301
        sta     $0307
L0_97A8:
        txa
        pha
        ldx     #$07
L0_97AC:
        lda     #$00
        sta     $0318,X
        dex
        bne     L0_97AC
        pla
        tax
        lda     #$00
        sta     $4008
        lda     #$0F
        sta     $4015
        lda     #$30
        sta     $4000
        sta     $4004
        sta     $400C
        rts
L0_97CC:
        inc     $0307
        sta     $1E
        txa
        pha
        tya
        pha
        lda     $1E
        jsr     L0_97E4
        lda     #$00
        sta     $0307
        pla
        tay
        pla
        tax
        rts
L0_97E4:
        sta     $0304
        asl     A
        tax
        lda     $9B04,X
        sta     $1E
        lda     $9B05,X
        sta     $1F
        ldy     #$00
        lda     ($1E),Y
        bne     L0_9800
        lda     $1F
        pha
        lda     $1E
        pha
        rts
L0_9800:
        iny
        sta     $0305
L0_9804:
        lda     ($1E),Y
        iny
        tax
        lda     ($1E),Y
        beq     L0_9850
        lda     $0319,X
        and     #$40
        bne     L0_9859
        lda     $0304
        sta     $03DD,X
        txa
        pha
        lda     #$09
        sta     $0304
L0_9820:
        lda     ($1E),Y
        iny
        sta     $0319,X
        txa
        clc
        adc     #$07
        tax
        dec     $0304
        bne     L0_9820
        pla
        tax
        lda     #$00
        sta     $0358,X
        sta     $03E4,X
        sta     $035F,X
        sta     $03EB,X
        lda     $03DD,X
        sta     $0304
        lda     #$01
        sta     $0366,X
        sta     $0374,X
        bne     L0_9854
L0_9850:
        sta     $0319,X
        iny
L0_9854:
        dec     $0305
        bne     L0_9804
L0_9859:
        rts

; ---- bank0.snd_985A (data) $985A-$9931, 216 bytes
; Note period table
        .byte   $FE,$07,$8E,$07,$20,$07,$BA,$06,$5A,$06,$FE,$05,$A8,$05,$56,$05
        .byte   $0A,$05,$C2,$04,$7E,$04,$3C,$04,$FF,$03,$C7,$03,$90,$03,$5D,$03
        .byte   $2D,$03,$FF,$02,$D4,$02,$AB,$02,$85,$02,$61,$02,$3F,$02,$1E,$02
        .byte   $FF,$01,$E3,$01,$C8,$01,$AE,$01,$96,$01,$7F,$01,$6A,$01,$55,$01
        .byte   $42,$01,$30,$01,$1F,$01,$0F,$01,$FF,$00,$F1,$00,$E4,$00,$D7,$00
        .byte   $CB,$00,$BF,$00,$B5,$00,$AA,$00,$A1,$00,$98,$00,$8F,$00,$87,$00
        .byte   $7F,$00,$78,$00,$72,$00,$6B,$00,$65,$00,$5F,$00,$5A,$00,$55,$00
        .byte   $50,$00,$4C,$00,$47,$00,$43,$00,$3F,$00,$3C,$00,$39,$00,$35,$00
        .byte   $32,$00,$2F,$00,$2D,$00,$2A,$00,$28,$00,$26,$00,$23,$00,$21,$00
        .byte   $1F,$00,$1E,$00,$1C,$00,$1A,$00,$19,$00,$17,$00,$16,$00,$15,$00
        .byte   $14,$00,$13,$00,$11,$00,$10,$00,$0F,$00,$0F,$00,$0E,$00,$0D,$00
        .byte   $0C,$00,$0B,$00,$0B,$00,$0A,$00,$0A,$00,$09,$00,$08,$00,$08,$00
        .byte   $07,$00,$07,$00,$07,$00,$06,$00,$06,$00,$05,$00,$05,$00,$05,$00
        .byte   $05,$00,$04,$00,$04,$00,$04,$00

; ---- UNCLAIMED (gap) $9932-$9932, 1 bytes
        .byte   $00

; ---- bank0.code_9933 (code) $9933-$9938, 6 bytes
L0_9933:
        lda     #$03
L0_9935:
        sta     $0301
        rts

; ---- UNCLAIMED (gap) $9939-$9939, 1 bytes
        .byte   $00

; ---- bank0.code_993A (code) $993A-$993D, 4 bytes
L0_993A:
        lda     #$01
        bne     L0_9935

; ---- UNCLAIMED (gap) $993E-$993E, 1 bytes
        .byte   $00

; ---- bank0.code_993F (code) $993F-$9941, 3 bytes
L0_993F:
        jmp     L0_97A8

; ---- bank0.snd_9942 (data) $9942-$995F, 30 bytes
; Note duration table
        .byte   $01,$02,$03,$04,$06,$08,$0C,$10,$18,$20,$30,$40,$60,$80,$C0,$00
        .byte   $09,$0B,$12,$15,$1E,$24,$2A,$2C,$2D,$3C,$42,$48,$54,$5A

; ---- bank0.tbl_9960 (data) $9960-$9960, 1 bytes
; Table, 1 bytes (structural extent)
        .byte   $0F

; ---- bank0.tbl_9961 (pointer_table) $9961-$9968, 8 bytes
; Pitch envelope pointers
        .byte   $69,$99,$72,$99,$94,$99,$A1,$99

; ---- bank0.snd_9969 (data) $9969-$99AC, 68 bytes
; Pitch envelope data
        .byte   $02,$01,$00,$FF,$FE,$FF,$00,$01,$82,$00,$00,$00,$00,$00,$00,$00
        .fill   18,$00
        .byte   $01,$00,$00,$FE,$00,$00,$01,$81,$08,$00,$00,$00,$01,$00,$00,$00
        .byte   $00,$00,$FF,$00,$00,$82,$00,$03,$01,$00,$FF,$FD,$FD,$FF,$00,$01
        .byte   $03,$81

; ---- bank0.tbl_99AD (pointer_table) $99AD-$99C4, 24 bytes
; Volume envelope pointers
        .byte   $C5,$99,$F3,$99,$FE,$99,$07,$9A,$2F,$9A,$3E,$9A,$41,$9A,$5F,$9A
        .byte   $6D,$9A,$A7,$9A,$6C,$9A,$B4,$9A

; ---- bank0.snd_99C5 (data) $99C5-$9ACC, 264 bytes
; Volume envelope data
        .byte   $00,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
        .byte   $0F,$0F,$0F,$0F,$0E,$0D,$0B,$0B,$0A,$0A,$09,$09,$09,$08,$08,$08
        .byte   $08,$07,$07,$07,$07,$06,$06,$06,$06,$05,$04,$03,$00,$80,$0F,$0D
        .byte   $0B,$0A,$09,$08,$07,$06,$04,$00,$80,$0F,$0B,$09,$08,$07,$06,$04
        .byte   $00,$80,$0F,$0F,$0E,$0D,$0C,$0B,$0A,$0A,$0A,$09,$09,$09,$09,$09
        .byte   $09,$09,$09,$08,$08,$08,$07,$07,$07,$06,$06,$06,$06,$05,$05,$05
        .byte   $04,$04,$04,$03,$03,$03,$02,$02,$00,$80,$0B,$0D,$0F,$0F,$0E,$0D
        .byte   $0C,$0B,$0A,$0A,$09,$09,$08,$07,$80,$00,$0F,$80,$06,$0A,$0E,$0F
        .byte   $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0E,$0D,$0C
        .byte   $0B,$0B,$0B,$0A,$0A,$0A,$09,$09,$08,$80,$06,$09,$0B,$0C,$0E,$0F
        .byte   $0F,$0E,$0C,$0A,$09,$08,$80,$00,$0F,$0F,$0E,$0D,$0C,$0B,$0A,$0A
        .byte   $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$08
        .byte   $08,$08,$08,$07,$07,$07,$07,$06,$06,$06,$06,$06,$05,$05,$05,$05
        .byte   $05,$04,$04,$04,$04,$03,$03,$03,$03,$03,$03,$02,$02,$02,$02,$02
        .byte   $01,$80,$08,$0A,$0C,$0E,$0F,$0F,$0E,$0D,$0C,$0B,$0B,$0A,$80,$00
        .byte   $0F,$0F,$0D,$0B,$0A,$0A,$09,$09,$09,$09,$08,$08,$07,$07,$06,$06
        .byte   $06,$05,$05,$04,$03,$02,$00,$80

; ---- bank0.snd_9ACD (music) $9ACD-$9ADE, 18 bytes
; Song data (2 tracks)
        .byte   $01,$06,$01,$3F,$06,$00,$00,$02,$00,$D8,$9A,$25,$E2,$27,$29,$2C
        .byte   $31,$82

; ---- UNCLAIMED (gap) $9ADF-$9ADF, 1 bytes
        .byte   $00

; ---- bank0.code_9AE0 (code) $9AE0-$9B03, 36 bytes
L0_9AE0:
        lda     #$01
        sta     $0307
        ldx     #$04
L0_9AE7:
        lda     $0358,X
        ora     #$30
        sta     $0358,X
        lda     $0300
        sta     $03C1,X
        lda     #$00
        sta     $03C8,X
        sta     $03CF,X
        dex
        bpl     L0_9AE7
        dec     $0307
        rts

; ---- bank0.tbl_9B04 (pointer_table) $9B04-$9B93, 144 bytes
; Song pointers (72 entries)
        .byte   $CD,$9A,$94,$9B,$2E,$9F,$B1,$A1,$FC,$A2,$52,$A4,$EA,$A5,$52,$A7
        .byte   $F8,$A8,$08,$AA,$42,$AC,$A5,$AC,$A5,$AC,$CD,$AD,$23,$AF,$1E,$B0
        .byte   $FC,$B2,$C5,$B3,$C5,$B3,$B7,$B4,$D7,$B5,$D7,$B5,$09,$B7,$84,$B7
        .byte   $80,$B8,$1D,$B9,$DB,$B9,$05,$BA,$4B,$BA,$E2,$BB,$0F,$9F,$3E,$99
        .byte   $F8,$BC,$08,$BD,$16,$BD,$2D,$BD,$48,$BD,$64,$BD,$74,$BD,$8C,$BD
        .byte   $AC,$BD,$B3,$9B,$C1,$BD,$D7,$BD,$EB,$BD,$CF,$9B,$FC,$BD,$12,$BE
        .byte   $27,$BE,$3E,$BE,$6E,$BE,$84,$BE,$9A,$BE,$B1,$BE,$C9,$BE,$DD,$BE
        .byte   $F4,$BE,$07,$BF,$1C,$BF,$1C,$BF,$27,$BF,$47,$BF,$47,$BF,$60,$BF
        .byte   $78,$BF,$8D,$BF,$A2,$BF,$B7,$BF,$3E,$99,$DF,$9A,$32,$99,$39,$99

; ---- bank0.snd_9B94 (music) $9B94-$9ECE, 827 bytes
; Song data (11 tracks)
        .byte   $03,$00,$01,$BF,$0A,$00,$00,$02,$00,$EB,$9B,$01,$01,$BC,$0A,$41
        .byte   $00,$02,$01,$0B,$9D,$02,$01,$BC,$03,$00,$24,$02,$02,$60,$9E,$01
        .byte   $04,$41,$BF,$00,$00,$00,$01,$03,$BE,$9B,$88,$70,$0D,$10,$E5,$86
        .byte   $01,$81,$70,$C1,$9B,$8C,$80,$50,$10,$EB,$82,$01,$04,$41,$BF,$00
        .byte   $00,$00,$01,$03,$DA,$9B,$8C,$80,$08,$88,$70,$0D,$03,$E5,$86,$FF
        .byte   $81,$70,$E0,$9B,$03,$EB,$82,$8F,$DE,$31,$E4,$31,$31,$2A,$E7,$36
        .byte   $E5,$31,$2F,$2E,$2C,$F6,$2F,$E4,$2F,$2F,$2A,$E7,$33,$E5,$2F,$31
        .byte   $33,$34,$F3,$31,$E5,$33,$34,$8F,$E7,$36,$ED,$86,$0C,$93,$29,$2A
        .byte   $F3,$28,$E3,$27,$28,$E7,$2F,$E4,$31,$33,$31,$E5,$00,$E3,$2A,$2A
        .byte   $F6,$2F,$F3,$2D,$E3,$2C,$2A,$E7,$28,$2A,$E5,$00,$E3,$31,$2A,$F3
        .byte   $2A,$E5,$2A,$2A,$2C,$EB,$93,$2D,$29,$F3,$27,$E3,$26,$29,$E7,$2E
        .byte   $E3,$00,$29,$00,$32,$E5,$00,$E3,$30,$30,$F6,$32,$E5,$00,$E3,$30
        .byte   $30,$E7,$32,$E5,$00,$E3,$30,$30,$E7,$37,$E5,$00,$E3,$33,$33,$F3
        .byte   $33,$E5,$35,$37,$39,$FC,$00,$E9,$86,$F4,$2A,$E9,$00,$E5,$2A,$2B
        .byte   $2D,$30,$E7,$2F,$2D,$2B,$2D,$E3,$00,$E5,$2A,$E3,$2A,$FA,$00,$E9
        .byte   $2A,$E9,$00,$E5,$2A,$2B,$2D,$30,$E7,$2F,$2D,$2B,$2D,$FC,$00,$E9
        .byte   $31,$E9,$00,$E5,$31,$32,$34,$37,$E7,$36,$34,$E5,$32,$F3,$32,$EB
        .byte   $00,$2F,$E9,$00,$E5,$2F,$31,$32,$34,$E7,$32,$31,$E5,$2D,$F3,$2F
        .byte   $EB,$37,$E5,$37,$00,$36,$00,$34,$32,$31,$2F,$E9,$00,$E5,$2F,$31
        .byte   $32,$34,$E7,$32,$34,$E5,$39,$F3,$36,$EB,$86,$0C,$85,$04,$32,$E7
        .byte   $31,$2F,$E5,$2D,$F3,$86,$F4,$85,$0A,$37,$E9,$00,$E5,$37,$36,$34
        .byte   $36,$E9,$34,$E7,$32,$E5,$34,$36,$EB,$2F,$E5,$2F,$31,$31,$32,$32
        .byte   $34,$34,$37,$E9,$00,$E5,$37,$36,$34,$36,$E9,$34,$E7,$32,$E5,$34
        .byte   $32,$ED,$94,$10,$80,$6E,$9C,$8F,$DE,$00,$E5,$31,$E4,$31,$31,$2A
        .byte   $E7,$36,$E5,$31,$2F,$E5,$2E,$2C,$85,$02,$92,$0D,$86,$0C,$83,$00
        .byte   $14,$17,$1C,$14,$E7,$86,$F4,$85,$0A,$92,$0B,$83,$41,$2F,$E4,$2F
        .byte   $2F,$2A,$E7,$33,$E5,$2F,$31,$33,$34,$F3,$31,$E5,$8F,$E7,$83,$00
        .byte   $33,$31,$EB,$92,$0C,$3D,$85,$02,$1C,$E4,$21,$23,$21,$23,$28,$23
        .byte   $28,$2C,$2F,$2C,$28,$2A,$25,$22,$25,$22,$1E,$22,$1E,$19,$1E,$19
        .byte   $16,$21,$25,$28,$25,$28,$2D,$28,$2D,$31,$34,$31,$2D,$31,$2E,$2A
        .byte   $2E,$2A,$25,$22,$E5,$85,$0A,$25,$25,$25,$27,$EB,$86,$0C,$92,$0D
        .byte   $22,$EB,$2E,$E5,$00,$E3,$2C,$2C,$F6,$2E,$E5,$00,$E3,$2B,$2B,$E7
        .byte   $2E,$E5,$00,$E3,$29,$29,$E7,$33,$E5,$00,$E3,$2E,$2E,$F3,$00,$36
        .byte   $FC,$00,$E9,$83,$41,$92,$0B,$86,$F4,$00,$E5,$2A,$E9,$00,$E5,$2A
        .byte   $2B,$2D,$E5,$30,$E7,$2F,$2D,$2B,$2D,$E3,$00,$E5,$2A,$E3,$2A,$F5
        .byte   $92,$0F,$83,$00,$32,$E3,$00,$E5,$2D,$E3,$2D,$F6,$00,$E5,$92,$0B
        .byte   $83,$41,$2A,$E9,$00,$E5,$2A,$2B,$2D,$30,$E7,$2F,$2D,$E7,$2B,$2D
        .byte   $FC,$00,$E9,$31,$E9,$00,$E5,$31,$32,$34,$37,$E7,$36,$34,$E5,$32
        .byte   $F3,$32,$F7,$86,$0C,$92,$0D,$83,$00,$85,$02,$00,$EB,$E5,$86,$F4
        .byte   $92,$0B,$85,$0A,$83,$41,$2F,$E9,$00,$E5,$2F,$31,$32,$34,$E7,$32
        .byte   $31,$E5,$2D,$F3,$2F,$EB,$37,$E5,$37,$00,$36,$00,$34,$32,$31,$2F
        .byte   $E9,$00,$E5,$2F,$31,$32,$34,$E7,$32,$34,$E5,$39,$F3,$36,$EB,$00
        .byte   $37,$E9,$00,$E5,$37,$36,$34,$36,$E9,$34,$E7,$32,$E5,$34,$36,$EB
        .byte   $2F,$E5,$2F,$31,$31,$32,$32,$34,$34,$37,$E9,$00,$E5,$37,$36,$34
        .byte   $36,$E9,$34,$E7,$32,$E5,$34,$32,$FE,$80,$AD,$9D,$8F,$DE,$12,$F6
        .byte   $10,$EB,$17,$F6,$15,$EB,$8F,$E7,$8A,$03,$89,$04,$85,$02,$12,$E4
        .byte   $12,$12,$12,$E7,$12,$12,$12,$E4,$12,$12,$12,$12,$12,$12,$12,$12
        .byte   $12,$E7,$90,$03,$9F,$10,$10,$10,$10,$12,$12,$12,$12,$15,$15,$15
        .byte   $15,$12,$12,$12,$12,$90,$00,$00,$8A,$03,$89,$04,$14,$14,$14,$E5
        .byte   $14,$14,$14,$90,$08,$9F,$88,$70,$18,$16,$11,$8B,$CF,$9E,$81,$70
        .byte   $AD,$9E,$90,$08,$9F,$88,$70,$1C,$0E,$E5,$09,$0E,$09,$0E,$09,$0E
        .byte   $09,$8B,$E7,$9E,$81,$70,$BC,$9E,$80,$B6,$9E

; ---- bank0.snd_9ECF (music) $9ECF-$9F02, 52 bytes
; Transpose table ($8B)
        .byte   $08,$00,$00,$00,$00,$00,$00,$00,$FD,$00,$00,$00,$FE,$00,$00,$00
        .byte   $FF,$00,$00,$00,$FE,$00,$00,$00,$00,$00,$F9,$02,$05,$00,$F9,$02
        .byte   $05,$00,$F9,$FE,$04,$00,$FE,$FE,$09,$00,$FB,$FE,$07,$00,$FB,$05
        .byte   $00,$00,$FB,$05

; ---- bank0.snd_9F03 (music) $9F03-$A160, 606 bytes
; Song data (7 tracks)
        .byte   $20,$64,$00,$03,$9F,$20,$20,$64,$20,$00,$08,$9F,$03,$00,$01,$BF
        .byte   $0A,$00,$00,$02,$00,$6E,$9C,$01,$01,$BC,$0A,$41,$00,$02,$01,$AD
        .byte   $9D,$02,$01,$BC,$03,$00,$24,$02,$02,$B6,$9E,$03,$00,$01,$BF,$04
        .byte   $00,$0F,$02,$00,$4D,$9F,$01,$01,$7F,$03,$00,$03,$02,$01,$E4,$9F
        .byte   $02,$01,$BC,$04,$00,$0F,$02,$02,$F1,$A0,$20,$E7,$1F,$1D,$E5,$1B
        .byte   $F3,$19,$EB,$16,$F3,$1B,$00,$E7,$20,$E7,$00,$E5,$1F,$E7,$20,$E5
        .byte   $22,$E7,$20,$E7,$1F,$1D,$E5,$1B,$F3,$19,$EB,$16,$F3,$1B,$00,$E7
        .byte   $20,$F3,$1F,$E7,$20,$00,$E5,$27,$E7,$00,$E5,$20,$F3,$00,$E7,$1F
        .byte   $F3,$20,$1F,$E7,$1B,$E7,$00,$E5,$1F,$F3,$00,$E7,$20,$E7,$00,$E5
        .byte   $1F,$E7,$20,$E5,$22,$E7,$27,$E7,$00,$E5,$20,$F3,$00,$E7,$1F,$F3
        .byte   $20,$1F,$E7,$1B,$E7,$00,$E5,$1F,$F3,$00,$E7,$20,$F3,$1F,$00,$E7
        .byte   $20,$E7,$1F,$1D,$E5,$1B,$F3,$19,$EB,$22,$F3,$1B,$00,$E7,$20,$E7
        .byte   $00,$E5,$1F,$E7,$20,$E5,$22,$E7,$20,$E7,$1F,$1D,$E5,$1B,$F3,$19
        .byte   $EB,$16,$F3,$1B,$00,$E7,$20,$F3,$1F,$E7,$20,$E7,$00,$E5,$80,$4D
        .byte   $9F,$90,$75,$A1,$88,$70,$0C,$11,$E3,$00,$1D,$1D,$8B,$61,$A1,$81
        .byte   $70,$EA,$9F,$18,$00,$13,$1F,$10,$10,$1C,$1C,$11,$11,$1D,$1D,$12
        .byte   $12,$1E,$1E,$88,$70,$0C,$11,$E3,$00,$1D,$1D,$8B,$61,$A1,$81,$70
        .byte   $09,$A0,$18,$00,$13,$1F,$10,$10,$1C,$1C,$90,$80,$A1,$11,$11,$1D
        .byte   $1D,$12,$12,$1E,$1E,$90,$75,$A1,$11,$11,$1D,$1D,$11,$00,$1D,$1D
        .byte   $00,$00,$11,$11,$1D,$1D,$1A,$1A,$19,$19,$0D,$0D,$0D,$00,$19,$19
        .byte   $00,$00,$0D,$0D,$19,$19,$0D,$0D,$0F,$0F,$1B,$1B,$0F,$00,$1B,$1B
        .byte   $00,$00,$1B,$1B,$19,$E5,$18,$E3,$18,$90,$88,$A1,$00,$E5,$18,$18
        .byte   $18,$18,$18,$18,$18,$90,$75,$A1,$11,$E3,$11,$1D,$1D,$11,$1D,$1D
        .byte   $1D,$00,$00,$11,$11,$1B,$1B,$1A,$1A,$19,$19,$0D,$0D,$0D,$00,$19
        .byte   $19,$00,$00,$0D,$0D,$19,$19,$0D,$0D,$88,$70,$04,$0F,$00,$1B,$1B
        .byte   $81,$70,$8F,$A0,$90,$90,$A1,$1F,$1F,$1C,$1C,$18,$18,$13,$13,$11
        .byte   $11,$10,$10,$11,$11,$12,$12,$90,$75,$A1,$88,$70,$0C,$11,$E3,$00
        .byte   $1D,$1D,$8B,$61,$A1,$81,$70,$B0,$A0,$18,$00,$13,$1F,$10,$10,$1C
        .byte   $1C,$11,$11,$1D,$1D,$12,$12,$1E,$1E,$88,$70,$0C,$11,$E3,$00,$1D
        .byte   $1D,$8B,$61,$A1,$81,$70,$CF,$A0,$90,$A1,$A1,$18,$00,$13,$1F,$10
        .byte   $10,$1C,$1C,$11,$11,$1D,$1D,$12,$12,$1E,$1E,$80,$E4,$9F,$88,$70
        .byte   $08,$24,$E7,$00,$E5,$24,$F3,$00,$E7,$8B,$6D,$A1,$81,$70,$F4,$A0
        .byte   $2C,$EB,$2B,$F3,$29,$27,$E7,$22,$EB,$28,$F3,$24,$F5,$1D,$E7,$1F
        .byte   $20,$22,$20,$F3,$25,$F5,$22,$E5,$1F,$1B,$22,$1F,$1B,$22,$1F,$1F
        .byte   $1C,$18,$1F,$1D,$1C,$1D,$1F,$24,$E7,$00,$E5,$24,$F3,$00,$E7,$2C
        .byte   $2B,$29,$E5,$27,$F3,$2B,$EB,$1C,$E7,$00,$E5,$28,$E7,$29,$E5,$2B
        .byte   $E7,$24,$E7,$00,$E5,$24,$F3,$00,$E7,$2C,$E7,$2B,$29,$E5,$27,$F3
        .byte   $2B,$EB,$1B,$E5,$1B,$1F,$1F,$22,$20,$1F,$22,$80,$F1,$A0

; ---- bank0.snd_A161 (music) $A161-$A174, 20 bytes
; Transpose table ($8B)
        .byte   $02,$00,$00,$00,$02,$00,$00,$00,$FC,$00,$00,$00,$08,$FD,$02,$F9
        .byte   $08,$FD,$02,$F9

; ---- bank0.snd_A175 (music) $A175-$A2DC, 360 bytes
; Song data (9 tracks)
        .byte   $20,$20,$20,$20,$64,$20,$20,$20,$00,$75,$A1,$64,$20,$64,$64,$64
        .byte   $64,$64,$64,$20,$20,$64,$20,$20,$64,$64,$64,$64,$20,$20,$20,$64
        .byte   $20,$20,$20,$64,$20,$20,$20,$64,$64,$20,$64,$20,$64,$20,$64,$20
        .byte   $64,$20,$64,$20,$64,$64,$64,$20,$64,$20,$64,$20,$03,$00,$01,$BE
        .byte   $04,$00,$0C,$02,$02,$D0,$A1,$01,$01,$BB,$04,$00,$00,$02,$01,$3F
        .byte   $A2,$02,$01,$7F,$03,$00,$0C,$02,$00,$B9,$A2,$8F,$EF,$88,$70,$04
        .byte   $31,$E5,$34,$33,$34,$31,$34,$33,$34,$81,$70,$D5,$A1,$30,$33,$31
        .byte   $33,$30,$33,$31,$33,$33,$38,$36,$38,$33,$38,$36,$38,$31,$37,$34
        .byte   $37,$31,$37,$34,$37,$31,$36,$35,$36,$31,$36,$35,$36,$31,$34,$39
        .byte   $3D,$40,$3D,$39,$34,$2E,$33,$37,$3A,$3F,$3A,$37,$33,$2D,$32,$36
        .byte   $39,$3C,$39,$36,$32,$2C,$31,$35,$38,$3D,$38,$35,$31,$2B,$30,$34
        .byte   $37,$3C,$37,$34,$30,$88,$70,$04,$2F,$E3,$2E,$81,$70,$2D,$A2,$2F
        .byte   $33,$36,$3B,$33,$36,$3F,$42,$80,$D2,$A1,$8F,$EF,$00,$E3,$00,$E5
        .byte   $88,$70,$04,$31,$E5,$34,$33,$34,$31,$34,$33,$34,$81,$70,$48,$A2
        .byte   $30,$33,$31,$33,$30,$33,$31,$33,$33,$38,$36,$38,$33,$38,$36,$38
        .byte   $31,$37,$34,$37,$31,$37,$34,$37,$31,$36,$35,$36,$31,$36,$35,$36
        .byte   $83,$41,$31,$34,$39,$3D,$40,$3D,$39,$34,$2E,$33,$37,$3A,$3F,$3A
        .byte   $37,$33,$83,$00,$2D,$32,$36,$39,$3C,$39,$36,$32,$2C,$31,$35,$38
        .byte   $3D,$38,$35,$E3,$00,$83,$42,$2B,$E5,$30,$34,$37,$3C,$37,$34,$30
        .byte   $88,$70,$04,$2F,$E3,$2E,$81,$70,$A8,$A2,$2F,$E5,$33,$36,$3B,$83
        .byte   $00,$80,$43,$A2,$8F,$EF,$90,$EB,$A2,$88,$70,$0E,$0D,$E3,$00,$0D
        .byte   $01,$0D,$01,$19,$E5,$0D,$E3,$01,$19,$01,$0D,$00,$19,$E5,$8B,$DD
        .byte   $A2,$81,$70,$C1,$A2,$80,$BE,$A2

; ---- bank0.snd_A2DD (music) $A2DD-$A2EA, 14 bytes
; Transpose table ($8B)
        .byte   $02,$FF,$FF,$FF,$FF,$FF,$FE,$FF,$FF,$00,$FF,$08,$F8,$08

; ---- bank0.snd_A2EB (music) $A2EB-$A424, 314 bytes
; Song data (5 tracks)
        .byte   $64,$20,$64,$44,$64,$44,$20,$64,$44,$64,$44,$64,$20,$64,$00,$EB
        .byte   $A2,$03,$00,$01,$BF,$01,$00,$18,$03,$00,$1B,$A3,$01,$01,$7F,$04
        .byte   $00,$00,$03,$01,$BA,$A3,$02,$01,$BF,$02,$00,$18,$03,$02,$02,$A4
        .byte   $8F,$F8,$19,$E5,$20,$1E,$E3,$23,$E5,$20,$E3,$25,$E5,$20,$23,$25
        .byte   $28,$F3,$27,$E5,$25,$E9,$2A,$E1,$2B,$E2,$2C,$F3,$00,$E3,$2F,$E5
        .byte   $2C,$E3,$2B,$E5,$2A,$E3,$28,$E5,$25,$E5,$23,$20,$1E,$20,$23,$E3
        .byte   $20,$E5,$1F,$E3,$1E,$1C,$19,$E5,$1C,$19,$E3,$1E,$E5,$19,$E3,$1F
        .byte   $E5,$19,$1E,$1C,$19,$1C,$19,$E3,$1E,$E5,$19,$E3,$1F,$E5,$19,$1E
        .byte   $1C,$19,$1C,$19,$E3,$1E,$E5,$19,$E3,$20,$E5,$19,$1E,$20,$25,$E3
        .byte   $23,$E5,$20,$E3,$1E,$E5,$20,$E3,$00,$23,$00,$20,$00,$1E,$E5,$1C
        .byte   $2A,$E1,$2B,$E2,$2C,$F4,$2F,$E5,$00,$F3,$2A,$E1,$2B,$E2,$2C,$F4
        .byte   $27,$E5,$00,$F3,$25,$E1,$27,$E2,$28,$F4,$2C,$E5,$2A,$28,$27,$25
        .byte   $E3,$23,$E5,$20,$E3,$1E,$E5,$20,$23,$20,$1E,$1B,$80,$1D,$A3,$8F
        .byte   $F8,$88,$70,$03,$25,$E5,$2C,$2A,$E3,$2F,$E5,$2C,$E3,$31,$E5,$2A
        .byte   $2F,$2C,$81,$70,$BF,$A3,$27,$2C,$2A,$E3,$2C,$E5,$2A,$E3,$30,$E5
        .byte   $2A,$2C,$2A,$88,$70,$03,$25,$2C,$2A,$E3,$2F,$E5,$2C,$E3,$31,$E5
        .byte   $2A,$2C,$2F,$81,$70,$E1,$A3,$27,$2C,$2A,$E3,$2C,$E5,$2A,$E3,$30
        .byte   $E5,$2A,$2C,$33,$80,$BC,$A3,$8F,$F8,$90,$43,$A4,$88,$70,$1E,$19
        .byte   $E2,$00,$19,$8B,$25,$A4,$81,$70,$0A,$A4,$90,$4C,$A4,$86,$FB,$19
        .byte   $00,$19,$19,$00,$19,$86,$05,$80,$04,$A4

; ---- bank0.snd_A425 (music) $A425-$A442, 30 bytes
; Transpose table ($8B)
        .byte   $05,$00,$00,$00,$00,$00,$FF,$00,$00,$00,$00,$00,$00,$00,$FE,$00
        .byte   $00,$00,$00,$00,$00,$00,$FE,$00,$00,$00,$00,$00,$00,$00

; ---- bank0.snd_A443 (music) $A443-$A5BE, 380 bytes
; Song data (6 tracks)
        .byte   $20,$20,$20,$64,$20,$20,$00,$43,$A4,$20,$20,$64,$64,$44,$64,$03
        .byte   $00,$01,$BF,$04,$00,$00,$02,$00,$71,$A4,$01,$01,$BC,$03,$00,$00
        .byte   $02,$01,$1D,$A5,$02,$01,$BE,$03,$00,$18,$02,$02,$9C,$A5,$8F,$CD
        .byte   $2C,$E5,$31,$34,$E3,$33,$E5,$31,$E3,$39,$E5,$38,$36,$E3,$34,$E5
        .byte   $00,$E3,$31,$EB,$2F,$E5,$36,$39,$E3,$38,$E5,$36,$E3,$3D,$E5,$3B
        .byte   $39,$E3,$36,$E5,$00,$E3,$38,$E9,$3C,$3D,$E5,$38,$E3,$3D,$E5,$37
        .byte   $E3,$3D,$E5,$36,$3D,$34,$3D,$31,$E5,$31,$E3,$31,$E5,$31,$E3,$31
        .byte   $E5,$38,$37,$36,$E3,$34,$F1,$31,$E5,$31,$E3,$31,$E5,$31,$E3,$31
        .byte   $E5,$31,$31,$2F,$2F,$2C,$EB,$85,$09,$2A,$F3,$2C,$E5,$28,$F3,$2A
        .byte   $E5,$27,$F3,$28,$E5,$25,$E9,$27,$F3,$28,$E5,$2A,$27,$28,$2A,$2C
        .byte   $E9,$27,$28,$F3,$2A,$E5,$2C,$28,$2A,$2C,$2F,$E9,$2D,$F3,$31,$E5
        .byte   $31,$E7,$2F,$2A,$E5,$2F,$F3,$2C,$EB,$85,$04,$83,$41,$34,$E5,$34
        .byte   $00,$F3,$34,$E5,$36,$38,$3B,$E7,$39,$38,$E5,$34,$F3,$36,$E9,$00
        .byte   $E5,$34,$36,$34,$34,$E9,$33,$80,$73,$A4,$8F,$CD,$85,$03,$92,$0C
        .byte   $88,$70,$10,$25,$E3,$20,$20,$20,$8B,$BF,$A5,$81,$70,$26,$A5,$92
        .byte   $0E,$88,$70,$04,$25,$20,$20,$25,$31,$25,$25,$2C,$25,$20,$20,$25
        .byte   $31,$25,$25,$2C,$8B,$CF,$A5,$81,$70,$37,$A5,$25,$20,$92,$0D,$85
        .byte   $09,$83,$41,$2A,$F3,$2C,$E5,$28,$F3,$2A,$E5,$27,$F3,$28,$E5,$25
        .byte   $E9,$27,$F3,$28,$E5,$2A,$27,$28,$2A,$2C,$E9,$27,$28,$F3,$2A,$E5
        .byte   $2C,$28,$2A,$2C,$2F,$E9,$2D,$F3,$31,$E5,$31,$E7,$2F,$2A,$2F,$2C
        .byte   $F7,$85,$03,$92,$0C,$88,$70,$10,$25,$E3,$20,$20,$20,$8B,$BF,$A5
        .byte   $81,$70,$8B,$A5,$83,$00,$80,$1F,$A5,$8F,$CD,$90,$D7,$A5,$88,$70
        .byte   $04,$19,$E3,$00,$19,$25,$01,$19,$25,$01,$19,$00,$19,$25,$00,$19
        .byte   $25,$01,$8B,$D3,$A5,$81,$70,$A4,$A5,$80,$9E,$A5

; ---- bank0.snd_A5BF (music) $A5BF-$A5D6, 24 bytes
; Transpose table ($8B)
        .byte   $05,$00,$00,$00,$FD,$00,$00,$00,$02,$00,$00,$00,$FC,$00,$00,$00
        .byte   $05,$FD,$02,$FC,$05,$FD,$02,$FC

; ---- bank0.snd_A5D7 (music) $A5D7-$A724, 334 bytes
; Song data (5 tracks)
        .byte   $66,$20,$66,$20,$46,$66,$20,$46,$66,$20,$66,$20,$20,$66,$66,$46
        .byte   $00,$D7,$A5,$03,$00,$01,$3F,$04,$00,$F4,$01,$00,$09,$A6,$01,$01
        .byte   $3C,$02,$41,$F4,$01,$01,$6C,$A6,$02,$01,$BB,$03,$00,$18,$01,$02
        .byte   $73,$A6,$8F,$91,$88,$70,$08,$2C,$E5,$2C,$2C,$2C,$2C,$2C,$2C,$2C
        .byte   $8B,$25,$A7,$81,$70,$0E,$A6,$3D,$3C,$E7,$38,$E5,$00,$33,$30,$E7
        .byte   $2C,$E7,$30,$33,$E5,$38,$E7,$00,$E5,$3B,$E5,$3A,$E7,$36,$E5,$00
        .byte   $31,$2E,$E7,$2A,$2E,$31,$E5,$36,$E7,$00,$E5,$35,$ED,$35,$F6,$36
        .byte   $E7,$38,$E9,$00,$E5,$38,$3A,$3B,$3D,$F6,$3B,$E7,$3A,$E9,$00,$E5
        .byte   $36,$38,$3A,$38,$EB,$86,$0C,$00,$E5,$38,$38,$38,$38,$38,$38,$38
        .byte   $86,$F4,$80,$0B,$A6,$8F,$91,$00,$F1,$80,$0B,$A6,$8F,$91,$90,$3F
        .byte   $A7,$88,$70,$10,$19,$E3,$00,$19,$00,$19,$00,$19,$00,$8B,$2D,$A7
        .byte   $81,$70,$7B,$A6,$88,$70,$02,$14,$00,$14,$00,$00,$00,$20,$00,$00
        .byte   $00,$14,$00,$20,$00,$14,$00,$14,$00,$14,$00,$14,$00,$14,$00,$20
        .byte   $00,$20,$00,$20,$00,$20,$00,$8B,$3D,$A7,$81,$70,$8E,$A6,$19,$00
        .byte   $25,$00,$00,$00,$19,$00,$00,$00,$19,$00,$20,$00,$25,$00,$19,$00
        .byte   $19,$00,$25,$00,$20,$00,$19,$00,$25,$00,$20,$00,$25,$00,$88,$70
        .byte   $03,$17,$00,$23,$00,$1E,$00,$23,$00,$81,$70,$D8,$A6,$17,$00,$1E
        .byte   $00,$23,$00,$17,$00,$88,$70,$03,$16,$00,$22,$00,$1D,$00,$22,$00
        .byte   $81,$70,$EF,$A6,$16,$00,$1D,$00,$22,$00,$16,$00,$88,$70,$02,$14
        .byte   $00,$20,$00,$1B,$00,$20,$00,$81,$70,$06,$A7,$14,$00,$2C,$00,$2C
        .byte   $00,$2C,$00,$2C,$00,$2C,$00,$2C,$2C,$2C,$00,$80,$75,$A6

; ---- bank0.snd_A725 (music) $A725-$A73E, 26 bytes
; Transpose table ($8B)
        .byte   $EF,$01,$04,$04,$03,$01,$03,$01,$00,$00,$FE,$00,$FF,$00,$03,$00
        .byte   $00,$00,$FE,$00,$FF,$00,$03,$00,$02,$FE

; ---- bank0.snd_A73F (music) $A73F-$A8AD, 367 bytes
; Song data (5 tracks)
        .byte   $66,$66,$66,$20,$66,$20,$66,$20,$66,$20,$66,$20,$66,$66,$66,$20
        .byte   $00,$3F,$A7,$03,$00,$01,$7F,$04,$00,$00,$02,$00,$71,$A7,$01,$01
        .byte   $7D,$04,$41,$0C,$02,$01,$BC,$A7,$02,$01,$BF,$03,$00,$18,$02,$02
        .byte   $F0,$A7,$29,$EB,$29,$E7,$2B,$2C,$2E,$27,$FC,$00,$E9,$29,$EB,$29
        .byte   $E7,$2B,$2C,$2E,$27,$EB,$2E,$F3,$2B,$27,$E7,$25,$F3,$2C,$2B,$E7
        .byte   $27,$27,$E5,$2E,$E7,$2E,$E5,$2B,$E7,$30,$F3,$37,$F5,$35,$E7,$37
        .byte   $38,$37,$25,$F3,$2C,$2B,$E7,$27,$27,$E5,$2E,$E7,$2E,$E5,$2B,$E7
        .byte   $30,$F3,$33,$37,$E7,$3A,$F3,$38,$37,$E7,$80,$71,$A7,$18,$F3,$83
        .byte   $00,$3C,$FB,$00,$E7,$83,$41,$1F,$ED,$18,$F3,$83,$00,$3C,$F5,$83
        .byte   $41,$30,$EB,$1F,$83,$00,$3A,$F3,$37,$F5,$83,$41,$1D,$EB,$1F,$1C
        .byte   $1D,$E7,$1F,$20,$1F,$1D,$EB,$1F,$1C,$24,$F3,$28,$2B,$E7,$80,$BC
        .byte   $A7,$90,$B5,$A8,$88,$70,$07,$11,$E3,$00,$11,$00,$0F,$00,$11,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00,$8B,$AE,$A8,$81,$70,$F6,$A7,$90
        .byte   $C8,$A8,$18,$E3,$00,$18,$00,$1A,$00,$1A,$00,$1B,$00,$1B,$00,$1D
        .byte   $00,$1D,$00,$90,$B5,$A8,$19,$00,$0D,$00,$20,$00,$14,$00,$1F,$00
        .byte   $20,$00,$19,$00,$19,$00,$1B,$00,$1B,$00,$16,$00,$16,$00,$14,$00
        .byte   $14,$00,$13,$00,$13,$00,$18,$00,$18,$00,$1F,$00,$1F,$00,$1D,$00
        .byte   $1D,$00,$1B,$00,$1B,$00,$1D,$00,$11,$00,$1B,$00,$0F,$00,$19,$00
        .byte   $0D,$00,$18,$00,$18,$00,$19,$00,$0D,$00,$20,$00,$14,$00,$1F,$00
        .byte   $20,$00,$19,$00,$19,$00,$1B,$00,$1B,$00,$16,$00,$16,$00,$14,$00
        .byte   $14,$00,$13,$00,$13,$00,$90,$D8,$A8,$18,$00,$18,$00,$18,$00,$1B
        .byte   $00,$1B,$00,$1B,$00,$13,$00,$13,$00,$90,$E8,$A8,$13,$00,$16,$00
        .byte   $16,$00,$16,$00,$14,$00,$14,$00,$13,$00,$13,$00,$80,$F0,$A7

; ---- bank0.snd_A8AE (music) $A8AE-$A8B4, 7 bytes
; Transpose table ($8B)
        .byte   $F9,$07,$00,$F9,$00,$07,$00

; ---- bank0.snd_A8B5 (music) $A8B5-$A9F1, 317 bytes
; Song data (8 tracks)
        .byte   $20,$20,$20,$20,$64,$20,$20,$20,$20,$20,$20,$20,$64,$20,$20,$20
        .byte   $00,$B5,$A8,$20,$20,$20,$20,$64,$20,$20,$20,$20,$20,$64,$20,$64
        .byte   $20,$64,$20,$64,$20,$20,$20,$20,$20,$64,$20,$20,$20,$20,$20,$64
        .byte   $20,$20,$20,$20,$20,$64,$20,$20,$20,$20,$20,$64,$20,$64,$64,$64
        .byte   $64,$64,$64,$03,$00,$01,$7F,$09,$00,$FB,$02,$00,$17,$A9,$01,$01
        .byte   $BE,$04,$00,$FB,$02,$01,$58,$A9,$02,$01,$BC,$03,$00,$1F,$02,$02
        .byte   $B8,$A9,$8F,$D6,$85,$04,$83,$00,$88,$70,$02,$25,$E3,$00,$25,$25
        .byte   $00,$25,$25,$00,$28,$E5,$28,$27,$E3,$25,$23,$20,$25,$00,$25,$25
        .byte   $00,$25,$25,$00,$2D,$E5,$2D,$2C,$E3,$2A,$28,$27,$81,$70,$20,$A9
        .byte   $85,$09,$83,$41,$2A,$E9,$30,$2C,$EB,$2F,$E9,$34,$33,$EB,$32,$ED
        .byte   $80,$19,$A9,$8F,$D6,$00,$ED,$00,$20,$E3,$20,$20,$20,$2C,$2C,$2A
        .byte   $2A,$28,$28,$27,$27,$25,$20,$25,$27,$24,$24,$24,$24,$24,$24,$24
        .byte   $24,$30,$30,$30,$30,$30,$30,$30,$30,$23,$23,$23,$23,$2F,$2F,$2D
        .byte   $2D,$2C,$2C,$2A,$2A,$2C,$2C,$2D,$2D,$2A,$2A,$2A,$2A,$2A,$2A,$2A
        .byte   $2A,$33,$33,$33,$33,$33,$33,$33,$33,$88,$70,$02,$28,$00,$28,$28
        .byte   $00,$28,$28,$00,$81,$70,$A1,$A9,$88,$70,$10,$34,$81,$70,$B0,$A9
        .byte   $80,$5A,$A9,$8F,$D6,$90,$F8,$A9,$88,$70,$04,$19,$E3,$00,$19,$19
        .byte   $00,$19,$19,$00,$15,$15,$15,$15,$17,$17,$17,$17,$81,$70,$C0,$A9
        .byte   $88,$70,$06,$14,$00,$14,$14,$00,$14,$14,$00,$14,$00,$14,$14,$00
        .byte   $14,$14,$00,$8B,$F2,$A9,$81,$70,$D8,$A9,$80,$BA,$A9

; ---- bank0.snd_A9F2 (music) $A9F2-$A9F7, 6 bytes
; Transpose table ($8B)
        .byte   $04,$00,$FE,$00,$FE,$00

; ---- bank0.snd_A9F8 (music) $A9F8-$ABFF, 520 bytes
; Song data (5 tracks)
        .byte   $66,$20,$66,$66,$66,$66,$66,$66,$20,$66,$66,$20,$66,$00,$F8,$A9
        .byte   $03,$00,$01,$7F,$04,$00,$02,$01,$00,$27,$AA,$01,$01,$7C,$04,$41
        .byte   $02,$01,$01,$C7,$AA,$02,$01,$BF,$03,$00,$1A,$01,$02,$69,$AB,$8F
        .byte   $91,$2E,$E7,$00,$E4,$00,$2C,$00,$E7,$2C,$00,$E4,$00,$2B,$00,$E7
        .byte   $2B,$00,$E4,$00,$29,$2E,$E7,$00,$E4,$00,$2C,$00,$E7,$2C,$00,$E4
        .byte   $00,$2B,$00,$E7,$2B,$E5,$00,$29,$00,$3A,$E7,$00,$E4,$00,$38,$00
        .byte   $E7,$38,$00,$E4,$00,$37,$00,$E7,$37,$00,$E4,$00,$35,$3A,$E7,$00
        .byte   $E4,$00,$38,$00,$E7,$38,$00,$E4,$00,$37,$00,$E7,$37,$E5,$00,$35
        .byte   $00,$33,$E8,$00,$E4,$3A,$E8,$37,$E5,$00,$32,$E8,$00,$E4,$35,$E8
        .byte   $3A,$E5,$00,$31,$E8,$00,$E4,$38,$E8,$35,$E5,$00,$30,$E8,$00,$E4
        .byte   $33,$E8,$38,$E5,$00,$33,$E8,$00,$E4,$3A,$E8,$37,$E5,$00,$32,$E8
        .byte   $00,$E4,$35,$E8,$3A,$E5,$00,$31,$E8,$00,$E4,$38,$E9,$00,$E4,$38
        .byte   $E8,$00,$E4,$37,$E6,$00,$38,$E7,$3A,$FC,$00,$E9,$80,$29,$AA,$8F
        .byte   $91,$00,$F1,$2E,$E7,$00,$E4,$00,$2C,$00,$E7,$2C,$00,$E4,$00,$2B
        .byte   $00,$E7,$2B,$00,$E4,$00,$29,$2E,$E7,$00,$E4,$00,$2C,$00,$E7,$2C
        .byte   $00,$E4,$00,$2B,$00,$E7,$2B,$E5,$00,$29,$00,$3A,$E7,$00,$E4,$00
        .byte   $38,$00,$E7,$38,$00,$E4,$00,$37,$00,$E7,$37,$00,$E4,$00,$35,$3A
        .byte   $E7,$00,$E4,$00,$38,$00,$E7,$38,$00,$E4,$00,$37,$00,$E7,$37,$E5
        .byte   $00,$35,$00,$33,$E8,$00,$E4,$3A,$E8,$37,$E5,$00,$32,$E8,$00,$E4
        .byte   $35,$E8,$3A,$E5,$00,$31,$E8,$00,$E4,$38,$E8,$35,$E5,$00,$30,$E8
        .byte   $00,$E4,$33,$E8,$38,$E5,$00,$33,$E8,$00,$E4,$3A,$E8,$37,$E5,$00
        .byte   $32,$E8,$00,$E4,$35,$E8,$3A,$E5,$00,$31,$E8,$00,$E4,$38,$E9,$00
        .byte   $E4,$38,$E8,$00,$E4,$37,$E6,$00,$38,$E7,$3A,$FC,$00,$E9,$80,$CB
        .byte   $AA,$8F,$91,$90,$06,$AC,$88,$70,$03,$16,$E4,$00,$16,$16,$00,$16
        .byte   $16,$00,$16,$16,$00,$16,$81,$70,$71,$AB,$90,$0F,$AC,$16,$01,$16
        .byte   $13,$01,$13,$14,$01,$14,$15,$01,$15,$90,$06,$AC,$88,$70,$03,$16
        .byte   $00,$16,$16,$00,$16,$16,$00,$16,$16,$00,$16,$81,$70,$97,$AB,$90
        .byte   $1B,$AC,$16,$01,$16,$18,$01,$18,$19,$01,$19,$1A,$01,$1A,$90,$27
        .byte   $AC,$88,$70,$06,$1B,$00,$1B,$1B,$00,$1B,$1B,$00,$1B,$1B,$00,$1B
        .byte   $8B,$00,$AC,$81,$70,$BC,$AB,$90,$06,$AC,$88,$70,$02,$0D,$00,$0D
        .byte   $0D,$00,$0D,$0D,$00,$0D,$0D,$00,$0D,$81,$70,$D5,$AB,$16,$00,$16
        .byte   $16,$00,$16,$16,$00,$16,$16,$00,$16,$16,$01,$16,$13,$13,$13,$14
        .byte   $14,$14,$15,$15,$15,$80,$6B,$AB

; ---- bank0.snd_AC00 (music) $AC00-$AC05, 6 bytes
; Transpose table ($8B)
        .byte   $01,$FF,$03,$FF,$FF,$FF

; ---- bank0.snd_AC06 (music) $AC06-$AF12, 781 bytes
; Song data (21 tracks)
        .byte   $20,$20,$20,$64,$20,$20,$00,$06,$AC,$20,$20,$20,$64,$20,$20,$64
        .byte   $64,$64,$64,$20,$64,$20,$20,$20,$64,$20,$20,$20,$20,$20,$64,$64
        .byte   $64,$20,$20,$20,$64,$20,$20,$20,$20,$20,$64,$20,$20,$20,$20,$20
        .byte   $64,$20,$20,$20,$20,$20,$64,$20,$64,$00,$27,$AC,$03,$00,$41,$7F
        .byte   $04,$00,$07,$02,$00,$61,$AC,$01,$41,$7C,$04,$41,$07,$02,$01,$82
        .byte   $AC,$02,$41,$BF,$01,$00,$13,$02,$02,$89,$AC,$8F,$BC,$2C,$E5,$25
        .byte   $28,$2C,$E7,$2A,$E5,$28,$E7,$27,$E5,$2A,$E7,$28,$E5,$8F,$A0,$28
        .byte   $21,$25,$8F,$8C,$27,$23,$1E,$8F,$78,$20,$F6,$82,$8F,$BC,$00,$E4
        .byte   $80,$63,$AC,$8F,$BC,$19,$F3,$15,$17,$14,$E5,$17,$1B,$8F,$A0,$1C
        .byte   $E7,$1B,$E5,$8F,$8C,$1E,$1C,$1B,$8F,$78,$19,$F3,$00,$EC,$84,$03
        .byte   $00,$01,$7F,$04,$00,$0C,$01,$00,$C4,$AC,$01,$01,$3D,$03,$00,$00
        .byte   $01,$01,$45,$AD,$02,$01,$BF,$03,$00,$18,$01,$02,$7A,$AD,$8F,$8D
        .byte   $88,$70,$06,$19,$E4,$00,$19,$81,$70,$C9,$AC,$1C,$E7,$1E,$88,$70
        .byte   $06,$19,$E4,$00,$19,$81,$70,$D7,$AC,$1E,$E7,$23,$20,$E9,$22,$23
        .byte   $22,$E7,$27,$23,$E9,$25,$27,$28,$E7,$2A,$88,$70,$02,$25,$28,$E5
        .byte   $00,$E3,$25,$E7,$25,$E3,$2A,$F1,$25,$E3,$2C,$E7,$25,$2F,$31,$81
        .byte   $70,$F3,$AC,$34,$E9,$33,$31,$2F,$E7,$33,$2C,$E9,$2A,$28,$E9,$27
        .byte   $E7,$2C,$88,$70,$02,$25,$28,$E5,$00,$E3,$25,$E7,$25,$E3,$2A,$F1
        .byte   $25,$E3,$2C,$E7,$25,$2F,$31,$81,$70,$1B,$AD,$34,$E9,$33,$31,$E9
        .byte   $2F,$E7,$33,$38,$E9,$36,$34,$34,$E5,$33,$31,$2F,$80,$C6,$AC,$8F
        .byte   $8D,$88,$70,$02,$88,$77,$06,$25,$E4,$25,$31,$81,$77,$4D,$AD,$21
        .byte   $21,$2D,$23,$23,$2F,$81,$70,$4A,$AD,$88,$70,$02,$88,$77,$06,$25
        .byte   $E4,$25,$31,$81,$77,$65,$AD,$21,$21,$2D,$23,$23,$2F,$81,$70,$62
        .byte   $AD,$80,$47,$AD,$8F,$8D,$90,$C9,$AD,$88,$70,$02,$88,$77,$03,$92
        .byte   $0B,$19,$E4,$19,$19,$92,$0F,$19,$92,$0B,$19,$19,$81,$77,$85,$AD
        .byte   $15,$00,$00,$92,$0F,$17,$92,$0B,$00,$00,$81,$70,$82,$AD,$88,$70
        .byte   $02,$88,$77,$03,$14,$14,$14,$92,$0F,$14,$92,$0B,$14,$14,$81,$77
        .byte   $AA,$AD,$12,$00,$00,$92,$0F,$17,$92,$0B,$00,$00,$81,$70,$A7,$AD
        .byte   $80,$7F,$AD,$64,$00,$C9,$AD,$03,$00,$01,$7F,$04,$00,$00,$01,$00
        .byte   $EC,$AD,$01,$01,$7F,$02,$00,$00,$01,$01,$4C,$AE,$02,$02,$BC,$03
        .byte   $00,$0C,$01,$02,$82,$AE,$8F,$A0,$85,$04,$88,$70,$04,$2C,$E7,$27
        .byte   $29,$E5,$2A,$E7,$2A,$2A,$E5,$2A,$2A,$2A,$29,$27,$E7,$81,$70,$F3
        .byte   $AD,$88,$70,$02,$2F,$E7,$2A,$2C,$E5,$2D,$E7,$2D,$2D,$E5,$2D,$2D
        .byte   $2D,$2C,$2A,$E7,$81,$70,$0A,$AE,$88,$70,$02,$2C,$E7,$27,$29,$E5
        .byte   $2A,$E7,$2A,$2A,$E5,$2A,$2A,$2A,$29,$27,$E7,$81,$70,$21,$AE,$85
        .byte   $09,$2A,$E9,$34,$2F,$00,$E5,$2F,$31,$33,$31,$E9,$2C,$2E,$00,$E5
        .byte   $2E,$2F,$31,$80,$EE,$AD,$8F,$A0,$88,$70,$10,$14,$E5,$14,$14,$14
        .byte   $14,$14,$14,$14,$8B,$13,$AF,$81,$70,$51,$AE,$88,$70,$02,$10,$10
        .byte   $10,$10,$10,$10,$1C,$17,$81,$70,$64,$AE,$88,$70,$02,$12,$12,$12
        .byte   $12,$12,$12,$1E,$19,$81,$70,$73,$AE,$80,$4E,$AE,$8F,$A0,$89,$04
        .byte   $88,$70,$03,$00,$E7,$01,$E5,$00,$E7,$01,$E5,$00,$01,$00,$F6,$01
        .byte   $E5,$00,$81,$70,$89,$AE,$00,$E7,$01,$E5,$00,$E7,$01,$E5,$00,$01
        .byte   $00,$E9,$01,$E5,$01,$01,$01,$00,$E7,$01,$E5,$00,$E7,$01,$E5,$00
        .byte   $01,$00,$F6,$01,$E5,$00,$00,$E7,$01,$E5,$00,$E7,$01,$E5,$00,$01
        .byte   $00,$F5,$01,$E5,$01,$00,$00,$E7,$01,$E5,$00,$E7,$01,$E5,$00,$01
        .byte   $00,$F6,$01,$E5,$00,$00,$E7,$01,$E5,$00,$E7,$01,$E5,$00,$01,$00
        .byte   $E9,$01,$E5,$01,$01,$01,$00,$E7,$01,$E5,$00,$F3,$01,$E5,$00,$F3
        .byte   $01,$E5,$00,$F3,$01,$E5,$01,$00,$E7,$01,$E5,$00,$F3,$01,$E5,$00
        .byte   $F3,$01,$E5,$00,$F3,$01,$E3,$01,$01,$01,$80,$86,$AE

; ---- bank0.snd_AF13 (music) $AF13-$AF22, 16 bytes
; Transpose table ($8B)
        .byte   $00,$00,$00,$00,$FD,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00

; ---- bank0.snd_AF23 (music) $AF23-$B00E, 236 bytes
; Song data (5 tracks)
        .byte   $04,$00,$01,$7F,$09,$00,$03,$02,$00,$4C,$AF,$01,$01,$BE,$09,$01
        .byte   $0F,$02,$02,$99,$AF,$02,$01,$3F,$02,$00,$03,$02,$01,$BF,$AF,$03
        .byte   $02,$BF,$03,$00,$00,$02,$03,$F7,$AF,$8F,$F8,$88,$70,$02,$25,$E5
        .byte   $25,$20,$E3,$23,$F1,$25,$E5,$25,$2C,$28,$2B,$E9,$26,$81,$70,$51
        .byte   $AF,$2E,$EB,$88,$70,$02,$2C,$E5,$2C,$2F,$E3,$2E,$F1,$2C,$E5,$2C
        .byte   $33,$2F,$2A,$2A,$2D,$E3,$2C,$F1,$2A,$E5,$2A,$31,$2D,$81,$70,$69
        .byte   $AF,$2C,$E9,$28,$2B,$27,$26,$EB,$00,$E9,$26,$E3,$26,$26,$26,$26
        .byte   $26,$26,$26,$80,$4E,$AF,$8F,$F8,$25,$F6,$20,$E7,$23,$E9,$21,$20
        .byte   $F6,$19,$E7,$1F,$E9,$1E,$22,$EB,$20,$E9,$23,$1E,$E9,$21,$20,$23
        .byte   $1E,$21,$20,$1C,$1B,$1F,$1E,$EB,$1A,$80,$9B,$AF,$8F,$F8,$88,$70
        .byte   $09,$19,$E5,$19,$19,$E3,$19,$F1,$19,$E5,$19,$19,$E3,$19,$19,$19
        .byte   $8B,$0F,$B0,$81,$70,$C4,$AF,$88,$70,$06,$10,$00,$10,$10,$00,$10
        .byte   $10,$00,$8B,$18,$B0,$81,$70,$DD,$AF,$88,$70,$10,$0E,$81,$70,$EF
        .byte   $AF,$80,$C1,$AF,$8F,$F8,$89,$02,$01,$E3,$00,$01,$01,$01,$00,$00
        .byte   $01,$01,$00,$01,$01,$01,$00,$01,$01,$80,$FB,$AF

; ---- bank0.snd_B00F (music) $B00F-$B01D, 15 bytes
; Transpose table ($8B)
        .byte   $07,$FE,$02,$FE,$02,$FD,$FC,$04,$FC,$02,$00,$FF,$00,$FF,$00

; ---- bank0.snd_B01E (music) $B01E-$B777, 1882 bytes
; Song data (38 tracks)
        .byte   $04,$00,$01,$BF,$04,$00,$00,$02,$00,$47,$B0,$01,$01,$BB,$04,$41
        .byte   $00,$02,$01,$D8,$B0,$02,$01,$BF,$09,$01,$18,$02,$02,$BA,$B1,$03
        .byte   $02,$BD,$02,$00,$00,$02,$03,$91,$B2,$8F,$BC,$25,$E7,$2C,$E5,$2A
        .byte   $E7,$2F,$E5,$2C,$E7,$33,$E9,$34,$25,$E7,$2C,$E5,$2A,$E7,$2F,$E5
        .byte   $2C,$E7,$33,$E9,$2F,$8F,$C1,$2A,$E7,$31,$E5,$2D,$E7,$34,$E5,$31
        .byte   $E7,$8F,$C6,$38,$E9,$36,$E7,$34,$33,$EB,$8F,$CD,$2F,$E9,$2F,$E5
        .byte   $30,$31,$E7,$8F,$D1,$88,$70,$01,$34,$E5,$31,$F6,$00,$E5,$00,$E7
        .byte   $37,$E1,$38,$F2,$36,$E5,$34,$31,$2F,$34,$E5,$31,$F6,$00,$E5,$00
        .byte   $E7,$25,$27,$28,$2A,$E5,$25,$F6,$00,$E5,$00,$E7,$31,$2F,$E5,$2E
        .byte   $2C,$2A,$81,$70,$C4,$B0,$2C,$F3,$27,$E5,$27,$F3,$27,$E5,$24,$E7
        .byte   $24,$20,$20,$80,$86,$B0,$8F,$CD,$2C,$F3,$27,$E5,$27,$F3,$27,$E5
        .byte   $8F,$C5,$24,$E7,$24,$20,$20,$80,$47,$B0,$8F,$BC,$00,$E5,$25,$E7
        .byte   $2C,$E5,$2A,$E7,$2F,$E5,$2C,$E7,$33,$E5,$87,$FE,$33,$87,$FE,$33
        .byte   $87,$FE,$33,$87,$06,$34,$87,$FE,$34,$87,$FE,$34,$87,$FE,$34,$87
        .byte   $06,$25,$E7,$2C,$E5,$2A,$E7,$2F,$E5,$2C,$E7,$33,$E5,$87,$FE,$33
        .byte   $87,$FE,$33,$87,$FE,$33,$87,$06,$2F,$87,$FE,$2F,$87,$FE,$2F,$87
        .byte   $FE,$2F,$87,$06,$8F,$C1,$2A,$E7,$31,$E5,$2D,$E7,$34,$E5,$31,$E7
        .byte   $8F,$C6,$38,$E5,$87,$FE,$38,$87,$FE,$38,$87,$FE,$38,$87,$06,$36
        .byte   $E7,$34,$33,$E5,$87,$FE,$33,$87,$FE,$33,$87,$FE,$33,$87,$FF,$33
        .byte   $87,$FF,$33,$87,$FF,$33,$87,$FF,$33,$87,$0A,$8F,$CD,$2F,$E9,$2F
        .byte   $E5,$30,$31,$E7,$8F,$D1,$88,$70,$01,$34,$E5,$31,$F6,$00,$E5,$00
        .byte   $E7,$37,$E1,$38,$F2,$36,$E5,$34,$31,$2F,$34,$E5,$31,$F6,$00,$E5
        .byte   $00,$E7,$25,$27,$28,$2A,$E5,$25,$F6,$00,$E5,$00,$E7,$31,$2F,$E5
        .byte   $2E,$2C,$2A,$81,$70,$A5,$B1,$2C,$F3,$27,$E5,$27,$F3,$27,$E5,$24
        .byte   $E7,$24,$20,$20,$80,$67,$B1,$8F,$CD,$2C,$F3,$27,$E5,$27,$F3,$27
        .byte   $E5,$8F,$C5,$24,$E7,$24,$20,$20,$E5,$80,$D8,$B0,$8F,$BC,$19,$ED
        .byte   $15,$8F,$C1,$12,$EB,$8F,$C6,$12,$17,$F1,$00,$F1,$17,$E3,$00,$17
        .byte   $F1,$00,$17,$E3,$00,$8F,$CD,$17,$E5,$00,$17,$00,$12,$E3,$00,$13
        .byte   $00,$14,$00,$F1,$8F,$D1,$19,$F3,$00,$E5,$20,$F1,$00,$19,$E3,$00
        .byte   $19,$E5,$00,$19,$00,$20,$00,$19,$00,$15,$F3,$00,$E5,$1C,$F1,$00
        .byte   $15,$E3,$00,$15,$E5,$00,$15,$00,$1C,$00,$15,$00,$12,$F3,$00,$E5
        .byte   $19,$F1,$00,$12,$E3,$00,$12,$E5,$00,$12,$00,$0D,$E3,$00,$0E,$00
        .byte   $1B,$00,$1C,$00,$14,$F1,$00,$14,$E3,$00,$0F,$F1,$00,$0F,$E3,$00
        .byte   $14,$E5,$00,$14,$00,$18,$00,$18,$00,$19,$F3,$00,$E5,$20,$F1,$00
        .byte   $19,$E3,$00,$19,$E5,$00,$19,$00,$20,$00,$19,$00,$15,$F3,$00,$E5
        .byte   $1C,$F1,$00,$15,$E3,$00,$15,$E5,$00,$15,$00,$1C,$00,$15,$00,$12
        .byte   $F3,$00,$E5,$19,$F1,$00,$12,$E3,$00,$12,$E5,$00,$12,$00,$0D,$E3
        .byte   $00,$0E,$00,$0F,$00,$10,$00,$8F,$CD,$14,$F1,$00,$14,$E3,$00,$0F
        .byte   $F1,$00,$0F,$E3,$00,$8F,$C5,$14,$E5,$00,$14,$00,$18,$00,$1B,$00
        .byte   $80,$BA,$B1,$89,$04,$8F,$BC,$00,$ED,$00,$8F,$C1,$00,$EB,$8F,$C6
        .byte   $00,$00,$E9,$01,$8F,$CD,$00,$E7,$01,$00,$01,$E5,$01,$8F,$D1,$00
        .byte   $E9,$01,$00,$E7,$01,$00,$01,$00,$00,$01,$00,$00,$01,$00,$01,$00
        .byte   $00,$01,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$01,$00,$01,$E3
        .byte   $01,$01,$01,$00,$E7,$00,$01,$00,$00,$01,$00,$01,$00,$00,$01,$00
        .byte   $00,$01,$00,$01,$00,$00,$01,$00,$00,$01,$00,$01,$8F,$CD,$00,$00
        .byte   $01,$00,$8F,$C5,$01,$01,$01,$E5,$01,$01,$E7,$80,$93,$B2,$03,$00
        .byte   $01,$7F,$02,$00,$FB,$02,$00,$1B,$B3,$01,$01,$7E,$02,$00,$FB,$02
        .byte   $01,$52,$B3,$02,$01,$BF,$04,$00,$1F,$02,$02,$98,$B3,$8F,$DE,$38
        .byte   $E5,$38,$00,$F6,$38,$E5,$38,$00,$F6,$36,$E5,$36,$00,$F6,$36,$E5
        .byte   $36,$00,$F6,$38,$E5,$38,$00,$F6,$38,$E5,$38,$00,$F6,$37,$E5,$37
        .byte   $00,$2E,$00,$2E,$2E,$2E,$37,$37,$00,$3A,$00,$3A,$3A,$E3,$3A,$3A
        .byte   $3A,$80,$1D,$B3,$8F,$DE,$33,$E5,$33,$00,$2C,$2F,$2E,$2A,$2C,$33
        .byte   $33,$00,$2C,$2F,$2E,$2A,$2C,$31,$31,$00,$2A,$2F,$2E,$2A,$2C,$31
        .byte   $31,$00,$2A,$2F,$2E,$2A,$2C,$34,$34,$00,$2C,$2F,$2E,$2A,$2C,$34
        .byte   $34,$00,$2C,$2F,$2E,$2A,$2C,$33,$33,$00,$27,$2B,$2E,$2B,$33,$33
        .byte   $33,$00,$2E,$33,$37,$33,$3A,$80,$54,$B3,$8F,$DE,$14,$E5,$14,$00
        .byte   $F6,$14,$E5,$14,$00,$F6,$12,$E5,$12,$00,$F6,$12,$E5,$12,$00,$F6
        .byte   $10,$E5,$10,$00,$F6,$10,$E5,$10,$00,$F6,$0F,$E5,$0F,$00,$F6,$0F
        .byte   $E5,$0F,$00,$F6,$80,$9A,$B3,$03,$00,$01,$BD,$04,$00,$00,$01,$00
        .byte   $E4,$B3,$01,$01,$BF,$04,$03,$0C,$01,$02,$2D,$B4,$02,$01,$BF,$04
        .byte   $00,$00,$01,$01,$76,$B4,$8F,$A3,$88,$70,$02,$30,$E7,$2A,$E5,$30
        .byte   $E7,$2A,$E5,$30,$2A,$81,$70,$E9,$B3,$88,$70,$02,$33,$E7,$2D,$E5
        .byte   $33,$E7,$2D,$E5,$33,$2D,$81,$70,$FA,$B3,$88,$70,$02,$36,$E7,$30
        .byte   $E5,$36,$E7,$30,$E5,$36,$30,$81,$70,$0B,$B4,$88,$70,$02,$35,$E7
        .byte   $2F,$E5,$35,$E7,$2F,$E5,$35,$2F,$81,$70,$1C,$B4,$80,$E6,$B3,$8F
        .byte   $A3,$88,$70,$02,$2D,$E7,$00,$E5,$2D,$E7,$00,$E5,$2D,$00,$81,$70
        .byte   $32,$B4,$88,$70,$02,$30,$E7,$00,$E5,$30,$E7,$00,$E5,$30,$00,$81
        .byte   $70,$43,$B4,$88,$70,$02,$33,$E7,$00,$E5,$33,$E7,$00,$E5,$33,$00
        .byte   $81,$70,$54,$B4,$88,$70,$02,$32,$E7,$00,$E5,$32,$E7,$00,$E5,$32
        .byte   $00,$81,$70,$65,$B4,$80,$2F,$B4,$8F,$A3,$88,$70,$02,$1E,$E7,$1E
        .byte   $E5,$1E,$E9,$00,$E5,$81,$70,$7B,$B4,$88,$70,$02,$21,$E7,$21,$E5
        .byte   $21,$E9,$00,$E5,$81,$70,$8A,$B4,$88,$70,$02,$24,$E7,$24,$E5,$24
        .byte   $E9,$00,$E5,$81,$70,$99,$B4,$88,$70,$02,$23,$E7,$23,$E5,$23,$E9
        .byte   $00,$E5,$81,$70,$A8,$B4,$80,$78,$B4,$04,$00,$01,$BF,$09,$00,$FD
        .byte   $02,$00,$E0,$B4,$01,$01,$BF,$09,$00,$09,$02,$02,$14,$B5,$02,$01
        .byte   $7F,$02,$00,$FD,$02,$01,$56,$B5,$03,$02,$BD,$03,$00,$00,$02,$03
        .byte   $C7,$B5,$8F,$CD,$25,$E5,$2C,$FB,$2A,$E7,$2F,$2C,$FC,$2A,$E7,$2F
        .byte   $2C,$EB,$34,$E9,$33,$E5,$2F,$F3,$31,$E5,$31,$36,$FD,$34,$E5,$39
        .byte   $FB,$38,$E5,$36,$34,$E7,$36,$E5,$36,$3B,$FA,$3B,$E5,$39,$E5,$38
        .byte   $E7,$3D,$ED,$80,$E2,$B4,$8F,$CD,$20,$E5,$25,$FB,$23,$E5,$22,$1E
        .byte   $E7,$20,$F3,$1E,$E5,$20,$EB,$27,$E5,$25,$27,$E7,$28,$F3,$27,$E5
        .byte   $28,$E9,$2C,$E9,$2A,$E5,$23,$F3,$25,$E5,$25,$2A,$FD,$28,$F6,$27
        .byte   $E7,$25,$E9,$25,$E5,$27,$28,$E7,$27,$E9,$2A,$E9,$23,$E9,$23,$E5
        .byte   $25,$27,$E7,$20,$ED,$80,$16,$B5,$8F,$CD,$19,$E5,$19,$19,$19,$19
        .byte   $19,$19,$19,$19,$19,$19,$19,$19,$19,$25,$20,$14,$14,$14,$14,$14
        .byte   $14,$14,$14,$14,$14,$14,$14,$14,$14,$20,$1B,$10,$10,$10,$10,$10
        .byte   $10,$10,$10,$10,$10,$10,$10,$10,$10,$1C,$17,$12,$12,$12,$12,$12
        .byte   $12,$12,$12,$12,$12,$12,$12,$12,$12,$1E,$19,$15,$15,$15,$15,$15
        .byte   $15,$21,$21,$15,$15,$15,$15,$15,$15,$21,$1C,$17,$17,$17,$17,$17
        .byte   $17,$23,$1E,$17,$17,$17,$17,$17,$17,$23,$1E,$88,$70,$04,$25,$20
        .byte   $1C,$19,$81,$70,$BC,$B5,$80,$58,$B5,$8F,$CD,$89,$03,$01,$E5,$01
        .byte   $01,$01,$01,$01,$01,$01,$80,$CB,$B5,$03,$00,$01,$7F,$04,$00,$00
        .byte   $02,$00,$F6,$B5,$01,$01,$7C,$03,$00,$00,$02,$01,$8E,$B6,$02,$03
        .byte   $BE,$03,$00,$18,$02,$02,$D1,$B6,$25,$E5,$2C,$28,$E7,$2F,$2A,$2C
        .byte   $EB,$25,$E5,$2C,$28,$E7,$2F,$2C,$33,$EB,$34,$E3,$00,$33,$00,$31
        .byte   $E7,$38,$31,$34,$E3,$00,$33,$00,$31,$E7,$38,$31,$34,$E3,$00,$33
        .byte   $00,$31,$E7,$38,$31,$34,$E5,$33,$31,$30,$2E,$2C,$2E,$30,$31,$E3
        .byte   $00,$34,$00,$31,$E7,$38,$31,$31,$E3,$00,$33,$00,$31,$E7,$38,$31
        .byte   $31,$E3,$00,$34,$00,$31,$E7,$38,$31,$3B,$E9,$38,$3D,$E3,$00,$3B
        .byte   $00,$3A,$00,$38,$00,$36,$00,$34,$00,$36,$00,$38,$00,$3B,$00,$3A
        .byte   $00,$38,$00,$36,$00,$34,$00,$33,$00,$34,$00,$36,$00,$39,$00,$38
        .byte   $00,$36,$00,$34,$00,$33,$00,$31,$00,$33,$00,$34,$00,$33,$00,$31
        .byte   $00,$30,$00,$2E,$00,$31,$30,$2E,$2C,$30,$2E,$2C,$28,$80,$F6,$B5
        .byte   $25,$E3,$25,$25,$25,$25,$E5,$25,$25,$E3,$25,$25,$25,$25,$E5,$25
        .byte   $28,$E3,$28,$28,$28,$28,$E5,$28,$28,$E3,$28,$28,$28,$28,$E5,$28
        .byte   $2D,$E3,$2D,$2D,$2D,$2D,$E5,$2D,$2D,$E3,$2D,$2D,$2D,$2D,$E5,$2D
        .byte   $2C,$E3,$2C,$2C,$2C,$2C,$E5,$2C,$2C,$E3,$2C,$2C,$2C,$2C,$E5,$2C
        .byte   $80,$8E,$B6,$90,$FE,$B6,$19,$E5,$20,$19,$20,$19,$20,$19,$20,$17
        .byte   $1E,$17,$1E,$17,$1E,$17,$1E,$15,$1C,$15,$1C,$15,$1C,$15,$1C,$14
        .byte   $1B,$14,$1B,$14,$1B,$90,$05,$B7,$14,$E3,$20,$14,$20,$80,$D1,$B6
        .byte   $20,$20,$64,$20,$00,$FE,$B6,$64,$00,$05,$B7,$03,$00,$01,$BE,$0A
        .byte   $41,$00,$02,$00,$28,$B7,$01,$01,$BF,$04,$00,$00,$02,$01,$4C,$B7
        .byte   $02,$03,$BA,$03,$00,$18,$02,$02,$60,$B7,$21,$E5,$20,$23,$22,$28
        .byte   $27,$00,$27,$21,$E5,$20,$23,$22,$28,$27,$00,$27,$2A,$EB,$2B,$E5
        .byte   $28,$F6,$00,$E5,$2E,$F6,$2D,$E5,$2E,$2F,$EB,$80,$28,$B7,$88,$70
        .byte   $0C,$86,$00,$8B,$78,$B7,$1C,$E5,$10,$1C,$10,$81,$70,$51,$B7,$80
        .byte   $4C,$B7,$89,$06,$8D,$01,$20,$E3,$20,$00,$20,$20,$20,$00,$20,$20
        .byte   $00,$20,$20,$20,$20,$00,$20,$80,$64,$B7

; ---- bank0.snd_B778 (music) $B778-$B783, 12 bytes
; Transpose table ($8B)
        .byte   $00,$01,$00,$FF,$00,$01,$00,$FF,$00,$00,$00,$00

; ---- bank0.snd_B784 (music) $B784-$B838, 181 bytes
; Song data (5 tracks)
        .byte   $03,$00,$01,$BE,$04,$00,$00,$01,$00,$A3,$B7,$01,$01,$BE,$04,$00
        .byte   $00,$01,$01,$FE,$B7,$02,$01,$BF,$04,$00,$24,$01,$02,$3C,$B8,$8F
        .byte   $8C,$27,$E4,$27,$27,$2B,$E7,$33,$2E,$2C,$E4,$2C,$2C,$31,$E7,$35
        .byte   $31,$33,$F1,$35,$E3,$33,$E9,$2E,$E7,$31,$F1,$33,$E3,$31,$E9,$2C
        .byte   $E7,$2E,$F1,$30,$E3,$2E,$F6,$88,$70,$02,$27,$E4,$27,$27,$2B,$E7
        .byte   $33,$2E,$2C,$E4,$2C,$2C,$31,$E7,$35,$31,$33,$F1,$35,$E3,$33,$E9
        .byte   $2E,$E7,$31,$F1,$33,$E3,$31,$E9,$2C,$E7,$2E,$F1,$30,$E3,$2E,$F6
        .byte   $8B,$6F,$B8,$81,$70,$CE,$B7,$80,$CB,$B7,$8F,$8C,$88,$70,$03,$80
        .byte   $09,$B8,$88,$70,$02,$22,$E4,$22,$22,$27,$E7,$2B,$27,$20,$E4,$20
        .byte   $20,$25,$E7,$29,$25,$27,$F1,$29,$E3,$27,$E9,$22,$E7,$25,$F1,$27
        .byte   $E3,$25,$E9,$20,$E7,$22,$F1,$27,$E3,$22,$F6,$8B,$39,$B8,$81,$70
        .byte   $09,$B8,$80,$06,$B8

; ---- bank0.snd_B839 (music) $B839-$B83B, 3 bytes
; Transpose table ($8B)
        .byte   $05,$FB,$00

; ---- bank0.snd_B83C (music) $B83C-$B86E, 51 bytes
; Song data (1 tracks)
        .byte   $8F,$8C,$88,$70,$05,$0F,$E4,$00,$0F,$0F,$00,$0F,$0F,$00,$0F,$0F
        .byte   $00,$0F,$8B,$71,$B8,$81,$70,$41,$B8,$88,$70,$0A,$0F,$E4,$00,$0F
        .byte   $0F,$00,$0F,$0F,$00,$0F,$0F,$00,$0F,$8B,$76,$B8,$81,$70,$58,$B8
        .byte   $80,$55,$B8

; ---- bank0.snd_B86F (music) $B86F-$B87F, 17 bytes
; Transpose table ($8B)
        .byte   $05,$FB,$00,$02,$FE,$02,$FE,$05,$02,$FE,$02,$FE,$FB,$02,$FE,$02
        .byte   $FE

; ---- bank0.snd_B880 (music) $B880-$B8F8, 121 bytes
; Song data (3 tracks)
        .byte   $03,$00,$01,$BF,$04,$00,$05,$02,$00,$9F,$B8,$01,$01,$7C,$02,$00
        .byte   $05,$02,$01,$DF,$B8,$02,$01,$BC,$02,$00,$11,$02,$02,$03,$B9,$8F
        .byte   $DC,$25,$E3,$00,$20,$25,$E5,$29,$31,$E3,$30,$2C,$F3,$00,$E3,$27
        .byte   $E3,$00,$23,$27,$E5,$2A,$33,$E3,$31,$2F,$F3,$00,$E3,$00,$31,$00
        .byte   $2C,$31,$E5,$35,$38,$36,$35,$31,$00,$E3,$2F,$00,$2A,$2F,$E5,$33
        .byte   $36,$35,$33,$2F,$31,$2C,$29,$2C,$2F,$2A,$27,$2A,$80,$A1,$B8,$8F
        .byte   $DC,$88,$70,$0A,$8B,$F9,$B8,$2C,$E3,$29,$31,$2C,$35,$31,$2C,$29
        .byte   $81,$70,$E4,$B8,$86,$02,$80,$E1,$B8

; ---- bank0.snd_B8F9 (music) $B8F9-$B902, 10 bytes
; Transpose table ($8B)
        .byte   $FE,$02,$00,$FE,$00,$02,$00,$FE,$00,$00

; ---- bank0.snd_B903 (music) $B903-$B9D6, 212 bytes
; Song data (5 tracks)
        .byte   $8F,$DC,$88,$70,$0A,$8B,$F9,$B8,$19,$E3,$19,$19,$25,$19,$19,$19
        .byte   $25,$81,$70,$08,$B9,$86,$02,$80,$05,$B9,$03,$00,$01,$7B,$02,$00
        .byte   $02,$02,$00,$3C,$B9,$01,$01,$BE,$04,$00,$02,$02,$02,$6C,$B9,$02
        .byte   $01,$7F,$05,$00,$02,$02,$01,$A4,$B9,$8F,$F0,$88,$70,$04,$8B,$D7
        .byte   $B9,$31,$E3,$2C,$20,$25,$19,$31,$20,$2F,$19,$2E,$20,$2C,$19,$2E
        .byte   $20,$2F,$31,$2C,$20,$28,$19,$2C,$20,$2E,$19,$2F,$20,$2E,$19,$2F
        .byte   $20,$31,$81,$70,$41,$B9,$80,$3E,$B9,$8F,$F0,$89,$04,$88,$70,$04
        .byte   $8B,$D7,$B9,$20,$E5,$31,$34,$33,$8A,$03,$8D,$02,$38,$E3,$00,$8A
        .byte   $01,$8D,$00,$34,$E5,$33,$36,$20,$31,$34,$33,$8A,$03,$8D,$02,$38
        .byte   $E3,$00,$8A,$01,$8D,$00,$34,$E5,$33,$2F,$81,$70,$73,$B9,$80,$70
        .byte   $B9,$8F,$F0,$25,$E5,$2C,$31,$F6,$00,$E5,$31,$2F,$2E,$2C,$2F,$2E
        .byte   $2A,$2F,$E9,$2A,$00,$E5,$2F,$2D,$2C,$2A,$2D,$2C,$28,$27,$E9,$33
        .byte   $33,$E5,$34,$33,$34,$36,$34,$33,$E3,$31,$2F,$2C,$31,$E9,$2C,$28
        .byte   $25,$80,$A6,$B9

; ---- bank0.snd_B9D7 (music) $B9D7-$B9DA, 4 bytes
; Transpose table ($8B)
        .byte   $05,$FD,$FE,$00

; ---- bank0.snd_B9DB (music) $B9DB-$BBCB, 497 bytes
; Song data (12 tracks)
        .byte   $02,$00,$01,$3F,$04,$00,$00,$01,$00,$F2,$B9,$01,$01,$3F,$04,$00
        .byte   $00,$01,$01,$F0,$B9,$00,$E5,$8F,$BE,$8C,$80,$20,$31,$E3,$2E,$2A
        .byte   $3A,$2E,$31,$3A,$86,$02,$8E,$F7,$B9,$84,$03,$00,$01,$BF,$04,$00
        .byte   $00,$02,$00,$24,$BA,$01,$01,$BF,$04,$00,$00,$02,$01,$2E,$BA,$02
        .byte   $01,$BF,$04,$00,$0C,$02,$02,$3F,$BA,$35,$E5,$33,$35,$E7,$31,$33
        .byte   $35,$EB,$84,$31,$E5,$30,$31,$E7,$2E,$E3,$30,$31,$33,$35,$36,$35
        .byte   $36,$31,$EB,$82,$20,$E5,$2C,$20,$2C,$1E,$2A,$20,$2C,$38,$E8,$82
        .byte   $04,$01,$01,$7F,$09,$00,$0C,$01,$02,$74,$BA,$00,$01,$BF,$09,$41
        .byte   $00,$01,$00,$FC,$BA,$02,$01,$BF,$02,$00,$00,$01,$01,$45,$BB,$03
        .byte   $02,$BF,$03,$00,$00,$01,$03,$9C,$BB,$8F,$91,$88,$70,$02,$31,$E3
        .byte   $00,$E5,$31,$E3,$33,$F6,$31,$E3,$00,$E5,$34,$E3,$33,$F6,$33,$E3
        .byte   $00,$E5,$33,$E3,$35,$F6,$33,$E3,$00,$E5,$36,$E3,$35,$F6,$81,$70
        .byte   $79,$BA,$36,$EB,$35,$91,$00,$86,$F4,$88,$70,$02,$88,$77,$02,$34
        .byte   $E4,$33,$31,$36,$F1,$34,$E3,$33,$E7,$81,$77,$AA,$BA,$88,$77,$02
        .byte   $39,$E4,$38,$36,$3B,$F1,$39,$E3,$38,$E7,$81,$77,$BB,$BA,$81,$70
        .byte   $A7,$BA,$91,$02,$86,$0C,$3D,$E7,$3C,$E9,$3B,$E7,$3A,$E9,$3D,$E7
        .byte   $3C,$E9,$3B,$E7,$3A,$E9,$91,$00,$86,$F4,$36,$E4,$38,$39,$3B,$E7
        .byte   $3D,$40,$3F,$3D,$E5,$3B,$F3,$91,$02,$86,$0C,$42,$EB,$41,$80,$76
        .byte   $BA,$8F,$91,$88,$70,$02,$2D,$E3,$00,$E5,$2D,$E3,$2F,$F6,$2D,$E3
        .byte   $00,$E5,$31,$E3,$2F,$F6,$2F,$E3,$00,$E5,$2F,$E3,$31,$F6,$2F,$E3
        .byte   $00,$E5,$33,$E3,$31,$F6,$81,$70,$01,$BB,$2F,$EB,$31,$88,$70,$08
        .byte   $00,$F6,$81,$70,$2B,$BB,$88,$70,$04,$38,$E7,$38,$E9,$81,$70,$34
        .byte   $BB,$00,$F6,$00,$EB,$31,$31,$80,$FE,$BA,$8F,$91,$88,$70,$08,$15
        .byte   $E3,$00,$E5,$15,$E3,$15,$E7,$15,$E4,$15,$15,$15,$E7,$8B,$CC,$BB
        .byte   $81,$70,$4A,$BB,$88,$70,$08,$19,$E4,$19,$19,$81,$70,$62,$BB,$88
        .byte   $70,$0E,$15,$E4,$21,$15,$15,$21,$15,$15,$21,$15,$8B,$D4,$BB,$81
        .byte   $70,$6D,$BB,$17,$23,$17,$19,$25,$19,$25,$19,$25,$19,$25,$19,$25
        .byte   $19,$25,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$80,$47
        .byte   $BB,$8F,$91,$89,$04,$88,$70,$0A,$00,$E7,$01,$00,$01,$81,$70,$A3
        .byte   $BB,$88,$70,$0D,$00,$E4,$01,$01,$01,$E7,$01,$E4,$00,$00,$81,$70
        .byte   $AF,$BB,$88,$70,$03,$00,$E7,$01,$00,$01,$81,$70,$C0,$BB,$80,$A0
        .byte   $BB

; ---- bank0.snd_BBCC (music) $BBCC-$BBE1, 22 bytes
; Transpose table ($8B)
        .byte   $FE,$00,$02,$00,$FE,$00,$02,$00,$FE,$02,$FC,$00,$00,$00,$02,$00
        .byte   $02,$00,$FE,$00,$02,$00

; ---- bank0.snd_BBE2 (music) $BBE2-$BF03, 802 bytes
; Song data (52 tracks)
        .byte   $03,$00,$01,$7F,$01,$00,$F6,$01,$00,$01,$BC,$01,$01,$3F,$01,$00
        .byte   $F6,$01,$01,$2B,$BC,$02,$03,$BD,$03,$00,$1A,$01,$02,$5C,$BC,$8F
        .byte   $90,$2E,$E5,$00,$E3,$2C,$2C,$E9,$29,$E5,$2A,$31,$E5,$00,$E3,$30
        .byte   $30,$E9,$30,$E3,$31,$E5,$33,$E3,$36,$F1,$38,$E7,$00,$E3,$39,$F1
        .byte   $3B,$E7,$00,$E3,$85,$09,$3C,$FC,$82,$8F,$90,$2A,$E5,$00,$E3,$29
        .byte   $E3,$29,$E9,$25,$E5,$27,$2E,$E5,$00,$E3,$2C,$2C,$E9,$2C,$E3,$2E
        .byte   $E5,$30,$E3,$86,$F4,$33,$36,$39,$3B,$39,$36,$33,$36,$31,$34,$38
        .byte   $39,$38,$33,$31,$33,$85,$09,$44,$FC,$82,$8F,$90,$90,$BE,$BC,$19
        .byte   $E3,$00,$19,$E2,$00,$E1,$19,$E3,$00,$19,$E2,$00,$E1,$19,$E3,$00
        .byte   $19,$00,$19,$00,$20,$00,$19,$00,$14,$00,$14,$E2,$00,$E1,$14,$E3
        .byte   $00,$14,$E2,$00,$E1,$14,$E3,$00,$14,$00,$14,$00,$1B,$00,$14,$00
        .byte   $17,$E2,$00,$E1,$17,$E2,$00,$E1,$17,$E2,$00,$E1,$17,$E2,$00,$E1
        .byte   $23,$E7,$15,$E2,$00,$E1,$15,$E2,$00,$E1,$15,$E2,$00,$E1,$15,$E2
        .byte   $00,$E1,$21,$E3,$00,$00,$00,$93,$29,$14,$EB,$82,$66,$20,$20,$20
        .byte   $20,$66,$20,$20,$20,$20,$66,$66,$66,$66,$66,$20,$20,$20,$20,$20
        .byte   $20,$20,$20,$66,$20,$20,$20,$20,$20,$20,$20,$20,$66,$66,$20,$20
        .byte   $20,$20,$20,$20,$20,$20,$20,$20,$66,$20,$20,$20,$20,$20,$20,$20
        .byte   $20,$66,$66,$66,$66,$66,$01,$05,$01,$BF,$00,$00,$F0,$01,$01,$03
        .byte   $BD,$52,$E1,$6A,$E2,$82,$01,$04,$01,$BF,$03,$99,$F4,$01,$01,$13
        .byte   $BD,$5E,$E3,$82,$01,$05,$03,$3F,$00,$83,$00,$01,$01,$21,$BD,$8C
        .byte   $80,$A0,$89,$0E,$24,$E3,$89,$0F,$24,$E8,$82,$01,$05,$01,$BF,$00
        .byte   $00,$00,$01,$03,$38,$BD,$0E,$E6,$88,$70,$08,$85,$01,$0F,$E4,$87
        .byte   $FE,$81,$70,$3F,$BD,$82,$01,$05,$01,$BF,$00,$00,$00,$01,$03,$53
        .byte   $BD,$8C,$80,$A0,$88,$70,$18,$87,$02,$0E,$E3,$0F,$E1,$81,$70,$59
        .byte   $BD,$82,$01,$04,$01,$7F,$00,$89,$00,$01,$01,$6F,$BD,$2A,$E2,$2A
        .byte   $E4,$82,$01,$04,$01,$8F,$00,$00,$04,$01,$02,$7F,$BD,$88,$70,$0C
        .byte   $2C,$E1,$33,$86,$02,$81,$70,$82,$BD,$82,$01,$04,$02,$B8,$00,$00
        .byte   $00,$01,$02,$97,$BD,$89,$0F,$88,$70,$0F,$0F,$E4,$87,$01,$89,$0F
        .byte   $81,$70,$9C,$BD,$8C,$84,$C0,$0F,$E9,$82,$01,$04,$01,$BF,$00,$00
        .byte   $00,$01,$01,$B7,$BD,$8C,$80,$40,$50,$E1,$51,$8E,$BA,$BD,$82,$01
        .byte   $04,$01,$BF,$00,$92,$00,$01,$01,$CC,$BD,$8C,$80,$A0,$33,$E2,$36
        .byte   $3A,$8E,$CF,$BD,$82,$01,$04,$01,$BF,$00,$9A,$00,$01,$01,$E2,$BD
        .byte   $8C,$80,$40,$19,$E5,$8E,$E5,$BD,$82,$01,$04,$01,$BF,$00,$8C,$00
        .byte   $01,$01,$F6,$BD,$8C,$84,$80,$4C,$E9,$82,$01,$05,$01,$BF,$00,$94
        .byte   $00,$01,$01,$07,$BE,$8C,$80,$40,$42,$E4,$86,$FF,$8E,$0A,$BE,$82
        .byte   $01,$05,$01,$BF,$00,$82,$00,$01,$01,$1D,$BE,$8C,$83,$30,$38,$E3
        .byte   $3A,$8E,$20,$BE,$82,$01,$05,$01,$BF,$00,$8A,$03,$01,$01,$32,$BE
        .byte   $8C,$80,$50,$33,$E1,$33,$86,$01,$8E,$35,$BE,$82,$04,$04,$00,$05
        .byte   $00,$04,$61,$BF,$04,$43,$FC,$02,$00,$57,$BE,$05,$41,$7F,$04,$00
        .byte   $FC,$02,$01,$63,$BE,$38,$E6,$38,$E4,$3C,$3A,$38,$3C,$41,$3F,$E8
        .byte   $82,$35,$E6,$E4,$35,$36,$36,$38,$38,$3C,$E8,$82,$01,$05,$41,$3F
        .byte   $00,$99,$00,$01,$01,$79,$BE,$8C,$88,$18,$0F,$E4,$86,$02,$8E,$7C
        .byte   $BE,$82,$01,$05,$01,$7F,$00,$00,$06,$01,$01,$8F,$BE,$8C,$82,$A0
        .byte   $33,$E1,$46,$E2,$8E,$92,$BE,$82,$01,$05,$01,$7F,$00,$00,$F4,$01
        .byte   $01,$A5,$BE,$8C,$82,$60,$33,$E2,$46,$3F,$E1,$8E,$A8,$BE,$82,$01
        .byte   $05,$01,$BF,$00,$00,$00,$01,$01,$BC,$BE,$8C,$86,$40,$35,$E1,$4D
        .byte   $29,$86,$02,$8E,$BF,$BE,$82,$01,$05,$21,$BF,$00,$82,$00,$01,$00
        .byte   $D4,$BE,$8C,$82,$80,$55,$E5,$8E,$D7,$BE,$82,$01,$04,$02,$BF,$00
        .byte   $00,$00,$01,$02,$E8,$BE,$89,$0F,$8C,$82,$10,$0D,$E4,$1B,$8E,$ED
        .byte   $BE,$82,$01,$05,$03,$BF,$04,$92,$00,$01,$01,$FF,$BE,$89,$08,$38
        .byte   $E7,$82

; ---- UNCLAIMED (gap) $BF04-$BF06, 3 bytes
        .byte   $12,$E9,$82

; ---- bank0.snd_BF07 (music) $BF07-$BFD9, 211 bytes
; Song data (23 tracks)
        .byte   $01,$05,$01,$BF,$00,$92,$00,$01,$01,$12,$BF,$8C,$80,$70,$33,$E5
        .byte   $3F,$8E,$15,$BF,$82,$01,$05,$01,$70,$00,$00,$FE,$01,$01,$32,$BF
        .byte   $01,$05,$01,$B0,$00,$00,$00,$01,$01,$32,$BF,$88,$70,$10,$33,$E1
        .byte   $34,$87,$01,$81,$70,$35,$BF,$8C,$80,$30,$33,$34,$8E,$41,$BF,$82
        .byte   $01,$06,$01,$7F,$00,$00,$00,$01,$01,$52,$BF,$8C,$80,$60,$48,$E1
        .byte   $54,$48,$E2,$50,$E1,$5C,$50,$EB,$82,$01,$05,$61,$7F,$00,$9B,$00
        .byte   $01,$00,$6B,$BF,$8C,$84,$20,$2A,$E2,$1E,$E4,$86,$04,$8E,$6E,$BF
        .byte   $82,$01,$05,$01,$BF,$00,$00,$00,$01,$03,$83,$BF,$8C,$84,$80,$0B
        .byte   $E1,$09,$8E,$86,$BF,$82,$01,$05,$01,$BF,$00,$00,$00,$01,$03,$98
        .byte   $BF,$8C,$88,$FF,$0F,$E1,$08,$8E,$9B,$BF,$82,$01,$05,$01,$BF,$00
        .byte   $00,$00,$01,$03,$AD,$BF,$8C,$80,$30,$0E,$E1,$04,$8E,$B0,$BF,$82
        .byte   $06,$00,$00,$01,$00,$02,$00,$03,$00,$00,$01,$BF,$00,$9E,$00,$01
        .byte   $00,$D4,$BF,$01,$01,$BF,$00,$9E,$00,$01,$01,$D4,$BF,$8C,$80,$30
        .byte   $29,$EC,$82

; ---- bank0.pad_BFDA (padding) $BFDA-$BFFE, 37 bytes
; Fill: 37 x $FF
        .fill   37,$FF

; ---- bank0.bank_id_BFFF (data) $BFFF-$BFFF, 1 bytes
; Bank 0 identity byte
        .byte   $00
