; PRG bank 3 - not yet established
; $8000-$BFFF
; The switchable window. Every address below exists in seven banks; only this
; one has these bytes at it, which is what the L3_ label prefix records.
.org $8000


; ---- bank3.code_8000 (code) $8000-$801D, 30 bytes
L3_8000:
        jmp     L3_8C98
L3_8003:
        jmp     L3_8F89
L3_8006:
        jmp     L3_90C6
L3_8009:
        jmp     L3_832D
L3_800C:
        jmp     L3_8300
L3_800F:
        jmp     L3_917F
L3_8012:
        jmp     L3_93FA
L3_8015:
        jmp     L3_952E
L3_8018:
        jmp     L3_80A0
L3_801B:
        jmp     L3_822A

; ---- UNCLAIMED (gap) $801E-$802D, 16 bytes
        .byte   $FF,$FF,$00,$00,$86,$96,$86,$96,$13,$97,$73,$97,$EF,$97,$EB,$98

; ---- bank3.code_802E (code) $802E-$8037, 10 bytes
L3_802E:
        lda     $18
        clc
        adc     #$03
        sta     $18
        jsr     L7_C171

; ---- bank3.inline_8038 (text) $8038-$803C, 5 bytes
; "0000" at $8038
        .byte   $04,$30,$30,$30,$30

; ---- bank3.code_803D (code) $803D-$803D, 1 bytes
        rts

; ---- UNCLAIMED (gap) $803E-$809F, 98 bytes
        .byte   $FF,$FF,$2D,$99,$91,$99,$91,$99,$73,$9A,$A5,$9A,$09,$9B,$4D,$9B
        .byte   $06,$9C,$4A,$9C,$6D,$9C,$B1,$9C,$DD,$9D,$41,$9E,$76,$A4,$F8,$A4
        .byte   $71,$A6,$D1,$A7,$C4,$A9,$88,$AA,$97,$AB,$FB,$AB,$7D,$AC,$E1,$AC
        .byte   $87,$AE,$CA,$AF,$00,$B1,$F5,$B1,$BF,$B3,$03,$B4,$03,$B4,$47,$B4
        .byte   $7F,$B5,$FD,$B5,$81,$B6,$81,$B6,$E0,$B6,$43,$B7,$3B,$B9,$0B,$BA
        .byte   $35,$BB,$B9,$BB,$3D,$BC,$39,$BD,$1D,$BE,$9E,$BE,$56,$BF,$6E,$A3
        .byte   $F2,$A3

; ---- bank3.code_80A0 (code) $80A0-$80AA, 11 bytes
L3_80A0:
        jsr     L7_C01B
        lda     #$20
        jsr     L7_C018
        jsr     L7_C06C

; ---- bank3.inline_80AB (data) $80AB-$80AE, 4 bytes
; Inline argument at $80AB
        .byte   $40,$23,$C0,$00

; ---- bank3.code_80AF (code) $80AF-$80C0, 18 bytes
        lda     #$30
        sta     $0181
        lda     #$21
        sta     $0182
        lda     #$16
        sta     $0183
        jsr     L7_C06F

; ---- bank3.inline_80C1 (text) $80C1-$80CF, 15 bytes
; "YOU GOT ITEM" at $80C1
        .byte   $0C,$20,$84,$59,$4F,$55,$20,$47,$4F,$54,$20,$49,$54,$45,$4D

; ---- bank3.code_80D0 (code) $80D0-$80D5, 6 bytes
        jsr     L7_C0DE
        jsr     L7_C006

; ---- bank3.inline_80D6 (data) $80D6-$80D8, 3 bytes
; Far-call argument at $80D6
        .byte   $06,$11,$80

; ---- bank3.code_80D9 (code) $80D9-$8106, 46 bytes
        lda     #$80
        sta     $14
        lda     #$C8
        sta     $18
        lda     #$20
        sta     $19
        ldx     $76
L3_80E7:
        cpx     #$92
        bcs     L3_8158
        lda     $15
        cmp     $817A,X
        bcc     L3_8158
        lda     $15
        pha
        lda     $14
        pha
        lda     $19
        pha
        lda     $18
        pha
        jsr     L3_820C
        lda     $817B,X
        jsr     L7_C006

; ---- bank3.inline_8107 (data) $8107-$8109, 3 bytes
; Far-call argument at $8107
        .byte   $02,$14,$80

; ---- bank3.code_810A (code) $810A-$815A, 81 bytes
        ldx     $76
        pla
        sta     $18
        pla
        sta     $19
        pla
        sta     $14
        pla
        sta     $15
        lda     $817A,X
        jsr     L7_C051
        jsr     L3_802E
        lda     $18
        clc
        adc     #$05
        sta     $18
        lda     #$00
        sta     $17
        ldy     #$C0
        lda     $14
        jsr     L7_C054
        ldy     #$64
        jsr     L7_C021
        inx
        inx
        stx     $76
        lda     $14
        clc
        adc     #$04
        sta     $14
        lda     $18
        and     #$C0
        clc
        adc     #$80
        ora     #$08
        sta     $18
        bcc     L3_8152
        inc     $19
L3_8152:
        lda     $19
        cmp     #$23
        bcc     L3_80E7
L3_8158:
        jsr     L7_C06F

; ---- bank3.inline_815B (text) $815B-$8171, 23 bytes
; "GO TO THE NEXT SPACE" at $815B
        .byte   $14,$23,$28,$47,$4F,$20,$54,$4F,$20,$54,$48,$45,$20,$4E,$45,$58
        .byte   $54,$20,$53,$50,$41,$43,$45

; ---- bank3.code_8172 (code) $8172-$8179, 8 bytes
        ldy     #$B4
        jsr     L7_C021
        jmp     L7_C0ED

; ---- UNCLAIMED (gap) $817A-$820B, 146 bytes
        .byte   $00,$10,$00,$00,$00,$0D,$00,$11,$01,$02,$01,$03,$02,$09,$02,$04
        .byte   $02,$01,$03,$07,$04,$11,$05,$0D,$06,$06,$07,$05,$07,$08,$08,$0A
        .byte   $08,$0D,$09,$11,$0A,$0E,$0B,$06,$0C,$09,$0D,$02,$0E,$0D,$0F,$0F
        .byte   $10,$10,$10,$04,$11,$03,$12,$08,$13,$0D,$14,$11,$15,$0B,$16,$00
        .byte   $17,$0F,$18,$07,$19,$0D,$1A,$0B,$1B,$0B,$1C,$0A,$1D,$0D,$1D,$05
        .byte   $1E,$01,$1F,$08,$1F,$04,$20,$11,$21,$0D,$22,$09,$23,$07,$24,$10
        .byte   $25,$11,$25,$05,$26,$03,$28,$0F,$29,$02,$2A,$0A,$2B,$0D,$2C,$00
        .byte   $2D,$01,$2E,$0D,$2E,$11,$2E,$10,$2F,$0F,$30,$0E,$32,$0B,$33,$0D
        .byte   $34,$06,$35,$0B,$36,$11,$38,$10,$3A,$0D,$3C,$0D,$44,$0D,$46,$11
        .byte   $50,$11

; ---- bank3.code_820C (code) $820C-$8225, 26 bytes
L3_820C:
        lda     $14
        sta     $18
        lda     #$01
        asl     $18
        rol     A
        asl     $18
        rol     A
        asl     $18
        rol     A
        asl     $18
        rol     A
        sta     $19
        lda     $817B,X
        jsr     L7_C006

; ---- bank3.inline_8226 (data) $8226-$8228, 3 bytes
; Far-call argument at $8226
        .byte   $02,$02,$80

; ---- bank3.code_8229 (code) $8229-$822F, 7 bytes
        rts
L3_822A:
        ldx     #$FF
        txs
        jsr     L7_C06F

; ---- bank3.inline_8230 (text) $8230-$823C, 13 bytes
; "SOUND TEST" at $8230
        .byte   $0A,$20,$88,$53,$4F,$55,$4E,$44,$20,$54,$45,$53,$54

; ---- bank3.code_823D (code) $823D-$827F, 67 bytes
        lda     #$01
        sta     $15
        lda     #$01
        sta     $14
L3_8245:
        lda     #$20
        sta     $19
        lda     #$CD
        sta     $18
        lda     $15
        jsr     L7_C051
L3_8252:
        jsr     L7_C0E4
        sta     $19
        beq     L3_8252
        lda     $F5
        bne     L3_8265
        dec     $14
        bne     L3_8252
        lda     #$02
        bne     L3_8267
L3_8265:
        lda     #$0F
L3_8267:
        sta     $14
        lda     $19
        and     #$04
        beq     L3_8277
        lda     $15
        jsr     L7_C030
        jmp     L3_8252
L3_8277:
        lda     $19
        and     #$08
        beq     L3_8286
        jsr     L7_C006

; ---- bank3.inline_8280 (data) $8280-$8282, 3 bytes
; Far-call argument at $8280
        .byte   $00,$FF,$7F

; ---- bank3.code_8283 (code) $8283-$82BC, 58 bytes
        jmp     L3_8252
L3_8286:
        lda     $19
        and     #$03
        beq     L3_8252
        cmp     #$02
        bne     L3_829A
        dec     $15
        bne     L3_8245
        lda     #$47
        sta     $15
        bne     L3_8245
L3_829A:
        cmp     #$01
        bne     L3_8252
        inc     $15
        lda     $15
        cmp     #$48
        bcc     L3_8245
        lda     #$01
        sta     $15
        bne     L3_8245
L3_82AC:
        lda     #$1F
        jsr     L7_C030
        sei
        jsr     L7_C015
        lda     #$20
        jsr     L7_C018
        jsr     L7_C06C

; ---- bank3.inline_82BD (data) $82BD-$82C0, 4 bytes
; Inline argument at $82BD
        .byte   $40,$23,$C0,$00

; ---- bank3.code_82C1 (code) $82C1-$82DB, 27 bytes
        lda     $FF
        ora     #$08
        and     #$DF
        sta     $FF
        sta     $2000
        lda     #$10
        sta     $19
        sta     $18
        lda     #$03
        ldy     #$02
        jsr     L7_C042
        jsr     L7_C006

; ---- bank3.inline_82DC (data) $82DC-$82DE, 3 bytes
; Far-call argument at $82DC
        .byte   $02,$11,$80

; ---- bank3.code_82DF (code) $82DF-$82F5, 23 bytes
        lda     #$22
        sta     $19
        lda     #$84
        sta     $18
        ldx     #$16
        ldy     #$05
        jsr     L3_8BB3
        jsr     L3_8B7E
        lda     #$19
        jmp     L7_C030

; ---- UNCLAIMED (gap) $82F6-$82FF, 10 bytes
        .byte   $20,$E4,$C0,$29,$F0,$F0,$F9,$4C,$7E,$8B

; ---- bank3.code_8300 (code) $8300-$8317, 24 bytes
L3_8300:
        lda     #$1F
        jsr     L7_C030
        lda     #$10
        jsr     L7_C030
        jsr     L3_82AC
        jsr     L3_834F
        lda     #$01
        sta     $0400
        jsr     L3_887F

; ---- UNCLAIMED (gap) $8318-$832C, 21 bytes
        .byte   $90,$09,$20,$6F,$87,$20,$F6,$82,$4C,$15,$83,$A5,$2F,$F0,$03,$20
        .byte   $73,$84,$4C,$97,$83

; ---- bank3.code_832D (code) $832D-$8351, 37 bytes
L3_832D:
        jsr     L3_82AC
        jsr     L3_83AE
        jsr     L3_860E
        ldy     #$20
L3_8338:
        lda     $0410,Y
        sta     $073F,Y
        dey
        bne     L3_8338
        jsr     L3_866B
        jsr     L3_8711
        beq     L3_8397
        jsr     L3_834F
        jmp     L3_8380
L3_834F:
        jsr     L7_C06C

; ---- bank3.inline_8352 (data) $8352-$8355, 4 bytes
; Inline argument at $8352
        .byte   $14,$22,$A6,$20

; ---- bank3.code_8356 (code) $8356-$8358, 3 bytes
        jsr     L7_C06C

; ---- bank3.inline_8359 (data) $8359-$835C, 4 bytes
; Inline argument at $8359
        .byte   $14,$22,$C6,$20

; ---- bank3.code_835D (code) $835D-$835F, 3 bytes
        jsr     L7_C06C

; ---- bank3.inline_8360 (data) $8360-$8363, 4 bytes
; Inline argument at $8360
        .byte   $14,$22,$E6,$20

; ---- bank3.code_8364 (code) $8364-$8366, 3 bytes
        jsr     L7_C06C

; ---- bank3.inline_8367 (data) $8367-$836A, 4 bytes
; Inline argument at $8367
        .byte   $14,$23,$06,$20

; ---- bank3.code_836B (code) $836B-$8375, 11 bytes
        lda     #$00
        ldy     #$20
L3_836F:
        sta     $0410,Y
        dey
        bne     L3_836F
        rts

; ---- UNCLAIMED (gap) $8376-$837F, 10 bytes
        .byte   $20,$11,$87,$F0,$1C,$A9,$00,$8D,$00,$04

; ---- bank3.code_8380 (code) $8380-$8385, 6 bytes
L3_8380:
        jsr     L3_8B7E
        jsr     L3_887F

; ---- UNCLAIMED (gap) $8386-$8396, 17 bytes
        .byte   $B0,$06,$20,$F2,$87,$4C,$91,$83,$20,$B5,$87,$20,$F6,$82,$4C,$76
        .byte   $83

; ---- bank3.code_8397 (code) $8397-$8442, 172 bytes
L3_8397:
        jsr     L7_C015
        lda     #$1F
        jsr     L7_C030
        jsr     L7_C0ED
        lda     $FF
        and     #$F7
        ora     #$20
        sta     $FF
        sta     $2000
        rts
L3_83AE:
        ldy     #$11
L3_83B0:
        lda     $049F,Y
        sta     $0438,Y
        dey
        bne     L3_83B0
        lda     $46
        lsr     A
        rol     $0441
        lsr     A
        rol     $0441
        lsr     A
        rol     $0441
        lsr     A
        rol     $0441
        lda     $0447
        and     #$7F
        sta     $0447
        lda     $47
        cmp     #$FF
        bne     L3_83DB
        lda     #$00
L3_83DB:
        ora     $6B
        sta     $044A
        lda     $52
        ldy     $4A
        dey
        jsr     L3_8430
        sta     $044B
        lda     $53
        ldy     $4B
        jsr     L3_8430
        sta     $044C
        lda     $0170
        sta     $19
        lda     $0171
        sta     $18
        lda     $0172
        jsr     L3_844D
        sta     $044D
        lsr     $18
        rol     $0444
        lsr     $18
        rol     $0444
        lda     $0173
        sta     $19
        lda     $0174
        sta     $18
        lda     $0175
        jsr     L3_844D
        sta     $044E
        lsr     $18
        rol     $0444
        lsr     $18
        rol     $0444
        rts
L3_8430:
        sta     $10
        tya
        jsr     L3_8439
        lda     $10
        rts
L3_8439:
        lsr     A
        rol     $10
        lsr     A
        rol     $10
        lsr     A
        rol     $10
        rts

; ---- UNCLAIMED (gap) $8443-$844C, 10 bytes
        .byte   $A0,$00,$84,$10,$20,$39,$84,$A4,$10,$60

; ---- bank3.code_844D (code) $844D-$8472, 38 bytes
L3_844D:
        sta     $10
        lda     $18
        asl     A
        asl     A
        adc     $18
        asl     A
        adc     $10
        sta     $10
        lda     #$00
        lda     $19
        asl     A
        adc     $19
        asl     A
        asl     A
        asl     A
        adc     $19
        asl     A
        rol     $18
        asl     A
        rol     $18
        adc     $10
        bcc     L3_8472
        inc     $18
L3_8472:
        rts

; ---- UNCLAIMED (gap) $8473-$8515, 163 bytes
        .byte   $A0,$11,$B9,$38,$04,$99,$9F,$04,$88,$D0,$F7,$AD,$AE,$04,$29,$7F
        .byte   $8D,$AE,$04,$AD,$B0,$04,$29,$7F,$8D,$B0,$04,$A9,$00,$4E,$A8,$04
        .byte   $2A,$4E,$A8,$04,$2A,$4E,$A8,$04,$2A,$4E,$A8,$04,$2A,$85,$46,$AD
        .byte   $4A,$04,$29,$07,$85,$6B,$AD,$4A,$04,$29,$F8,$D0,$02,$A9,$FF,$85
        .byte   $47,$AD,$4B,$04,$20,$43,$84,$85,$7C,$C8,$84,$4A,$AD,$4C,$04,$20
        .byte   $43,$84,$85,$7D,$84,$4B,$A9,$00,$4E,$AB,$04,$2A,$4E,$AB,$04,$2A
        .byte   $A8,$AD,$4E,$04,$20,$02,$85,$8C,$75,$01,$8D,$74,$01,$A5,$19,$8D
        .byte   $73,$01,$A9,$00,$4E,$AB,$04,$2A,$4E,$AB,$04,$2A,$A8,$AD,$4D,$04
        .byte   $20,$02,$85,$8C,$72,$01,$8D,$71,$01,$A5,$19,$8D,$70,$01,$60,$48
        .byte   $A9,$64,$85,$10,$68,$20,$0E,$C1,$85,$19,$A9,$0A,$20,$0B,$C1,$60
        .byte   $13,$06,$0B

; ---- bank3.code_8516 (code) $8516-$870C, 503 bytes
L3_8516:
        jsr     L7_C045
        lda     $042F
        lsr     A
        lsr     A
        lsr     A
        lsr     A
        sta     $19
        lda     $0430
        asl     A
        asl     A
        ora     $19
        clc
        adc     #$1D
        sta     $19
        lda     #$00
        sta     $17
        sta     $14
        sta     $18
        lda     #$08
        sta     $16
L3_853A:
        ldx     $14
        jsr     L3_85BB
        ldx     $17
        ldy     #$00
        lda     #$03
        sta     $15
L3_8547:
        lda     $0403,Y
        cpx     #$17
        beq     L3_8552
        eor     $19
        dec     $19
L3_8552:
        sta     $011E,X
        cmp     $0439,X
        beq     L3_855C
        inc     $18
L3_855C:
        inx
        iny
        dec     $15
        bne     L3_8547
        stx     $17
        lda     $14
        clc
        adc     #$04
        sta     $14
        dec     $16
        bne     L3_853A
        lda     $0400
        bne     L3_857A
        lda     $18
        beq     L3_85B9
L3_8578:
        sec
        rts
L3_857A:
        ldy     #$00
L3_857C:
        lda     $8513,Y
        cmp     $0411,Y
        bne     L3_859B
        iny
        cpy     #$03
        bne     L3_857C
L3_8589:
        lda     $0411,Y
        bne     L3_859B
        iny
        cpy     #$20
        bne     L3_8589
        sta     $2F
        lda     #$02
        sta     $30
        clc
        rts
L3_859B:
        ldx     #$16
        lda     #$00
        clc
L3_85A0:
        adc     $011D,X
        dex
        bne     L3_85A0
        adc     $0135
        cmp     $0134
        bne     L3_8578
        ldx     #$18
L3_85B0:
        lda     $011D,X
        sta     $0438,X
        dex
        bne     L3_85B0
L3_85B9:
        clc
        rts
L3_85BB:
        lda     #$04
        sta     $15
        ldy     #$00
L3_85C1:
        lda     $0411,X
        sta     $0403,Y
        iny
        inx
        dec     $15
        bne     L3_85C1
        ldx     #$03
L3_85CF:
        lda     $0402,X
        and     #$3F
        sta     $0402,X
        dex
        bne     L3_85CF
        lda     #$00
        lsr     $0404
        ror     A
        lsr     $0404
        ror     A
        ora     $0403
        sta     $0403
        lda     #$00
        lsr     $0405
        ror     A
        lsr     $0405
        ror     A
        lsr     $0405
        ror     A
        lsr     $0405
        ror     A
        ora     $0404
        sta     $0404
        lda     $0406
        asl     A
        asl     A
        ora     $0405
        sta     $0405
        rts
L3_860E:
        jsr     L7_C0EA
        sta     $0450
        jsr     L7_C045
        ldx     #$16
        lda     #$00
        clc
L3_861C:
        adc     $0438,X
        dex
        bne     L3_861C
        adc     $0450
        sta     $044F
        lda     $0450
        sta     $19
        ldx     #$1E
L3_862F:
        lda     $0438,X
        eor     $19
        inc     $19
        sta     a:$00FF,x
        dex
        bne     L3_862F
        lda     $0450
        sta     $0117
        lda     #$20
        sta     $14
        ldy     #$00
L3_8648:
        jsr     L3_8654
        sta     $0411,Y
        iny
        dec     $14
        bne     L3_8648
        rts
L3_8654:
        lda     #$06
        sta     $15
        lda     #$00
L3_865A:
        ldx     #$18
        clc
L3_865D:
        ror     a:$00FF,x
        dex
        bne     L3_865D
        ror     A
        dec     $15
        bne     L3_865A
        lsr     A
        lsr     A
        rts
L3_866B:
        lda     #$22
        sta     $19
        lda     #$A6
        sta     $18
        ldx     #$00
