; PRG bank 5 - not yet established
; $8000-$BFFF
; The switchable window. Every address below exists in seven banks; only this
; one has these bytes at it, which is what the L5_ label prefix records.
.org $8000


; ---- bank5.code_8000 (code) $8000-$803B, 60 bytes
L5_8000:
        jmp     L5_ACA9
L5_8003:
        jmp     L5_8155
L5_8006:
        jmp     L5_8354
L5_8009:
        jmp     L5_83B3
L5_800C:
        jmp     L5_8471
L5_800F:
        jmp     L5_8483
L5_8012:
        jmp     L5_9F22
L5_8015:
        jmp     L5_8121
L5_8018:
        jmp     L5_B2E4
L5_801B:
        jmp     L5_84CB
L5_801E:
        jmp     L5_8711
L5_8021:
        jmp     L5_8937
L5_8024:
        jmp     L5_A33F
L5_8027:
        jmp     L5_AD1A
L5_802A:
        jmp     L5_89FB
L5_802D:
        jmp     L5_8071
L5_8030:
        jmp     L5_A3BB
L5_8033:
        jmp     L5_86ED
L5_8036:
        jmp     L5_A430
L5_8039:
        jmp     L5_A462

; ---- UNCLAIMED (gap) $803C-$8041, 6 bytes
        .byte   $61,$AF,$69,$AF,$71,$AF

; ---- bank5.code_8042 (code) $8042-$8066, 37 bytes
L5_8042:
        ldy     #$00
        sty     $17
        and     #$1F
        sta     $16
        asl     A
        rol     $17
        asl     A
        rol     $17
        asl     A
        rol     $17
        adc     $16
        bcc     L5_8059
        inc     $17
L5_8059:
        asl     A
        rol     $17
        adc     #$EA
        sta     $16
        lda     #$91
        adc     $17
        sta     $17
        rts

; ---- UNCLAIMED (gap) $8067-$8070, 10 bytes
        .byte   $00,$FF,$00,$01,$00,$FF,$00,$00,$00,$01

; ---- bank5.code_8071 (code) $8071-$82D8, 616 bytes
L5_8071:
        lda     $A4
        lsr     A
        tay
        lda     $52
        clc
        adc     $8067,Y
        sta     $52
        sta     $19
        lda     $53
        clc
        adc     $806C,Y
        sta     $53
        sta     $18
        lda     #$00
        sta     $15
        sta     $14
        lda     #$6E
        sta     $16
        lda     #$8A
        sta     $17
        lda     $18
        beq     L5_80A4
        dec     $18
        jsr     L5_80F5
        inc     $18
        lda     $17
L5_80A4:
        sta     $E1
        lda     $16
        sta     $E0
        lda     $19
        beq     L5_80B7
        dec     $19
        jsr     L5_80F5
        inc     $19
        lda     $17
L5_80B7:
        sta     $E3
        lda     $16
        sta     $E2
        jsr     L5_80F5
        lda     $17
        sta     $E5
        lda     $16
        sta     $E4
        lda     $19
        sec
        sbc     #$17
        beq     L5_80D8
        inc     $19
        jsr     L5_80F5
        dec     $19
        lda     $17
L5_80D8:
        sta     $E7
        lda     $16
        sta     $E6
        lda     $18
        sec
        sbc     #$17
        beq     L5_80EE
        inc     $18
        jsr     L5_80F5
        dec     $18
        lda     $17
L5_80EE:
        sta     $E9
        lda     $16
        sta     $E8
        rts
L5_80F5:
        ldy     #$00
L5_80F7:
        lda     $14
        cmp     $18
        bne     L5_8103
        lda     $15
        cmp     $19
        beq     L5_8120
L5_8103:
        lda     ($16),Y
        and     #$0F
        sec
        adc     $16
        sta     $16
        bcc     L5_8110
        inc     $17
L5_8110:
        inc     $15
        lda     $15
        cmp     #$18
        bne     L5_80F7
        lda     #$00
        sta     $15
        inc     $14
        bne     L5_80F7
L5_8120:
        rts
L5_8121:
        lda     #$03
        sta     $10
        ldy     #$00
        lda     ($E4),Y
        and     #$60
        sta     $5D
        beq     L5_813B
        cmp     #$60
        beq     L5_813B
        ldy     #$03
        lda     ($E4),Y
        sta     $5E
        inc     $10
L5_813B:
        ldy     #$01
        lda     ($E4),Y
        and     #$08
        beq     L5_814B
        ldy     $10
        lda     ($E4),Y
        bne     L5_814B
        lda     #$01
L5_814B:
        sta     $57
        ldy     $5E
        lda     $A377,Y
        sta     $55
        rts
L5_8155:
        jsr     L7_C045
        jsr     L5_A749
        ldy     #$01
        lda     ($18),Y
        tax
        sta     $12
L5_8162:
        ldy     #$02
        lda     ($18),Y
        sta     $1B
        sta     $11
        iny
        lda     ($18),Y
        sta     $1A
        iny
        sty     $10
L5_8172:
        lda     ($18),Y
        sta     $0740,X
        inx
        iny
        txa
        and     #$0F
        beq     L5_818B
        dec     $1B
        bne     L5_8172
L5_8182:
        lda     $11
        sta     $1B
        ldy     $10
        jmp     L5_8172
L5_818B:
        cpx     #$C0
        beq     L5_81A4
        lda     $12
        adc     #$10
        sta     $12
        tax
        dec     $1A
        beq     L5_8162
        lda     $10
        clc
        adc     $11
        sta     $10
        jmp     L5_8182
L5_81A4:
        ldy     #$00
        lda     ($18),Y
        tay
        lda     ($18),Y
        beq     L5_81B0
        jsr     L5_8379
L5_81B0:
        lda     $15
        sta     $19
        lda     $14
        sta     $18
        ldy     #$00
        jsr     L5_8379
        sty     $14
        lda     $30
        and     #$20
        bne     L5_8227
        ldy     #$01
        lda     ($E4),Y
        sta     $15
        ldy     #$00
        lda     ($E0),Y
        bmi     L5_81D5
        bit     $15
        bmi     L5_81DB
L5_81D5:
        ldy     $14
        iny
        jsr     L5_A6EB
L5_81DB:
        ldy     $14
        tya
        clc
        adc     ($18),Y
        sta     $14
        ldy     #$00
        lda     ($E2),Y
        bmi     L5_81ED
        bit     $15
        bvs     L5_81F3
L5_81ED:
        ldy     $14
        iny
        jsr     L5_A6EB
L5_81F3:
        ldy     $14
        tya
        clc
        adc     ($18),Y
        sta     $14
        ldy     #$00
        lda     ($E6),Y
        bmi     L5_8207
        lda     $15
        and     #$20
        bne     L5_820D
L5_8207:
        ldy     $14
        iny
        jsr     L5_A6EB
L5_820D:
        ldy     $14
        tya
        clc
        adc     ($18),Y
        sta     $14
        ldy     #$00
        lda     ($E8),Y
        bmi     L5_8221
        lda     $15
        and     #$10
        bne     L5_8227
L5_8221:
        ldy     $14
        iny
        jsr     L5_A6EB
L5_8227:
        ldy     #$00
L5_8229:
        lda     ($16),Y
        sta     $18
        iny
        lda     ($16),Y
        sta     $19
        ora     $18
        beq     L5_8243
        iny
        tya
        pha
        ldy     #$00
        jsr     L5_A6EB
        pla
        tay
        jmp     L5_8229
L5_8243:
        ldy     #$00
        lda     ($E4),Y
        and     #$10
        bne     L5_824E
        jmp     L5_82DD
L5_824E:
        ldy     #$03
        lda     $57
        beq     L5_8255
        iny
L5_8255:
        lda     $5D
        beq     L5_825E
        cmp     #$60
        beq     L5_825E
        iny
L5_825E:
        lda     ($E4),Y
        sta     $18
        iny
        lda     ($E4),Y
        sta     $19
        ldy     #$00
        lda     ($18),Y
        jsr     L5_8042
        ldy     #$01
        lda     ($18),Y
        sta     $10
        ldx     #$20
        ldy     #$00
L5_8278:
        lda     ($16),Y
        sta     $11
L5_827C:
        asl     $11
        bcc     L5_8285
        lda     $10
        sta     $0740,X
L5_8285:
        inx
        txa
        and     #$07
        bne     L5_827C
        iny
        cpy     #$12
        bne     L5_8278
        ldy     #$00
        lda     ($18),Y
        rol     A
        rol     A
        rol     A
        rol     A
        and     #$07
        bne     L5_829F
        jmp     L5_82DD
L5_829F:
        sta     $17
        ldy     #$02
L5_82A3:
        lda     ($18),Y
        sta     $16
        iny
        lda     ($18),Y
        tax
        iny
        lda     ($18),Y
        iny
        sty     $11
        sta     $10
        rol     A
        rol     A
        rol     A
        and     #$03
        tay
        lda     $82D9,Y
        sta     $12
        ldy     #$06
L5_82C0:
        lsr     $10
        bcc     L5_82C9
        lda     $16
        sta     $0740,X
L5_82C9:
        txa
        clc
        adc     $12
        tax
        dey
        bne     L5_82C0
        ldy     $11
        dec     $17
        bne     L5_82A3
        beq     L5_82DD

; ---- UNCLAIMED (gap) $82D9-$82DC, 4 bytes
        .byte   $F1,$01,$10,$11

; ---- bank5.code_82DD (code) $82DD-$83A4, 200 bytes
L5_82DD:
        lda     #$08
        sta     $58
        sta     $59
        sta     $5A
        sta     $5B
        ldy     #$01
        lda     ($E4),Y
        sta     $15
        sta     $54
        dey
        lda     ($E4),Y
        sta     $14
        bit     $15
        bpl     L5_830B
        lda     ($E0),Y
        ora     $14
        bpl     L5_830B
        iny
        lda     ($E0),Y
        and     #$07
        sta     $58
        dey
        lda     #$08
        sta     $0777
L5_830B:
        bit     $15
        bvc     L5_8322
        lda     ($E2),Y
        ora     $14
        bpl     L5_8322
        iny
        lda     ($E2),Y
        and     #$07
        sta     $59
        dey
        lda     #$08
        sta     $07B2
L5_8322:
        lda     $15
        and     #$20
        beq     L5_833B
        lda     ($E6),Y
        ora     $14
        bpl     L5_833B
        iny
        lda     ($E6),Y
        and     #$07
        sta     $5A
        dey
        lda     #$08
        sta     $07BD
L5_833B:
        lda     $15
        and     #$10
        beq     L5_8353
        lda     ($E8),Y
        ora     $14
        bpl     L5_8353
        iny
        lda     ($E8),Y
        and     #$07
        sta     $5B
        lda     #$08
        sta     $07E7
L5_8353:
        rts
L5_8354:
        ldx     #$00
        ldy     #$00
L5_8358:
        lda     $0740,Y
        jsr     L5_838E
        asl     A
        asl     A
        asl     A
        asl     A
        sta     $0400,X
        iny
        lda     $0740,Y
        jsr     L5_838E
        ora     $0400,X
        sta     $0400,X
        iny
        inx
        cpx     #$60
        bne     L5_8358
        rts
L5_8379:
        lda     #$04
L5_837B:
        pha
        tya
        pha
        iny
        jsr     L5_A6EB
        pla
        tay
        clc
        adc     ($18),Y
        tay
        pla
        sbc     #$00
        bne     L5_837B
        rts
L5_838E:
        cmp     #$A0
        bcs     L5_83A2
        cmp     #$20
        bcc     L5_8399
        lda     #$00
        rts
L5_8399:
        sty     $10
        tay
        lda     $83A5,Y
        ldy     $10
        rts
L5_83A2:
        lda     #$09
        rts

; ---- UNCLAIMED (gap) $83A5-$83B2, 14 bytes
        .byte   $00,$08,$07,$06,$05,$01,$04,$04,$0A,$09,$00,$02,$0E,$00

; ---- bank5.code_83B3 (code) $83B3-$8468, 182 bytes
L5_83B3:
        ldx     #$0F
L5_83B5:
        stx     $14
        lda     $04C0,X
        sta     $10
        and     #$1F
        sta     $12
        asl     A
        asl     A
        adc     $12
        sta     $12
        lda     $10
        lsr     A
        lsr     A
        lsr     A
        lsr     A
        lsr     A
        tay
        lda     $0460,Y
        clc
        adc     $12
        sta     $12
        lda     $0468,Y
        adc     #$00
        sta     $13
        lda     $0470,Y
        sta     $10
        sty     $11
        ldy     #$00
        txa
        asl     A
        tax
        lda     ($12),Y
        cmp     #$FF
        bne     L5_83F3
        lda     #$20
        bne     L5_83F5
L5_83F3:
        adc     $10
L5_83F5:
        sta     $0130,X
        iny
        lda     ($12),Y
        cmp     #$FF
        bne     L5_8403
        lda     #$20
        bne     L5_8405
L5_8403:
        adc     $10
L5_8405:
        sta     $0131,X
        iny
        lda     ($12),Y
        cmp     #$FF
        bne     L5_8413
        lda     #$20
        bne     L5_8415
L5_8413:
        adc     $10
L5_8415:
        sta     $0150,X
        iny
        lda     ($12),Y
        cmp     #$FF
        bne     L5_8423
        lda     #$20
        bne     L5_8425
L5_8423:
        adc     $10
L5_8425:
        sta     $0151,X
        iny
        lda     ($12),Y
        sta     $12
        and     #$07
        sta     $13
        lda     $14
        and     #$01
        tay
        lda     $AE
        and     #$01
        beq     L5_843E
        iny
        iny
L5_843E:
        lda     $14
        lsr     A
        tax
        lda     $04E8,X
        and     $8469,Y
        sta     $10
        lda     $846D,Y
        ldy     $13
        and     $0199,Y
        ora     $10
        sta     $04E8,X
        ldx     $14
        lda     $12
        and     #$F0
        ora     $11
        sta     $04C0,X
        dex
        bmi     L5_8468
        jmp     L5_83B5
L5_8468:
        rts

; ---- UNCLAIMED (gap) $8469-$8470, 8 bytes
        .byte   $FC,$F3,$CF,$3F,$03,$0C,$30,$C0

; ---- bank5.code_8471 (code) $8471-$84AB, 59 bytes
L5_8471:
        lda     $0620,X
        asl     A
        tay
        lda     $960F,Y
        sta     $05C0,X
        lda     $9610,Y
        sta     $05D8,X
        rts
L5_8483:
        lda     $05C0,X
        clc
        adc     $0638,X
        sta     $05C0,X
        sta     $10
        lda     $05D8,X
        adc     #$00
        sta     $05D8,X
        sta     $11
        ldy     #$00
        lda     ($10),Y
        sta     $15
        iny
        lda     ($10),Y
        sta     $14
        tya
        sta     $0638,X
        rts
L5_84A9:
        jsr     L7_C06C

; ---- bank5.inline_84AC (data) $84AC-$84AF, 4 bytes
; Inline argument at $84AC
        .byte   $40,$27,$C0,$00

; ---- bank5.code_84B0 (code) $84B0-$84C2, 19 bytes
        lda     #$24
        sta     $15
        lda     #$20
        sta     $14
        lda     #$1C
        sta     $17
        lda     #$18
        sta     $16
        jmp     L7_C084

; ---- UNCLAIMED (gap) $84C3-$84CA, 8 bytes
        .byte   $05,$0F,$1F,$FF,$00,$01,$02,$03

; ---- bank5.code_84CB (code) $84CB-$8517, 77 bytes
L5_84CB:
        sei
        jsr     L7_C00F
        ldx     #$18
L5_84D1:
        lda     $0180,X
        sta     $04CF,X
        dex
        bne     L5_84D1
        jsr     L5_84A9
        lda     $0200
        sta     $0177
        jsr     L7_C015
        lda     #$B4
        sta     $FC
        lda     #$01
        sta     $A2
        lda     #$C3
        sta     $18
        lda     #$84
        sta     $19
        jsr     L7_C05D
        lda     #$16
        sta     $0196
        lda     #$30
        sta     $0197
        lda     #$03
        sta     $017F
        lda     #$10
        sta     $19
        sta     $18
        lda     #$03
        ldy     #$02
        jsr     L7_C042
        jsr     L7_C06F

; ---- bank5.inline_8518 (data) $8518-$852A, 19 bytes
; Queued PPU write at $8518
        .byte   $10,$10,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$80,$80,$80,$80
        .byte   $80,$80,$80

; ---- bank5.code_852B (code) $852B-$852D, 3 bytes
        jsr     L7_C06F

; ---- bank5.inline_852E (text) $852E-$8533, 6 bytes
; "KEY" at $852E
        .byte   $03,$27,$B0,$4B,$45,$59

; ---- bank5.code_8534 (code) $8534-$8549, 22 bytes
        jsr     L5_8805
        ldy     #$00
        sty     $18
        lda     #$18
        sta     $19
L5_853F:
        lda     $18
        pha
        lda     $19
        pha
        tya
        pha
        jsr     L7_C006

; ---- bank5.inline_854A (data) $854A-$854C, 3 bytes
; Far-call argument at $854A
        .byte   $02,$02,$80

; ---- bank5.code_854D (code) $854D-$856D, 33 bytes
        pla
        tay
        pla
        sta     $19
        pla
        clc
        adc     #$40
        sta     $18
        bcc     L5_855C
        inc     $19
L5_855C:
        iny
        cpy     #$0C
        bne     L5_853F
        ldy     #$01
L5_8563:
        lda     $18
        pha
        lda     $19
        pha
        tya
        pha
        jsr     L7_C006

; ---- bank5.inline_856E (data) $856E-$8570, 3 bytes
; Far-call argument at $856E
        .byte   $02,$05,$80

; ---- bank5.code_8571 (code) $8571-$8587, 23 bytes
        pla
        tay
        pla
        sta     $19
        pla
        clc
        adc     #$40
        sta     $18
        bcc     L5_8580
        inc     $19
L5_8580:
        iny
        cpy     #$08
        bne     L5_8563
        jsr     L7_C006

; ---- bank5.inline_8588 (data) $8588-$858A, 3 bytes
; Far-call argument at $8588
        .byte   $00,$17,$80

; ---- bank5.code_858B (code) $858B-$85DA, 80 bytes
        ldy     #$00
L5_858D:
        sty     $16
        cpy     #$1C
        bne     L5_8596
        jmp     L5_85EA
L5_8596:
        bcs     L5_85AC
        sty     $17
        tya
        lsr     A
        lsr     A
        jsr     L7_C078
        ldy     $17
        and     $04B0
        beq     L5_85A9
        lda     #$01
L5_85A9:
        pha
        bpl     L5_85C1
L5_85AC:
        lda     $8690,Y
        ora     #$20
        sta     $18
        lda     $8691,Y
        sta     $19
        tya
        lsr     A
        lsr     A
        sbc     #$07
        jsr     L7_C075
        pha
L5_85C1:
        tay
        lda     $85DA,Y
        sta     $17
        ldy     $16
        lda     $8690,Y
        sta     $18
        lda     $8691,Y
        sta     $19
        pla
        bne     L5_85DE
        lda     #$20
        bne     L5_85E1
        brk

; ---- UNCLAIMED (gap) $85DB-$85DD, 3 bytes
        .byte   $00,$55,$AA

; ---- bank5.code_85DE (code) $85DE-$85F9, 28 bytes
L5_85DE:
        lda     $8693,Y
L5_85E1:
        pha
        lda     $8692,Y
        tay
        pla
        jsr     L7_C054
L5_85EA:
        lda     $16
        clc
        adc     #$04
        tay
        cpy     #$50
        beq     L5_85F7
        jmp     L5_858D
L5_85F7:
        jsr     L7_C06F

; ---- bank5.inline_85FA (text) $85FA-$85FE, 5 bytes
; "NO" at $85FA
        .byte   $02,$2D,$C2,$4E,$4F

; ---- bank5.code_85FF (code) $85FF-$8601, 3 bytes
        jsr     L7_C06F

; ---- bank5.inline_8602 (text) $8602-$8607, 6 bytes
; "USE" at $8602
        .byte   $03,$2D,$E2,$55,$53,$45

; ---- bank5.code_8608 (code) $8608-$8611, 10 bytes
        lda     $04AE
        and     #$C0
        beq     L5_8625
        jsr     L7_C06F

; ---- bank5.inline_8612 (text) $8612-$8616, 5 bytes
; "EE" at $8612
        .byte   $02,$2E,$50,$45,$45

; ---- bank5.code_8617 (code) $8617-$8627, 17 bytes
        lda     #$2E
        sta     $19
        lda     #$70
        sta     $18
        lda     $04AF
        jsr     L7_C051
L5_8625:
        jsr     L7_C06F

; ---- bank5.inline_8628 (text) $8628-$8632, 11 bytes
; "CHIP MAX" at $8628
        .byte   $08,$2C,$90,$43,$48,$49,$50,$20,$4D,$41,$58

; ---- bank5.code_8633 (code) $8633-$864E, 28 bytes
        lda     $4E
        sta     $16
        lda     $4F
        sta     $17
        lda     #$2C
        sta     $19
        lda     #$99
        sta     $18
        jsr     L7_C04E
        jsr     L5_8782
        jsr     L5_879F
        jsr     L7_C06F

; ---- bank5.inline_864F (text) $864F-$865D, 15 bytes
; "WEAPON POWER" at $864F
        .byte   $0C,$2D,$30,$57,$45,$41,$50,$4F,$4E,$20,$50,$4F,$57,$45,$52

; ---- bank5.code_865E (code) $865E-$8660, 3 bytes
        jsr     L7_C06F

; ---- bank5.inline_8661 (text) $8661-$866B, 11 bytes
; "USE CHIP" at $8661
        .byte   $08,$2D,$50,$55,$53,$45,$20,$43,$48,$49,$50

