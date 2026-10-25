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

; ---- bank3.pad_801E (padding) $801E-$801F, 2 bytes
; Fill: 2 x $FF
        .byte   $FF,$FF

; ---- bank3.tbl_8020 (data) $8020-$8021, 2 bytes
; Tile-block id 0: no block
        .byte   $00,$00

; ---- bank3.gfxtbl_8022 (pointer_table) $8022-$802D, 12 bytes
; Tile block pointers (6 entries)
        .byte   $86,$96,$86,$96,$13,$97,$73,$97,$EF,$97,$EB,$98

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

; ---- bank3.tbl_803E (data) $803E-$803F, 2 bytes
; Tile-block id 15: no block ($FFFF)
        .byte   $FF,$FF

; ---- bank3.gfxtbl_8040 (pointer_table) $8040-$809F, 96 bytes
; Tile block pointers (48 entries)
        .byte   $2D,$99,$91,$99,$91,$99,$73,$9A,$A5,$9A,$09,$9B,$4D,$9B,$06,$9C
        .byte   $4A,$9C,$6D,$9C,$B1,$9C,$DD,$9D,$41,$9E,$76,$A4,$F8,$A4,$71,$A6
        .byte   $D1,$A7,$C4,$A9,$88,$AA,$97,$AB,$FB,$AB,$7D,$AC,$E1,$AC,$87,$AE
        .byte   $CA,$AF,$00,$B1,$F5,$B1,$BF,$B3,$03,$B4,$03,$B4,$47,$B4,$7F,$B5
        .byte   $FD,$B5,$81,$B6,$81,$B6,$E0,$B6,$43,$B7,$3B,$B9,$0B,$BA,$35,$BB
        .byte   $B9,$BB,$3D,$BC,$39,$BD,$1D,$BE,$9E,$BE,$56,$BF,$6E,$A3,$F2,$A3

; ---- bank3.code_80A0 (code) $80A0-$80A7, 8 bytes
L3_80A0:
        jsr     L7_C01B
        lda     #$20
        jsr     L7_C018

; ---- bank3.code_80A8 (code) $80A8-$80AA, 3 bytes
        jsr     L7_C06C

; ---- bank3.inline_80AB (data) $80AB-$80AE, 4 bytes
; Inline argument at $80AB
        .byte   $40,$23,$C0,$00

; ---- bank3.code_80AF (code) $80AF-$80BD, 15 bytes
        lda     #$30
        sta     $0181
        lda     #$21
        sta     $0182
        lda     #$16
        sta     $0183

; ---- bank3.code_80BE (code) $80BE-$80C0, 3 bytes
        jsr     L7_C06F

; ---- bank3.inline_80C1 (text) $80C1-$80CF, 15 bytes
; "YOU GOT ITEM" at $80C1
        .byte   $0C,$20,$84,$59,$4F,$55,$20,$47,$4F,$54,$20,$49,$54,$45,$4D

; ---- bank3.code_80D0 (code) $80D0-$80D2, 3 bytes
        jsr     L7_C0DE

; ---- bank3.code_80D3 (code) $80D3-$80D5, 3 bytes
        jsr     L7_C006

; ---- bank3.inline_80D6 (data) $80D6-$80D8, 3 bytes
; Far-call argument at $80D6
        .byte   $06,$11,$80

; ---- bank3.code_80D9 (code) $80D9-$80E4, 12 bytes
        lda     #$80
        sta     $14
        lda     #$C8
        sta     $18
        lda     #$20
        sta     $19

; ---- bank3.code_80E5 (code) $80E5-$80EA, 6 bytes
        ldx     $76
L3_80E7:
        cpx     #$92
        bcs     L3_8158

; ---- bank3.code_80EB (code) $80EB-$80F1, 7 bytes
        lda     $15
        cmp     $817A,X
        bcc     L3_8158

; ---- bank3.code_80F2 (code) $80F2-$80FD, 12 bytes
        lda     $15
        pha
        lda     $14
        pha
        lda     $19
        pha
        lda     $18
        pha

; ---- bank3.code_80FE (code) $80FE-$8100, 3 bytes
        jsr     L3_820C

; ---- bank3.code_8101 (code) $8101-$8106, 6 bytes
        lda     $817B,X
        jsr     L7_C006

; ---- bank3.inline_8107 (data) $8107-$8109, 3 bytes
; Far-call argument at $8107
        .byte   $02,$14,$80

; ---- bank3.code_810A (code) $810A-$8117, 14 bytes
        ldx     $76
        pla
        sta     $18
        pla
        sta     $19
        pla
        sta     $14
        pla
        sta     $15

; ---- bank3.code_8118 (code) $8118-$8120, 9 bytes
        lda     $817A,X
        jsr     L7_C051
        jsr     L3_802E

; ---- bank3.code_8121 (code) $8121-$8132, 18 bytes
        lda     $18
        clc
        adc     #$05
        sta     $18
        lda     #$00
        sta     $17
        ldy     #$C0
        lda     $14
        jsr     L7_C054

; ---- bank3.code_8133 (code) $8133-$8137, 5 bytes
        ldy     #$64
        jsr     L7_C021

; ---- bank3.code_8138 (code) $8138-$8157, 32 bytes
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

; ---- bank3.code_8158 (code) $8158-$815A, 3 bytes
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

; ---- bank3.tbl_817A (data) $817A-$820B, 146 bytes
; Item reward list: 73 x [threshold][icon]
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

; ---- bank3.code_8229 (code) $8229-$8229, 1 bytes
        rts

; ---- bank3.code_822A (code) $822A-$822C, 3 bytes
L3_822A:
        ldx     #$FF
        txs

; ---- bank3.code_822D (code) $822D-$822F, 3 bytes
        jsr     L7_C06F

; ---- bank3.inline_8230 (text) $8230-$823C, 13 bytes
; "SOUND TEST" at $8230
        .byte   $0A,$20,$88,$53,$4F,$55,$4E,$44,$20,$54,$45,$53,$54

; ---- bank3.code_823D (code) $823D-$8244, 8 bytes
        lda     #$01
        sta     $15
        lda     #$01
        sta     $14

; ---- bank3.code_8245 (code) $8245-$824C, 8 bytes
L3_8245:
        lda     #$20
        sta     $19
        lda     #$CD
        sta     $18

; ---- bank3.code_824D (code) $824D-$8251, 5 bytes
        lda     $15
        jsr     L7_C051

; ---- bank3.code_8252 (code) $8252-$8258, 7 bytes
L3_8252:
        jsr     L7_C0E4
        sta     $19
        beq     L3_8252

; ---- bank3.code_8259 (code) $8259-$8264, 12 bytes
        lda     $F5
        bne     L3_8265
        dec     $14
        bne     L3_8252
        lda     #$02
        bne     L3_8267

; ---- bank3.code_8265 (code) $8265-$8266, 2 bytes
L3_8265:
        lda     #$0F

; ---- bank3.code_8267 (code) $8267-$8268, 2 bytes
L3_8267:
        sta     $14

; ---- bank3.code_8269 (code) $8269-$8276, 14 bytes
        lda     $19
        and     #$04
        beq     L3_8277
        lda     $15
        jsr     L7_C030
        jmp     L3_8252

; ---- bank3.code_8277 (code) $8277-$827F, 9 bytes
L3_8277:
        lda     $19
        and     #$08
        beq     L3_8286
        jsr     L7_C006

; ---- bank3.inline_8280 (data) $8280-$8282, 3 bytes
; Far-call argument at $8280
        .byte   $00,$FF,$7F

; ---- bank3.code_8283 (code) $8283-$8285, 3 bytes
        jmp     L3_8252

; ---- bank3.code_8286 (code) $8286-$828B, 6 bytes
L3_8286:
        lda     $19
        and     #$03
        beq     L3_8252

; ---- bank3.code_828C (code) $828C-$8299, 14 bytes
        cmp     #$02
        bne     L3_829A
        dec     $15
        bne     L3_8245
        lda     #$47
        sta     $15
        bne     L3_8245

; ---- bank3.code_829A (code) $829A-$82AB, 18 bytes
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

; ---- bank3.code_82AC (code) $82AC-$82BC, 17 bytes
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

; ---- bank3.code_82C1 (code) $82C1-$82CB, 11 bytes
        lda     $FF
        ora     #$08
        and     #$DF
        sta     $FF
        sta     $2000

; ---- bank3.code_82CC (code) $82CC-$82DB, 16 bytes
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

; ---- bank3.code_82F6 (code) $82F6-$82FF, 10 bytes
L3_82F6:
        jsr     L7_C0E4
        and     #$F0
        beq     L3_82F6
        jmp     L3_8B7E

; ---- bank3.code_8300 (code) $8300-$8314, 21 bytes
L3_8300:
        lda     #$1F
        jsr     L7_C030
        lda     #$10
        jsr     L7_C030
        jsr     L3_82AC
        jsr     L3_834F
        lda     #$01
        sta     $0400

; ---- bank3.code_8315 (code) $8315-$8319, 5 bytes
L3_8315:
        jsr     L3_887F
        bcc     L3_8323

; ---- bank3.code_831A (code) $831A-$8322, 9 bytes
        jsr     L3_876F
        jsr     L3_82F6
        jmp     L3_8315

; ---- bank3.code_8323 (code) $8323-$832C, 10 bytes
L3_8323:
        lda     $2F
        beq     L3_832A
        jsr     L3_8473
L3_832A:
        jmp     L3_8397

; ---- bank3.code_832D (code) $832D-$8348, 28 bytes
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

; ---- bank3.code_8349 (code) $8349-$834E, 6 bytes
        jsr     L3_834F
        jmp     L3_8380

; ---- bank3.code_834F (code) $834F-$8351, 3 bytes
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

; ---- bank3.code_8376 (code) $8376-$837A, 5 bytes
L3_8376:
        jsr     L3_8711
        beq     L3_8397

; ---- bank3.code_837B (code) $837B-$837F, 5 bytes
        lda     #$00
        sta     $0400

; ---- bank3.code_8380 (code) $8380-$8382, 3 bytes
L3_8380:
        jsr     L3_8B7E

; ---- bank3.code_8383 (code) $8383-$8390, 14 bytes
        jsr     L3_887F
        bcs     L3_838E
        jsr     L3_87F2
        jmp     L3_8391
L3_838E:
        jsr     L3_87B5

; ---- bank3.code_8391 (code) $8391-$8396, 6 bytes
L3_8391:
        jsr     L3_82F6
        jmp     L3_8376

; ---- bank3.code_8397 (code) $8397-$83AD, 23 bytes
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

; ---- bank3.code_83AE (code) $83AE-$83B8, 11 bytes
L3_83AE:
        ldy     #$11
L3_83B0:
        lda     $049F,Y
        sta     $0438,Y
        dey
        bne     L3_83B0

; ---- bank3.code_83B9 (code) $83B9-$83CA, 18 bytes
        lda     $46
        lsr     A
        rol     $0441
        lsr     A
        rol     $0441
        lsr     A
        rol     $0441
        lsr     A
        rol     $0441

; ---- bank3.code_83CB (code) $83CB-$83D2, 8 bytes
        lda     $0447
        and     #$7F
        sta     $0447

; ---- bank3.code_83D3 (code) $83D3-$83DF, 13 bytes
        lda     $47
        cmp     #$FF
        bne     L3_83DB
        lda     #$00
L3_83DB:
        ora     $6B
        sta     $044A

; ---- bank3.code_83E0 (code) $83E0-$83EA, 11 bytes
        lda     $52
        ldy     $4A
        dey
        jsr     L3_8430
        sta     $044B

; ---- bank3.code_83EB (code) $83EB-$83F4, 10 bytes
        lda     $53
        ldy     $4B
        jsr     L3_8430
        sta     $044C

; ---- bank3.code_83F5 (code) $83F5-$8411, 29 bytes
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

; ---- bank3.code_8412 (code) $8412-$842F, 30 bytes
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

; ---- bank3.code_8430 (code) $8430-$8438, 9 bytes
L3_8430:
        sta     $10
        tya
        jsr     L3_8439
        lda     $10
        rts

; ---- bank3.code_8439 (code) $8439-$8442, 10 bytes
L3_8439:
        lsr     A
        rol     $10
        lsr     A
        rol     $10
        lsr     A
        rol     $10
        rts

; ---- bank3.code_8443 (code) $8443-$844C, 10 bytes
L3_8443:
        ldy     #$00
        sty     $10
        jsr     L3_8439
        ldy     $10
        rts

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

; ---- bank3.code_8473 (code) $8473-$847D, 11 bytes
L3_8473:
        ldy     #$11
L3_8475:
        lda     $0438,Y
        sta     $049F,Y
        dey
        bne     L3_8475

; ---- bank3.code_847E (code) $847E-$848D, 16 bytes
        lda     $04AE
        and     #$7F
        sta     $04AE
        lda     $04B0
        and     #$7F
        sta     $04B0

; ---- bank3.code_848E (code) $848E-$84A1, 20 bytes
        lda     #$00
        lsr     $04A8
        rol     A
        lsr     $04A8
        rol     A
        lsr     $04A8
        rol     A
        lsr     $04A8
        rol     A
        sta     $46

; ---- bank3.code_84A2 (code) $84A2-$84B3, 18 bytes
        lda     $044A
        and     #$07
        sta     $6B
        lda     $044A
        and     #$F8
        bne     L3_84B2
        lda     #$FF
L3_84B2:
        sta     $47

; ---- bank3.code_84B4 (code) $84B4-$84BE, 11 bytes
        lda     $044B
        jsr     L3_8443
        sta     $7C
        iny
        sty     $4A

; ---- bank3.code_84BF (code) $84BF-$84C8, 10 bytes
        lda     $044C
        jsr     L3_8443
        sta     $7D
        sty     $4B

; ---- bank3.code_84C9 (code) $84C9-$84E4, 28 bytes
        lda     #$00
        lsr     $04AB
        rol     A
        lsr     $04AB
        rol     A
        tay
        lda     $044E
        jsr     L3_8502
        sty     $0175
        sta     $0174
        lda     $19
        sta     $0173

; ---- bank3.code_84E5 (code) $84E5-$8501, 29 bytes
        lda     #$00
        lsr     $04AB
        rol     A
        lsr     $04AB
        rol     A
        tay
        lda     $044D
        jsr     L3_8502
        sty     $0172
        sta     $0171
        lda     $19
        sta     $0170
        rts

; ---- bank3.code_8502 (code) $8502-$8512, 17 bytes
L3_8502:
        pha
        lda     #$64
        sta     $10
        pla
        jsr     L7_C10E
        sta     $19
        lda     #$0A
        jsr     L7_C10B
        rts

; ---- bank3.data_8513 (data) $8513-$8515, 3 bytes
; The TGL password constant
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

; ---- bank3.tbl_870D (data) $870D-$8710, 4 bytes
; OAM template: one sprite
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
L3_876F:
        jsr     L3_8783
L3_8772:
        jsr     L7_C06F

; ---- bank3.inline_8775 (text) $8775-$8781, 13 bytes
; "WRONG WORD" at $8775
        .byte   $0A,$21,$8A,$57,$52,$4F,$4E,$47,$20,$57,$4F,$52,$44

; ---- bank3.code_8782 (code) $8782-$87CC, 75 bytes
        rts
L3_8783:
        lda     #$21
        sta     $19
        lda     #$88
L3_8789:
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
L3_87B5:
        jsr     L3_8B7E
        lda     #$21
        sta     $19
        lda     #$48
        sta     $18
        ldx     #$0E
        ldy     #$07
        jsr     L3_8BB3
        jsr     L3_8772
        jsr     L7_C06F

; ---- bank3.inline_87CD (text) $87CD-$87D8, 12 bytes
; "THE ABOVE" at $87CD
        .byte   $09,$21,$CA,$54,$48,$45,$20,$41,$42,$4F,$56,$45

; ---- bank3.code_87D9 (code) $87D9-$87FD, 37 bytes
        jsr     L3_87FB
        lda     #$20
        sta     $19
        lda     #$86
        sta     $18
        ldx     #$00
L3_87E6:
        lda     $0740,X
        jsr     L3_8681
        inx
        cpx     #$20
        bne     L3_87E6
        rts
L3_87F2:
        lda     #$22
        sta     $19
        lda     #$08
        jsr     L3_8789
L3_87FB:
        jsr     L7_C06F

; ---- bank3.inline_87FE (text) $87FE-$880D, 16 bytes
; "WORD IS RIGHT" at $87FE
        .byte   $0D,$22,$0A,$57,$4F,$52,$44,$20,$49,$53,$20,$52,$49,$47,$48,$54

; ---- bank3.code_880E (code) $880E-$8876, 105 bytes
        rts
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

; ---- bank3.tbl_8877 (data) $8877-$887E, 8 bytes
; Table, 8 bytes (structural extent)
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

; ---- bank3.tbl_8B1B (data) $8B1B-$8B22, 8 bytes
; OAM template: two sprites
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

; ---- bank3.code_8B6B (code) $8B6B-$8B7D, 19 bytes
        lda     #$20
        sta     $15
        lda     #$20
        sta     $14
        lda     #$00
        sta     $17
        lda     #$14
        sta     $16
        jsr     $C084

; ---- bank3.code_8B7E (code) $8B7E-$8C97, 282 bytes
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

; ---- bank3.code_8C98 (code) $8C98-$8C9C, 5 bytes
L3_8C98:
        lda     $0500
        bmi     L3_8CE7

; ---- bank3.code_8C9D (code) $8C9D-$8CA1, 5 bytes
        ora     #$80
        sta     $0500

; ---- bank3.code_8CA2 (code) $8CA2-$8CA6, 5 bytes
        lda     #$03
        sta     $0620

; ---- bank3.code_8CA7 (code) $8CA7-$8CAE, 8 bytes
        lda     #$00
        sta     $0728
        sta     $07E8

; ---- bank3.code_8CAF (code) $8CAF-$8CB1, 3 bytes
        jsr     L3_8FAA

; ---- bank3.code_8CB2 (code) $8CB2-$8CB4, 3 bytes
        jsr     L7_C0A2

; ---- bank3.code_8CB5 (code) $8CB5-$8CB7, 3 bytes
        jsr     L7_C132

; ---- bank3.code_8CB8 (code) $8CB8-$8CC1, 10 bytes
        lda     $0578
        and     #$80
        ora     #$14
        sta     $0578

; ---- bank3.code_8CC2 (code) $8CC2-$8CC5, 4 bytes
        bit     $30
        bvc     L3_8CDA

; ---- bank3.code_8CC6 (code) $8CC6-$8CCA, 5 bytes
        lda     #$05
        sta     $0680

; ---- bank3.code_8CCB (code) $8CCB-$8CCF, 5 bytes
        lda     #$01
        sta     $0548

; ---- bank3.code_8CD0 (code) $8CD0-$8CD9, 10 bytes
        lda     #$00
        sta     $06B0
        sta     $06C8
        beq     L3_8CE7

; ---- bank3.code_8CDA (code) $8CDA-$8CDE, 5 bytes
L3_8CDA:
        lda     #$08
        sta     $06B0

; ---- bank3.code_8CDF (code) $8CDF-$8CE6, 8 bytes
        jsr     L7_C0A2
        ldy     $32
        jsr     L3_8F85

; ---- bank3.code_8CE7 (code) $8CE7-$8CEB, 5 bytes
L3_8CE7:
        lda     $07E8
        beq     L3_8CF3

; ---- bank3.code_8CEC (code) $8CEC-$8CEE, 3 bytes
        jsr     L7_C006

; ---- bank3.inline_8CEF (data) $8CEF-$8CF1, 3 bytes
; Far-call argument at $8CEF
        .byte   $01,$FF,$7F

; ---- bank3.code_8CF2 (code) $8CF2-$8CF2, 1 bytes
        rts

; ---- bank3.code_8CF3 (code) $8CF3-$8CF5, 3 bytes
L3_8CF3:
        jsr     L7_C02D