L3_8675:
        lda     $0411,X
        jsr     L3_8681
        inx
        cpx     #$20
        bne     L3_8675
        rts
L3_8681:
        sta     $10
        txa
        pha
        ldy     #$00
        cpx     #$10
        bcc     L3_8690
        iny
        txa
        sbc     #$10
        tax
L3_8690:
        cpx     #$0C
        bcc     L3_8695
        inx
L3_8695:
        cpx     #$08
        bcc     L3_869B
        inx
        inx
L3_869B:
        cpx     #$04
        bcc     L3_86A0
        inx
L3_86A0:
        lda     $10
        jsr     L3_86A8
        pla
        tax
        rts
L3_86A8:
        pha
        lda     #$05
        jsr     L7_C04B
        jsr     L7_C03C
        stx     $13
        tax
        lda     #$82
        sta     $0100,X
        lda     $18
        clc
        adc     $13
        sta     $0102,X
        lda     $19
        sta     $0101,X
        tya
        beq     L3_86DA
L3_86C9:
        lda     $0102,X
        clc
        adc     #$40
        sta     $0102,X
        bcc     L3_86D7
        inc     $0101,X
L3_86D7:
        dey
        bne     L3_86C9
L3_86DA:
        pla
        ldy     #$20
        cmp     #$1A
        bcs     L3_86E5
        adc     #$41
        bne     L3_8701
L3_86E5:
        cmp     #$1E
        bcs     L3_86ED
        adc     #$16
        bne     L3_8701
L3_86ED:
        cmp     #$38
        bcs     L3_86F7
        adc     #$63
        ldy     #$AE
        bne     L3_8701
L3_86F7:
        cmp     #$3E
        bcs     L3_86FF
        adc     #$FC
        bne     L3_8701
L3_86FF:
        adc     #$5C
L3_8701:
        sta     $0104,X
        tya
        sta     $0103,X
        ldx     $13
        jmp     L7_C03F

; ---- UNCLAIMED (gap) $870D-$8710, 4 bytes
        .byte   $54,$00,$00,$50

; ---- bank3.code_8711 (code) $8711-$8722, 18 bytes
L3_8711:
        lda     #$20
        sta     $19
        lda     #$E8
        sta     $18
        ldx     #$0E
        ldy     #$07
        jsr     L3_8BB3
        jsr     L7_C06F

; ---- bank3.inline_8723 (text) $8723-$872B, 9 bytes
; "GO OUT" at $8723
        .byte   $06,$21,$4B,$47,$4F,$20,$4F,$55,$54

; ---- bank3.code_872C (code) $872C-$872E, 3 bytes
        jsr     L7_C06F

; ---- bank3.inline_872F (text) $872F-$873B, 13 bytes
; "WORD CHECK" at $872F
        .byte   $0A,$21,$8B,$57,$4F,$52,$44,$20,$43,$48,$45,$43,$4B

; ---- bank3.code_873C (code) $873C-$8774, 57 bytes
        ldx     #$04
L3_873E:
        lda     $870C,X
        sta     $0203,X
        dex
        bne     L3_873E
L3_8747:
        jsr     L3_8864
        jsr     L7_C0E4
        and     #$2C
        bne     L3_875D
        lda     $F5
        and     #$D0
        beq     L3_8747
        lda     $0204
        cmp     #$54
        rts
L3_875D:
        lda     $0204
        cmp     #$54
        bne     L3_8768
        lda     #$64
        bne     L3_876A
L3_8768:
        lda     #$54
L3_876A:
        sta     $0204
        bne     L3_8747
        jsr     L3_8783
        jsr     L7_C06F

; ---- bank3.inline_8775 (text) $8775-$8781, 13 bytes
; "WRONG WORD" at $8775
        .byte   $0A,$21,$8A,$57,$52,$4F,$4E,$47,$20,$57,$4F,$52,$44

; ---- bank3.code_8782 (code) $8782-$87B4, 51 bytes
        rts
L3_8783:
        lda     #$21
        sta     $19
        lda     #$88
        sta     $18
        ldx     #$0E
        ldy     #$00
        tya
        jsr     L3_8BB3
        lda     $18
        sec
        sbc     #$20
        sta     $18
        bcs     L3_879E
        dec     $19
L3_879E:
        ldy     #$01
        lda     #$00
        jsr     L3_8BB3
        lda     $18
        sec
        sbc     #$20
        sta     $18
        bcs     L3_87B0
        dec     $19
L3_87B0:
        ldy     #$03
        jmp     L3_8BB3

; ---- UNCLAIMED (gap) $87B5-$880E, 90 bytes
        .byte   $20,$7E,$8B,$A9,$21,$85,$19,$A9,$48,$85,$18,$A2,$0E,$A0,$07,$20
        .byte   $B3,$8B,$20,$72,$87,$20,$6F,$C0,$09,$21,$CA,$54,$48,$45,$20,$41
        .byte   $42,$4F,$56,$45,$20,$FB,$87,$A9,$20,$85,$19,$A9,$86,$85,$18,$A2
        .byte   $00,$BD,$40,$07,$20,$81,$86,$E8,$E0,$20,$D0,$F5,$60,$A9,$22,$85
        .byte   $19,$A9,$08,$20,$89,$87,$20,$6F,$C0,$0D,$22,$0A,$57,$4F,$52,$44
        .byte   $20,$49,$53,$20,$52,$49,$47,$48,$54,$60

; ---- bank3.code_880F (code) $880F-$8876, 104 bytes
L3_880F:
        lda     $0207
        cmp     #$80
        bcc     L3_8819
        clc
        adc     #$F8
L3_8819:
        clc
        adc     #$D0
        lsr     A
        lsr     A
        lsr     A
        lsr     A
        sta     $16
        lda     $0204
        clc
        adc     #$D0
        lsr     A
        lsr     A
        lsr     A
        lsr     A
        beq     L3_8839
        tax
L3_882F:
        lda     $16
        clc
        adc     #$0A
        sta     $16
        dex
        bne     L3_882F
L3_8839:
        lda     $020B
        lsr     A
        lsr     A
        lsr     A
        sta     $10
        sec
        sbc     #$06
        tax
        cpx     #$05
        bcc     L3_884A
        dex
L3_884A:
        cpx     #$0A
        bcc     L3_8850
        dex
        dex
L3_8850:
        cpx     #$0D
        bcc     L3_8855
        dex
L3_8855:
        stx     $17
        ldy     $0208
        cpy     #$C8
        bne     L3_8863
        txa
        adc     #$0F
        sta     $17
L3_8863:
        rts
L3_8864:
        inc     $41
        lda     $41
        and     #$07
        tay
        lda     $8877,Y
        sta     $018D
        lda     #$03
        sta     $017F
        rts

; ---- UNCLAIMED (gap) $8877-$887E, 8 bytes
        .byte   $30,$10,$00,$0C,$0F,$0C,$00,$10

; ---- bank3.code_887F (code) $887F-$8B1A, 668 bytes
L3_887F:
        jsr     L3_8B23
        jsr     L3_8B0F
L3_8885:
        jsr     L3_8864
        jsr     L7_C0E4
        sta     $0457
        lda     $F7
        and     #$40
        ora     $0457
        sta     $0457
        ldy     #$00
        lda     $F5
        bne     L3_88B4
        inc     $0458
        ldy     $0458
        cpy     #$14
        bcc     L3_88BB
        ldy     #$0F
        lda     $F7
        and     #$0F
        ora     $0457
        sta     $0457
L3_88B4:
        beq     L3_88BB
        lda     #$33
        jsr     L7_C030
L3_88BB:
        sty     $0458
        jsr     L3_893E
        jsr     L3_88C7
        jmp     L3_8885
L3_88C7:
        lda     $0457
        and     #$80
        bne     L3_88CF
        rts
L3_88CF:
        lda     $0457
        ora     #$40
        sta     $0457
        lda     #$34
        jsr     L7_C030
        lda     $0204
        cmp     #$90
        beq     L3_891E
L3_88E3:
        jsr     L3_880F
        lda     #$22
        sta     $19
        lda     #$A6
        sta     $18
        ldx     $17
        lda     $16
        sta     $0411,X
        jsr     L3_8681
L3_88F8:
        lda     $0208
        cmp     #$C8
        bne     L3_8906
        lda     $020B
        cmp     #$C8
        beq     L3_8912
L3_8906:
        jsr     L3_8A93
L3_8909:
        lda     $0457
        and     #$BF
        sta     $0457
        rts
L3_8912:
        lda     #$C0
        sta     $0207
        lda     #$90
        sta     $0204
        bne     L3_8909
L3_891E:
        lda     $0207
        cmp     #$80
        beq     L3_88F8
        lda     $0207
        cmp     #$A0
        bne     L3_8932
        jsr     L3_8A0B
        jmp     L3_8909
L3_8932:
        lda     $0207
        cmp     #$C0
        bne     L3_88E3
        pla
        pla
        jmp     L3_8516
L3_893E:
        lda     #$08
        bit     $0457
        beq     L3_8948
        jmp     L3_8967
L3_8948:
        lda     #$04
        bit     $0457
        beq     L3_8952
        jmp     L3_89B8
L3_8952:
        lda     #$02
        bit     $0457
        beq     L3_895C
        jmp     L3_8A0B
L3_895C:
        lda     #$01
        bit     $0457
        beq     L3_8966
        jmp     L3_8A93
L3_8966:
        rts
L3_8967:
        lda     $0457
        and     #$40
        bne     L3_89A9
        lda     $0204
        cmp     #$30
        bne     L3_898D
        lda     $0207
        cmp     #$70
        bne     L3_8980
        lda     #$60
        bne     L3_8984
L3_8980:
        bcc     L3_8987
        lda     #$A0
L3_8984:
        sta     $0207
L3_8987:
        lda     #$90
        sta     $0204
        rts
L3_898D:
        cmp     #$90
        beq     L3_899B
L3_8991:
        clc
        lda     $0204
        adc     #$F0
        sta     $0204
        rts
L3_899B:
        lda     $0207
        cmp     #$70
        bcc     L3_8991
        lda     #$88
        sta     $0207
        bne     L3_8991
L3_89A9:
        lda     $0208
        cmp     #$B8
        bne     L3_89B1
        rts
L3_89B1:
        clc
        adc     #$F0
        sta     $0208
        rts
L3_89B8:
        lda     $0457
        and     #$40
        bne     L3_89FC
        lda     $0204
        cmp     #$90
        bne     L3_89D8
        lda     $0207
        cmp     #$70
        bcc     L3_89D2
        lda     #$88
        sta     $0207
L3_89D2:
        lda     #$30
        sta     $0204
        rts
L3_89D8:
        cmp     #$80
        beq     L3_89E6
L3_89DC:
        clc
        lda     $0204
        adc     #$10
        sta     $0204
        rts
L3_89E6:
        lda     $0207
        cmp     #$61
        bcc     L3_89DC
        cmp     #$70
        bne     L3_89F5
        lda     #$60
        bne     L3_89F7
L3_89F5:
        lda     #$A0
L3_89F7:
        sta     $0207
        bne     L3_89DC
L3_89FC:
        lda     $0208
        cmp     #$C8
        bne     L3_8A04
        rts
L3_8A04:
        clc
        adc     #$10
        sta     $0208
        rts
L3_8A0B:
        lda     $0457
        and     #$40
        bne     L3_8A5D
        lda     $0207
        cmp     #$30
        bne     L3_8A28
        lda     $0204
        cmp     #$90
        bne     L3_8A24
        lda     #$C0
        bne     L3_8A3E
L3_8A24:
        lda     #$C8
        bne     L3_8A3E
L3_8A28:
        lda     $0204
        cmp     #$90
        beq     L3_8A42
        lda     $0207
        cmp     #$88
        bne     L3_8A3B
        clc
        adc     #$E8
        bne     L3_8A3E
L3_8A3B:
        clc
        adc     #$F0
L3_8A3E:
        sta     $0207
        rts
L3_8A42:
        lda     $0207
        cmp     #$61
        bcc     L3_8A3B
        cmp     #$80
        bne     L3_8A51
        lda     #$60
        bne     L3_8A3E
L3_8A51:
        cmp     #$A0
        bne     L3_8A59
        lda     #$80
        bne     L3_8A3E
L3_8A59:
        lda     #$A0
        bne     L3_8A3E
L3_8A5D:
        lda     $020B
        cmp     #$30
        bne     L3_8A76
        lda     $0208
        cmp     #$C8
        bne     L3_8A75
        lda     #$B8
        sta     $0208
        lda     #$C8
        sta     $020B
L3_8A75:
        rts
L3_8A76:
        cmp     #$58
        beq     L3_8A89
        cmp     #$B0
        beq     L3_8A89
        cmp     #$88
        beq     L3_8A8E
        clc
        adc     #$F8
L3_8A85:
        sta     $020B
        rts
L3_8A89:
        clc
        adc     #$F0
        bne     L3_8A85
L3_8A8E:
        clc
        adc     #$E8
        bne     L3_8A85
L3_8A93:
        lda     $0457
        and     #$40
        bne     L3_8AD9
        lda     $0204
        cmp     #$90
        beq     L3_8ABC
        lda     $0207
        cmp     #$C8
        bne     L3_8AAC
L3_8AA8:
        lda     #$30
        bne     L3_8AB8
L3_8AAC:
        cmp     #$70
        bne     L3_8AB5
        clc
        adc     #$18
        bne     L3_8AB8
L3_8AB5:
        clc
        adc     #$10
L3_8AB8:
        sta     $0207
        rts
L3_8ABC:
        lda     $0207
        cmp     #$C0
        beq     L3_8AA8
        cmp     #$60
        bcc     L3_8AB5
        bne     L3_8ACD
        lda     #$80
        bne     L3_8AB8
L3_8ACD:
        cmp     #$80
        bne     L3_8AD5
        lda     #$A0
        bne     L3_8AB8
L3_8AD5:
        lda     #$C0
        bne     L3_8AB8
L3_8AD9:
        lda     $020B
        cmp     #$C8
        bne     L3_8AF2
        lda     $0208
        cmp     #$B8
        bne     L3_8A75
        lda     #$C8
        sta     $0208
        lda     #$30
        sta     $020B
        rts
L3_8AF2:
        cmp     #$48
        beq     L3_8B05
        cmp     #$A0
        beq     L3_8B05
        cmp     #$70
        beq     L3_8B0A
        clc
        adc     #$08
L3_8B01:
        sta     $020B
        rts
L3_8B05:
        clc
        adc     #$10
        bne     L3_8B01
L3_8B0A:
        clc
        adc     #$18
        bne     L3_8B01
L3_8B0F:
        ldx     #$08
L3_8B11:
        lda     $8B1A,X
        sta     $0203,X
        dex
        bne     L3_8B11
        rts

; ---- UNCLAIMED (gap) $8B1B-$8B22, 8 bytes
        .byte   $30,$00,$00,$30,$B8,$00,$00,$30

; ---- bank3.code_8B23 (code) $8B23-$8B5B, 57 bytes
L3_8B23:
        lda     #$20
        sta     $19
        lda     #$86
        sta     $18
        ldx     #$00
        stx     $15
        stx     $14
L3_8B31:
        lda     $15
        ldy     $14
        jsr     L3_86A8
        inc     $15
        inx
        inx
        cpx     #$08
        bne     L3_8B48
        ldy     $14
        cpy     #$06
        bne     L3_8B31
        beq     L3_8B59
L3_8B48:
        cpx     #$0A
        bne     L3_8B4F
        inx
        bne     L3_8B31
L3_8B4F:
        cpx     #$15
        bne     L3_8B31
        ldx     #$00
        inc     $14
        bne     L3_8B31
L3_8B59:
        jsr     L7_C06F

; ---- bank3.inline_8B5C (text) $8B5C-$8B69, 14 bytes
; "FR[ BA[ END" at $8B5C
        .byte   $0B,$22,$2F,$46,$52,$5B,$20,$42,$41,$5B,$20,$45,$4E,$44

; ---- bank3.code_8B6A (code) $8B6A-$8B6A, 1 bytes
        rts

; ---- UNCLAIMED (gap) $8B6B-$8B7D, 19 bytes
        .byte   $A9,$20,$85,$15,$A9,$20,$85,$14,$A9,$00,$85,$17,$A9,$14,$85,$16
        .byte   $20,$84,$C0

; ---- bank3.code_8B7E (code) $8B7E-$8CEE, 369 bytes
L3_8B7E:
        lda     #$F8
        sta     $0204
        sta     $0208
        lda     #$21
        sta     $19
        lda     #$6C
        sta     $18
        ldx     #$06
        ldy     #$00
L3_8B92:
        jsr     L3_8BB3
        cpy     #$0F
        bcs     L3_8BB2
        lda     #$00
        jsr     L3_8BB3
        tya
        beq     L3_8BA2
        iny
L3_8BA2:
        iny
        inx
        inx
        lda     $18
        sec
        sbc     #$21
        sta     $18
        bcs     L3_8BB0
        dec     $19
L3_8BB0:
        bne     L3_8B92
L3_8BB2:
        rts
L3_8BB3:
        sta     $1B
        sty     $1A
        jsr     L3_8C7F
        lda     #$07
        jsr     L3_8C76
        sta     $0103,Y
        jsr     L7_C03F
        stx     $15
        txa
        beq     L3_8BD8
        inc     $18
        lda     #$03
        jsr     L3_8C76
        sta     $14
        jsr     L7_C036
        dec     $18
L3_8BD8:
        lda     $18
        pha
        sec
        adc     $15
        sta     $18
        jsr     L3_8C7F
        lda     #$0B
        jsr     L3_8C76
        sta     $0103,Y
        jsr     L7_C03F
        lda     $19
        pha
        lda     $1A
        beq     L3_8C1D
        ora     #$80
        sta     $15
        jsr     L7_C0E7
        lda     #$0A
        jsr     L3_8C76
        sta     $14
        jsr     L7_C036
        pla
        sta     $19
        pla
        sta     $18
        pha
        lda     $19
        pha
        jsr     L7_C0E7
        lda     #$05
        jsr     L3_8C76
        sta     $14
        jsr     L7_C036
L3_8C1D:
        pla
        sta     $19
        pla
        sta     $18
        pha
        lda     $19
        pha
        lda     $1A
        beq     L3_8C45
        sta     $15
        jsr     L7_C0E7
L3_8C30:
        jsr     L7_C0E7
        dec     $15
        bne     L3_8C30
        jsr     L3_8C7F
        lda     #$0D
        jsr     L3_8C76
        sta     $0103,Y
        jsr     L7_C03F
L3_8C45:
        stx     $15
        txa
        beq     L3_8C58
        inc     $18
        lda     #$0C
        jsr     L3_8C76
        sta     $14
        jsr     L7_C036
        dec     $18
L3_8C58:
        lda     $18
        sec
        adc     $15
        sta     $18
        jsr     L3_8C7F
        lda     #$0E
        jsr     L3_8C76
        sta     $0103,Y
        jsr     L7_C03F
        pla
        sta     $19
        pla
        sta     $18
        ldy     $1A
        rts
L3_8C76:
        ror     $1B
        rol     $1B
        bne     L3_8C7E
        lda     #$20
L3_8C7E:
        rts
L3_8C7F:
        lda     #$04
        jsr     L7_C04B
        jsr     L7_C03C
        tay
        lda     $19
        sta     $0101,Y
        lda     $18
        sta     $0102,Y
        lda     #$01
        sta     $0100,Y
        rts
L3_8C98:
        lda     $0500
        bmi     L3_8CE7
        ora     #$80
        sta     $0500
        lda     #$03
        sta     $0620
        lda     #$00
        sta     $0728
        sta     $07E8
        jsr     L3_8FAA
        jsr     L7_C0A2
        jsr     L7_C132
        lda     $0578
        and     #$80
        ora     #$14
        sta     $0578
        bit     $30
        bvc     L3_8CDA
        lda     #$05
        sta     $0680
        lda     #$01
        sta     $0548
        lda     #$00
        sta     $06B0
        sta     $06C8
        beq     L3_8CE7
L3_8CDA:
        lda     #$08
        sta     $06B0
        jsr     L7_C0A2
        ldy     $32
        jsr     L3_8F85
L3_8CE7:
        lda     $07E8
        beq     L3_8CF3
        jsr     L7_C006

; ---- bank3.inline_8CEF (data) $8CEF-$8CF1, 3 bytes
; Far-call argument at $8CEF
        .byte   $01,$FF,$7F

; ---- bank3.code_8CF2 (code) $8CF2-$8D43, 82 bytes
        rts
L3_8CF3:
        jsr     L7_C02D
        bit     $30
        bvs     L3_8D27
        lda     $A0
        and     #$01
        beq     L3_8D03
        jmp     L3_8E6B
L3_8D03:
        jsr     L3_8F53
        ldy     $32
        cpy     #$04
        bne     L3_8D18
        lda     #$FF
        sta     $0650,X
        lda     $0728
        bne     L3_8D24
        beq     L3_8D21
L3_8D18:
        lda     $8EF4,Y
        sta     $0668
        jsr     L7_C102
L3_8D21:
        jsr     L3_8FB9
L3_8D24:
        jmp     L3_8DF5