; ---- bank5.code_866C (code) $866C-$8689, 30 bytes
        jsr     L5_89CB
        lda     $FF
        and     #$DF
        ora     #$08
        sta     $FF
        sta     $2000
        lda     $3C
        sta     $0176
        lda     #$05
        sta     $15
        lda     #$00
        sta     $14
        jsr     L7_C006

; ---- bank5.inline_868A (data) $868A-$868C, 3 bytes
; Far-call argument at $868A
        .byte   $02,$1D,$80

; ---- bank5.code_868D (code) $868D-$868F, 3 bytes
        jmp     L7_C063

; ---- UNCLAIMED (gap) $8690-$86DF, 80 bytes
        .byte   $10,$2C,$C4,$B0,$12,$2C,$C4,$B4,$14,$2C,$C5,$B8,$16,$2C,$C5,$BC
        .byte   $18,$2C,$C6,$C0,$1A,$2C,$C6,$C4,$1C,$2C,$C7,$C8,$00,$00,$00,$00
        .byte   $C8,$2D,$DA,$80,$CE,$2D,$DB,$84,$D4,$2D,$DD,$88,$DA,$2D,$DE,$8C
        .byte   $02,$2E,$E0,$90,$08,$2E,$E2,$94,$0E,$2E,$E3,$98,$14,$2E,$E5,$9C
        .byte   $1A,$2E,$E6,$A0,$42,$2E,$E0,$A4,$48,$2E,$E2,$A8,$4E,$2E,$E3,$AC

; ---- bank5.code_86E0 (code) $86E0-$86E2, 3 bytes
L5_86E0:
        jsr     L7_C06F

; ---- bank5.inline_86E3 (data) $86E3-$86EB, 9 bytes
; Queued PPU write at $86E3
        .byte   $C7,$3C,$20,$20,$20,$20,$F7,$00,$FF

; ---- bank5.code_86EC (code) $86EC-$86F3, 8 bytes
        rts
L5_86ED:
        lda     $3C
        beq     L5_86E0
        jsr     L7_C06F

; ---- bank5.inline_86F4 (data) $86F4-$86FC, 9 bytes
; Queued PPU write at $86F4
        .byte   $C7,$3C,$3C,$3E,$3D,$3F,$F7,$00,$FF

; ---- bank5.code_86FD (code) $86FD-$870C, 16 bytes
        lda     #$13
        sta     $19
        lda     #$C0
        sta     $18
        lda     $3C
        sec
        sbc     #$01
        jsr     L7_C006

; ---- bank5.inline_870D (data) $870D-$870F, 3 bytes
; Far-call argument at $870D
        .byte   $02,$02,$80

; ---- bank5.code_8710 (code) $8710-$875C, 77 bytes
        rts
L5_8711:
        sei
        jsr     L7_C00F
        jsr     L5_86ED
        lda     $3C
        cmp     $0176
        beq     L5_8732
        ldx     #$03
L5_8721:
        jsr     L7_C048
        inx
        cpx     #$05
        bne     L5_8721
        lda     $30
        and     #$08
        bne     L5_8732
        jsr     L7_C069
L5_8732:
        jsr     L7_C072
        jsr     L7_C015
        jsr     L5_84A9
        lda     $FF
        and     #$F7
        ora     #$20
        sta     $FF
        sta     $2000
        lda     $5C
        jsr     L5_ACA9
        bit     $30
        bvc     L5_8757
        lda     #$01
        jsr     L5_ACA9
        jmp     L5_8760
L5_8757:
        jsr     L7_C08A
        jsr     L7_C006

; ---- bank5.inline_875D (data) $875D-$875F, 3 bytes
; Far-call argument at $875D
        .byte   $02,$0B,$80

; ---- bank5.code_8760 (code) $8760-$8778, 25 bytes
L5_8760:
        ldx     #$18
L5_8762:
        lda     $04CF,X
        sta     $0180,X
        dex
        bne     L5_8762
        lda     #$03
        sta     $017F
        jsr     L7_C045
        jsr     L7_C087
        jsr     L7_C006

; ---- bank5.inline_8779 (data) $8779-$877B, 3 bytes
; Far-call argument at $8779
        .byte   $06,$FF,$7F

; ---- bank5.code_877C (code) $877C-$8784, 9 bytes
        lda     $0177
        jmp     L7_C060
L5_8782:
        jsr     L7_C06F

; ---- bank5.inline_8785 (text) $8785-$878D, 9 bytes
; "ATTACK" at $8785
        .byte   $06,$2C,$B0,$41,$54,$54,$41,$43,$4B

; ---- bank5.code_878E (code) $878E-$87A1, 20 bytes
        lda     #$2C
        sta     $19
        lda     #$B7
        sta     $18
        lda     #$CD
        sta     $15
        lda     $4A
        jmp     L5_87B9
L5_879F:
        jsr     L7_C06F

; ---- bank5.inline_87A2 (text) $87A2-$87AA, 9 bytes
; "SHIELD" at $87A2
        .byte   $06,$2C,$D0,$53,$48,$49,$45,$4C,$44

; ---- bank5.code_87AB (code) $87AB-$87E3, 57 bytes
        lda     #$2C
        sta     $19
        lda     #$D7
        sta     $18
        lda     #$CC
        sta     $15
        lda     $4B
L5_87B9:
        bne     L5_87BC
        rts
L5_87BC:
        pha
        clc
        adc     #$03
        jsr     L7_C04B
        jsr     L7_C03C
        tay
        pla
        sta     $10
        sta     $0100,Y
        lda     $19
        sta     $0101,Y
        lda     $18
        sta     $0102,Y
L5_87D7:
        lda     $15
        sta     $0103,Y
        iny
        dec     $10
        bne     L5_87D7
        jmp     L7_C03F

; ---- UNCLAIMED (gap) $87E4-$8804, 33 bytes
        .byte   $0E,$27,$A1,$03,$0E,$2D,$81,$0C,$8C,$2C,$01,$05,$8C,$2C,$0E,$0A
        .byte   $01,$27,$A1,$07,$01,$27,$AE,$0B,$01,$2D,$81,$0D,$01,$2D,$8E,$0E
        .byte   $FF

; ---- bank5.code_8805 (code) $8805-$89C7, 451 bytes
L5_8805:
        lda     $A5
        bne     L5_8805
        ldx     #$00
L5_880B:
        lda     $87E4,X
        cmp     #$FF
        beq     L5_882D
        sta     $15
        lda     $87E5,X
        sta     $19
        lda     $87E6,X
        sta     $18
        lda     $87E7,X
        sta     $14
        jsr     L7_C036
        txa
        clc
        adc     #$04
        tax
        bne     L5_880B
L5_882D:
        lda     #$8A
        sta     $1B
        lda     #$6E
        sta     $1A
        lda     #$2C
        sta     $19
        lda     #$02
        sta     $18
        lda     #$00
        sta     $17
        lda     #$00
        sta     $14
L5_8845:
        ldx     #$0B
        lda     #$00
L5_8849:
        sta     $0150,X
        dex
        bpl     L5_8849
L5_884F:
        lda     #$00
        sta     $15
L5_8853:
        ldy     #$00
        lda     ($1A),Y
        cmp     #$80
        beq     L5_88B9
        ldy     #$01
        lda     ($1A),Y
        and     #$07
        beq     L5_886E
        sec
        sbc     #$01
        jsr     L7_C078
        and     $04B0
        beq     L5_88B9
L5_886E:
        jsr     L5_891F
        ldy     #$00
        lda     ($1A),Y
        bpl     L5_88B9
        ldy     #$02
        lda     ($1A),Y
        bpl     L5_88B9
        and     #$7F
        cmp     #$15
        bne     L5_8891
        lda     $04AA
        ora     #$FC
        and     $04A9
        cmp     #$FF
        bne     L5_88B9
        beq     L5_8896
L5_8891:
        jsr     L7_C07B
        bcc     L5_88B9
L5_8896:
        ldy     $17
        lda     $15
        asl     A
        asl     A
        adc     #$10
        sta     $0203,Y
        tya
        adc     #$04
        sta     $17
        lda     $14
        asl     A
        asl     A
        adc     #$3B
        sta     $0200,Y
        lda     #$01
        sta     $0201,Y
        lda     #$03
        sta     $0202,Y
L5_88B9:
        ldy     #$00
        lda     ($1A),Y
        and     #$0F
        sec
        adc     $1A
        sta     $1A
        lda     $1B
        adc     #$00
        sta     $1B
        inc     $15
        lda     $15
        cmp     #$18
        beq     L5_88D5
        jmp     L5_8853
L5_88D5:
        inc     $14
        lda     $14
        lsr     A
        bcc     L5_88DF
        jmp     L5_884F
L5_88DF:
        lda     #$0F
        jsr     L7_C04B
        jsr     L7_C03C
        tay
        lda     #$0C
        sta     $0100,Y
        lda     $18
        sta     $0102,Y
        clc
        adc     #$20
        sta     $18
        lda     $19
        sta     $0101,Y
        adc     #$00
        sta     $19
        ldx     #$00
L5_8902:
        lda     $0150,X
        bne     L5_8909
        lda     #$20
L5_8909:
        sta     $0103,Y
        iny
        inx
        cpx     #$0C
        bne     L5_8902
        jsr     L7_C03F
        lda     $14
        cmp     #$18
        beq     L5_891E
        jmp     L5_8845
L5_891E:
        rts
L5_891F:
        lda     $14
        lsr     A
        ldy     #$01
        bcc     L5_8928
        ldy     #$04
L5_8928:
        lda     $15
        lsr     A
        tax
        tya
        bcc     L5_8930
        asl     A
L5_8930:
        ora     $0150,X
        sta     $0150,X
        rts
L5_8937:
        lda     $F5
        ora     $F6
        bne     L5_8951
        lda     $F7
        ora     $F8
        bne     L5_8946
        jmp     L5_89C5
L5_8946:
        dec     $15
        beq     L5_894D
        jmp     L5_89C5
L5_894D:
        lda     #$06
        bne     L5_8953
L5_8951:
        lda     #$14
L5_8953:
        sta     $15
L5_8955:
        lda     $F7
        ora     $F8
        and     #$0F
        bne     L5_8960
        jmp     L5_89C5
L5_8960:
        cmp     #$01
        bne     L5_8970
        inc     $3C
        lda     $3C
        cmp     #$0D
        bcc     L5_89AA
        lda     #$00
        beq     L5_89A8
L5_8970:
        cmp     #$02
        bne     L5_897C
        dec     $3C
        bpl     L5_89AA
        lda     #$0C
        bne     L5_89A8
L5_897C:
        cmp     #$08
        bne     L5_8991
        lda     $3C
        sec
        sbc     #$05
        bcs     L5_89A8
        adc     #$0F
        cmp     #$0D
        bcc     L5_89A8
        sbc     #$05
        bcs     L5_89A8
L5_8991:
        cmp     #$04
        bne     L5_89C5
        lda     $3C
        clc
        adc     #$05
        cmp     #$0D
        bcc     L5_89A8
        cmp     #$0F
        bcs     L5_89A6
        sbc     #$09
        bcs     L5_89A8
L5_89A6:
        sbc     #$0F
L5_89A8:
        sta     $3C
L5_89AA:
        lda     #$3E
        jsr     L7_C030
        jsr     L7_C135
        lda     $3C
        beq     L5_89BC
        lda     $3D
        beq     L5_8955
        bne     L5_89BC
L5_89BC:
        jsr     L5_86ED
        jsr     L7_C072
        jsr     L5_89CB
L5_89C5:
        jsr     L7_C006

; ---- bank5.inline_89C8 (data) $89C8-$89CA, 3 bytes
; Far-call argument at $89C8
        .byte   $02,$1D,$80

; ---- bank5.code_89CB (code) $89CB-$8A6D, 163 bytes
L5_89CB:
        lda     #$04
        jsr     L7_C04B
        jsr     L7_C03C
        tay
        lda     #$01
        sta     $0100,Y
        lda     #$2D
        sta     $0101,Y
        lda     #$3D
        sta     $0102,Y
        lda     $3D
        clc
        adc     #$30
        sta     $0103,Y
        jsr     L7_C03F
        lda     #$2D
        sta     $19
        lda     #$5B
        sta     $18
        lda     $45
        jmp     L7_C051
L5_89FB:
        lda     #$E8
        clc
        adc     $AF
        sec
        sbc     $B7
        sta     $14
        ldx     #$0F
L5_8A07:
        lda     $04C0,X
        and     #$F0
        beq     L5_8A6A
        sta     $10
        lda     $04C0,X
        and     #$0F
        tay
        lda     $0478,Y
        asl     A
        tay
        lda     $803C,Y
        sta     $11
        lda     $803D,Y
        sta     $12
        lda     $10
        lsr     A
        lsr     A
        lsr     A
        lsr     A
        tay
        lda     ($11),Y
        beq     L5_8A6A
        sta     $15
        jsr     L7_C027
        bcs     L5_8A6D
        lda     $15
        sta     $0500,Y
        lda     $04C0,X
        sta     $0698,Y
        lda     $AE
        sta     $05F0,Y
        txa
        asl     A
        adc     $AC
        sta     $05C0,Y
        lda     $AD
        sta     $05D8,Y
        txa
        asl     A
        asl     A
        asl     A
        asl     A
        adc     #$08
        sta     $0530,Y
        lda     $14
        sta     $0518,Y
        txa
        lsr     A
        clc
        adc     $AA
        sta     $0608,Y
L5_8A6A:
        dex
        bpl     L5_8A07
L5_8A6D:
        rts