; ---- bank3.code_8CF6 (code) $8CF6-$8CF9, 4 bytes
        bit     $30
        bvs     L3_8D27

; ---- bank3.code_8CFA (code) $8CFA-$8D02, 9 bytes
        lda     $A0
        and     #$01
        beq     L3_8D03
        jmp     L3_8E6B

; ---- bank3.code_8D03 (code) $8D03-$8D05, 3 bytes
L3_8D03:
        jsr     L3_8F53

; ---- bank3.code_8D06 (code) $8D06-$8D0B, 6 bytes
        ldy     $32
        cpy     #$04
        bne     L3_8D18

; ---- bank3.code_8D0C (code) $8D0C-$8D17, 12 bytes
        lda     #$FF
        sta     $0650,X
        lda     $0728
        bne     L3_8D24
        beq     L3_8D21

; ---- bank3.code_8D18 (code) $8D18-$8D20, 9 bytes
L3_8D18:
        lda     $8EF4,Y
        sta     $0668
        jsr     L7_C102

; ---- bank3.code_8D21 (code) $8D21-$8D23, 3 bytes
L3_8D21:
        jsr     L3_8FB9

; ---- bank3.code_8D24 (code) $8D24-$8D26, 3 bytes
L3_8D24:
        jmp     L3_8DF5

; ---- bank3.code_8D27 (code) $8D27-$8D2D, 7 bytes
L3_8D27:
        bit     $0578
        bpl     L3_8D5C
        bvc     L3_8D5C

; ---- bank3.code_8D2E (code) $8D2E-$8D34, 7 bytes
        lda     #$80
        ldy     #$0C
        jsr     L7_C0A5

; ---- bank3.code_8D35 (code) $8D35-$8D3A, 6 bytes
        lda     $8D44,Y
        sta     $0548,X

; ---- bank3.code_8D3B (code) $8D3B-$8D40, 6 bytes
        lda     $8D50,Y
        sta     $0560,X

; ---- bank3.code_8D41 (code) $8D41-$8D43, 3 bytes
        jmp     L3_8D9A

; ---- bank3.tbl_8D44 (data) $8D44-$8D4F, 12 bytes
; Ship hit-spin metasprite by phase
        .byte   $01,$02,$03,$04,$05,$06,$07,$06,$05,$04,$03,$02

; ---- bank3.tbl_8D50 (data) $8D50-$8D5B, 12 bytes
; Ship hit-spin palette by phase
        .byte   $00,$01,$02,$03,$00,$01,$02,$43,$40,$41,$42,$43

; ---- bank3.code_8D5C (code) $8D5C-$8D62, 7 bytes
L3_8D5C:
        ldy     $32
        lda     $8EEB,Y
        bne     L3_8D76

; ---- bank3.code_8D63 (code) $8D63-$8D75, 19 bytes
        lda     $0680
        cmp     #$05
        beq     L3_8D8B
        bcs     L3_8D71
        inc     $0680
        bpl     L3_8D8B
L3_8D71:
        dec     $0680
        bpl     L3_8D8B

; ---- bank3.code_8D76 (code) $8D76-$8D8A, 21 bytes
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

; ---- bank3.code_8D8B (code) $8D8B-$8D99, 15 bytes
L3_8D8B:
        ldy     $0680
        lda     $8EFD,Y
        sta     $0548
        lda     $8F08,Y
        sta     $0560

; ---- bank3.code_8D9A (code) $8D9A-$8DA1, 8 bytes
L3_8D9A:
        ldy     $32
        lda     $8EF4,Y
        sta     $0668

; ---- bank3.code_8DA2 (code) $8DA2-$8DA5, 4 bytes
        cpy     #$04
        beq     L3_8DF5

; ---- bank3.code_8DA6 (code) $8DA6-$8DA8, 3 bytes
        jsr     L7_C102

; ---- bank3.code_8DA9 (code) $8DA9-$8DCE, 38 bytes
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

; ---- bank3.code_8DCF (code) $8DCF-$8DF4, 38 bytes
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

; ---- bank3.code_8DF5 (code) $8DF5-$8E00, 12 bytes
L3_8DF5:
        lda     $0548
        ldy     $49
        bne     L3_8DFE
        lda     #$0A
L3_8DFE:
        jsr     L7_C0B4

; ---- bank3.code_8E01 (code) $8E01-$8E0E, 14 bytes
        lda     $F7
        ora     $F8
        and     #$40
        bne     L3_8E0F
        lda     #$01
        sta     $33
        bne     L3_8E3C

; ---- bank3.code_8E0F (code) $8E0F-$8E16, 8 bytes
L3_8E0F:
        dec     $33
        bne     L3_8E3C
        lda     $39
        sta     $33

; ---- bank3.code_8E17 (code) $8E17-$8E24, 14 bytes
        ldy     #$00
L3_8E19:
        lda     $0501,Y
        beq     L3_8E25
        iny
        cpy     $3B
        bne     L3_8E19
        beq     L3_8E3C

; ---- bank3.code_8E25 (code) $8E25-$8E3B, 23 bytes
L3_8E25:
        lda     #$02
        sta     $0501,Y
        lda     $0518
        sta     $0519,Y
        lda     $0530
        sta     $0531,Y
        lda     $0668
        sta     $0789,Y

; ---- bank3.code_8E3C (code) $8E3C-$8E47, 12 bytes
L3_8E3C:
        lda     $3C
        beq     L3_8E6B
        lda     $F7
        ora     $F8
        and     #$80
        beq     L3_8E6B

; ---- bank3.code_8E48 (code) $8E48-$8E6A, 35 bytes
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

; ---- bank3.code_8E6B (code) $8E6B-$8E6F, 5 bytes
L3_8E6B:
        lda     $0578
        bpl     L3_8E92

; ---- bank3.code_8E70 (code) $8E70-$8E74, 5 bytes
        dec     $0788
        bne     L3_8E86

; ---- bank3.code_8E75 (code) $8E75-$8E85, 17 bytes
        bit     $30
        bvs     L3_8E7C
        jsr     L3_8F89
L3_8E7C:
        lda     $0578
        and     #$3F
        sta     $0578
        bpl     L3_8E92

; ---- bank3.code_8E86 (code) $8E86-$8E91, 12 bytes
L3_8E86:
        bit     $0578
        bvs     L3_8E92
        lda     $0788
        and     #$01
        bne     L3_8E95

; ---- bank3.code_8E92 (code) $8E92-$8E94, 3 bytes
L3_8E92:
        jsr     L7_C090

; ---- bank3.code_8E95 (code) $8E95-$8EAD, 25 bytes
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

; ---- bank3.code_8EAE (code) $8EAE-$8EB9, 12 bytes
L3_8EAE:
        lda     $8ED8,Y
        sta     $87
        bmi     L3_8EBA
        lda     #$1D
        jsr     L7_C093

; ---- bank3.code_8EBA (code) $8EBA-$8EC8, 15 bytes
L3_8EBA:
        lda     $0578
        and     #$40
        beq     L3_8ED7
        ldy     $0788
        lda     $8EDC,Y
        beq     L3_8ED7

; ---- bank3.code_8EC9 (code) $8EC9-$8ED6, 14 bytes
        lda     $0560
        sta     $86
        lda     #$70
        sta     $87
        lda     #$21
        jmp     L7_C093

; ---- bank3.code_8ED7 (code) $8ED7-$8ED7, 1 bytes
L3_8ED7:
        rts

; ---- bank3.tbl_8ED8 (data) $8ED8-$8EDB, 4 bytes
; Exhaust flame tile base
        .byte   $FF,$00,$30,$32

; ---- bank3.tbl_8EDC (data) $8EDC-$8EEA, 15 bytes
; Hit overlay flash by remaining count (15 entries)
        .byte   $34,$01,$00,$00,$00,$01,$00,$00,$01,$00,$01,$00,$01,$00,$01

; ---- bank3.tbl_8EEB (data) $8EEB-$8EF3, 9 bytes
; Sideways part of the pad cell
        .byte   $FF,$FF,$FF,$00,$00,$00,$01,$01,$01

; ---- bank3.tbl_8EF4 (data) $8EF4-$8EFC, 9 bytes
; Facing by pad cell
        .byte   $06,$08,$0A,$04,$0C,$0C,$02,$00,$0E

; ---- bank3.tbl_8EFD (data) $8EFD-$8F07, 11 bytes
; Corridor ship metasprite by banking phase
        .byte   $03,$02,$02,$02,$02,$01,$02,$02,$02,$02,$03

; ---- bank3.tbl_8F08 (data) $8F08-$8F12, 11 bytes
; Corridor ship palette by banking phase
        .byte   $00,$00,$00,$00,$00,$00,$40,$40,$40,$40,$40

; ---- bank3.tbl_8F13 (data) $8F13-$8F32, 32 bytes
; Ship walking tile base: 8 facings x 4 poses
        .byte   $20,$28,$30,$28,$38,$40,$48,$40,$00,$08,$00,$08,$38,$40,$48,$40
        .byte   $20,$28,$30,$28,$50,$58,$60,$58,$10,$18,$10,$18,$50,$58,$60,$58

; ---- bank3.tbl_8F33 (data) $8F33-$8F52, 32 bytes
; Ship walking palette (flip): 8 facings x 4 poses
        .byte   $40,$40,$40,$40,$40,$40,$40,$40,$00,$00,$40,$40,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$40,$40,$40,$40,$40

; ---- bank3.code_8F53 (code) $8F53-$8F5B, 9 bytes
L3_8F53:
        ldy     $32
        bit     $0578
        bpl     L3_8F85
        bvc     L3_8F85

; ---- bank3.code_8F5C (code) $8F5C-$8F62, 7 bytes
        lda     #$80
        ldy     #$08
        jsr     L7_C0A5

; ---- bank3.code_8F63 (code) $8F63-$8F68, 6 bytes
        lda     $8F75,Y
        sta     $06C8

; ---- bank3.code_8F69 (code) $8F69-$8F6E, 6 bytes
        lda     $8F7D,Y
        sta     $0560

; ---- bank3.code_8F6F (code) $8F6F-$8F74, 6 bytes
        lda     #$50
        sta     $0548
        rts

; ---- bank3.tbl_8F75 (data) $8F75-$8F7C, 8 bytes
; Ship hit-spin tile base (labyrinth)
        .byte   $00,$40,$28,$58,$10,$58,$28,$40

; ---- bank3.tbl_8F7D (data) $8F7D-$8F84, 8 bytes
; Ship hit-spin palette (labyrinth)
        .byte   $00,$01,$02,$03,$00,$41,$42,$43

; ---- bank3.code_8F85 (code) $8F85-$8F88, 4 bytes
L3_8F85:
        cpy     #$04
        beq     L3_8F90

; ---- bank3.code_8F89 (code) $8F89-$8F8F, 7 bytes
L3_8F89:
        lda     #$20
        ldy     #$04
        jsr     L7_C0A5

; ---- bank3.code_8F90 (code) $8F90-$8F9D, 14 bytes
L3_8F90:
        lda     $0668
        asl     A
        adc     $0638
        tay
        lda     $8F13,Y
        sta     $06C8

; ---- bank3.code_8F9E (code) $8F9E-$8FA2, 5 bytes
        lda     #$50
        sta     $0548

; ---- bank3.code_8FA3 (code) $8FA3-$8FA8, 6 bytes
        lda     $8F33,Y
        sta     $0560

; ---- bank3.code_8FA9 (code) $8FA9-$8FA9, 1 bytes
        rts

; ---- bank3.code_8FAA (code) $8FAA-$8FB8, 15 bytes
L3_8FAA:
        lda     #$00
        sta     $05C0,X
        sta     $05D8,X
        sta     $05F0,X
        sta     $0608,X
        rts

; ---- bank3.code_8FB9 (code) $8FB9-$8FBB, 3 bytes
L3_8FB9:
        jsr     L7_C006

; ---- bank3.inline_8FBC (data) $8FBC-$8FBE, 3 bytes
; Far-call argument at $8FBC
        .byte   $06,$08,$80

; ---- bank3.code_8FBF (code) $8FBF-$8FC8, 10 bytes
        lda     $6C
        cmp     $07A0
        sta     $07A0
        beq     L3_9015

; ---- bank3.code_8FC9 (code) $8FC9-$8FCC, 4 bytes
        cmp     #$02
        bne     L3_9015

; ---- bank3.code_8FCD (code) $8FCD-$8FEC, 32 bytes
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

; ---- bank3.code_8FED (code) $8FED-$8FEE, 2 bytes
L3_8FED:
        sta     $A4

; ---- bank3.code_8FEF (code) $8FEF-$8FFD, 15 bytes
        cmp     #$04
        bcc     L3_8FF5
        sbc     #$02
L3_8FF5:
        lsr     A
        tay
        lda     a:$0058,y
        and     #$07
        beq     L3_9009

; ---- bank3.code_8FFE (code) $8FFE-$9008, 11 bytes
        sec
        sbc     #$01
        jsr     L7_C078
        and     $04B0
        beq     L3_9014

; ---- bank3.code_9009 (code) $9009-$9013, 11 bytes
L3_9009:
        lda     $A0
        ora     #$03
        sta     $A0
        lda     #$3B
        jmp     L7_C030

; ---- bank3.code_9014 (code) $9014-$9014, 1 bytes
L3_9014:
        rts

; ---- bank3.code_9015 (code) $9015-$901A, 6 bytes
L3_9015:
        lda     $6C
        cmp     #$01
        bne     L3_9045

; ---- bank3.code_901B (code) $901B-$9029, 15 bytes
        lda     #$33
        jsr     L7_C030
        lda     #$14
        jsr     L7_C12F
        lda     #$02
        jsr     L7_C00C

; ---- bank3.code_902A (code) $902A-$9044, 27 bytes
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

; ---- bank3.code_9045 (code) $9045-$904B, 7 bytes
L3_9045:
        lda     $0518
        cmp     #$10
        bcs     L3_9064

; ---- bank3.code_904C (code) $904C-$9063, 24 bytes
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

; ---- bank3.code_9064 (code) $9064-$9081, 30 bytes
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

; ---- bank3.code_9082 (code) $9082-$90A0, 31 bytes
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

; ---- bank3.code_90A1 (code) $90A1-$90BC, 28 bytes
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

; ---- bank3.code_90BD (code) $90BD-$90C4, 8 bytes
L3_90BD:
        sta     $A4
        lda     $A0
        ora     #$01
        sta     $A0

; ---- bank3.code_90C5 (code) $90C5-$90C5, 1 bytes
L3_90C5:
        rts

; ---- bank3.code_90C6 (code) $90C6-$90CA, 5 bytes
L3_90C6:
        lda     $0500,X
        bmi     L3_90CC

; ---- bank3.code_90CB (code) $90CB-$90CB, 1 bytes
        rts

; ---- bank3.code_90CC (code) $90CC-$90D2, 7 bytes
L3_90CC:
        lda     #$10
        ldy     #$0A
        jsr     L7_C0A5

; ---- bank3.code_90D3 (code) $90D3-$90D8, 6 bytes
        bcc     L3_90D9
        sty     $0500
        rts

; ---- bank3.code_90D9 (code) $90D9-$90E2, 10 bytes
L3_90D9:
        lda     $41
        and     #$01
        clc
        adc     $0638
        sta     $15

; ---- bank3.code_90E3 (code) $90E3-$90F0, 14 bytes
        ldy     #$06
        lda     $0638
        cmp     #$04
        bcs     L3_90F1
        jsr     L7_C090
        ldy     #$05

; ---- bank3.code_90F1 (code) $90F1-$90F6, 6 bytes
L3_90F1:
        sty     $14
        lda     #$00
        sta     $87

; ---- bank3.code_90F7 (code) $90F7-$90FF, 9 bytes
L3_90F7:
        lda     $0530
        clc
        adc     $9121,Y
        sta     $85

; ---- bank3.code_9100 (code) $9100-$9108, 9 bytes
        lda     $0518
        clc
        adc     $9128,Y
        sta     $84

; ---- bank3.code_9109 (code) $9109-$9111, 9 bytes
        lda     $41
        clc
        adc     $14
        and     #$01
        sta     $86

; ---- bank3.code_9112 (code) $9112-$9119, 8 bytes
        ldy     $15
        lda     $912F,Y
        jsr     L7_C093

; ---- bank3.code_911A (code) $911A-$911F, 6 bytes
        dec     $14
        ldy     $14
        bpl     L3_90F7

; ---- bank3.code_9120 (code) $9120-$9120, 1 bytes
        rts

; ---- bank3.tbl_9121 (data) $9121-$9127, 7 bytes
; Dying ship: piece x offsets
        .byte   $FA,$06,$F4,$0C,$FA,$06,$00

; ---- bank3.tbl_9128 (data) $9128-$912E, 7 bytes
; Dying ship: piece y offsets
        .byte   $F4,$F4,$00,$00,$0C,$0C,$00

; ---- bank3.tbl_912F (data) $912F-$9138, 10 bytes
; Dying ship: piece metasprite by index
        .byte   $00,$30,$00,$31,$30,$31,$32,$33,$32,$33

; ---- bank3.tbl_9139 (data) $9139-$9139, 1 bytes
; A byte before the stage table `$913A`
        .byte   $00

; ---- bank3.tbl_913A (data) $913A-$9150, 23 bytes
; Table, 23 bytes
        .byte   $88,$88,$88,$88,$88,$88,$88,$02,$88,$88,$88,$88,$88,$88,$88,$88
        .byte   $88,$02,$88,$88,$88,$00,$00

; ---- bank3.tbl_9151 (data) $9151-$9167, 23 bytes
; Boss object type, by corridor
        .byte   $06,$40,$45,$2E,$46,$23,$47,$06,$49,$18,$19,$2D,$41,$4C,$25,$24
        .byte   $2F,$06,$48,$4D,$26,$4D,$4F

; ---- bank3.tbl_9168 (data) $9168-$917E, 23 bytes
; Table, 23 bytes (structural extent)
        .byte   $03,$03,$03,$06,$06,$03,$03,$06,$03,$06,$03,$16,$03,$06,$06,$16
        .byte   $03,$16,$03,$16,$03,$06,$06

; ---- bank3.code_917F (code) $917F-$9182, 4 bytes
L3_917F:
        lda     $70
        bne     L3_9184

; ---- bank3.code_9183 (code) $9183-$9183, 1 bytes
L3_9183:
        rts

; ---- bank3.code_9184 (code) $9184-$919F, 28 bytes
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

; ---- bank3.code_91A0 (code) $91A0-$91A3, 4 bytes
L3_91A0:
        bit     $30
        bvc     L3_91C8

; ---- bank3.code_91A4 (code) $91A4-$91B7, 20 bytes
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

; ---- bank3.code_91B8 (code) $91B8-$91C7, 16 bytes
        ldy     $51
        lda     $913A,Y
        sta     $71
        cpy     #$15
        beq     L3_91D2
        lda     $9151,Y
        sta     $72

; ---- bank3.code_91C8 (code) $91C8-$91D1, 10 bytes
L3_91C8:
        lda     #$40
        sta     $0300
        lda     #$45
        jsr     L7_C030

; ---- bank3.code_91D2 (code) $91D2-$91D7, 6 bytes
L3_91D2:
        lda     #$00
        sta     $73
        sta     $74

; ---- bank3.code_91D8 (code) $91D8-$9209, 50 bytes
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

; ---- bank3.code_920A (code) $920A-$9217, 14 bytes
L3_920A:
        lda     $71
        and     #$08
        sta     $10
        lda     $60
        ora     $10
        sta     $60
        inc     $70

; ---- bank3.code_9218 (code) $9218-$921B, 4 bytes
L3_9218:
        bit     $30
        bvc     L3_924B

; ---- bank3.code_921C (code) $921C-$9221, 6 bytes
        lda     $51
        cmp     #$15
        beq     L3_9246