L3_8D27:
        bit     $0578
        bpl     L3_8D5C
        bvc     L3_8D5C
        lda     #$80
        ldy     #$0C
        jsr     L7_C0A5
        lda     $8D44,Y
        sta     $0548,X
        lda     $8D50,Y
        sta     $0560,X
        jmp     L3_8D9A

; ---- UNCLAIMED (gap) $8D44-$8D5B, 24 bytes
        .byte   $01,$02,$03,$04,$05,$06,$07,$06,$05,$04,$03,$02,$00,$01,$02,$03
        .byte   $00,$01,$02,$43,$40,$41,$42,$43

; ---- bank3.code_8D5C (code) $8D5C-$8ED7, 380 bytes
L3_8D5C:
        ldy     $32
        lda     $8EEB,Y
        bne     L3_8D76
        lda     $0680
        cmp     #$05
        beq     L3_8D8B
        bcs     L3_8D71
        inc     $0680
        bpl     L3_8D8B
L3_8D71:
        dec     $0680
        bpl     L3_8D8B
L3_8D76:
        clc
        adc     $0680
        sta     $0680
        bpl     L3_8D84
        inc     $0680
        bpl     L3_8D8B
L3_8D84:
        cmp     #$0B
        bne     L3_8D8B
        dec     $0680
L3_8D8B:
        ldy     $0680
        lda     $8EFD,Y
        sta     $0548
        lda     $8F08,Y
        sta     $0560
L3_8D9A:
        ldy     $32
        lda     $8EF4,Y
        sta     $0668
        cpy     #$04
        beq     L3_8DF5
        jsr     L7_C102
        lda     $05C0
        clc
        adc     $0758
        tay
        lda     $05D8
        adc     $0518
        cmp     #$18
        bcs     L3_8DC1
        lda     #$18
        ldy     #$00
        beq     L3_8DC9
L3_8DC1:
        cmp     #$B0
        bcc     L3_8DC9
        lda     #$B0
        ldy     #$00
L3_8DC9:
        sta     $0518
        sty     $0758
        lda     $05F0
        clc
        adc     $0770
        tay
        lda     $0608
        adc     $0530
        cmp     #$0C
        bcs     L3_8DE7
        lda     #$0C
        ldy     #$00
        beq     L3_8DEF
L3_8DE7:
        cmp     #$F4
        bcc     L3_8DEF
        lda     #$F4
        ldy     #$00
L3_8DEF:
        sta     $0530
        sty     $0770
L3_8DF5:
        lda     $0548
        ldy     $49
        bne     L3_8DFE
        lda     #$0A
L3_8DFE:
        jsr     L7_C0B4
        lda     $F7
        ora     $F8
        and     #$40
        bne     L3_8E0F
        lda     #$01
        sta     $33
        bne     L3_8E3C
L3_8E0F:
        dec     $33
        bne     L3_8E3C
        lda     $39
        sta     $33
        ldy     #$00
L3_8E19:
        lda     $0501,Y
        beq     L3_8E25
        iny
        cpy     $3B
        bne     L3_8E19
        beq     L3_8E3C
L3_8E25:
        lda     #$02
        sta     $0501,Y
        lda     $0518
        sta     $0519,Y
        lda     $0530
        sta     $0531,Y
        lda     $0668
        sta     $0789,Y
L3_8E3C:
        lda     $3C
        beq     L3_8E6B
        lda     $F7
        ora     $F8
        and     #$80
        beq     L3_8E6B
        ldy     $3B
L3_8E4A:
        lda     $0501,Y
        bne     L3_8E66
        lda     $0668
        sta     $0789,Y
        lda     #$03
        sta     $0501,Y
        lda     $0518
        sta     $0519,Y
        lda     $0530
        sta     $0531,Y
L3_8E66:
        iny
        cpy     #$04
        bne     L3_8E4A
L3_8E6B:
        lda     $0578
        bpl     L3_8E92
        dec     $0788
        bne     L3_8E86
        bit     $30
        bvs     L3_8E7C
        jsr     L3_8F89
L3_8E7C:
        lda     $0578
        and     #$3F
        sta     $0578
        bpl     L3_8E92
L3_8E86:
        bit     $0578
        bvs     L3_8E92
        lda     $0788
        and     #$01
        bne     L3_8E95
L3_8E92:
        jsr     L7_C090
L3_8E95:
        bit     $30
        bvc     L3_8EBA
        lda     $41
        and     #$02
        lsr     A
        tay
        lda     $B9
        beq     L3_8EAE
        iny
        cmp     #$03
        bcc     L3_8EAE
        iny
        cmp     #$04
        bcc     L3_8EAE
        iny
L3_8EAE:
        lda     $8ED8,Y
        sta     $87
        bmi     L3_8EBA
        lda     #$1D
        jsr     L7_C093
L3_8EBA:
        lda     $0578
        and     #$40
        beq     L3_8ED7
        ldy     $0788
        lda     $8EDC,Y
        beq     L3_8ED7
        lda     $0560
        sta     $86
        lda     #$70
        sta     $87
        lda     #$21
        jmp     L7_C093
L3_8ED7:
        rts

; ---- UNCLAIMED (gap) $8ED8-$8F52, 123 bytes
        .byte   $FF,$00,$30,$32,$34,$01,$00,$00,$00,$01,$00,$00,$01,$00,$01,$00
        .byte   $01,$00,$01,$FF,$FF,$FF,$00,$00,$00,$01,$01,$01,$06,$08,$0A,$04
        .byte   $0C,$0C,$02,$00,$0E,$03,$02,$02,$02,$02,$01,$02,$02,$02,$02,$03
        .byte   $00,$00,$00,$00,$00,$00,$40,$40,$40,$40,$40,$20,$28,$30,$28,$38
        .byte   $40,$48,$40,$00,$08,$00,$08,$38,$40,$48,$40,$20,$28,$30,$28,$50
        .byte   $58,$60,$58,$10,$18,$10,$18,$50,$58,$60,$58,$40,$40,$40,$40,$40
        .byte   $40,$40,$40,$00,$00,$40,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$40,$40,$40,$40,$40,$40

; ---- bank3.code_8F53 (code) $8F53-$8F74, 34 bytes
L3_8F53:
        ldy     $32
        bit     $0578
        bpl     L3_8F85
        bvc     L3_8F85
        lda     #$80
        ldy     #$08
        jsr     L7_C0A5
        lda     $8F75,Y
        sta     $06C8
        lda     $8F7D,Y
        sta     $0560
        lda     #$50
        sta     $0548
        rts

; ---- UNCLAIMED (gap) $8F75-$8F84, 16 bytes
        .byte   $00,$40,$28,$58,$10,$58,$28,$40,$00,$01,$02,$03,$00,$41,$42,$43

; ---- bank3.code_8F85 (code) $8F85-$8FBB, 55 bytes
L3_8F85:
        cpy     #$04
        beq     L3_8F90
L3_8F89:
        lda     #$20
        ldy     #$04
        jsr     L7_C0A5
L3_8F90:
        lda     $0668
        asl     A
        adc     $0638
        tay
        lda     $8F13,Y
        sta     $06C8
        lda     #$50
        sta     $0548
        lda     $8F33,Y
        sta     $0560
        rts
L3_8FAA:
        lda     #$00
        sta     $05C0,X
        sta     $05D8,X
        sta     $05F0,X
        sta     $0608,X
        rts
L3_8FB9:
        jsr     L7_C006

; ---- bank3.inline_8FBC (data) $8FBC-$8FBE, 3 bytes
; Far-call argument at $8FBC
        .byte   $06,$08,$80

; ---- bank3.code_8FBF (code) $8FBF-$9120, 354 bytes
        lda     $6C
        cmp     $07A0
        sta     $07A0
        beq     L3_9015
        cmp     #$02
        bne     L3_9015
        lda     $0518
        cmp     #$38
        bcs     L3_8FD8
        lda     #$00
        beq     L3_8FED
L3_8FD8:
        cmp     #$90
        bcc     L3_8FE0
        lda     #$08
        bne     L3_8FED
L3_8FE0:
        lda     $0530
        cmp     #$30
        bcs     L3_8FEB
        lda     #$02
        bne     L3_8FED
L3_8FEB:
        lda     #$06
L3_8FED:
        sta     $A4
        cmp     #$04
        bcc     L3_8FF5
        sbc     #$02
L3_8FF5:
        lsr     A
        tay
        lda     a:$0058,y
        and     #$07
        beq     L3_9009
        sec
        sbc     #$01
        jsr     L7_C078
        and     $04B0
        beq     L3_9014
L3_9009:
        lda     $A0
        ora     #$03
        sta     $A0
        lda     #$3B
        jmp     L7_C030
L3_9014:
        rts
L3_9015:
        lda     $6C
        cmp     #$01
        bne     L3_9045
        lda     #$33
        jsr     L7_C030
        lda     #$14
        jsr     L7_C12F
        lda     #$02
        jsr     L7_C00C
        lda     #$00
        sta     $15
        sta     $17
        lda     #$1C
        sta     $16
        lda     $0518,X
        clc
        adc     $06B0,X
        sta     $18
        lda     $0530,X
        sta     $19
        jmp     L7_C11A
L3_9045:
        lda     $0518
        cmp     #$10
        bcs     L3_9064
        bit     $54
        bpl     L3_9058
        lda     $58
        and     #$0F
        cmp     #$08
        beq     L3_9060
L3_9058:
        lda     #$10
        sta     $0518
        jmp     L3_9082
L3_9060:
        lda     #$00
        beq     L3_90BD
L3_9064:
        cmp     #$B0
        bcc     L3_9082
        lda     $54
        and     #$10
        beq     L3_9076
        lda     $5B
        and     #$0F
        cmp     #$08
        beq     L3_907E
L3_9076:
        lda     #$AF
        sta     $0518
        jmp     L3_9082
L3_907E:
        lda     #$08
        bne     L3_90BD
L3_9082:
        lda     $0530
        cmp     #$0E
        bcs     L3_90A1
        bit     $54
        bvc     L3_9095
        lda     $59
        and     #$0F
        cmp     #$08
        beq     L3_909D
L3_9095:
        lda     #$0E
        sta     $0530
        jmp     L3_90C5
L3_909D:
        lda     #$02
        bne     L3_90BD
L3_90A1:
        cmp     #$F2
        bcc     L3_90C5
        lda     $54
        and     #$20
        beq     L3_90B3
        lda     $5A
        and     #$0F
        cmp     #$08
        beq     L3_90BB
L3_90B3:
        lda     #$F1
        sta     $0530
        jmp     L3_90C5
L3_90BB:
        lda     #$06
L3_90BD:
        sta     $A4
        lda     $A0
        ora     #$01
        sta     $A0
L3_90C5:
        rts
L3_90C6:
        lda     $0500,X
        bmi     L3_90CC
        rts
L3_90CC:
        lda     #$10
        ldy     #$0A
        jsr     L7_C0A5
        bcc     L3_90D9
        sty     $0500
        rts
L3_90D9:
        lda     $41
        and     #$01
        clc
        adc     $0638
        sta     $15
        ldy     #$06
        lda     $0638
        cmp     #$04
        bcs     L3_90F1
        jsr     L7_C090
        ldy     #$05
L3_90F1:
        sty     $14
        lda     #$00
        sta     $87
L3_90F7:
        lda     $0530
        clc
        adc     $9121,Y
        sta     $85
        lda     $0518
        clc
        adc     $9128,Y
        sta     $84
        lda     $41
        clc
        adc     $14
        and     #$01
        sta     $86
        ldy     $15
        lda     $912F,Y
        jsr     L7_C093
        dec     $14
        ldy     $14
        bpl     L3_90F7
        rts

; ---- UNCLAIMED (gap) $9121-$917E, 94 bytes
        .byte   $FA,$06,$F4,$0C,$FA,$06,$00,$F4,$F4,$00,$00,$0C,$0C,$00,$00,$30
        .byte   $00,$31,$30,$31,$32,$33,$32,$33,$00,$88,$88,$88,$88,$88,$88,$88
        .byte   $02,$88,$88,$88,$88,$88,$88,$88,$88,$88,$02,$88,$88,$88,$00,$00
        .byte   $06,$40,$45,$2E,$46,$23,$47,$06,$49,$18,$19,$2D,$41,$4C,$25,$24
        .byte   $2F,$06,$48,$4D,$26,$4D,$4F,$03,$03,$03,$06,$06,$03,$03,$06,$03
        .byte   $06,$03,$16,$03,$06,$06,$16,$03,$16,$03,$16,$03,$06,$06

; ---- bank3.code_917F (code) $917F-$92BA, 316 bytes
L3_917F:
        lda     $70
        bne     L3_9184
L3_9183:
        rts
L3_9184:
        lda     $70
        beq     L3_9183
        cmp     #$04
        bcc     L3_9194
        bne     L3_9191
        jmp     L3_92EE
L3_9191:
        jmp     L3_93A3
L3_9194:
        cmp     #$02
        bcc     L3_91A0
        bne     L3_919D
        jmp     L3_9218
L3_919D:
        jmp     L3_92DF
L3_91A0:
        bit     $30
        bvc     L3_91C8
        ldy     #$05
        sec
L3_91A7:
        lda     $0170,Y
        sbc     $04B9,Y
        bcs     L3_91B2
        adc     #$0A
        clc
L3_91B2:
        sta     $04B9,Y
        dey
        bpl     L3_91A7
        ldy     $51
        lda     $913A,Y
        sta     $71
        cpy     #$15
        beq     L3_91D2
        lda     $9151,Y
        sta     $72
L3_91C8:
        lda     #$40
        sta     $0300
        lda     #$45
        jsr     L7_C030
L3_91D2:
        lda     #$00
        sta     $73
        sta     $74
        lda     $71
        bpl     L3_920A
        ldx     #$00
        ldy     #$05
L3_91E0:
        lda     $0500,Y
        beq     L3_91FD
        and     #$7F
        cmp     #$29
        beq     L3_91F2
        lda     $0578,Y
        and     #$02
        bne     L3_91FD
L3_91F2:
        inx
        lda     #$00
        sta     $0740,Y
        lda     #$08
        sta     $0500,Y
L3_91FD:
        iny
        cpy     #$18
        bne     L3_91E0
        txa
        beq     L3_920A
        lda     #$22
        jsr     L7_C030
L3_920A:
        lda     $71
        and     #$08
        sta     $10
        lda     $60
        ora     $10
        sta     $60
        inc     $70
L3_9218:
        bit     $30
        bvc     L3_924B
        lda     $51
        cmp     #$15
        beq     L3_9246
        inc     $73
        bne     L3_9228
        inc     $74
L3_9228:
        lda     $73
        and     #$3F
        beq     L3_922F
        rts
L3_922F:
        lda     $74
        beq     L3_9239
        lda     $73
        cmp     #$80
        beq     L3_923E
L3_9239:
        lda     #$43
        jmp     L7_C030
L3_923E:
        ldy     $51
        lda     $9168,Y
L3_9243:
        jsr     L7_C030
L3_9246:
        inc     $70
        jmp     L3_92DF
L3_924B:
        inc     $74
        lda     $74
        cmp     #$08
        bcc     L3_926B
        lda     #$00
        sta     $74
        lda     $73
        tay
        inc     $73
        and     #$07
        bne     L3_9265
        lda     #$43
        jsr     L7_C030
L3_9265:
        tya
        sec
        sbc     #$08
        bcs     L3_926C
L3_926B:
        rts
L3_926C:
        cmp     #$28
        bcs     L3_92B6
        lsr     A
        tay
        lda     $92BB,Y
        sta     $18
        bcc     L3_928B
        and     #$0F
        eor     #$0F
        sta     $10
        lda     $18
        and     #$F0
        eor     #$F0
        sbc     #$20
        ora     $10
        sta     $18
L3_928B:
        lsr     A
        tay
        lda     $0400,Y
        bcs     L3_9296
        lsr     A
        lsr     A
        lsr     A
        lsr     A
L3_9296:
        and     #$0F
        tay
        lda     $92CF,Y
        bne     L3_92B5
        lda     $18
        asl     A
        asl     A
        asl     A
        asl     A
        sta     $19
        lda     #$0E
        sta     $15
        lda     #$55
        sta     $17
        lda     #$10
        sta     $16
        jsr     L7_C117
L3_92B5:
        rts
L3_92B6:
        lda     #$06
        jmp     L3_9243

; ---- UNCLAIMED (gap) $92BB-$92DE, 36 bytes
        .byte   $22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$3E,$4E,$5E,$6E
        .byte   $7E,$8E,$9E,$AE,$00,$01,$00,$01,$01,$01,$00,$00,$00,$01,$00,$01
        .byte   $01,$01,$00,$00

; ---- bank3.code_92DF (code) $92DF-$934E, 112 bytes
L3_92DF:
        jsr     L7_C027
        bcc     L3_92E5
L3_92E4:
        rts
L3_92E5:
        lda     $72
        sta     $0500,Y
        sty     $75
        inc     $70
L3_92EE:
        ldy     $75
        lda     $0500,Y
        and     #$7F
        cmp     $72
        bne     L3_931E
        bit     $30
        bvc     L3_92E4
        lda     $41
        and     #$3F
        bne     L3_92E4
        ldx     #$05
L3_9305:
        dec     $04B9,X
        bpl     L3_92E4
        lda     #$09
        sta     $04B9,X
        dex
        bpl     L3_9305
        ldy     #$05
        lda     #$00
L3_9316:
        sta     $04B9,Y
        dey
        bpl     L3_9316
        bmi     L3_92E4
L3_931E:
        bit     $30
        bvs     L3_9355
        lda     #$60
        sta     $18
        lda     #$70
        sta     $19
        lda     #$04
        sta     $15
        lda     #$00
        sta     $17
        lda     #$18
        sta     $16
        jsr     L7_C117
        jsr     L7_C027
        bcc     L3_9345
        ldx     $75
        jsr     L7_C048
        ldy     $75
L3_9345:
        lda     #$31
        sta     $0500,Y
        lda     #$67
        jsr     L7_C006

; ---- bank3.inline_934F (data) $934F-$9351, 3 bytes
; Far-call argument at $934F
        .byte   $05,$23,$80

; ---- bank3.code_9352 (code) $9352-$935C, 11 bytes
        jmp     L3_9387
L3_9355:
        lda     #$2F
        jsr     L7_C030
        jsr     L7_C006

; ---- bank3.inline_935D (data) $935D-$935F, 3 bytes
; Far-call argument at $935D
        .byte   $06,$02,$80

; ---- bank3.code_9360 (code) $9360-$93F1, 146 bytes
        ldy     #$00
L3_9362:
        lda     $93F2,Y
        jsr     L7_C0CC
        tya
        pha
        lda     #$23
        jsr     L7_C030
        lda     #$04
L3_9371:
        pha
        jsr     L7_C15C
        ldy     #$01
        jsr     L7_C024
        pla
        sec
        sbc     #$01
        bne     L3_9371
        pla
        tay
        iny
        cpy     #$08
        bne     L3_9362
L3_9387:
        inc     $70
        inc     $70
        lda     #$00
        sta     $73
        bit     $30
        bvc     L3_93A3
        ldy     $51
        cpy     #$15
        bne     L3_939F
        ldy     $72
        cpy     #$4D
        bne     L3_93A3
L3_939F:
        sta     $BA
        sta     $BB
L3_93A3:
        inc     $73
        lda     $73
        cmp     #$5A
        bcc     L3_93EE
        ldy     #$1A
        bit     $30
        bvc     L3_93C3
        iny
        lda     $51
        cmp     #$15
        bne     L3_93C3
        lda     $72
        cmp     #$4D
        beq     L3_93C3
        lda     #$00
        sta     $70
        rts
L3_93C3:
        lda     #$1F
        jsr     L7_C030
        tya
        jsr     L7_C030
        lda     #$00
        sta     $70
        sta     $0300
L3_93D3:
        bit     $30
        bvc     L3_93DA
        jsr     L7_C15C
L3_93DA:
        ldy     #$01
        jsr     L7_C024
        lda     $0300
        beq     L3_93D3
        bit     $30
        bvc     L3_93EF
        lda     $A0
        ora     #$01
        sta     $A0
L3_93EE:
        rts
L3_93EF:
        jmp     L7_C15F

; ---- UNCLAIMED (gap) $93F2-$93F9, 8 bytes
        .byte   $0C,$00,$10,$30,$10,$00,$0C,$0F

; ---- bank3.code_93FA (code) $93FA-$950E, 277 bytes
L3_93FA:
        ldy     $0500,X
        bmi     L3_9438
        lda     $94E2,Y
        sta     $0560,X
        lda     $94F5,Y
        sta     $07B8,X
        jsr     L7_C0A8
        jsr     L7_C165
        lda     #$80
        sta     $0530,X
        sta     $0680,X
        lda     #$30
        sta     $0518,X
        sta     $0668,X
        lda     #$01
        sta     $05D8,X
        lda     #$04
        sta     $0608,X
        lda     #$78
        sta     $0788,X
        lda     #$01
        sta     $07A0,X
        jsr     L7_C0A2
L3_9438:
        lda     $0788,X
        beq     L3_9452
        dec     $0788,X
        beq     L3_944D
        lda     $0788,X
        and     #$01
        beq     L3_944A
        rts