; ---- UNCLAIMED (gap) $8A6E-$960E, 2977 bytes
        .byte   $02,$36,$09,$36,$6E,$09,$08,$2A,$AE,$94,$43,$66,$19,$1E,$03,$5E
        .byte   $09,$28,$80,$80,$80,$80,$A3,$27,$03,$14,$03,$7F,$0A,$25,$15,$5F
        .byte   $0A,$29,$8C,$94,$82,$17,$8A,$43,$37,$1A,$20,$03,$6F,$0A,$2E,$14
        .byte   $57,$0A,$46,$94,$80,$36,$1B,$04,$37,$17,$C9,$94,$02,$13,$04,$A3
        .byte   $23,$02,$41,$14,$73,$04,$6F,$95,$82,$43,$84,$80,$80,$80,$02,$96
        .byte   $09,$80,$15,$3E,$09,$27,$9B,$95,$14,$D6,$09,$46,$94,$80,$80,$80
        .byte   $80,$82,$27,$01,$14,$D7,$0A,$15,$94,$03,$9F,$0A,$2D,$15,$AF,$0A
        .byte   $2F,$85,$95,$02,$C7,$0A,$03,$3F,$0A,$2D,$03,$CF,$0A,$03,$80,$15
        .byte   $BB,$04,$14,$5D,$94,$03,$EB,$04,$05,$43,$63,$14,$14,$75,$DB,$04
        .byte   $18,$6F,$94,$80,$80,$80,$80,$15,$BE,$09,$29,$68,$94,$03,$5E,$09
        .byte   $02,$82,$86,$89,$03,$9E,$09,$25,$80,$80,$80,$80,$15,$3F,$0A,$2B
        .byte   $C3,$93,$15,$CF,$0A,$2C,$E5,$93,$03,$AF,$0A,$2C,$14,$67,$0A,$66
        .byte   $93,$15,$5F,$0A,$2F,$04,$94,$03,$AF,$0A,$2E,$14,$57,$0A,$4D,$93
        .byte   $80,$03,$9B,$04,$14,$36,$3B,$04,$2A,$18,$AE,$94,$03,$6B,$04,$17
        .byte   $02,$C3,$04,$80,$15,$3C,$05,$10,$87,$94,$03,$6C,$05,$11,$02,$44
        .byte   $05,$35,$86,$09,$07,$BE,$94,$03,$AE,$09,$18,$03,$6E,$09,$06,$36
        .byte   $EE,$09,$34,$2A,$B3,$94,$03,$5E,$09,$23,$43,$36,$19,$1D,$36,$5E
        .byte   $09,$06,$25,$AE,$94,$80,$14,$97,$0A,$42,$93,$80,$03,$3F,$0A,$2D
        .byte   $43,$57,$1A,$1F,$03,$9F,$0A,$2B,$80,$15,$9F,$0A,$2C,$26,$94,$80
        .byte   $43,$A3,$14,$13,$03,$DB,$04,$01,$80,$80,$80,$03,$BC,$05,$13,$02
        .byte   $64,$05,$36,$4C,$05,$2C,$19,$C9,$94,$80,$80,$80,$15,$3E,$09,$27
        .byte   $64,$95,$82,$E6,$93,$15,$CE,$09,$23,$4E,$95,$03,$9E,$09,$18,$80
        .byte   $03,$AF,$0A,$21,$03,$6F,$0A,$29,$74,$C7,$0A,$41,$94,$03,$9F,$0A
        .byte   $01,$35,$A7,$0A,$09,$B3,$94,$15,$6F,$0A,$21,$66,$93,$14,$C7,$0A
        .byte   $E5,$93,$80,$80,$82,$A3,$8E,$15,$7B,$04,$10,$4E,$95,$02,$53,$04
        .byte   $80,$43,$B4,$15,$16,$15,$6C,$05,$1A,$6F,$95,$82,$44,$85,$80,$80
        .byte   $80,$03,$9E,$09,$04,$A3,$26,$03,$13,$02,$56,$09,$15,$9E,$09,$29
        .byte   $4D,$93,$80,$80,$80,$80,$82,$B7,$94,$A3,$47,$02,$43,$80,$80,$80
        .byte   $80,$A3,$13,$03,$0E,$02,$93,$04,$03,$9B,$04,$05,$80,$03,$BC,$05
        .byte   $19,$15,$6C,$05,$13,$D1,$94,$02,$44,$05,$43,$11,$11,$0E,$80,$80
        .byte   $36,$AE,$09,$33,$28,$C9,$94,$14,$66,$09,$66,$93,$15,$EE,$09,$2A
        .byte   $7F,$93,$15,$EE,$09,$27,$E5,$93,$03,$6E,$09,$06,$03,$5E,$09,$04
        .byte   $80,$80,$15,$9F,$0A,$2F,$49,$95,$80,$80,$03,$3B,$04,$01,$15,$6B
        .byte   $04,$02,$66,$93,$15,$6B,$04,$09,$9E,$93,$15,$EB,$04,$0C,$04,$94
        .byte   $03,$EB,$04,$17,$36,$CB,$04,$29,$13,$B3,$94,$80,$15,$BC,$05,$11
        .byte   $68,$94,$03,$6C,$05,$0E,$36,$4C,$05,$2B,$10,$BE,$94,$03,$A9,$01
        .byte   $0E,$03,$59,$01,$11,$80,$80,$80,$80,$80,$80,$75,$AE,$09,$02,$0D
        .byte   $95,$82,$56,$01,$80,$82,$97,$01,$80,$82,$33,$01,$15,$CB,$04,$09
        .byte   $F3,$94,$80,$80,$80,$80,$80,$80,$03,$BC,$05,$1A,$03,$6C,$05,$17
        .byte   $A3,$44,$03,$0F,$15,$39,$01,$10,$6F,$95,$82,$C1,$8B,$80,$15,$39
        .byte   $01,$08,$E3,$94,$03,$69,$01,$04,$02,$61,$01,$75,$59,$01,$03,$41
        .byte   $94,$80,$80,$75,$98,$00,$09,$17,$95,$80,$14,$90,$00,$1C,$95,$80
        .byte   $75,$98,$00,$06,$17,$95,$80,$80,$75,$3C,$05,$05,$44,$95,$03,$6C
        .byte   $05,$02,$15,$6C,$05,$09,$52,$94,$43,$64,$15,$15,$15,$6C,$05,$0E
        .byte   $6F,$95,$82,$E4,$8F,$03,$6C,$05,$09,$36,$4C,$05,$01,$05,$B3,$94
        .byte   $36,$A9,$01,$26,$04,$B3,$94,$03,$59,$01,$11,$82,$11,$01,$02,$91
        .byte   $01,$80,$80,$75,$99,$01,$0A,$44,$95,$80,$36,$38,$00,$21,$09,$AE
        .byte   $94,$03,$F8,$00,$01,$03,$68,$00,$06,$14,$F0,$00,$A6,$95,$03,$68
        .byte   $00,$02,$15,$E8,$00,$07,$D9,$94,$43,$70,$10,$0C,$74,$60,$00,$03
        .byte   $95,$82,$C4,$01,$80,$80,$80,$80,$80,$80,$80,$03,$39,$01,$0F,$75
        .byte   $E9,$01,$06,$6F,$94,$03,$E9,$01,$0D,$36,$D9,$01,$24,$0A,$C9,$94
        .byte   $80,$80,$82,$A0,$81,$14,$60,$00,$EB,$94,$03,$D8,$00,$02,$15,$98
        .byte   $00,$09,$9B,$95,$A3,$30,$06,$3D,$03,$D8,$00,$07,$A3,$30,$06,$3C
        .byte   $A3,$50,$06,$3B,$03,$98,$00,$08,$80,$80,$80,$43,$14,$16,$17,$80
        .byte   $36,$1C,$06,$2E,$03,$C9,$94,$80,$80,$80,$15,$B9,$01,$03,$50,$94
        .byte   $15,$59,$01,$0D,$87,$94,$80,$03,$A9,$01,$08,$43,$51,$11,$0D,$80
        .byte   $80,$80,$36,$98,$00,$05,$08,$AE,$94,$82,$90,$95,$A3,$80,$06,$3E
        .byte   $03,$98,$00,$03,$A3,$B0,$03,$03,$A3,$C0,$06,$3A,$03,$B8,$00,$01
        .byte   $15,$68,$00,$05,$08,$95,$82,$64,$86,$75,$6C,$06,$1B,$FB,$94,$02
        .byte   $F4,$06,$03,$6C,$06,$04,$15,$FC,$06,$1D,$8C,$94,$02,$44,$06,$80
        .byte   $80,$15,$A9,$01,$0F,$68,$94,$15,$E9,$01,$0E,$3F,$94,$03,$69,$01
        .byte   $06,$02,$61,$01,$36,$C9,$01,$23,$10,$BE,$94,$80,$80,$80,$15,$B8
        .byte   $00,$01,$D9,$95,$15,$F8,$00,$03,$85,$95,$03,$78,$00,$04,$A3,$F0
        .byte   $03,$00,$36,$F8,$00,$35,$02,$BE,$94,$02,$70,$00,$15,$F8,$00,$03
        .byte   $C8,$95,$A3,$65,$02,$42,$35,$64,$06,$0A,$B3,$94,$02,$54,$06,$36
        .byte   $8C,$06,$2D,$11,$BE,$94,$80,$02,$94,$06,$80,$80,$80,$80,$80,$80
        .byte   $80,$80,$80,$82,$31,$01,$15,$68,$00,$07,$E9,$94,$43,$D0,$10,$0B
        .byte   $A3,$80,$03,$02,$A3,$80,$03,$01,$03,$98,$00,$01,$82,$80,$01,$74
        .byte   $80,$00,$EA,$95,$02,$90,$00,$80,$80,$03,$AC,$06,$18,$82,$54,$90
        .byte   $15,$2C,$06,$1C,$66,$93,$15,$FC,$06,$16,$D1,$93,$36,$4C,$06,$02
        .byte   $19,$AE,$94,$80,$80,$03,$39,$02,$09,$43,$61,$12,$10,$03,$69,$02
        .byte   $12,$36,$59,$02,$25,$06,$AE,$94,$14,$31,$02,$90,$95,$03,$59,$02
        .byte   $0B,$75,$99,$02,$09,$24,$95,$80,$75,$B8,$00,$05,$37,$95,$36,$68
        .byte   $00,$39,$04,$C9,$94,$03,$78,$00,$06,$14,$E0,$00,$B4,$95,$15,$78
        .byte   $00,$03,$DF,$94,$02,$60,$00,$75,$E8,$00,$09,$03,$95,$82,$55,$01
        .byte   $80,$80,$14,$94,$06,$7A,$95,$80,$14,$94,$06,$71,$93,$80,$80,$80
        .byte   $14,$B1,$02,$C3,$93,$15,$69,$02,$08,$5B,$93,$15,$79,$02,$0B,$90
        .byte   $95,$03,$C9,$02,$05,$82,$91,$8C,$03,$A9,$02,$13,$03,$C9,$02,$05
        .byte   $80,$82,$92,$01,$80,$15,$98,$00,$02,$3C,$95,$80,$02,$A0,$00,$A3
        .byte   $50,$03,$10,$80,$75,$9D,$07,$0D,$24,$95,$80,$02,$34,$06,$15,$FC
        .byte   $06,$1D,$68,$94,$14,$64,$06,$66,$93,$14,$F4,$06,$8A,$93,$14,$44
        .byte   $06,$04,$94,$80,$80,$15,$99,$02,$11,$71,$93,$80,$82,$81,$82,$80
        .byte   $03,$99,$02,$06,$80,$80,$80,$74,$92,$03,$24,$95,$80,$82,$95,$88
        .byte   $80,$80,$A3,$83,$03,$12,$80,$02,$95,$07,$80,$43,$84,$16,$18,$02
        .byte   $94,$06,$80,$15,$8C,$06,$13,$42,$93,$80,$80,$80,$15,$A9,$02,$09
        .byte   $B5,$93,$15,$79,$02,$12,$5B,$93,$36,$69,$02,$36,$03,$AE,$94,$03
        .byte   $69,$02,$13,$15,$E9,$02,$0F,$3D,$94,$43,$51,$12,$0F,$80,$03,$3A
        .byte   $03,$0C,$02,$C2,$03,$80,$75,$9D,$08,$0E,$29,$95,$80,$80,$80,$80
        .byte   $03,$9D,$07,$21,$80,$80,$82,$95,$01,$80,$80,$80,$80,$80,$80,$A3
        .byte   $81,$02,$3F,$80,$80,$80,$A3,$81,$03,$0C,$80,$03,$9A,$03,$05,$80
        .byte   $80,$36,$AD,$08,$31,$16,$B3,$94,$03,$6D,$08,$10,$43,$55,$18,$1B
        .byte   $80,$80,$15,$AD,$07,$1F,$D7,$94,$43,$65,$17,$19,$03,$5D,$07,$0D
        .byte   $02,$95,$07,$03,$3D,$07,$10,$03,$5D,$07,$1C,$80,$80,$80,$80,$80
        .byte   $80,$80,$80,$80,$80,$75,$9A,$03,$13,$9D,$94,$80,$36,$3D,$08,$38
        .byte   $27,$BE,$94,$15,$7D,$08,$26,$64,$95,$82,$45,$92,$02,$A5,$08,$03
        .byte   $5D,$08,$23,$80,$80,$80,$03,$9D,$07,$18,$82,$B5,$91,$36,$DD,$07
        .byte   $2F,$1E,$AE,$94,$14,$B5,$07,$52,$94,$14,$65,$07,$3F,$94,$02,$55
        .byte   $07,$80,$03,$3A,$03,$10,$43,$52,$13,$11,$03,$3A,$03,$14,$03,$5A
        .byte   $03,$16,$82,$22,$83,$82,$62,$8D,$14,$62,$03,$59,$95,$03,$DA,$03
        .byte   $09,$80,$15,$BD,$08,$24,$66,$93,$15,$DD,$08,$10,$D1,$93,$80,$03
        .byte   $3D,$08,$25,$15,$ED,$08,$24,$3D,$94,$35,$45,$08,$32,$BE,$94,$80
        .byte   $02,$35,$07,$14,$E5,$07,$5D,$94,$15,$DD,$07,$20,$7A,$95,$03,$AD
        .byte   $07,$0D,$03,$CD,$07,$20,$A3,$25,$03,$11,$43,$D5,$17,$1A,$80,$03
        .byte   $9A,$03,$03,$03,$AA,$03,$15,$15,$CA,$03,$10,$DD,$94,$15,$BA,$03
        .byte   $0D,$C3,$93,$14,$62,$03,$5B,$93,$03,$5A,$03,$16,$80,$15,$9A,$03
        .byte   $03,$68,$94,$80,$14,$B5,$08,$C3,$93,$14,$D5,$08,$E5,$93,$80,$03
        .byte   $AD,$08,$1F,$75,$7D,$08,$20,$9D,$94,$82,$45,$01,$80,$15,$9D,$07
        .byte   $10,$15,$94,$82,$35,$01,$14,$D5,$07,$D5,$94,$03,$3D,$07,$1C,$02
        .byte   $55,$07,$80,$03,$BD,$07,$1E,$A3,$45,$02,$40,$35,$B2,$03,$27,$B3
        .byte   $94,$02,$62,$03,$15,$6A,$03,$14,$66,$93,$15,$EA,$03,$15,$E5,$93
        .byte   $03,$7A,$03,$10,$02,$E2,$03,$36,$5A,$03,$28,$13,$BE,$94,$02,$92
        .byte   $03,$80,$15,$BD,$08,$23,$B5,$93,$15,$FD,$08,$18,$D1,$93,$02,$55
        .byte   $08,$43,$35,$18,$1C,$03,$CD,$08,$25,$80,$80,$15,$BD,$07,$18,$71
        .byte   $93,$03,$CD,$07,$1F,$03,$BD,$07,$21,$14,$D5,$07,$9B,$95,$03,$9D
        .byte   $07,$04,$02,$35,$07,$03,$DD,$07,$22,$80,$03,$AA,$03,$0D,$A3,$42
        .byte   $03,$0D,$80,$80,$82,$82,$01,$80,$43,$A2,$13,$12,$03,$CA,$03,$05
        .byte   $80,$14,$A5,$08,$66,$93,$14,$C5,$08,$E5,$93,$03,$AD,$08,$26,$35
        .byte   $C5,$08,$04,$C9,$94,$80,$80,$80,$14,$A5,$07,$B5,$93,$36,$6D,$07
        .byte   $03,$1F,$F8,$95,$02,$C5,$07,$82,$A5,$87,$15,$ED,$07,$22,$59,$95
        .byte   $03,$ED,$07,$04,$36,$CD,$07,$30,$21,$C9,$94,$80,$00,$00,$00,$00
        .fill   18,$00
        .byte   $06,$00,$0E,$00,$1F,$E0,$1F,$E0,$0E,$00,$06,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$60,$00,$70,$07,$F8,$07,$F8,$00,$70,$00,$60,$00,$00
        .byte   $01,$80,$03,$C0,$07,$E0,$07,$E0,$01,$80,$01,$80,$01,$80,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00,$01,$80,$01,$80,$01,$80,$07,$E0
        .byte   $07,$E0,$03,$C0,$00,$00,$00,$00,$00,$00,$03,$80,$02,$80,$03,$80
        .byte   $00,$00,$00,$00,$00,$00,$00,$00,$00,$60,$1C,$20,$14,$60,$00,$00
        .byte   $00,$00,$0C,$50,$08,$70,$0C,$00,$00,$00,$04,$40,$04,$40,$04,$40
        .byte   $00,$00,$0E,$70,$00,$00,$1C,$E0,$00,$00,$00,$00,$18,$00,$12,$00
        .byte   $06,$00,$00,$00,$00,$00,$00,$60,$00,$48,$00,$18,$00,$00,$00,$00
        .byte   $3C,$00,$3E,$00,$0F,$00,$0F,$00,$0E,$00,$3C,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$3C,$00,$7C,$00,$F0,$00,$F0,$00,$70,$00,$3C,$00,$00
        .byte   $00,$00,$1C,$78,$1C,$78,$0F,$F0,$07,$E0,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$E0,$0F,$F0
        .byte   $1C,$78,$1C,$78,$00,$00,$00,$00,$00,$00,$3C,$00,$04,$00,$04,$00
        .byte   $04,$00,$3C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3C,$00,$20
        .byte   $00,$20,$00,$20,$00,$3C,$00,$00,$00,$00,$04,$40,$04,$40,$04,$40
        .byte   $07,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$07,$C0,$04,$40,$04,$40,$04,$40,$00,$00,$18,$18
        .byte   $3C,$3C,$3F,$FC,$3F,$FC,$3F,$FC,$3F,$FC,$3F,$FC,$1F,$F8,$00,$00
        .byte   $0C,$00,$0C,$00,$00,$C0,$00,$C0,$0C,$00,$0C,$30,$00,$30,$00,$00
        .byte   $00,$03,$60,$03,$09,$07,$BF,$09,$45,$5B,$09,$55,$51,$80,$03,$09
        .byte   $65,$5F,$09,$87,$8B,$09,$75,$51,$09,$88,$43,$60,$03,$09,$70,$7F
        .byte   $09,$63,$47,$09,$83,$47,$60,$03,$09,$79,$7F,$09,$89,$4F,$09,$7F
        .byte   $C1,$80,$03,$09,$07,$BF,$09,$67,$BD,$09,$69,$87,$09,$68,$85,$60
        .byte   $03,$09,$70,$7F,$09,$76,$7F,$09,$7C,$4F,$C0,$03,$09,$07,$BF,$09
        .byte   $67,$BF,$09,$70,$7F,$09,$78,$7F,$09,$7E,$43,$09,$76,$C1,$E0,$03
        .byte   $09,$70,$7F,$09,$76,$7F,$09,$7C,$4F,$09,$62,$55,$09,$68,$55,$09
        .byte   $82,$55,$09,$88,$55,$80,$03,$09,$07,$BF,$09,$7A,$7F,$09,$58,$47
        .byte   $09,$6A,$C1,$80,$03,$09,$77,$7F,$09,$87,$8F,$09,$7D,$47,$09,$88
        .byte   $C1,$C0,$03,$09,$57,$BF,$09,$70,$7F,$09,$58,$87,$09,$59,$87,$09
        .byte   $76,$C1,$09,$B7,$C1,$80,$03,$09,$07,$BF,$09,$70,$7F,$09,$67,$83
        .byte   $09,$76,$C1,$A0,$03,$09,$4A,$BF,$09,$39,$83,$09,$3B,$83,$09,$99
        .byte   $83,$09,$9B,$83,$A0,$03,$09,$70,$7F,$09,$39,$9F,$09,$76,$47,$09
        .byte   $93,$47,$09,$99,$47,$A0,$03,$09,$87,$7F,$09,$49,$D5,$09,$97,$87
        .byte   $09,$4A,$85,$09,$69,$05,$E0,$03,$09,$37,$FF,$09,$42,$FF,$09,$47
        .byte   $FF,$09,$43,$DF,$09,$07,$87,$09,$A7,$83,$09,$9D,$C1,$01,$03,$01
        .byte   $0A,$21,$01,$05,$56,$89,$41,$03,$09,$66,$5F,$09,$76,$5F,$02,$02
        .byte   $02,$0A,$62,$03,$0A,$85,$4F,$0A,$AA,$07,$0A,$A9,$C1,$62,$03,$09
        .byte   $66,$55,$09,$76,$55,$09,$59,$89,$23,$01,$03,$27,$43,$03,$0A,$63
        .byte   $01,$0A,$57,$8F,$0A,$58,$8F,$04,$47,$43,$43,$03,$09,$46,$4F,$09
        .byte   $55,$61,$24,$03,$03,$B7,$43,$24,$0A,$0A,$B7,$43,$A4,$03,$0A,$95
        .byte   $0F,$0A,$B7,$0F,$0A,$A6,$07,$0A,$57,$C1,$03,$B8,$C1,$A4,$09,$04
        .byte   $96,$4F,$01,$95,$C7,$01,$B8,$07,$01,$85,$61,$04,$A7,$43,$25,$01
        .byte   $06,$67,$C1,$65,$01,$09,$56,$C5,$09,$76,$05,$06,$67,$C1,$65,$01
        .byte   $09,$56,$87,$09,$58,$87,$06,$67,$C1,$45,$01,$06,$58,$C1,$09,$67
        .byte   $C1,$06,$09,$07,$09,$08,$09,$12,$09,$06,$01,$07,$01,$08,$01,$12
        .byte   $01,$06,$0A,$07,$0A,$08,$0A,$12,$0A,$09,$02,$49,$02,$09,$55,$C3
        .byte   $09,$85,$03,$49,$02,$0A,$54,$8F,$0A,$52,$43,$49,$02,$05,$64,$C3
        .byte   $05,$74,$03,$2A,$02,$04,$4C,$A3,$2A,$02,$09,$66,$83,$2A,$02,$05
        .byte   $5A,$8F,$2A,$02,$05,$4B,$95,$2B,$02,$04,$39,$83,$4B,$09,$03,$39
        .byte   $C7,$03,$3A,$85,$2B,$02,$05,$66,$49,$8B,$02,$0A,$44,$C3,$0A,$5A
        .byte   $03,$05,$33,$C1,$05,$3C,$C1,$2C,$02,$04,$57,$C1,$4C,$02,$09,$54
        .byte   $55,$09,$5A,$45,$2C,$02,$05,$87,$C1,$2C,$02,$0A,$66,$4F,$6D,$01
        .byte   $09,$44,$95,$09,$66,$85,$09,$A4,$C1,$6D,$01,$09,$44,$95,$09,$46
        .byte   $95,$09,$A4,$45,$6E,$01,$09,$4B,$95,$09,$69,$85,$09,$AB,$C1,$6E
        .byte   $01,$09,$49,$95,$09,$4B,$95,$09,$A9,$45,$6F,$01,$09,$54,$55,$09
        .byte   $76,$45,$09,$5A,$C1,$6F,$01,$09,$54,$55,$09,$74,$55,$09,$5A,$85
        .byte   $70,$01,$09,$84,$55,$09,$66,$45,$09,$8A,$C1,$70,$01,$09,$64,$55
        .byte   $09,$84,$55,$09,$6A,$85,$80,$03,$03,$44,$9F,$03,$45,$DF,$03,$5A
        .byte   $8F,$09,$4A,$C1,$C0,$03,$03,$65,$7F,$03,$85,$7F,$03,$45,$5F,$09
        .byte   $4A,$C1,$03,$55,$C1,$03,$7A,$C1,$A0,$03,$03,$65,$7F,$03,$85,$7F
        .byte   $03,$45,$5F,$03,$55,$85,$09,$4A,$C1,$A0,$03,$03,$44,$8F,$03,$47
        .byte   $8F,$03,$85,$5B,$03,$5A,$87,$09,$4A,$C1,$91,$04,$05,$65,$7F,$05
        .byte   $85,$7F,$05,$75,$85,$05,$7A,$C1,$E5,$03,$09,$39,$BF,$09,$70,$7F
        .byte   $09,$35,$A7,$09,$36,$A3,$09,$37,$A3,$09,$38,$A3,$06,$67,$C1

; ---- bank5.msgtable_960F (pointer_table) $960F-$9638, 42 bytes
; Dialogue message pointer table
        .byte   $39,$96,$B3,$98,$B6,$99,$13,$9B,$6F,$9B,$C8,$9B,$C8,$9B,$D1,$9B
        .byte   $06,$9C,$2C,$9C,$38,$9C,$43,$9C,$90,$9C,$C8,$9C,$2C,$9D,$A3,$9D
        .byte   $E2,$9D,$26,$9E,$7D,$9E,$B5,$9E,$E4,$9E

; ---- bank5.message_9639 (text) $9639-$98B2, 634 bytes
; "If someone is reading this... I must have failed..."
        .byte   $49,$66,$20,$73,$6F,$6D,$65,$6F,$6E,$65,$20,$69,$73,$0D,$72,$65
        .byte   $61,$64,$69,$6E,$67,$20,$74,$68,$69,$73,$5B,$5B,$5B,$0D,$49,$20
        .byte   $6D,$75,$73,$74,$20,$68,$61,$76,$65,$0D,$66,$61,$69,$6C,$65,$64
        .byte   $5B,$01,$54,$68,$69,$73,$20,$73,$74,$61,$72,$20,$5E,$4E,$41,$4A
        .byte   $55,$5E,$0D,$77,$61,$73,$20,$6F,$75,$72,$20,$68,$6F,$6D,$65,$3C
        .byte   $01,$62,$75,$74,$20,$77,$65,$20,$77,$65,$72,$65,$0D,$69,$6E,$76
        .byte   $61,$64,$65,$64,$20,$62,$79,$0D,$65,$76,$69,$6C,$20,$6C,$69,$66
        .byte   $65,$3D,$66,$6F,$72,$6D,$73,$5B,$01,$45,$76,$65,$72,$79,$6F,$6E
        .byte   $65,$20,$65,$78,$63,$65,$70,$74,$0D,$6D,$65,$20,$77,$61,$73,$20
        .byte   $6B,$69,$6C,$6C,$65,$64,$5B,$01,$49,$20,$61,$6D,$20,$67,$6F,$69
        .byte   $6E,$67,$20,$74,$6F,$0D,$74,$72,$79,$20,$74,$6F,$20,$61,$63,$74
        .byte   $69,$76,$61,$74,$65,$0D,$74,$68,$65,$20,$73,$65,$6C,$66,$3D,$0D
        .byte   $64,$65,$73,$74,$72,$75,$63,$74,$20,$64,$65,$76,$69,$63,$65,$5B
        .byte   $01,$49,$66,$20,$49,$20,$66,$61,$69,$6C,$3C,$0D,$49,$20,$77,$6F
        .byte   $75,$6C,$64,$20,$6C,$69,$6B,$65,$20,$79,$6F,$75,$0D,$74,$6F,$20
        .byte   $64,$6F,$20,$74,$68,$69,$73,$20,$74,$61,$73,$6B,$0D,$73,$6F,$20
        .byte   $74,$68,$69,$73,$20,$63,$61,$6E,$6E,$6F,$74,$01,$68,$61,$70,$70
        .byte   $65,$6E,$20,$74,$6F,$20,$61,$6E,$79,$0D,$6F,$74,$68,$65,$72,$20
        .byte   $72,$61,$63,$65,$5B,$01,$54,$68,$65,$20,$73,$65,$6C,$66,$3D,$0D
        .byte   $64,$65,$73,$74,$72,$75,$63,$74,$0D,$6D,$65,$63,$68,$61,$6E,$69
        .byte   $73,$6D,$01,$69,$73,$20,$70,$72,$6F,$74,$65,$63,$74,$65,$64,$20
        .byte   $62,$79,$0D,$61,$20,$73,$61,$66,$65,$74,$79,$20,$64,$65,$76,$69
        .byte   $63,$65,$01,$77,$68,$69,$63,$68,$20,$69,$73,$20,$6C,$6F,$63,$61
        .byte   $74,$65,$64,$0D,$69,$6E,$0D,$74,$68,$65,$20,$75,$6E,$64,$65,$72
        .byte   $67,$72,$6F,$75,$6E,$64,$0D,$63,$6F,$72,$72,$69,$64,$6F,$72,$73
        .byte   $5B,$01,$52,$65,$6D,$6F,$76,$65,$20,$65,$61,$63,$68,$20,$73,$65
        .byte   $61,$6C,$0D,$61,$6E,$64,$20,$67,$6F,$20,$64,$65,$65,$70,$0D,$69
        .byte   $6E,$73,$69,$64,$65,$20,$4E,$41,$4A,$55,$5B,$01,$49,$66,$20,$79
        .byte   $6F,$75,$20,$64,$65,$73,$74,$72,$6F,$79,$0D,$61,$6C,$6C,$20,$31
        .byte   $30,$20,$73,$61,$66,$65,$74,$79,$0D,$64,$65,$76,$69,$63,$65,$73
        .byte   $3C,$74,$68,$65,$0D,$73,$65,$6C,$66,$3D,$64,$65,$73,$74,$72,$75
        .byte   $63,$74,$01,$73,$65,$71,$75,$65,$6E,$63,$65,$20,$77,$69,$6C,$6C
        .byte   $20,$62,$65,$0D,$61,$63,$74,$69,$76,$61,$74,$65,$64,$5B,$01,$49
        .byte   $20,$64,$6F,$6E,$60,$74,$20,$68,$61,$76,$65,$0D,$6D,$75,$63,$68
        .byte   $20,$74,$69,$6D,$65,$5B,$01,$49,$20,$68,$6F,$70,$65,$20,$74,$68
        .byte   $69,$73,$0D,$6D,$65,$73,$73,$61,$67,$65,$20,$77,$69,$6C,$6C,$0D
        .byte   $6E,$6F,$74,$20,$62,$65,$20,$72,$65,$61,$64,$20,$62,$79,$0D,$61
        .byte   $6E,$79,$6F,$6E,$65,$5B,$5B,$5B,$01,$69,$74,$20,$77,$69,$6C,$6C
        .byte   $20,$6D,$65,$61,$6E,$0D,$74,$68,$61,$74,$20,$49,$20,$68,$61,$76
        .byte   $65,$0D,$66,$61,$69,$6C,$65,$64,$5B,$00