; ---- bank3.code_9222 (code) $9222-$9227, 6 bytes
        inc     $73
        bne     L3_9228
        inc     $74

; ---- bank3.code_9228 (code) $9228-$922E, 7 bytes
L3_9228:
        lda     $73
        and     #$3F
        beq     L3_922F
        rts

; ---- bank3.code_922F (code) $922F-$9245, 23 bytes
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

; ---- bank3.code_9246 (code) $9246-$924A, 5 bytes
L3_9246:
        inc     $70
        jmp     L3_92DF

; ---- bank3.code_924B (code) $924B-$92B5, 107 bytes
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

; ---- bank3.code_92B6 (code) $92B6-$92BA, 5 bytes
L3_92B6:
        lda     #$06
        jmp     L3_9243

; ---- bank3.tbl_92BB (data) $92BB-$92CE, 20 bytes
; Miniboss entrance: cell order (20 entries)
        .byte   $22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$3E,$4E,$5E,$6E
        .byte   $7E,$8E,$9E,$AE

; ---- bank3.tbl_92CF (data) $92CF-$92DE, 16 bytes
; Miniboss entrance: which cell classes are broken
        .byte   $00,$01,$00,$01,$01,$01,$00,$00,$00,$01,$00,$01,$01,$01,$00,$00

; ---- bank3.code_92DF (code) $92DF-$92E3, 5 bytes
L3_92DF:
        jsr     L7_C027
        bcc     L3_92E5

; ---- bank3.code_92E4 (code) $92E4-$92E4, 1 bytes
L3_92E4:
        rts

; ---- bank3.code_92E5 (code) $92E5-$92ED, 9 bytes
L3_92E5:
        lda     $72
        sta     $0500,Y
        sty     $75
        inc     $70

; ---- bank3.code_92EE (code) $92EE-$931D, 48 bytes
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

; ---- bank3.code_931E (code) $931E-$9321, 4 bytes
L3_931E:
        bit     $30
        bvs     L3_9355

; ---- bank3.code_9322 (code) $9322-$9338, 23 bytes
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

; ---- bank3.code_9339 (code) $9339-$934E, 22 bytes
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

; ---- bank3.code_9352 (code) $9352-$9354, 3 bytes
        jmp     L3_9387

; ---- bank3.code_9355 (code) $9355-$935C, 8 bytes
L3_9355:
        lda     #$2F
        jsr     L7_C030
        jsr     L7_C006

; ---- bank3.inline_935D (data) $935D-$935F, 3 bytes
; Far-call argument at $935D
        .byte   $06,$02,$80

; ---- bank3.code_9360 (code) $9360-$9386, 39 bytes
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

; ---- bank3.code_9387 (code) $9387-$93A2, 28 bytes
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

; ---- bank3.code_93A3 (code) $93A3-$93BD, 27 bytes
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

; ---- bank3.code_93BE (code) $93BE-$93C2, 5 bytes
        lda     #$00
        sta     $70
        rts

; ---- bank3.code_93C3 (code) $93C3-$93D2, 16 bytes
L3_93C3:
        lda     #$1F
        jsr     L7_C030
        tya
        jsr     L7_C030
        lda     #$00
        sta     $70
        sta     $0300

; ---- bank3.code_93D3 (code) $93D3-$93E3, 17 bytes
L3_93D3:
        bit     $30
        bvc     L3_93DA
        jsr     L7_C15C
L3_93DA:
        ldy     #$01
        jsr     L7_C024
        lda     $0300
        beq     L3_93D3

; ---- bank3.code_93E4 (code) $93E4-$93ED, 10 bytes
        bit     $30
        bvc     L3_93EF
        lda     $A0
        ora     #$01
        sta     $A0

; ---- bank3.code_93EE (code) $93EE-$93EE, 1 bytes
L3_93EE:
        rts

; ---- bank3.code_93EF (code) $93EF-$93F1, 3 bytes
L3_93EF:
        jmp     L7_C15F

; ---- bank3.tbl_93F2 (data) $93F2-$93F9, 8 bytes
; Boss death: backdrop flash colours
        .byte   $0C,$00,$10,$30,$10,$00,$0C,$0F

; ---- bank3.code_93FA (code) $93FA-$93FE, 5 bytes
L3_93FA:
        ldy     $0500,X
        bmi     L3_9438

; ---- bank3.code_93FF (code) $93FF-$940A, 12 bytes
        lda     $94E2,Y
        sta     $0560,X
        lda     $94F5,Y
        sta     $07B8,X

; ---- bank3.code_940B (code) $940B-$9410, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C165

; ---- bank3.code_9411 (code) $9411-$9420, 16 bytes
        lda     #$80
        sta     $0530,X
        sta     $0680,X
        lda     #$30
        sta     $0518,X
        sta     $0668,X

; ---- bank3.code_9421 (code) $9421-$942A, 10 bytes
        lda     #$01
        sta     $05D8,X
        lda     #$04
        sta     $0608,X

; ---- bank3.code_942B (code) $942B-$9434, 10 bytes
        lda     #$78
        sta     $0788,X
        lda     #$01
        sta     $07A0,X

; ---- bank3.code_9435 (code) $9435-$9437, 3 bytes
        jsr     L7_C0A2

; ---- bank3.code_9438 (code) $9438-$943C, 5 bytes
L3_9438:
        lda     $0788,X
        beq     L3_9452

; ---- bank3.code_943D (code) $943D-$9441, 5 bytes
        dec     $0788,X
        beq     L3_944D

; ---- bank3.code_9442 (code) $9442-$9449, 8 bytes
        lda     $0788,X
        and     #$01
        beq     L3_944A
        rts

; ---- bank3.code_944A (code) $944A-$944C, 3 bytes
L3_944A:
        jmp     L3_94D5

; ---- bank3.code_944D (code) $944D-$9451, 5 bytes
L3_944D:
        lda     #$0B
        sta     $0620,X

; ---- bank3.code_9452 (code) $9452-$945B, 10 bytes
L3_9452:
        lda     #$12
        jsr     L7_C09F
        lda     #$20
        jsr     L7_C09C

; ---- bank3.code_945C (code) $945C-$9465, 10 bytes
        ldy     $0638,X
        lda     $951A,Y
        cmp     #$28
        bcs     L3_94D5

; ---- bank3.code_9466 (code) $9466-$946A, 5 bytes
        dec     $07A0,X
        bne     L3_94C5

; ---- bank3.code_946B (code) $946B-$9478, 14 bytes
        ldy     $0500,X
        lda     $9478,Y
        sta     $07A0,X
        lda     $947B,Y
        bne     L3_9480

; ---- bank3.code_9479 (code) $9479-$947F, 7 bytes
        jsr     L7_C0EA
        and     #$03
        ora     #$01

; ---- bank3.code_9480 (code) $9480-$9481, 2 bytes
L3_9480:
        sta     $16

; ---- bank3.code_9482 (code) $9482-$9491, 16 bytes
        lda     $0518,X
        cmp     $0518
        bcc     L3_9492
        lda     $16
        eor     #$FF
        sta     $16
        inc     $16

; ---- bank3.code_9492 (code) $9492-$9496, 5 bytes
L3_9492:
        lda     $947E,Y
        sta     $14

; ---- bank3.code_9497 (code) $9497-$949B, 5 bytes
        jsr     L7_C108
        bcs     L3_94D5

; ---- bank3.code_949C (code) $949C-$94A3, 8 bytes
        lda     $07E8,X
        clc
        adc     #$30
        sta     $17

; ---- bank3.code_94A4 (code) $94A4-$94AB, 8 bytes
        jsr     L7_C13E
        lda     $14
        jsr     L7_C13B

; ---- bank3.code_94AC (code) $94AC-$94B1, 6 bytes
        lda     $05A8,X
        sta     $05A8,Y

; ---- bank3.code_94B2 (code) $94B2-$94B7, 6 bytes
        lda     $0560,X
        sta     $0560,Y

; ---- bank3.code_94B8 (code) $94B8-$94BC, 5 bytes
        lda     #$01
        sta     $0620,Y

; ---- bank3.code_94BD (code) $94BD-$94C4, 8 bytes
        lda     $0518,Y
        adc     #$18
        sta     $0518,Y

; ---- bank3.code_94C5 (code) $94C5-$94CA, 6 bytes
L3_94C5:
        lda     $41
        and     #$1F
        bne     L3_94D5

; ---- bank3.code_94CB (code) $94CB-$94D4, 10 bytes
        jsr     L7_C108
        bcs     L3_94D5
        lda     #$0B
        jsr     L7_C105

; ---- bank3.code_94D5 (code) $94D5-$94DC, 8 bytes
L3_94D5:
        lda     $07B8,X
        ldy     #$08
        jsr     L7_C0A5

; ---- bank3.code_94DD (code) $94DD-$94EC, 16 bytes
        lda     $9512,Y
        sta     $0548,X
        lda     $951A,Y
        clc
        adc     $07E8,X
        sta     $06C8,X

; ---- bank3.code_94ED (code) $94ED-$94EF, 3 bytes
        jsr     L7_C08D

; ---- bank3.code_94F0 (code) $94F0-$94FD, 14 bytes
        lda     $41
        and     #$04
        beq     L3_94F8
        lda     #$0E
L3_94F8:
        clc
        adc     $07E8,X
        sta     $87

; ---- bank3.code_94FE (code) $94FE-$9502, 5 bytes
        lda     #$7C
        jsr     L7_C093

; ---- bank3.code_9503 (code) $9503-$950A, 8 bytes
        lda     $0788,X
        bne     L3_950E
        jsr     L7_C0C6

; ---- bank3.code_950B (code) $950B-$950D, 3 bytes
        jmp     L7_C0D8

; ---- bank3.code_950E (code) $950E-$950E, 1 bytes
L3_950E:
        rts

; ---- bank3.tbl_950F (data) $950F-$9511, 3 bytes
; Optomon palette by type
        .byte   $03,$02,$00

; ---- bank3.tbl_9512 (data) $9512-$9519, 8 bytes
; Optomon metasprite by phase
        .byte   $7E,$7E,$7E,$7E,$7D,$7D,$7E,$7E

; ---- bank3.tbl_951A (data) $951A-$9521, 8 bytes
; Optomon tile offset by phase
        .byte   $2C,$28,$24,$24,$00,$00,$24,$28

; ---- bank3.tbl_9522 (data) $9522-$9524, 3 bytes
; Optomon animation step by type
        .byte   $20,$28,$0C

; ---- bank3.tbl_9525 (data) $9525-$9527, 3 bytes
; Optomon beam timer by type
        .byte   $28,$20,$44

; ---- bank3.tbl_9528 (data) $9528-$952A, 3 bytes
; Optomon beam speed by type
        .byte   $01,$00,$01

; ---- bank3.tbl_952B (data) $952B-$952D, 3 bytes
; Optomon beam style record by type
        .byte   $09,$0C,$0F

; ---- bank3.code_952E (code) $952E-$9532, 5 bytes
L3_952E:
        ldy     $0500,X
        bmi     L3_9562

; ---- bank3.code_9533 (code) $9533-$9538, 6 bytes
        lda     $9633,Y
        sta     $0560,X

; ---- bank3.code_9539 (code) $9539-$953E, 6 bytes
        lda     $9635,Y
        sta     $07A0,X

; ---- bank3.code_953F (code) $953F-$9544, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C165

; ---- bank3.code_9545 (code) $9545-$954A, 6 bytes
        jsr     L7_C0A2
        jsr     L7_C0F0

; ---- bank3.code_954B (code) $954B-$954F, 5 bytes
        lda     #$83
        sta     $0548,X

; ---- bank3.code_9550 (code) $9550-$9557, 8 bytes
        lda     #$10
        sta     $0518,X
        sta     $0668,X

; ---- bank3.code_9558 (code) $9558-$955C, 5 bytes
        lda     #$00
        sta     $07B8,X

; ---- bank3.code_955D (code) $955D-$9561, 5 bytes
        lda     #$78
        sta     $0788,X

; ---- bank3.code_9562 (code) $9562-$9566, 5 bytes
L3_9562:
        lda     $0788,X
        beq     L3_9579

; ---- bank3.code_9567 (code) $9567-$956B, 5 bytes
        dec     $0788,X
        beq     L3_9574

; ---- bank3.code_956C (code) $956C-$9572, 7 bytes
        lda     $0788,X
        and     #$01
        bne     L3_959F

; ---- bank3.code_9573 (code) $9573-$9573, 1 bytes
        rts

; ---- bank3.code_9574 (code) $9574-$9578, 5 bytes
L3_9574:
        lda     #$04
        sta     $05D8,X

; ---- bank3.code_9579 (code) $9579-$957D, 5 bytes
L3_9579:
        lda     #$10
        jsr     L7_C09C

; ---- bank3.code_957E (code) $957E-$959E, 33 bytes
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

; ---- bank3.code_959F (code) $959F-$95BA, 28 bytes
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

; ---- bank3.code_95BB (code) $95BB-$95C9, 15 bytes
L3_95BB:
        lsr     A
        lsr     A
        lsr     A
        tay
        lda     $0560,X
        and     #$03
        ora     $9677,Y
        sta     $0560,X

; ---- bank3.code_95CA (code) $95CA-$95CC, 3 bytes
        jsr     L7_C08D

; ---- bank3.code_95CD (code) $95CD-$95DF, 19 bytes
        ldy     $16
        lda     $9679,Y
        pha
        jsr     L7_C093
        lda     $86
        eor     #$40
        sta     $86
        pla
        jsr     L7_C093

; ---- bank3.code_95E0 (code) $95E0-$95F5, 22 bytes
        ldy     $07B8,X
        lda     $967B,Y
        sta     $86
        lda     $967E,Y
        clc
        adc     $87
        sta     $87
        lda     $9681,Y
        jsr     L7_C093

; ---- bank3.code_95F6 (code) $95F6-$95F9, 4 bytes
        lda     #$00
        sta     $17

; ---- bank3.code_95FA (code) $95FA-$95FE, 5 bytes
        lda     $0788,X
        bne     L3_9638

; ---- bank3.code_95FF (code) $95FF-$960A, 12 bytes
        ldy     $05C0,X
        lda     $05D8,X
        beq     L3_960B
        cmp     #$FF
        bne     L3_9638

; ---- bank3.code_960B (code) $960B-$960E, 4 bytes
L3_960B:
        lda     #$01
        sta     $17

; ---- bank3.code_960F (code) $960F-$9615, 7 bytes
        lda     $41
        and     $07A0,X
        bne     L3_9638

; ---- bank3.code_9616 (code) $9616-$961A, 5 bytes
        jsr     L7_C108
        bcs     L3_9638

; ---- bank3.code_961B (code) $961B-$961F, 5 bytes
        lda     #$27
        jsr     L7_C105

; ---- bank3.code_9620 (code) $9620-$9627, 8 bytes
        lda     $0518,Y
        adc     #$24
        sta     $0518,Y

; ---- bank3.code_9628 (code) $9628-$9632, 11 bytes
        inc     $0638,X
        lda     $0638,X
        ora     #$08
        sta     $0788,Y

; ---- bank3.code_9633 (code) $9633-$9637, 5 bytes
        lda     #$00
        sta     $07A0,Y

; ---- bank3.code_9638 (code) $9638-$9650, 25 bytes
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

; ---- bank3.code_9651 (code) $9651-$9666, 22 bytes
        lda     $0518,X
        cmp     #$10
        bcs     L3_9667
        lda     $05D8,X
        bpl     L3_9667
        lda     #$04
        sta     $05D8,X
        lda     #$00
        sta     $05C0,X

; ---- bank3.code_9667 (code) $9667-$966B, 5 bytes
L3_9667:
        lda     $0788,X
        beq     L3_966D

; ---- bank3.code_966C (code) $966C-$966C, 1 bytes
        rts

; ---- bank3.code_966D (code) $966D-$9672, 6 bytes
L3_966D:
        jsr     L7_C0C6
        jmp     L7_C0D8

; ---- bank3.tbl_9673 (data) $9673-$9674, 2 bytes
; Fleepa palette by type
        .byte   $02,$00

; ---- bank3.tbl_9675 (data) $9675-$9676, 2 bytes
; Fleepa fire mask by type
        .byte   $0F,$07

; ---- bank3.tbl_9677 (data) $9677-$9678, 2 bytes
; Fleepa palette flip
        .byte   $00,$40

; ---- bank3.tbl_9679 (data) $9679-$967A, 2 bytes
; Fleepa wing metasprite
        .byte   $84,$85

; ---- bank3.tbl_967B (data) $967B-$967D, 3 bytes
; Fleepa head flip by side state
        .byte   $00,$40,$00

; ---- bank3.tbl_967E (data) $967E-$9680, 3 bytes
; Fleepa head tile offset by side state
        .byte   $3A,$36,$36

; ---- bank3.tbl_9681 (data) $9681-$9683, 3 bytes
; Fleepa head metasprite by side state
        .byte   $7B,$19,$19

; ---- bank3.tbl_9684 (data) $9684-$9685, 2 bytes
; Fleepa belly metasprite
        .byte   $86,$87

; ---- bank3.gfx_9686 (graphics) $9686-$9712, 141 bytes
; Tile block: 10 tiles
        .byte   $04,$05,$00,$00,$00,$80,$C0,$FE,$5F,$33,$00,$00,$00,$80,$40,$BE
        .byte   $63,$3C,$0E,$01,$04,$00,$06,$04,$0F,$01,$04,$00,$0B,$04,$3E,$D5
        .byte   $EE,$04,$00,$05,$04,$3E,$EB,$17,$4E,$C5,$3E,$04,$00,$05,$04,$B7
        .byte   $FB,$3E,$04,$00,$05,$04,$1E,$33,$3D,$3D,$39,$39,$1E,$1A,$1E,$3F
        .byte   $2F,$2F,$27,$27,$12,$16,$1A,$3C,$34,$34,$38,$28,$70,$E0,$16,$34
        .byte   $2C,$2C,$28,$38,$50,$A0,$04,$00,$07,$01,$01,$00,$07,$04,$01,$03
        .byte   $0E,$74,$B7,$7C,$00,$00,$00,$02,$0D,$7B,$CF,$7C,$04,$00,$05,$04
        .byte   $38,$7C,$7A,$FA,$E6,$CC,$00,$00,$38,$64,$5E,$9E,$9E,$3C,$B0,$40
        .byte   $80,$04,$00,$05,$04,$70,$C0,$80,$04,$00,$05,$04,$04

; ---- bank3.gfx_9713 (graphics) $9713-$9772, 96 bytes
; Tile block: 6 tiles
        .byte   $FD,$FF,$FD,$00,$06,$FD,$01,$06,$FD,$00,$06,$FD,$01,$07,$09,$13
        .byte   $17,$17,$12,$09,$06,$00,$0E,$1C,$18,$18,$1D,$0F,$06,$00,$10,$38
        .byte   $70,$70,$E0,$E0,$C0,$C0,$10,$28,$50,$50,$A0,$A0,$40,$40,$A0,$A0
        .byte   $A0,$60,$40,$80,$00,$00,$60,$60,$60,$E0,$C0,$80,$00,$00,$10,$28
        .byte   $38,$28,$38,$28,$7C,$44,$10,$38,$28,$38,$28,$38,$6C,$7C,$54,$54
        .byte   $BA,$FE,$BA,$54,$28,$10,$6C,$6C,$C6,$82,$C6,$6C,$38,$10,$FD,$FD