L3_944A:
        jmp     L3_94D5
L3_944D:
        lda     #$0B
        sta     $0620,X
L3_9452:
        lda     #$12
        jsr     L7_C09F
        lda     #$20
        jsr     L7_C09C
        ldy     $0638,X
        lda     $951A,Y
        cmp     #$28
        bcs     L3_94D5
        dec     $07A0,X
        bne     L3_94C5
        ldy     $0500,X
        lda     $9478,Y
        sta     $07A0,X
        lda     $947B,Y
        bne     L3_9480
        jsr     L7_C0EA
        and     #$03
        ora     #$01
L3_9480:
        sta     $16
        lda     $0518,X
        cmp     $0518
        bcc     L3_9492
        lda     $16
        eor     #$FF
        sta     $16
        inc     $16
L3_9492:
        lda     $947E,Y
        sta     $14
        jsr     L7_C108
        bcs     L3_94D5
        lda     $07E8,X
        clc
        adc     #$30
        sta     $17
        jsr     L7_C13E
        lda     $14
        jsr     L7_C13B
        lda     $05A8,X
        sta     $05A8,Y
        lda     $0560,X
        sta     $0560,Y
        lda     #$01
        sta     $0620,Y
        lda     $0518,Y
        adc     #$18
        sta     $0518,Y
L3_94C5:
        lda     $41
        and     #$1F
        bne     L3_94D5
        jsr     L7_C108
        bcs     L3_94D5
        lda     #$0B
        jsr     L7_C105
L3_94D5:
        lda     $07B8,X
        ldy     #$08
        jsr     L7_C0A5
        lda     $9512,Y
        sta     $0548,X
        lda     $951A,Y
        clc
        adc     $07E8,X
        sta     $06C8,X
        jsr     L7_C08D
        lda     $41
        and     #$04
        beq     L3_94F8
        lda     #$0E
L3_94F8:
        clc
        adc     $07E8,X
        sta     $87
        lda     #$7C
        jsr     L7_C093
        lda     $0788,X
        bne     L3_950E
        jsr     L7_C0C6
        jmp     L7_C0D8
L3_950E:
        rts

; ---- UNCLAIMED (gap) $950F-$952D, 31 bytes
        .byte   $03,$02,$00,$7E,$7E,$7E,$7E,$7D,$7D,$7E,$7E,$2C,$28,$24,$24,$00
        .byte   $00,$24,$28,$20,$28,$0C,$28,$20,$44,$01,$00,$01,$09,$0C,$0F

; ---- bank3.code_952E (code) $952E-$9672, 325 bytes
L3_952E:
        ldy     $0500,X
        bmi     L3_9562
        lda     $9633,Y
        sta     $0560,X
        lda     $9635,Y
        sta     $07A0,X
        jsr     L7_C0A8
        jsr     L7_C165
        jsr     L7_C0A2
        jsr     L7_C0F0
        lda     #$83
        sta     $0548,X
        lda     #$10
        sta     $0518,X
        sta     $0668,X
        lda     #$00
        sta     $07B8,X
        lda     #$78
        sta     $0788,X
L3_9562:
        lda     $0788,X
        beq     L3_9579
        dec     $0788,X
        beq     L3_9574
        lda     $0788,X
        and     #$01
        bne     L3_959F
        rts
L3_9574:
        lda     #$04
        sta     $05D8,X
L3_9579:
        lda     #$10
        jsr     L7_C09C
        lda     $41
        and     #$01
        bne     L3_959F
        sta     $07B8,X
        lda     $0530,X
        cmp     $0530
        beq     L3_959F
        inc     $07B8,X
        bcs     L3_959C
        inc     $07B8,X
        inc     $0530,X
        bcc     L3_959F
L3_959C:
        dec     $0530,X
L3_959F:
        lda     $05D8,X
        bmi     L3_95AE
        lda     #$00
        sta     $16
        lda     $41
        and     #$08
        bpl     L3_95BB
L3_95AE:
        lda     $41
        and     #$04
        lsr     A
        lsr     A
        sta     $16
        lda     $41
        and     #$10
        lsr     A
L3_95BB:
        lsr     A
        lsr     A
        lsr     A
        tay
        lda     $0560,X
        and     #$03
        ora     $9677,Y
        sta     $0560,X
        jsr     L7_C08D
        ldy     $16
        lda     $9679,Y
        pha
        jsr     L7_C093
        lda     $86
        eor     #$40
        sta     $86
        pla
        jsr     L7_C093
        ldy     $07B8,X
        lda     $967B,Y
        sta     $86
        lda     $967E,Y
        clc
        adc     $87
        sta     $87
        lda     $9681,Y
        jsr     L7_C093
        lda     #$00
        sta     $17
        lda     $0788,X
        bne     L3_9638
        ldy     $05C0,X
        lda     $05D8,X
        beq     L3_960B
        cmp     #$FF
        bne     L3_9638
L3_960B:
        lda     #$01
        sta     $17
        lda     $41
        and     $07A0,X
        bne     L3_9638
        jsr     L7_C108
        bcs     L3_9638
        lda     #$27
        jsr     L7_C105
        lda     $0518,Y
        adc     #$24
        sta     $0518,Y
        inc     $0638,X
        lda     $0638,X
        ora     #$08
        sta     $0788,Y
        lda     #$00
        sta     $07A0,Y
L3_9638:
        lda     $0560,X
        sta     $86
        lda     $84
        clc
        adc     #$18
        sta     $84
        lda     $06C8,X
        sta     $87
        ldy     $17
        lda     $9684,Y
        jsr     L7_C093
        lda     $0518,X
        cmp     #$10
        bcs     L3_9667
        lda     $05D8,X
        bpl     L3_9667
        lda     #$04
        sta     $05D8,X
        lda     #$00
        sta     $05C0,X
L3_9667:
        lda     $0788,X
        beq     L3_966D
        rts
L3_966D:
        jsr     L7_C0C6
        jmp     L7_C0D8