; ---- bank5.message_98B3 (text) $98B3-$99B5, 259 bytes
; "I put some weapons in these boxes. Take them out..."
        .byte   $49,$20,$70,$75,$74,$20,$73,$6F,$6D,$65,$0D,$77,$65,$61,$70,$6F
        .byte   $6E,$73,$0D,$69,$6E,$20,$74,$68,$65,$73,$65,$20,$62,$6F,$78,$65
        .byte   $73,$5B,$01,$54,$61,$6B,$65,$20,$74,$68,$65,$6D,$20,$6F,$75,$74
        .byte   $20,$6F,$66,$0D,$74,$68,$65,$20,$62,$6F,$78,$65,$73,$20,$74,$6F
        .byte   $20,$75,$73,$65,$0D,$74,$68,$65,$6D,$5B,$01,$53,$6F,$6D,$65,$20
        .byte   $77,$65,$61,$70,$6F,$6E,$73,$0D,$68,$61,$76,$65,$20,$62,$65,$65
        .byte   $6E,$20,$73,$74,$6F,$6C,$65,$6E,$0D,$62,$79,$20,$73,$6F,$6D,$65
        .byte   $20,$6F,$66,$0D,$74,$68,$65,$20,$6C,$69,$66,$65,$3D,$66,$6F,$72
        .byte   $6D,$73,$3B,$01,$69,$66,$20,$79,$6F,$75,$20,$6E,$65,$65,$64,$0D
        .byte   $74,$68,$65,$73,$65,$20,$77,$65,$61,$70,$6F,$6E,$73,$01,$79,$6F
        .byte   $75,$20,$77,$69,$6C,$6C,$20,$68,$61,$76,$65,$20,$74,$6F,$0D,$64
        .byte   $65,$73,$74,$72,$6F,$79,$0D,$74,$68,$65,$20,$6C,$69,$66,$65,$3D
        .byte   $66,$6F,$72,$6D,$73,$5B,$01,$41,$6C,$6C,$20,$74,$68,$65,$20,$77
        .byte   $65,$61,$70,$6F,$6E,$73,$0D,$6E,$65,$65,$64,$0D,$50,$6F,$77,$65
        .byte   $72,$20,$43,$68,$69,$70,$73,$5B,$01,$59,$6F,$75,$20,$6D,$75,$73
        .byte   $74,$20,$73,$65,$61,$72,$63,$68,$0D,$66,$6F,$72,$20,$74,$68,$65
        .byte   $6D,$5B,$00

; ---- bank5.message_99B6 (text) $99B6-$9B12, 349 bytes
; "I had all the corridors sealed. If you need to k..."
        .byte   $49,$20,$68,$61,$64,$20,$61,$6C,$6C,$20,$74,$68,$65,$0D,$63,$6F
        .byte   $72,$72,$69,$64,$6F,$72,$73,$0D,$73,$65,$61,$6C,$65,$64,$5B,$01
        .byte   $49,$66,$20,$79,$6F,$75,$20,$6E,$65,$65,$64,$20,$74,$6F,$0D,$6B
        .byte   $6E,$6F,$77,$20,$68,$6F,$77,$20,$74,$6F,$0D,$72,$65,$6D,$6F,$76
        .byte   $65,$20,$74,$68,$65,$20,$73,$65,$61,$6C,$3C,$01,$61,$73,$6B,$20
        .byte   $74,$68,$65,$20,$70,$65,$72,$73,$6F,$6E,$0D,$77,$68,$6F,$20,$73
        .byte   $65,$61,$6C,$65,$64,$20,$69,$74,$5B,$01,$54,$6F,$20,$72,$65,$6D
        .byte   $6F,$76,$65,$20,$74,$68,$65,$0D,$73,$65,$61,$6C,$20,$61,$74,$20
        .byte   $63,$6F,$72,$72,$69,$64,$6F,$72,$0D,$4E,$4F,$5B,$31,$3C,$66,$69
        .byte   $72,$65,$0D,$61,$74,$20,$74,$68,$65,$20,$67,$61,$74,$65,$5B,$01
        .byte   $41,$6C,$6C,$20,$74,$68,$65,$20,$72,$6F,$6F,$6D,$73,$0D,$6C,$65
        .byte   $61,$64,$69,$6E,$67,$20,$74,$6F,$20,$74,$68,$65,$0D,$63,$6F,$72
        .byte   $72,$69,$64,$6F,$72,$73,$20,$61,$72,$65,$0D,$6C,$6F,$63,$6B,$65
        .byte   $64,$3C,$01,$73,$6F,$20,$75,$73,$65,$20,$74,$68,$65,$0D,$5E,$57
        .byte   $61,$72,$70,$20,$70,$61,$6E,$65,$6C,$5E,$20,$74,$6F,$0D,$67,$65
        .byte   $74,$20,$69,$6E,$74,$6F,$20,$74,$68,$65,$0D,$72,$6F,$6F,$6D,$5B
        .byte   $01,$54,$6F,$20,$75,$73,$65,$20,$74,$68,$65,$0D,$5E,$57,$61,$72
        .byte   $70,$20,$70,$61,$6E,$65,$6C,$5E,$3C,$0D,$62,$6C,$61,$73,$74,$20
        .byte   $74,$68,$72,$6F,$75,$67,$68,$0D,$74,$68,$65,$20,$63,$6F,$76,$65
        .byte   $72,$5B,$01,$59,$6F,$75,$20,$77,$69,$6C,$6C,$20,$61,$6C,$73,$6F
        .byte   $0D,$6E,$65,$65,$64,$20,$74,$68,$65,$20,$6B,$65,$79,$0D,$66,$6F
        .byte   $72,$20,$74,$68,$65,$20,$70,$61,$6E,$65,$6C,$5B,$00

; ---- bank5.message_9B13 (text) $9B13-$9B6E, 92 bytes
; "There is a round creature in this room. It will ..."
        .byte   $54,$68,$65,$72,$65,$20,$69,$73,$20,$61,$0D,$72,$6F,$75,$6E,$64
        .byte   $20,$63,$72,$65,$61,$74,$75,$72,$65,$0D,$69,$6E,$20,$74,$68,$69
        .byte   $73,$20,$72,$6F,$6F,$6D,$5B,$01,$49,$74,$20,$77,$69,$6C,$6C,$20
        .byte   $67,$69,$76,$65,$20,$79,$6F,$75,$0D,$69,$74,$65,$6D,$73,$20,$69
        .byte   $6E,$0D,$65,$78,$63,$68,$61,$6E,$67,$65,$20,$66,$6F,$72,$0D,$50
        .byte   $6F,$77,$65,$72,$20,$43,$68,$69,$70,$73,$5B,$00

; ---- bank5.message_9B6F (text) $9B6F-$9BC7, 89 bytes
; "Do you want me to record your progress? Set your..."
        .byte   $44,$6F,$20,$79,$6F,$75,$20,$77,$61,$6E,$74,$0D,$6D,$65,$20,$74
        .byte   $6F,$20,$72,$65,$63,$6F,$72,$64,$0D,$79,$6F,$75,$72,$0D,$70,$72
        .byte   $6F,$67,$72,$65,$73,$73,$3F,$01,$53,$65,$74,$20,$79,$6F,$75,$72
        .byte   $0D,$77,$65,$61,$70,$6F,$6E,$20,$74,$6F,$0D,$5E,$4E,$4F,$20,$55
        .byte   $53,$45,$5E,$20,$61,$6E,$64,$01,$70,$72,$65,$73,$73,$0D,$62,$75
        .byte   $74,$74,$6F,$6E,$5E,$41,$5E,$5B,$00

; ---- bank5.message_9BC8 (text) $9BC8-$9BD0, 9 bytes
; "Corridor"
        .byte   $43,$6F,$72,$72,$69,$64,$6F,$72,$00

; ---- bank5.message_9BD1 (text) $9BD1-$9C05, 53 bytes
; "I will sell this to you in exchange for Power Ch..."
        .byte   $49,$20,$77,$69,$6C,$6C,$20,$73,$65,$6C,$6C,$0D,$74,$68,$69,$73
        .byte   $20,$74,$6F,$20,$79,$6F,$75,$01,$69,$6E,$20,$65,$78,$63,$68,$61
        .byte   $6E,$67,$65,$0D,$66,$6F,$72,$20,$50,$6F,$77,$65,$72,$0D,$43,$68
        .byte   $69,$70,$73,$5B,$00

; ---- bank5.message_9C06 (text) $9C06-$9C2B, 38 bytes
; "I will sell only one of these to you."
        .byte   $49,$20,$77,$69,$6C,$6C,$20,$73,$65,$6C,$6C,$0D,$6F,$6E,$6C,$79
        .byte   $20,$6F,$6E,$65,$0D,$6F,$66,$20,$74,$68,$65,$73,$65,$0D,$74,$6F
        .byte   $20,$79,$6F,$75,$5B,$00

; ---- bank5.message_9C2C (text) $9C2C-$9C37, 12 bytes
; "Good Luck!"
        .byte   $0D,$47,$6F,$6F,$64,$20,$4C,$75,$63,$6B,$5D,$00

; ---- bank5.message_9C38 (text) $9C38-$9C42, 11 bytes
; "Any luck?"
        .byte   $0D,$41,$6E,$79,$20,$6C,$75,$63,$6B,$3F,$00

; ---- bank5.message_9C43 (text) $9C43-$9C8F, 77 bytes
; "I see you are trying very hard, so I will remove..."
        .byte   $49,$20,$73,$65,$65,$20,$79,$6F,$75,$0D,$61,$72,$65,$20,$74,$72
        .byte   $79,$69,$6E,$67,$0D,$76,$65,$72,$79,$20,$68,$61,$72,$64,$3C,$0D
        .byte   $73,$6F,$20,$49,$20,$77,$69,$6C,$6C,$01,$72,$65,$6D,$6F,$76,$65
        .byte   $20,$74,$68,$65,$0D,$73,$65,$61,$6C,$20,$66,$6F,$72,$0D,$43,$6F
        .byte   $72,$72,$69,$64,$6F,$72,$0D,$4E,$6F,$5B,$34,$5B,$00

; ---- bank5.message_9C90 (text) $9C90-$9CC7, 56 bytes
; "To remove the seal for Corridor No.2, touch ever..."
        .byte   $54,$6F,$20,$72,$65,$6D,$6F,$76,$65,$0D,$74,$68,$65,$20,$73,$65
        .byte   $61,$6C,$20,$66,$6F,$72,$0D,$43,$6F,$72,$72,$69,$64,$6F,$72,$20
        .byte   $4E,$6F,$5B,$32,$3C,$01,$74,$6F,$75,$63,$68,$0D,$65,$76,$65,$72
        .byte   $79,$77,$68,$65,$72,$65,$5B,$00

; ---- bank5.message_9CC8 (text) $9CC8-$9D2B, 100 bytes
; "Wait, wait forever... The seal for No.3 will be ..."
        .byte   $57,$61,$69,$74,$3C,$0D,$77,$61,$69,$74,$20,$66,$6F,$72,$65,$76
        .byte   $65,$72,$5B,$5B,$5B,$01,$54,$68,$65,$20,$73,$65,$61,$6C,$20,$66
        .byte   $6F,$72,$0D,$4E,$6F,$5B,$33,$20,$77,$69,$6C,$6C,$20,$62,$65,$0D
        .byte   $72,$65,$6D,$6F,$76,$65,$64,$5B,$01,$57,$68,$61,$74,$20,$61,$72
        .byte   $65,$20,$79,$6F,$75,$0D,$64,$6F,$69,$6E,$67,$20,$68,$65,$72,$65
        .byte   $3F,$0D,$44,$6F,$20,$6E,$6F,$74,$20,$77,$61,$69,$74,$0D,$68,$65
        .byte   $72,$65,$5D,$00

; ---- bank5.message_9D2C (text) $9D2C-$9DA2, 119 bytes
; "Seal No.4 cannot be removed; I think I goofed up..."
        .byte   $53,$65,$61,$6C,$20,$4E,$6F,$5B,$34,$0D,$63,$61,$6E,$6E,$6F,$74
        .byte   $0D,$62,$65,$20,$72,$65,$6D,$6F,$76,$65,$64,$3B,$01,$49,$20,$74
        .byte   $68,$69,$6E,$6B,$20,$49,$0D,$67,$6F,$6F,$66,$65,$64,$20,$75,$70
        .byte   $20,$77,$68,$65,$6E,$0D,$49,$20,$73,$65,$61,$6C,$65,$64,$20,$69
        .byte   $74,$5B,$01,$41,$73,$6B,$20,$66,$6F,$72,$20,$68,$65,$6C,$70,$0D
        .byte   $66,$72,$6F,$6D,$20,$74,$68,$65,$20,$72,$6F,$75,$6E,$64,$0D,$63
        .byte   $72,$65,$61,$74,$75,$72,$65,$0D,$73,$65,$76,$65,$72,$61,$6C,$20
        .byte   $74,$69,$6D,$65,$73,$5B,$00

; ---- bank5.message_9DA3 (text) $9DA3-$9DE1, 63 bytes
; "Fire into the corridor, then the seal on No.5 wi..."
        .byte   $46,$69,$72,$65,$20,$69,$6E,$74,$6F,$20,$74,$68,$65,$0D,$63,$6F
        .byte   $72,$72,$69,$64,$6F,$72,$3C,$01,$74,$68,$65,$6E,$20,$74,$68,$65
        .byte   $20,$73,$65,$61,$6C,$0D,$6F,$6E,$20,$4E,$6F,$5B,$35,$20,$77,$69
        .byte   $6C,$6C,$20,$62,$65,$0D,$72,$65,$6D,$6F,$76,$65,$64,$5B,$00

; ---- bank5.message_9DE2 (text) $9DE2-$9E25, 68 bytes
; "I set seal 6 very well; you will need a special ..."
        .byte   $49,$20,$73,$65,$74,$20,$73,$65,$61,$6C,$20,$36,$0D,$76,$65,$72
        .byte   $79,$20,$77,$65,$6C,$6C,$3B,$01,$79,$6F,$75,$20,$77,$69,$6C,$6C
        .byte   $20,$6E,$65,$65,$64,$0D,$61,$20,$73,$70,$65,$63,$69,$61,$6C,$20
        .byte   $77,$65,$61,$70,$6F,$6E,$0D,$74,$6F,$20,$62,$72,$65,$61,$6B,$20
        .byte   $69,$74,$5B,$00

; ---- bank5.message_9E26 (text) $9E26-$9E7C, 87 bytes
; "Try to enter the room in the corridor several ti..."
        .byte   $54,$72,$79,$20,$74,$6F,$20,$65,$6E,$74,$65,$72,$0D,$74,$68,$65
        .byte   $20,$72,$6F,$6F,$6D,$20,$69,$6E,$0D,$74,$68,$65,$20,$63,$6F,$72
        .byte   $72,$69,$64,$6F,$72,$0D,$73,$65,$76,$65,$72,$61,$6C,$20,$74,$69
        .byte   $6D,$65,$73,$3B,$01,$6F,$6E,$6C,$79,$20,$74,$68,$65,$6E,$20,$77
        .byte   $69,$6C,$6C,$0D,$73,$65,$61,$6C,$20,$37,$20,$62,$65,$0D,$72,$65
        .byte   $6D,$6F,$76,$65,$64,$5B,$00

; ---- bank5.message_9E7D (text) $9E7D-$9EB4, 56 bytes
; "To remove seal 8, set your weapon to "NO USE" an..."
        .byte   $54,$6F,$20,$72,$65,$6D,$6F,$76,$65,$20,$73,$65,$61,$6C,$20,$38
        .byte   $3C,$0D,$73,$65,$74,$20,$79,$6F,$75,$72,$20,$77,$65,$61,$70,$6F
        .byte   $6E,$0D,$74,$6F,$20,$5E,$4E,$4F,$20,$55,$53,$45,$5E,$20,$61,$6E
        .byte   $64,$0D,$66,$69,$72,$65,$5B,$00

; ---- bank5.message_9EB5 (text) $9EB5-$9EE3, 47 bytes
; "Seal 9 can be removed by standing on the gate."
        .byte   $53,$65,$61,$6C,$20,$39,$20,$63,$61,$6E,$20,$62,$65,$0D,$72,$65
        .byte   $6D,$6F,$76,$65,$64,$20,$62,$79,$0D,$73,$74,$61,$6E,$64,$69,$6E
        .byte   $67,$20,$6F,$6E,$0D,$74,$68,$65,$20,$67,$61,$74,$65,$5B,$00

; ---- bank5.message_9EE4 (text) $9EE4-$9F0F, 44 bytes
; "Keep firing, the last seal will be removed."
        .byte   $4B,$65,$65,$70,$20,$66,$69,$72,$69,$6E,$67,$3C,$20,$74,$68,$65
        .byte   $0D,$6C,$61,$73,$74,$20,$73,$65,$61,$6C,$20,$77,$69,$6C,$6C,$0D
        .byte   $62,$65,$20,$72,$65,$6D,$6F,$76,$65,$64,$5B,$00

; ---- bank5.code_9F10 (code) $9F10-$9F31, 34 bytes
L5_9F10:
        asl     A
        tay
L5_9F12:
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
L5_9F22:
        lda     $0500,X
        bpl     L5_9F2A
        jmp     L5_A0AE
L5_9F2A:
        jsr     L7_C0AE
        lda     $51
        jsr     L5_9F10

; ---- bank5.tbl_9F32 (pointer_table) $9F32-$9F43, 18 bytes
; Inline jump table A (9 entries)
        .byte   $47,$C0,$B5,$9F,$E8,$9F,$C3,$9F,$87,$9F,$74,$9F,$75,$A0,$CE,$9F
        .byte   $43,$9F

; ---- bank5.code_9F44 (code) $9F44-$9F97, 84 bytes
L5_9F44:
        jsr     L5_9F88
        lda     #$B5
        sta     $0500,X
        sta     $0501,X
        lda     #$00
        sta     $0638,X
        sta     $0788,X
        sta     $0620,X
        sta     $0669,X
        sta     $0681,X
        lda     #$6A
        sta     $0578,X
        lda     #$01
        sta     $0650,X
        sta     $0621,X
        lda     #$3C
        sta     $07A1,X
        jmp     L5_A0F7
L5_9F75:
        jsr     L5_9F88
        lda     #$80
        sta     $0535
        lda     #$70
        sta     $051D
        lda     #$31
        sta     $0505
        rts
L5_9F88:
        lda     #$00
        sta     $0788,X
        lda     #$06
        sta     $0620,X
L5_9F92:
        jsr     L7_C045
        jsr     L7_C006

; ---- bank5.inline_9F98 (data) $9F98-$9F9A, 3 bytes
; Far-call argument at $9F98
        .byte   $02,$08,$80

; ---- bank5.code_9F9B (code) $9F9B-$A04D, 179 bytes
        lda     $0788,X
        cmp     #$83
        bne     L5_9F92
        jsr     L7_C048
        lda     #$20
        sta     $19
        lda     #$91
        sta     $18
        ldy     #$02
        lda     ($E4),Y
        and     #$7F
        jmp     L7_C051
L5_9FB6:
        lda     $52
        sta     $7C
        lda     $53
        sta     $7D
        inx
        lda     #$04
        jmp     L5_9FC6
L5_9FC4:
        lda     $5E
L5_9FC6:
        sta     $0788,X
        lda     #$34
        sta     $0500,X
        rts
L5_9FCF:
        jsr     L5_A2E7
        beq     L5_9FD8
        lda     #$0A
        bne     L5_9FC6
L5_9FD8:
        lda     $04B1
        ora     #$08
        sta     $04B1
        lda     #$3F
        jsr     L7_C030
        lda     #$0B
        bne     L5_9FC6
L5_9FE9:
        lda     #$65
        ldy     #$06
        jsr     L5_A33F
        lda     #$5C
        sta     $069E
        lda     #$67
        ldy     #$07
        jsr     L5_A33F
        lda     #$D8
        sta     $069F
        lda     #$69
        ldy     #$08
        jsr     L5_A33F
        lda     #$DC
        sta     $06A0
        lda     #$33
        sta     $0506
        sta     $0507
        sta     $0508
        lda     $55
        asl     A
        asl     A
        adc     $55
        tay
        lda     $A04E,Y
        sta     $10
        lda     $A04F,Y
        sta     $11
        ldx     #$06
L5_A02B:
        lda     $A050,Y
        sta     $0680,X
        lda     $10
        sta     $0758,X
        lda     $11
        sta     $0770,X
        iny
        inx
        cpx     #$09
        bne     L5_A02B
        jsr     L5_A2E7
        bne     L5_A049
        jmp     L5_9FD8
L5_A049:
        lda     #$08
        jmp     L5_9FC6