; ---- bank3.gfx_9773 (graphics) $9773-$97EE, 124 bytes
; Tile block: 8 tiles
        .byte   $FE,$FF,$00,$03,$0F,$0F,$1F,$1D,$1D,$1E,$03,$0C,$10,$11,$22,$26
        .byte   $27,$23,$0F,$0F,$03,$FE,$00,$05,$FE,$11,$10,$0C,$03,$FE,$00,$05
        .byte   $FE,$03,$0F,$0F,$1F,$2D,$2D,$13,$03,$0C,$10,$1C,$32,$33,$3F,$3E
        .byte   $0F,$0F,$03,$FE,$00,$05,$FE,$1C,$10,$0C,$03,$FE,$00,$05,$FE,$C0
        .byte   $F0,$F0,$FE,$F8,$04,$FE,$C0,$30,$08,$08,$FE,$04,$04,$FE,$F0,$F0
        .byte   $C0,$FE,$00,$05,$FE,$08,$08,$30,$C0,$FE,$00,$05,$FE,$03,$0F,$0F
        .byte   $1F,$17,$17,$0F,$03,$0C,$10,$10,$28,$2C,$3C,$38,$0F,$0F,$03,$FE
        .byte   $00,$05,$FE,$10,$10,$0C,$03,$FE,$00,$04,$FE,$FE

; ---- bank3.gfx_97EF (graphics) $97EF-$98EA, 252 bytes
; Tile block: 16 tiles
        .byte   $01,$02,$00,$00,$1F,$1F,$1F,$1C,$1C,$1E,$01,$00,$04,$01,$10,$1B
        .byte   $1F,$1F,$1F,$EF,$3B,$C7,$31,$0C,$0F,$10,$1F,$0F,$C3,$F9,$3E,$0F
        .byte   $00,$0F,$00,$10,$38,$AC,$D4,$F6,$7A,$3A,$00,$00,$20,$30,$18,$18
        .byte   $8C,$C4,$1D,$8F,$C7,$E3,$F1,$79,$FF,$7F,$E3,$F1,$F9,$FD,$FF,$FF
        .byte   $3E,$8C,$04,$1A,$32,$26,$6C,$4F,$DF,$BF,$00,$06,$0E,$1E,$1C,$38
        .byte   $30,$60,$F9,$F1,$E3,$C7,$0F,$1E,$BF,$FC,$C7,$8F,$1F,$3F,$FF,$FF
        .byte   $FC,$63,$01,$00,$05,$C0,$03,$00,$06,$40,$01,$C0,$03,$01,$DC,$E0
        .byte   $8C,$3E,$E3,$00,$C0,$C0,$C0,$9C,$7C,$E0,$1C,$FF,$00,$1F,$07,$03
        .byte   $06,$0C,$19,$33,$1F,$1F,$07,$03,$07,$0F,$1F,$3D,$65,$69,$70,$01
        .byte   $00,$05,$01,$7B,$75,$48,$01,$00,$05,$01,$05,$0E,$FF,$F3,$61,$C3
        .byte   $87,$8E,$FE,$01,$FF,$04,$01,$FD,$F9,$F1,$FD,$FD,$0A,$0A,$14,$14
        .byte   $08,$00,$82,$06,$0C,$0C,$18,$18,$00,$00,$C0,$60,$9F,$0E,$07,$C3
        .byte   $E1,$F0,$7F,$01,$FF,$04,$01,$BF,$9F,$8F,$F8,$5C,$2E,$2F,$15,$14
        .byte   $0A,$04,$C7,$23,$11,$18,$0C,$0C,$06,$00,$07,$FC,$C0,$60,$30,$D8
        .byte   $E8,$F8,$FF,$FC,$C0,$E0,$F0,$B8,$D8,$E8,$60,$30,$30,$F0,$F0,$00
        .byte   $00,$00,$E0,$F0,$F0,$30,$10,$00,$00,$00,$01,$01

; ---- bank3.gfx_98EB (graphics) $98EB-$992C, 66 bytes
; Tile block: 4 tiles
        .byte   $01,$04,$3F,$6E,$DC,$B0,$C0,$80,$C5,$88,$20,$51,$A3,$CF,$BF,$FF
        .byte   $BA,$F7,$D4,$B8,$FF,$E0,$E0,$E0,$60,$3F,$AB,$C7,$C0,$FF,$FF,$FF
        .byte   $7F,$3F,$FC,$1A,$35,$6B,$55,$AD,$19,$33,$00,$E4,$CA,$94,$AA,$52
        .byte   $E6,$CC,$65,$CB,$FF,$03,$03,$03,$02,$FC,$9A,$34,$00,$01,$FC,$05
        .byte   $01,$01

; ---- bank3.gfx_992D (graphics) $992D-$9990, 100 bytes
; Tile block: 8 tiles
        .byte   $06,$07,$06,$00,$06,$06,$03,$1E,$06,$00,$05,$06,$03,$0C,$01,$03
        .byte   $06,$00,$07,$06,$0C,$03,$06,$00,$0D,$01,$01,$00,$06,$01,$01,$02
        .byte   $02,$06,$03,$04,$08,$06,$00,$04,$06,$05,$04,$0B,$04,$06,$00,$07
        .byte   $08,$03,$06,$1C,$14,$06,$00,$04,$14,$02,$06,$22,$2A,$14,$1C,$06
        .byte   $08,$03,$00,$03,$06,$2A,$22,$14,$14,$06,$00,$09,$06,$18,$3C,$7E
        .byte   $06,$00,$06,$06,$18,$24,$7E,$3C,$18,$06,$00,$05,$06,$24,$18,$06
        .byte   $00,$06,$06,$06

; ---- bank3.gfx_9991 (graphics) $9991-$9A72, 226 bytes
; Tile block: 14 tiles
        .byte   $05,$06,$05,$00,$05,$05,$02,$04,$38,$00,$00,$00,$03,$07,$0F,$1F
        .byte   $3F,$0C,$0C,$14,$28,$32,$16,$16,$30,$37,$37,$2F,$1F,$1F,$3F,$3F
        .byte   $3F,$08,$0E,$33,$23,$7F,$61,$C1,$E1,$07,$7F,$FD,$FC,$FE,$FF,$FF
        .byte   $FE,$CC,$D2,$AD,$AD,$B3,$9E,$41,$3F,$FF,$FF,$F3,$F3,$05,$FF,$04
        .byte   $05,$20,$60,$C0,$F8,$1C,$16,$F3,$1B,$C0,$BC,$FE,$FF,$EF,$EF,$FF
        .byte   $EF,$9B,$77,$7B,$7B,$7F,$FC,$FA,$02,$6F,$EF,$F7,$97,$FB,$8F,$FF
        .byte   $FF,$30,$18,$1C,$0F,$11,$15,$2B,$34,$05,$3F,$05,$05,$1B,$37,$2C
        .byte   $44,$28,$1C,$04,$02,$09,$01,$00,$7C,$78,$3C,$3C,$0E,$0F,$03,$00
        .byte   $07,$0F,$0C,$18,$D8,$F8,$97,$07,$FF,$F8,$FB,$F7,$F7,$FF,$8F,$3F
        .byte   $18,$58,$6C,$32,$02,$00,$00,$00,$28,$78,$74,$3E,$02,$00,$00,$00
        .byte   $E0,$F0,$30,$18,$1B,$1F,$ED,$D1,$FF,$1F,$DF,$EF,$EF,$FF,$FD,$E9
        .byte   $29,$14,$28,$4B,$5C,$60,$80,$80,$35,$1C,$38,$7B,$6F,$57,$E0,$C0
        .byte   $0C,$18,$38,$ED,$D4,$94,$A4,$04,$05,$FE,$04,$F7,$02,$05,$D7,$F6
        .byte   $20,$90,$A0,$80,$60,$00,$00,$00,$D0,$E0,$D0,$E0,$E0,$00,$00,$00
        .byte   $05,$05

; ---- bank3.gfx_9A73 (graphics) $9A73-$9AA4, 50 bytes
; Tile block: 4 tiles
        .byte   $01,$02,$01,$00,$11,$01,$20,$4C,$84,$80,$41,$3E,$00,$00,$3E,$73
        .byte   $FB,$FF,$7F,$3E,$01,$00,$07,$01,$10,$20,$01,$00,$06,$01,$1C,$3E
        .byte   $4C,$44,$40,$40,$22,$1C,$00,$00,$72,$7A,$7E,$7E,$3E,$1C,$00,$00
        .byte   $01,$01

; ---- bank3.gfx_9AA5 (graphics) $9AA5-$9B08, 100 bytes
; Tile block: 6 tiles
        .byte   $02,$03,$00,$00,$1F,$01,$3C,$50,$26,$48,$00,$07,$26,$7F,$FF,$6F
        .byte   $5F,$3F,$12,$2A,$5C,$49,$12,$30,$10,$00,$FF,$F7,$EF,$FE,$7D,$7F
        .byte   $1F,$18,$00,$E9,$72,$80,$3A,$7D,$3E,$34,$30,$75,$BF,$FF,$C5,$82
        .byte   $C1,$CB,$80,$36,$92,$23,$25,$70,$D0,$00,$FF,$FF,$7F,$FF,$FB,$FF
        .byte   $DE,$04,$00,$60,$20,$F8,$0E,$40,$78,$0E,$00,$A0,$F8,$FC,$F6,$FE
        .byte   $FF,$FF,$6A,$94,$D8,$4E,$A0,$40,$20,$00,$F6,$7B,$3F,$BF,$DB,$79
        .byte   $38,$00,$02,$02

; ---- bank3.gfx_9B09 (graphics) $9B09-$9B4C, 68 bytes
; Tile block: 4 tiles
        .byte   $01,$02,$04,$0F,$7F,$A8,$7B,$BE,$3D,$3D,$07,$0C,$7B,$F7,$B7,$3F
        .byte   $3E,$1E,$7E,$7F,$7B,$5E,$BF,$5F,$07,$00,$6F,$73,$5E,$3F,$7F,$DF
        .byte   $07,$00,$26,$F9,$F6,$10,$DC,$7C,$BC,$BC,$E6,$3F,$D8,$E8,$EC,$FC
        .byte   $7C,$78,$7E,$FE,$D2,$7C,$FC,$F8,$E0,$00,$F6,$C2,$7E,$FC,$FC,$F8
        .byte   $E0,$00,$01,$01

; ---- bank3.gfx_9B4D (graphics) $9B4D-$9C05, 185 bytes
; Tile block: 12 tiles
        .byte   $08,$09,$00,$02,$02,$05,$06,$02,$05,$04,$03,$07,$0F,$0B,$1B,$1F
        .byte   $1E,$1F,$0C,$0C,$14,$0E,$06,$08,$01,$03,$1F,$03,$08,$17,$0B,$0F
        .byte   $07,$03,$80,$A0,$50,$40,$D0,$D0,$C0,$20,$40,$60,$E0,$F0,$E8,$68
        .byte   $78,$F8,$20,$20,$60,$50,$A0,$80,$00,$00,$08,$F8,$04,$08,$D0,$F0
        .byte   $E0,$C0,$08,$00,$04,$08,$04,$0A,$05,$12,$00,$00,$00,$03,$0F,$17
        .byte   $1B,$3F,$32,$1A,$06,$1A,$17,$01,$00,$00,$1F,$2F,$3F,$1F,$1B,$0F
        .byte   $03,$08,$00,$04,$80,$02,$08,$78,$E0,$48,$00,$00,$00,$40,$70,$D8
        .byte   $D8,$F4,$48,$F0,$50,$10,$10,$60,$80,$00,$F4,$3C,$BC,$F8,$F8,$F0
        .byte   $C0,$08,$00,$08,$10,$01,$00,$05,$08,$03,$0F,$1F,$0E,$4B,$66,$5A
        .byte   $24,$2C,$0C,$06,$3F,$77,$FB,$BF,$FF,$77,$3F,$0F,$08,$00,$07,$78
        .byte   $01,$00,$05,$08,$C0,$F0,$98,$70,$EC,$20,$D0,$59,$16,$10,$20,$FC
        .byte   $F2,$FF,$3F,$BF,$FE,$FC,$F0,$08,$08

; ---- bank3.gfx_9C06 (graphics) $9C06-$9C49, 68 bytes
; Tile block: 4 tiles
        .byte   $08,$0B,$00,$00,$0E,$1F,$05,$0A,$0A,$09,$00,$00,$0E,$1B,$1F,$17
        .byte   $17,$17,$0A,$02,$06,$02,$01,$01,$01,$01,$17,$0F,$0F,$07,$07,$03
        .byte   $01,$01,$00,$02,$77,$8E,$34,$4A,$41,$42,$00,$02,$75,$FE,$CE,$B7
        .byte   $BF,$BF,$04,$0C,$0C,$14,$22,$21,$01,$00,$FF,$FF,$FF,$77,$67,$69
        .byte   $41,$00,$08,$08

; ---- bank3.gfx_9C4A (graphics) $9C4A-$9C6C, 35 bytes
; Tile block: 2 tiles
        .byte   $01,$02,$01,$00,$04,$01,$14,$4C,$33,$B2,$01,$00,$04,$01,$28,$3E
        .byte   $CA,$4B,$43,$C6,$3E,$28,$01,$00,$04,$01,$F2,$47,$7C,$14,$01,$00
        .byte   $04,$01,$01

; ---- bank3.gfx_9C6D (graphics) $9C6D-$9CB0, 68 bytes
; Tile block: 4 tiles
        .byte   $00,$01,$1E,$33,$2D,$3F,$2D,$29,$35,$2B,$1E,$3F,$33,$21,$33,$37
        .byte   $2B,$35,$4A,$52,$A4,$B4,$28,$48,$68,$48,$76,$6E,$DC,$CC,$D8,$B8
        .byte   $98,$B8,$A8,$94,$64,$54,$5E,$5A,$6A,$5A,$D8,$EC,$5C,$6C,$66,$66
        .byte   $56,$66,$4A,$D2,$A4,$54,$AC,$54,$CA,$0E,$76,$EE,$DC,$AC,$74,$DC
        .byte   $CE,$0E,$00,$00

; ---- bank3.gfx_9CB1 (graphics) $9CB1-$9DDC, 300 bytes
; Tile block: 20 tiles
        .byte   $09,$0B,$09,$00,$04,$09,$02,$05,$02,$09,$00,$04,$09,$03,$0D,$1A
        .byte   $1D,$3F,$02,$04,$02,$05,$02,$00,$00,$00,$1D,$1B,$0D,$02,$01,$09
        .byte   $00,$08,$09,$21,$08,$42,$00,$07,$CF,$09,$FF,$05,$09,$08,$42,$A8
        .byte   $11,$0A,$14,$00,$00,$FF,$BF,$57,$EE,$B5,$2B,$1E,$00,$00,$00,$02
        .byte   $15,$08,$05,$08,$11,$00,$03,$05,$0A,$37,$7A,$77,$EE,$2A,$04,$08
        .byte   $15,$08,$00,$00,$00,$D5,$FB,$77,$2A,$37,$1F,$02,$00,$00,$00,$0A
        .byte   $40,$20,$08,$15,$28,$1D,$3F,$F5,$BF,$DF,$FF,$FF,$FF,$05,$00,$88
        .byte   $10,$22,$54,$28,$00,$FF,$FF,$77,$EF,$DD,$AB,$D7,$FE,$09,$00,$04
        .byte   $09,$01,$02,$01,$09,$00,$04,$09,$03,$06,$05,$0E,$0F,$02,$01,$09
        .byte   $00,$06,$09,$05,$06,$03,$09,$00,$05,$09,$6A,$39,$28,$56,$2F,$5A
        .byte   $1A,$45,$7D,$7E,$7F,$FF,$FF,$EF,$F5,$FA,$88,$05,$0A,$09,$00,$05
        .byte   $09,$77,$DA,$15,$0F,$09,$00,$07,$09,$04,$0A,$05,$02,$00,$00,$00
        .byte   $0F,$1B,$15,$3A,$7D,$7F,$02,$04,$0A,$05,$02,$00,$00,$00,$7D,$3B
        .byte   $15,$1A,$0D,$02,$00,$00,$F3,$E7,$FF,$E7,$D7,$CF,$93,$58,$EF,$FF
        .byte   $FF,$DF,$EF,$FF,$FF,$F7,$08,$42,$A8,$11,$0A,$14,$00,$00,$FF,$BF
        .byte   $57,$EE,$B5,$2B,$1E,$00,$04,$18,$2A,$59,$4C,$93,$A8,$B4,$07,$1F
        .byte   $3D,$6E,$7F,$FF,$F7,$EB,$EB,$E3,$FF,$D7,$E7,$9B,$9B,$54,$F7,$FF
        .byte   $DF,$EF,$DF,$EF,$F7,$7B,$09,$00,$10,$09,$04,$18,$2A,$59,$4C,$93
        .byte   $A8,$B4,$07,$1F,$3D,$6E,$7F,$FF,$F7,$EB,$09,$09

; ---- bank3.gfx_9DDD (graphics) $9DDD-$9E40, 100 bytes
; Tile block: 6 tiles
        .byte   $FE,$FF,$00,$00,$03,$0F,$FE,$1F,$04,$FE,$00,$00,$03,$0F,$1F,$1F
        .byte   $3F,$3F,$0F,$23,$11,$1D,$0F,$03,$00,$00,$3F,$3F,$1E,$1E,$0F,$03
        .byte   $FE,$00,$04,$FE,$C0,$F0,$FE,$F8,$04,$FE,$00,$00,$C0,$F0,$F8,$F8
        .byte   $FC,$FC,$F0,$C4,$08,$38,$F0,$C0,$00,$00,$FC,$FC,$F8,$F8,$F0,$C0
        .byte   $FE,$00,$04,$FE,$C0,$F0,$FE,$F8,$04,$FE,$00,$00,$C0,$F0,$F8,$F8
        .byte   $FC,$FC,$F8,$DC,$18,$38,$F0,$C0,$00,$00,$F4,$E4,$E8,$F8,$F0,$C0
        .byte   $00,$00,$FE,$FE