; ---- UNCLAIMED (gap) $9673-$BFFE, 10636 bytes
        .byte   $02,$00,$0F,$07,$00,$40,$84,$85,$00,$40,$00,$3A,$36,$36,$7B,$19
        .byte   $19,$86,$87,$04,$05,$00,$00,$00,$80,$C0,$FE,$5F,$33,$00,$00,$00
        .byte   $80,$40,$BE,$63,$3C,$0E,$01,$04,$00,$06,$04,$0F,$01,$04,$00,$0B
        .byte   $04,$3E,$D5,$EE,$04,$00,$05,$04,$3E,$EB,$17,$4E,$C5,$3E,$04,$00
        .byte   $05,$04,$B7,$FB,$3E,$04,$00,$05,$04,$1E,$33,$3D,$3D,$39,$39,$1E
        .byte   $1A,$1E,$3F,$2F,$2F,$27,$27,$12,$16,$1A,$3C,$34,$34,$38,$28,$70
        .byte   $E0,$16,$34,$2C,$2C,$28,$38,$50,$A0,$04,$00,$07,$01,$01,$00,$07
        .byte   $04,$01,$03,$0E,$74,$B7,$7C,$00,$00,$00,$02,$0D,$7B,$CF,$7C,$04
        .byte   $00,$05,$04,$38,$7C,$7A,$FA,$E6,$CC,$00,$00,$38,$64,$5E,$9E,$9E
        .byte   $3C,$B0,$40,$80,$04,$00,$05,$04,$70,$C0,$80,$04,$00,$05,$04,$04
        .byte   $FD,$FF,$FD,$00,$06,$FD,$01,$06,$FD,$00,$06,$FD,$01,$07,$09,$13
        .byte   $17,$17,$12,$09,$06,$00,$0E,$1C,$18,$18,$1D,$0F,$06,$00,$10,$38
        .byte   $70,$70,$E0,$E0,$C0,$C0,$10,$28,$50,$50,$A0,$A0,$40,$40,$A0,$A0
        .byte   $A0,$60,$40,$80,$00,$00,$60,$60,$60,$E0,$C0,$80,$00,$00,$10,$28
        .byte   $38,$28,$38,$28,$7C,$44,$10,$38,$28,$38,$28,$38,$6C,$7C,$54,$54
        .byte   $BA,$FE,$BA,$54,$28,$10,$6C,$6C,$C6,$82,$C6,$6C,$38,$10,$FD,$FD
        .byte   $FE,$FF,$00,$03,$0F,$0F,$1F,$1D,$1D,$1E,$03,$0C,$10,$11,$22,$26
        .byte   $27,$23,$0F,$0F,$03,$FE,$00,$05,$FE,$11,$10,$0C,$03,$FE,$00,$05
        .byte   $FE,$03,$0F,$0F,$1F,$2D,$2D,$13,$03,$0C,$10,$1C,$32,$33,$3F,$3E
        .byte   $0F,$0F,$03,$FE,$00,$05,$FE,$1C,$10,$0C,$03,$FE,$00,$05,$FE,$C0
        .byte   $F0,$F0,$FE,$F8,$04,$FE,$C0,$30,$08,$08,$FE,$04,$04,$FE,$F0,$F0
        .byte   $C0,$FE,$00,$05,$FE,$08,$08,$30,$C0,$FE,$00,$05,$FE,$03,$0F,$0F
        .byte   $1F,$17,$17,$0F,$03,$0C,$10,$10,$28,$2C,$3C,$38,$0F,$0F,$03,$FE
        .byte   $00,$05,$FE,$10,$10,$0C,$03,$FE,$00,$04,$FE,$FE,$01,$02,$00,$00
        .byte   $1F,$1F,$1F,$1C,$1C,$1E,$01,$00,$04,$01,$10,$1B,$1F,$1F,$1F,$EF
        .byte   $3B,$C7,$31,$0C,$0F,$10,$1F,$0F,$C3,$F9,$3E,$0F,$00,$0F,$00,$10
        .byte   $38,$AC,$D4,$F6,$7A,$3A,$00,$00,$20,$30,$18,$18,$8C,$C4,$1D,$8F
        .byte   $C7,$E3,$F1,$79,$FF,$7F,$E3,$F1,$F9,$FD,$FF,$FF,$3E,$8C,$04,$1A
        .byte   $32,$26,$6C,$4F,$DF,$BF,$00,$06,$0E,$1E,$1C,$38,$30,$60,$F9,$F1
        .byte   $E3,$C7,$0F,$1E,$BF,$FC,$C7,$8F,$1F,$3F,$FF,$FF,$FC,$63,$01,$00
        .byte   $05,$C0,$03,$00,$06,$40,$01,$C0,$03,$01,$DC,$E0,$8C,$3E,$E3,$00
        .byte   $C0,$C0,$C0,$9C,$7C,$E0,$1C,$FF,$00,$1F,$07,$03,$06,$0C,$19,$33
        .byte   $1F,$1F,$07,$03,$07,$0F,$1F,$3D,$65,$69,$70,$01,$00,$05,$01,$7B
        .byte   $75,$48,$01,$00,$05,$01,$05,$0E,$FF,$F3,$61,$C3,$87,$8E,$FE,$01
        .byte   $FF,$04,$01,$FD,$F9,$F1,$FD,$FD,$0A,$0A,$14,$14,$08,$00,$82,$06
        .byte   $0C,$0C,$18,$18,$00,$00,$C0,$60,$9F,$0E,$07,$C3,$E1,$F0,$7F,$01
        .byte   $FF,$04,$01,$BF,$9F,$8F,$F8,$5C,$2E,$2F,$15,$14,$0A,$04,$C7,$23
        .byte   $11,$18,$0C,$0C,$06,$00,$07,$FC,$C0,$60,$30,$D8,$E8,$F8,$FF,$FC
        .byte   $C0,$E0,$F0,$B8,$D8,$E8,$60,$30,$30,$F0,$F0,$00,$00,$00,$E0,$F0
        .byte   $F0,$30,$10,$00,$00,$00,$01,$01,$01,$04,$3F,$6E,$DC,$B0,$C0,$80
        .byte   $C5,$88,$20,$51,$A3,$CF,$BF,$FF,$BA,$F7,$D4,$B8,$FF,$E0,$E0,$E0
        .byte   $60,$3F,$AB,$C7,$C0,$FF,$FF,$FF,$7F,$3F,$FC,$1A,$35,$6B,$55,$AD
        .byte   $19,$33,$00,$E4,$CA,$94,$AA,$52,$E6,$CC,$65,$CB,$FF,$03,$03,$03
        .byte   $02,$FC,$9A,$34,$00,$01,$FC,$05,$01,$01,$06,$07,$06,$00,$06,$06
        .byte   $03,$1E,$06,$00,$05,$06,$03,$0C,$01,$03,$06,$00,$07,$06,$0C,$03
        .byte   $06,$00,$0D,$01,$01,$00,$06,$01,$01,$02,$02,$06,$03,$04,$08,$06
        .byte   $00,$04,$06,$05,$04,$0B,$04,$06,$00,$07,$08,$03,$06,$1C,$14,$06
        .byte   $00,$04,$14,$02,$06,$22,$2A,$14,$1C,$06,$08,$03,$00,$03,$06,$2A
        .byte   $22,$14,$14,$06,$00,$09,$06,$18,$3C,$7E,$06,$00,$06,$06,$18,$24
        .byte   $7E,$3C,$18,$06,$00,$05,$06,$24,$18,$06,$00,$06,$06,$06,$05,$06
        .byte   $05,$00,$05,$05,$02,$04,$38,$00,$00,$00,$03,$07,$0F,$1F,$3F,$0C
        .byte   $0C,$14,$28,$32,$16,$16,$30,$37,$37,$2F,$1F,$1F,$3F,$3F,$3F,$08
        .byte   $0E,$33,$23,$7F,$61,$C1,$E1,$07,$7F,$FD,$FC,$FE,$FF,$FF,$FE,$CC
        .byte   $D2,$AD,$AD,$B3,$9E,$41,$3F,$FF,$FF,$F3,$F3,$05,$FF,$04,$05,$20
        .byte   $60,$C0,$F8,$1C,$16,$F3,$1B,$C0,$BC,$FE,$FF,$EF,$EF,$FF,$EF,$9B
        .byte   $77,$7B,$7B,$7F,$FC,$FA,$02,$6F,$EF,$F7,$97,$FB,$8F,$FF,$FF,$30
        .byte   $18,$1C,$0F,$11,$15,$2B,$34,$05,$3F,$05,$05,$1B,$37,$2C,$44,$28
        .byte   $1C,$04,$02,$09,$01,$00,$7C,$78,$3C,$3C,$0E,$0F,$03,$00,$07,$0F
        .byte   $0C,$18,$D8,$F8,$97,$07,$FF,$F8,$FB,$F7,$F7,$FF,$8F,$3F,$18,$58
        .byte   $6C,$32,$02,$00,$00,$00,$28,$78,$74,$3E,$02,$00,$00,$00,$E0,$F0
        .byte   $30,$18,$1B,$1F,$ED,$D1,$FF,$1F,$DF,$EF,$EF,$FF,$FD,$E9,$29,$14
        .byte   $28,$4B,$5C,$60,$80,$80,$35,$1C,$38,$7B,$6F,$57,$E0,$C0,$0C,$18
        .byte   $38,$ED,$D4,$94,$A4,$04,$05,$FE,$04,$F7,$02,$05,$D7,$F6,$20,$90
        .byte   $A0,$80,$60,$00,$00,$00,$D0,$E0,$D0,$E0,$E0,$00,$00,$00,$05,$05
        .byte   $01,$02,$01,$00,$11,$01,$20,$4C,$84,$80,$41,$3E,$00,$00,$3E,$73
        .byte   $FB,$FF,$7F,$3E,$01,$00,$07,$01,$10,$20,$01,$00,$06,$01,$1C,$3E
        .byte   $4C,$44,$40,$40,$22,$1C,$00,$00,$72,$7A,$7E,$7E,$3E,$1C,$00,$00
        .byte   $01,$01,$02,$03,$00,$00,$1F,$01,$3C,$50,$26,$48,$00,$07,$26,$7F
        .byte   $FF,$6F,$5F,$3F,$12,$2A,$5C,$49,$12,$30,$10,$00,$FF,$F7,$EF,$FE
        .byte   $7D,$7F,$1F,$18,$00,$E9,$72,$80,$3A,$7D,$3E,$34,$30,$75,$BF,$FF
        .byte   $C5,$82,$C1,$CB,$80,$36,$92,$23,$25,$70,$D0,$00,$FF,$FF,$7F,$FF
        .byte   $FB,$FF,$DE,$04,$00,$60,$20,$F8,$0E,$40,$78,$0E,$00,$A0,$F8,$FC
        .byte   $F6,$FE,$FF,$FF,$6A,$94,$D8,$4E,$A0,$40,$20,$00,$F6,$7B,$3F,$BF
        .byte   $DB,$79,$38,$00,$02,$02,$01,$02,$04,$0F,$7F,$A8,$7B,$BE,$3D,$3D
        .byte   $07,$0C,$7B,$F7,$B7,$3F,$3E,$1E,$7E,$7F,$7B,$5E,$BF,$5F,$07,$00
        .byte   $6F,$73,$5E,$3F,$7F,$DF,$07,$00,$26,$F9,$F6,$10,$DC,$7C,$BC,$BC
        .byte   $E6,$3F,$D8,$E8,$EC,$FC,$7C,$78,$7E,$FE,$D2,$7C,$FC,$F8,$E0,$00
        .byte   $F6,$C2,$7E,$FC,$FC,$F8,$E0,$00,$01,$01,$08,$09,$00,$02,$02,$05
        .byte   $06,$02,$05,$04,$03,$07,$0F,$0B,$1B,$1F,$1E,$1F,$0C,$0C,$14,$0E
        .byte   $06,$08,$01,$03,$1F,$03,$08,$17,$0B,$0F,$07,$03,$80,$A0,$50,$40
        .byte   $D0,$D0,$C0,$20,$40,$60,$E0,$F0,$E8,$68,$78,$F8,$20,$20,$60,$50
        .byte   $A0,$80,$00,$00,$08,$F8,$04,$08,$D0,$F0,$E0,$C0,$08,$00,$04,$08
        .byte   $04,$0A,$05,$12,$00,$00,$00,$03,$0F,$17,$1B,$3F,$32,$1A,$06,$1A
        .byte   $17,$01,$00,$00,$1F,$2F,$3F,$1F,$1B,$0F,$03,$08,$00,$04,$80,$02
        .byte   $08,$78,$E0,$48,$00,$00,$00,$40,$70,$D8,$D8,$F4,$48,$F0,$50,$10
        .byte   $10,$60,$80,$00,$F4,$3C,$BC,$F8,$F8,$F0,$C0,$08,$00,$08,$10,$01
        .byte   $00,$05,$08,$03,$0F,$1F,$0E,$4B,$66,$5A,$24,$2C,$0C,$06,$3F,$77
        .byte   $FB,$BF,$FF,$77,$3F,$0F,$08,$00,$07,$78,$01,$00,$05,$08,$C0,$F0
        .byte   $98,$70,$EC,$20,$D0,$59,$16,$10,$20,$FC,$F2,$FF,$3F,$BF,$FE,$FC
        .byte   $F0,$08,$08,$08,$0B,$00,$00,$0E,$1F,$05,$0A,$0A,$09,$00,$00,$0E
        .byte   $1B,$1F,$17,$17,$17,$0A,$02,$06,$02,$01,$01,$01,$01,$17,$0F,$0F
        .byte   $07,$07,$03,$01,$01,$00,$02,$77,$8E,$34,$4A,$41,$42,$00,$02,$75
        .byte   $FE,$CE,$B7,$BF,$BF,$04,$0C,$0C,$14,$22,$21,$01,$00,$FF,$FF,$FF
        .byte   $77,$67,$69,$41,$00,$08,$08,$01,$02,$01,$00,$04,$01,$14,$4C,$33
        .byte   $B2,$01,$00,$04,$01,$28,$3E,$CA,$4B,$43,$C6,$3E,$28,$01,$00,$04
        .byte   $01,$F2,$47,$7C,$14,$01,$00,$04,$01,$01,$00,$01,$1E,$33,$2D,$3F
        .byte   $2D,$29,$35,$2B,$1E,$3F,$33,$21,$33,$37,$2B,$35,$4A,$52,$A4,$B4
        .byte   $28,$48,$68,$48,$76,$6E,$DC,$CC,$D8,$B8,$98,$B8,$A8,$94,$64,$54
        .byte   $5E,$5A,$6A,$5A,$D8,$EC,$5C,$6C,$66,$66,$56,$66,$4A,$D2,$A4,$54
        .byte   $AC,$54,$CA,$0E,$76,$EE,$DC,$AC,$74,$DC,$CE,$0E,$00,$00,$09,$0B
        .byte   $09,$00,$04,$09,$02,$05,$02,$09,$00,$04,$09,$03,$0D,$1A,$1D,$3F
        .byte   $02,$04,$02,$05,$02,$00,$00,$00,$1D,$1B,$0D,$02,$01,$09,$00,$08
        .byte   $09,$21,$08,$42,$00,$07,$CF,$09,$FF,$05,$09,$08,$42,$A8,$11,$0A
        .byte   $14,$00,$00,$FF,$BF,$57,$EE,$B5,$2B,$1E,$00,$00,$00,$02,$15,$08
        .byte   $05,$08,$11,$00,$03,$05,$0A,$37,$7A,$77,$EE,$2A,$04,$08,$15,$08
        .byte   $00,$00,$00,$D5,$FB,$77,$2A,$37,$1F,$02,$00,$00,$00,$0A,$40,$20
        .byte   $08,$15,$28,$1D,$3F,$F5,$BF,$DF,$FF,$FF,$FF,$05,$00,$88,$10,$22
        .byte   $54,$28,$00,$FF,$FF,$77,$EF,$DD,$AB,$D7,$FE,$09,$00,$04,$09,$01
        .byte   $02,$01,$09,$00,$04,$09,$03,$06,$05,$0E,$0F,$02,$01,$09,$00,$06
        .byte   $09,$05,$06,$03,$09,$00,$05,$09,$6A,$39,$28,$56,$2F,$5A,$1A,$45
        .byte   $7D,$7E,$7F,$FF,$FF,$EF,$F5,$FA,$88,$05,$0A,$09,$00,$05,$09,$77
        .byte   $DA,$15,$0F,$09,$00,$07,$09,$04,$0A,$05,$02,$00,$00,$00,$0F,$1B
        .byte   $15,$3A,$7D,$7F,$02,$04,$0A,$05,$02,$00,$00,$00,$7D,$3B,$15,$1A
        .byte   $0D,$02,$00,$00,$F3,$E7,$FF,$E7,$D7,$CF,$93,$58,$EF,$FF,$FF,$DF
        .byte   $EF,$FF,$FF,$F7,$08,$42,$A8,$11,$0A,$14,$00,$00,$FF,$BF,$57,$EE
        .byte   $B5,$2B,$1E,$00,$04,$18,$2A,$59,$4C,$93,$A8,$B4,$07,$1F,$3D,$6E
        .byte   $7F,$FF,$F7,$EB,$EB,$E3,$FF,$D7,$E7,$9B,$9B,$54,$F7,$FF,$DF,$EF
        .byte   $DF,$EF,$F7,$7B,$09,$00,$10,$09,$04,$18,$2A,$59,$4C,$93,$A8,$B4
        .byte   $07,$1F,$3D,$6E,$7F,$FF,$F7,$EB,$09,$09,$FE,$FF,$00,$00,$03,$0F
        .byte   $FE,$1F,$04,$FE,$00,$00,$03,$0F,$1F,$1F,$3F,$3F,$0F,$23,$11,$1D
        .byte   $0F,$03,$00,$00,$3F,$3F,$1E,$1E,$0F,$03,$FE,$00,$04,$FE,$C0,$F0
        .byte   $FE,$F8,$04,$FE,$00,$00,$C0,$F0,$F8,$F8,$FC,$FC,$F0,$C4,$08,$38
        .byte   $F0,$C0,$00,$00,$FC,$FC,$F8,$F8,$F0,$C0,$FE,$00,$04,$FE,$C0,$F0
        .byte   $FE,$F8,$04,$FE,$00,$00,$C0,$F0,$F8,$F8,$FC,$FC,$F8,$DC,$18,$38
        .byte   $F0,$C0,$00,$00,$F4,$E4,$E8,$F8,$F0,$C0,$00,$00,$FE,$FE,$ED,$F2
        .byte   $ED,$00,$04,$ED,$01,$02,$02,$04,$00,$00,$00,$01,$02,$05,$05,$0B
        .byte   $04,$08,$09,$0F,$0F,$0C,$08,$1F,$0B,$17,$17,$17,$1F,$0F,$0F,$1F
        .byte   $08,$08,$18,$B0,$20,$60,$40,$C0,$38,$78,$F8,$70,$E0,$E0,$C0,$C0
        .byte   $C0,$E0,$E0,$E0,$F0,$F0,$38,$3C,$C0,$E0,$E0,$E0,$F0,$70,$D8,$DC
        .byte   $03,$07,$0F,$0E,$1D,$1D,$1E,$0F,$00,$00,$00,$01,$03,$03,$01,$00
        .byte   $07,$18,$37,$63,$60,$C4,$D3,$CE,$08,$1F,$3F,$7F,$7F,$FF,$FF,$FF
        .byte   $E7,$F9,$FD,$7E,$BE,$BE,$7E,$FD,$1F,$07,$03,$81,$C1,$41,$81,$03
        .byte   $F3,$07,$FA,$02,$06,$FD,$85,$5A,$0F,$ED,$FF,$06,$ED,$BF,$9F,$BB
        .byte   $CD,$CE,$DF,$F8,$E1,$C3,$EB,$EC,$FE,$FF,$FF,$FF,$FE,$FC,$8C,$93
        .byte   $2F,$5F,$9F,$3F,$7F,$F7,$F3,$EF,$DF,$BC,$F0,$E0,$C0,$C8,$01,$03
        .byte   $07,$03,$05,$02,$03,$06,$00,$00,$01,$05,$06,$07,$0F,$0F,$06,$02
        .byte   $04,$04,$04,$06,$06,$03,$07,$0F,$1F,$1F,$3F,$3F,$3F,$1F,$7C,$B0
        .byte   $D1,$51,$A2,$66,$41,$C1,$FF,$7F,$3E,$BE,$7D,$FD,$FE,$FE,$C8,$C0
        .byte   $60,$30,$1D,$46,$38,$03,$ED,$FF,$04,$ED,$FE,$B9,$C7,$FF,$1B,$B2
        .byte   $76,$65,$EF,$EC,$6D,$66,$FF,$7F,$FF,$FE,$FC,$FF,$FE,$FF,$33,$99
        .byte   $0C,$6E,$87,$03,$F1,$FE,$FF,$FF,$FF,$9F,$7F,$FF,$FF,$FF,$5E,$BD
        .byte   $BB,$57,$77,$FB,$3D,$CE,$A1,$43,$46,$AE,$8F,$07,$C3,$31,$77,$B9
        .byte   $CF,$73,$78,$9F,$EF,$F9,$88,$C6,$F0,$FC,$BF,$EF,$F3,$FE,$0B,$05
        .byte   $0C,$0A,$1A,$1D,$0C,$06,$17,$0B,$0B,$1D,$3D,$7E,$7F,$7F,$03,$08
        .byte   $26,$31,$1C,$1F,$27,$26,$7F,$37,$39,$3E,$3F,$6F,$5F,$DE,$8F,$DF
        .byte   $FF,$3F,$1F,$0F,$C3,$00,$FF,$FC,$F8,$F8,$FC,$FE,$3F,$FF,$8C,$71
        .byte   $67,$9F,$7F,$FF,$7F,$3F,$F3,$EF,$9F,$7C,$FE,$FF,$7F,$1F,$FF,$FF
        .byte   $CF,$B7,$B7,$CF,$FD,$78,$0F,$03,$31,$68,$78,$33,$86,$FF,$07,$90
        .byte   $EE,$F1,$BF,$DD,$FB,$FB,$FF,$EF,$F1,$FF,$FF,$FF,$9F,$DF,$3F,$D7
        .byte   $EB,$FB,$9B,$37,$F3,$EF,$ED,$FF,$05,$ED,$FB,$7F,$F6,$97,$2F,$1D
        .byte   $FB,$F4,$E0,$83,$0F,$EE,$DE,$FE,$FC,$FB,$FF,$FD,$F1,$46,$44,$4C
        .byte   $48,$ED,$28,$04,$ED,$BE,$BC,$BC,$B8,$58,$58,$58,$18,$18,$10,$ED
        .byte   $00,$06,$ED,$28,$10,$ED,$00,$06,$ED,$3F,$1F,$0F,$0F,$17,$17,$2F
        .byte   $4F,$1F,$2F,$17,$0F,$1F,$1F,$3B,$73,$C3,$D3,$C4,$68,$6F,$31,$44
        .byte   $88,$FE,$FC,$FF,$7F,$7F,$3F,$7B,$F7,$FE,$ED,$FF,$07,$ED,$F1,$F9
        .byte   $FD,$ED,$FF,$08,$ED,$3F,$0F,$F7,$CB,$F5,$FF,$DF,$97,$E7,$F7,$FE
        .byte   $FC,$FE,$7F,$ED,$FF,$07,$ED,$99,$1D,$9D,$DF,$ED,$FF,$12,$ED,$FD
        .byte   $D9,$F3,$9D,$AA,$A5,$97,$48,$2A,$1A,$FF,$FD,$DB,$DE,$EF,$7F,$3D
        .byte   $1D,$0A,$0A,$0A,$08,$08,$04,$06,$02,$0D,$0D,$0D,$0F,$0F,$07,$07
        .byte   $03,$DA,$1D,$AE,$13,$51,$83,$F7,$9E,$FF,$FF,$77,$EF,$EF,$FF,$FF
        .byte   $FF,$AE,$AA,$DA,$DA,$EA,$AA,$99,$00,$DF,$DB,$EB,$EB,$FB,$BB,$99
        .byte   $00,$7F,$80,$F7,$DC,$AE,$4B,$95,$71,$91,$FF,$FF,$FF,$DF,$BF,$FB
        .byte   $FF,$A8,$B0,$A8,$90,$88,$04,$00,$80,$7C,$68,$74,$5C,$4E,$C6,$C0
        .byte   $C0,$01,$02,$06,$0C,$09,$0D,$0B,$0B,$01,$03,$05,$0B,$0F,$0B,$0F
        .byte   $0F,$05,$18,$37,$63,$60,$C4,$D3,$CE,$0F,$1F,$3F,$7F,$7F,$FF,$FF
        .byte   $FF,$03,$3D,$5D,$BE,$42,$9A,$96,$8D,$ED,$FF,$05,$ED,$E7,$EF,$FF
        .byte   $FB,$07,$FA,$02,$06,$FD,$85,$5A,$ED,$FF,$07,$ED,$BF,$9F,$BB,$CD
        .byte   $C6,$CF,$DC,$B7,$6E,$EB,$EC,$FE,$FF,$FF,$FF,$FB,$FF,$D9,$B4,$63
        .byte   $4C,$B0,$45,$20,$9F,$FE,$FB,$FF,$FF,$FF,$FA,$DF,$7F,$1C,$B9,$73
        .byte   $65,$EF,$EF,$68,$61,$FF,$7F,$FF,$FE,$FC,$FF,$FF,$FE,$33,$99,$0C
        .byte   $6E,$87,$03,$F1,$FE,$FF,$FF,$FF,$9F,$7F,$FF,$FF,$FF,$7C,$E1,$0B
        .byte   $57,$F7,$FB,$FD,$3E,$FF,$FF,$F6,$AE,$0F,$87,$C3,$E1,$5F,$2F,$CD
        .byte   $23,$D8,$EF,$F0,$FF,$B0,$D8,$F6,$ED,$FF,$05,$ED,$8F,$DE,$FC,$F9
        .byte   $7B,$78,$BC,$3E,$FF,$FF,$FF,$FE,$FC,$FF,$7F,$FF,$5F,$8F,$E1,$B5
        .byte   $78,$FF,$7F,$3F,$BF,$FF,$DF,$7A,$FF,$FF,$7F,$1F,$FF,$07,$03,$81
        .byte   $01,$61,$F3,$76,$FF,$FF,$FF,$7F,$FF,$FF,$BF,$FF,$FF,$FE,$FE,$30
        .byte   $01,$5D,$FB,$FB,$FF,$FF,$F9,$CF,$FF,$FF,$9F,$DF,$9F,$BB,$CD,$CA
        .byte   $D7,$EC,$92,$27,$EB,$EC,$FE,$FF,$FF,$FF,$FD,$FF,$4C,$99,$35,$6F
        .byte   $8C,$32,$48,$A0,$FF,$FE,$FB,$F7,$FF,$FD,$F7,$5F,$1C,$38,$F1,$67
        .byte   $FE,$F4,$70,$79,$FF,$FF,$7F,$FF,$FF,$FB,$FF,$FF,$33,$99,$0C,$6E
        .byte   $87,$03,$F1,$FE,$FF,$FF,$FF,$9F,$7F,$FF,$FF,$FF,$00,$7F,$FF,$D5
        .byte   $80,$3F,$E0,$00,$FF,$FF,$FF,$EA,$7F,$FF,$FF,$FF,$00,$0F,$B8,$C0
        .byte   $70,$9F,$E4,$ED,$FF,$09,$00,$04,$ED,$01,$00,$03,$0B,$ED,$00,$04
        .byte   $ED,$02,$03,$07,$0F,$05,$1B,$36,$6F,$6D,$C4,$D3,$CE,$0B,$1F,$3F
        .byte   $77,$76,$FB,$FF,$FF,$03,$21,$19,$4E,$16,$AE,$7E,$BD,$07,$13,$FB
        .byte   $3F,$2F,$3F,$FF,$FF,$F9,$A9,$C8,$5A,$AE,$BD,$E5,$7A,$FF,$FF,$FF
        .byte   $EF,$DF,$DF,$BF,$FF,$8F,$DF,$FF,$FF,$7F,$7C,$BF,$3D,$ED,$FF,$06
        .byte   $ED,$7F,$FF,$5F,$8F,$FC,$B5,$7A,$FF,$7E,$3F,$BF,$FF,$DF,$7E,$FF
        .byte   $FF,$7F,$1F,$FF,$FF,$FF,$DF,$5F,$B7,$2F,$5E,$ED,$FF,$06,$ED,$DF
        .byte   $BF,$2F,$6E,$5E,$36,$1B,$3D,$BB,$BB,$FF,$BF,$FF,$CF,$E7,$DF,$DF
        .byte   $DF,$3F,$D7,$EB,$FB,$9B,$37,$B3,$2F,$ED,$FF,$05,$ED,$FB,$7F,$F6
        .byte   $77,$3F,$7D,$7B,$74,$E0,$83,$0F,$BE,$DE,$BE,$FC,$FB,$FF,$FD,$F1
        .byte   $9F,$BB,$CD,$CA,$D7,$EC,$92,$27,$EB,$EC,$FE,$FF,$FF,$FF,$FD,$FF
        .byte   $4C,$99,$3D,$6F,$9F,$3F,$7F,$BF,$FF,$FF,$FB,$FF,$EF,$F7,$FF,$7F
        .byte   $1C,$38,$F1,$67,$FE,$F4,$70,$79,$FF,$FF,$7F,$FF,$FF,$FB,$FF,$FF
        .byte   $33,$99,$0C,$6E,$87,$03,$F1,$FE,$FF,$FF,$FF,$9F,$7F,$FF,$FF,$FF
        .byte   $7F,$7F,$FF,$FF,$FF,$7F,$F0,$6E,$BF,$FF,$FF,$FF,$7F,$BD,$FF,$B9
        .byte   $65,$7A,$F6,$CB,$74,$9F,$E4,$FF,$BA,$FF,$FD,$F7,$FB,$FF,$FF,$FF
        .byte   $3F,$1F,$0F,$0F,$17,$17,$2F,$4F,$1F,$2F,$17,$0F,$1F,$1F,$3B,$73
        .byte   $C3,$D3,$FC,$62,$47,$89,$E1,$93,$FE,$FC,$FF,$7F,$7B,$F7,$FF,$FF
        .byte   $FE,$ED,$FF,$07,$ED,$F1,$F9,$FD,$ED,$FF,$08,$ED,$3F,$0F,$F7,$CB
        .byte   $35,$FF,$DF,$97,$E7,$F7,$FE,$FC,$FE,$94,$89,$AC,$AB,$98,$89,$CA
        .byte   $8A,$FF,$FE,$DF,$DF,$EF,$FF,$FF,$FF,$8A,$82,$C2,$42,$42,$04,$04
        .byte   $03,$FB,$F3,$F3,$73,$73,$17,$07,$03,$9A,$35,$42,$93,$E4,$6F,$39
        .byte   $9A,$7F,$FF,$FF,$EF,$DF,$FF,$FF,$7D,$A9,$A4,$A2,$21,$40,$80,$80
        .byte   $00,$6E,$67,$63,$E1,$C0,$80,$80,$00,$7F,$80,$F7,$9C,$2E,$4D,$98
        .byte   $64,$91,$FF,$FF,$FF,$DF,$BF,$FF,$FB,$7B,$AC,$54,$54,$CC,$4A,$54
        .byte   $40,$F7,$7C,$EC,$EC,$FC,$7E,$76,$60,$ED,$ED,$01,$02,$00,$00,$38
        .byte   $70,$C0,$DC,$7E,$3F,$07,$1F,$3F,$7F,$FF,$FF,$E7,$E7,$3E,$1D,$9D
        .byte   $9C,$DC,$5C,$4C,$60,$FF,$FF,$FB,$FF,$FF,$7B,$7F,$7F,$00,$00,$6C
        .byte   $2E,$03,$03,$06,$FC,$E0,$F8,$9C,$DE,$01,$FF,$04,$01,$00,$98,$BD
        .byte   $3D,$D9,$C2,$C2,$04,$FF,$7F,$E7,$E7,$FF,$BE,$FE,$FC,$2B,$3C,$3B
        .byte   $28,$2E,$51,$9C,$FF,$3F,$3F,$37,$3F,$37,$3F,$FF,$7F,$66,$76,$7E
        .byte   $2F,$0D,$0B,$10,$00,$FF,$FF,$DF,$9D,$3F,$3B,$36,$70,$D4,$3C,$DC
        .byte   $17,$74,$8C,$3C,$FE,$FC,$FC,$EC,$FE,$EF,$FF,$FD,$FB,$B3,$B3,$F3
        .byte   $DE,$F8,$D0,$00,$00,$FF,$FF,$DF,$FE,$FC,$DC,$00,$00,$01,$01,$05
        .byte   $06,$01,$02,$04,$04,$07,$C3,$F3,$FF,$01,$03,$07,$37,$FF,$FE,$DF
        .byte   $9F,$F9,$FC,$EA,$E3,$EE,$FB,$F4,$96,$8F,$FF,$CF,$87,$8F,$DF,$FF
        .byte   $FF,$80,$40,$20,$22,$E4,$FC,$FC,$DC,$80,$C7,$FE,$FE,$FC,$7C,$F8
        .byte   $F0,$9E,$3C,$5C,$D8,$70,$E0,$70,$78,$F8,$FC,$F0,$F0,$F0,$F8,$FC
        .byte   $CC,$8F,$6C,$05,$00,$04,$05,$10,$4C,$EB,$68,$08,$1C,$1C,$1C,$3C
        .byte   $7C,$60,$64,$78,$7F,$1F,$7F,$3F,$0F,$7C,$7C,$78,$7F,$1F,$7F,$3F
        .byte   $0F,$F8,$78,$78,$6C,$05,$80,$04,$05,$CC,$40,$70,$7C,$05,$FC,$04
        .byte   $80,$02,$05,$C0,$E4,$B8,$80,$C0,$F0,$FE,$05,$FC,$04,$05,$FE,$FC
        .byte   $F8,$05,$05,$06,$09,$00,$00,$00,$04,$01,$03,$1E,$0C,$06,$00,$04
        .byte   $0F,$02,$06,$1F,$3F,$1C,$0E,$1F,$0C,$05,$00,$00,$00,$2F,$1F,$1F
        .byte   $17,$0E,$01,$06,$00,$06,$06,$A0,$D0,$F8,$F0,$00,$00,$00,$60,$D0
        .byte   $F0,$F4,$7C,$78,$68,$C0,$E0,$60,$00,$00,$00,$F8,$F0,$F8,$F8,$E0
        .byte   $80,$06,$00,$04,$06,$08,$00,$01,$02,$5C,$08,$00,$08,$14,$1C,$0F
        .byte   $CF,$BF,$FF,$08,$0C,$1E,$07,$04,$20,$00,$00,$7F,$1F,$1F,$3F,$7F
        .byte   $53,$21,$00,$00,$00,$08,$00,$80,$D1,$30,$50,$00,$10,$30,$78,$F9
        .byte   $F6,$FE,$BC,$18,$20,$40,$E0,$62,$00,$00,$40,$F8,$F8,$FC,$FE,$ED
        .byte   $87,$C0,$80,$06,$06,$F9,$FA,$00,$00,$F9,$80,$06,$F9,$00,$00,$80
        .byte   $C0,$C0,$E0,$E0,$F0,$80,$40,$40,$20,$13,$0C,$03,$00,$FC,$7F,$7F
        .byte   $3F,$1C,$0F,$03,$00,$10,$0C,$03,$F9,$00,$05,$F9,$1C,$1F,$0F,$07
        .byte   $07,$0F,$0F,$3F,$00,$01,$2A,$5D,$A3,$CE,$31,$C0,$FF,$FE,$D5,$A2
        .byte   $5C,$3F,$F1,$C0,$70,$3C,$16,$0B,$0B,$05,$05,$07,$70,$2C,$1E,$0F
        .byte   $0F,$07,$07,$05,$09,$0F,$16,$1A,$14,$2C,$34,$24,$0F,$09,$1A,$16
        .byte   $1C,$34,$2C,$3C,$2C,$25,$28,$91,$42,$B2,$B9,$B1,$34,$BC,$F7,$EF
        .byte   $FF,$CF,$C7,$CF,$99,$72,$55,$54,$2B,$22,$D5,$39,$E7,$CF,$EE,$EF
        .byte   $F6,$FF,$FB,$37,$3F,$3B,$2D,$7F,$7F,$5D,$49,$3E,$3F,$37,$33,$77
        .byte   $5D,$7F,$7F,$22,$2A,$2A,$2A,$1C,$1C,$1C,$14,$08,$36,$36,$36,$14
        .byte   $14,$14,$1C,$08,$00,$00,$F9,$80,$04,$F9,$A0,$40,$00,$00,$80,$80
        .byte   $C0,$C0,$C0,$78,$32,$0C,$03,$F9,$00,$05,$F9,$3D,$0F,$03,$F9,$00
        .byte   $08,$F9,$C0,$30,$0E,$01,$02,$00,$00,$C0,$F0,$3F,$1F,$0F,$3D,$AE
        .byte   $58,$07,$D8,$F9,$00,$04,$F9,$51,$A7,$FF,$F8,$F9,$00,$14,$F9,$02
        .byte   $1D,$62,$8C,$90,$90,$90,$48,$02,$1F,$7E,$FC,$F0,$F0,$F0,$78,$34
        .byte   $24,$34,$28,$42,$8D,$9D,$8A,$2C,$3C,$2C,$34,$FF,$F3,$E3,$F7,$44
        .byte   $EF,$98,$B4,$DC,$B4,$7C,$7E,$FF,$DF,$E8,$FC,$EC,$CC,$6C,$3A,$BA
        .byte   $92,$7C,$54,$54,$54,$38,$38,$FE,$FE,$44,$6C,$6C,$6C,$28,$28,$38
        .byte   $28,$10,$F9,$00,$05,$F9,$28,$38,$10,$F9,$00,$05,$F9,$78,$DC,$B4
        .byte   $FE,$FE,$BA,$92,$7C,$78,$EC,$CC,$EE,$BA,$FE,$FE,$C7,$54,$54,$57
        .byte   $F8,$38,$38,$28,$10,$EF,$EF,$EF,$E8,$28,$28,$38,$10,$F9,$00,$07
        .byte   $F9,$02,$F9,$00,$06,$F9,$03,$1D,$0F,$70,$80,$F9,$00,$05,$F9,$7F
        .byte   $F0,$80,$F9,$00,$0B,$F9,$58,$AE,$F9,$00,$05,$F9,$F0,$A6,$51,$C2
        .byte   $3E,$01,$F9,$00,$05,$F9,$FD,$3F,$01,$F9,$00,$05,$F9,$F9,$F3,$F5
        .byte   $F3,$00,$04,$F3,$03,$02,$02,$1F,$00,$00,$07,$1F,$3D,$7F,$FF,$FF
        .byte   $62,$82,$02,$01,$01,$00,$00,$00,$FF,$FF,$FF,$7F,$1F,$01,$00,$00
        .byte   $00,$21,$50,$B4,$1D,$4B,$1E,$F6,$0F,$7E,$EF,$EB,$FF,$B7,$EF,$FB
        .byte   $92,$0B,$23,$05,$01,$81,$07,$01,$6F,$F6,$DD,$FB,$FF,$FF,$1F,$03
        .byte   $00,$00,$01,$01,$01,$03,$15,$0F,$01,$01,$00,$02,$06,$0C,$3A,$FC
        .byte   $2B,$1B,$65,$8B,$D7,$9F,$AB,$D7,$DF,$F4,$FA,$F4,$A8,$E0,$D4,$68
        .byte   $37,$39,$57,$0B,$42,$71,$78,$3E,$E8,$DE,$AC,$F7,$FD,$FE,$CF,$E5
        .byte   $0E,$E4,$7F,$3F,$1F,$1F,$0F,$00,$FF,$5B,$C9,$6D,$7F,$37,$13,$0F
        .byte   $F3,$00,$04,$F3,$06,$05,$05,$12,$00,$00,$00,$01,$05,$0E,$3E,$6F
        .byte   $2B,$22,$0B,$5F,$38,$00,$00,$00,$57,$DD,$F7,$BC,$74,$60,$00,$00
        .byte   $00,$04,$14,$A2,$52,$4B,$13,$47,$00,$07,$2F,$5F,$AF,$B7,$EF,$BA
        .byte   $9F,$FF,$F0,$F3,$00,$05,$F3,$FE,$E2,$F3,$00,$06,$F3,$8B,$67,$F9
        .byte   $7E,$3C,$00,$E4,$7F,$7C,$FF,$DE,$C7,$FF,$FF,$DB,$C9,$3F,$3F,$3F
        .byte   $1F,$1F,$0F,$00,$00,$ED,$7F,$7F,$7F,$37,$13,$0F,$F3,$00,$04,$F3
        .byte   $05,$0F,$3F,$7F,$FF,$00,$00,$03,$1F,$7E,$F0,$C0,$C0,$FD,$7F,$7F
        .byte   $3D,$1F,$07,$00,$00,$C2,$C0,$00,$02,$F3,$00,$05,$F3,$07,$7F,$FF
        .byte   $FB,$DD,$F6,$6F,$0F,$3E,$F8,$C0,$04,$22,$09,$90,$BB,$EF,$B6,$FF
        .byte   $6B,$EF,$7E,$0F,$44,$10,$49,$00,$94,$10,$01,$00,$0C,$0F,$3F,$3F
        .byte   $1C,$04,$B9,$FF,$03,$3B,$0F,$6B,$7B,$FB,$FF,$E7,$E5,$CF,$FE,$FD
        .byte   $F6,$F8,$F6,$F8,$FA,$70,$21,$52,$29,$57,$29,$17,$68,$D4,$E0,$A8
        .byte   $74,$DA,$F4,$D6,$97,$2B,$1F,$57,$8B,$25,$0B,$29,$FC,$3A,$0C,$06
        .byte   $02,$00,$01,$01,$03,$05,$03,$01,$01,$01,$00,$00,$F3,$F3,$09,$0D
        .byte   $03,$05,$F2,$79,$FE,$F9,$F0,$00,$FD,$FA,$2D,$27,$FF,$56,$5F,$FF
        .byte   $21,$03,$02,$04,$04,$00,$00,$00,$5F,$3F,$1F,$0F,$07,$07,$03,$09
        .byte   $00,$06,$09,$05,$0A,$05,$00,$00,$00,$03,$07,$0A,$15,$3B,$0B,$17
        .byte   $0E,$3C,$FE,$BB,$F3,$61,$37,$6F,$7F,$FF,$DF,$DE,$FF,$FF,$03,$17
        .byte   $0B,$57,$2C,$1C,$FF,$FF,$01,$0B,$F7,$AE,$DF,$FF,$7F,$FF,$CF,$95
        .byte   $2E,$55,$2C,$16,$AF,$1D,$FF,$EE,$D5,$AE,$D7,$EF,$5F,$FB,$E0,$95
        .byte   $8A,$51,$80,$3C,$FA,$F5,$C0,$EA,$75,$AE,$78,$FA,$FC,$EA,$AA,$55
        .byte   $BB,$5F,$AA,$5D,$8A,$FD,$75,$BA,$5D,$BE,$5D,$AA,$FD,$FB,$00,$40
        .byte   $AA,$09,$00,$06,$09,$A0,$55,$00,$00,$03,$06,$0E,$80,$20,$A0,$44
        .byte   $C8,$D8,$B0,$F0,$1C,$BC,$BC,$F8,$F8,$B8,$F8,$E8,$03,$E5,$72,$5D
        .byte   $06,$8D,$F8,$E0,$FD,$9A,$3D,$0F,$07,$06,$57,$5F,$20,$01,$21,$11
        .byte   $0B,$02,$02,$00,$DF,$7F,$5F,$2F,$17,$1F,$07,$01,$B2,$E5,$CA,$8F
        .byte   $FE,$FD,$F8,$9D,$FD,$FA,$F5,$FF,$FD,$FE,$DF,$FA,$8E,$DD,$8E,$57
        .byte   $A2,$01,$03,$54,$FD,$AE,$75,$AA,$5F,$FF,$FD,$A8,$BB,$77,$FE,$D5
        .byte   $EA,$71,$A8,$74,$75,$EB,$7D,$EA,$D5,$EE,$76,$B8,$B8,$18,$20,$09
        .byte   $00,$05,$09,$50,$F8,$D0,$E0,$C0,$80,$00,$00,$B0,$D0,$D8,$C8,$EC
        .byte   $24,$00,$04,$F8,$BC,$FC,$FC,$DC,$BC,$1C,$1A,$02,$09,$00,$06,$09
        .byte   $01,$0C,$0E,$06,$06,$02,$03,$01,$00,$00,$40,$AA,$09,$00,$06,$09
        .byte   $A0,$55,$00,$18,$10,$10,$30,$80,$40,$C0,$50,$A0,$A0,$A0,$C0,$30
        .byte   $09,$F0,$03,$E0,$04,$09,$C0,$E0,$A0,$A0,$B0,$10,$10,$00,$F0,$B0
        .byte   $F0,$F0,$D0,$F0,$30,$30,$09,$00,$08,$30,$03,$10,$02,$18,$01,$08
        .byte   $05,$09,$14,$2A,$1C,$2A,$1C,$00,$00,$14,$08,$14,$22,$14,$22,$2A
        .byte   $1C,$08,$08,$6B,$7F,$2A,$6B,$14,$22,$77,$36,$77,$36,$77,$77,$08
        .byte   $14,$3E,$14,$22,$77,$7F,$3E,$36,$2A,$14,$6A,$5D,$49,$36,$6B,$1E
        .byte   $00,$00,$28,$14,$08,$10,$08,$7F,$3E,$3E,$16,$08,$14,$0C,$00,$08
        .byte   $14,$3E,$14,$3E,$7F,$7F,$7F,$36,$2A,$14,$6A,$55,$5D,$7F,$2A,$3F
        .byte   $1C,$00,$28,$14,$08,$10,$08,$62,$3E,$3E,$16,$08,$14,$0C,$00,$10
        .byte   $10,$10,$68,$B4,$58,$54,$48,$00,$00,$28,$50,$E8,$74,$78,$7C,$4C
        .byte   $48,$4C,$68,$74,$34,$34,$6C,$78,$7C,$FE,$FC,$09,$FE,$04,$09,$4C
        .byte   $5C,$54,$54,$74,$6C,$6C,$4C,$FE,$F6,$FE,$FE,$EE,$FE,$FE,$FE,$4C
        .byte   $48,$50,$54,$58,$90,$A8,$D0,$FE,$FC,$7C,$78,$70,$F8,$F0,$C0,$09
        .byte   $09,$FB,$FD,$00,$10,$28,$10,$44,$7C,$00,$38,$10,$38,$38,$28,$7C
        .byte   $6C,$38,$28,$18,$00,$54,$38,$00,$10,$BA,$FE,$38,$38,$6C,$7C,$FE
        .byte   $EE,$C6,$FE,$38,$00,$7C,$D6,$92,$00,$38,$28,$C6,$FE,$FE,$EE,$EE
        .byte   $FE,$7C,$3C,$10,$38,$10,$10,$38,$10,$10,$10,$28,$38,$28,$28,$38
        .byte   $28,$FB,$00,$04,$FB,$01,$07,$0E,$01,$00,$00,$00,$01,$07,$1D,$FF
        .byte   $1F,$00,$00,$00,$01,$06,$05,$09,$F3,$1F,$26,$01,$06,$1F,$7B,$77
        .byte   $FF,$EF,$DF,$00,$80,$C0,$90,$D0,$F0,$18,$28,$20,$60,$C0,$F0,$F8
        .byte   $FC,$7C,$DC,$D8,$70,$70,$D0,$A0,$C0,$00,$80,$FC,$FC,$F8,$F0,$C0
        .byte   $C0,$C0,$40,$37,$3E,$73,$0D,$04,$03,$03,$00,$CF,$CF,$7F,$73,$1B
        .byte   $0D,$07,$01,$10,$00,$20,$60,$20,$18,$16,$03,$1C,$32,$42,$64,$10
        .byte   $28,$1B,$06,$C0,$80,$40,$A0,$A0,$E0,$60,$70,$C0,$40,$A0,$E0,$E0
        .byte   $F0,$F8,$BC,$14,$38,$08,$0A,$0E,$10,$70,$50,$7C,$3E,$FB,$1E,$04
        .byte   $FB,$7C,$F8,$FB,$FB,$FB,$FD,$18,$28,$50,$50,$70,$50,$50,$A8,$18
        .byte   $38,$FB,$70,$05,$FB,$D8,$B8,$E8,$A4,$94,$9A,$7E,$4D,$25,$F8,$D8
        .byte   $DC,$EC,$FE,$66,$73,$3B,$17,$1E,$0B,$09,$06,$04,$05,$02,$1F,$19
        .byte   $0C,$0F,$07,$07,$06,$03,$03,$02,$02,$03,$02,$02,$07,$05,$FB,$03
        .byte   $06,$FB,$07,$06,$80,$40,$20,$E0,$B0,$D0,$68,$E8,$80,$C0,$E0,$E0
        .byte   $70,$30,$98,$F8,$78,$C8,$E8,$E8,$78,$C8,$E8,$E8,$98,$38,$D8,$38
        .byte   $98,$38,$D8,$38,$05,$0B,$0F,$0F,$1F,$27,$3E,$6E,$06,$0F,$0C,$0F
        .byte   $18,$38,$3D,$73,$5E,$5B,$7D,$FA,$FE,$B2,$FA,$FA,$63,$67,$43,$FE
        .byte   $86,$CE,$86,$FE,$D0,$D0,$D0,$E0,$A0,$C0,$C0,$80,$30,$B0,$70,$60
        .byte   $E0,$C0,$C0,$80,$80,$FB,$00,$07,$FB,$80,$FB,$00,$07,$FB,$F6,$BA
        .byte   $F2,$BA,$FA,$FF,$9B,$79,$8E,$C6,$8E,$C6,$BE,$C7,$E7,$47,$5E,$2D
        .byte   $3F,$26,$13,$17,$19,$14,$7F,$33,$20,$39,$1C,$1F,$1E,$1B,$FB,$00
        .byte   $10,$FB,$80,$C0,$40,$A0,$20,$D0,$70,$10,$80,$C0,$C0,$60,$E0,$F0
        .byte   $F0,$F0,$11,$07,$0E,$1C,$0C,$0C,$36,$23,$FB,$1F,$04,$FB,$0F,$3F
        .byte   $47,$43,$20,$20,$20,$10,$10,$08,$06,$01,$40,$40,$40,$20,$20,$10
        .byte   $08,$06,$C0,$F0,$38,$DC,$D8,$D8,$3C,$E6,$F8,$FC,$FC,$3C,$F8,$FC
        .byte   $F2,$E1,$02,$02,$02,$06,$04,$0C,$18,$20,$FB,$01,$04,$FB,$02,$02
        .byte   $04,$18,$FB,$FB,$01,$02,$00,$00,$00,$18,$28,$44,$DA,$29,$00,$00
        .byte   $00,$10,$3C,$66,$93,$BD,$44,$82,$99,$2C,$43,$C0,$00,$00,$26,$C3
        .byte   $D5,$3F,$63,$80,$80,$01,$00,$04,$01,$28,$66,$CA,$97,$C1,$00,$00
        .byte   $00,$30,$78,$F4,$E8,$FE,$8D,$C3,$CB,$FE,$7E,$7C,$18,$00,$F2,$FC
        .byte   $F4,$FC,$66,$7C,$18,$00,$20,$00,$38,$10,$50,$A0,$20,$20,$00,$70
        .byte   $70,$58,$D8,$D0,$F0,$B0,$38,$50,$60,$40,$50,$20,$20,$20,$30,$98
        .byte   $C0,$60,$60,$30,$30,$30,$01,$01,$07,$09,$07,$00,$05,$07,$01,$00
        .byte   $01,$07,$00,$05,$01,$02,$02,$02,$07,$03,$01,$02,$01,$08,$0C,$03
        .byte   $03,$03,$02,$05,$06,$0F,$0F,$0F,$00,$10,$60,$30,$60,$D0,$60,$40
        .byte   $18,$20,$50,$F0,$90,$B0,$F0,$B0,$A0,$90,$60,$80,$40,$B0,$C0,$80
        .byte   $50,$F0,$F0,$70,$B0,$70,$F0,$F8,$05,$12,$1D,$0C,$0F,$03,$16,$3A
        .byte   $1A,$1D,$1A,$1F,$37,$7C,$29,$7D,$FF,$BB,$3E,$16,$6D,$C9,$89,$80
        .byte   $7F,$BF,$35,$2D,$5F,$AF,$CD,$C4,$50,$80,$38,$70,$D0,$A0,$A0,$4C
        .byte   $AC,$78,$D8,$F8,$EC,$5C,$5E,$BC,$FA,$6D,$A6,$FE,$8C,$04,$00,$00
        .byte   $FC,$BE,$FB,$BB,$CE,$C6,$80,$00,$07,$07,$FD,$FE,$00,$0F,$2D,$5A
        .byte   $44,$70,$18,$26,$00,$0F,$3A,$65,$7B,$6F,$7F,$5F,$03,$E7,$1C,$0A
        .byte   $05,$06,$02,$00,$FF,$FF,$FF,$FB,$7D,$3F,$3E,$0C,$FD,$00,$04,$FD
        .byte   $4B,$36,$0C,$03,$00,$00,$00,$78,$76,$3D,$0F,$03,$01,$00,$00,$01
        .byte   $01,$00,$00,$07,$01,$00,$00,$01,$02,$07,$0F,$1F,$00,$00,$03,$05
        .byte   $0F,$AD,$5A,$44,$01,$01,$03,$06,$8F,$7A,$E5,$FB,$70,$B8,$68,$8B
        .byte   $4C,$70,$C0,$00,$EF,$DF,$9F,$FF,$FC,$F0,$C0,$00,$FD,$FD,$FA,$FD
        .byte   $00,$00,$00,$01,$0B,$13,$17,$27,$01,$07,$0F,$0F,$17,$0F,$2F,$1F
        .byte   $4F,$6F,$4F,$5F,$9F,$DF,$9E,$DE,$3F,$1F,$3F,$BF,$7F,$3F,$7F,$3F
        .byte   $00,$40,$C0,$80,$80,$80,$00,$00,$C0,$E0,$E0,$C0,$C0,$C1,$81,$81
        .byte   $00,$00,$02,$02,$00,$04,$04,$08,$83,$83,$85,$85,$8F,$8B,$9B,$17
        .byte   $9E,$CE,$8E,$CE,$87,$46,$06,$02,$7F,$3F,$7F,$3F,$7F,$BF,$7F,$7F
        .byte   $03,$01,$00,$00,$03,$00,$00,$00,$3F,$3F,$1F,$1F,$07,$03,$01,$00
        .byte   $08,$18,$10,$FA,$00,$05,$FA,$37,$27,$6F,$7E,$FE,$FE,$FC,$FC,$00
        .byte   $80,$F0,$00,$80,$98,$27,$4C,$F8,$F0,$F0,$E0,$C0,$9F,$FF,$FF,$FA
        .byte   $00,$0F,$FA,$1C,$08,$04,$03,$09,$04,$1A,$E4,$32,$0F,$07,$0B,$0F
        .byte   $07,$FB,$FC,$FF,$FA,$00,$13,$FA,$80,$60,$70,$D0,$40,$00,$C0,$E0
        .byte   $F0,$D8,$EC,$BC,$F0,$FA,$00,$04,$FA,$01,$07,$0F,$08,$00,$00,$00
        .byte   $03,$0E,$18,$70,$77,$14,$08,$FA,$00,$05,$FA,$07,$EB,$F7,$FF,$FF
        .byte   $7F,$3F,$0F,$07,$00,$00,$07,$36,$D0,$43,$1F,$3D,$00,$07,$F8,$C9
        .byte   $2F,$BF,$FF,$FE,$7A,$C0,$C0,$C0,$60,$3F,$37,$AC,$F5,$FA,$FF,$06
        .byte   $FA,$BF,$00,$A0,$78,$2F,$00,$FE,$FF,$54,$00,$58,$87,$D0,$FF,$FF
        .byte   $FF,$AB,$00,$00,$01,$07,$00,$09,$E4,$32,$FF,$FF,$FF,$F7,$03,$F9
        .byte   $FC,$FF,$FA,$00,$04,$FA,$80,$00,$E0,$7F,$00,$00,$00,$C0,$70,$FC
        .byte   $FF,$FF,$00,$00,$C0,$00,$60,$F0,$50,$40,$FC,$C0,$C0,$E0,$98,$EC
        .byte   $3C,$F0,$00,$01,$00,$0A,$15,$26,$41,$51,$00,$0D,$0F,$3D,$76,$E7
        .byte   $CD,$FF,$0A,$17,$21,$C8,$17,$20,$00,$00,$7D,$76,$EF,$DF,$37,$60
        .byte   $00,$01,$C9,$99,$A9,$AC,$97,$8B,$CA,$C1,$FE,$EF,$DF,$DF,$EF,$F7
        .byte   $F5,$FE,$C0,$60,$E0,$B0,$18,$4C,$B3,$40,$FF,$FF,$FF,$BF,$3F,$3F
        .byte   $73,$C0,$93,$95,$95,$35,$E9,$D1,$A3,$43,$7F,$FB,$FB,$FB,$F7,$EF
        .byte   $5F,$BF,$03,$06,$07,$0C,$1F,$37,$CA,$00,$FF,$FF,$FE,$FF,$FF,$FB
        .byte   $CC,$04,$00,$80,$A0,$50,$88,$20,$50,$90,$00,$80,$D0,$A0,$70,$F8
        .byte   $DC,$FC,$48,$88,$48,$A0,$20,$D0,$10,$08,$BC,$7C,$FC,$F8,$F8,$F8
        .byte   $3C,$1C,$FA,$FA,$0C,$12,$87,$C9,$B1,$96,$9E,$DA,$AA,$4C,$87,$CF
        .byte   $FF,$FA,$F6,$BE,$DE,$FC,$F8,$E0,$C4,$6A,$EF,$BC,$F4,$D0,$7C,$7E
        .byte   $FA,$96,$1F,$7F,$FB,$EF,$00,$01,$33,$4A,$86,$74,$4D,$25,$00,$01
        .byte   $33,$7B,$FF,$7F,$7E,$3F,$1F,$0B,$09,$0D,$0E,$17,$13,$15,$1F,$0F
        .byte   $0F,$0A,$0D,$1E,$1F,$1B,$38,$E4,$A2,$42,$A1,$41,$A1,$41,$38,$FC
        .byte   $DE,$BE,$5F,$BF,$5F,$BF,$81,$41,$81,$01,$81,$01,$01,$05,$7F,$BF
        .byte   $7F,$FF,$7F,$FF,$FF,$FB,$A0,$D7,$FF,$FB,$E6,$8D,$5A,$9D,$5F,$2F
        .byte   $1F,$FF,$FF,$7E,$BD,$72,$BA,$F5,$6A,$F5,$EA,$75,$AA,$D5,$75,$6A
        .byte   $F5,$CA,$95,$8A,$55,$2A,$02,$0F,$DD,$F7,$73,$B3,$79,$DA,$0D,$08
        .byte   $DE,$FF,$FD,$7C,$BE,$3D,$7D,$BD,$77,$EB,$5F,$BD,$5E,$BF,$8E,$46
        .byte   $8E,$17,$A3,$42,$A1,$40,$00,$03,$04,$08,$08,$08,$11,$10,$00,$03
        .byte   $07,$0F,$0F,$0F,$1E,$1F,$11,$10,$11,$10,$91,$60,$A1,$60,$1E,$1F
        .byte   $1E,$1F,$9E,$7F,$BE,$7F,$07,$0B,$2B,$56,$26,$CC,$9C,$38,$FB,$F7
        .byte   $D7,$AF,$DF,$3E,$7E,$FC,$70,$F0,$A0,$C0,$80,$00,$00,$00,$FC,$E8
        .byte   $D0,$01,$01,$06,$38,$C0,$EA,$54,$AA,$D4,$A8,$54,$AB,$DF,$15,$AB
        .byte   $55,$2B,$57,$AB,$54,$20,$FC,$83,$FF,$FF,$5E,$64,$F4,$98,$03,$0C
        .byte   $FF,$04,$0C,$DC,$EE,$9F,$5D,$BB,$5F,$BD,$7F,$AD,$5F,$99,$A2,$44
        .byte   $A0,$42,$80,$52,$A0,$66,$E6,$1F,$FF,$3E,$15,$2D,$2A,$11,$1F,$FF
        .byte   $FF,$FF,$6E,$1E,$FB,$11,$A0,$E0,$E1,$E8,$39,$14,$0F,$0B,$BF,$FF
        .byte   $FE,$F7,$36,$1B,$18,$1C,$04,$07,$01,$0C,$00,$05,$4F,$02,$0C,$27
        .byte   $21,$18,$07,$00,$00,$0C,$0C,$08,$09,$00,$3C,$73,$9A,$AD,$9A,$65
        .byte   $1D,$00,$3C,$7F,$FD,$DA,$EB,$7D,$1D,$00,$01,$01,$01,$03,$02,$02
        .byte   $08,$01,$05,$03,$03,$01,$01,$00,$03,$80,$02,$C0,$02,$A0,$01,$00
        .byte   $03,$80,$02,$C0,$02,$08,$60,$A0,$50,$B0,$20,$D0,$50,$B0,$D0,$60
        .byte   $F0,$D0,$E0,$F0,$B0,$70,$F0,$01,$02,$04,$05,$0D,$16,$26,$23,$03
        .byte   $07,$07,$06,$0E,$1D,$3F,$3F,$25,$57,$5A,$4F,$4C,$AB,$A6,$9F,$3A
        .byte   $78,$7D,$7F,$73,$F4,$F9,$F0,$58,$28,$A8,$28,$5C,$74,$E4,$84,$F8
        .byte   $F8,$78,$F8,$08,$FC,$04,$08,$0A,$9A,$72,$C2,$82,$05,$D9,$71,$FE
        .byte   $7E,$FE,$FE,$7E,$FF,$3F,$FF,$8F,$80,$CA,$B7,$9F,$0D,$97,$FF,$FF
        .byte   $FF,$F5,$E8,$FF,$F2,$E8,$E0,$55,$CF,$7A,$B7,$6B,$EA,$46,$38,$FA
        .byte   $FF,$F7,$7A,$FD,$DE,$7C,$38,$C3,$05,$49,$B1,$C1,$41,$8A,$A6,$FF
        .byte   $FF,$BF,$7F,$FF,$BF,$76,$5F,$7A,$C3,$C4,$5E,$F5,$BA,$E6,$01,$BF
        .byte   $FF,$7C,$FE,$7B,$FF,$67,$01,$04,$04,$0A,$17,$2A,$1F,$04,$3A,$00
        .byte   $0E,$1F,$3D,$7B,$3B,$1E,$3B,$56,$F8,$C9,$86,$91,$A6,$8A,$B2,$6E
        .byte   $F6,$FF,$FF,$ED,$DE,$FE,$DE,$96,$B2,$96,$92,$94,$94,$10,$10,$FA
        .byte   $DE,$FA,$FE,$FC,$FC,$78,$30,$08,$00,$10,$08,$30,$C0,$00,$06,$B8
        .byte   $E0,$04,$C8,$3C,$B0,$C6,$9E,$D8,$E4,$CC,$BA,$72,$84,$C8,$70,$C0
        .byte   $A0,$68,$98,$F6,$4C,$B8,$70,$C0,$60,$D8,$E8,$58,$74,$4A,$85,$ED
        .byte   $95,$93,$AD,$78,$7C,$76,$FB,$F3,$FB,$FD,$DB,$DB,$DB,$A5,$A5,$A3
        .byte   $A3,$42,$00,$BD,$BD,$E7,$E7,$E3,$E3,$42,$00,$08,$08,$05,$0A,$05
        .byte   $00,$07,$01,$01,$00,$04,$05,$01,$00,$08,$1F,$01,$04,$06,$13,$19
        .byte   $0F,$03,$09,$07,$17,$3F,$5F,$1F,$0F,$35,$77,$00,$00,$00,$04,$01
        .byte   $01,$11,$9B,$01,$03,$02,$03,$C6,$C7,$FF,$FF,$8F,$DE,$F8,$E7,$CF
        .byte   $CF,$9F,$9F,$FF,$FF,$FF,$FB,$F4,$FE,$F3,$F7,$00,$00,$00,$80,$C0
        .byte   $88,$1D,$29,$00,$08,$10,$B1,$F3,$EF,$FF,$DF,$8A,$FC,$1E,$C7,$EA
        .byte   $F3,$F9,$FD,$FD,$FF,$FF,$FF,$F7,$9F,$DF,$EB,$05,$00,$07,$10,$01
        .byte   $00,$03,$05,$80,$00,$10,$18,$28,$80,$C0,$C0,$10,$50,$D0,$96,$FC
        .byte   $F0,$E0,$F1,$F3,$BE,$AE,$EE,$FC,$01,$1F,$03,$00,$00,$0D,$07,$00
        .byte   $9F,$1F,$03,$3F,$7F,$8F,$07,$03,$02,$00,$01,$05,$00,$05,$05,$01
        .byte   $0F,$1F,$05,$00,$05,$05,$BF,$9F,$CF,$4F,$65,$F8,$1F,$93,$DF,$F9
        .byte   $FB,$F7,$FB,$FF,$FF,$7F,$65,$E7,$02,$05,$00,$05,$05,$FB,$FF,$3B
        .byte   $33,$31,$30,$10,$00,$F9,$FD,$E3,$E2,$CF,$5C,$FE,$F3,$CF,$7B,$3F
        .byte   $FF,$F6,$BF,$FF,$EF,$34,$10,$30,$05,$00,$05,$FA,$01,$F6,$02,$05
        .byte   $84,$8C,$80,$00,$00,$30,$30,$90,$60,$38,$A0,$60,$00,$F0,$D6,$EF
        .byte   $FC,$F8,$60,$E0,$E0,$80,$05,$00,$07,$05,$F0,$30,$18,$05,$00,$05
        .byte   $05,$05,$F6,$F8,$FF,$FF,$F7,$E7,$CB,$D3,$E3,$C3,$60,$8E,$3E,$7E
        .byte   $7E,$FE,$FE,$FE,$E3,$F3,$DB,$CF,$E7,$F7,$FF,$FF,$FE,$FE,$FE,$7E
        .byte   $3E,$DE,$EE,$F0,$80,$40,$20,$38,$30,$08,$0D,$0F,$00,$80,$40,$20
        .byte   $0C,$36,$1B,$0F,$3F,$03,$07,$1E,$25,$4C,$88,$1C,$00,$3C,$78,$7F
        .byte   $7B,$F3,$F7,$E3,$1F,$62,$C1,$42,$46,$44,$48,$F0,$00,$1D,$3E,$BD
        .byte   $B9,$BB,$B7,$FF,$FE,$7F,$0F,$01,$00,$80,$40,$20,$7F,$8F,$F1,$FE
        .byte   $F6,$FF,$04,$F6,$E0,$1C,$03,$F6,$00,$06,$F6,$E0,$FC,$F6,$FF,$05
        .byte   $F6,$03,$86,$CD,$F3,$77,$37,$1A,$ED,$FF,$FD,$FB,$7F,$BF,$DF,$EF
        .byte   $FF,$00,$00,$00,$C0,$20,$20,$20,$72,$F6,$00,$04,$F6,$C0,$C0,$F0
        .byte   $B8,$DD,$6E,$BB,$D5,$AB,$74,$97,$9F,$FE,$FB,$FD,$FE,$DF,$8F,$6F
        .byte   $FE,$2E,$5D,$3E,$39,$31,$51,$97,$0E,$D1,$BE,$7F,$77,$2F,$3F,$7F
        .byte   $CF,$0D,$02,$04,$06,$03,$04,$08,$10,$1E,$0D,$07,$07,$0F,$1A,$34
        .byte   $08,$13,$0C,$8D,$4B,$8B,$CB,$65,$B4,$FF,$FF,$7F,$BF,$FF,$FF,$FF
        .byte   $7F,$1A,$19,$4C,$9C,$3C,$7C,$38,$11,$FF,$FF,$BF,$7F,$FF,$7F,$7F
        .byte   $3F,$76,$F9,$F7,$F7,$FA,$E6,$12,$8A,$9F,$EF,$EF,$EF,$C7,$9B,$EF
        .byte   $F7,$42,$26,$9E,$FF,$73,$13,$FB,$CF,$F6,$FF,$07,$F6,$CF,$03,$0F
        .byte   $21,$20,$1C,$7E,$7B,$3A,$03,$31,$7E,$FF,$FF,$BF,$BF,$DF,$1E,$17
        .byte   $10,$10,$3C,$7E,$47,$05,$E7,$78,$7F,$7F,$7F,$47,$3D,$7E,$CC,$B6
        .byte   $FA,$7C,$1C,$0E,$8C,$EC,$F4,$FA,$7C,$9E,$EC,$FC,$FE,$FE,$B4,$AC
        .byte   $EC,$3C,$1C,$0C,$8C,$4C,$FE,$FE,$3E,$DE,$EE,$FE,$FE,$FE,$04,$04
        .byte   $04,$02,$09,$08,$08,$08,$7F,$7F,$3F,$3F,$F6,$37,$04,$F6,$0C,$04
        .byte   $04,$07,$04,$0E,$06,$02,$13,$1B,$1B,$1B,$1F,$19,$09,$0D,$EC,$7C
        .byte   $5C,$6C,$5C,$EC,$5C,$4C,$7E,$DE,$EE,$F6,$FE,$05,$F6,$6C,$5C,$4C
        .byte   $6C,$DC,$4C,$2C,$1C,$F6,$FE,$08,$03,$03,$F6,$02,$01,$01,$01,$00
        .byte   $0C,$0C,$04,$05,$06,$06,$06,$03,$F6,$00,$08,$03,$03,$01,$05,$0C
        .byte   $05,$F6,$8C,$0C,$8C,$F6,$FE,$05,$F6,$7E,$FE,$7E,$8C,$8C,$8C,$CC
        .byte   $CC,$8C,$4C,$4C,$7E,$7E,$7E,$3E,$3E,$7E,$BE,$BE,$4C,$FC,$FC,$EE
        .byte   $32,$10,$10,$00,$BE,$0E,$72,$DC,$4E,$6E,$6E,$3E,$10,$10,$F6,$00
        .byte   $06,$F6,$2E,$2E,$3E,$1E,$1E,$1E,$0E,$0E,$F6,$F6,$02,$06,$01,$03
        .byte   $07,$E7,$FE,$CE,$66,$36,$00,$00,$00,$60,$39,$39,$1D,$0D,$1A,$0F
        .byte   $67,$03,$0B,$13,$2D,$30,$05,$04,$1A,$E1,$04,$0E,$1C,$30,$80,$C0
        .byte   $C0,$C3,$6A,$74,$64,$68,$80,$C0,$C0,$C3,$E6,$EC,$FC,$F8,$7E,$38
        .byte   $F0,$78,$30,$E8,$E4,$60,$F8,$F6,$F8,$F8,$EC,$66,$22,$20,$02,$02
        .byte   $01,$05,$04,$0E,$1D,$38,$70,$A0,$C0,$E0,$07,$0F,$1E,$3F,$7F,$FF
        .byte   $FF,$FF,$D8,$BC,$7F,$3F,$1E,$0C,$04,$02,$FF,$FF,$7F,$3F,$1F,$0F
        .byte   $07,$03,$00,$70,$F8,$3C,$1E,$0C,$08,$08,$C0,$80,$00,$C0,$E0,$F3
        .byte   $F7,$F7,$14,$22,$C7,$CE,$7C,$38,$30,$60,$EB,$DD,$38,$30,$80,$C0
        .byte   $C0,$80,$01,$01,$F5,$FA,$0E,$0E,$1C,$1C,$18,$38,$38,$1C,$0E,$06
        .byte   $F5,$00,$06,$F5,$0C,$3D,$71,$EE,$1F,$5E,$6F,$2C,$32,$63,$EF,$DD
        .byte   $FE,$FF,$5D,$3E,$F5,$00,$09,$F5,$07,$1F,$3F,$7F,$7F,$FF,$FF,$80
        .byte   $C1,$C3,$83,$03,$01,$00,$00,$7F,$3E,$3C,$7C,$FC,$7E,$3F,$07,$00
        .byte   $00,$00,$01,$18,$3C,$38,$03,$00,$00,$07,$1E,$27,$43,$C7,$FC,$07
        .byte   $07,$03,$03,$F5,$00,$04,$F5,$F8,$F8,$7C,$3C,$0F,$03,$00,$00,$00
        .byte   $03,$E1,$F5,$00,$05,$F5,$0F,$FC,$1E,$F5,$FF,$05,$F5,$80,$C0,$C7
        .byte   $8F,$0F,$07,$00,$00,$7F,$3F,$38,$70,$F0,$F8,$FF,$1F,$00,$F0,$E1
        .byte   $F5,$00,$05,$F5,$FC,$0F,$1E,$F5,$FF,$05,$F5,$07,$0F,$8F,$C7,$C0
        .byte   $80,$00,$00,$F8,$F0,$70,$38,$3F,$7F,$FE,$F0,$00,$00,$00,$E0,$30
        .byte   $00,$1E,$3C,$00,$C0,$F8,$1E,$CE,$FF,$E1,$C3,$1C,$80,$80,$F5,$00
        .byte   $05,$F5,$E2,$7E,$7C,$F8,$E0,$80,$00,$00,$1C,$78,$60,$C0,$C0,$EC
        .byte   $7D,$79,$0C,$08,$00,$00,$00,$1E,$07,$C7,$F6,$1F,$5E,$6F,$2C,$00
        .byte   $00,$00,$CD,$FE,$FF,$5D,$3E,$00,$00,$00,$01,$0F,$0F,$37,$3D,$21
        .byte   $1C,$6E,$01,$07,$07,$3B,$3A,$3F,$67,$5F,$D8,$87,$6F,$77,$36,$1B
        .byte   $00,$00,$EF,$FB,$B7,$BB,$5B,$6F,$3F,$03,$F0,$7C,$F9,$BB,$FD,$BD
        .byte   $C5,$6E,$3C,$FB,$77,$F7,$33,$D6,$FE,$FF,$6E,$0C,$75,$78,$FE,$7E
        .byte   $7C,$00,$DF,$F7,$BB,$BF,$7F,$FD,$9B,$FF,$00,$00,$80,$D0,$F8,$38
        .byte   $A0,$EC,$00,$80,$C0,$B0,$B8,$FC,$DC,$F2,$EC,$5C,$C8,$E0,$C0,$80
        .byte   $00,$00,$DA,$BA,$F4,$D8,$B8,$60,$E0,$00,$F5,$F5,$FD,$FF,$00,$00
        .byte   $00,$0A,$15,$0E,$17,$0B,$00,$00,$0F,$15,$2A,$31,$28,$34,$04,$01
        .byte   $FD,$00,$06,$FD,$1B,$1E,$0F,$03,$01,$FD,$00,$08,$FD,$80,$40,$80
        .byte   $00,$00,$00,$C0,$F0,$70,$B8,$7C,$B8,$78,$F8,$FE,$0F,$03,$00,$00
        .byte   $7C,$F8,$E0,$C0,$80,$FD,$00,$04,$FD,$17,$3E,$7F,$3F,$7F,$1F,$7F
        .byte   $03,$08,$01,$00,$40,$00,$E1,$83,$37,$2F,$37,$0F,$FD,$00,$04,$FD
        .byte   $CB,$57,$4F,$37,$0F,$FD,$00,$04,$FD,$80,$A0,$D0,$E8,$F8,$F8,$F8
        .byte   $C0,$70,$58,$2C,$14,$7C,$FC,$F8,$F8,$E8,$BC,$FE,$9E,$0E,$00,$00
        .byte   $F8,$D8,$C0,$E0,$80,$00,$00,$00,$FD,$FD,$FB,$FD,$00,$04,$48,$08
        .byte   $28,$23,$0E,$4B,$82,$42,$24,$65,$15,$16,$2B,$7E,$3A,$6E,$6F,$64
        .byte   $DB,$A5,$DB,$F7,$7F,$7F,$7F,$7B,$F4,$FA,$F4,$E8,$00,$82,$00,$92
        .byte   $10,$E2,$C0,$B4,$94,$14,$9A,$28,$A6,$C4,$AD,$F9,$AC,$FC,$F2,$0A
        .byte   $D8,$EB,$55,$AC,$FF,$FE,$FE,$F6,$2E,$17,$AB,$57,$A7,$8B,$D5,$AB
        .byte   $D5,$CB,$45,$7B,$F8,$F4,$EA,$F4,$EA,$F4,$7A,$64,$55,$3B,$2F,$3B
        .byte   $17,$1E,$0D,$03,$7A,$34,$38,$3C,$1C,$1F,$0E,$03,$55,$EC,$75,$AB
        .byte   $D5,$BB,$75,$AA,$AB,$17,$8B,$57,$2B,$47,$8B,$56,$52,$E8,$54,$BC
        .byte   $48,$18,$30,$80,$AE,$1C,$AC,$5C,$B8,$F8,$F0,$C0,$FB,$FB,$FD,$FE
        .byte   $FD,$00,$05,$FD,$21,$63,$E7,$FD,$00,$04,$FD,$01,$63,$E2,$BD,$E7
        .byte   $61,$22,$FD,$00,$05,$FD,$BE,$E3,$63,$FD,$00,$07,$FD,$20,$60,$A0
        .byte   $60,$21,$26,$00,$00,$20,$60,$E2,$E3,$E3,$FF,$27,$A3,$E3,$E1,$E0
        .byte   $40,$00,$00,$FF,$E2,$E2,$A1,$A0,$40,$00,$00,$20,$20,$60,$A0,$60
        .byte   $A1,$22,$24,$20,$60,$E2,$E2,$E3,$E3,$E3,$FF,$26,$23,$23,$21,$A0
        .byte   $E0,$E0,$40,$FF,$E3,$E2,$E1,$E0,$E0,$A0,$40,$FD,$FD,$FE,$FF,$00
        .byte   $0C,$12,$16,$0C,$03,$06,$05,$00,$0C,$1E,$1A,$0C,$03,$07,$07,$05
        .byte   $36,$4B,$58,$30,$00,$00,$00,$07,$37,$7B,$68,$30,$FE,$00,$05,$FE
        .byte   $18,$34,$34,$1B,$06,$05,$00,$00,$18,$2C,$2C,$1B,$07,$06,$05,$06
        .byte   $1B,$34,$24,$18,$00,$00,$06,$07,$1B,$2C,$3C,$18,$00,$00,$01,$03
        .byte   $02,$01,$00,$03,$66,$D5,$01,$02,$03,$01,$00,$03,$67,$B6,$95,$66
        .byte   $03,$00,$01,$03,$02,$01,$F6,$67,$03,$00,$01,$02,$03,$01,$FE,$FE
        .byte   $FA,$FC,$FA,$00,$04,$FA,$01,$03,$06,$0D,$FA,$00,$06,$FA,$01,$03
        .byte   $1A,$36,$6A,$5A,$3A,$5A,$5A,$5A,$07,$0D,$1D,$35,$75,$75,$35,$35
        .byte   $34,$3C,$74,$74,$37,$7D,$B7,$B3,$3C,$1C,$1C,$9C,$FF,$DF,$DF,$5E
        .byte   $B7,$BB,$B1,$B7,$97,$BA,$7D,$FB,$5F,$5F,$5F,$5E,$7F,$5F,$9F,$1F
        .byte   $58,$5A,$56,$5E,$5E,$5E,$5D,$5B,$37,$35,$39,$31,$31,$31,$33,$36
        .byte   $57,$5B,$5B,$3A,$7C,$78,$70,$60,$3C,$3C,$35,$66,$44,$08,$10,$20
        .byte   $AB,$CD,$F6,$BB,$7D,$EE,$E7,$D3,$FA,$7F,$04,$FA,$FE,$BB,$3D,$1A
        .byte   $D0,$90,$10,$10,$18,$18,$08,$08,$58,$98,$18,$18,$10,$10,$00,$00
        .byte   $0C,$0C,$1C,$14,$34,$2C,$6C,$4C,$04,$04,$04,$0C,$0C,$14,$14,$34
        .byte   $CC,$AC,$26,$27,$AF,$AF,$9D,$9C,$34,$54,$DC,$DC,$54,$56,$65,$64
        .byte   $14,$1C,$14,$14,$16,$3D,$37,$3A,$0C,$1C,$0C,$0C,$1E,$3F,$3F,$37
        .byte   $37,$1B,$35,$36,$D7,$EA,$ED,$EB,$3F,$1F,$3B,$7F,$7F,$3F,$3F,$FF
        .byte   $BC,$BC,$BC,$B8,$B8,$B8,$A8,$A8,$44,$44,$44,$48,$48,$48,$58,$58
        .byte   $98,$98,$B0,$B0,$60,$60,$C0,$C0,$68,$68,$50,$50,$A0,$A0,$40,$40
        .byte   $2B,$4D,$76,$3B,$3D,$2A,$25,$12,$7F,$7F,$7F,$3F,$3E,$3F,$3F,$1B
        .byte   $11,$10,$10,$10,$18,$18,$08,$08,$19,$18,$18,$18,$10,$10,$00,$00
        .byte   $FA,$10,$05,$FA,$18,$18,$14,$00,$00,$08,$08,$0C,$04,$06,$0A,$14
        .byte   $10,$14,$10,$10,$13,$17,$17,$0B,$0F,$0B,$0F,$0F,$0E,$0A,$0A,$14
        .byte   $1C,$14,$14,$16,$3D,$37,$33,$0C,$1C,$0C,$0C,$1E,$3F,$3F,$3E,$37
        .byte   $1B,$31,$37,$57,$EB,$EF,$EF,$3F,$1F,$3F,$7E,$FF,$3E,$3D,$7B,$17
        .byte   $14,$0C,$FA,$04,$05,$FA,$0B,$0B,$FA,$03,$06,$FA,$06,$06,$04,$04
        .byte   $02,$02,$FA,$01,$04,$FA,$03,$03,$01,$01,$00,$00,$AF,$4F,$77,$3B
        .byte   $3D,$6E,$27,$13,$FB,$7D,$7E,$3F,$3E,$7B,$3D,$1A,$FA,$10,$04,$FA
        .byte   $18,$18,$08,$08,$FA,$18,$04,$FA,$10,$10,$00,$00,$00,$FA,$08,$04
        .byte   $FA,$0C,$0A,$09,$00,$00,$04,$06,$07,$03,$05,$06,$08,$08,$09,$09
        .byte   $08,$08,$08,$09,$07,$07,$06,$06,$07,$07,$07,$06,$14,$1C,$14,$14
        .byte   $16,$3D,$37,$32,$0C,$1C,$0C,$0C,$1E,$BF,$FF,$FF,$37,$1B,$11,$36
        .byte   $57,$6B,$EF,$EF,$FF,$FF,$FF,$EF,$FF,$BE,$3D,$3B,$09,$05,$03,$03
        .byte   $FA,$02,$04,$FA,$06,$02,$00,$FA,$01,$05,$FA,$02,$01,$FA,$00,$06
        .byte   $FA,$01,$FA,$00,$07,$FA,$AF,$CF,$F7,$FB,$BD,$2E,$27,$92,$7B,$FD
        .byte   $FE,$FF,$FE,$FF,$FF,$7F,$98,$18,$98,$58,$38,$18,$08,$0C,$74,$F4
        .byte   $74,$34,$14,$14,$04,$00,$FA,$FA,$FD,$FF,$FD,$00,$05,$10,$03,$00
        .byte   $07,$FD,$7F,$3F,$10,$10,$10,$FD,$00,$04,$FD,$E0,$7F,$FD,$00,$0D
        .byte   $FD,$4C,$FD,$00,$07,$FD,$FC,$FE,$4C,$FD,$00,$06,$FD,$9A,$FC,$FD
        .byte   $00,$15,$FD,$01,$41,$36,$18,$08,$08,$04,$00,$00,$06,$19,$36,$78
        .byte   $30,$FD,$00,$08,$FD,$0C,$1C,$E8,$FD,$00,$05,$FD,$1C,$74,$98,$C0
        .byte   $FD,$00,$07,$FD,$E0,$80,$FD,$00,$0C,$FD,$01,$01,$FD,$00,$06,$FD
        .byte   $01,$03,$03,$42,$34,$18,$0C,$04,$02,$00,$04,$0D,$1B,$1E,$3C,$30
        .byte   $FD,$00,$05,$FD,$18,$38,$30,$40,$80,$00,$00,$00,$18,$68,$F0,$B0
        .byte   $60,$C0,$FD,$00,$07,$FD,$C0,$80,$FD,$00,$0D,$FD,$01,$FD,$00,$05
        .byte   $FD,$01,$01,$03,$01,$02,$22,$1C,$06,$02,$01,$00,$02,$05,$05,$0A
        .byte   $0E,$1C,$08,$00,$00,$00,$E0,$E0,$40,$80,$80,$80,$00,$00,$E0,$A0
        .byte   $E0,$40,$40,$80,$FD,$00,$11,$FD,$10,$38,$10,$10,$10,$38,$10,$00
        .byte   $10,$28,$38,$28,$28,$28,$38,$FD,$10,$04,$FD,$38,$D6,$00,$00,$FD
        .byte   $28,$05,$FD,$38,$38,$10,$FD,$FD,$FD,$FE,$FD,$00,$05,$FD,$10,$00
        .byte   $0F,$FD,$00,$04,$FD,$3C,$1F,$1E,$0F,$03,$01,$3F,$10,$FD,$00,$04
        .byte   $FD,$7D,$3E,$3F,$1F,$3E,$FD,$00,$08,$FD,$40,$00,$1C,$FD,$00,$05
        .byte   $FD,$80,$00,$74,$98,$80,$00,$40,$FD,$00,$04,$FD,$FF,$7C,$00,$80
        .byte   $FD,$00,$08,$FD,$01,$00,$01,$06,$FD,$00,$04,$FD,$02,$0E,$1F,$7F
        .byte   $08,$01,$06,$08,$FD,$00,$04,$FD,$0F,$1F,$3F,$0F,$03,$06,$FD,$00
        .byte   $06,$FD,$18,$30,$8C,$D8,$FD,$00,$04,$FD,$0E,$3C,$FC,$30,$00,$80
        .byte   $20,$FD,$00,$05,$FD,$80,$80,$C0,$C0,$FD,$00,$07,$FD,$01,$02,$00
        .byte   $05,$09,$FD,$00,$05,$FD,$04,$0F,$1F,$02,$05,$03,$06,$FD,$00,$04
        .byte   $FD,$2F,$07,$0F,$0F,$03,$02,$FD,$00,$05,$FD,$20,$48,$18,$90,$C8
        .byte   $00,$00,$04,$38,$78,$70,$F0,$40,$F0,$80,$FD,$00,$06,$FD,$D0,$E0
        .byte   $C0,$80,$FD,$00,$07,$FD,$04,$04,$00,$00,$09,$FD,$00,$05,$FD,$08
        .byte   $08,$1C,$09,$11,$01,$02,$02,$00,$00,$00,$1E,$3F,$2F,$07,$03,$02
        .byte   $02,$00,$00,$00,$10,$30,$30,$00,$88,$C8,$00,$10,$30,$70,$60,$E0
        .byte   $C0,$C0,$E0,$60,$40,$40,$FD,$00,$04,$FD,$B0,$B0,$E0,$E0,$40,$40
        .byte   $00,$00,$00,$01,$03,$03,$01,$10,$12,$07,$01,$FD,$03,$06,$FD,$13
        .byte   $0B,$0B,$0A,$08,$FD,$00,$04,$FD,$1E,$1E,$1F,$1D,$11,$01,$01,$00
        .byte   $00,$00,$80,$80,$00,$10,$90,$C0,$00,$80,$80,$00,$80,$80,$80,$90
        .byte   $80,$A0,$A0,$20,$FD,$00,$04,$FD,$D0,$F0,$F0,$70,$10,$00,$00,$00
        .byte   $FD,$FD,$FD,$FF,$00,$38,$56,$76,$F7,$E7,$CF,$CF,$00,$20,$78,$7C
        .byte   $FA,$FC,$FE,$FE,$ED,$F1,$F3,$76,$44,$28,$00,$00,$F6,$FE,$FE,$7C
        .byte   $7A,$30,$00,$00,$00,$38,$6E,$5E,$FB,$F7,$E7,$E7,$00,$20,$58,$78
        .byte   $FC,$FA,$DE,$DE,$F7,$FB,$D9,$5A,$60,$28,$00,$00,$FA,$FC,$FE,$7C
        .byte   $7E,$30,$00,$00,$00,$38,$6E,$5E,$DD,$FB,$F3,$F7,$00,$20,$78,$7C
        .byte   $FE,$EC,$FE,$FA,$E7,$D7,$AD,$4E,$66,$28,$00,$00,$FC,$EE,$FE,$7C
        .byte   $58,$30,$00,$00,$00,$38,$4E,$6E,$CF,$DF,$BF,$BF,$00,$20,$70,$7C
        .byte   $F6,$FA,$FC,$FC,$B9,$DB,$C7,$5E,$64,$20,$00,$00,$DE,$E6,$FE,$7C
        .byte   $7A,$38,$00,$00,$FD,$FD,$FE,$FF,$01,$05,$03,$05,$02,$04,$01,$13
        .byte   $02,$0A,$1C,$1A,$3D,$3B,$3F,$5F,$1D,$19,$09,$0C,$06,$03,$00,$00
        .byte   $1E,$1F,$4F,$6F,$27,$07,$06,$02,$01,$01,$02,$01,$02,$00,$01,$03
        .byte   $00,$06,$0D,$0E,$1D,$1F,$1F,$0F,$1D,$19,$19,$0C,$06,$03,$00,$00
        .byte   $1E,$7F,$5F,$0F,$1F,$1B,$08,$00,$00,$40,$80,$C0,$A0,$00,$80,$C8
        .byte   $80,$A0,$70,$30,$58,$F8,$F8,$FA,$B8,$98,$90,$30,$60,$80,$00,$00
        .byte   $7E,$F8,$F0,$FC,$E4,$C0,$C0,$80,$00,$01,$02,$01,$02,$01,$01,$03
        .byte   $01,$02,$05,$06,$0D,$0E,$0F,$07,$1D,$19,$19,$0C,$06,$03,$00,$00
        .byte   $7E,$5F,$1F,$1F,$3F,$33,$01,$01,$FE,$FE,$FD,$FF,$FD,$00,$06,$FD
        .byte   $2C,$7B,$FD,$00,$05,$FD,$03,$17,$7E,$5E,$7B,$14,$FD,$00,$05,$FD
        .byte   $AF,$7E,$2F,$03,$FD,$00,$08,$FD,$18,$18,$A0,$50,$FD,$00,$05,$FD
        .byte   $E0,$58,$AC,$FC,$50,$AC,$0C,$FD,$00,$04,$FD,$02,$AC,$50,$E0,$FD
        .byte   $00,$0A,$FD,$01,$05,$FD,$00,$05,$FD,$01,$06,$06,$2E,$7A,$2E,$38
        .byte   $10,$00,$00,$00,$1F,$37,$1F,$74,$FD,$00,$07,$FD,$60,$60,$58,$60
        .byte   $C8,$FD,$00,$04,$FD,$18,$A4,$98,$30,$98,$FD,$00,$07,$FD,$60,$C0
        .byte   $80,$FD,$00,$0B,$FD,$01,$FD,$00,$06,$FD,$01,$06,$07,$06,$0F,$1B
        .byte   $1E,$0C,$20,$00,$00,$07,$07,$0F,$34,$18,$08,$FD,$00,$04,$FD,$60
        .byte   $60,$50,$AC,$DC,$E0,$00,$00,$00,$18,$A8,$50,$20,$10,$80,$FD,$00
        .byte   $07,$FD,$60,$C0,$80,$FD,$00,$07,$FD,$03,$03,$00,$00,$01,$01,$FD
        .byte   $00,$04,$FD,$01,$01,$02,$02,$03,$07,$07,$0D,$06,$03,$00,$00,$03
        .byte   $03,$0D,$07,$03,$06,$08,$FD,$00,$04,$FD,$60,$6C,$CC,$A0,$C0,$00
        .byte   $00,$60,$90,$90,$30,$50,$20,$80,$C0,$00,$80,$FD,$00,$04,$FD,$60
        .byte   $C0,$80,$FD,$00,$07,$FD,$D6,$D6,$38,$54,$38,$54,$00,$10,$28,$28
        .byte   $44,$28,$C6,$AA,$7C,$54,$7C,$38,$6C,$38,$00,$10,$FE,$7C,$38,$6C
        .byte   $38,$6C,$10,$00,$FD,$FD,$F9,$FD,$03,$07,$0B,$1F,$3D,$3D,$7B,$7F
        .byte   $04,$08,$14,$20,$22,$72,$66,$66,$1F,$3F,$7F,$7F,$7E,$FB,$3F,$00
        .byte   $60,$47,$05,$D8,$F1,$A5,$C3,$7F,$E0,$F0,$F8,$F4,$FA,$FC,$FA,$FE
        .byte   $10,$0C,$06,$0A,$05,$03,$07,$02,$F4,$D8,$FC,$FC,$F8,$F0,$E0,$00
        .byte   $0E,$3C,$FC,$78,$F4,$E8,$D0,$C0,$01,$03,$05,$0F,$0F,$1F,$1F,$1F
        .byte   $02,$0C,$1A,$10,$38,$3C,$7E,$6E,$7F,$7F,$3F,$7F,$FF,$FF,$FF,$00
        .byte   $6C,$E0,$C0,$C5,$56,$FC,$54,$7F,$C0,$F0,$E8,$F4,$F8,$F6,$C4,$9C
        .byte   $20,$08,$14,$0A,$06,$09,$3B,$7B,$BC,$B8,$F8,$E0,$E0,$80,$00,$00
        .byte   $72,$66,$04,$D8,$60,$40,$C0,$80,$03,$07,$0B,$0F,$1F,$1F,$3F,$3F
        .byte   $04,$08,$14,$38,$39,$7B,$73,$6D,$3F,$7F,$FF,$FF,$FF,$3F,$1F,$0E
        .byte   $5D,$CC,$90,$75,$BD,$EF,$2A,$01,$E0,$F0,$FC,$FC,$FA,$FC,$FA,$FE
        .byte   $10,$0C,$02,$02,$05,$83,$C7,$C2,$F4,$D8,$B8,$F0,$E0,$E0,$80,$00
        .byte   $8E,$3C,$78,$28,$F8,$90,$E0,$80,$03,$0F,$0F,$1F,$2F,$5F,$3F,$3F
        .byte   $04,$10,$30,$20,$54,$2E,$5E,$5C,$1F,$0F,$17,$1F,$1F,$0F,$07,$03
        .byte   $29,$13,$38,$34,$2D,$17,$1D,$0C,$F9,$F9,$FE,$FF,$00,$03,$04,$09
        .byte   $0F,$1F,$16,$1D,$00,$00,$03,$05,$17,$07,$2B,$2E,$1D,$1E,$1F,$0D
        .byte   $09,$04,$03,$00,$2E,$2F,$05,$17,$05,$03,$00,$00,$00,$80,$40,$A0
        .byte   $A0,$F0,$70,$B8,$00,$00,$80,$90,$E8,$B8,$F4,$7C,$B8,$60,$F0,$E0
        .byte   $A0,$40,$80,$00,$7C,$DC,$F8,$E8,$90,$80,$00,$00,$00,$01,$01,$01
        .byte   $07,$0F,$0D,$19,$FE,$00,$04,$FE,$06,$0A,$0E,$1E,$19,$0C,$0E,$07
        .byte   $01,$00,$00,$00,$1F,$0F,$0B,$07,$01,$FE,$00,$07,$FE,$07,$0F,$0E
        .byte   $1F,$00,$03,$0C,$11,$26,$2E,$4F,$5D,$0D,$0F,$0F,$07,$01,$00,$00
        .byte   $00,$53,$4E,$2F,$27,$11,$0C,$03,$00,$FE,$FE,$FB,$FD,$01,$03,$07
        .byte   $0E,$1D,$3B,$76,$EC,$01,$03,$07,$0F,$1E,$3C,$79,$F3,$D8,$6C,$36
        .byte   $1B,$0D,$06,$03,$01,$E7,$73,$39,$1C,$0E,$07,$03,$01,$80,$C0,$E0
        .byte   $70,$B8,$DC,$6E,$37,$00,$00,$00,$80,$C0,$E0,$F0,$F8,$18,$30,$60
        .byte   $C0,$80,$00,$00,$00,$FF,$FE,$FC,$F8,$F0,$E0,$C0,$80,$00,$00,$01
        .byte   $07,$1F,$7F,$F9,$E1,$00,$00,$01,$07,$1F,$7F,$FF,$FF,$81,$06,$18
        .byte   $FB,$00,$05,$FB,$FF,$FF,$7F,$1F,$07,$01,$FB,$00,$05,$FB,$C0,$F0
        .byte   $FC,$3E,$5E,$FB,$00,$05,$FB,$C0,$F0,$AC,$EA,$D4,$38,$FB,$00,$05
        .byte   $FB,$16,$EA,$F4,$F0,$C0,$FB,$00,$06,$01,$04,$FB,$FF,$00,$00,$00
        .byte   $1F,$3F,$7F,$FF,$FF,$FF,$7F,$3F,$1F,$FB,$00,$04,$FB,$FF,$7F,$3F
        .byte   $1F,$FB,$00,$07,$FB,$F0,$A8,$D4,$AA,$FE,$FB,$00,$04,$FB,$50,$28
        .byte   $54,$FE,$D4,$A8,$D0,$A0,$FB,$00,$04,$FB,$2A,$54,$28,$50,$FB,$00
        .byte   $04,$FB,$FB,$FE,$FF,$4C,$8C,$8C,$4E,$2F,$2B,$1B,$0B,$6A,$FA,$FA
        .byte   $7C,$3F,$3F,$1F,$0D,$0B,$0A,$0E,$0A,$06,$06,$00,$00,$0D,$0C,$0C
        .byte   $0C,$04,$04,$00,$00,$00,$20,$70,$F0,$70,$70,$F4,$E0,$00,$60,$50
        .byte   $D8,$D8,$FC,$F8,$48,$FE,$A0,$06,$FE,$C0,$C0,$40,$C0,$C0,$C0,$E0
        .byte   $C0,$80,$80,$30,$50,$56,$B6,$B6,$74,$4C,$44,$28,$6C,$6C,$EC,$EC
        .byte   $78,$7C,$78,$24,$28,$28,$28,$38,$28,$18,$18,$38,$FE,$30,$05,$FE
        .byte   $10,$10,$00,$30,$30,$30,$B8,$7A,$3F,$2F,$00,$28,$68,$E8,$F1,$5B
        .byte   $2E,$37,$2F,$2C,$28,$38,$28,$18,$18,$00,$36,$36,$30,$30,$30,$10
        .byte   $10,$00,$FE,$FE,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .fill   28,$FF

; ---- bank3.bank_id_BFFF (data) $BFFF-$BFFF, 1 bytes
; Bank 3 identity byte
        .byte   $03