; ---- UNCLAIMED (gap) $A04E-$A075, 40 bytes
        .byte   $96,$00,$10,$14,$00,$E8,$03,$10,$14,$02,$90,$01,$0D,$0C,$03,$58
        .byte   $02,$11,$0C,$04,$D0,$07,$06,$0C,$05,$32,$00,$02,$64,$00,$06,$96
        .byte   $00,$01,$F4,$01,$07,$2C,$01,$08

; ---- bank5.code_A076 (code) $A076-$A1C3, 334 bytes
L5_A076:
        lda     #$67
        ldy     #$06
        jsr     L5_A33F
        lda     #$33
        sta     $0506
        lda     #$5C
        sta     $069E
        lda     $55
        asl     A
        adc     $55
        tay
        lda     $A067,Y
        sta     $075E
        lda     $A068,Y
        sta     $0776
        lda     $A069,Y
        sta     $0686
        ldx     #$09
        jsr     L5_A2E7
        bne     L5_A0A9
        jmp     L5_9FD8
L5_A0A9:
        lda     #$07
        jmp     L5_9FC6
L5_A0AE:
        lda     $51
        cmp     #$08
        beq     L5_A0F7
        cmp     #$06
        beq     L5_A0DF
        cmp     #$01
        bne     L5_A0BF
        jmp     L5_A2B9
L5_A0BF:
        lda     $0506
        and     $0507
        and     $0508
        bne     L5_A0F6
        lda     $F7
        ora     $F8
        and     #$10
        bne     L5_A0E4
        lda     #$01
        sta     $07A6
        sta     $07A7
        sta     $07A8
        bne     L5_A0E4
L5_A0DF:
        lda     $0506
        bne     L5_A0F6
L5_A0E4:
        lda     $5E
        jsr     L7_C066
        jsr     L7_C048
        lda     #$34
        sta     $0509
        lda     #$09
        sta     $0791
L5_A0F6:
        rts
L5_A0F7:
        lda     $0620,X
        beq     L5_A0FF
        jmp     L5_A192
L5_A0FF:
        lda     $0788,X
        beq     L5_A118
        lda     $0638,X
        cmp     #$1C
        bcs     L5_A118
        dec     $0650,X
        bne     L5_A118
        lda     #$08
        sta     $0650,X
        inc     $0638,X
L5_A118:
        lda     #$E2
        sta     $86
        lda     #$D1
        sta     $87
        lda     #$6F
        sta     $84
        lda     #$80
        clc
        adc     $0638,X
        sta     $85
        lda     #$8B
        jsr     L7_C093
        lda     #$22
        sta     $86
        lda     #$80
        sec
        sbc     $0638,X
        sta     $85
        lda     #$8B
        jsr     L7_C093
        lda     $0638,X
        cmp     #$10
        bcc     L5_A19A
        ldy     #$00
        jsr     L5_A30E
        jsr     L7_C0C9
        bcc     L5_A19A
        lda     $6E
        bne     L5_A19A
        lda     #$01
        cmp     $07E8
        sta     $07E8
        beq     L5_A19A
        lda     #$00
        sta     $05C0
        sta     $0608
        sta     $05F0
        lda     #$FD
        sta     $05D8
        lda     $0530
        cmp     #$78
        bcs     L5_A17C
        lda     #$30
        bne     L5_A185
L5_A17C:
        cmp     #$88
        bcc     L5_A188
        dec     $0608
        lda     #$D0
L5_A185:
        sta     $05F0
L5_A188:
        lda     #$F8
        sta     $0668
        lda     #$04
        sta     $A4
        rts
L5_A192:
        lda     $07A0,X
        beq     L5_A19B
        dec     $07A0,X
L5_A19A:
        rts
L5_A19B:
        ldy     #$02
        lda     ($E4),Y
        and     #$7F
        sec
        sbc     #$01
        sta     $15
        cmp     #$0A
        bcc     L5_A1B7
L5_A1AA:
        lda     #$01
        sta     $0787,X
        lda     #$3F
        jsr     L7_C030
        jmp     L7_C048
L5_A1B7:
        jsr     L7_C078
        and     $04B1,Y
        bne     L5_A1AA
        lda     $15
        jsr     L5_9F10

; ---- bank5.tbl_A1C4 (pointer_table) $A1C4-$A1D7, 20 bytes
; Inline jump table B (10 entries)
        .byte   $1C,$A2,$5A,$A2,$D7,$A1,$DE,$A1,$55,$A2,$DF,$A1,$16,$A2,$F4,$A1
        .byte   $1C,$A2,$01,$A2

; ---- bank5.code_A1D8 (code) $A1D8-$A28F, 184 bytes
L5_A1D8:
        jsr     L5_A2F8
        cmp     #$14
        bcs     L5_A245
L5_A1DF:
        rts
L5_A1E0:
        lda     $0668,X
        bne     L5_A1ED
        inc     $0668,X
        lda     $4C
        sta     $0680,X
L5_A1ED:
        lda     $0680,X
        cmp     $4C
        bne     L5_A245
        rts
L5_A1F5:
        lda     $3C
        bne     L5_A201
        lda     $F5
        ora     $F6
        and     #$80
        bne     L5_A245
L5_A201:
        rts
L5_A202:
        lda     $F7
        ora     $F8
        and     #$40
        bne     L5_A20F
        sta     $0680,X
        beq     L5_A201
L5_A20F:
        jsr     L5_A2F8
        cmp     #$0A
        bcs     L5_A245
        rts
L5_A217:
        jsr     L5_A2E7
        beq     L5_A245
        rts
L5_A21D:
        ldy     #$00
L5_A21F:
        jsr     L5_A30E
        jsr     L7_C0C9
        bcc     L5_A201
        lda     $15
        cmp     #$08
        beq     L5_A251
        ldy     $6E
        beq     L5_A201
        lda     #$0A
        sta     $0500,Y
        lda     #$20
        jsr     L7_C030
        inc     $0680,X
        lda     $0680,X
        cmp     #$32
        bcc     L5_A201
L5_A245:
        lda     $15
        jsr     L7_C078
        ora     $04B1,Y
        sta     $04B1,Y
        rts
L5_A251:
        lda     $6E
        beq     L5_A245
        rts
L5_A256:
        ldy     #$04
        jmp     L5_A21F
L5_A25B:
        ldy     #$00
L5_A25D:
        tya
        pha
        lda     $A2A9,Y
        and     $0680,X
        bne     L5_A298
        lda     $A2AA,Y
        tay
        jsr     L5_A30E
        jsr     L7_C0C9
        bcc     L5_A298
        lda     $6E
        bne     L5_A298
        pla
        pha
        tay
        lda     $A2A9,Y
        ora     $0680,X
        sta     $0680,X
        lda     $A2AB,Y
        sta     $19
        lda     $A2AC,Y
        sta     $18
        jsr     L7_C006

; ---- bank5.inline_A290 (data) $A290-$A292, 3 bytes
; Far-call argument at $A290
        .byte   $01,$02,$80

; ---- bank5.code_A293 (code) $A293-$A2A8, 22 bytes
        lda     #$23
        jsr     L7_C030
L5_A298:
        pla
        clc
        adc     #$04
        tay
        cpy     #$10
        bne     L5_A25D
        lda     $0680,X
        cmp     #$0F
        beq     L5_A245
        rts

; ---- UNCLAIMED (gap) $A2A9-$A2B8, 16 bytes
        .byte   $01,$08,$50,$40,$02,$0C,$90,$40,$04,$10,$50,$80,$08,$14,$90,$80

; ---- bank5.code_A2B9 (code) $A2B9-$A2D6, 30 bytes
L5_A2B9:
        lda     $3C
        bne     L5_A2C5
        lda     $F5
        ora     $F6
        and     #$80
        bne     L5_A2C6
L5_A2C5:
        rts
L5_A2C6:
        ldx     #$05
        jsr     L7_C048
        inx
        jsr     L7_C048
        lda     #$00
        sta     $0500
        jsr     L7_C006

; ---- bank5.inline_A2D7 (data) $A2D7-$A2D9, 3 bytes
; Far-call argument at $A2D7
        .byte   $03,$08,$80

; ---- bank5.code_A2DA (code) $A2DA-$A326, 77 bytes
        lda     #$03
        sta     $A0
        lda     #$20
        sta     $30
        lda     #$03
        sta     $2F
        rts
L5_A2E7:
        ldy     #$06
L5_A2E9:
        lda     $04F0,Y
        clc
        adc     $04EF,Y
        cmp     #$08
        bne     L5_A2F7
        dey
        bne     L5_A2E9
L5_A2F7:
        rts
L5_A2F8:
        inc     $0668,X
        lda     $0668,X
        cmp     #$3C
        bne     L5_A30A
        lda     #$00
        sta     $0668,X
        inc     $0680,X
L5_A30A:
        lda     $0680,X
        rts
L5_A30E:
        lda     $A327,Y
        sta     $06E0,X
        lda     $A328,Y
        sta     $06F8,X
        lda     $A329,Y
        sta     $0710,X
        lda     $A32A,Y
        sta     $0728,X
        rts

; ---- UNCLAIMED (gap) $A327-$A33E, 24 bytes
        .byte   $74,$8C,$60,$78,$60,$8F,$10,$38,$50,$70,$40,$60,$90,$B0,$40,$60
        .byte   $50,$70,$80,$A0,$90,$B0,$80,$A0

; ---- bank5.code_A33F (code) $A33F-$A376, 56 bytes
L5_A33F:
        sta     $10
        and     #$F0
        sta     $18
        ora     #$08
        sta     $0518,Y
        lsr     A
        lsr     A
        lsr     A
        lsr     A
        sta     $05F0,Y
        lda     $10
        asl     A
        asl     A
        asl     A
        asl     A
        sta     $19
        ora     #$08
        sta     $0530,Y
        tya
        pha
        jsr     L7_C111
        pla
        sty     $10
        tay
        lda     $10
        sta     $0608,Y
        lda     $18
        sta     $05C0,Y
        lda     $19
        sta     $05D8,Y
        rts

; ---- UNCLAIMED (gap) $A377-$A3BA, 68 bytes
        .byte   $00,$0D,$0B,$0B,$0D,$11,$0F,$0C,$0B,$0C,$0C,$03,$0D,$05,$11,$0E
        .byte   $11,$0B,$0F,$00,$0E,$02,$0F,$0F,$11,$04,$0F,$11,$0B,$02,$0D,$0F
        .byte   $0B,$00,$00,$0A,$01,$0D,$0C,$10,$11,$0D,$0A,$03,$04,$00,$05,$07
        .byte   $0F,$0C,$0B,$0D,$11,$10,$10,$10,$08,$09,$00,$01,$02,$03,$04,$00
        .byte   $01,$02,$03,$04

; ---- bank5.code_A3BB (code) $A3BB-$A41A, 96 bytes
L5_A3BB:
        lda     #$FF
        sta     $56
        lda     $5D
        cmp     #$20
        bne     L5_A3DB
        ldy     #$03
        lda     ($E4),Y
        sta     $5E
        jsr     L7_C0E1
        bcs     L5_A3DA
        lda     #$06
        jsr     L5_A425
        lda     #$01
        sta     $073F,Y
L5_A3DA:
        rts
L5_A3DB:
        cmp     #$60
        bne     L5_A3DA
        lda     #$00
        sta     $15
        sta     $14
        ldx     #$00
L5_A3E7:
        ldy     $04F0,X
        lda     $A41B,Y
        clc
        adc     $15
        sta     $15
        lda     $A41C,Y
        clc
        adc     $14
        sta     $14
        ora     $15
        beq     L5_A405
        inx
        cpx     #$0A
        bne     L5_A3E7
        beq     L5_A3DA
L5_A405:
        ldy     #$C0
L5_A407:
        lda     $073F,Y
        cmp     #$04
        beq     L5_A412
        cmp     #$05
        bne     L5_A417
L5_A412:
        lda     #$03
        sta     $073F,Y
L5_A417:
        dey
        bne     L5_A407
        rts

; ---- UNCLAIMED (gap) $A41B-$A424, 10 bytes
        .byte   $00,$FF,$FF,$00,$00,$00,$01,$00,$00,$01

; ---- bank5.code_A425 (code) $A425-$A496, 114 bytes
L5_A425:
        ldy     #$C0
L5_A427:
        cmp     $073F,Y
        beq     L5_A42F
        dey
        bne     L5_A427
L5_A42F:
        rts
L5_A430:
        lda     #$05
        sta     $7E
        sta     $7F
        lda     #$00
        sta     $27
        ldx     #$C0
L5_A43C:
        sta     $073F,X
        dex
        bne     L5_A43C
        ldy     #$0F
L5_A444:
        sta     $0480,Y
        dey
        bpl     L5_A444
        lda     $60
        and     #$F4
        sta     $60
        lda     #$0F
        sta     $19
        lda     #$80
        sta     $18
        lda     #$10
        ldy     #$03
        jsr     L7_C042
        jmp     L7_C045
L5_A462:
        jsr     L5_A430
        lda     $5D
        cmp     #$40
        bne     L5_A46E
        jmp     L5_A663
L5_A46E:
        lda     #$80
        sta     $27
        lda     #$97
        sta     $28
        lda     #$A4
        sta     $29
        lda     $57
        beq     L5_A496
        asl     A
        tay
        lda     $A4C5,Y
        sta     $66
        lda     $A4C6,Y
        sta     $67
        lda     $60
        ora     #$02
        sta     $60
        lda     #$01
        sta     $68
        sta     $69
L5_A496:
        rts

; ---- UNCLAIMED (gap) $A497-$A662, 460 bytes
        .byte   $00,$13,$80,$01,$14,$84,$02,$16,$8A,$03,$1B,$96,$04,$15,$9C,$05
        .byte   $17,$A0,$06,$3E,$A4,$07,$23,$AC,$08,$30,$B2,$09,$24,$BA,$0A,$06
        .byte   $C2,$0B,$19,$C6,$0C,$1D,$CA,$0D,$48,$D2,$0E,$37,$DA,$8F,$12,$E2
        .byte   $25,$A5,$2A,$A5,$2F,$A5,$37,$A5,$3C,$A5,$45,$A5,$4D,$A5,$55,$A5
        .byte   $5D,$A5,$62,$A5,$6A,$A5,$72,$A5,$7A,$A5,$7D,$A5,$85,$A5,$8D,$A5
        .byte   $93,$A5,$96,$A5,$9D,$A5,$A5,$A5,$AA,$A5,$AF,$A5,$B7,$A5,$BF,$A5
        .byte   $C5,$A5,$CC,$A5,$D1,$A5,$D6,$A5,$DC,$A5,$EA,$A5,$EF,$A5,$F4,$A5
        .byte   $FA,$A5,$FF,$A5,$0A,$A6,$0F,$A6,$17,$A6,$1F,$A6,$25,$A6,$28,$A6
        .byte   $2D,$A6,$32,$A6,$40,$A6,$45,$A6,$4D,$A6,$55,$A6,$5C,$A6,$8F,$08
        .byte   $0F,$01,$02,$8E,$06,$28,$01,$02,$8F,$06,$14,$8E,$04,$32,$01,$02
        .byte   $90,$06,$1E,$01,$02,$90,$04,$14,$01,$14,$01,$15,$01,$02,$94,$03
        .byte   $0A,$95,$03,$0A,$01,$02,$D0,$02,$1E,$D1,$02,$1E,$01,$02,$D3,$02
        .byte   $1E,$D4,$02,$1E,$01,$02,$D2,$05,$1E,$01,$02,$91,$02,$1E,$93,$02
        .byte   $1E,$01,$02,$90,$02,$1E,$92,$02,$1E,$01,$02,$D2,$03,$1E,$94,$03
        .byte   $28,$01,$02,$70,$01,$02,$91,$02,$14,$D1,$02,$14,$01,$02,$8E,$03
        .byte   $28,$D3,$02,$28,$01,$02,$D2,$03,$28,$70,$01,$02,$6F,$01,$02,$70
        .byte   $01,$53,$01,$54,$01,$02,$8E,$08,$0A,$F4,$02,$3C,$01,$02,$F1,$08
        .byte   $0F,$01,$02,$F0,$02,$05,$01,$02,$D2,$04,$14,$F1,$03,$14,$01,$02
        .byte   $F1,$04,$0A,$93,$02,$14,$01,$02,$92,$02,$0A,$70,$01,$02,$72,$01
        .byte   $F4,$04,$14,$01,$02,$D1,$06,$0A,$01,$02,$F2,$06,$01,$01,$02,$F2
        .byte   $02,$01,$54,$01,$02,$90,$02,$0A,$91,$02,$0A,$92,$02,$0A,$93,$02
        .byte   $0A,$01,$02,$F3,$02,$1E,$01,$02,$F4,$02,$1E,$01,$02,$D2,$04,$1E
        .byte   $73,$01,$02,$F0,$04,$0A,$01,$02,$94,$03,$14,$95,$03,$14,$D4,$02
        .byte   $14,$01,$02,$9E,$02,$28,$01,$02,$F4,$03,$14,$95,$03,$14,$01,$02
        .byte   $D2,$03,$1E,$F4,$03,$14,$01,$02,$8E,$05,$14,$1E,$01,$02,$65,$01
        .byte   $02,$9C,$3C,$14,$01,$02,$93,$08,$0A,$01,$02,$93,$08,$05,$92,$02
        .byte   $05,$91,$02,$05,$90,$02,$05,$01,$02,$E5,$02,$01,$01,$02,$F3,$05
        .byte   $0A,$94,$03,$14,$01,$02,$9C,$3C,$1E,$8E,$04,$0F,$01,$02,$9C,$3C
        .byte   $1E,$01,$1E,$01,$02,$F4,$04,$1E,$01,$1F,$01,$02

; ---- bank5.code_A663 (code) $A663-$A68C, 42 bytes
L5_A663:
        lda     $5E
        jsr     L7_C0E1
        bcs     L5_A66B
        rts
L5_A66B:
        ldy     $5E
        lda     $A682,Y
        tay
        lda     $A6A3,Y
        sta     $72
        lda     $A6A4,Y
        sta     $28
        lda     $A6A5,Y
        sta     $29
        lda     #$80
        sta     $27
        lda     #$01
        sta     $70
        lda     #$00
        sta     $71
        rts

; ---- UNCLAIMED (gap) $A68D-$A6EA, 94 bytes
        .byte   $00,$12,$09,$03,$0C,$03,$12,$18,$03,$1B,$03,$21,$12,$0F,$12,$0F
        .byte   $1E,$06,$06,$12,$24,$15,$1D,$CA,$A6,$1E,$CA,$A6,$1F,$CA,$A6,$55
        .byte   $CD,$A6,$56,$CD,$A6,$57,$CD,$A6,$58,$D3,$A6,$47,$D9,$A6,$5A,$DF
        .byte   $A6,$5B,$DF,$A6,$5C,$DF,$A6,$5D,$E2,$A6,$5E,$E8,$A6,$80,$12,$80
        .byte   $00,$26,$80,$81,$18,$9C,$00,$1A,$80,$81,$14,$94,$00,$34,$80,$81
        .byte   $35,$A0,$80,$29,$80,$00,$05,$80,$81,$4B,$90,$80,$4B,$80

; ---- bank5.code_A6EB (code) $A6EB-$A7A6, 188 bytes
L5_A6EB:
        lda     ($18),Y
        sta     $10
        tax
        iny
        lda     ($18),Y
        sta     $13
        and     #$7F
        sta     $11
        iny
        lda     $19
        pha
        lda     $18
        pha
        lda     ($18),Y
        bpl     L5_A718
        and     #$7F
        sta     $12
        iny
        lda     ($18),Y
        pha
        iny
        lda     ($18),Y
        sta     $19
        pla
        sta     $18
        ldy     #$00
        beq     L5_A71B
L5_A718:
        sta     $12
        iny
L5_A71B:
        lda     ($18),Y
        beq     L5_A722
        sta     $0740,X
L5_A722:
        bit     $13
        bmi     L5_A727
        iny
L5_A727:
        inx
        dec     $11
        bne     L5_A71B
        lda     $13
        and     #$7F
        sta     $11
        lda     $10
        clc
        adc     #$10
        tax
        sta     $10
        cmp     #$C0
        bcs     L5_A742
        dec     $12
        bne     L5_A71B
L5_A742:
        pla
        sta     $18
        pla
        sta     $19
        rts
L5_A749:
        lda     #$A9
        sta     $17
        lda     #$16
        sta     $16
        lda     $30
        and     #$60
        bne     L5_A75E
        lda     $50
        asl     A
        tax
        tay
        bcc     L5_A792
L5_A75E:
        lda     $51
        asl     A
        tay
        lda     $A7E2,Y
        sta     $16
        lda     $A7E3,Y
        sta     $17
        cpy     #$0A
        beq     L5_A774
        cpy     #$10
        bne     L5_A78A
L5_A774:
        ldy     #$02
        lda     ($E4),Y
        and     #$7F
        cmp     #$15
        beq     L5_A78A
        cmp     #$0B
        bcc     L5_A78A
        lda     #$38
        sta     $16
        lda     #$A9
        sta     $17
L5_A78A:
        ldx     #$16
        ldy     $51
        lda     $A7A7,Y
        tay
L5_A792:
        lda     $A7B0,Y
        sta     $18
        lda     $A7B1,Y
        sta     $19
        lda     $A7CA,X
        sta     $14
        lda     $A7CB,X
        sta     $15
        rts

; ---- bank5.tbl_A7A7 (data) $A7A7-$A7AF, 9 bytes
; Area to structure-set offset
        .byte   $16,$16,$18,$16,$16,$16,$18,$18,$16