; ---- bank3.gfx_9E41 (graphics) $9E41-$A36D, 1325 bytes
; Tile block: 86 tiles
        .byte   $ED,$F2,$ED,$00,$04,$ED,$01,$02,$02,$04,$00,$00,$00,$01,$02,$05
        .byte   $05,$0B,$04,$08,$09,$0F,$0F,$0C,$08,$1F,$0B,$17,$17,$17,$1F,$0F
        .byte   $0F,$1F,$08,$08,$18,$B0,$20,$60,$40,$C0,$38,$78,$F8,$70,$E0,$E0
        .byte   $C0,$C0,$C0,$E0,$E0,$E0,$F0,$F0,$38,$3C,$C0,$E0,$E0,$E0,$F0,$70
        .byte   $D8,$DC,$03,$07,$0F,$0E,$1D,$1D,$1E,$0F,$00,$00,$00,$01,$03,$03
        .byte   $01,$00,$07,$18,$37,$63,$60,$C4,$D3,$CE,$08,$1F,$3F,$7F,$7F,$FF
        .byte   $FF,$FF,$E7,$F9,$FD,$7E,$BE,$BE,$7E,$FD,$1F,$07,$03,$81,$C1,$41
        .byte   $81,$03,$F3,$07,$FA,$02,$06,$FD,$85,$5A,$0F,$ED,$FF,$06,$ED,$BF
        .byte   $9F,$BB,$CD,$CE,$DF,$F8,$E1,$C3,$EB,$EC,$FE,$FF,$FF,$FF,$FE,$FC
        .byte   $8C,$93,$2F,$5F,$9F,$3F,$7F,$F7,$F3,$EF,$DF,$BC,$F0,$E0,$C0,$C8
        .byte   $01,$03,$07,$03,$05,$02,$03,$06,$00,$00,$01,$05,$06,$07,$0F,$0F
        .byte   $06,$02,$04,$04,$04,$06,$06,$03,$07,$0F,$1F,$1F,$3F,$3F,$3F,$1F
        .byte   $7C,$B0,$D1,$51,$A2,$66,$41,$C1,$FF,$7F,$3E,$BE,$7D,$FD,$FE,$FE
        .byte   $C8,$C0,$60,$30,$1D,$46,$38,$03,$ED,$FF,$04,$ED,$FE,$B9,$C7,$FF
        .byte   $1B,$B2,$76,$65,$EF,$EC,$6D,$66,$FF,$7F,$FF,$FE,$FC,$FF,$FE,$FF
        .byte   $33,$99,$0C,$6E,$87,$03,$F1,$FE,$FF,$FF,$FF,$9F,$7F,$FF,$FF,$FF
        .byte   $5E,$BD,$BB,$57,$77,$FB,$3D,$CE,$A1,$43,$46,$AE,$8F,$07,$C3,$31
        .byte   $77,$B9,$CF,$73,$78,$9F,$EF,$F9,$88,$C6,$F0,$FC,$BF,$EF,$F3,$FE
        .byte   $0B,$05,$0C,$0A,$1A,$1D,$0C,$06,$17,$0B,$0B,$1D,$3D,$7E,$7F,$7F
        .byte   $03,$08,$26,$31,$1C,$1F,$27,$26,$7F,$37,$39,$3E,$3F,$6F,$5F,$DE
        .byte   $8F,$DF,$FF,$3F,$1F,$0F,$C3,$00,$FF,$FC,$F8,$F8,$FC,$FE,$3F,$FF
        .byte   $8C,$71,$67,$9F,$7F,$FF,$7F,$3F,$F3,$EF,$9F,$7C,$FE,$FF,$7F,$1F
        .byte   $FF,$FF,$CF,$B7,$B7,$CF,$FD,$78,$0F,$03,$31,$68,$78,$33,$86,$FF
        .byte   $07,$90,$EE,$F1,$BF,$DD,$FB,$FB,$FF,$EF,$F1,$FF,$FF,$FF,$9F,$DF
        .byte   $3F,$D7,$EB,$FB,$9B,$37,$F3,$EF,$ED,$FF,$05,$ED,$FB,$7F,$F6,$97
        .byte   $2F,$1D,$FB,$F4,$E0,$83,$0F,$EE,$DE,$FE,$FC,$FB,$FF,$FD,$F1,$46
        .byte   $44,$4C,$48,$ED,$28,$04,$ED,$BE,$BC,$BC,$B8,$58,$58,$58,$18,$18
        .byte   $10,$ED,$00,$06,$ED,$28,$10,$ED,$00,$06,$ED,$3F,$1F,$0F,$0F,$17
        .byte   $17,$2F,$4F,$1F,$2F,$17,$0F,$1F,$1F,$3B,$73,$C3,$D3,$C4,$68,$6F
        .byte   $31,$44,$88,$FE,$FC,$FF,$7F,$7F,$3F,$7B,$F7,$FE,$ED,$FF,$07,$ED
        .byte   $F1,$F9,$FD,$ED,$FF,$08,$ED,$3F,$0F,$F7,$CB,$F5,$FF,$DF,$97,$E7
        .byte   $F7,$FE,$FC,$FE,$7F,$ED,$FF,$07,$ED,$99,$1D,$9D,$DF,$ED,$FF,$12
        .byte   $ED,$FD,$D9,$F3,$9D,$AA,$A5,$97,$48,$2A,$1A,$FF,$FD,$DB,$DE,$EF
        .byte   $7F,$3D,$1D,$0A,$0A,$0A,$08,$08,$04,$06,$02,$0D,$0D,$0D,$0F,$0F
        .byte   $07,$07,$03,$DA,$1D,$AE,$13,$51,$83,$F7,$9E,$FF,$FF,$77,$EF,$EF
        .byte   $FF,$FF,$FF,$AE,$AA,$DA,$DA,$EA,$AA,$99,$00,$DF,$DB,$EB,$EB,$FB
        .byte   $BB,$99,$00,$7F,$80,$F7,$DC,$AE,$4B,$95,$71,$91,$FF,$FF,$FF,$DF
        .byte   $BF,$FB,$FF,$A8,$B0,$A8,$90,$88,$04,$00,$80,$7C,$68,$74,$5C,$4E
        .byte   $C6,$C0,$C0,$01,$02,$06,$0C,$09,$0D,$0B,$0B,$01,$03,$05,$0B,$0F
        .byte   $0B,$0F,$0F,$05,$18,$37,$63,$60,$C4,$D3,$CE,$0F,$1F,$3F,$7F,$7F
        .byte   $FF,$FF,$FF,$03,$3D,$5D,$BE,$42,$9A,$96,$8D,$ED,$FF,$05,$ED,$E7
        .byte   $EF,$FF,$FB,$07,$FA,$02,$06,$FD,$85,$5A,$ED,$FF,$07,$ED,$BF,$9F
        .byte   $BB,$CD,$C6,$CF,$DC,$B7,$6E,$EB,$EC,$FE,$FF,$FF,$FF,$FB,$FF,$D9
        .byte   $B4,$63,$4C,$B0,$45,$20,$9F,$FE,$FB,$FF,$FF,$FF,$FA,$DF,$7F,$1C
        .byte   $B9,$73,$65,$EF,$EF,$68,$61,$FF,$7F,$FF,$FE,$FC,$FF,$FF,$FE,$33
        .byte   $99,$0C,$6E,$87,$03,$F1,$FE,$FF,$FF,$FF,$9F,$7F,$FF,$FF,$FF,$7C
        .byte   $E1,$0B,$57,$F7,$FB,$FD,$3E,$FF,$FF,$F6,$AE,$0F,$87,$C3,$E1,$5F
        .byte   $2F,$CD,$23,$D8,$EF,$F0,$FF,$B0,$D8,$F6,$ED,$FF,$05,$ED,$8F,$DE
        .byte   $FC,$F9,$7B,$78,$BC,$3E,$FF,$FF,$FF,$FE,$FC,$FF,$7F,$FF,$5F,$8F
        .byte   $E1,$B5,$78,$FF,$7F,$3F,$BF,$FF,$DF,$7A,$FF,$FF,$7F,$1F,$FF,$07
        .byte   $03,$81,$01,$61,$F3,$76,$FF,$FF,$FF,$7F,$FF,$FF,$BF,$FF,$FF,$FE
        .byte   $FE,$30,$01,$5D,$FB,$FB,$FF,$FF,$F9,$CF,$FF,$FF,$9F,$DF,$9F,$BB
        .byte   $CD,$CA,$D7,$EC,$92,$27,$EB,$EC,$FE,$FF,$FF,$FF,$FD,$FF,$4C,$99
        .byte   $35,$6F,$8C,$32,$48,$A0,$FF,$FE,$FB,$F7,$FF,$FD,$F7,$5F,$1C,$38
        .byte   $F1,$67,$FE,$F4,$70,$79,$FF,$FF,$7F,$FF,$FF,$FB,$FF,$FF,$33,$99
        .byte   $0C,$6E,$87,$03,$F1,$FE,$FF,$FF,$FF,$9F,$7F,$FF,$FF,$FF,$00,$7F
        .byte   $FF,$D5,$80,$3F,$E0,$00,$FF,$FF,$FF,$EA,$7F,$FF,$FF,$FF,$00,$0F
        .byte   $B8,$C0,$70,$9F,$E4,$ED,$FF,$09,$00,$04,$ED,$01,$00,$03,$0B,$ED
        .byte   $00,$04,$ED,$02,$03,$07,$0F,$05,$1B,$36,$6F,$6D,$C4,$D3,$CE,$0B
        .byte   $1F,$3F,$77,$76,$FB,$FF,$FF,$03,$21,$19,$4E,$16,$AE,$7E,$BD,$07
        .byte   $13,$FB,$3F,$2F,$3F,$FF,$FF,$F9,$A9,$C8,$5A,$AE,$BD,$E5,$7A,$FF
        .byte   $FF,$FF,$EF,$DF,$DF,$BF,$FF,$8F,$DF,$FF,$FF,$7F,$7C,$BF,$3D,$ED
        .byte   $FF,$06,$ED,$7F,$FF,$5F,$8F,$FC,$B5,$7A,$FF,$7E,$3F,$BF,$FF,$DF
        .byte   $7E,$FF,$FF,$7F,$1F,$FF,$FF,$FF,$DF,$5F,$B7,$2F,$5E,$ED,$FF,$06
        .byte   $ED,$DF,$BF,$2F,$6E,$5E,$36,$1B,$3D,$BB,$BB,$FF,$BF,$FF,$CF,$E7
        .byte   $DF,$DF,$DF,$3F,$D7,$EB,$FB,$9B,$37,$B3,$2F,$ED,$FF,$05,$ED,$FB
        .byte   $7F,$F6,$77,$3F,$7D,$7B,$74,$E0,$83,$0F,$BE,$DE,$BE,$FC,$FB,$FF
        .byte   $FD,$F1,$9F,$BB,$CD,$CA,$D7,$EC,$92,$27,$EB,$EC,$FE,$FF,$FF,$FF
        .byte   $FD,$FF,$4C,$99,$3D,$6F,$9F,$3F,$7F,$BF,$FF,$FF,$FB,$FF,$EF,$F7
        .byte   $FF,$7F,$1C,$38,$F1,$67,$FE,$F4,$70,$79,$FF,$FF,$7F,$FF,$FF,$FB
        .byte   $FF,$FF,$33,$99,$0C,$6E,$87,$03,$F1,$FE,$FF,$FF,$FF,$9F,$7F,$FF
        .byte   $FF,$FF,$7F,$7F,$FF,$FF,$FF,$7F,$F0,$6E,$BF,$FF,$FF,$FF,$7F,$BD
        .byte   $FF,$B9,$65,$7A,$F6,$CB,$74,$9F,$E4,$FF,$BA,$FF,$FD,$F7,$FB,$FF
        .byte   $FF,$FF,$3F,$1F,$0F,$0F,$17,$17,$2F,$4F,$1F,$2F,$17,$0F,$1F,$1F
        .byte   $3B,$73,$C3,$D3,$FC,$62,$47,$89,$E1,$93,$FE,$FC,$FF,$7F,$7B,$F7
        .byte   $FF,$FF,$FE,$ED,$FF,$07,$ED,$F1,$F9,$FD,$ED,$FF,$08,$ED,$3F,$0F
        .byte   $F7,$CB,$35,$FF,$DF,$97,$E7,$F7,$FE,$FC,$FE,$94,$89,$AC,$AB,$98
        .byte   $89,$CA,$8A,$FF,$FE,$DF,$DF,$EF,$FF,$FF,$FF,$8A,$82,$C2,$42,$42
        .byte   $04,$04,$03,$FB,$F3,$F3,$73,$73,$17,$07,$03,$9A,$35,$42,$93,$E4
        .byte   $6F,$39,$9A,$7F,$FF,$FF,$EF,$DF,$FF,$FF,$7D,$A9,$A4,$A2,$21,$40
        .byte   $80,$80,$00,$6E,$67,$63,$E1,$C0,$80,$80,$00,$7F,$80,$F7,$9C,$2E
        .byte   $4D,$98,$64,$91,$FF,$FF,$FF,$DF,$BF,$FF,$FB,$7B,$AC,$54,$54,$CC
        .byte   $4A,$54,$40,$F7,$7C,$EC,$EC,$FC,$7E,$76,$60,$ED,$ED

; ---- bank3.gfx_A36E (graphics) $A36E-$A3F1, 132 bytes
; Tile block: 8 tiles
        .byte   $01,$02,$00,$00,$38,$70,$C0,$DC,$7E,$3F,$07,$1F,$3F,$7F,$FF,$FF
        .byte   $E7,$E7,$3E,$1D,$9D,$9C,$DC,$5C,$4C,$60,$FF,$FF,$FB,$FF,$FF,$7B
        .byte   $7F,$7F,$00,$00,$6C,$2E,$03,$03,$06,$FC,$E0,$F8,$9C,$DE,$01,$FF
        .byte   $04,$01,$00,$98,$BD,$3D,$D9,$C2,$C2,$04,$FF,$7F,$E7,$E7,$FF,$BE
        .byte   $FE,$FC,$2B,$3C,$3B,$28,$2E,$51,$9C,$FF,$3F,$3F,$37,$3F,$37,$3F
        .byte   $FF,$7F,$66,$76,$7E,$2F,$0D,$0B,$10,$00,$FF,$FF,$DF,$9D,$3F,$3B
        .byte   $36,$70,$D4,$3C,$DC,$17,$74,$8C,$3C,$FE,$FC,$FC,$EC,$FE,$EF,$FF
        .byte   $FD,$FB,$B3,$B3,$F3,$DE,$F8,$D0,$00,$00,$FF,$FF,$DF,$FE,$FC,$DC
        .byte   $00,$00,$01,$01

; ---- bank3.gfx_A3F2 (graphics) $A3F2-$A475, 132 bytes
; Tile block: 8 tiles
        .byte   $05,$06,$01,$02,$04,$04,$07,$C3,$F3,$FF,$01,$03,$07,$37,$FF,$FE
        .byte   $DF,$9F,$F9,$FC,$EA,$E3,$EE,$FB,$F4,$96,$8F,$FF,$CF,$87,$8F,$DF
        .byte   $FF,$FF,$80,$40,$20,$22,$E4,$FC,$FC,$DC,$80,$C7,$FE,$FE,$FC,$7C
        .byte   $F8,$F0,$9E,$3C,$5C,$D8,$70,$E0,$70,$78,$F8,$FC,$F0,$F0,$F0,$F8
        .byte   $FC,$CC,$8F,$6C,$05,$00,$04,$05,$10,$4C,$EB,$68,$08,$1C,$1C,$1C
        .byte   $3C,$7C,$60,$64,$78,$7F,$1F,$7F,$3F,$0F,$7C,$7C,$78,$7F,$1F,$7F
        .byte   $3F,$0F,$F8,$78,$78,$6C,$05,$80,$04,$05,$CC,$40,$70,$7C,$05,$FC
        .byte   $04,$80,$02,$05,$C0,$E4,$B8,$80,$C0,$F0,$FE,$05,$FC,$04,$05,$FE
        .byte   $FC,$F8,$05,$05

; ---- bank3.gfx_A476 (graphics) $A476-$A4F7, 130 bytes
; Tile block: 8 tiles
        .byte   $06,$09,$00,$00,$00,$04,$01,$03,$1E,$0C,$06,$00,$04,$0F,$02,$06
        .byte   $1F,$3F,$1C,$0E,$1F,$0C,$05,$00,$00,$00,$2F,$1F,$1F,$17,$0E,$01
        .byte   $06,$00,$06,$06,$A0,$D0,$F8,$F0,$00,$00,$00,$60,$D0,$F0,$F4,$7C
        .byte   $78,$68,$C0,$E0,$60,$00,$00,$00,$F8,$F0,$F8,$F8,$E0,$80,$06,$00
        .byte   $04,$06,$08,$00,$01,$02,$5C,$08,$00,$08,$14,$1C,$0F,$CF,$BF,$FF
        .byte   $08,$0C,$1E,$07,$04,$20,$00,$00,$7F,$1F,$1F,$3F,$7F,$53,$21,$00
        .byte   $00,$00,$08,$00,$80,$D1,$30,$50,$00,$10,$30,$78,$F9,$F6,$FE,$BC
        .byte   $18,$20,$40,$E0,$62,$00,$00,$40,$F8,$F8,$FC,$FE,$ED,$87,$C0,$80
        .byte   $06,$06

; ---- bank3.gfx_A4F8 (graphics) $A4F8-$A670, 377 bytes
; Tile block: 26 tiles
        .byte   $F9,$FA,$00,$00,$F9,$80,$06,$F9,$00,$00,$80,$C0,$C0,$E0,$E0,$F0
        .byte   $80,$40,$40,$20,$13,$0C,$03,$00,$FC,$7F,$7F,$3F,$1C,$0F,$03,$00
        .byte   $10,$0C,$03,$F9,$00,$05,$F9,$1C,$1F,$0F,$07,$07,$0F,$0F,$3F,$00
        .byte   $01,$2A,$5D,$A3,$CE,$31,$C0,$FF,$FE,$D5,$A2,$5C,$3F,$F1,$C0,$70
        .byte   $3C,$16,$0B,$0B,$05,$05,$07,$70,$2C,$1E,$0F,$0F,$07,$07,$05,$09
        .byte   $0F,$16,$1A,$14,$2C,$34,$24,$0F,$09,$1A,$16,$1C,$34,$2C,$3C,$2C
        .byte   $25,$28,$91,$42,$B2,$B9,$B1,$34,$BC,$F7,$EF,$FF,$CF,$C7,$CF,$99
        .byte   $72,$55,$54,$2B,$22,$D5,$39,$E7,$CF,$EE,$EF,$F6,$FF,$FB,$37,$3F
        .byte   $3B,$2D,$7F,$7F,$5D,$49,$3E,$3F,$37,$33,$77,$5D,$7F,$7F,$22,$2A
        .byte   $2A,$2A,$1C,$1C,$1C,$14,$08,$36,$36,$36,$14,$14,$14,$1C,$08,$00
        .byte   $00,$F9,$80,$04,$F9,$A0,$40,$00,$00,$80,$80,$C0,$C0,$C0,$78,$32
        .byte   $0C,$03,$F9,$00,$05,$F9,$3D,$0F,$03,$F9,$00,$08,$F9,$C0,$30,$0E
        .byte   $01,$02,$00,$00,$C0,$F0,$3F,$1F,$0F,$3D,$AE,$58,$07,$D8,$F9,$00
        .byte   $04,$F9,$51,$A7,$FF,$F8,$F9,$00,$14,$F9,$02,$1D,$62,$8C,$90,$90
        .byte   $90,$48,$02,$1F,$7E,$FC,$F0,$F0,$F0,$78,$34,$24,$34,$28,$42,$8D
        .byte   $9D,$8A,$2C,$3C,$2C,$34,$FF,$F3,$E3,$F7,$44,$EF,$98,$B4,$DC,$B4
        .byte   $7C,$7E,$FF,$DF,$E8,$FC,$EC,$CC,$6C,$3A,$BA,$92,$7C,$54,$54,$54
        .byte   $38,$38,$FE,$FE,$44,$6C,$6C,$6C,$28,$28,$38,$28,$10,$F9,$00,$05
        .byte   $F9,$28,$38,$10,$F9,$00,$05,$F9,$78,$DC,$B4,$FE,$FE,$BA,$92,$7C
        .byte   $78,$EC,$CC,$EE,$BA,$FE,$FE,$C7,$54,$54,$57,$F8,$38,$38,$28,$10
        .byte   $EF,$EF,$EF,$E8,$28,$28,$38,$10,$F9,$00,$07,$F9,$02,$F9,$00,$06
        .byte   $F9,$03,$1D,$0F,$70,$80,$F9,$00,$05,$F9,$7F,$F0,$80,$F9,$00,$0B
        .byte   $F9,$58,$AE,$F9,$00,$05,$F9,$F0,$A6,$51,$C2,$3E,$01,$F9,$00,$05
        .byte   $F9,$FD,$3F,$01,$F9,$00,$05,$F9,$F9

; ---- bank3.gfx_A671 (graphics) $A671-$A7D0, 352 bytes
; Tile block: 22 tiles
        .byte   $F3,$F5,$F3,$00,$04,$F3,$03,$02,$02,$1F,$00,$00,$07,$1F,$3D,$7F
        .byte   $FF,$FF,$62,$82,$02,$01,$01,$00,$00,$00,$FF,$FF,$FF,$7F,$1F,$01
        .byte   $00,$00,$00,$21,$50,$B4,$1D,$4B,$1E,$F6,$0F,$7E,$EF,$EB,$FF,$B7
        .byte   $EF,$FB,$92,$0B,$23,$05,$01,$81,$07,$01,$6F,$F6,$DD,$FB,$FF,$FF
        .byte   $1F,$03,$00,$00,$01,$01,$01,$03,$15,$0F,$01,$01,$00,$02,$06,$0C
        .byte   $3A,$FC,$2B,$1B,$65,$8B,$D7,$9F,$AB,$D7,$DF,$F4,$FA,$F4,$A8,$E0
        .byte   $D4,$68,$37,$39,$57,$0B,$42,$71,$78,$3E,$E8,$DE,$AC,$F7,$FD,$FE
        .byte   $CF,$E5,$0E,$E4,$7F,$3F,$1F,$1F,$0F,$00,$FF,$5B,$C9,$6D,$7F,$37
        .byte   $13,$0F,$F3,$00,$04,$F3,$06,$05,$05,$12,$00,$00,$00,$01,$05,$0E
        .byte   $3E,$6F,$2B,$22,$0B,$5F,$38,$00,$00,$00,$57,$DD,$F7,$BC,$74,$60
        .byte   $00,$00,$00,$04,$14,$A2,$52,$4B,$13,$47,$00,$07,$2F,$5F,$AF,$B7
        .byte   $EF,$BA,$9F,$FF,$F0,$F3,$00,$05,$F3,$FE,$E2,$F3,$00,$06,$F3,$8B
        .byte   $67,$F9,$7E,$3C,$00,$E4,$7F,$7C,$FF,$DE,$C7,$FF,$FF,$DB,$C9,$3F
        .byte   $3F,$3F,$1F,$1F,$0F,$00,$00,$ED,$7F,$7F,$7F,$37,$13,$0F,$F3,$00
        .byte   $04,$F3,$05,$0F,$3F,$7F,$FF,$00,$00,$03,$1F,$7E,$F0,$C0,$C0,$FD
        .byte   $7F,$7F,$3D,$1F,$07,$00,$00,$C2,$C0,$00,$02,$F3,$00,$05,$F3,$07
        .byte   $7F,$FF,$FB,$DD,$F6,$6F,$0F,$3E,$F8,$C0,$04,$22,$09,$90,$BB,$EF
        .byte   $B6,$FF,$6B,$EF,$7E,$0F,$44,$10,$49,$00,$94,$10,$01,$00,$0C,$0F
        .byte   $3F,$3F,$1C,$04,$B9,$FF,$03,$3B,$0F,$6B,$7B,$FB,$FF,$E7,$E5,$CF
        .byte   $FE,$FD,$F6,$F8,$F6,$F8,$FA,$70,$21,$52,$29,$57,$29,$17,$68,$D4
        .byte   $E0,$A8,$74,$DA,$F4,$D6,$97,$2B,$1F,$57,$8B,$25,$0B,$29,$FC,$3A
        .byte   $0C,$06,$02,$00,$01,$01,$03,$05,$03,$01,$01,$01,$00,$00,$F3,$F3

; ---- bank3.gfx_A7D1 (graphics) $A7D1-$A9C3, 499 bytes
; Tile block: 32 tiles
        .byte   $09,$0D,$03,$05,$F2,$79,$FE,$F9,$F0,$00,$FD,$FA,$2D,$27,$FF,$56
        .byte   $5F,$FF,$21,$03,$02,$04,$04,$00,$00,$00,$5F,$3F,$1F,$0F,$07,$07
        .byte   $03,$09,$00,$06,$09,$05,$0A,$05,$00,$00,$00,$03,$07,$0A,$15,$3B
        .byte   $0B,$17,$0E,$3C,$FE,$BB,$F3,$61,$37,$6F,$7F,$FF,$DF,$DE,$FF,$FF
        .byte   $03,$17,$0B,$57,$2C,$1C,$FF,$FF,$01,$0B,$F7,$AE,$DF,$FF,$7F,$FF
        .byte   $CF,$95,$2E,$55,$2C,$16,$AF,$1D,$FF,$EE,$D5,$AE,$D7,$EF,$5F,$FB
        .byte   $E0,$95,$8A,$51,$80,$3C,$FA,$F5,$C0,$EA,$75,$AE,$78,$FA,$FC,$EA
        .byte   $AA,$55,$BB,$5F,$AA,$5D,$8A,$FD,$75,$BA,$5D,$BE,$5D,$AA,$FD,$FB
        .byte   $00,$40,$AA,$09,$00,$06,$09,$A0,$55,$00,$00,$03,$06,$0E,$80,$20
        .byte   $A0,$44,$C8,$D8,$B0,$F0,$1C,$BC,$BC,$F8,$F8,$B8,$F8,$E8,$03,$E5
        .byte   $72,$5D,$06,$8D,$F8,$E0,$FD,$9A,$3D,$0F,$07,$06,$57,$5F,$20,$01
        .byte   $21,$11,$0B,$02,$02,$00,$DF,$7F,$5F,$2F,$17,$1F,$07,$01,$B2,$E5
        .byte   $CA,$8F,$FE,$FD,$F8,$9D,$FD,$FA,$F5,$FF,$FD,$FE,$DF,$FA,$8E,$DD
        .byte   $8E,$57,$A2,$01,$03,$54,$FD,$AE,$75,$AA,$5F,$FF,$FD,$A8,$BB,$77
        .byte   $FE,$D5,$EA,$71,$A8,$74,$75,$EB,$7D,$EA,$D5,$EE,$76,$B8,$B8,$18
        .byte   $20,$09,$00,$05,$09,$50,$F8,$D0,$E0,$C0,$80,$00,$00,$B0,$D0,$D8
        .byte   $C8,$EC,$24,$00,$04,$F8,$BC,$FC,$FC,$DC,$BC,$1C,$1A,$02,$09,$00
        .byte   $06,$09,$01,$0C,$0E,$06,$06,$02,$03,$01,$00,$00,$40,$AA,$09,$00
        .byte   $06,$09,$A0,$55,$00,$18,$10,$10,$30,$80,$40,$C0,$50,$A0,$A0,$A0
        .byte   $C0,$30,$09,$F0,$03,$E0,$04,$09,$C0,$E0,$A0,$A0,$B0,$10,$10,$00
        .byte   $F0,$B0,$F0,$F0,$D0,$F0,$30,$30,$09,$00,$08,$30,$03,$10,$02,$18
        .byte   $01,$08,$05,$09,$14,$2A,$1C,$2A,$1C,$00,$00,$14,$08,$14,$22,$14
        .byte   $22,$2A,$1C,$08,$08,$6B,$7F,$2A,$6B,$14,$22,$77,$36,$77,$36,$77
        .byte   $77,$08,$14,$3E,$14,$22,$77,$7F,$3E,$36,$2A,$14,$6A,$5D,$49,$36
        .byte   $6B,$1E,$00,$00,$28,$14,$08,$10,$08,$7F,$3E,$3E,$16,$08,$14,$0C
        .byte   $00,$08,$14,$3E,$14,$3E,$7F,$7F,$7F,$36,$2A,$14,$6A,$55,$5D,$7F
        .byte   $2A,$3F,$1C,$00,$28,$14,$08,$10,$08,$62,$3E,$3E,$16,$08,$14,$0C
        .byte   $00,$10,$10,$10,$68,$B4,$58,$54,$48,$00,$00,$28,$50,$E8,$74,$78
        .byte   $7C,$4C,$48,$4C,$68,$74,$34,$34,$6C,$78,$7C,$FE,$FC,$09,$FE,$04
        .byte   $09,$4C,$5C,$54,$54,$74,$6C,$6C,$4C,$FE,$F6,$FE,$FE,$EE,$FE,$FE
        .byte   $FE,$4C,$48,$50,$54,$58,$90,$A8,$D0,$FE,$FC,$7C,$78,$70,$F8,$F0
        .byte   $C0,$09,$09

; ---- bank3.gfx_A9C4 (graphics) $A9C4-$AA87, 196 bytes
; Tile block: 12 tiles
        .byte   $FB,$FD,$00,$10,$28,$10,$44,$7C,$00,$38,$10,$38,$38,$28,$7C,$6C
        .byte   $38,$28,$18,$00,$54,$38,$00,$10,$BA,$FE,$38,$38,$6C,$7C,$FE,$EE
        .byte   $C6,$FE,$38,$00,$7C,$D6,$92,$00,$38,$28,$C6,$FE,$FE,$EE,$EE,$FE
        .byte   $7C,$3C,$10,$38,$10,$10,$38,$10,$10,$10,$28,$38,$28,$28,$38,$28
        .byte   $FB,$00,$04,$FB,$01,$07,$0E,$01,$00,$00,$00,$01,$07,$1D,$FF,$1F
        .byte   $00,$00,$00,$01,$06,$05,$09,$F3,$1F,$26,$01,$06,$1F,$7B,$77,$FF
        .byte   $EF,$DF,$00,$80,$C0,$90,$D0,$F0,$18,$28,$20,$60,$C0,$F0,$F8,$FC
        .byte   $7C,$DC,$D8,$70,$70,$D0,$A0,$C0,$00,$80,$FC,$FC,$F8,$F0,$C0,$C0
        .byte   $C0,$40,$37,$3E,$73,$0D,$04,$03,$03,$00,$CF,$CF,$7F,$73,$1B,$0D
        .byte   $07,$01,$10,$00,$20,$60,$20,$18,$16,$03,$1C,$32,$42,$64,$10,$28
        .byte   $1B,$06,$C0,$80,$40,$A0,$A0,$E0,$60,$70,$C0,$40,$A0,$E0,$E0,$F0
        .byte   $F8,$BC,$14,$38,$08,$0A,$0E,$10,$70,$50,$7C,$3E,$FB,$1E,$04,$FB
        .byte   $7C,$F8,$FB,$FB

; ---- bank3.gfx_AA88 (graphics) $AA88-$AB96, 271 bytes
; Tile block: 18 tiles
        .byte   $FB,$FD,$18,$28,$50,$50,$70,$50,$50,$A8,$18,$38,$FB,$70,$05,$FB
        .byte   $D8,$B8,$E8,$A4,$94,$9A,$7E,$4D,$25,$F8,$D8,$DC,$EC,$FE,$66,$73
        .byte   $3B,$17,$1E,$0B,$09,$06,$04,$05,$02,$1F,$19,$0C,$0F,$07,$07,$06
        .byte   $03,$03,$02,$02,$03,$02,$02,$07,$05,$FB,$03,$06,$FB,$07,$06,$80
        .byte   $40,$20,$E0,$B0,$D0,$68,$E8,$80,$C0,$E0,$E0,$70,$30,$98,$F8,$78
        .byte   $C8,$E8,$E8,$78,$C8,$E8,$E8,$98,$38,$D8,$38,$98,$38,$D8,$38,$05
        .byte   $0B,$0F,$0F,$1F,$27,$3E,$6E,$06,$0F,$0C,$0F,$18,$38,$3D,$73,$5E
        .byte   $5B,$7D,$FA,$FE,$B2,$FA,$FA,$63,$67,$43,$FE,$86,$CE,$86,$FE,$D0
        .byte   $D0,$D0,$E0,$A0,$C0,$C0,$80,$30,$B0,$70,$60,$E0,$C0,$C0,$80,$80
        .byte   $FB,$00,$07,$FB,$80,$FB,$00,$07,$FB,$F6,$BA,$F2,$BA,$FA,$FF,$9B
        .byte   $79,$8E,$C6,$8E,$C6,$BE,$C7,$E7,$47,$5E,$2D,$3F,$26,$13,$17,$19
        .byte   $14,$7F,$33,$20,$39,$1C,$1F,$1E,$1B,$FB,$00,$10,$FB,$80,$C0,$40
        .byte   $A0,$20,$D0,$70,$10,$80,$C0,$C0,$60,$E0,$F0,$F0,$F0,$11,$07,$0E
        .byte   $1C,$0C,$0C,$36,$23,$FB,$1F,$04,$FB,$0F,$3F,$47,$43,$20,$20,$20
        .byte   $10,$10,$08,$06,$01,$40,$40,$40,$20,$20,$10,$08,$06,$C0,$F0,$38
        .byte   $DC,$D8,$D8,$3C,$E6,$F8,$FC,$FC,$3C,$F8,$FC,$F2,$E1,$02,$02,$02
        .byte   $06,$04,$0C,$18,$20,$FB,$01,$04,$FB,$02,$02,$04,$18,$FB,$FB

; ---- bank3.gfx_AB97 (graphics) $AB97-$ABFA, 100 bytes
; Tile block: 6 tiles
        .byte   $01,$02,$00,$00,$00,$18,$28,$44,$DA,$29,$00,$00,$00,$10,$3C,$66
        .byte   $93,$BD,$44,$82,$99,$2C,$43,$C0,$00,$00,$26,$C3,$D5,$3F,$63,$80
        .byte   $80,$01,$00,$04,$01,$28,$66,$CA,$97,$C1,$00,$00,$00,$30,$78,$F4
        .byte   $E8,$FE,$8D,$C3,$CB,$FE,$7E,$7C,$18,$00,$F2,$FC,$F4,$FC,$66,$7C
        .byte   $18,$00,$20,$00,$38,$10,$50,$A0,$20,$20,$00,$70,$70,$58,$D8,$D0
        .byte   $F0,$B0,$38,$50,$60,$40,$50,$20,$20,$20,$30,$98,$C0,$60,$60,$30
        .byte   $30,$30,$01,$01

; ---- bank3.gfx_ABFB (graphics) $ABFB-$AC7C, 130 bytes
; Tile block: 8 tiles
        .byte   $07,$09,$07,$00,$05,$07,$01,$00,$01,$07,$00,$05,$01,$02,$02,$02
        .byte   $07,$03,$01,$02,$01,$08,$0C,$03,$03,$03,$02,$05,$06,$0F,$0F,$0F
        .byte   $00,$10,$60,$30,$60,$D0,$60,$40,$18,$20,$50,$F0,$90,$B0,$F0,$B0
        .byte   $A0,$90,$60,$80,$40,$B0,$C0,$80,$50,$F0,$F0,$70,$B0,$70,$F0,$F8
        .byte   $05,$12,$1D,$0C,$0F,$03,$16,$3A,$1A,$1D,$1A,$1F,$37,$7C,$29,$7D
        .byte   $FF,$BB,$3E,$16,$6D,$C9,$89,$80,$7F,$BF,$35,$2D,$5F,$AF,$CD,$C4
        .byte   $50,$80,$38,$70,$D0,$A0,$A0,$4C,$AC,$78,$D8,$F8,$EC,$5C,$5E,$BC
        .byte   $FA,$6D,$A6,$FE,$8C,$04,$00,$00,$FC,$BE,$FB,$BB,$CE,$C6,$80,$00
        .byte   $07,$07

; ---- bank3.gfx_AC7D (graphics) $AC7D-$ACE0, 100 bytes
; Tile block: 6 tiles
        .byte   $FD,$FE,$00,$0F,$2D,$5A,$44,$70,$18,$26,$00,$0F,$3A,$65,$7B,$6F
        .byte   $7F,$5F,$03,$E7,$1C,$0A,$05,$06,$02,$00,$FF,$FF,$FF,$FB,$7D,$3F
        .byte   $3E,$0C,$FD,$00,$04,$FD,$4B,$36,$0C,$03,$00,$00,$00,$78,$76,$3D
        .byte   $0F,$03,$01,$00,$00,$01,$01,$00,$00,$07,$01,$00,$00,$01,$02,$07
        .byte   $0F,$1F,$00,$00,$03,$05,$0F,$AD,$5A,$44,$01,$01,$03,$06,$8F,$7A
        .byte   $E5,$FB,$70,$B8,$68,$8B,$4C,$70,$C0,$00,$EF,$DF,$9F,$FF,$FC,$F0
        .byte   $C0,$00,$FD,$FD

; ---- bank3.gfx_ACE1 (graphics) $ACE1-$AE86, 422 bytes
; Tile block: 28 tiles
        .byte   $FA,$FD,$00,$00,$00,$01,$0B,$13,$17,$27,$01,$07,$0F,$0F,$17,$0F
        .byte   $2F,$1F,$4F,$6F,$4F,$5F,$9F,$DF,$9E,$DE,$3F,$1F,$3F,$BF,$7F,$3F
        .byte   $7F,$3F,$00,$40,$C0,$80,$80,$80,$00,$00,$C0,$E0,$E0,$C0,$C0,$C1
        .byte   $81,$81,$00,$00,$02,$02,$00,$04,$04,$08,$83,$83,$85,$85,$8F,$8B
        .byte   $9B,$17,$9E,$CE,$8E,$CE,$87,$46,$06,$02,$7F,$3F,$7F,$3F,$7F,$BF
        .byte   $7F,$7F,$03,$01,$00,$00,$03,$00,$00,$00,$3F,$3F,$1F,$1F,$07,$03
        .byte   $01,$00,$08,$18,$10,$FA,$00,$05,$FA,$37,$27,$6F,$7E,$FE,$FE,$FC
        .byte   $FC,$00,$80,$F0,$00,$80,$98,$27,$4C,$F8,$F0,$F0,$E0,$C0,$9F,$FF
        .byte   $FF,$FA,$00,$0F,$FA,$1C,$08,$04,$03,$09,$04,$1A,$E4,$32,$0F,$07
        .byte   $0B,$0F,$07,$FB,$FC,$FF,$FA,$00,$13,$FA,$80,$60,$70,$D0,$40,$00
        .byte   $C0,$E0,$F0,$D8,$EC,$BC,$F0,$FA,$00,$04,$FA,$01,$07,$0F,$08,$00
        .byte   $00,$00,$03,$0E,$18,$70,$77,$14,$08,$FA,$00,$05,$FA,$07,$EB,$F7
        .byte   $FF,$FF,$7F,$3F,$0F,$07,$00,$00,$07,$36,$D0,$43,$1F,$3D,$00,$07
        .byte   $F8,$C9,$2F,$BF,$FF,$FE,$7A,$C0,$C0,$C0,$60,$3F,$37,$AC,$F5,$FA
        .byte   $FF,$06,$FA,$BF,$00,$A0,$78,$2F,$00,$FE,$FF,$54,$00,$58,$87,$D0
        .byte   $FF,$FF,$FF,$AB,$00,$00,$01,$07,$00,$09,$E4,$32,$FF,$FF,$FF,$F7
        .byte   $03,$F9,$FC,$FF,$FA,$00,$04,$FA,$80,$00,$E0,$7F,$00,$00,$00,$C0
        .byte   $70,$FC,$FF,$FF,$00,$00,$C0,$00,$60,$F0,$50,$40,$FC,$C0,$C0,$E0
        .byte   $98,$EC,$3C,$F0,$00,$01,$00,$0A,$15,$26,$41,$51,$00,$0D,$0F,$3D
        .byte   $76,$E7,$CD,$FF,$0A,$17,$21,$C8,$17,$20,$00,$00,$7D,$76,$EF,$DF
        .byte   $37,$60,$00,$01,$C9,$99,$A9,$AC,$97,$8B,$CA,$C1,$FE,$EF,$DF,$DF
        .byte   $EF,$F7,$F5,$FE,$C0,$60,$E0,$B0,$18,$4C,$B3,$40,$FF,$FF,$FF,$BF
        .byte   $3F,$3F,$73,$C0,$93,$95,$95,$35,$E9,$D1,$A3,$43,$7F,$FB,$FB,$FB
        .byte   $F7,$EF,$5F,$BF,$03,$06,$07,$0C,$1F,$37,$CA,$00,$FF,$FF,$FE,$FF
        .byte   $FF,$FB,$CC,$04,$00,$80,$A0,$50,$88,$20,$50,$90,$00,$80,$D0,$A0
        .byte   $70,$F8,$DC,$FC,$48,$88,$48,$A0,$20,$D0,$10,$08,$BC,$7C,$FC,$F8
        .byte   $F8,$F8,$3C,$1C,$FA,$FA