; ---- bank5.tbl_A7B0 (pointer_table) $A7B0-$A7F5, 70 bytes
; Structure pointers (35 entries)
        .byte   $F6,$A7,$D3,$AA,$D3,$AA,$6D,$AB,$6D,$AB,$07,$AC,$07,$AC,$01,$AC
        .byte   $01,$AC,$8A,$AA,$8A,$AA,$97,$A8,$A0,$A8,$FB,$A7,$EE,$A9,$EE,$A9
        .byte   $D9,$AA,$D9,$AA,$0D,$AC,$0D,$AC,$73,$AB,$73,$AB,$EE,$A9,$EE,$A9
        .byte   $A6,$A8,$16,$A9,$FE,$A8,$18,$A9,$0C,$A9,$32,$A9,$26,$A9,$18,$A9
        .byte   $18,$A9,$26,$A9,$38,$A9

; ---- bank5.struct_A7F6 (level) $A7F6-$A7FA, 5 bytes
; Structure 1x1 to +$00
        .byte   $05,$00,$01,$01,$70

; ---- bank5.struct_A7FB (level) $A7FB-$A80A, 16 bytes
; Structure 3x4 to +$00
        .byte   $10,$00,$03,$04,$C1,$C1,$CA,$B7,$CB,$C2,$B8,$B9,$C3,$BA,$BB,$C4

; ---- bank5.struct_A80B (level) $A80B-$A81A, 16 bytes
; Structure 3x4 to +$0D
        .byte   $10,$0D,$03,$04,$CC,$C1,$C1,$C9,$CD,$B7,$C8,$B8,$B9,$C5,$BA,$BB

; ---- bank5.struct_A81B (level) $A81B-$A824, 10 bytes
; Structure 3x2 to +$A0
        .byte   $0A,$A0,$03,$02,$D1,$D2,$C6,$C1,$C1,$D3

; ---- bank5.struct_A825 (level) $A825-$A82E, 10 bytes
; Structure 3x2 to +$AD
        .byte   $0A,$AD,$03,$02,$C7,$CE,$D1,$D0,$C1,$C1

; ---- bank5.struct_A82F (level) $A82F-$A856, 40 bytes
; Structure 12x3 to +$02
        .byte   $28,$02,$0C,$03,$A8,$B7,$A9,$B7,$A9,$B7,$A9,$B7,$A9,$B7,$A9,$AA
        .byte   $C2,$B8,$B9,$B8,$B9,$B8,$B9,$B8,$B9,$B8,$B9,$C9,$C3,$BA,$BB,$BA
        .byte   $BB,$BA,$BB,$BA,$BB,$BA,$BB,$C8

; ---- bank5.struct_A857 (level) $A857-$A86E, 24 bytes
; Structure 2x10 to +$10
        .byte   $18,$10,$02,$0A,$CF,$AF,$B3,$B0,$C1,$C0,$B3,$B0,$C1,$C0,$B3,$B0
        .byte   $C1,$C0,$B3,$B0,$C1,$C0,$B1,$B2

; ---- bank5.struct_A86F (level) $A86F-$A886, 24 bytes
; Structure 2x10 to +$1E
        .byte   $18,$1E,$02,$0A,$BD,$CF,$BE,$B3,$BF,$C1,$B5,$B3,$B6,$C1,$B5,$B3
        .byte   $B6,$C1,$B5,$B3,$B6,$C1,$B4,$B1

; ---- bank5.struct_A887 (level) $A887-$A896, 16 bytes
; Structure 12x1 to +$B2
        .byte   $10,$B2,$0C,$01,$AC,$BC,$AD,$BC,$AD,$BC,$AD,$BC,$AD,$BC,$AD,$AE

; ---- bank5.struct_A897 (level) $A897-$A89E, 8 bytes
; Structure 2x2 to +$00
        .byte   $08,$00,$02,$02,$77,$78,$75,$76

; ---- UNCLAIMED (gap) $A89F-$A89F, 1 bytes
        .byte   $00

; ---- bank5.struct_A8A0 (level) $A8A0-$A8A4, 5 bytes
; Structure 1x1 to +$00
        .byte   $05,$00,$01,$01,$6F

; ---- UNCLAIMED (gap) $A8A5-$A9ED, 329 bytes
        .byte   $00,$06,$00,$10,$83,$BE,$A8,$06,$B0,$10,$81,$CE,$A8,$06,$30,$02
        .byte   $88,$EE,$A8,$06,$3E,$02,$88,$EE,$A8,$A6,$A7,$A6,$A7,$A6,$A7,$A6
        .byte   $A7,$A6,$A7,$A6,$A7,$A6,$A7,$A6,$A7,$A5,$A4,$A5,$A4,$A5,$A4,$A5
        .byte   $A4,$A5,$A4,$A5,$A4,$A5,$A4,$A5,$A4,$A7,$A6,$A7,$A6,$A7,$A6,$A7
        .byte   $A6,$A7,$A6,$A7,$A6,$A7,$A6,$A7,$A6,$A4,$A5,$A6,$A7,$A4,$A5,$A6
        .byte   $A7,$A4,$A5,$A6,$A7,$A4,$A5,$A6,$A7,$44,$A9,$48,$A9,$4C,$A9,$55
        .byte   $A9,$5E,$A9,$69,$A9,$00,$00,$44,$A9,$48,$A9,$4C,$A9,$55,$A9,$5E
        .byte   $A9,$00,$00,$44,$A9,$70,$A9,$74,$A9,$81,$A9,$8E,$A9,$92,$A9,$00
        .byte   $00,$99,$A9,$A8,$A9,$B7,$A9,$BC,$A9,$C1,$A9,$00,$00,$99,$A9,$A8
        .byte   $A9,$00,$00,$99,$A9,$A8,$A9,$D8,$A9,$DD,$A9,$C1,$A9,$00,$00,$44
        .byte   $88,$05,$0D,$44,$88,$01,$72,$43,$01,$06,$71,$74,$74,$74,$74,$63
        .byte   $4C,$01,$06,$73,$7B,$7B,$7B,$7B,$64,$94,$08,$01,$62,$7C,$7C,$7C
        .byte   $7C,$7C,$7C,$62,$54,$02,$02,$A0,$A2,$A1,$A3,$34,$88,$01,$6C,$42
        .byte   $02,$05,$6F,$68,$6A,$0D,$6A,$0D,$6A,$0D,$6F,$66,$4C,$02,$05,$67
        .byte   $6F,$0D,$69,$0D,$69,$0D,$69,$65,$6F,$94,$88,$01,$6B,$44,$02,$02
        .byte   $A0,$A2,$A1,$A3,$15,$06,$02,$F1,$F2,$F2,$F2,$F2,$F3,$FD,$FE,$FE
        .byte   $FE,$FE,$FF,$47,$02,$06,$82,$83,$84,$85,$86,$86,$87,$87,$82,$83
        .byte   $84,$85,$45,$02,$86,$CC,$A9,$49,$02,$86,$CC,$A9,$66,$04,$02,$86
        .byte   $0D,$0D,$86,$87,$0D,$0D,$87,$60,$61,$80,$81,$00,$00,$00,$00,$60
        .byte   $61,$80,$81,$45,$02,$86,$E2,$A9,$49,$02,$86,$E2,$A9,$82,$83,$84
        .byte   $85,$00,$00,$00,$00,$82,$83,$84,$85

; ---- bank5.struct_A9EE (level) $A9EE-$A9FD, 16 bytes
; Structure 3x4 to +$00
        .byte   $10,$00,$03,$04,$F0,$F0,$EF,$F8,$F8,$ED,$F2,$F2,$F3,$F5,$F5,$F6

; ---- bank5.struct_A9FE (level) $A9FE-$AA0D, 16 bytes
; Structure 3x4 to +$0D
        .byte   $10,$0D,$03,$04,$EE,$F0,$F0,$EB,$F8,$F8,$F1,$F2,$F2,$F4,$F5,$F5

; ---- bank5.struct_AA0E (level) $AA0E-$AA17, 10 bytes
; Structure 3x2 to +$A0
        .byte   $0A,$A0,$03,$02,$F7,$F7,$EA,$F0,$F0,$EF

; ---- bank5.struct_AA18 (level) $AA18-$AA21, 10 bytes
; Structure 3x2 to +$AD
        .byte   $0A,$AD,$03,$02,$E8,$F7,$F7,$EE,$F0,$F0

; ---- bank5.struct_AA22 (level) $AA22-$AA49, 40 bytes
; Structure 12x3 to +$02
        .byte   $28,$02,$0C,$03,$F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8
        .byte   $00,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$00,$00,$F5,$F5,$F5
        .byte   $F5,$F5,$F5,$F5,$F5,$F5,$F5,$00

; ---- bank5.struct_AA4A (level) $AA4A-$AA61, 24 bytes
; Structure 2x10 to +$10
        .byte   $18,$10,$02,$0A,$F0,$F0,$F0,$EF,$F0,$EF,$F0,$EF,$F0,$EF,$F0,$EF
        .byte   $F0,$EF,$F0,$EF,$F0,$EF,$F0,$F0

; ---- bank5.struct_AA62 (level) $AA62-$AA79, 24 bytes
; Structure 2x10 to +$1E
        .byte   $18,$1E,$02,$0A,$F0,$F0,$EE,$F0,$EE,$F0,$EE,$F0,$EE,$F0,$EE,$F0
        .byte   $EE,$F0,$EE,$F0,$EE,$F0,$F0,$F0

; ---- bank5.struct_AA7A (level) $AA7A-$AA89, 16 bytes
; Structure 12x1 to +$B2
        .byte   $10,$B2,$0C,$01,$F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7

; ---- bank5.struct_AA8A (level) $AA8A-$AA8E, 5 bytes
; Structure 1x1 to +$00
        .byte   $05,$00,$01,$01,$4F

; ---- UNCLAIMED (gap) $AA8F-$AAD2, 68 bytes
        .byte   $05,$37,$83,$01,$7F,$05,$A7,$83,$01,$87,$12,$45,$07,$02,$4F,$6D
        .byte   $6C,$4F,$4F,$6C,$4F,$6D,$4F,$89,$89,$6D,$4F,$6C,$28,$64,$09,$04
        .byte   $7D,$6C,$89,$89,$89,$89,$6D,$4F,$7E,$7D,$4F,$6C,$89,$89,$6D,$6C
        .byte   $4F,$7E,$4F,$6C,$6D,$6C,$6D,$89,$6C,$6D,$4F,$4F,$4F,$6C,$4F,$4F
        .byte   $6C,$6D,$4F,$4F

; ---- bank5.struct_AAD3 (level) $AAD3-$AAD7, 5 bytes
; Structure 1x1 to +$00
        .byte   $05,$00,$01,$01,$4F

; ---- UNCLAIMED (gap) $AAD8-$AAD8, 1 bytes
        .byte   $00

; ---- bank5.struct_AAD9 (level) $AAD9-$AAE8, 16 bytes
; Structure 3x4 to +$00
        .byte   $10,$00,$03,$04,$C5,$C4,$C1,$C4,$C5,$C3,$C6,$C7,$C9,$C8,$C9,$00

; ---- bank5.struct_AAE9 (level) $AAE9-$AAF8, 16 bytes
; Structure 3x4 to +$0D
        .byte   $10,$0D,$03,$04,$C0,$C5,$C4,$C2,$C4,$C5,$C8,$C6,$C7,$00,$C8,$C9

; ---- bank5.struct_AAF9 (level) $AAF9-$AAFE, 6 bytes
; Structure 2x1 to +$B0
        .byte   $06,$B0,$02,$01,$C0,$C1

; ---- bank5.struct_AAFF (level) $AAFF-$AB04, 6 bytes
; Structure 2x1 to +$BE
        .byte   $06,$BE,$02,$01,$C0,$C1

; ---- bank5.struct_AB05 (level) $AB05-$AB2C, 40 bytes
; Structure 12x3 to +$02
        .byte   $28,$02,$0C,$03,$C5,$C4,$C5,$C4,$C5,$C4,$C5,$C4,$C5,$C4,$C5,$C4
        .byte   $C7,$C6,$C7,$C6,$C7,$C6,$C7,$C6,$C7,$C6,$C7,$C6,$C9,$C8,$C9,$C8
        .byte   $C9,$C8,$C9,$C8,$C9,$C8,$C9,$C8

; ---- bank5.struct_AB2D (level) $AB2D-$AB44, 24 bytes
; Structure 2x10 to +$20
        .byte   $18,$20,$02,$0A,$C5,$C7,$C4,$C1,$C5,$C3,$C4,$C1,$C5,$C3,$C4,$C1
        .byte   $C5,$C3,$C4,$C1,$C5,$C3,$C4,$C1

; ---- bank5.struct_AB45 (level) $AB45-$AB5C, 24 bytes
; Structure 2x10 to +$2E
        .byte   $18,$2E,$02,$0A,$C6,$C4,$C0,$C5,$C2,$C4,$C0,$C5,$C2,$C4,$C0,$C5
        .byte   $C2,$C4,$C0,$C5,$C2,$C4,$C0,$C5

; ---- bank5.struct_AB5D (level) $AB5D-$AB6C, 16 bytes
; Structure 12x1 to +$B2
        .byte   $10,$B2,$0C,$01,$C0,$C1,$C0,$C1,$C0,$C1,$C0,$C1,$C0,$C1,$C0,$C1

; ---- bank5.struct_AB6D (level) $AB6D-$AB71, 5 bytes
; Structure 1x1 to +$00
        .byte   $05,$00,$01,$01,$40

; ---- UNCLAIMED (gap) $AB72-$AB72, 1 bytes
        .byte   $00

; ---- bank5.struct_AB73 (level) $AB73-$AB82, 16 bytes
; Structure 3x4 to +$00
        .byte   $10,$00,$03,$04,$C1,$C1,$C7,$C1,$C7,$CE,$D5,$CE,$CD,$CE,$CD,$00

; ---- bank5.struct_AB83 (level) $AB83-$AB92, 16 bytes
; Structure 3x4 to +$0D
        .byte   $10,$0D,$03,$04,$C5,$C1,$C1,$CE,$C5,$C1,$CC,$CE,$D4,$00,$CC,$CE

; ---- bank5.struct_AB93 (level) $AB93-$AB9F, 13 bytes
; Structure 3x3 to +$90
        .byte   $0D,$90,$03,$03,$C8,$00,$00,$C1,$C4,$00,$29,$C1,$C4

; ---- bank5.struct_ABA0 (level) $ABA0-$ABAC, 13 bytes
; Structure 3x3 to +$9D
        .byte   $0D,$9D,$03,$03,$00,$00,$C9,$00,$C2,$C1,$C2,$C1,$29

; ---- bank5.struct_ABAD (level) $ABAD-$ABCE, 34 bytes
; Structure 10x3 to +$03
        .byte   $22,$03,$0A,$03,$C2,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$C4,$C5,$D7
        .byte   $D7,$D7,$D7,$D7,$D7,$D7,$D7,$C7,$CE,$CE,$CE,$CE,$CE,$CE,$CE,$CE
        .byte   $CE,$CE

; ---- bank5.struct_ABCF (level) $ABCF-$ABE0, 18 bytes
; Structure 2x7 to +$30
        .byte   $12,$30,$02,$07,$C3,$C8,$D2,$D3,$D2,$D3,$D2,$D3,$D2,$D3,$C1,$CB
        .byte   $00,$CD

; ---- bank5.struct_ABE1 (level) $ABE1-$ABF2, 18 bytes
; Structure 2x7 to +$3E
        .byte   $12,$3E,$02,$07,$C9,$C3,$D0,$D1,$D0,$D1,$D0,$D1,$D0,$D1,$CA,$C1
        .byte   $CC,$00

; ---- bank5.struct_ABF3 (level) $ABF3-$AC00, 14 bytes
; Structure 10x1 to +$B3
        .byte   $0E,$B3,$0A,$01,$C2,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$C4

; ---- bank5.struct_AC01 (level) $AC01-$AC05, 5 bytes
; Structure 1x1 to +$00
        .byte   $05,$00,$01,$01,$86

; ---- UNCLAIMED (gap) $AC06-$AC06, 1 bytes
        .byte   $00

; ---- bank5.struct_AC07 (level) $AC07-$AC0B, 5 bytes
; Structure 1x1 to +$00
        .byte   $05,$00,$01,$01,$56

; ---- UNCLAIMED (gap) $AC0C-$AC0C, 1 bytes
        .byte   $00

; ---- bank5.struct_AC0D (level) $AC0D-$AC1C, 16 bytes
; Structure 3x4 to +$00
        .byte   $10,$00,$03,$04,$CC,$CC,$CB,$C8,$C8,$C9,$C0,$C0,$C1,$C1,$C1,$00

; ---- bank5.struct_AC1D (level) $AC1D-$AC2C, 16 bytes
; Structure 3x4 to +$0D
        .byte   $10,$0D,$03,$04,$CA,$CC,$CC,$C7,$C8,$C8,$C1,$C0,$C0,$00,$C1,$C1

; ---- bank5.struct_AC2D (level) $AC2D-$AC36, 10 bytes
; Structure 3x2 to +$A0
        .byte   $0A,$A0,$03,$02,$C5,$C5,$C6,$CC,$CC,$CB

; ---- bank5.struct_AC37 (level) $AC37-$AC40, 10 bytes
; Structure 3x2 to +$AD
        .byte   $0A,$AD,$03,$02,$C4,$C5,$C5,$CA,$CC,$CC

; ---- bank5.struct_AC41 (level) $AC41-$AC68, 40 bytes
; Structure 12x3 to +$02
        .byte   $28,$02,$0C,$03,$CC,$C8,$C8,$C8,$C8,$C8,$C8,$C8,$C8,$C8,$C8,$CC
        .byte   $00,$C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0,$00,$00,$C1,$C1,$C1
        .byte   $C1,$C1,$C1,$C1,$C1,$C1,$C1,$00

; ---- bank5.struct_AC69 (level) $AC69-$AC80, 24 bytes
; Structure 2x10 to +$10
        .byte   $18,$10,$02,$0A,$CC,$CC,$CC,$CB,$CC,$CB,$CC,$CB,$CC,$CB,$CC,$CB
        .byte   $CC,$CB,$CC,$CB,$CC,$CB,$CC,$CC

; ---- bank5.struct_AC81 (level) $AC81-$AC98, 24 bytes
; Structure 2x10 to +$1E
        .byte   $18,$1E,$02,$0A,$CC,$CC,$CA,$CC,$CA,$CC,$CA,$CC,$CA,$CC,$CA,$CC
        .byte   $CA,$CC,$CA,$CC,$CA,$CC,$CC,$CC

; ---- bank5.struct_AC99 (level) $AC99-$ACA8, 16 bytes
; Structure 12x1 to +$B2
        .byte   $10,$B2,$0C,$01,$CC,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$CC

; ---- bank5.code_ACA9 (code) $ACA9-$AD90, 232 bytes
L5_ACA9:
        sta     $10
        asl     A
        adc     $10
        clc
        adc     #$91
        sta     $1A
        lda     #$AD
        adc     #$00
        adc     #$00
        sta     $1B
        txa
        pha
        ldy     #$00
        lda     ($1A),Y
        cmp     #$FF
        beq     L5_AD0C
        asl     A
        tay
        lda     $AE06,Y
        sta     $16
        lda     $AE07,Y
        sta     $17
        ldy     #$00
        lda     ($16),Y
        tax
L5_ACD6:
        iny
        lda     #$01
        sta     $19
        lda     ($16),Y
        asl     A
        rol     $19
        asl     A
        rol     $19
        asl     A
        rol     $19
        asl     A
        rol     $19
        sta     $18
        iny
        lda     ($16),Y
        iny
        sta     $10
        tya
        pha
        lda     ($16),Y
        bpl     L5_AD02
        and     #$0F
        sta     $11
        lda     $5C
        and     #$0F
        clc
        adc     $11
L5_AD02:
        ldy     $10
        jsr     L7_C042
        pla
        tay
        dex
        bne     L5_ACD6
L5_AD0C:
        ldy     #$01
        lda     ($1A),Y
        cmp     #$FF
        beq     L5_AD54
        jsr     L5_AD1A
        jmp     L5_AD54
L5_AD1A:
        asl     A
        tay
        lda     $AE24,Y
        sta     $16
        lda     $AE25,Y
        sta     $17
        ldy     #$00
        lda     ($16),Y
        sta     $15
L5_AD2C:
        iny
        lda     ($16),Y
        iny
        sta     $10
        and     #$07
        tax
        lda     $10
        lsr     A
        lsr     A
        lsr     A
        lsr     A
        sta     $0478,X
        lda     ($16),Y
        iny
        sta     $0470,X
        lda     ($16),Y
        sta     $0460,X
        iny
        lda     ($16),Y
        sta     $0468,X
        dec     $15
        bne     L5_AD2C
        rts
L5_AD54:
        ldy     #$02
        lda     ($1A),Y
        cmp     #$FF
        beq     L5_AD8E
        asl     A
        tay
        lda     $AE50,Y
        sta     $16
        lda     $AE51,Y
        sta     $17
        ldy     #$00
        lda     ($16),Y
        pha
        iny
        lda     ($16),Y
        sta     $18
        iny
        lda     ($16),Y
        sta     $19
        jsr     L7_C05D
        pla
        ldy     #$03
        and     #$02
        beq     L5_AD8E
        ldx     #$00
L5_AD83:
        lda     ($16),Y
        sta     $0199,X
        iny
        inx
        cpx     #$08
        bne     L5_AD83
L5_AD8E:
        pla
        tax
        rts