; ---- bank3.gfx_AE87 (graphics) $AE87-$AFC9, 323 bytes
; Tile block: 20 tiles
        .byte   $0C,$12,$87,$C9,$B1,$96,$9E,$DA,$AA,$4C,$87,$CF,$FF,$FA,$F6,$BE
        .byte   $DE,$FC,$F8,$E0,$C4,$6A,$EF,$BC,$F4,$D0,$7C,$7E,$FA,$96,$1F,$7F
        .byte   $FB,$EF,$00,$01,$33,$4A,$86,$74,$4D,$25,$00,$01,$33,$7B,$FF,$7F
        .byte   $7E,$3F,$1F,$0B,$09,$0D,$0E,$17,$13,$15,$1F,$0F,$0F,$0A,$0D,$1E
        .byte   $1F,$1B,$38,$E4,$A2,$42,$A1,$41,$A1,$41,$38,$FC,$DE,$BE,$5F,$BF
        .byte   $5F,$BF,$81,$41,$81,$01,$81,$01,$01,$05,$7F,$BF,$7F,$FF,$7F,$FF
        .byte   $FF,$FB,$A0,$D7,$FF,$FB,$E6,$8D,$5A,$9D,$5F,$2F,$1F,$FF,$FF,$7E
        .byte   $BD,$72,$BA,$F5,$6A,$F5,$EA,$75,$AA,$D5,$75,$6A,$F5,$CA,$95,$8A
        .byte   $55,$2A,$02,$0F,$DD,$F7,$73,$B3,$79,$DA,$0D,$08,$DE,$FF,$FD,$7C
        .byte   $BE,$3D,$7D,$BD,$77,$EB,$5F,$BD,$5E,$BF,$8E,$46,$8E,$17,$A3,$42
        .byte   $A1,$40,$00,$03,$04,$08,$08,$08,$11,$10,$00,$03,$07,$0F,$0F,$0F
        .byte   $1E,$1F,$11,$10,$11,$10,$91,$60,$A1,$60,$1E,$1F,$1E,$1F,$9E,$7F
        .byte   $BE,$7F,$07,$0B,$2B,$56,$26,$CC,$9C,$38,$FB,$F7,$D7,$AF,$DF,$3E
        .byte   $7E,$FC,$70,$F0,$A0,$C0,$80,$00,$00,$00,$FC,$E8,$D0,$01,$01,$06
        .byte   $38,$C0,$EA,$54,$AA,$D4,$A8,$54,$AB,$DF,$15,$AB,$55,$2B,$57,$AB
        .byte   $54,$20,$FC,$83,$FF,$FF,$5E,$64,$F4,$98,$03,$0C,$FF,$04,$0C,$DC
        .byte   $EE,$9F,$5D,$BB,$5F,$BD,$7F,$AD,$5F,$99,$A2,$44,$A0,$42,$80,$52
        .byte   $A0,$66,$E6,$1F,$FF,$3E,$15,$2D,$2A,$11,$1F,$FF,$FF,$FF,$6E,$1E
        .byte   $FB,$11,$A0,$E0,$E1,$E8,$39,$14,$0F,$0B,$BF,$FF,$FE,$F7,$36,$1B
        .byte   $18,$1C,$04,$07,$01,$0C,$00,$05,$4F,$02,$0C,$27,$21,$18,$07,$00
        .byte   $00,$0C,$0C

; ---- bank3.gfx_AFCA (graphics) $AFCA-$B0FF, 310 bytes
; Tile block: 20 tiles
        .byte   $08,$09,$00,$3C,$73,$9A,$AD,$9A,$65,$1D,$00,$3C,$7F,$FD,$DA,$EB
        .byte   $7D,$1D,$00,$01,$01,$01,$03,$02,$02,$08,$01,$05,$03,$03,$01,$01
        .byte   $00,$03,$80,$02,$C0,$02,$A0,$01,$00,$03,$80,$02,$C0,$02,$08,$60
        .byte   $A0,$50,$B0,$20,$D0,$50,$B0,$D0,$60,$F0,$D0,$E0,$F0,$B0,$70,$F0
        .byte   $01,$02,$04,$05,$0D,$16,$26,$23,$03,$07,$07,$06,$0E,$1D,$3F,$3F
        .byte   $25,$57,$5A,$4F,$4C,$AB,$A6,$9F,$3A,$78,$7D,$7F,$73,$F4,$F9,$F0
        .byte   $58,$28,$A8,$28,$5C,$74,$E4,$84,$F8,$F8,$78,$F8,$08,$FC,$04,$08
        .byte   $0A,$9A,$72,$C2,$82,$05,$D9,$71,$FE,$7E,$FE,$FE,$7E,$FF,$3F,$FF
        .byte   $8F,$80,$CA,$B7,$9F,$0D,$97,$FF,$FF,$FF,$F5,$E8,$FF,$F2,$E8,$E0
        .byte   $55,$CF,$7A,$B7,$6B,$EA,$46,$38,$FA,$FF,$F7,$7A,$FD,$DE,$7C,$38
        .byte   $C3,$05,$49,$B1,$C1,$41,$8A,$A6,$FF,$FF,$BF,$7F,$FF,$BF,$76,$5F
        .byte   $7A,$C3,$C4,$5E,$F5,$BA,$E6,$01,$BF,$FF,$7C,$FE,$7B,$FF,$67,$01
        .byte   $04,$04,$0A,$17,$2A,$1F,$04,$3A,$00,$0E,$1F,$3D,$7B,$3B,$1E,$3B
        .byte   $56,$F8,$C9,$86,$91,$A6,$8A,$B2,$6E,$F6,$FF,$FF,$ED,$DE,$FE,$DE
        .byte   $96,$B2,$96,$92,$94,$94,$10,$10,$FA,$DE,$FA,$FE,$FC,$FC,$78,$30
        .byte   $08,$00,$10,$08,$30,$C0,$00,$06,$B8,$E0,$04,$C8,$3C,$B0,$C6,$9E
        .byte   $D8,$E4,$CC,$BA,$72,$84,$C8,$70,$C0,$A0,$68,$98,$F6,$4C,$B8,$70
        .byte   $C0,$60,$D8,$E8,$58,$74,$4A,$85,$ED,$95,$93,$AD,$78,$7C,$76,$FB
        .byte   $F3,$FB,$FD,$DB,$DB,$DB,$A5,$A5,$A3,$A3,$42,$00,$BD,$BD,$E7,$E7
        .byte   $E3,$E3,$42,$00,$08,$08

; ---- bank3.gfx_B100 (graphics) $B100-$B1F4, 245 bytes
; Tile block: 16 tiles
        .byte   $05,$0A,$05,$00,$07,$01,$01,$00,$04,$05,$01,$00,$08,$1F,$01,$04
        .byte   $06,$13,$19,$0F,$03,$09,$07,$17,$3F,$5F,$1F,$0F,$35,$77,$00,$00
        .byte   $00,$04,$01,$01,$11,$9B,$01,$03,$02,$03,$C6,$C7,$FF,$FF,$8F,$DE
        .byte   $F8,$E7,$CF,$CF,$9F,$9F,$FF,$FF,$FF,$FB,$F4,$FE,$F3,$F7,$00,$00
        .byte   $00,$80,$C0,$88,$1D,$29,$00,$08,$10,$B1,$F3,$EF,$FF,$DF,$8A,$FC
        .byte   $1E,$C7,$EA,$F3,$F9,$FD,$FD,$FF,$FF,$FF,$F7,$9F,$DF,$EB,$05,$00
        .byte   $07,$10,$01,$00,$03,$05,$80,$00,$10,$18,$28,$80,$C0,$C0,$10,$50
        .byte   $D0,$96,$FC,$F0,$E0,$F1,$F3,$BE,$AE,$EE,$FC,$01,$1F,$03,$00,$00
        .byte   $0D,$07,$00,$9F,$1F,$03,$3F,$7F,$8F,$07,$03,$02,$00,$01,$05,$00
        .byte   $05,$05,$01,$0F,$1F,$05,$00,$05,$05,$BF,$9F,$CF,$4F,$65,$F8,$1F
        .byte   $93,$DF,$F9,$FB,$F7,$FB,$FF,$FF,$7F,$65,$E7,$02,$05,$00,$05,$05
        .byte   $FB,$FF,$3B,$33,$31,$30,$10,$00,$F9,$FD,$E3,$E2,$CF,$5C,$FE,$F3
        .byte   $CF,$7B,$3F,$FF,$F6,$BF,$FF,$EF,$34,$10,$30,$05,$00,$05,$FA,$01
        .byte   $F6,$02,$05,$84,$8C,$80,$00,$00,$30,$30,$90,$60,$38,$A0,$60,$00
        .byte   $F0,$D6,$EF,$FC,$F8,$60,$E0,$E0,$80,$05,$00,$07,$05,$F0,$30,$18
        .byte   $05,$00,$05,$05,$05

; ---- bank3.gfx_B1F5 (graphics) $B1F5-$B3BE, 458 bytes
; Tile block: 30 tiles
        .byte   $F6,$F8,$FF,$FF,$F7,$E7,$CB,$D3,$E3,$C3,$60,$8E,$3E,$7E,$7E,$FE
        .byte   $FE,$FE,$E3,$F3,$DB,$CF,$E7,$F7,$FF,$FF,$FE,$FE,$FE,$7E,$3E,$DE
        .byte   $EE,$F0,$80,$40,$20,$38,$30,$08,$0D,$0F,$00,$80,$40,$20,$0C,$36
        .byte   $1B,$0F,$3F,$03,$07,$1E,$25,$4C,$88,$1C,$00,$3C,$78,$7F,$7B,$F3
        .byte   $F7,$E3,$1F,$62,$C1,$42,$46,$44,$48,$F0,$00,$1D,$3E,$BD,$B9,$BB
        .byte   $B7,$FF,$FE,$7F,$0F,$01,$00,$80,$40,$20,$7F,$8F,$F1,$FE,$F6,$FF
        .byte   $04,$F6,$E0,$1C,$03,$F6,$00,$06,$F6,$E0,$FC,$F6,$FF,$05,$F6,$03
        .byte   $86,$CD,$F3,$77,$37,$1A,$ED,$FF,$FD,$FB,$7F,$BF,$DF,$EF,$FF,$00
        .byte   $00,$00,$C0,$20,$20,$20,$72,$F6,$00,$04,$F6,$C0,$C0,$F0,$B8,$DD
        .byte   $6E,$BB,$D5,$AB,$74,$97,$9F,$FE,$FB,$FD,$FE,$DF,$8F,$6F,$FE,$2E
        .byte   $5D,$3E,$39,$31,$51,$97,$0E,$D1,$BE,$7F,$77,$2F,$3F,$7F,$CF,$0D
        .byte   $02,$04,$06,$03,$04,$08,$10,$1E,$0D,$07,$07,$0F,$1A,$34,$08,$13
        .byte   $0C,$8D,$4B,$8B,$CB,$65,$B4,$FF,$FF,$7F,$BF,$FF,$FF,$FF,$7F,$1A
        .byte   $19,$4C,$9C,$3C,$7C,$38,$11,$FF,$FF,$BF,$7F,$FF,$7F,$7F,$3F,$76
        .byte   $F9,$F7,$F7,$FA,$E6,$12,$8A,$9F,$EF,$EF,$EF,$C7,$9B,$EF,$F7,$42
        .byte   $26,$9E,$FF,$73,$13,$FB,$CF,$F6,$FF,$07,$F6,$CF,$03,$0F,$21,$20
        .byte   $1C,$7E,$7B,$3A,$03,$31,$7E,$FF,$FF,$BF,$BF,$DF,$1E,$17,$10,$10
        .byte   $3C,$7E,$47,$05,$E7,$78,$7F,$7F,$7F,$47,$3D,$7E,$CC,$B6,$FA,$7C
        .byte   $1C,$0E,$8C,$EC,$F4,$FA,$7C,$9E,$EC,$FC,$FE,$FE,$B4,$AC,$EC,$3C
        .byte   $1C,$0C,$8C,$4C,$FE,$FE,$3E,$DE,$EE,$FE,$FE,$FE,$04,$04,$04,$02
        .byte   $09,$08,$08,$08,$7F,$7F,$3F,$3F,$F6,$37,$04,$F6,$0C,$04,$04,$07
        .byte   $04,$0E,$06,$02,$13,$1B,$1B,$1B,$1F,$19,$09,$0D,$EC,$7C,$5C,$6C
        .byte   $5C,$EC,$5C,$4C,$7E,$DE,$EE,$F6,$FE,$05,$F6,$6C,$5C,$4C,$6C,$DC
        .byte   $4C,$2C,$1C,$F6,$FE,$08,$03,$03,$F6,$02,$01,$01,$01,$00,$0C,$0C
        .byte   $04,$05,$06,$06,$06,$03,$F6,$00,$08,$03,$03,$01,$05,$0C,$05,$F6
        .byte   $8C,$0C,$8C,$F6,$FE,$05,$F6,$7E,$FE,$7E,$8C,$8C,$8C,$CC,$CC,$8C
        .byte   $4C,$4C,$7E,$7E,$7E,$3E,$3E,$7E,$BE,$BE,$4C,$FC,$FC,$EE,$32,$10
        .byte   $10,$00,$BE,$0E,$72,$DC,$4E,$6E,$6E,$3E,$10,$10,$F6,$00,$06,$F6
        .byte   $2E,$2E,$3E,$1E,$1E,$1E,$0E,$0E,$F6,$F6

; ---- bank3.gfx_B3BF (graphics) $B3BF-$B402, 68 bytes
; Tile block: 4 tiles
        .byte   $02,$06,$01,$03,$07,$E7,$FE,$CE,$66,$36,$00,$00,$00,$60,$39,$39
        .byte   $1D,$0D,$1A,$0F,$67,$03,$0B,$13,$2D,$30,$05,$04,$1A,$E1,$04,$0E
        .byte   $1C,$30,$80,$C0,$C0,$C3,$6A,$74,$64,$68,$80,$C0,$C0,$C3,$E6,$EC
        .byte   $FC,$F8,$7E,$38,$F0,$78,$30,$E8,$E4,$60,$F8,$F6,$F8,$F8,$EC,$66
        .byte   $22,$20,$02,$02

; ---- bank3.gfx_B403 (graphics) $B403-$B446, 68 bytes
; Tile block: 4 tiles
        .byte   $01,$05,$04,$0E,$1D,$38,$70,$A0,$C0,$E0,$07,$0F,$1E,$3F,$7F,$FF
        .byte   $FF,$FF,$D8,$BC,$7F,$3F,$1E,$0C,$04,$02,$FF,$FF,$7F,$3F,$1F,$0F
        .byte   $07,$03,$00,$70,$F8,$3C,$1E,$0C,$08,$08,$C0,$80,$00,$C0,$E0,$F3
        .byte   $F7,$F7,$14,$22,$C7,$CE,$7C,$38,$30,$60,$EB,$DD,$38,$30,$80,$C0
        .byte   $C0,$80,$01,$01

; ---- bank3.gfx_B447 (graphics) $B447-$B57E, 312 bytes
; Tile block: 20 tiles
        .byte   $F5,$FA,$0E,$0E,$1C,$1C,$18,$38,$38,$1C,$0E,$06,$F5,$00,$06,$F5
        .byte   $0C,$3D,$71,$EE,$1F,$5E,$6F,$2C,$32,$63,$EF,$DD,$FE,$FF,$5D,$3E
        .byte   $F5,$00,$09,$F5,$07,$1F,$3F,$7F,$7F,$FF,$FF,$80,$C1,$C3,$83,$03
        .byte   $01,$00,$00,$7F,$3E,$3C,$7C,$FC,$7E,$3F,$07,$00,$00,$00,$01,$18
        .byte   $3C,$38,$03,$00,$00,$07,$1E,$27,$43,$C7,$FC,$07,$07,$03,$03,$F5
        .byte   $00,$04,$F5,$F8,$F8,$7C,$3C,$0F,$03,$00,$00,$00,$03,$E1,$F5,$00
        .byte   $05,$F5,$0F,$FC,$1E,$F5,$FF,$05,$F5,$80,$C0,$C7,$8F,$0F,$07,$00
        .byte   $00,$7F,$3F,$38,$70,$F0,$F8,$FF,$1F,$00,$F0,$E1,$F5,$00,$05,$F5
        .byte   $FC,$0F,$1E,$F5,$FF,$05,$F5,$07,$0F,$8F,$C7,$C0,$80,$00,$00,$F8
        .byte   $F0,$70,$38,$3F,$7F,$FE,$F0,$00,$00,$00,$E0,$30,$00,$1E,$3C,$00
        .byte   $C0,$F8,$1E,$CE,$FF,$E1,$C3,$1C,$80,$80,$F5,$00,$05,$F5,$E2,$7E
        .byte   $7C,$F8,$E0,$80,$00,$00,$1C,$78,$60,$C0,$C0,$EC,$7D,$79,$0C,$08
        .byte   $00,$00,$00,$1E,$07,$C7,$F6,$1F,$5E,$6F,$2C,$00,$00,$00,$CD,$FE
        .byte   $FF,$5D,$3E,$00,$00,$00,$01,$0F,$0F,$37,$3D,$21,$1C,$6E,$01,$07
        .byte   $07,$3B,$3A,$3F,$67,$5F,$D8,$87,$6F,$77,$36,$1B,$00,$00,$EF,$FB
        .byte   $B7,$BB,$5B,$6F,$3F,$03,$F0,$7C,$F9,$BB,$FD,$BD,$C5,$6E,$3C,$FB
        .byte   $77,$F7,$33,$D6,$FE,$FF,$6E,$0C,$75,$78,$FE,$7E,$7C,$00,$DF,$F7
        .byte   $BB,$BF,$7F,$FD,$9B,$FF,$00,$00,$80,$D0,$F8,$38,$A0,$EC,$00,$80
        .byte   $C0,$B0,$B8,$FC,$DC,$F2,$EC,$5C,$C8,$E0,$C0,$80,$00,$00,$DA,$BA
        .byte   $F4,$D8,$B8,$60,$E0,$00,$F5,$F5

; ---- bank3.gfx_B57F (graphics) $B57F-$B5FC, 126 bytes
; Tile block: 8 tiles
        .byte   $FD,$FF,$00,$00,$00,$0A,$15,$0E,$17,$0B,$00,$00,$0F,$15,$2A,$31
        .byte   $28,$34,$04,$01,$FD,$00,$06,$FD,$1B,$1E,$0F,$03,$01,$FD,$00,$08
        .byte   $FD,$80,$40,$80,$00,$00,$00,$C0,$F0,$70,$B8,$7C,$B8,$78,$F8,$FE
        .byte   $0F,$03,$00,$00,$7C,$F8,$E0,$C0,$80,$FD,$00,$04,$FD,$17,$3E,$7F
        .byte   $3F,$7F,$1F,$7F,$03,$08,$01,$00,$40,$00,$E1,$83,$37,$2F,$37,$0F
        .byte   $FD,$00,$04,$FD,$CB,$57,$4F,$37,$0F,$FD,$00,$04,$FD,$80,$A0,$D0
        .byte   $E8,$F8,$F8,$F8,$C0,$70,$58,$2C,$14,$7C,$FC,$F8,$F8,$E8,$BC,$FE
        .byte   $9E,$0E,$00,$00,$F8,$D8,$C0,$E0,$80,$00,$00,$00,$FD,$FD

; ---- bank3.gfx_B5FD (graphics) $B5FD-$B680, 132 bytes
; Tile block: 8 tiles
        .byte   $FB,$FD,$00,$04,$48,$08,$28,$23,$0E,$4B,$82,$42,$24,$65,$15,$16
        .byte   $2B,$7E,$3A,$6E,$6F,$64,$DB,$A5,$DB,$F7,$7F,$7F,$7F,$7B,$F4,$FA
        .byte   $F4,$E8,$00,$82,$00,$92,$10,$E2,$C0,$B4,$94,$14,$9A,$28,$A6,$C4
        .byte   $AD,$F9,$AC,$FC,$F2,$0A,$D8,$EB,$55,$AC,$FF,$FE,$FE,$F6,$2E,$17
        .byte   $AB,$57,$A7,$8B,$D5,$AB,$D5,$CB,$45,$7B,$F8,$F4,$EA,$F4,$EA,$F4
        .byte   $7A,$64,$55,$3B,$2F,$3B,$17,$1E,$0D,$03,$7A,$34,$38,$3C,$1C,$1F
        .byte   $0E,$03,$55,$EC,$75,$AB,$D5,$BB,$75,$AA,$AB,$17,$8B,$57,$2B,$47
        .byte   $8B,$56,$52,$E8,$54,$BC,$48,$18,$30,$80,$AE,$1C,$AC,$5C,$B8,$F8
        .byte   $F0,$C0,$FB,$FB

; ---- bank3.gfx_B681 (graphics) $B681-$B6DF, 95 bytes
; Tile block: 6 tiles
        .byte   $FD,$FE,$FD,$00,$05,$FD,$21,$63,$E7,$FD,$00,$04,$FD,$01,$63,$E2
        .byte   $BD,$E7,$61,$22,$FD,$00,$05,$FD,$BE,$E3,$63,$FD,$00,$07,$FD,$20
        .byte   $60,$A0,$60,$21,$26,$00,$00,$20,$60,$E2,$E3,$E3,$FF,$27,$A3,$E3
        .byte   $E1,$E0,$40,$00,$00,$FF,$E2,$E2,$A1,$A0,$40,$00,$00,$20,$20,$60
        .byte   $A0,$60,$A1,$22,$24,$20,$60,$E2,$E2,$E3,$E3,$E3,$FF,$26,$23,$23
        .byte   $21,$A0,$E0,$E0,$40,$FF,$E3,$E2,$E1,$E0,$E0,$A0,$40,$FD,$FD

; ---- bank3.gfx_B6E0 (graphics) $B6E0-$B742, 99 bytes
; Tile block: 6 tiles
        .byte   $FE,$FF,$00,$0C,$12,$16,$0C,$03,$06,$05,$00,$0C,$1E,$1A,$0C,$03
        .byte   $07,$07,$05,$36,$4B,$58,$30,$00,$00,$00,$07,$37,$7B,$68,$30,$FE
        .byte   $00,$05,$FE,$18,$34,$34,$1B,$06,$05,$00,$00,$18,$2C,$2C,$1B,$07
        .byte   $06,$05,$06,$1B,$34,$24,$18,$00,$00,$06,$07,$1B,$2C,$3C,$18,$00
        .byte   $00,$01,$03,$02,$01,$00,$03,$66,$D5,$01,$02,$03,$01,$00,$03,$67
        .byte   $B6,$95,$66,$03,$00,$01,$03,$02,$01,$F6,$67,$03,$00,$01,$02,$03
        .byte   $01,$FE,$FE

; ---- bank3.gfx_B743 (graphics) $B743-$B93A, 504 bytes
; Tile block: 32 tiles
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
        .byte   $74,$34,$14,$14,$04,$00,$FA,$FA

; ---- bank3.gfx_B93B (graphics) $B93B-$BA0A, 208 bytes
; Tile block: 18 tiles
        .byte   $FD,$FF,$FD,$00,$05,$10,$03,$00,$07,$FD,$7F,$3F,$10,$10,$10,$FD
        .byte   $00,$04,$FD,$E0,$7F,$FD,$00,$0D,$FD,$4C,$FD,$00,$07,$FD,$FC,$FE
        .byte   $4C,$FD,$00,$06,$FD,$9A,$FC,$FD,$00,$15,$FD,$01,$41,$36,$18,$08
        .byte   $08,$04,$00,$00,$06,$19,$36,$78,$30,$FD,$00,$08,$FD,$0C,$1C,$E8
        .byte   $FD,$00,$05,$FD,$1C,$74,$98,$C0,$FD,$00,$07,$FD,$E0,$80,$FD,$00
        .byte   $0C,$FD,$01,$01,$FD,$00,$06,$FD,$01,$03,$03,$42,$34,$18,$0C,$04
        .byte   $02,$00,$04,$0D,$1B,$1E,$3C,$30,$FD,$00,$05,$FD,$18,$38,$30,$40
        .byte   $80,$00,$00,$00,$18,$68,$F0,$B0,$60,$C0,$FD,$00,$07,$FD,$C0,$80
        .byte   $FD,$00,$0D,$FD,$01,$FD,$00,$05,$FD,$01,$01,$03,$01,$02,$22,$1C
        .byte   $06,$02,$01,$00,$02,$05,$05,$0A,$0E,$1C,$08,$00,$00,$00,$E0,$E0
        .byte   $40,$80,$80,$80,$00,$00,$E0,$A0,$E0,$40,$40,$80,$FD,$00,$11,$FD
        .byte   $10,$38,$10,$10,$10,$38,$10,$00,$10,$28,$38,$28,$28,$28,$38,$FD
        .byte   $10,$04,$FD,$38,$D6,$00,$00,$FD,$28,$05,$FD,$38,$38,$10,$FD,$FD

; ---- bank3.gfx_BA0B (graphics) $BA0B-$BB34, 298 bytes
; Tile block: 20 tiles
        .byte   $FD,$FE,$FD,$00,$05,$FD,$10,$00,$0F,$FD,$00,$04,$FD,$3C,$1F,$1E
        .byte   $0F,$03,$01,$3F,$10,$FD,$00,$04,$FD,$7D,$3E,$3F,$1F,$3E,$FD,$00
        .byte   $08,$FD,$40,$00,$1C,$FD,$00,$05,$FD,$80,$00,$74,$98,$80,$00,$40
        .byte   $FD,$00,$04,$FD,$FF,$7C,$00,$80,$FD,$00,$08,$FD,$01,$00,$01,$06
        .byte   $FD,$00,$04,$FD,$02,$0E,$1F,$7F,$08,$01,$06,$08,$FD,$00,$04,$FD
        .byte   $0F,$1F,$3F,$0F,$03,$06,$FD,$00,$06,$FD,$18,$30,$8C,$D8,$FD,$00
        .byte   $04,$FD,$0E,$3C,$FC,$30,$00,$80,$20,$FD,$00,$05,$FD,$80,$80,$C0
        .byte   $C0,$FD,$00,$07,$FD,$01,$02,$00,$05,$09,$FD,$00,$05,$FD,$04,$0F
        .byte   $1F,$02,$05,$03,$06,$FD,$00,$04,$FD,$2F,$07,$0F,$0F,$03,$02,$FD
        .byte   $00,$05,$FD,$20,$48,$18,$90,$C8,$00,$00,$04,$38,$78,$70,$F0,$40
        .byte   $F0,$80,$FD,$00,$06,$FD,$D0,$E0,$C0,$80,$FD,$00,$07,$FD,$04,$04
        .byte   $00,$00,$09,$FD,$00,$05,$FD,$08,$08,$1C,$09,$11,$01,$02,$02,$00
        .byte   $00,$00,$1E,$3F,$2F,$07,$03,$02,$02,$00,$00,$00,$10,$30,$30,$00
        .byte   $88,$C8,$00,$10,$30,$70,$60,$E0,$C0,$C0,$E0,$60,$40,$40,$FD,$00
        .byte   $04,$FD,$B0,$B0,$E0,$E0,$40,$40,$00,$00,$00,$01,$03,$03,$01,$10
        .byte   $12,$07,$01,$FD,$03,$06,$FD,$13,$0B,$0B,$0A,$08,$FD,$00,$04,$FD
        .byte   $1E,$1E,$1F,$1D,$11,$01,$01,$00,$00,$00,$80,$80,$00,$10,$90,$C0
        .byte   $00,$80,$80,$00,$80,$80,$80,$90,$80,$A0,$A0,$20,$FD,$00,$04,$FD
        .byte   $D0,$F0,$F0,$70,$10,$00,$00,$00,$FD,$FD

; ---- bank3.gfx_BB35 (graphics) $BB35-$BBB8, 132 bytes
; Tile block: 8 tiles
        .byte   $FD,$FF,$00,$38,$56,$76,$F7,$E7,$CF,$CF,$00,$20,$78,$7C,$FA,$FC
        .byte   $FE,$FE,$ED,$F1,$F3,$76,$44,$28,$00,$00,$F6,$FE,$FE,$7C,$7A,$30
        .byte   $00,$00,$00,$38,$6E,$5E,$FB,$F7,$E7,$E7,$00,$20,$58,$78,$FC,$FA
        .byte   $DE,$DE,$F7,$FB,$D9,$5A,$60,$28,$00,$00,$FA,$FC,$FE,$7C,$7E,$30
        .byte   $00,$00,$00,$38,$6E,$5E,$DD,$FB,$F3,$F7,$00,$20,$78,$7C,$FE,$EC
        .byte   $FE,$FA,$E7,$D7,$AD,$4E,$66,$28,$00,$00,$FC,$EE,$FE,$7C,$58,$30
        .byte   $00,$00,$00,$38,$4E,$6E,$CF,$DF,$BF,$BF,$00,$20,$70,$7C,$F6,$FA
        .byte   $FC,$FC,$B9,$DB,$C7,$5E,$64,$20,$00,$00,$DE,$E6,$FE,$7C,$7A,$38
        .byte   $00,$00,$FD,$FD

; ---- bank3.gfx_BBB9 (graphics) $BBB9-$BC3C, 132 bytes
; Tile block: 8 tiles
        .byte   $FE,$FF,$01,$05,$03,$05,$02,$04,$01,$13,$02,$0A,$1C,$1A,$3D,$3B
        .byte   $3F,$5F,$1D,$19,$09,$0C,$06,$03,$00,$00,$1E,$1F,$4F,$6F,$27,$07
        .byte   $06,$02,$01,$01,$02,$01,$02,$00,$01,$03,$00,$06,$0D,$0E,$1D,$1F
        .byte   $1F,$0F,$1D,$19,$19,$0C,$06,$03,$00,$00,$1E,$7F,$5F,$0F,$1F,$1B
        .byte   $08,$00,$00,$40,$80,$C0,$A0,$00,$80,$C8,$80,$A0,$70,$30,$58,$F8
        .byte   $F8,$FA,$B8,$98,$90,$30,$60,$80,$00,$00,$7E,$F8,$F0,$FC,$E4,$C0
        .byte   $C0,$80,$00,$01,$02,$01,$02,$01,$01,$03,$01,$02,$05,$06,$0D,$0E
        .byte   $0F,$07,$1D,$19,$19,$0C,$06,$03,$00,$00,$7E,$5F,$1F,$1F,$3F,$33
        .byte   $01,$01,$FE,$FE

; ---- bank3.gfx_BC3D (graphics) $BC3D-$BD38, 252 bytes
; Tile block: 18 tiles
        .byte   $FD,$FF,$FD,$00,$06,$FD,$2C,$7B,$FD,$00,$05,$FD,$03,$17,$7E,$5E
        .byte   $7B,$14,$FD,$00,$05,$FD,$AF,$7E,$2F,$03,$FD,$00,$08,$FD,$18,$18
        .byte   $A0,$50,$FD,$00,$05,$FD,$E0,$58,$AC,$FC,$50,$AC,$0C,$FD,$00,$04
        .byte   $FD,$02,$AC,$50,$E0,$FD,$00,$0A,$FD,$01,$05,$FD,$00,$05,$FD,$01
        .byte   $06,$06,$2E,$7A,$2E,$38,$10,$00,$00,$00,$1F,$37,$1F,$74,$FD,$00
        .byte   $07,$FD,$60,$60,$58,$60,$C8,$FD,$00,$04,$FD,$18,$A4,$98,$30,$98
        .byte   $FD,$00,$07,$FD,$60,$C0,$80,$FD,$00,$0B,$FD,$01,$FD,$00,$06,$FD
        .byte   $01,$06,$07,$06,$0F,$1B,$1E,$0C,$20,$00,$00,$07,$07,$0F,$34,$18
        .byte   $08,$FD,$00,$04,$FD,$60,$60,$50,$AC,$DC,$E0,$00,$00,$00,$18,$A8
        .byte   $50,$20,$10,$80,$FD,$00,$07,$FD,$60,$C0,$80,$FD,$00,$07,$FD,$03
        .byte   $03,$00,$00,$01,$01,$FD,$00,$04,$FD,$01,$01,$02,$02,$03,$07,$07
        .byte   $0D,$06,$03,$00,$00,$03,$03,$0D,$07,$03,$06,$08,$FD,$00,$04,$FD
        .byte   $60,$6C,$CC,$A0,$C0,$00,$00,$60,$90,$90,$30,$50,$20,$80,$C0,$00
        .byte   $80,$FD,$00,$04,$FD,$60,$C0,$80,$FD,$00,$07,$FD,$D6,$D6,$38,$54
        .byte   $38,$54,$00,$10,$28,$28,$44,$28,$C6,$AA,$7C,$54,$7C,$38,$6C,$38
        .byte   $00,$10,$FE,$7C,$38,$6C,$38,$6C,$10,$00,$FD,$FD

; ---- bank3.gfx_BD39 (graphics) $BD39-$BE1C, 228 bytes
; Tile block: 14 tiles
        .byte   $F9,$FD,$03,$07,$0B,$1F,$3D,$3D,$7B,$7F,$04,$08,$14,$20,$22,$72
        .byte   $66,$66,$1F,$3F,$7F,$7F,$7E,$FB,$3F,$00,$60,$47,$05,$D8,$F1,$A5
        .byte   $C3,$7F,$E0,$F0,$F8,$F4,$FA,$FC,$FA,$FE,$10,$0C,$06,$0A,$05,$03
        .byte   $07,$02,$F4,$D8,$FC,$FC,$F8,$F0,$E0,$00,$0E,$3C,$FC,$78,$F4,$E8
        .byte   $D0,$C0,$01,$03,$05,$0F,$0F,$1F,$1F,$1F,$02,$0C,$1A,$10,$38,$3C
        .byte   $7E,$6E,$7F,$7F,$3F,$7F,$FF,$FF,$FF,$00,$6C,$E0,$C0,$C5,$56,$FC
        .byte   $54,$7F,$C0,$F0,$E8,$F4,$F8,$F6,$C4,$9C,$20,$08,$14,$0A,$06,$09
        .byte   $3B,$7B,$BC,$B8,$F8,$E0,$E0,$80,$00,$00,$72,$66,$04,$D8,$60,$40
        .byte   $C0,$80,$03,$07,$0B,$0F,$1F,$1F,$3F,$3F,$04,$08,$14,$38,$39,$7B
        .byte   $73,$6D,$3F,$7F,$FF,$FF,$FF,$3F,$1F,$0E,$5D,$CC,$90,$75,$BD,$EF
        .byte   $2A,$01,$E0,$F0,$FC,$FC,$FA,$FC,$FA,$FE,$10,$0C,$02,$02,$05,$83
        .byte   $C7,$C2,$F4,$D8,$B8,$F0,$E0,$E0,$80,$00,$8E,$3C,$78,$28,$F8,$90
        .byte   $E0,$80,$03,$0F,$0F,$1F,$2F,$5F,$3F,$3F,$04,$10,$30,$20,$54,$2E
        .byte   $5E,$5C,$1F,$0F,$17,$1F,$1F,$0F,$07,$03,$29,$13,$38,$34,$2D,$17
        .byte   $1D,$0C,$F9,$F9

; ---- bank3.gfx_BE1D (graphics) $BE1D-$BE9D, 129 bytes
; Tile block: 8 tiles
        .byte   $FE,$FF,$00,$03,$04,$09,$0F,$1F,$16,$1D,$00,$00,$03,$05,$17,$07
        .byte   $2B,$2E,$1D,$1E,$1F,$0D,$09,$04,$03,$00,$2E,$2F,$05,$17,$05,$03
        .byte   $00,$00,$00,$80,$40,$A0,$A0,$F0,$70,$B8,$00,$00,$80,$90,$E8,$B8
        .byte   $F4,$7C,$B8,$60,$F0,$E0,$A0,$40,$80,$00,$7C,$DC,$F8,$E8,$90,$80
        .byte   $00,$00,$00,$01,$01,$01,$07,$0F,$0D,$19,$FE,$00,$04,$FE,$06,$0A
        .byte   $0E,$1E,$19,$0C,$0E,$07,$01,$00,$00,$00,$1F,$0F,$0B,$07,$01,$FE
        .byte   $00,$07,$FE,$07,$0F,$0E,$1F,$00,$03,$0C,$11,$26,$2E,$4F,$5D,$0D
        .byte   $0F,$0F,$07,$01,$00,$00,$00,$53,$4E,$2F,$27,$11,$0C,$03,$00,$FE
        .byte   $FE

; ---- bank3.gfx_BE9E (graphics) $BE9E-$BF55, 184 bytes
; Tile block: 12 tiles
        .byte   $FB,$FD,$01,$03,$07,$0E,$1D,$3B,$76,$EC,$01,$03,$07,$0F,$1E,$3C
        .byte   $79,$F3,$D8,$6C,$36,$1B,$0D,$06,$03,$01,$E7,$73,$39,$1C,$0E,$07
        .byte   $03,$01,$80,$C0,$E0,$70,$B8,$DC,$6E,$37,$00,$00,$00,$80,$C0,$E0
        .byte   $F0,$F8,$18,$30,$60,$C0,$80,$00,$00,$00,$FF,$FE,$FC,$F8,$F0,$E0
        .byte   $C0,$80,$00,$00,$01,$07,$1F,$7F,$F9,$E1,$00,$00,$01,$07,$1F,$7F
        .byte   $FF,$FF,$81,$06,$18,$FB,$00,$05,$FB,$FF,$FF,$7F,$1F,$07,$01,$FB
        .byte   $00,$05,$FB,$C0,$F0,$FC,$3E,$5E,$FB,$00,$05,$FB,$C0,$F0,$AC,$EA
        .byte   $D4,$38,$FB,$00,$05,$FB,$16,$EA,$F4,$F0,$C0,$FB,$00,$06,$01,$04
        .byte   $FB,$FF,$00,$00,$00,$1F,$3F,$7F,$FF,$FF,$FF,$7F,$3F,$1F,$FB,$00
        .byte   $04,$FB,$FF,$7F,$3F,$1F,$FB,$00,$07,$FB,$F0,$A8,$D4,$AA,$FE,$FB
        .byte   $00,$04,$FB,$50,$28,$54,$FE,$D4,$A8,$D0,$A0,$FB,$00,$04,$FB,$2A
        .byte   $54,$28,$50,$FB,$00,$04,$FB,$FB

; ---- bank3.gfx_BF56 (graphics) $BF56-$BFD6, 129 bytes
; Tile block: 8 tiles
        .byte   $FE,$FF,$4C,$8C,$8C,$4E,$2F,$2B,$1B,$0B,$6A,$FA,$FA,$7C,$3F,$3F
        .byte   $1F,$0D,$0B,$0A,$0E,$0A,$06,$06,$00,$00,$0D,$0C,$0C,$0C,$04,$04
        .byte   $00,$00,$00,$20,$70,$F0,$70,$70,$F4,$E0,$00,$60,$50,$D8,$D8,$FC
        .byte   $F8,$48,$FE,$A0,$06,$FE,$C0,$C0,$40,$C0,$C0,$C0,$E0,$C0,$80,$80
        .byte   $30,$50,$56,$B6,$B6,$74,$4C,$44,$28,$6C,$6C,$EC,$EC,$78,$7C,$78
        .byte   $24,$28,$28,$28,$38,$28,$18,$18,$38,$FE,$30,$05,$FE,$10,$10,$00
        .byte   $30,$30,$30,$B8,$7A,$3F,$2F,$00,$28,$68,$E8,$F1,$5B,$2E,$37,$2F
        .byte   $2C,$28,$38,$28,$18,$18,$00,$36,$36,$30,$30,$30,$10,$10,$00,$FE
        .byte   $FE

; ---- bank3.pad_BFD7 (padding) $BFD7-$BFFE, 40 bytes
; Fill: 40 x $FF
        .fill   40,$FF

; ---- bank3.bank_id_BFFF (data) $BFFF-$BFFF, 1 bytes
; Bank 3 identity byte
        .byte   $03