; ---- UNCLAIMED (gap) $AD91-$B2E3, 1363 bytes
        .byte   $00,$00,$00,$01,$FF,$FF,$04,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$05
        .byte   $05,$00,$09,$06,$01,$09,$06,$01,$0C,$08,$02,$0C,$08,$02,$0E,$15
        .byte   $03,$0E,$15,$03,$06,$07,$04,$06,$07,$04,$09,$06,$05,$09,$06,$05
        .byte   $02,$02,$07,$02,$02,$06,$02,$02,$00,$02,$02,$00,$03,$02,$00,$03
        .byte   $02,$00,$02,$02,$06,$02,$02,$00,$03,$02,$00,$02,$02,$00,$02,$02
        .byte   $00,$02,$02,$00,$02,$02,$00,$02,$02,$00,$02,$02,$00,$02,$02,$00
        .byte   $08,$10,$FF,$0D,$14,$FF,$0C,$13,$FF,$0E,$15,$FF,$0B,$12,$FF,$0A
        .byte   $11,$FF,$09,$11,$FF,$AB,$AE,$B2,$AE,$B6,$AE,$C3,$AE,$D0,$AE,$D4
        .byte   $AE,$D8,$AE,$00,$00,$DF,$AE,$E3,$AE,$ED,$AE,$F7,$AE,$FB,$AE,$FF
        .byte   $AE,$09,$AF,$1C,$AF,$00,$00,$76,$AF,$00,$00,$00,$00,$76,$AF,$76
        .byte   $B3,$4F,$B6,$83,$BA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$57,$B1,$76,$B3,$60,$B6,$83,$BA,$87,$BC,$9F,$BD,$60
        .byte   $AE,$6B,$AE,$6E,$AE,$71,$AE,$74,$AE,$77,$AE,$7A,$AE,$7D,$AE,$03
        .byte   $80,$AE,$00,$55,$AA,$FF,$00,$55,$AA,$FF,$01,$88,$AE,$01,$8D,$AE
        .byte   $01,$92,$AE,$01,$97,$AE,$01,$9C,$AE,$01,$A1,$AE,$01,$A6,$AE,$05
        .byte   $06,$04,$07,$00,$01,$02,$03,$05,$06,$1A,$1B,$FE,$05,$06,$16,$18
        .byte   $FE,$05,$06,$1D,$1E,$FE,$05,$06,$15,$15,$FE,$05,$06,$11,$12,$FE
        .byte   $05,$06,$07,$1D,$FE,$05,$06,$10,$1B,$FE,$02,$10,$02,$01,$FE,$01
        .byte   $02,$01,$00,$01,$03,$04,$80,$01,$00,$F0,$01,$01,$E0,$01,$06,$D0
        .byte   $01,$08,$04,$80,$01,$00,$F0,$01,$01,$E0,$01,$09,$D0,$01,$07,$01
        .byte   $60,$02,$0F,$01,$80,$01,$00,$02,$60,$01,$0D,$FE,$01,$02,$01,$90
        .byte   $01,$05,$03,$60,$02,$09,$80,$01,$0A,$C0,$01,$0B,$03,$60,$02,$09
        .byte   $80,$01,$0A,$D0,$01,$0C,$01,$60,$01,$0D,$01,$60,$01,$0E,$03,$80
        .byte   $01,$0A,$60,$01,$0F,$B0,$01,$10,$06,$80,$01,$0A,$82,$01,$11,$86
        .byte   $01,$12,$8C,$01,$13,$9D,$01,$14,$B0,$01,$15,$01,$00,$00,$1C,$AF
        .byte   $14,$16,$15,$17,$01,$14,$16,$15,$17,$01,$14,$16,$15,$17,$01,$18
        .byte   $1A,$19,$1B,$00,$28,$2A,$29,$2B,$00,$18,$1A,$19,$1B,$10,$18,$1A
        .byte   $19,$1B,$00,$14,$16,$15,$17,$00,$10,$12,$11,$13,$00,$1C,$1E,$1D
        .byte   $1F,$01,$00,$02,$01,$03,$00,$10,$12,$11,$13,$01,$FF,$FF,$FF,$FF
        .byte   $00,$31,$36,$37,$3C,$75,$76,$7C,$7D,$38,$39,$3A,$3A,$3B,$3C,$3D
        .byte   $3F,$7F,$7E,$7E,$7A,$05,$03,$00,$8B,$AF,$04,$00,$2B,$B0,$05,$00
        .byte   $53,$B0,$06,$00,$F3,$B0,$07,$00,$8B,$AF,$E0,$E1,$E4,$E5,$00,$E2
        .byte   $E3,$E6,$E7,$00,$B6,$B6,$A8,$A8,$00,$A5,$B5,$A7,$A8,$00,$B7,$A6
        .byte   $A8,$A9,$00,$FF,$D0,$D0,$D5,$02,$D1,$FF,$D4,$D1,$02,$D2,$D7,$FF
        .byte   $D2,$02,$D6,$D3,$D3,$FF,$02,$D2,$D7,$D0,$D5,$02,$D5,$D3,$D4,$D1
        .byte   $02,$D1,$D0,$D4,$D5,$02,$D6,$D7,$D3,$D2,$02,$D2,$D3,$D0,$D1,$02
        .byte   $D1,$D0,$D3,$D2,$02,$D6,$D7,$D4,$D5,$02,$8A,$8A,$8A,$8A,$02,$A2
        .byte   $A3,$A5,$FF,$00,$A3,$A3,$FF,$FF,$00,$A3,$A4,$FF,$A6,$00,$A5,$FF
        .byte   $A5,$FF,$00,$F6,$F8,$F0,$F9,$02,$F8,$F5,$F9,$FA,$02,$F0,$F9,$F5
        .byte   $F7,$02,$F9,$FA,$F7,$F6,$02,$F6,$F5,$F5,$F6,$02,$F9,$F9,$F9,$F9
        .byte   $02,$FF,$A6,$FF,$A6,$00,$B5,$B7,$A8,$A8,$00,$A5,$FF,$A7,$A8,$00
        .byte   $FF,$FF,$A8,$A8,$00,$FF,$A6,$A8,$A9,$00,$E8,$E9,$EC,$ED,$00,$EA
        .byte   $EB,$EE,$EF,$00,$82,$80,$91,$8D,$03,$80,$83,$8D,$90,$03,$91,$8D
        .byte   $92,$81,$03,$8D,$90,$81,$93,$03,$82,$83,$91,$90,$03,$91,$90,$92
        .byte   $93,$03,$E0,$E1,$E2,$E3,$00,$E4,$E5,$E6,$E7,$00,$E9,$E8,$EB,$EA
        .byte   $00,$ED,$EC,$EF,$EE,$00,$C0,$C1,$C4,$C5,$03,$C2,$C3,$C6,$C7,$03
        .byte   $C8,$C9,$CC,$CD,$03,$CA,$CB,$CE,$CF,$03,$9A,$9A,$95,$AC,$03,$9B
        .byte   $9A,$8D,$8D,$03,$9A,$9B,$AB,$99,$03,$9B,$9A,$8F,$8F,$03,$85,$9F
        .byte   $9A,$9A,$03,$9C,$9C,$9B,$9A,$03,$A1,$84,$9A,$9B,$03,$9B,$95,$8F
        .byte   $AD,$03,$8F,$9D,$9B,$9D,$03,$8F,$8F,$8F,$8F,$03,$8F,$A0,$8F,$85
        .byte   $03,$8F,$8F,$9B,$9B,$03,$B0,$8F,$84,$8F,$03,$FF,$8F,$FF,$9B,$03
        .byte   $FF,$9B,$FF,$9B,$03,$9B,$9B,$8D,$8D,$03,$82,$83,$92,$93,$03,$82
        .byte   $80,$92,$81,$03,$83,$82,$93,$92,$03,$80,$83,$81,$93,$03,$9C,$9C
        .byte   $9B,$9B,$03,$99,$9B,$AA,$8F,$03,$BA,$8F,$BA,$9B,$03,$BA,$9B,$BA
        .byte   $9B,$03,$9B,$9D,$9B,$9D,$03,$9B,$9B,$9B,$9B,$03,$8C,$98,$98,$8B
        .byte   $03,$8B,$88,$88,$8B,$03,$8B,$86,$86,$8A,$02,$87,$FF,$8A,$87,$02
        .byte   $96,$8A,$8C,$96,$02,$8A,$97,$97,$FF,$02,$B0,$FF,$FF,$B0,$03,$89
        .byte   $9E,$FF,$89,$03,$9A,$9D,$95,$B1,$03,$9B,$95,$8D,$B3,$03,$FF,$9B
        .byte   $B9,$99,$03,$99,$9B,$B2,$8D,$03,$B4,$8D,$84,$8F,$03,$9B,$9B,$8F
        .byte   $8F,$03,$B0,$84,$FF,$9B,$03,$8D,$8D,$8F,$8F,$03,$8D,$B8,$8F,$85
        .byte   $03,$85,$AE,$9A,$9D,$03,$04,$01,$00,$68,$B1,$02,$00,$C7,$B1,$03
        .byte   $00,$67,$B2,$04,$00,$8A,$B2,$CA,$CB,$DA,$DB,$32,$CC,$CD,$DC,$DD
        .byte   $02,$EA,$EB,$FA,$FB,$02,$EC,$ED,$FC,$FD,$02,$CA,$C0,$C2,$C3,$02
        .byte   $C1,$CD,$C4,$C5,$02,$C6,$C7,$FA,$CE,$02,$C8,$C9,$CF,$FD,$02,$CA
        .byte   $DE,$B8,$B9,$02,$DF,$CD,$BA,$BB,$02,$BC,$BD,$FA,$EE,$02,$BE,$BF
        .byte   $EF,$FD,$02,$CA,$B6,$B2,$FF,$01,$B7,$CD,$FF,$B3,$01,$B0,$FF,$FA
        .byte   $B4,$01,$FF,$B1,$B5,$FD,$01,$9A,$9B,$96,$97,$02,$9E,$9F,$9C,$9D
        .byte   $02,$98,$99,$9C,$9D,$02,$D7,$D8,$E7,$E8,$02,$D8,$D9,$E8,$E9,$02
        .byte   $E7,$E8,$F7,$F8,$02,$E8,$E9,$F8,$F9,$02,$F0,$F0,$E8,$E8,$02,$E8
        .byte   $E8,$F8,$F8,$02,$E7,$E8,$E7,$E8,$02,$E8,$E9,$E8,$E9,$02,$D8,$D8
        .byte   $E8,$E8,$02,$E8,$E8,$F8,$F8,$02,$D7,$D9,$F7,$F9,$22,$D7,$D9,$E7
        .byte   $E9,$02,$E7,$E9,$F7,$F9,$02,$D7,$D8,$F7,$F8,$02,$A0,$A1,$A4,$A5
        .byte   $03,$A2,$A3,$A6,$A7,$03,$D8,$D9,$F8,$F9,$02,$00,$00,$00,$00,$00
        .byte   $D6,$A2,$F5,$E6,$01,$D2,$F6,$F3,$E1,$01,$F5,$F6,$F5,$F6,$01,$D4
        .byte   $F6,$A2,$E4,$01,$F1,$F6,$F5,$F6,$01,$F5,$F2,$F5,$F6,$01,$F5,$D3
        .byte   $E3,$A2,$01,$F5,$D1,$E2,$F6,$01,$A2,$D5,$E5,$F6,$01,$D8,$D8,$F8
        .byte   $F8,$02,$E7,$E9,$E7,$E9,$02,$FF,$FF,$FF,$FF,$00,$A8,$A9,$AC,$AD
        .byte   $03,$AA,$AB,$AE,$AF,$03,$91,$90,$FF,$91,$00,$94,$95,$92,$93,$00
        .byte   $91,$FF,$90,$FF,$00,$FF,$D5,$E5,$F6,$01,$D6,$FF,$F5,$E6,$01,$F5
        .byte   $D3,$E3,$FF,$01,$D4,$F6,$FF,$E4,$01,$D7,$D8,$E7,$E8,$01,$D8,$D9
        .byte   $E8,$E9,$01,$E7,$E8,$F7,$F8,$01,$E8,$E9,$F8,$F9,$01,$F0,$F0,$E8
        .byte   $E8,$01,$E8,$E8,$F8,$F8,$01,$E7,$E8,$E7,$E8,$01,$E8,$E9,$E8,$E9
        .byte   $01,$D8,$D8,$E8,$E8,$01,$E8,$E8,$F8,$F8,$01,$D7,$D9,$F7,$F9,$01
        .byte   $D7,$D9,$E7,$E9,$01,$E7,$E9,$F7,$F9,$01,$D7,$D8,$F7,$F8,$01,$D8
        .byte   $D9,$F8,$F9,$01,$E8,$E8,$E8,$E8,$01,$E7,$E9,$E7,$E9,$01,$D8,$D8
        .byte   $F8,$F8,$01

; ---- bank5.code_B2E4 (code) $B2E4-$B309, 38 bytes
L5_B2E4:
        stx     $10
        sta     $11
        asl     A
        adc     $11
        tax
        sty     $12
        tya
        asl     A
        adc     $12
        tay
        lda     $B30A,X
        sta     $0181,Y
        lda     $B30B,X
        sta     $0182,Y
        lda     $B30C,X
        sta     $0183,Y
        ldx     $10
        ldy     $12
        rts

; ---- UNCLAIMED (gap) $B30A-$BFFE, 3317 bytes
        .byte   $30,$16,$0F,$30,$27,$06,$30,$21,$0F,$30,$29,$0F,$30,$1A,$0A,$30
        .byte   $21,$16,$38,$18,$1B,$30,$10,$00,$30,$26,$16,$30,$12,$01,$30,$16
        .byte   $11,$31,$21,$11,$11,$01,$16,$22,$12,$16,$1C,$0C,$16,$30,$2A,$27
        .byte   $27,$17,$07,$37,$17,$0F,$28,$18,$08,$30,$21,$12,$22,$12,$05,$25
        .byte   $06,$05,$30,$16,$0A,$30,$16,$06,$2A,$1A,$0A,$2A,$1C,$1A,$30,$1C
        .byte   $16,$2C,$1C,$0C,$31,$12,$02,$35,$15,$05,$30,$10,$00,$30,$24,$16
        .byte   $30,$16,$06,$30,$27,$17,$30,$2C,$1C,$33,$26,$06,$07,$11,$00,$93
        .byte   $B3,$12,$00,$C5,$B3,$13,$00,$65,$B4,$14,$00,$05,$B5,$15,$00,$A5
        .byte   $B5,$16,$00,$82,$B5,$07,$00,$D2,$B5,$80,$80,$80,$C0,$73,$80,$80
        .byte   $C1,$C2,$03,$80,$80,$C3,$80,$03,$C4,$C5,$CA,$CB,$03,$C6,$C7,$CC
        .byte   $CD,$03,$C8,$C9,$CE,$CF,$03,$DA,$DB,$E0,$E1,$03,$DC,$DD,$E2,$E3
        .byte   $03,$DE,$DF,$E4,$E5,$03,$E6,$E7,$EC,$ED,$03,$E8,$E9,$EE,$EF,$03
        .byte   $EA,$EB,$F0,$F1,$03,$AF,$AF,$AF,$AF,$03,$80,$AF,$AF,$88,$03,$AF
        .byte   $80,$88,$AF,$03,$AF,$88,$80,$AF,$03,$88,$AF,$AF,$80,$03,$84,$85
        .byte   $87,$88,$03,$85,$86,$88,$89,$03,$87,$88,$8A,$8B,$03,$88,$89,$8B
        .byte   $8C,$03,$8D,$8E,$8D,$8E,$03,$8E,$8F,$8E,$8F,$03,$90,$91,$80,$80
        .byte   $03,$91,$92,$80,$80,$03,$80,$80,$80,$80,$03,$80,$80,$80,$9A,$03
        .byte   $9B,$9B,$9B,$9B,$03,$80,$9A,$9A,$9B,$03,$80,$84,$84,$95,$03,$85
        .byte   $85,$88,$88,$03,$86,$81,$97,$86,$03,$82,$9B,$97,$82,$03,$8A,$97
        .byte   $8D,$8A,$03,$88,$88,$8B,$8B,$03,$95,$8C,$8C,$8F,$03,$8D,$8D,$8D
        .byte   $8D,$03,$8E,$8E,$8E,$8E,$03,$8F,$8F,$8F,$8F,$03,$90,$8D,$80,$90
        .byte   $03,$8E,$8E,$91,$91,$03,$8F,$83,$83,$9B,$03,$9A,$9B,$9B,$9B,$03
        .byte   $9B,$80,$9C,$80,$03,$8F,$92,$92,$80,$03,$87,$88,$87,$88,$03,$88
        .byte   $88,$88,$88,$03,$88,$89,$88,$89,$03,$88,$97,$97,$88,$03,$95,$97
        .byte   $97,$95,$03,$95,$88,$88,$95,$03,$87,$95,$87,$97,$03,$97,$89,$95
        .byte   $89,$03,$99,$80,$9B,$99,$03,$96,$80,$81,$96,$03,$81,$98,$98,$80
        .byte   $03,$9B,$9C,$9C,$80,$03,$80,$A0,$A0,$A1,$03,$9E,$9E,$A2,$A2,$03
        .byte   $A4,$80,$A3,$A4,$03,$A5,$A6,$A5,$FF,$03,$A7,$A7,$FF,$FF,$03,$A8
        .byte   $A9,$FF,$A9,$03,$AA,$AB,$80,$AA,$03,$FF,$FF,$AE,$AE,$03,$AC,$AD
        .byte   $AD,$80,$03,$A0,$A1,$A1,$A6,$03,$A2,$A2,$A7,$A7,$03,$A3,$A4,$A8
        .byte   $A3,$03,$80,$80,$A4,$80,$03,$80,$80,$80,$A0,$03,$80,$A5,$80,$A5
        .byte   $03,$A9,$80,$A9,$80,$03,$80,$80,$9E,$9E,$03,$A6,$FF,$FF,$FF,$03
        .byte   $AE,$AE,$9E,$9E,$03,$FF,$A8,$FF,$FF,$03,$80,$AA,$80,$80,$03,$AB
        .byte   $FF,$AA,$AB,$03,$FF,$AC,$AC,$AD,$03,$AD,$80,$80,$80,$03,$AE,$AE
        .byte   $80,$80,$03,$96,$80,$98,$96,$03,$96,$98,$98,$96,$03,$9D,$A1,$A1
        .byte   $A2,$03,$A2,$A2,$A2,$A2,$03,$A3,$9F,$A2,$A3,$03,$A8,$A2,$FF,$A8
        .byte   $03,$A2,$A6,$A6,$FF,$03,$9D,$9F,$AA,$AD,$13,$A9,$A5,$A9,$A5,$03
        .byte   $81,$80,$80,$81,$03,$80,$81,$81,$80,$03,$FF,$FF,$FF,$FF,$03,$87
        .byte   $89,$87,$89,$03,$85,$85,$8B,$8B,$03,$85,$85,$95,$97,$03,$97,$95
        .byte   $8B,$8B,$03,$B0,$B3,$BC,$BF,$23,$80,$D0,$D3,$D4,$33,$D1,$D2,$D5
        .byte   $D6,$03,$D7,$D8,$DB,$DC,$03,$D9,$DA,$DD,$DE,$03,$E2,$E1,$E6,$E5
        .byte   $33,$E0,$80,$E4,$E3,$03,$EA,$E9,$EE,$ED,$03,$E8,$E7,$EC,$EB,$03
        .byte   $F0,$F1,$F2,$F3,$03,$F5,$F6,$80,$80,$03,$80,$80,$F0,$F1,$03,$F2
        .byte   $F3,$F5,$F6,$03,$F7,$F8,$F3,$F4,$03,$F9,$FA,$9B,$9B,$03,$9B,$9B
        .byte   $F7,$F8,$03,$F3,$F4,$F9,$FA,$03,$84,$85,$87,$88,$03,$85,$86,$88
        .byte   $89,$03,$87,$88,$8A,$8B,$03,$88,$89,$8B,$8C,$03,$8D,$8E,$8D,$8E
        .byte   $03,$8E,$8F,$8E,$8F,$03,$90,$91,$80,$80,$03,$91,$92,$80,$80,$03
        .byte   $80,$84,$84,$95,$03,$85,$85,$95,$97,$03,$86,$81,$97,$86,$03,$8A
        .byte   $97,$8D,$8A,$03,$97,$95,$8B,$8B,$03,$95,$8C,$8C,$8F,$03,$87,$95
        .byte   $87,$97,$03,$97,$89,$95,$89,$03,$95,$97,$97,$95,$03,$8D,$8D,$8D
        .byte   $8D,$03,$8E,$8E,$8E,$8E,$03,$8F,$8F,$8F,$8F,$03,$90,$8D,$80,$90
        .byte   $03,$8E,$8E,$91,$91,$03,$8F,$92,$92,$80,$03,$85,$85,$95,$97,$03
        .byte   $97,$95,$8B,$8B,$03,$04,$01,$00,$7D,$B6,$03,$00,$40,$B7,$04,$00
        .byte   $E0,$B7,$06,$00,$0B,$BA,$07,$21,$00,$7D,$B6,$22,$00,$A0,$B6,$23
        .byte   $00,$40,$B7,$24,$00,$E0,$B7,$25,$00,$67,$B8,$26,$00,$07,$B9,$27
        .byte   $00,$A7,$B9,$D0,$D2,$D1,$D3,$11,$D4,$D6,$D5,$D7,$01,$D8,$DA,$D9
        .byte   $DB,$01,$DC,$DE,$DD,$DF,$01,$CC,$CE,$CD,$CF,$21,$CC,$CE,$CD,$CF
        .byte   $31,$FF,$FF,$FF,$FF,$43,$88,$88,$88,$66,$03,$88,$88,$67,$88,$03
        .byte   $88,$68,$88,$88,$03,$69,$88,$88,$88,$03,$88,$9B,$9B,$6F,$03,$71
        .byte   $88,$6F,$71,$03,$88,$88,$88,$88,$03,$84,$85,$87,$66,$03,$85,$86
        .byte   $67,$89,$03,$87,$68,$8A,$8B,$03,$69,$89,$8B,$8C,$03,$8D,$8E,$8D
        .byte   $8E,$03,$8E,$8F,$8E,$8F,$03,$8D,$8E,$60,$61,$03,$8E,$8F,$61,$62
        .byte   $03,$80,$81,$82,$83,$03,$66,$67,$68,$69,$03,$6E,$84,$84,$88,$03
        .byte   $85,$85,$88,$88,$03,$86,$6E,$88,$86,$03,$8A,$88,$8D,$8A,$03,$88
        .byte   $88,$8B,$8B,$03,$88,$8C,$8C,$8F,$03,$60,$8D,$6E,$60,$03,$8E,$8E
        .byte   $61,$61,$03,$8F,$62,$62,$6E,$03,$8D,$8D,$6F,$8D,$03,$8E,$8E,$8E
        .byte   $8E,$03,$8F,$8F,$8F,$8F,$03,$71,$72,$77,$78,$03,$73,$67,$79,$69
        .byte   $03,$66,$74,$68,$7A,$03,$75,$76,$7B,$7C,$03,$A0,$90,$91,$92,$03
        .byte   $95,$96,$68,$69,$03,$66,$67,$97,$98,$03,$99,$9A,$9B,$9C,$03,$6E
        .byte   $6E,$6E,$6E,$03,$7D,$7D,$7E,$7E,$03,$88,$88,$88,$B0,$03,$88,$88
        .byte   $B1,$B2,$03,$88,$88,$B3,$88,$03,$88,$BA,$88,$B8,$03,$BB,$88,$B9
        .byte   $88,$03,$88,$B4,$88,$88,$03,$B5,$B6,$88,$88,$03,$B7,$88,$88,$88
        .byte   $03,$88,$88,$88,$80,$03,$88,$88,$81,$88,$03,$88,$82,$88,$88,$03
        .byte   $83,$88,$88,$88,$03,$7D,$7D,$BC,$78,$03,$71,$72,$7E,$7E,$03,$7D
        .byte   $7D,$7B,$7C,$03,$75,$76,$7E,$7E,$03,$71,$72,$6F,$6F,$03,$75,$76
        .byte   $8D,$8D,$03,$6F,$70,$70,$6E,$03,$71,$72,$8D,$8D,$03,$6E,$6E,$BC
        .byte   $78,$03,$6E,$6E,$7B,$BD,$03,$87,$88,$87,$88,$03,$88,$89,$88,$89
        .byte   $03,$6E,$6E,$6A,$6B,$03,$6A,$6D,$6D,$6E,$03,$6C,$6B,$6E,$6C,$03
        .byte   $6E,$6E,$6B,$6E,$03,$6E,$6E,$6E,$6A,$03,$6A,$6D,$6D,$6A,$03,$6B
        .byte   $6C,$6C,$6B,$03,$6A,$6B,$6C,$6D,$03,$6C,$6D,$6E,$6E,$03,$6E,$84
        .byte   $84,$B0,$03,$85,$85,$B1,$B2,$03,$86,$6E,$B3,$86,$03,$87,$BA,$87
        .byte   $B8,$03,$BB,$89,$B9,$89,$03,$8A,$B4,$8D,$8A,$03,$B5,$B6,$8B,$8B
        .byte   $03,$B7,$8C,$8C,$8F,$03,$85,$7C,$88,$91,$03,$77,$85,$92,$88,$03
        .byte   $94,$88,$9C,$8B,$03,$88,$93,$8B,$9B,$03,$94,$93,$9C,$9B,$03,$92
        .byte   $93,$94,$93,$03,$94,$91,$94,$93,$03,$94,$93,$94,$99,$03,$94,$93
        .byte   $9A,$93,$03,$88,$91,$88,$93,$03,$92,$88,$94,$88,$03,$88,$93,$88
        .byte   $99,$03,$94,$88,$9A,$88,$03,$88,$93,$88,$93,$03,$94,$88,$94,$88
        .byte   $03,$88,$63,$88,$63,$03,$75,$9D,$7B,$9F,$03,$A3,$A4,$A1,$A2,$03
        .byte   $AC,$AD,$AE,$AF,$03,$A5,$A6,$A7,$A8,$03,$AB,$72,$A9,$78,$03,$75
        .byte   $9D,$FF,$A3,$03,$FF,$FF,$A1,$FF,$03,$A3,$A4,$FF,$A3,$03,$A5,$A6
        .byte   $A6,$FF,$03,$FF,$FF,$FF,$A8,$03,$AB,$72,$A6,$FF,$03,$AC,$FF,$AA
        .byte   $A8,$03,$FF,$AD,$A1,$A2,$03,$AC,$AD,$7B,$9F,$03,$AC,$AD,$A9,$78
        .byte   $03,$A3,$A4,$7B,$9F,$03,$A5,$A6,$A9,$78,$03,$7D,$7D,$7B,$7C,$03
        .byte   $7D,$7D,$77,$78,$03,$75,$9D,$7E,$7E,$03,$AB,$72,$7E,$7E,$03,$FF
        .byte   $FF,$7B,$7C,$03,$FF,$FF,$77,$78,$03,$AC,$AD,$7E,$7E,$03,$71,$72
        .byte   $7B,$7C,$03,$75,$76,$77,$78,$03,$FF,$FF,$FF,$FF,$03,$E2,$E3,$EC
        .byte   $FB,$02,$6E,$6E,$E2,$E3,$02,$EC,$ED,$6E,$6E,$02,$E0,$FD,$EE,$EF
        .byte   $02,$EE,$EF,$6E,$6E,$02,$6E,$6E,$E0,$E1,$02,$6E,$FA,$F3,$F4,$02
        .byte   $F0,$F1,$6E,$FA,$02,$EC,$FB,$6E,$FA,$02,$FC,$EF,$FA,$6E,$02,$EA
        .byte   $EB,$E4,$E5,$02,$6E,$EA,$6E,$E4,$02,$EB,$6E,$E5,$6E,$02,$E8,$E9
        .byte   $E6,$E7,$02,$6E,$E8,$6E,$E6,$02,$E9,$6E,$E7,$6E,$02,$EA,$EB,$FC
        .byte   $E5,$02,$6E,$EA,$F9,$FC,$02,$EB,$6E,$E5,$6E,$02,$E8,$E9,$E6,$FB
        .byte   $02,$6E,$E8,$6E,$E6,$02,$E9,$6E,$FB,$F9,$02,$F1,$F2,$FA,$6E,$02
        .byte   $FA,$6E,$F4,$F5,$02,$E0,$E1,$E4,$E5,$02,$E2,$E3,$E6,$E7,$02,$E8
        .byte   $E9,$EC,$ED,$02,$EA,$EB,$EE,$EF,$02,$E0,$FD,$E4,$E5,$02,$FE,$E3
        .byte   $E6,$E7,$02,$E8,$E9,$EC,$FB,$02,$EA,$EB,$FC,$EF,$02,$FA,$6E,$FE
        .byte   $E3,$02,$6E,$FA,$E0,$FD,$02,$FC,$EF,$FA,$6E,$02,$EC,$FB,$6E,$FA
        .byte   $02,$6E,$F0,$6E,$6E,$02,$F2,$6E,$6E,$6E,$02,$6E,$6E,$6E,$F3,$02
        .byte   $6E,$6E,$F5,$6E,$02,$6E,$6E,$F9,$F9,$02,$F9,$F9,$6E,$6E,$02,$6E
        .byte   $FA,$6E,$FA,$02,$FA,$6E,$FA,$6E,$02,$E0,$E1,$FC,$E5,$02,$E2,$E3
        .byte   $E6,$FB,$02,$FE,$E9,$EC,$ED,$02,$EA,$FD,$EE,$EF,$02,$E2,$E3,$EC
        .byte   $ED,$02,$E0,$E1,$EE,$EF,$02,$E0,$E1,$FC,$EF,$02,$FE,$E3,$EC,$ED
        .byte   $02,$66,$67,$68,$69,$03,$80,$81,$82,$83,$03,$6E,$84,$84,$88,$03
        .byte   $85,$85,$88,$88,$03,$86,$6E,$88,$86,$03,$71,$88,$6F,$71,$03,$88
        .byte   $88,$8B,$8B,$03,$88,$9B,$9B,$6F,$02,$85,$7C,$88,$91,$03,$77,$85
        .byte   $92,$88,$03,$94,$88,$9C,$8B,$03,$88,$93,$8B,$9B,$03,$60,$8D,$6D
        .byte   $60,$03,$6F,$70,$70,$6E,$02,$8D,$8D,$6F,$8D,$03,$6E,$6E,$6E,$6E
        .byte   $02,$71,$72,$77,$78,$03,$73,$67,$79,$69,$03,$66,$74,$68,$7A,$03
        .byte   $75,$76,$7B,$7C,$03,$71,$72,$8D,$8D,$03,$75,$76,$8D,$8D,$03,$A0
        .byte   $90,$91,$92,$03,$99,$9A,$9B,$9C,$03,$05,$01,$00,$98,$BA,$02,$00
        .byte   $E3,$BA,$03,$00,$83,$BB,$04,$00,$23,$BC,$06,$00,$55,$BC,$60,$61
        .byte   $63,$64,$01,$62,$7C,$65,$7F,$02,$7B,$7A,$7E,$7D,$01,$66,$67,$69
        .byte   $6A,$02,$68,$82,$6B,$85,$72,$81,$80,$84,$83,$02,$6C,$6D,$6F,$70
        .byte   $01,$6E,$88,$71,$8B,$02,$87,$86,$8A,$89,$01,$72,$8C,$73,$8D,$02
        .byte   $74,$8E,$75,$8F,$02,$E0,$E1,$F0,$F1,$41,$F7,$F8,$F7,$F8,$53,$B8
        .byte   $B9,$C8,$C9,$03,$BA,$BB,$CA,$CB,$03,$F7,$F8,$F7,$F8,$03,$9C,$9D
        .byte   $AC,$AD,$03,$9E,$9F,$AE,$AF,$03,$D8,$D9,$E8,$E9,$03,$DA,$DB,$EA
        .byte   $EB,$03,$F7,$F8,$F3,$F4,$63,$F7,$F8,$F5,$F6,$03,$C2,$C3,$D2,$D3
        .byte   $03,$A6,$A7,$B6,$B7,$03,$C6,$C7,$D6,$D7,$03,$E6,$E7,$D2,$D3,$03
        .byte   $C6,$C7,$D2,$D3,$03,$F7,$F8,$F7,$76,$03,$F7,$F8,$90,$F8,$03,$76
        .byte   $90,$79,$93,$03,$D4,$D5,$E5,$E4,$03,$F7,$F7,$F7,$FD,$03,$BC,$BD
        .byte   $CC,$CD,$03,$BE,$BF,$CE,$CF,$03,$DC,$BD,$EC,$CD,$03,$BE,$DF,$CE
        .byte   $EF,$03,$F7,$DD,$F7,$ED,$03,$DE,$F8,$EE,$F8,$03,$F7,$76,$76,$96
        .byte   $03,$90,$F8,$96,$90,$03,$79,$96,$F7,$79,$03,$96,$93,$93,$F8,$03
        .byte   $FD,$FD,$FD,$FD,$03,$76,$93,$93,$F8,$03,$79,$90,$F7,$79,$03,$FD
        .byte   $F7,$F7,$F7,$03,$F7,$FD,$F7,$F7,$03,$F7,$F7,$FD,$F7,$03,$B4,$B5
        .byte   $C4,$C5,$03,$D4,$D5,$D2,$D3,$03,$F7,$D2,$F7,$F8,$03,$D3,$F8,$F7
        .byte   $F8,$03,$F7,$F8,$F7,$E4,$03,$E4,$E5,$E5,$E4,$03,$F7,$F8,$E5,$F8
        .byte   $03,$E4,$E5,$C4,$E4,$03,$E4,$E5,$E5,$C5,$03,$D4,$C4,$D2,$D4,$03
        .byte   $C5,$D5,$D5,$D3,$03,$D3,$D2,$F7,$F8,$03,$C5,$C4,$D5,$D4,$03,$F7
        .byte   $F8,$B5,$B4,$03,$B4,$B5,$E5,$E4,$03,$9B,$9A,$B6,$B7,$03,$AA,$AB
        .byte   $C2,$C3,$03,$D2,$D3,$F7,$F7,$03,$9A,$9B,$B7,$B6,$03,$F7,$A6,$F7
        .byte   $B6,$03,$A7,$F7,$B7,$F7,$03,$F7,$C6,$F7,$C2,$03,$C7,$F7,$C3,$F7
        .byte   $03,$D2,$AA,$F7,$C2,$03,$AB,$D3,$C3,$F7,$03,$AB,$AA,$C3,$C2,$03
        .byte   $C6,$9B,$C2,$B6,$03,$9A,$C7,$B7,$C3,$03,$A6,$9A,$B6,$B7,$03,$9B
        .byte   $A7,$B6,$B7,$03,$A7,$A6,$B7,$B6,$03,$E4,$E4,$E5,$C4,$03,$E5,$E5
        .byte   $C5,$E4,$03,$F9,$FA,$F7,$F8,$03,$FB,$FC,$F7,$F8,$03,$F7,$F8,$F9
        .byte   $FA,$03,$F7,$F8,$FB,$FC,$03,$F7,$F8,$94,$95,$03,$94,$95,$C2,$C3
        .byte   $03,$D2,$D3,$F7,$F8,$03,$D2,$D3,$94,$95,$03,$9C,$9D,$AC,$AD,$03
        .byte   $9E,$9F,$AE,$AF,$03,$BC,$BD,$CC,$CD,$03,$BE,$BF,$CE,$CF,$03,$D8
        .byte   $D9,$E8,$E9,$03,$DA,$DB,$EA,$EB,$03,$DC,$BD,$EC,$CD,$03,$BE,$DF
        .byte   $CE,$EF,$03,$F7,$DD,$F7,$ED,$03,$DE,$F8,$EE,$F8,$03,$06,$11,$00
        .byte   $A0,$BC,$12,$00,$C5,$B3,$13,$00,$65,$B4,$14,$00,$D7,$BC,$15,$00
        .byte   $77,$BD,$16,$00,$D2,$B5,$60,$61,$64,$65,$83,$62,$63,$66,$67,$03
        .byte   $68,$69,$6C,$6D,$02,$6A,$6B,$6E,$6F,$02,$7A,$7B,$80,$80,$03,$7C
        .byte   $80,$80,$80,$03,$BF,$DF,$CF,$EF,$52,$70,$71,$74,$75,$03,$72,$73
        .byte   $76,$77,$03,$80,$78,$80,$79,$03,$D5,$D6,$E5,$E6,$03,$B7,$B8,$C7
        .byte   $C8,$01,$B9,$BA,$C9,$CA,$01,$D9,$DA,$E9,$EA,$01,$BB,$BC,$CB,$CC
        .byte   $01,$BD,$BE,$CD,$CE,$01,$CB,$CC,$DB,$DC,$01,$CD,$CE,$DD,$DE,$01
        .byte   $B0,$B1,$C0,$C1,$03,$D0,$D1,$E2,$E1,$03,$80,$80,$9A,$99,$03,$D4
        .byte   $E4,$80,$80,$03,$80,$80,$D4,$E4,$03,$D4,$E4,$80,$D4,$03,$D4,$E4
        .byte   $E4,$D4,$03,$D4,$E4,$E4,$80,$03,$80,$80,$80,$D4,$03,$80,$80,$E4
        .byte   $80,$03,$F8,$F9,$FA,$FB,$03,$F0,$F1,$F4,$F5,$03,$F2,$F3,$F6,$F7
        .byte   $03,$B0,$B1,$C0,$C1,$03,$80,$B0,$80,$C0,$03,$B1,$B0,$C1,$C0,$03
        .byte   $B1,$80,$C1,$80,$03,$B3,$B2,$C3,$C2,$03,$B2,$B3,$C2,$C3,$03,$D3
        .byte   $9B,$E3,$9C,$03,$9C,$80,$80,$80,$03,$B4,$9B,$C4,$9C,$03,$80,$B0
        .byte   $80,$C0,$03,$B0,$B3,$C0,$C3,$03,$80,$D0,$80,$E2,$03,$D3,$D2,$E3
        .byte   $E2,$03,$D0,$B2,$E2,$C2,$03,$B3,$D1,$C3,$E1,$03,$D2,$D3,$E2,$E3
        .byte   $03,$B2,$B4,$C2,$C4,$03,$B0,$B3,$C0,$C3,$03,$B2,$B1,$C2,$C1,$03
        .byte   $9D,$9F,$AA,$AD,$13,$06,$01,$00,$B8,$BD,$02,$00,$C2,$BD,$03,$00
        .byte   $62,$BE,$04,$00,$02,$BF,$05,$00,$A2,$BF,$06,$00,$B1,$BF,$FF,$F8
        .byte   $FF,$FA,$82,$F9,$FF,$FB,$FF,$02,$AF,$80,$AF,$80,$03,$88,$AF,$88
        .byte   $AF,$03,$AF,$AF,$AF,$AF,$03,$80,$AF,$AF,$88,$03,$AF,$80,$88,$AF
        .byte   $03,$AF,$88,$80,$AF,$03,$88,$AF,$AF,$80,$03,$91,$92,$A1,$A2,$03
        .byte   $93,$94,$A3,$A4,$03,$91,$94,$A1,$A4,$03,$BE,$BF,$CE,$CF,$03,$BC
        .byte   $BD,$CC,$CD,$03,$8D,$8E,$9D,$9E,$03,$82,$83,$9D,$9E,$03,$82,$83
        .byte   $A5,$A6,$03,$80,$80,$80,$80,$03,$80,$80,$80,$9A,$03,$9B,$9B,$9B
        .byte   $9B,$03,$80,$9A,$9A,$9B,$03,$FF,$84,$84,$95,$03,$85,$85,$95,$97
        .byte   $03,$86,$FF,$97,$86,$03,$FC,$FC,$FC,$FC,$01,$8A,$97,$BE,$F2,$03
        .byte   $95,$97,$8B,$8B,$03,$95,$8C,$F7,$BF,$03,$DE,$DF,$EE,$EF,$03,$DC
        .byte   $DD,$EC,$ED,$03,$AD,$AE,$8F,$9F,$03,$AD,$AE,$A5,$A6,$03,$FC,$FC
        .byte   $FC,$FD,$01,$FC,$FC,$FD,$FC,$01,$9A,$9B,$9B,$9B,$03,$9B,$80,$9C
        .byte   $80,$03,$80,$80,$9A,$99,$03,$87,$88,$87,$88,$03,$88,$88,$88,$88
        .byte   $03,$88,$89,$88,$89,$03,$88,$97,$97,$88,$03,$95,$97,$97,$95,$03
        .byte   $95,$88,$88,$95,$03,$87,$95,$87,$97,$03,$97,$89,$95,$89,$03,$99
        .byte   $80,$9B,$99,$03,$96,$80,$81,$96,$03,$81,$98,$98,$80,$03,$9B,$9C
        .byte   $9C,$80,$03,$FC,$FC,$FD,$FD,$01,$FC,$FD,$FC,$FC,$01,$FD,$FC,$FC
        .byte   $FC,$01,$FD,$FC,$FC,$FD,$01,$FC,$FD,$FD,$FC,$01,$FD,$FD,$FC,$FD
        .byte   $01,$FD,$FD,$FD,$FC,$01,$FC,$FD,$FD,$FD,$01,$FD,$FC,$FD,$FD,$01
        .byte   $FD,$FD,$FD,$FD,$01,$FD,$FD,$FC,$FC,$01,$84,$86,$8A,$8C,$03,$8D
        .byte   $8E,$8F,$9F,$03,$BA,$BB,$9D,$9E,$03,$DA,$DB,$EA,$EB,$01,$CA,$CB
        .byte   $9D,$9E,$03,$CB,$CA,$9E,$9D,$03,$80,$80,$80,$A7,$03,$80,$80,$A8
        .byte   $A9,$03,$80,$80,$AA,$AB,$03,$80,$80,$AC,$80,$03,$80,$80,$80,$C1
        .byte   $03,$B2,$B3,$C2,$C3,$03,$B8,$B9,$C8,$C9,$03,$80,$80,$B1,$80,$03
        .byte   $80,$D1,$80,$80,$03,$D2,$D3,$E2,$E3,$03,$D4,$D5,$E4,$E5,$03,$D6
        .byte   $D7,$E6,$E7,$03,$D8,$D9,$E8,$E9,$03,$E1,$80,$80,$80,$03,$FF,$FF
        .byte   $FF,$FF,$02,$F3,$F4,$80,$80,$03,$F5,$F6,$80,$80,$03,$E9,$80,$80
        .byte   $80,$03,$FF,$82,$FF,$9D,$03,$83,$FF,$9E,$FF,$03,$FF,$AD,$FF,$A5
        .byte   $03,$AE,$FF,$A6,$FF,$03,$82,$CB,$9D,$9E,$03,$CA,$83,$9D,$9E,$03
        .byte   $AD,$BA,$A5,$9D,$03,$BB,$AE,$9E,$A6,$03,$80,$8D,$80,$9D,$03,$8E
        .byte   $80,$9E,$80,$03,$80,$AD,$80,$8F,$03,$AE,$9C,$9F,$80,$03,$8D,$CB
        .byte   $9D,$9E,$03,$CA,$8E,$9D,$9E,$03,$AD,$CA,$8F,$9D,$03,$CB,$AE,$9E
        .byte   $9F,$03,$9C,$80,$80,$80,$03,$BE,$BF,$CE,$CF,$03,$DE,$DF,$EE,$EF
        .byte   $03,$82,$83,$9D,$9E,$03,$AD,$AE,$A5,$A6,$03,$FF,$84,$84,$88,$03
        .byte   $85,$85,$88,$88,$03,$86,$FF,$88,$86,$03,$8A,$88,$BE,$8A,$03,$88
        .byte   $88,$8B,$8B,$03,$88,$8C,$8C,$BF,$03,$87,$88,$87,$88,$03,$88,$89
        .byte   $88,$89,$03,$88,$88,$88,$88,$03,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF

; ---- bank5.bank_id_BFFF (data) $BFFF-$BFFF, 1 bytes
; Bank 5 identity byte
        .byte   $05
