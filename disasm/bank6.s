; PRG bank 6 - not yet established
; $8000-$BFFF
; The switchable window. Every address below exists in seven banks; only this
; one has these bytes at it, which is what the L6_ label prefix records.
.org $8000


; ---- bank6.code_8000 (code) $8000-$8026, 39 bytes
L6_8000:
        jmp     L6_81FB
L6_8003:
        jmp     L6_8BCE
L6_8006:
        jmp     L6_8435
L6_8009:
        jmp     L6_826D
L6_800C:
        jmp     L6_81F5
L6_800F:
        jmp     L6_8015
L6_8012:
        jmp     L6_805A
L6_8015:
        lda     #$00
        sta     $A5
        sta     $20
        sta     $017F
        sta     $7E
        sta     $7F
        sta     $06
        jsr     L7_C006

; ---- bank6.inline_8027 (data) $8027-$8029, 3 bytes
; Far-call argument at $8027
        .byte   $00,$FF,$7F

; ---- bank6.code_802A (code) $802A-$80DE, 181 bytes
        lda     #$81
        sta     $4010
        sta     $05
        lda     #$00
        sta     $4011
        lda     #$FF
        sta     $4012
        lda     #$01
        sta     $4013
        ldx     #$05
L6_8042:
        lda     #$00
        sta     $0170,X
        dex
        bpl     L6_8042
        ldx     #$0A
        lda     #$00
L6_804E:
        sta     $00,X
        inx
        cpx     #$F9
        bne     L6_804E
        lda     #$04
        sta     $83
        rts
L6_805A:
        ldy     #$05
        clc
L6_805D:
        lda     $04B9,Y
        adc     $04B3,Y
        cmp     #$0A
        bcc     L6_8069
        sbc     #$0A
L6_8069:
        sta     $04B3,Y
        dey
        bpl     L6_805D
        bcs     L6_8093
        lda     $04B3
        tay
        beq     L6_8081
        ldy     #$C8
        cmp     #$02
        beq     L6_8081
        ldy     #$64
        bcs     L6_8093
L6_8081:
        sty     $10
        lda     $04B4
        asl     A
        asl     A
        adc     $04B4
        asl     A
        adc     $04B5
        adc     $10
        bcc     L6_8095
L6_8093:
        lda     #$FF
L6_8095:
        sta     $15
        lda     #$20
        sta     $19
        lda     #$94
        sta     $18
        lda     $15
        beq     L6_80A6
        jsr     L7_C051
L6_80A6:
        lda     #$07
        jsr     L7_C04B
        jsr     L7_C03C
        tay
        lda     #$04
        sta     $0100,Y
        lda     #$20
        sta     $0101,Y
        lda     #$97
        sta     $0102,Y
        lda     $04B6
        clc
        adc     #$30
        sta     $0103,Y
        lda     $04B7
        adc     #$30
        sta     $0104,Y
        lda     $04B8
        adc     #$30
        sta     $0105,Y
        lda     #$30
        sta     $0106,Y
        jmp     L7_C03F

; ---- UNCLAIMED (gap) $80DF-$81F4, 278 bytes
        .byte   $6D,$8F,$6A,$74,$6A,$88,$5E,$5E,$68,$47,$0B,$66,$47,$5B,$56,$1C
        .byte   $1C,$1C,$1C,$6D,$6D,$EE,$7E,$97,$97,$F9,$97,$F9,$09,$09,$09,$B7
        .byte   $35,$A5,$6F,$67,$67,$67,$C5,$71,$18,$CF,$7C,$41,$79,$79,$79,$2B
        .byte   $F0,$F0,$F0,$F7,$11,$D7,$D7,$67,$F8,$38,$86,$C6,$BB,$F8,$2B,$80
        .byte   $80,$E1,$A0,$4D,$87,$87,$19,$DB,$DB,$47,$47,$87,$87,$DC,$04,$02
        .byte   $02,$6D,$F9,$F9,$48,$48,$48,$45,$D8,$06,$06,$06,$BB,$40,$B6,$22
        .byte   $F3,$FA,$81,$25,$7B,$8A,$C1,$17,$9B,$68,$D9,$03,$32,$64,$6A,$35
        .byte   $8F,$99,$6D,$A3,$77,$ED,$47,$47,$47,$FE,$BC,$92,$16,$50,$50,$84
        .byte   $84,$86,$84,$A2,$A8,$97,$97,$99,$C0,$96,$96,$C0,$9A,$9B,$9C,$9C
        .byte   $9C,$9C,$A2,$A2,$8B,$8C,$8C,$8C,$9D,$9E,$9D,$9D,$9D,$9D,$9F,$A0
        .byte   $A0,$8D,$8E,$8E,$8E,$A0,$99,$9A,$96,$96,$97,$90,$90,$90,$99,$99
        .byte   $99,$99,$99,$9A,$A8,$A8,$BA,$BB,$BD,$B0,$B3,$BD,$BE,$AC,$90,$90
        .byte   $AC,$AD,$AE,$90,$91,$93,$93,$93,$C0,$C0,$91,$91,$95,$96,$A7,$A7
        .byte   $A7,$A7,$A7,$A3,$A3,$A3,$A4,$B0,$A5,$A5,$A5,$A5,$A6,$A6,$B1,$AE
        .byte   $9F,$AF,$B0,$BF,$B2,$B2,$B3,$AA,$AB,$AB,$B9,$B6,$B6,$B1,$B2,$B3
        .byte   $B6,$B9,$B9,$B4,$B4,$C0,$C0,$C0,$B9,$B7,$B5,$B7,$B8,$B8,$00,$01
        .byte   $02,$03,$04,$17,$16,$15,$14,$13,$12,$11,$10,$0F,$0E,$0D,$0C,$0B
        .byte   $0A,$09,$08,$07,$06,$05

; ---- bank6.code_81F5 (code) $81F5-$8269, 117 bytes
L6_81F5:
        ldx     #$01
        stx     $35
        bne     L6_8204
L6_81FB:
        jsr     L7_C096
        ldx     #$00
        stx     $35
        inc     $36
L6_8204:
        lda     $36
        and     #$02
        beq     L6_820E
        lda     $81DD,X
        tax
L6_820E:
        stx     $37
        lda     $0500,X
        beq     L6_8227
        and     #$7F
        tay
        lda     #$82
        pha
        lda     #$26
        pha
        lda     $815D,Y
        pha
        lda     $80DE,Y
        pha
        rts
L6_8227:
        inc     $35
        ldx     $35
        cpx     #$18
        bne     L6_8204
        jsr     L7_C099
        lda     $0500
        cmp     #$04
        bne     L6_8246
        lda     $2E
        ora     $48
        ora     $49
        beq     L6_8247
        lda     #$81
        sta     $0500
L6_8246:
        rts
L6_8247:
        lda     #$84
        sta     $0500
        ldx     #$04
L6_824E:
        jsr     L7_C048
        dex
        bne     L6_824E
        jsr     L7_C0A2
        lda     #$1F
        jsr     L7_C030
        lda     #$37
        jsr     L7_C030
        lda     $A0
        and     #$FE
        sta     $A0
        jsr     L7_C006

; ---- bank6.inline_826A (data) $826A-$826C, 3 bytes
; Far-call argument at $826A
        .byte   $00,$0E,$80

; ---- bank6.code_826D (code) $826D-$8424, 440 bytes
L6_826D:
        lda     $0758,X
        clc
        adc     $05C0,X
        sta     $16
        lda     $0518,X
        adc     $05D8,X
        clc
        adc     $06B0,X
        sta     $17
        lda     $0770,X
        clc
        adc     $05F0,X
        sta     $18
        lda     $0530,X
        adc     $0608,X
        sta     $19
        lda     #$00
        sta     $6F
        lda     $17
        and     #$F0
        sta     $10
        lda     $0518,X
        clc
        adc     $06B0,X
        and     #$F0
        cmp     $10
        bne     L6_82AE
        lda     #$80
        sta     $6F
L6_82AE:
        lda     $19
        and     #$F0
        sta     $11
        lda     $0530,X
        and     #$F0
        cmp     $11
        bne     L6_82CE
        lda     #$40
        ora     $6F
        sta     $6F
        cmp     #$C0
        bne     L6_82CE
        lda     #$00
        sta     $6C
        jmp     L6_840C
L6_82CE:
        lda     $10
        lsr     A
        sta     $10
        lda     $11
        lsr     A
        lsr     A
        lsr     A
        lsr     A
        sta     $11
        lsr     A
        ora     $10
        tay
        lda     $0400,Y
        bcs     L6_82E8
        lsr     A
        lsr     A
        lsr     A
        lsr     A
L6_82E8:
        and     #$0F
        cpy     #$60
        bcc     L6_82F0
        lda     #$09
L6_82F0:
        sta     $6C
        bit     $6F
        bvc     L6_82FB
        lda     $6C
        jmp     L6_8317
L6_82FB:
        lda     $0530,X
        lsr     A
        lsr     A
        lsr     A
        lsr     A
        lsr     A
        ora     $10
        tay
        lda     $0400,Y
        bcs     L6_830F
        lsr     A
        lsr     A
        lsr     A
        lsr     A
L6_830F:
        and     #$0F
        cpy     #$60
        bcc     L6_8317
        lda     #$09
L6_8317:
        sta     $6D
        bit     $6F
        bpl     L6_8322
        lda     $6C
        jmp     L6_8345
L6_8322:
        lda     $0518,X
        clc
        adc     $06B0,X
        and     #$F0
        lsr     A
        sta     $10
        lda     $11
        lsr     A
        ora     $10
        tay
        lda     $0400,Y
        bcs     L6_833D
        lsr     A
        lsr     A
        lsr     A
        lsr     A
L6_833D:
        and     #$0F
        cpy     #$60
        bcc     L6_8345
        lda     #$09
L6_8345:
        sta     $6E
        ldy     $6C
        lda     $8425,Y
        sta     $10
        ldy     $6D
        lda     $8425,Y
        sta     $11
        lda     $6E
        lda     $8425,Y
        sta     $12
        ora     $11
        ora     $10
        bne     L6_8365
        jmp     L6_840C
L6_8365:
        lda     $05D8,X
        bmi     L6_8375
        lda     $0518,X
        clc
        adc     $06B0,X
        ora     #$0F
        bne     L6_837E
L6_8375:
        lda     $0518,X
        clc
        adc     $06B0,X
        and     #$F0
L6_837E:
        sec
        sbc     $06B0,X
        sta     $0518,X
        lda     $0608,X
        bmi     L6_8391
        lda     $0530,X
        ora     #$0F
        bne     L6_8396
L6_8391:
        lda     $0530,X
        and     #$F0
L6_8396:
        sta     $0530,X
        bit     $6F
        bvc     L6_83A7
        lda     $10
        bne     L6_83A4
L6_83A1:
        jmp     L6_840C
L6_83A4:
        jmp     L6_8415
L6_83A7:
        bpl     L6_83B9
        lda     $10
        beq     L6_83A1
L6_83AD:
        lda     $17
        sec
        sbc     $06B0,X
        sta     $0518,X
        jmp     L6_841A
L6_83B9:
        lda     $0518,X
        clc
        adc     $06B0,X
        eor     #$FF
        clc
        adc     #$01
        clc
        adc     $17
        bcs     L6_83CE
        eor     #$FF
        adc     #$01
L6_83CE:
        sta     $13
        lda     $19
        sec
        sbc     $0530,X
        bcs     L6_83DC
        eor     #$FF
        adc     #$01
L6_83DC:
        cmp     $13
        bne     L6_83EA
        lda     $11
        bne     L6_83F6
        lda     $12
        bne     L6_8406
        beq     L6_841A
L6_83EA:
        bcs     L6_83FC
        lda     $11
        bne     L6_83F6
        lda     $10
        bne     L6_83AD
        beq     L6_840C
L6_83F6:
        lda     $12
        beq     L6_8415
        bne     L6_841A
L6_83FC:
        lda     $12
        bne     L6_8406
        lda     $10
        bne     L6_8415
        beq     L6_840C
L6_8406:
        lda     $11
        beq     L6_83AD
        bne     L6_841A
L6_840C:
        lda     $17
        sec
        sbc     $06B0,X
        sta     $0518,X
L6_8415:
        lda     $19
        sta     $0530,X
L6_841A:
        lda     $16
        sta     $0758,X
        lda     $18
        sta     $0770,X
        rts

; ---- UNCLAIMED (gap) $8425-$8434, 16 bytes
        .byte   $00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$01,$00

; ---- bank6.code_8435 (code) $8435-$8470, 60 bytes
L6_8435:
        lda     $0530,X
        sta     $1B
        lda     $0518,X
        clc
        adc     $06B0,X
        sta     $1A
L6_8443:
        bit     $30
        bvs     L6_844D
        lda     $1A
        cmp     #$C0
        bcc     L6_8451
L6_844D:
        lda     #$00
        beq     L6_846B
L6_8451:
        and     #$F0
        lsr     A
        sta     $10
        lda     $1B
        lsr     A
        lsr     A
        lsr     A
        lsr     A
        lsr     A
        ora     $10
        tay
        lda     $0400,Y
        bcs     L6_8469
        lsr     A
        lsr     A
        lsr     A
        lsr     A
L6_8469:
        and     #$0F
L6_846B:
        sta     $6C
        rts
L6_846E:
        jsr     L7_C006

; ---- bank6.inline_8471 (data) $8471-$8473, 3 bytes
; Far-call argument at $8471
        .byte   $03,$FF,$7F

; ---- bank6.code_8474 (code) $8474-$8477, 4 bytes
        rts
L6_8475:
        jsr     L7_C006

; ---- bank6.inline_8478 (data) $8478-$847A, 3 bytes
; Far-call argument at $8478
        .byte   $03,$05,$80

; ---- bank6.code_847B (code) $847B-$847B, 1 bytes
        rts

; ---- UNCLAIMED (gap) $847C-$848F, 20 bytes
        .byte   $81,$43,$82,$83,$25,$27,$29,$27,$25,$25,$25,$18,$25,$26,$28,$26
        .byte   $25,$25,$25,$17

; ---- bank6.code_8490 (code) $8490-$8512, 131 bytes
L6_8490:
        lda     $0500,X
        bmi     L6_84BF
        jsr     L7_C0AE
        lda     $05A8
        sta     $05A8,X
        ldy     $3A
        lda     $847C,Y
        sta     $0698,X
        lda     $0788,X
        bit     $30
        bvc     L6_84AF
        lda     #$0C
L6_84AF:
        sta     $07A0,X
        jsr     L7_C102
        lda     #$02
        sta     $0560,X
        lda     #$25
        jsr     L7_C030
L6_84BF:
        inc     $0788,X
        lda     $0788,X
        and     #$01
        asl     A
        asl     A
        adc     $3A
        tay
        lda     $07A0,X
        and     #$07
        cmp     #$04
        beq     L6_84DB
        lda     $8480,Y
        jmp     L6_84DE
L6_84DB:
        lda     $8488,Y
L6_84DE:
        sta     $0548,X
        jsr     L7_C08D
        jsr     L7_C0B1
        lda     $06E0,X
        clc
        adc     $06F8,X
        ror     A
        sta     $1B
        lda     $0710,X
        clc
        adc     $0728,X
        ror     A
        sta     $1A
        jsr     L6_8443
        sty     $14
        ldy     $6C
        lda     $8513,Y
        beq     L6_850A
        jsr     L6_8523
L6_850A:
        lda     $0590,X
        bne     L6_8512
        jmp     L7_C048
L6_8512:
        rts

; ---- UNCLAIMED (gap) $8513-$8522, 16 bytes
        .byte   $00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$00,$00,$00,$01,$00

; ---- bank6.code_8523 (code) $8523-$8652, 304 bytes
L6_8523:
        cpy     #$0E
        beq     L6_852B
        cpy     #$09
        bne     L6_8533
L6_852B:
        lda     #$21
        jsr     L7_C030
        jmp     L6_85E6
L6_8533:
        cpy     #$05
        bne     L6_8556
        lda     #$01
        sta     $15
        lda     #$00
        sta     $17
        lda     #$28
L6_8541:
        sta     $16
        lda     $1B
        sta     $19
        lda     $1A
        sta     $18
        jsr     L7_C117
        lda     #$23
        jsr     L7_C030
        jmp     L6_85E6
L6_8556:
        cpy     #$0A
        bne     L6_85C6
        lda     #$02
        sta     $15
        lda     #$00
        sta     $17
        lda     $1B
        cmp     #$40
        bcs     L6_85B0
        ldy     #$01
L6_856A:
        lda     a:$0058,y
        sec
        sbc     #$10
        sta     a:$0058,y
        bcs     L6_85A8
        and     #$0F
        cmp     #$08
        beq     L6_859F
        sta     $10
        sty     $11
        ldy     #$00
L6_8581:
        cpy     $11
        beq     L6_8597
        lda     a:$0058,y
        and     #$0F
        cmp     #$08
        beq     L6_8592
        cmp     $10
        bne     L6_859B
L6_8592:
        iny
        cpy     #$04
        bne     L6_8581
L6_8597:
        lda     #$00
        beq     L6_8541
L6_859B:
        lda     #$04
        bne     L6_8541
L6_859F:
        lda     #$00
        sta     $15
        lda     #$1C
        jmp     L6_8541
L6_85A8:
        lda     #$20
        jsr     L7_C030
        jmp     L6_85E6
L6_85B0:
        cmp     #$C0
        bcc     L6_85B8
        ldy     #$02
        bne     L6_856A
L6_85B8:
        lda     $1A
        cmp     #$60
        bcs     L6_85C2
        ldy     #$00
        beq     L6_856A
L6_85C2:
        ldy     #$03
        bne     L6_856A
L6_85C6:
        cpy     #$06
        beq     L6_85E0
        dey
        sty     $15
        lda     #$20
        jsr     L7_C030
        lda     $1B
        sta     $19
        lda     $1A
        sta     $18
        jsr     L7_C11D
        jmp     L6_85E6
L6_85E0:
        lda     #$55
        sta     $17
        bne     L6_859F
L6_85E6:
        lda     $0590,X
        sec
        sbc     #$08
        bcs     L6_85F0
        lda     #$00
L6_85F0:
        sta     $0590,X
        rts
L6_85F4:
        asl     A
        tay
L6_85F6:
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
L6_8606:
        lda     $45
        jsr     L6_8B8F
        lda     $45
        jsr     L7_C138
        jmp     L7_C072
L6_8613:
        jmp     L7_C048
L6_8616:
        ldy     $3C
        lda     $879A,Y
        bmi     L6_8644
        dec     $3F
        bne     L6_8644
        lda     $3B
        cmp     #$03
        lda     #$3C
        bcs     L6_862B
        lda     #$78
L6_862B:
        sta     $3F
        jsr     L6_8606
        lda     $3E
        bne     L6_8644
        lda     $3B
        cmp     #$03
        bcs     L6_8641
        ldx     #$03
        jsr     L7_C048
        ldx     #$04
L6_8641:
        jmp     L7_C048
L6_8644:
        lda     $07B8,X
        bne     L6_864E
        lda     #$FF
        sta     $0590,X
L6_864E:
        lda     $3C
        jsr     L6_85F4

; ---- UNCLAIMED (gap) $8653-$866A, 24 bytes
        .byte   $47,$C0,$B1,$87,$02,$88,$33,$88,$74,$88,$6F,$89,$B1,$87,$13,$8A
        .byte   $F0,$88,$C3,$8A,$EC,$8A,$EC,$8A

; ---- bank6.code_866B (code) $866B-$86E6, 124 bytes
L6_866B:
        lda     $0500,X
        bmi     L6_8616
        ora     #$80
        sta     $0500,X
        lda     #$13
        sta     $0620,X
        lda     $3E
        beq     L6_8613
        jsr     L7_C0A2
        lda     #$00
        sta     $07A0,X
        ldy     $3C
        cpy     #$09
        bne     L6_8690
        bit     $30
        bvc     L6_8613
L6_8690:
        lda     $879A,Y
        pha
        bpl     L6_8699
        jsr     L6_8606
L6_8699:
        pla
        and     #$7F
        beq     L6_86A1
        jsr     L7_C030
L6_86A1:
        ldy     $3C
        lda     $878F,Y
        sta     $0560,X
        lda     $8784,Y
        sta     $0548,X
        lda     $3D
        asl     A
        asl     A
        adc     $3D
        asl     A
        adc     $3D
        adc     $3C
        tay
        lda     $05A8
        sta     $05A8,X
        lda     $86F5,Y
        beq     L6_86C9
        sta     $05A8,X
L6_86C9:
        lda     $8716,Y
        sta     $07B8,X
        bne     L6_86D3
        lda     #$FF
L6_86D3:
        sta     $0590,X
        lda     $8737,Y
        sta     $0698,X
        lda     $8758,Y
        sta     $0578,X
        lda     $3C
        jsr     L6_85F4

; ---- UNCLAIMED (gap) $86E7-$8B8E, 1192 bytes
        .byte   $47,$C0,$A6,$87,$ED,$87,$05,$88,$69,$88,$46,$89,$D3,$87,$01,$8A
        .byte   $DD,$88,$99,$8A,$EC,$8A,$EC,$8A,$9E,$8B,$00,$00,$01,$00,$10,$10
        .byte   $00,$04,$02,$00,$00,$00,$00,$02,$00,$20,$18,$00,$07,$04,$00,$00
        .byte   $00,$00,$06,$00,$30,$20,$00,$0A,$10,$00,$00,$03,$02,$08,$00,$00
        .byte   $80,$80,$00,$00,$00,$00,$10,$04,$20,$00,$00,$00,$F0,$00,$00,$00
        .byte   $00,$30,$10,$00,$00,$00,$00,$00,$00,$00,$00,$00,$43,$06,$C1,$01
        .byte   $0C,$02,$03,$01,$02,$00,$00,$82,$42,$85,$00,$1E,$41,$81,$01,$03
        .byte   $00,$00,$83,$43,$C2,$00,$3C,$06,$82,$01,$03,$00,$00,$30,$10,$10
        .byte   $14,$30,$30,$30,$10,$18,$30,$30,$30,$10,$30,$14,$30,$34,$30,$30
        .byte   $38,$30,$30,$30,$10,$34,$14,$34,$34,$34,$34,$3C,$34,$34,$1A,$21
        .byte   $21,$1A,$37,$1A,$1A,$1A,$00,$00,$00,$02,$01,$00,$01,$00,$00,$00
        .byte   $00,$02,$01,$02,$26,$2A,$2B,$26,$AE,$A7,$26,$A6,$28,$2C,$2C,$00
        .byte   $BD,$88,$07,$20,$02,$C1,$A9,$02,$20,$60,$88,$20,$B8,$87,$4C,$E1
        .byte   $84,$A9,$80,$A0,$02,$20,$A5,$C0,$BD,$48,$05,$C9,$1A,$D0,$07,$B9
        .byte   $DE,$87,$9D,$C8,$06,$60,$B9,$DF,$87,$9D,$C8,$06,$60,$20,$E1,$87
        .byte   $20,$02,$C1,$A9,$01,$D0,$D1,$76,$78,$7C,$BD,$88,$07,$24,$30,$50
        .byte   $05,$A9,$0C,$9D,$88,$07,$60,$20,$E1,$87,$E0,$04,$18,$D0,$04,$69
        .byte   $0B,$90,$02,$69,$05,$29,$0F,$9D,$88,$07,$10,$12,$4C,$E1,$84,$24
        .byte   $30,$50,$08,$A4,$32,$B9,$37,$88,$9D,$88,$07,$BD,$88,$07,$20,$02
        .byte   $C1,$A5,$3D,$C9,$03,$90,$07,$A9,$76,$9D,$C8,$06,$D0,$0F,$BC,$88
        .byte   $07,$B9,$40,$88,$9D,$48,$05,$B9,$50,$88,$9D,$60,$05,$4C,$E1,$84
        .byte   $0B,$0B,$0B,$0C,$0C,$0C,$0D,$0D,$0D,$2C,$2C,$2D,$2E,$2E,$2E,$2D
        .byte   $2C,$2C,$2C,$2D,$2E,$2E,$2E,$2D,$2C,$40,$40,$C0,$80,$80,$80,$80
        .byte   $00,$00,$00,$00,$00,$00,$00,$40,$40,$C5,$3D,$B0,$05,$A9,$21,$9D
        .byte   $48,$05,$60,$BD,$98,$06,$9D,$D0,$07,$A9,$02,$20,$60,$88,$AD,$30
        .byte   $05,$9D,$30,$05,$AD,$18,$05,$24,$30,$50,$03,$38,$E9,$10,$9D,$18
        .byte   $05,$20,$B8,$87,$BD,$A0,$07,$FE,$A0,$07,$BC,$D0,$07,$D0,$01,$0A
        .byte   $29,$1F,$A8,$A5,$3C,$C9,$04,$F0,$17,$20,$F6,$C0,$C9,$80,$6A,$C9
        .byte   $80,$6A,$85,$18,$20,$F9,$C0,$C9,$80,$6A,$C9,$80,$6A,$4C,$C5,$88
        .byte   $20,$F6,$C0,$20,$CF,$88,$85,$18,$20,$F9,$C0,$20,$CF,$88,$85,$19
        .byte   $20,$08,$89,$B0,$9D,$4C,$E7,$84,$C9,$80,$6A,$85,$10,$C9,$80,$6A
        .byte   $18,$65,$10,$C9,$80,$6A,$60,$20,$E1,$87,$20,$02,$C1,$A9,$02,$20
        .byte   $60,$88,$A4,$3D,$B9,$04,$89,$9D,$D0,$07,$BD,$48,$05,$85,$15,$A9
        .byte   $00,$9D,$48,$05,$20,$8D,$C0,$A5,$15,$9D,$48,$05,$D0,$83,$01,$00
        .byte   $00,$BD,$30,$05,$48,$18,$65,$19,$24,$19,$30,$04,$90,$04,$B0,$2A
        .byte   $90,$28,$9D,$30,$05,$BD,$18,$05,$48,$18,$65,$18,$24,$18,$30,$04
        .byte   $90,$04,$B0,$15,$90,$13,$9D,$18,$05,$20,$90,$C0,$20,$B1,$C0,$68
        .byte   $9D,$18,$05,$68,$9D,$30,$05,$18,$60,$68,$68,$9D,$30,$05,$38,$60
        .byte   $BD,$98,$06,$48,$A9,$02,$9D,$98,$06,$BD,$88,$07,$20,$02,$C1,$68
        .byte   $9D,$98,$06,$A9,$FE,$9D,$68,$06,$18,$7D,$D8,$05,$9D,$D8,$05,$A9
        .byte   $3C,$9D,$A0,$07,$A9,$37,$9D,$48,$05,$BD,$A0,$07,$F0,$35,$A9,$12
        .byte   $20,$9C,$C0,$DE,$A0,$07,$F0,$1C,$A9,$60,$A0,$04,$20,$A5,$C0,$B9
        .byte   $CC,$89,$9D,$C8,$06,$B9,$D0,$89,$9D,$60,$05,$20,$6D,$AF,$20,$57
        .byte   $AF,$4C,$8D,$C0,$A9,$42,$20,$30,$C0,$A9,$7C,$9D,$C8,$06,$A9,$21
        .byte   $9D,$48,$05,$DE,$98,$06,$D0,$03,$4C,$48,$C0,$BD,$98,$06,$A4,$3D
        .byte   $39,$D3,$89,$0A,$79,$D6,$89,$A8,$B9,$DA,$89,$85,$19,$B9,$DB,$89
        .byte   $85,$18,$4C,$C7,$88,$7A,$76,$78,$76,$00,$00,$00,$40,$03,$07,$0F
        .byte   $00,$08,$08,$00,$00,$00,$EC,$F0,$08,$10,$08,$F4,$F4,$F4,$0C,$0C
        .byte   $F4,$0C,$0C,$E8,$E8,$E8,$18,$18,$E8,$18,$18,$D0,$00,$00,$D0,$30
        .byte   $00,$00,$30,$E8,$00,$00,$E8,$18,$00,$00,$18,$E0,$03,$F0,$05,$A9
        .byte   $02,$9D,$60,$05,$BD,$88,$07,$20,$02,$C1,$4C,$8C,$8A,$DE,$80,$06
        .byte   $D0,$7B,$E0,$03,$D0,$04,$A0,$04,$D0,$02,$A0,$03,$B9,$00,$05,$C9
        .byte   $83,$D0,$04,$B9,$A0,$07,$A8,$84,$11,$BC,$A0,$07,$D0,$02,$A0,$05
        .byte   $84,$10,$B9,$00,$05,$10,$15,$C9,$B1,$90,$04,$C9,$B6,$90,$0D,$B9
        .byte   $78,$05,$30,$08,$29,$04,$D0,$04,$C4,$11,$D0,$0D,$C8,$C0,$18,$90
        .byte   $02,$A0,$05,$C4,$10,$D0,$DB,$A0,$00,$98,$9D,$A0,$07,$20,$14,$C1
        .byte   $38,$FD,$88,$07,$F0,$14,$29,$0F,$C9,$08,$90,$0B,$D0,$04,$E0,$04
        .byte   $90,$05,$DE,$88,$07,$B0,$03,$FE,$88,$07,$BD,$88,$07,$29,$0F,$9D
        .byte   $88,$07,$20,$02,$C1,$A4,$3D,$B9,$96,$8A,$9D,$80,$06,$4C,$B2,$87
        .byte   $08,$04,$01,$A9,$00,$9D,$68,$06,$A9,$81,$9D,$80,$06,$A4,$3D,$B9
        .byte   $DD,$8A,$9D,$D8,$05,$B9,$E0,$8A,$9D,$C8,$06,$B9,$E3,$8A,$48,$8A
        .byte   $A8,$68,$20,$3B,$C1,$A9,$03,$9D,$20,$06,$20,$41,$C1,$20,$29,$C1
        .byte   $B0,$2C,$A9,$08,$9D,$78,$05,$A4,$3D,$B9,$E6,$8A,$25,$41,$D0,$06
        .byte   $B9,$E9,$8A,$9D,$78,$05,$60,$FA,$F6,$F8,$76,$76,$02,$00,$03,$06
        .byte   $01,$00,$00,$18,$38,$3C,$A5,$F7,$05,$F8,$29,$80,$D0,$03,$4C,$48
        .byte   $C0,$AD,$30,$05,$9D,$30,$05,$AD,$18,$05,$9D,$18,$05,$AD,$68,$06
        .byte   $20,$E4,$87,$A8,$A5,$3C,$C9,$0A,$F0,$0C,$98,$E9,$04,$E0,$04,$90
        .byte   $02,$69,$07,$29,$0F,$A8,$B9,$6F,$8B,$85,$18,$B9,$73,$8B,$85,$19
        .byte   $A5,$41,$29,$01,$F0,$04,$06,$19,$06,$18,$24,$30,$50,$0A,$C0,$0C
        .byte   $D0,$06,$A5,$18,$E9,$08,$85,$18,$98,$4A,$29,$03,$A8,$B9,$83,$8B
        .byte   $9D,$48,$05,$B9,$87,$8B,$9D,$C8,$06,$BD,$60,$05,$29,$03,$19,$8B
        .byte   $8B,$9D,$60,$05,$AD,$A8,$05,$0A,$A4,$3D,$88,$F0,$05,$0A,$88,$F0
        .byte   $01,$0A,$9D,$A8,$05,$4C,$C7,$88,$00,$06,$0B,$0F,$10,$0F,$0B,$06
        .byte   $00,$FA,$F5,$F1,$F0,$F1,$F5,$FA,$00,$06,$0B,$0F,$1A,$79,$37,$79
        .byte   $7C,$7A,$7E,$7A,$00,$80,$00,$00

; ---- bank6.code_8B8F (code) $8B8F-$8B9E, 16 bytes
L6_8B8F:
        sta     $10
        lda     $4C
        sec
        sbc     $10
        sta     $4C
        bcs     L6_8B9C
        dec     $4D
L6_8B9C:
        jmp     L7_C05A

; ---- UNCLAIMED (gap) $8B9F-$8BCD, 47 bytes
        .byte   $A5,$F5,$05,$F6,$29,$80,$F0,$24,$A9,$2F,$20,$30,$C0,$A9,$30,$20
        .byte   $CC,$C0,$A9,$2F,$20,$30,$C0,$A0,$06,$20,$21,$C0,$20,$CE,$8B,$A9
        .byte   $0F,$20,$CC,$C0,$CE,$AF,$04,$C6,$3E,$20,$72,$C0,$4C,$48,$C0

; ---- bank6.code_8BCE (code) $8BCE-$8C69, 156 bytes
L6_8BCE:
        ldy     #$05
L6_8BD0:
        lda     $0500,Y
        bpl     L6_8BE9
        lda     $0578,Y
        and     #$40
        bne     L6_8BE9
        lda     $0500,Y
        and     #$7F
        sta     $0740,Y
        lda     #$08
        sta     $0500,Y
L6_8BE9:
        iny
        cpy     #$18
        bne     L6_8BD0
        rts
L6_8BEF:
        lda     $0500,X
        bmi     L6_8C1F
        jsr     L7_C0A8
        lda     $0518,X
        bne     L6_8BFF
        jsr     L7_C0F0
L6_8BFF:
        lda     $07E8,X
        clc
        adc     #$0C
        sta     $06C8,X
        jsr     L7_C0A2
        lda     #$01
        sta     $0560,X
        lda     #$1A
        sta     $0548,X
        jsr     L7_C0EA
        and     #$7F
        adc     #$20
        sta     $0788,X
L6_8C1F:
        lda     $0788,X
        beq     L6_8C50
        jsr     L7_C12C
        lda     $0518,X
        cmp     $0788,X
        bcs     L6_8C3E
        lda     $B8
        ora     $B9
        beq     L6_8C3E
        jsr     L7_C090
        jsr     L7_C0CF
        jmp     L7_C0D2
L6_8C3E:
        lda     #$00
        sta     $0788,X
        lda     #$06
        sta     $0698,X
        jsr     L7_C0FC
        lda     #$02
        sta     $0560,X
L6_8C50:
        lda     #$40
        ldy     #$07
        jsr     L7_C0A5
        lda     $8C71,Y
        sta     $14
        lda     $8C78,Y
        sta     $15
        lda     $8C6A,Y
        jsr     L6_A1D8
        jmp     L6_9F4F

; ---- UNCLAIMED (gap) $8C6A-$8C7E, 21 bytes
        .byte   $1A,$19,$19,$19,$19,$19,$19,$00,$40,$40,$40,$00,$00,$00,$0C,$08
        .byte   $04,$00,$00,$04,$08

; ---- bank6.code_8C7F (code) $8C7F-$8D67, 233 bytes
L6_8C7F:
        lda     $0500,X
        bmi     L6_8C50
        jsr     L7_C0A8
        lda     #$00
        sta     $0560,X
        lda     $0788,X
        jsr     L7_C102
        jsr     L7_C0A2
        jmp     L6_8C50
L6_8C98:
        ldy     $0500,X
        bmi     L6_8CC8
        lda     $8D50,Y
        sta     $0560,X
        lda     $8D54,Y
        sta     $07B8,X
        jsr     L7_C0A8
        jsr     L7_C165
        lda     #$01
        sta     $05D8,X
        lda     #$82
        sta     $0548,X
        lda     #$80
        sta     $0530,X
        lda     #$60
        sta     $0788,X
        lda     #$00
        sta     $0668,X
L6_8CC8:
        lda     #$02
        jsr     L7_C09C
        lda     $0788,X
        beq     L6_8CF6
        lda     $05D8,X
        bpl     L6_8CDF
        lda     $0518,X
        cmp     $0788,X
        bcc     L6_8CE3
L6_8CDF:
        jsr     L7_C08D
        rts
L6_8CE3:
        lda     #$00
        sta     $0788,X
        lda     #$60
        sta     $0668,X
        ldy     $0500,X
        lda     $8CD2,Y
        sta     $0560,X
L6_8CF6:
        lda     $41
        and     #$1F
        bne     L6_8D2C
        jsr     L7_C027
        bcs     L6_8D5F
        lda     $07E8,X
        adc     #$1C
        sta     $17
        lda     #$02
        sta     $16
        jsr     L7_C13E
        lda     #$15
        jsr     L7_C13B
        lda     $0518,X
        adc     #$10
        sta     $0518,Y
        lda     $41
        and     #$7F
        lsr     A
        adc     $0530,X
        sbc     #$17
        sta     $0530,Y
        jmp     L6_8D5F
L6_8D2C:
        and     #$0F
        bne     L6_8D5F
        jsr     L6_AD9A
        tay
        lda     $8D6E,Y
        sta     $15
        jsr     L7_C108
        bcs     L6_8D5F
        lda     $07B8,X
        sta     $0500,Y
        lda     $0518,X
        adc     #$20
        sta     $0518,Y
        lda     $0530,X
        adc     $15
        sta     $0530,Y
        lda     #$03
        sta     $07A0,Y
        lda     $0518,X
        sta     $0788,Y
L6_8D5F:
        jsr     L7_C08D
        jsr     L7_C0C6
        jmp     L7_C0D8

; ---- UNCLAIMED (gap) $8D68-$8D6F, 8 bytes
        .byte   $01,$03,$02,$00,$16,$27,$E0,$20

; ---- bank6.code_8D70 (code) $8D70-$8E5E, 239 bytes
L6_8D70:
        lda     $0500,X
        bmi     L6_8D9B
        jsr     L7_C0A8
        jsr     L7_C165
        lda     #$00
        sta     $0560,X
        jsr     L7_C0F0
        lda     #$78
        sta     $0788,X
        lda     #$C0
        sta     $0518,X
L6_8D8D:
        jsr     L7_C147
        lda     #$FB
        sta     $0668,X
        sta     $05D8,X
        jsr     L7_C0A2
L6_8D9B:
        lda     $0788,X
        beq     L6_8DA8
        dec     $0788,X
        and     #$01
        beq     L6_8E01
        rts
L6_8DA8:
        lda     #$18
        jsr     L7_C09C
        lda     $0530
        sta     $0680,X
        lda     #$08
        jsr     L7_C09F
        lda     $05D8,X
        bmi     L6_8E01
        lda     $0518,X
        cmp     #$C0
        bcs     L6_8D8D
        lda     $0638,X
        cmp     #$02
        bcs     L6_8E01
        lda     #$40
        ldy     #$03
        jsr     L7_C0A5
        cpy     #$02
        bcc     L6_8E01
        jsr     L7_C0FF
        sta     $14
        lda     #$02
        sta     $15
L6_8DDF:
        jsr     L7_C108
        bcs     L6_8E01
        lda     #$27
        jsr     L7_C105
        lda     #$01
        sta     $07A0,Y
        stx     $10
        ldx     $15
        lda     $8E65,X
        clc
        adc     $14
        sta     $0788,Y
        ldx     $10
        dec     $15
        bpl     L6_8DDF
L6_8E01:
        ldy     $0638,X
        lda     $8E5F,Y
        sta     $0548,X
        lda     $8E62,Y
        jsr     L6_A1E7
        lda     $0788,X
        beq     L6_8E1B
        jsr     L7_C090
        jmp     L6_8E30
L6_8E1B:
        jsr     L7_C08D
        bcc     L6_8E30
L6_8E20:
        lda     #$00
        sta     $0530,X
        lda     $0608,X
        bmi     L6_8E2D
        dec     $0530,X
L6_8E2D:
        jmp     L7_C123
L6_8E30:
        lda     $84
        sec
        sbc     #$28
        sta     $84
        bcc     L6_8E43
        lda     $07E8,X
        sta     $87
        lda     #$7F
        jsr     L7_C093
L6_8E43:
        lda     $0788,X
        beq     L6_8E49
        rts
L6_8E49:
        jsr     L7_C0B1
        lda     $0710,X
        sec
        sbc     #$30
        bcs     L6_8E56
        lda     #$00
L6_8E56:
        sta     $0710,X
        jsr     L7_C0C9
        jmp     L7_C0D8

; ---- UNCLAIMED (gap) $8E5F-$8E67, 9 bytes
        .byte   $80,$80,$81,$1E,$16,$00,$00,$04,$0C

; ---- bank6.code_8E68 (code) $8E68-$9030, 457 bytes
L6_8E68:
        ldy     $0500,X
        bmi     L6_8E9F
        lda     $900D,Y
        sta     $0560,X
        lda     $9010,Y
        sta     $07A0,X
        lda     $9013,Y
        sta     $07D0,X
        jsr     L7_C0A8
        jsr     L7_C165
        lda     #$00
        sta     $07B8,X
        lda     #$6D
        sta     $0548,X
        jsr     L7_C0F0
        lda     #$28
        sta     $0518,X
        lda     #$3C
        sta     $0788,X
        jsr     L7_C0A2
L6_8E9F:
        lda     $0788,X
        beq     L6_8EAF
        dec     $0788,X
        lda     $0788,X
        and     #$01
        bne     L6_8EC0
        rts
L6_8EAF:
        lda     $41
        and     #$01
        bne     L6_8EB8
        jsr     L6_A325
L6_8EB8:
        lda     $07A0,X
        ldy     #$3C
        jsr     L7_C0A5
L6_8EC0:
        jsr     L7_C090
        lda     $0740,X
        beq     L6_8ECB
        jmp     L6_8F50
L6_8ECB:
        lda     $07B8,X
        cmp     #$01
        bcc     L6_8F41
        beq     L6_8EEF
        lda     $0638,X
        cmp     #$1E
        bcc     L6_8EE0
        lda     #$14
        sta     $0638,X
L6_8EE0:
        lda     $0590,X
        cmp     #$32
        bcs     L6_8EEC
        lda     #$01
        sta     $0560,X
L6_8EEC:
        jmp     L6_8FAA
L6_8EEF:
        lda     #$01
        sta     $86
        lda     $0590,X
        cmp     #$14
        bcs     L6_8F50
        jsr     L7_C108
        bcs     L6_8F12
        lda     #$05
        sta     $0500,Y
        sty     $15
        jsr     L7_C108
        bcc     L6_8F19
        ldy     $15
        lda     #$00
        sta     $0500,Y
L6_8F12:
        lda     #$14
        sta     $0590,X
        bne     L6_8F50
L6_8F19:
        jsr     L6_903A
        lda     $0680,X
        sta     $0530,Y
        lda     #$01
        sta     $0560,Y
        ldy     $15
        jsr     L6_903A
        lda     $0668,X
        sta     $0530,Y
        lda     #$41
        sta     $0560,Y
        lda     #$C8
        sta     $0590,X
        inc     $07B8,X
        bne     L6_8F50
L6_8F41:
        lda     $0590,X
        cmp     #$14
        bcs     L6_8F50
        lda     #$64
        sta     $0590,X
        inc     $07B8,X
L6_8F50:
        lda     $0638,X
        cmp     #$0A
        bcs     L6_8F5B
L6_8F57:
        lda     #$00
        beq     L6_8F73
L6_8F5B:
        cmp     #$1A
        bcs     L6_8F63
        sbc     #$09
        bcs     L6_8F73
L6_8F63:
        cmp     #$22
        bcs     L6_8F6B
        lda     #$10
        bne     L6_8F73
L6_8F6B:
        cmp     #$32
        bcs     L6_8F57
        eor     #$FF
        adc     #$33
L6_8F73:
        sta     $15
        lda     $84
        clc
        adc     #$38
        sta     $84
        lda     $0530,X
        sec
        sbc     #$08
        sbc     $15
        bcc     L6_8F90
        sta     $0680,X
        sta     $85
        lda     #$6E
        jsr     L7_C093
L6_8F90:
        lda     $0530,X
        clc
        adc     #$08
        adc     $15
        bcs     L6_8FAA
        sta     $0668,X
        sta     $85
        lda     $86
        eor     #$40
        sta     $86
        lda     #$6E
        jsr     L7_C093
L6_8FAA:
        lda     $0788,X
        beq     L6_8FB0
        rts
L6_8FB0:
        lda     $0638,X
        cmp     #$1C
        bne     L6_8FEC
        lda     $07E8,X
        clc
        adc     #$1E
        sta     $17
        lda     #$10
        sta     $16
        jsr     L7_C027
        bcs     L6_8FEC
        inc     $0638,X
        lda     #$12
        jsr     L7_C13B
        lda     #$00
        sta     $0560,Y
        lda     #$03
        sta     $0620,Y
        jsr     L7_C13E
        lda     $0518,Y
        clc
        adc     #$18
        sta     $0518,Y
        lda     $05A8,X
        sta     $05A8,Y
L6_8FEC:
        lda     $0638,X
        cmp     #$1A
        bcs     L6_9018
        and     #$07
        bne     L6_9018
        lda     $0650,X
        cmp     $07D0,X
        bcs     L6_9018
        jsr     L7_C108
        bcs     L6_9018
        lda     #$27
        jsr     L7_C105
        jsr     L6_AD9A
        asl     A
        asl     A
        asl     A
        sta     $0788,Y
        lda     $07D0,X
        sta     $07A0,Y
L6_9018:
        jsr     L7_C0B1
        lda     $07B8,X
        cmp     #$02
        bcs     L6_902B
        lda     $0728,X
        clc
        adc     #$40
        sta     $0728,X
L6_902B:
        jsr     L7_C0C9
        jmp     L7_C0D8

; ---- UNCLAIMED (gap) $9031-$9039, 9 bytes
        .byte   $03,$02,$00,$20,$40,$80,$01,$01,$05

; ---- bank6.code_903A (code) $903A-$907C, 67 bytes
L6_903A:
        lda     #$AC
        sta     $0500,Y
        lda     $0518,X
        clc
        adc     #$38
        sta     $0518,Y
        lda     #$6E
        sta     $0548,Y
        lda     $06C8,X
        sta     $06C8,Y
        lda     #$52
        sta     $0578,Y
        lda     #$11
        sta     $0620,Y
        lda     #$2A
        sta     $07B8,Y
        lda     #$0B
        sta     $07D0,Y
        lda     #$80
        sta     $05A8,Y
        lda     #$FF
        sta     $0590,Y
        jsr     L7_C147
        lda     #$30
        sta     $05C0,Y
        rts
L6_907A:
        jsr     L7_C006

; ---- bank6.inline_907D (data) $907D-$907F, 3 bytes
; Far-call argument at $907D
        .byte   $03,$11,$80

; ---- bank6.code_9080 (code) $9080-$9083, 4 bytes
        rts
L6_9081:
        jsr     L7_C006

; ---- bank6.inline_9084 (data) $9084-$9086, 3 bytes
; Far-call argument at $9084
        .byte   $03,$14,$80

; ---- bank6.code_9087 (code) $9087-$9170, 234 bytes
        rts
L6_9088:
        lda     $0500,X
        bmi     L6_90B9
        jsr     L7_C0A8
        jsr     L7_C165
        lda     #$80
        sta     $0530,X
        lda     #$60
        sta     $0518,X
        lda     #$30
        sta     $0668,X
        lda     #$00
        sta     $0560,X
        lda     #$04
        sta     $07A0,X
        lda     #$2A
        sta     $0548,X
        lda     #$78
        sta     $0788,X
        jsr     L7_C0A2
L6_90B9:
        jsr     L7_C009
        lda     #$09
        jsr     L7_C09C
        lda     $0530
        sta     $0680,X
        lda     #$04
        jsr     L7_C09F
        jsr     L7_C08D
        bcc     L6_90D7
        jsr     L6_8E20
        jmp     L6_9144
L6_90D7:
        lda     #$20
        ldy     #$08
        jsr     L7_C0A5
        and     #$01
        bne     L6_9124
        lda     $0650,X
        cmp     #$20
        bcs     L6_9124
        jsr     L7_C0FF
        sta     $15
        jsr     L7_C108
        bcs     L6_9124
        lda     #$2C
        jsr     L7_C105
        lda     $0518,X
        clc
        adc     #$38
        sta     $0518,Y
        lda     $15
        sta     $0788,Y
        lda     #$05
        sta     $0698,Y
        lda     #$49
        sta     $07B8,Y
        lda     #$05
        sta     $07D0,Y
        lda     #$30
        sta     $07A0,Y
        lda     #$19
        sta     $0548,Y
        lda     #$80
        sta     $0560,Y
L6_9124:
        ldy     $0638,X
        lda     $9180,Y
        sta     $15
        lda     #$F6
        jsr     L6_914A
        lda     $0638,X
        clc
        adc     #$04
        and     #$07
        tay
        lda     $9180,Y
        sta     $15
        lda     #$0A
        jsr     L6_914A
L6_9144:
        jsr     L7_C0C6
        jmp     L7_C0D8
L6_914A:
        clc
        bmi     L6_9154
        adc     $0530,X
        bcs     L6_9170
        bcc     L6_9159
L6_9154:
        adc     $0530,X
        bcc     L6_9170
L6_9159:
        sta     $85
        lda     $0518,X
        clc
        adc     #$20
        sta     $84
        ldy     $15
        lda     $9171,Y
        sta     $86
        lda     $9176,Y
        jmp     L7_C093
L6_9170:
        rts

; ---- UNCLAIMED (gap) $9171-$9187, 23 bytes
        .byte   $40,$40,$00,$00,$00,$22,$23,$24,$23,$22,$14,$0C,$FC,$F4,$EC,$00
        .byte   $01,$02,$03,$04,$03,$02,$01

; ---- bank6.code_9188 (code) $9188-$92FC, 373 bytes
L6_9188:
        ldy     $0500,X
        bmi     L6_91D9
        cpy     #$46
        beq     L6_91A1
        lda     $92CC,Y
        sta     $07B8,X
        lda     $8FE6,Y
        sta     $0560,X
        ldy     #$6D
        bne     L6_91A5
L6_91A1:
        lda     #$01
        ldy     #$88
L6_91A5:
        sta     $0560,X
        tya
        sta     $0548,X
        jsr     L7_C0A8
        jsr     L7_C165
L6_91B2:
        jsr     L7_C0F0
        lda     $0560,X
        eor     #$40
        sta     $0560,X
        lda     $0530,X
        and     #$7F
        adc     #$20
        sta     $0518,X
        lda     #$78
        sta     $0788,X
        lda     #$00
        sta     $07A0,X
        lda     #$04
        sta     $0680,X
        jsr     L7_C0A2
L6_91D9:
        dec     $0788,X
        bpl     L6_91EC
        jsr     L7_C0FF
        sta     $0668,X
        inc     $07A0,X
        lda     #$78
        sta     $0788,X
L6_91EC:
        lda     $07A0,X
        beq     L6_91FB
        cmp     #$03
        beq     L6_9205
        bcs     L6_91B2
        cmp     #$02
        bne     L6_920C
L6_91FB:
        dec     $0788,X
        lda     $0788,X
        and     #$02
        bne     L6_9206
L6_9205:
        rts
L6_9206:
        jsr     L7_C090
        jmp     L6_92BE
L6_920C:
        jsr     L7_C090
        lda     #$20
        ldy     #$09
        jsr     L7_C0A5
        lda     $0500,X
        cmp     #$C6
        beq     L6_9257
        lda     $0638,X
        cmp     #$02
        beq     L6_9227
        jmp     L6_92B2
L6_9227:
        inc     $0638,X
        lda     #$1E
        sta     $0788,X
        lda     #$10
        sta     $15
L6_9233:
        jsr     L7_C108
        bcs     L6_92B2
        stx     $10
        lda     $0668,X
        adc     $15
        sbc     #$04
        sta     $0788,Y
        ldx     $10
        lda     #$27
        jsr     L7_C105
        lda     $07B8,X
        sta     $07A0,Y
        dec     $15
        bne     L6_9233
        beq     L6_92B2
L6_9257:
        lda     $0650,X
        cmp     #$20
        bcs     L6_92B2
        lda     $92FD,Y
        clc
        adc     $0668,X
        and     #$0F
        sta     $0680,X
        and     #$07
        tay
        lda     $9306,Y
        tay
        lda     $930E,Y
        sta     $14
        lda     $9310,Y
        sta     $17
        jsr     L7_C108
        bcs     L6_92B2
        lda     #$2C
        jsr     L7_C105
        lda     $0518,Y
        clc
        adc     #$10
        sta     $0518,Y
        lda     $0680,X
        sta     $0788,Y
        lda     #$41
        sta     $0698,Y
        lda     #$03
        sta     $07B8,Y
        lda     #$05
        sta     $07D0,Y
        lda     $14
        sta     $07A0,Y
        lda     $17
        sta     $0548,Y
        lda     #$81
        sta     $0560,Y
L6_92B2:
        jsr     L7_C0B1
        jsr     L6_92BE
        jsr     L7_C0C9
        jmp     L7_C0D8
L6_92BE:
        lda     $0500,X
        cmp     #$C6
        bne     L6_92E2
        lda     $0680,X
        lsr     A
        lsr     A
        tay
        lda     $9312,Y
        ora     #$01
        sta     $86
        lda     $0680,X
        and     #$07
        tay
        lda     $9306,Y
        tay
        lda     $9316,Y
        jmp     L7_C093
L6_92E2:
        lda     $84
        adc     #$1F
        sta     $84
        lda     $86
        eor     #$80
        sta     $86
        lda     #$6D
        jsr     L7_C093
        lda     $0728,X
        clc
        adc     #$20
        sta     $0728,X
        rts

; ---- UNCLAIMED (gap) $92FD-$9319, 29 bytes
        .byte   $FC,$FD,$FE,$FF,$00,$01,$02,$03,$04,$00,$00,$00,$01,$01,$01,$00
        .byte   $00,$00,$04,$19,$37,$40,$00,$00,$40,$8A,$89,$01,$05

; ---- bank6.code_931A (code) $931A-$93D2, 185 bytes
L6_931A:
        lda     $0500,X
        bmi     L6_9350
        jsr     L7_C0A8
        jsr     L7_C165
        lda     #$7A
        sta     $0548,X
        lda     #$02
        sta     $0560,X
        lda     #$60
        sta     $0668,X
        lda     #$28
        sta     $0518,X
        lda     #$80
        sta     $0680,X
        lda     #$30
        sta     $0530,X
        lda     #$78
        sta     $0788,X
        lda     #$FA
        sta     $07A0,X
        jsr     L7_C0A2
L6_9350:
        jsr     L7_C009
        lda     $07A0,X
        cmp     #$04
        bcs     L6_93AB
        lda     #$40
        ldy     #$06
        jsr     L7_C0A5
        php
        lda     $93D3,Y
        jsr     L6_A1E7
        jsr     L7_C090
        plp
        bcc     L6_937F
        dec     $07A0,X
        bne     L6_93BB
        jsr     L7_C0EA
        and     #$7F
        adc     #$50
        sta     $07A0,X
        bne     L6_93BB
L6_937F:
        lda     $0638,X
        cmp     #$03
        bne     L6_93BB
        lda     $0650,X
        cmp     #$40
        bcs     L6_93BB
        ldy     $07A0,X
        lda     $93D8,Y
        sta     $15
        jsr     L7_C108
        bcs     L6_93BB
        lda     #$27
        jsr     L7_C105
        lda     #$05
        sta     $07A0,Y
        lda     $15
        sta     $0788,Y
        bne     L6_93BB
L6_93AB:
        dec     $07A0,X
        lda     #$10
        jsr     L7_C09C
        lda     #$10
        jsr     L7_C09F
        jsr     L7_C08D
L6_93BB:
        jsr     L7_C0C6
        lda     $0638,X
        beq     L6_93C6
        jsr     L7_C0D8
L6_93C6:
        bcs     L6_93C9
        rts
L6_93C9:
        ldy     $6E
        bne     L6_93D0
        jmp     L7_C0D8
L6_93D0:
        jmp     L7_C168

; ---- UNCLAIMED (gap) $93D3-$93DB, 9 bytes
        .byte   $00,$08,$10,$18,$10,$08,$00,$08,$0C

; ---- bank6.code_93DC (code) $93DC-$95C2, 487 bytes
L6_93DC:
        ldy     $0500,X
        bmi     L6_9419
        lda     $8FEA,Y
        sta     $0560,X
        lda     $9586,Y
        sta     $07D0,X
        jsr     L7_C0A8
        jsr     L7_C165
        lda     #$68
        sta     $0668,X
        lda     #$80
        sta     $0680,X
        lda     #$30
        sta     $0518,X
        lda     #$C0
        sta     $0530,X
        lda     #$40
        sta     $0548,X
        jsr     L7_C0A2
        lda     #$78
        sta     $0788,X
        lda     #$9F
        sta     $07A0,X
L6_9419:
        lda     $07A0,X
        bpl     L6_9438
        dec     $0788,X
        bne     L6_942A
        lda     #$1F
        sta     $07A0,X
        bne     L6_9438
L6_942A:
        lda     $0788,X
        and     #$01
        bne     L6_9432
        rts
L6_9432:
        jsr     L7_C090
        jmp     L6_9481
L6_9438:
        lda     #$07
        jsr     L6_9B09
        lda     $07A0,X
        and     #$20
        beq     L6_9454
        lda     $41
        beq     L6_944E
        jsr     L6_95D0
        jmp     L6_9479
L6_944E:
        jsr     L7_C090
        jmp     L6_9479
L6_9454:
        jsr     L6_95D0
        ldy     $0740,X
        cpy     #$03
        bcs     L6_9479
        lda     #$1C
        cpy     #$02
        bcs     L6_9476
        lda     #$10
        cpy     #$01
        bcs     L6_9476
        lda     #$01
        sta     $0740,X
        lda     #$01
        sta     $0560,X
        lda     #$20
L6_9476:
        sta     $07A0,X
L6_9479:
        lda     $07D0,X
        ldy     #$1C
        jsr     L7_C0A5
L6_9481:
        lda     $07A0,X
        and     #$10
        bne     L6_948C
        lda     #$44
        bne     L6_949E
L6_948C:
        ldy     $0638,X
        cpy     #$08
        bcc     L6_9497
        cpy     #$0B
        bcc     L6_949B
L6_9497:
        lda     #$41
        bne     L6_949E
L6_949B:
        lda     $95C3,Y
L6_949E:
        sta     $17
        jsr     L7_C093
        lda     $86
        and     #$03
        sta     $86
        lda     $07A0,X
        and     #$04
        bne     L6_94B4
        lda     #$4A
        bne     L6_94C5
L6_94B4:
        ldy     $0638,X
        cpy     #$0E
        bcc     L6_94BF
        cpy     #$11
        bcc     L6_94C3
L6_94BF:
        lda     #$48
        bne     L6_94C5
L6_94C3:
        lda     #$49
L6_94C5:
        sta     $15
        jsr     L7_C093
        lda     $07A0,X
        and     #$01
        bne     L6_94D5
        lda     #$47
        bne     L6_94E6
L6_94D5:
        ldy     $0638,X
        cpy     #$18
        bcc     L6_94E0
        cpy     #$1B
        bcc     L6_94E4
L6_94E0:
        lda     #$45
        bne     L6_94E6
L6_94E4:
        lda     #$46
L6_94E6:
        sta     $14
        jsr     L7_C093
        lda     $86
        eor     #$40
        sta     $86
        lda     $15
        jsr     L7_C093
        lda     $14
        jsr     L7_C093
        lda     $07A0,X
        bpl     L6_9501
        rts
L6_9501:
        lda     $0650,X
        cmp     $07D0,X
        bcs     L6_9546
        lda     $17
        cmp     #$44
        beq     L6_9520
        cmp     #$41
        beq     L6_9549
        jsr     L7_C108
        bcs     L6_9546
        lda     #$0B
        jsr     L7_C105
        jmp     L6_95BD
L6_9520:
        jsr     L7_C108
        bcs     L6_9546
        jsr     L6_BF61
        lda     $0638,X
        and     #$01
        beq     L6_9546
        lda     #$04
        sta     $07B8,Y
        sta     $0728,Y
        lda     #$03
        sta     $0560,Y
        lda     #$1A
        sta     $0548,Y
        lda     #$00
        sta     $07A0,Y
L6_9546:
        jmp     L6_95BD
L6_9549:
        ldy     $0638,X
        lda     $15
        cmp     #$49
        bne     L6_955A
        cpy     #$0E
        bne     L6_955A
        ldy     #$00
        beq     L6_9566
L6_955A:
        lda     $14
        cmp     #$46
        bne     L6_95BD
        cpy     #$18
        bne     L6_95BD
        ldy     #$04
L6_9566:
        sty     $17
        jsr     L7_C0FF
        sta     $16
        lda     #$02
        sta     $14
        ldy     #$4E
        jsr     L6_AD9A
        beq     L6_9581
        lda     $0500,X
        cmp     #$C8
        beq     L6_9581
        ldy     #$27
L6_9581:
        sty     $15
L6_9583:
        ldy     $17
        lda     $95C3,Y
        sta     $19
        iny
        lda     $95C3,Y
        sta     $18
        iny
        sty     $17
        jsr     L7_C108
        bcs     L6_95BD
        lda     $15
        sta     $0500,Y
        lda     $0530,X
        clc
        adc     $19
        sta     $0530,Y
        lda     $0518,X
        clc
        adc     $18
        sta     $0518,Y
        lda     $16
        sta     $0788,Y
        lda     #$04
        sta     $07A0,Y
        dec     $14
        bne     L6_9583
L6_95BD:
        jsr     L7_C0C6
        jmp     L7_C0D8

; ---- UNCLAIMED (gap) $95C3-$95CF, 13 bytes
        .byte   $F0,$F4,$10,$F4,$F4,$14,$0C,$14,$42,$43,$42,$30,$40

; ---- bank6.code_95D0 (code) $95D0-$9607, 56 bytes
L6_95D0:
        lda     #$18
        jsr     L7_C09C
        lda     #$10
        jsr     L7_C09F
        jmp     L7_C08D
L6_95DD:
        lda     $0500,X
        bmi     L6_95F8
        jsr     L7_C0A8
        lda     #$00
        sta     $0560,X
        lda     #$41
        sta     $0698,X
        lda     $0788,X
        jsr     L7_C102
        jsr     L7_C0A2
L6_95F8:
        lda     #$60
        ldy     #$08
        jsr     L7_C0A5
        jsr     L6_A1CB
        jmp     L6_9F4F
L6_9605:
        jsr     L7_C006

; ---- bank6.inline_9608 (data) $9608-$960A, 3 bytes
; Far-call argument at $9608
        .byte   $01,$0B,$80

; ---- bank6.code_960B (code) $960B-$96C3, 185 bytes
        rts
L6_960C:
        lda     $0500,X
        bmi     L6_9631
        lda     #$03
        sta     $0698,X
        jsr     L6_963A
        jsr     L7_C0FC
L6_961C:
        lda     #$25
        sta     $0548,X
        lda     #$00
        sta     $0560,X
        lda     #$8A
        sta     $06C8,X
        jsr     L7_C0AE
        jsr     L7_C162
L6_9631:
        jsr     L6_9646
        jsr     L7_C0BD
        jmp     L7_C0D5
L6_963A:
        lda     $4B
        cmp     #$04
        bcc     L6_9645
        lda     #$05
        sta     $0698,X
L6_9645:
        rts
L6_9646:
        jsr     L6_9B53
        lda     $0500,X
        bmi     L6_9651
        pla
        pla
        rts
L6_9651:
        jsr     L6_8435
        lda     $6C
        tay
        lda     $8513,Y
        beq     L6_9666
        lda     #$00
        sta     $0740,X
        lda     #$08
        sta     $0500,X
L6_9666:
        rts
L6_9667:
        lda     $0500,X
        bmi     L6_9631
        lda     #$03
        sta     $0698,X
        jsr     L6_963A
        lda     $0788,X
        jsr     L7_C102
        jmp     L6_961C
L6_967D:
        lda     $0500,X
        bmi     L6_969E
        jsr     L7_C0AE
        jsr     L7_C162
        lda     #$04
        sta     $0698,X
        jsr     L6_963A
        lda     $0788,X
        jsr     L7_C102
        lda     #$40
        jsr     L7_C030
        jsr     L7_C0A2
L6_969E:
        lda     #$40
        jsr     L6_96AC
        jsr     L6_9646
        jsr     L7_C0C6
        jmp     L7_C0D5
L6_96AC:
        ldy     #$04
        jsr     L7_C0A5
        lda     $96C4,Y
        sta     $0548,X
        lda     $96C8,Y
        sta     $0560,X
        lda     $96CC,Y
        sta     $06C8,X
        rts

; ---- UNCLAIMED (gap) $96C4-$96CF, 12 bytes
        .byte   $1A,$79,$37,$79,$00,$01,$02,$43,$F8,$FA,$FC,$FA

; ---- bank6.code_96D0 (code) $96D0-$97AD, 222 bytes
L6_96D0:
        lda     $0500,X
        bmi     L6_972A
        lda     $0728,X
        beq     L6_96FE
        lda     $07B8,X
        jsr     L7_C0AB
        lda     $07A0,X
        jsr     L6_A1E7
        asl     $05A8,X
        asl     $0590,X
        lda     $51
        cmp     #$16
        bne     L6_96F7
        lda     #$FF
        sta     $0590,X
L6_96F7:
        lda     #$00
        sta     $0578,X
        beq     L6_9713
L6_96FE:
        jsr     L7_C0AE
        lda     #$25
        sta     $0548,X
        lda     #$00
        sta     $0560,X
        sta     $07B8,X
        lda     #$8A
        sta     $06C8,X
L6_9713:
        jsr     L7_C162
        lda     #$FE
        sta     $05D8,X
        sta     $0668,X
        lda     $0788,X
        sta     $0608,X
        jsr     L7_C0EA
        sta     $05F0,X
L6_972A:
        lda     #$14
        jsr     L7_C09C
L6_972F:
        lda     $0578,X
        and     #$04
        beq     L6_9739
        jmp     L6_9631
L6_9739:
        jsr     L7_C08D
        jsr     L7_C0C6
        jmp     L7_C0D5
L6_9742:
        lda     $0500,X
        bmi     L6_972F
        lda     $07B8,X
        jsr     L7_C0AB
        jsr     L7_C162
        lda     $07A0,X
        jsr     L6_A1E7
        lda     $0788,X
        jsr     L7_C102
        jmp     L6_972F
L6_975F:
        lda     $0500,X
        bmi     L6_97B1
        ldy     #$24
        cmp     #$07
        beq     L6_977A
        dey
        cmp     #$30
        beq     L6_977A
        dey
        lda     $0740,X
        bne     L6_977A
        sta     $0578,X
        beq     L6_977E
L6_977A:
        tya
        jsr     L7_C030
L6_977E:
        jsr     L7_C0A2
L6_9781:
        jsr     L7_C02A
        lda     $0578,X
        and     #$10
        pha
        jsr     L7_C0AE
        pla
        ora     $0578,X
        sta     $0578,X
        lda     #$00
        sta     $0560,X
        sta     $06C8,X
        sta     $0788,X
        lda     $0500,X
        cmp     #$88
        bne     L6_97B1
        ldy     $0740,X
        beq     L6_97B1
        jsr     L7_C006

; ---- bank6.inline_97AE (data) $97AE-$97B0, 3 bytes
; Far-call argument at $97AE
        .byte   $01,$08,$80

; ---- bank6.code_97B1 (code) $97B1-$98CA, 282 bytes
L6_97B1:
        lda     $0500,X
        cmp     #$87
        beq     L6_97D4
        lda     $0788,X
        beq     L6_97C0
        jmp     L6_9842
L6_97C0:
        lda     $0578,X
        and     #$10
        beq     L6_982D
L6_97C7:
        lda     #$80
        ldy     #$10
        jsr     L7_C0A5
        bcs     L6_9836
        lda     #$15
        bne     L6_97DF
L6_97D4:
        lda     #$60
        ldy     #$10
        jsr     L7_C0A5
        bcs     L6_9836
        lda     #$0F
L6_97DF:
        sty     $14
        sta     $15
L6_97E3:
        ldy     $15
        lda     $14
        sec
        sbc     $98CB,Y
        bcc     L6_9822
        cmp     #$08
        bcs     L6_9822
        tay
        lda     $990D,Y
        sta     $16
        ldy     $15
        lda     $0530,X
        sta     $17
        lda     $98E1,Y
        jsr     L6_991F
        bcs     L6_9822
        sta     $85
        lda     $0518,X
        sta     $17
        lda     $98F7,Y
        jsr     L6_991F
        bcs     L6_9822
        sta     $84
        lda     #$00
        sta     $86
        sta     $87
        lda     $16
        jsr     L7_C093
L6_9822:
        dec     $15
        lda     $15
        and     #$0F
        cmp     #$0F
        bne     L6_97E3
        rts
L6_982D:
        lda     #$40
        ldy     #$06
L6_9831:
        jsr     L7_C0A5
        bcc     L6_9839
L6_9836:
        jmp     L7_C048
L6_9839:
        lda     $9919,Y
        sta     $0548,X
        jmp     L7_C090
L6_9842:
        lda     #$40
        ldy     #$20
        jsr     L7_C0A5
        bit     $30
        bvs     L6_9863
L6_984D:
        bcs     L6_9892
        tya
        jsr     L6_9856
        jmp     L7_C090
L6_9856:
        and     #$03
        sta     $0560,X
        tay
        lda     $9915,Y
        sta     $0548,X
        rts
L6_9863:
        lda     $B8
        ora     $B9
        beq     L6_984D
        lda     #$11
        sta     $0620,X
        lda     #$03
        jsr     L7_C09C
        lda     $0638,X
        jsr     L6_9856
        jsr     L7_C08D
        lda     $0530,X
        sta     $07D0,X
        lda     $0518,X
        sta     $07B8,X
        cmp     #$10
        bcc     L6_9892
        lda     $05D8,X
        bpl     L6_9892
        rts
L6_9892:
        lda     #$32
        sta     $0500,X
        lda     $A6
        and     #$0F
        sta     $10
        lda     $07B8,X
        and     #$F0
        ora     #$08
        sec
        sbc     $10
        bcs     L6_98AB
        lda     #$08
L6_98AB:
        sta     $0518,X
        sta     $18
        lda     $07D0,X
        and     #$F0
        ora     #$08
        sta     $0530,X
        sta     $19
        lda     #$00
        sta     $17
        lda     #$04
        sta     $15
        lda     #$18
        sta     $16
        jmp     L7_C11A

; ---- UNCLAIMED (gap) $98CB-$991E, 84 bytes
        .byte   $00,$00,$01,$01,$01,$01,$02,$02,$02,$03,$03,$03,$03,$03,$04,$04
        .byte   $00,$01,$01,$02,$03,$04,$FC,$08,$F8,$F6,$06,$04,$0C,$FB,$0A,$F4
        .byte   $F5,$EA,$18,$07,$F3,$14,$00,$08,$F7,$05,$FC,$F6,$FA,$E8,$10,$F0
        .byte   $02,$19,$F8,$EC,$0C,$06,$E4,$F6,$E6,$F2,$16,$0B,$00,$F7,$08,$0C
        .byte   $F4,$06,$30,$30,$31,$31,$32,$32,$33,$33,$30,$31,$32,$31,$30,$30
        .byte   $31,$31,$32,$33

; ---- bank6.code_991F (code) $991F-$99C8, 170 bytes
L6_991F:
        clc
        bmi     L6_9925
        adc     $17
        rts
L6_9925:
        adc     $17
        rol     A
        eor     #$01
        ror     A
        rts
L6_992C:
        lda     $0500,X
        bmi     L6_994F
        lda     $0740,X
        bne     L6_993B
        sta     $0578,X
        beq     L6_9940
L6_993B:
        lda     #$23
        jsr     L7_C030
L6_9940:
        jsr     L7_C0A2
        lda     $0518,X
        clc
        adc     $B7
        sta     $0518,X
        jmp     L6_9781
L6_994F:
        lda     $0518,X
        clc
        adc     $B7
        sta     $0518,X
        lda     $0578,X
        and     #$10
        beq     L6_9962
        jmp     L6_97C7
L6_9962:
        lda     #$80
        ldy     #$06
        jmp     L6_9831
L6_9969:
        dec     $0578,X
        beq     L6_996F
        rts
L6_996F:
        jmp     L7_C048
L6_9972:
        lda     $0500,X
        bmi     L6_9988
        lda     $0578,X
        sta     $0788,X
        jsr     L7_C0AE
        jsr     L7_C0A2
        lda     #$02
        sta     $0560,X
L6_9988:
        lda     #$60
        ldy     #$10
        jsr     L7_C0A5
        bcs     L6_996F
        lda     $99C9,Y
        sta     $0548,X
        lda     $99D9,Y
        sta     $06C8,X
        jsr     L7_C090
        lda     $0788,X
        and     #$10
        beq     L6_99C8
        ldy     #$03
L6_99A9:
        tya
        pha
        lda     $99E9,Y
        clc
        adc     $0530,X
        sta     $85
        lda     $99ED,Y
        clc
        adc     $0518,X
        sta     $84
        lda     $0548,X
        jsr     L7_C093
        pla
        tay
        dey
        bpl     L6_99A9
L6_99C8:
        rts

; ---- UNCLAIMED (gap) $99C9-$99F0, 40 bytes
        .byte   $79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$37,$37,$37,$37
        .byte   $01,$03,$01,$03,$01,$03,$01,$03,$01,$03,$05,$07,$09,$0B,$0D,$0F
        .byte   $F6,$0A,$F6,$0A,$F6,$F6,$0A,$0A

; ---- bank6.code_99F1 (code) $99F1-$99F3, 3 bytes
L6_99F1:
        jsr     L7_C006

; ---- bank6.inline_99F4 (data) $99F4-$99F6, 3 bytes
; Far-call argument at $99F4
        .byte   $02,$0E,$80

; ---- bank6.code_99F7 (code) $99F7-$9A0D, 23 bytes
        rts
L6_99F8:
        lda     $0500,X
        bmi     L6_9A0B
        jsr     L7_C0AE
        lda     $0788,X
        sta     $0620,X
        lda     #$00
        sta     $0788,X
L6_9A0B:
        jsr     L7_C006

; ---- bank6.inline_9A0E (data) $9A0E-$9A10, 3 bytes
; Far-call argument at $9A0E
        .byte   $02,$08,$80

; ---- bank6.code_9A11 (code) $9A11-$9A14, 4 bytes
        rts
L6_9A12:
        jsr     L7_C006

; ---- bank6.inline_9A15 (data) $9A15-$9A17, 3 bytes
; Far-call argument at $9A15
        .byte   $05,$11,$80

; ---- bank6.code_9A18 (code) $9A18-$9ADA, 195 bytes
        rts
L6_9A19:
        lda     $0500,X
        bmi     L6_9A2E
        jsr     L7_C0AE
        lda     #$01
        sta     $0698,X
        jsr     L7_C0F0
        lda     #$00
        sta     $0518,X
L6_9A2E:
        lda     $60
        and     #$08
        bne     L6_9A52
        dec     $0698,X
        bne     L6_9A52
        lda     $07A0,X
        sta     $0698,X
        jsr     L7_C108
        bcs     L6_9A52
        lda     $0548,X
        jsr     L7_C105
        dec     $0560,X
        bne     L6_9A52
        jmp     L7_C048
L6_9A52:
        rts
L6_9A53:
        jsr     L6_8435
        ldy     $6C
        lda     $8425,Y
        rts
L6_9A5C:
        lda     $0500,X
        bmi     L6_9AA7
        lda     $0728,X
        bne     L6_9A71
        jsr     L7_C0F3
        jsr     L6_9A53
        beq     L6_9A71
        jmp     L6_9B17
L6_9A71:
        jsr     L7_C0A8
        lda     #$01
        sta     $0680,X
        jsr     L7_C0A2
        lda     #$3C
        sta     $0548,X
        jsr     L6_9B0F
        lda     $9ADB,Y
        sta     $0560,X
        lda     $9AE1,Y
        sta     $0698,X
        lda     $9AE7,Y
        sta     $0668,X
        lda     $9AED,Y
        sta     $05A8,X
        lda     $9AF3,Y
        sta     $0590,X
        lda     #$28
        sta     $0788,X
L6_9AA7:
        jsr     L7_C009
        lda     #$40
        jsr     L6_9AF9
        dec     $0680,X
        bne     L6_9AC6
        jsr     L7_C0EA
        tay
        and     #$3F
        adc     $0668,X
        sta     $0680,X
        tya
        and     #$0F
        jsr     L7_C102
L6_9AC6:
        jsr     L6_9B2A
        ldy     $6C
        lda     $8425,Y
        beq     L6_9AD5
        lda     #$01
        sta     $0680,X
L6_9AD5:
        jsr     L7_C0C6
        jmp     L7_C0D2

; ---- UNCLAIMED (gap) $9ADB-$9AF8, 30 bytes
        .byte   $00,$00,$00,$01,$02,$03,$01,$02,$02,$02,$03,$41,$40,$30,$20,$20
        .byte   $10,$08,$04,$08,$10,$20,$30,$50,$01,$02,$06,$0C,$18,$30

; ---- bank6.code_9AF9 (code) $9AF9-$9C0C, 276 bytes
L6_9AF9:
        ldy     #$01
        jsr     L7_C0A5
        bcc     L6_9B08
L6_9B00:
        lda     $0560,X
        eor     #$40
        sta     $0560,X
L6_9B08:
        rts
L6_9B09:
        and     $41
        beq     L6_9B00
        bne     L6_9B08
L6_9B0F:
        lda     $50
        clc
        adc     #$01
        lsr     A
        tay
        rts
L6_9B17:
        lda     $0620,X
        pha
        jsr     L7_C048
        pla
        and     #$10
        bne     L6_9B29
        lda     $0740,X
        sta     $0500,X
L6_9B29:
        rts
L6_9B2A:
        bit     $30
        bvs     L6_9B34
        jsr     L6_826D
        jmp     L7_C090
L6_9B34:
        lda     #$00
        sta     $6C
        lda     $0620,X
        and     #$10
        bne     L6_9B48
        jsr     L7_C08D
        bcc     L6_9B52
        pla
        pla
        bcs     L6_9B17
L6_9B48:
        jsr     L6_9B53
        lda     $0500,X
        bmi     L6_9B52
        pla
        pla
L6_9B52:
        rts
L6_9B53:
        jsr     L7_C08D
        rts
L6_9B57:
        lda     $0500,X
        bmi     L6_9BA9
        lda     $0728,X
        bne     L6_9B6C
        jsr     L7_C0F3
        jsr     L6_9A53
        beq     L6_9B6C
        jmp     L6_9B17
L6_9B6C:
        jsr     L7_C0A8
        lda     #$03
        sta     $0698,X
        lda     #$37
        sta     $0548,X
        jsr     L6_9B0F
        lda     $9C0D,Y
        sta     $0560,X
        lda     $9C13,Y
        sta     $07A0,X
        lda     $9AED,Y
        lsr     A
        ora     #$01
        sta     $05A8,X
        lda     $9AF3,Y
        sta     $0590,X
L6_9B97:
        lda     #$28
        sta     $0788,X
        lda     #$01
        sta     $0668,X
        jsr     L7_C0A2
        lda     #$00
        sta     $0680,X
L6_9BA9:
        jsr     L7_C009
        dec     $0668,X
        bne     L6_9BDF
        inc     $0680,X
        lda     $0680,X
        and     #$03
        sta     $0680,X
        tay
        bne     L6_9BC4
        lda     $07A0,X
        bne     L6_9BC7
L6_9BC4:
        lda     $9C19,Y
L6_9BC7:
        sta     $0668,X
        cpy     #$02
        bne     L6_9BDF
        jsr     L7_C0FF
        sta     $15
        jsr     L7_C0EA
        and     #$03
        adc     $15
        and     #$0C
        jsr     L7_C102
L6_9BDF:
        lda     $0680,X
        beq     L6_9BF7
        lda     $0500,X
        cmp     #$F4
        beq     L6_9BF7
        lda     #$60
        ldy     #$02
        jsr     L7_C0A5
        tya
        asl     A
        jsr     L6_A1E7
L6_9BF7:
        lda     $0680,X
        cmp     #$02
        beq     L6_9C04
        jsr     L7_C090
        jmp     L6_9C07
L6_9C04:
        jsr     L6_9B2A
L6_9C07:
        jsr     L7_C0C6
        jmp     L7_C0D2

; ---- UNCLAIMED (gap) $9C0D-$9C1C, 16 bytes
        .byte   $02,$01,$01,$02,$03,$00,$50,$3C,$28,$14,$0A,$01,$50,$28,$14,$14

; ---- bank6.code_9C1D (code) $9C1D-$9CED, 209 bytes
L6_9C1D:
        ldy     $0500,X
        bmi     L6_9C67
        lda     $9CDE,Y
        sta     $0560,X
        lda     $9CF2,Y
        sta     $07D0,X
        jsr     L7_C0A8
        jsr     L7_C162
        lda     $0728,X
        bne     L6_9C3C
        jsr     L7_C0F3
L6_9C3C:
        lda     #$19
        sta     $0548,X
        lda     #$01
        sta     $0698,X
        lda     #$FF
        sta     $0668,X
        lda     #$28
        sta     $0788,X
        lda     $07E8,X
        clc
        adc     #$08
        sta     $06C8,X
        lda     $0518,X
        sta     $07A0,X
        jsr     L7_C0A2
        lda     #$00
        sta     $07B8,X
L6_9C67:
        jsr     L7_C009
        lda     $05D8,X
        bmi     L6_9CC7
        lda     $07E8,X
        clc
        adc     #$04
        sta     $06C8,X
        lda     $0518,X
        cmp     $07A0,X
        bcc     L6_9CC7
        inc     $07B8,X
        lda     $07B8,X
        and     $07D0,X
        beq     L6_9C8F
        lda     #$04
        bne     L6_9C92
L6_9C8F:
        jsr     L7_C0FF
L6_9C92:
        pha
        jsr     L7_C102
        jsr     L7_C0EA
        and     #$1F
        sta     $15
        lda     $05C0,X
        sbc     $15
        sta     $05C0,X
        lda     $05D8,X
        sec
        sbc     #$03
        sta     $05D8,X
        pla
        tay
        lda     $07B8,X
        and     $07D0,X
        beq     L6_9CBA
        ldy     #$00
L6_9CBA:
        lda     $0518,X
        clc
        adc     $9CF2,Y
        sta     $07A0,X
        jsr     L7_C0A2
L6_9CC7:
        lda     #$20
        jsr     L7_C09C
        lda     $0638,X
        cmp     #$03
        bcs     L6_9CE0
        lda     #$40
        ldy     #$04
        jsr     L7_C0A5
        lda     $9D06,Y
        jsr     L6_A1E7
L6_9CE0:
        jsr     L7_C08D
        bcc     L6_9CE8
        jmp     L6_9B17
L6_9CE8:
        jsr     L7_C0C6
        jmp     L7_C0D2

; ---- UNCLAIMED (gap) $9CEE-$9D09, 28 bytes
        .byte   $01,$02,$00,$03,$00,$04,$08,$0C,$10,$0C,$08,$04,$00,$FC,$F8,$F4
        .byte   $F0,$F4,$F8,$FC,$03,$01,$00,$05,$08,$08,$04,$00

; ---- bank6.code_9D0A (code) $9D0A-$9DF1, 232 bytes
L6_9D0A:
        ldy     $0500,X
        bmi     L6_9D46
        lda     $9DD7,Y
        sta     $0560,X
        lda     $9DDA,Y
        sta     $0698,X
        jsr     L7_C0A8
        jsr     L7_C165
        lda     #$1F
        sta     $0548,X
L6_9D26:
        jsr     L7_C0A2
        jsr     L7_C0F3
        jsr     L6_9A53
        beq     L6_9D34
        jmp     L6_9B17
L6_9D34:
        lda     #$3C
        sta     $0788,X
        jsr     L7_C0A2
        lda     #$1E
        sta     $07A0,X
        lda     #$04
        sta     $0668,X
L6_9D46:
        jsr     L7_C009
        dec     $07A0,X
        bne     L6_9D95
        lda     $0500,X
        cmp     #$9E
        bcc     L6_9D5F
        jsr     L7_C108
        bcs     L6_9D5F
        lda     #$0B
        jsr     L7_C105
L6_9D5F:
        jsr     L7_C0EA
        and     #$1F
        adc     #$18
        sta     $07A0,X
        lda     $0500,X
        cmp     #$9F
        bcc     L6_9D73
        lsr     $07A0,X
L6_9D73:
        jsr     L7_C0FF
        clc
        adc     #$02
        and     #$0C
        sta     $15
        adc     #$08
        and     #$0C
        cmp     $0668,X
        bne     L6_9D8D
        adc     $15
        lsr     A
        and     #$0C
        sta     $15
L6_9D8D:
        lda     $15
        sta     $0668,X
        jsr     L7_C102
L6_9D95:
        lda     $0500,X
        cmp     #$F3
        bne     L6_9DA4
        lda     #$03
        jsr     L6_9B09
        jmp     L6_9DB1
L6_9DA4:
        lda     #$20
        ldy     #$02
        jsr     L7_C0A5
        lda     $9DF2,Y
        sta     $0548,X
L6_9DB1:
        jsr     L6_826D
        ldy     $6C
        lda     $8425,Y
        beq     L6_9DE9
        lda     $07A0,X
        cmp     #$04
        bcs     L6_9DE9
        jsr     L7_C0EA
        and     #$3F
        adc     #$08
        sta     $07A0,X
        and     #$08
        sta     $15
        lda     $0668,X
        adc     $15
        sbc     #$03
        and     #$0C
        sta     $0668,X
        jsr     L7_C102
        lda     $0500,X
        cmp     #$9F
        bne     L6_9DE9
        lsr     $07A0,X
L6_9DE9:
        jsr     L7_C090
        jsr     L7_C0C6
        jmp     L7_C0D8

; ---- UNCLAIMED (gap) $9DF2-$9DF9, 8 bytes
        .byte   $1F,$20,$03,$02,$00,$01,$02,$03

; ---- bank6.code_9DFA (code) $9DFA-$9E81, 136 bytes
L6_9DFA:
        lda     $0500,X
        bmi     L6_9E5C
        jsr     L7_C0A8
        jsr     L7_C162
        jsr     L7_C0F0
        lda     #$01
        sta     $0560,X
        lda     #$03
        sta     $05D8,X
        lda     #$00
        sta     $0668,X
        lda     #$19
        sta     $0548,X
        lda     $0530,X
        ldy     #$01
        cmp     $0530
        bcc     L6_9E28
        ldy     #$FF
L6_9E28:
        tya
        sta     $0608,X
        jsr     L7_C0A2
        lda     $0500,X
        cmp     #$9C
        beq     L6_9E48
        lda     $50
        cmp     #$09
        bcc     L6_9E5C
        lda     #$00
        sta     $0560,X
        lda     #$FF
        sta     $0590,X
        bne     L6_9E5C
L6_9E48:
        lda     #$04
        sta     $05D8,X
        lda     #$37
        sta     $0548,X
        lda     #$03
        sta     $0560,X
        lda     #$02
        sta     $0788,X
L6_9E5C:
        lda     $0500,X
        cmp     #$9C
        bne     L6_9E66
        jmp     L6_9E8A
L6_9E66:
        lda     #$40
        ldy     #$04
        jsr     L7_C0A5
        lda     $9E82,Y
        sta     $15
        lda     $9E86,Y
        sta     $14
        jsr     L6_A1DB
        lda     #$07
        jsr     L7_C09C
        jmp     L6_9F4F

; ---- UNCLAIMED (gap) $9E82-$9E89, 8 bytes
        .byte   $00,$04,$08,$04,$00,$00,$00,$80

; ---- bank6.code_9E8A (code) $9E8A-$9EDE, 85 bytes
L6_9E8A:
        lda     $0530,X
        sta     $0680,X
        lda     #$08
        jsr     L7_C09F
        jmp     L6_9F03
L6_9E98:
        lda     $0500,X
        bmi     L6_9F03
        jsr     L7_C0A8
        lda     #$37
        sta     $0548,X
        lda     $0728,X
        bne     L6_9EF1
        lda     #$74
        sta     $0530,X
        lda     #$20
        sta     $0518,X
        lda     #$81
        sta     $0560,X
        lda     #$00
        sta     $0788,X
        lda     #$81
        sta     $0698,X
        ldy     $4B
        lda     $9EDE,Y
        sta     $07B8,X
        sta     $07A0,X
        lda     $9EE5,Y
        sta     $07D0,X
        lda     #$00
        sta     $0680,X
        jsr     L7_C102
        jmp     L6_9F03

; ---- UNCLAIMED (gap) $9EDF-$9EF0, 18 bytes
        .byte   $04,$05,$06,$07,$08,$08,$08,$00,$03,$01,$01,$03,$01,$00,$03,$04
        .byte   $05,$06

; ---- bank6.code_9EF1 (code) $9EF1-$9FB3, 195 bytes
L6_9EF1:
        lda     #$02
        sta     $0560,X
        ldy     $4A
        lda     $9EEC,Y
        sta     $0698,X
        lda     #$01
        sta     $0788,X
L6_9F03:
        lda     #$30
        ldy     #$04
        jsr     L7_C0A5
        lda     $9FB4,Y
        jsr     L6_A1E7
        lda     $0788,X
        beq     L6_9F58
        cmp     #$02
        beq     L6_9F4F
        lda     $0668,X
        tay
        lda     $0500,Y
        cmp     #$9B
        bne     L6_9F3C
        lda     $0788,Y
        bne     L6_9F3C
        lda     $0680,X
        and     #$F0
        sta     $10
        lda     $0680,Y
        and     #$F0
        cmp     $10
        bne     L6_9F3C
        jmp     L7_C090
L6_9F3C:
        jsr     L7_C0FC
        lda     #$01
        sta     $0590,X
        jsr     L7_C162
        lda     #$00
        sta     $0560,X
        inc     $0788,X
L6_9F4F:
        jsr     L7_C08D
        jsr     L7_C0C6
        jmp     L7_C0D2
L6_9F58:
        dec     $07A0,X
        beq     L6_9F66
        jsr     L7_C08D
        jsr     L7_C0CF
        jmp     L7_C0D2
L6_9F66:
        lda     $07B8,X
        sta     $07A0,X
        inc     $0680,X
        lda     $0680,X
        and     #$0F
        bne     L6_9F80
        ldy     $51
        cpy     #$15
        beq     L6_9F80
        txa
        tay
        bpl     L6_9F93
L6_9F80:
        jsr     L7_C102
        jsr     L7_C08D
        lda     $0680,X
        and     $07D0,X
        bne     L6_9FB3
        jsr     L7_C108
        bcs     L6_9FB3
L6_9F93:
        lda     #$1B
        sta     $0500,Y
        lda     $0530,X
        sta     $0530,Y
        lda     $0518,X
        sta     $0518,Y
        lda     #$FF
        sta     $0728,Y
        lda     $0680,X
        sta     $0680,Y
        txa
        sta     $0668,Y
L6_9FB3:
        rts

; ---- UNCLAIMED (gap) $9FB4-$9FB7, 4 bytes
        .byte   $00,$02,$04,$06

; ---- bank6.code_9FB8 (code) $9FB8-$9FEE, 55 bytes
L6_9FB8:
        lda     $0500,X
        bmi     L6_9FD5
        jsr     L7_C0A8
        jsr     L7_C0A2
        jsr     L7_C0F0
        lda     $0530,X
        and     #$3F
        adc     #$28
        sta     $05C0,X
        lda     #$02
        sta     $0560,X
L6_9FD5:
        lda     #$30
        ldy     #$04
        jsr     L7_C0A5
        lda     $9FF3,Y
        sta     $15
        lda     $9FF7,Y
        sta     $14
        lda     $9FEF,Y
        jsr     L6_A1D8
        jmp     L6_9F4F

; ---- UNCLAIMED (gap) $9FEF-$9FFA, 12 bytes
        .byte   $19,$79,$19,$79,$00,$04,$00,$06,$00,$00,$40,$00

; ---- bank6.code_9FFB (code) $9FFB-$A091, 151 bytes
L6_9FFB:
        lda     $0500,X
        bmi     L6_A019
        jsr     L7_C0A8
        jsr     L7_C162
        jsr     L7_C0A2
        jsr     L7_C0F0
        lda     #$41
        sta     $0698,X
        jsr     L7_C0FC
        lda     #$00
        sta     $0560,X
L6_A019:
        jsr     L6_A01F
        jmp     L6_9F4F
L6_A01F:
        lda     #$20
        ldy     #$04
        jsr     L7_C0A5
        lda     $A09E,Y
        sta     $15
        lda     $A0A2,Y
        sta     $14
        lda     $A09A,Y
        jmp     L6_A1D8
L6_A036:
        lda     $0500,X
        bmi     L6_A06E
        jsr     L7_C0A8
        jsr     L7_C162
        jsr     L7_C0A2
        lda     #$40
        sta     $0668,X
        ldy     #$00
        jsr     L6_AD9A
        beq     L6_A052
        ldy     #$04
L6_A052:
        lda     $A092,Y
        sta     $0530,X
        lda     $A093,Y
        sta     $0608,X
        lda     $A094,Y
        sta     $0680,X
        lda     #$02
        sta     $0560,X
        lda     #$14
        sta     $07A0,X
L6_A06E:
        lda     #$08
        jsr     L7_C09C
        lda     #$0E
        jsr     L7_C09F
        jsr     L6_A01F
        dec     $07A0,X
        bne     L6_A08F
        lda     #$1E
        sta     $07A0,X
        jsr     L7_C108
        bcs     L6_A08F
        lda     #$0B
        jsr     L7_C105
L6_A08F:
        jmp     L6_9F4F

; ---- UNCLAIMED (gap) $A092-$A0A5, 20 bytes
        .byte   $60,$FD,$FF,$00,$A0,$03,$00,$00,$19,$37,$19,$1A,$00,$04,$00,$06
        .byte   $00,$00,$40,$00

; ---- bank6.code_A0A6 (code) $A0A6-$A1EE, 329 bytes
L6_A0A6:
        lda     $0500,X
        bmi     L6_A0B8
        ora     #$80
        sta     $0500,X
        lda     #$4E
        sta     $0578,X
        jsr     L7_C141
L6_A0B8:
        jsr     L7_C129
        bcc     L6_A0C0
        jmp     L7_C048
L6_A0C0:
        jsr     L7_C0C0
        jmp     L7_C0D5
L6_A0C6:
        lda     $0500,X
        bmi     L6_A113
        ldy     $07A0,X
        lda     $A21F,Y
        sta     $07B8,X
        jsr     L7_C0AB
        ldy     $07A0,X
        lda     $A1EF,Y
        sta     $0560,X
        lda     $A1F7,Y
        sta     $0698,X
        lda     $A1FF,Y
        sta     $06B0,X
        lda     $A207,Y
        sta     $07D0,X
        lda     $A227,Y
        sta     $0668,X
        lda     $A22F,Y
        sta     $0680,X
        lda     $A20F,Y
        sta     $0590,X
        lda     $A217,Y
        sta     $05A8,X
        jsr     L7_C0A2
        lda     $0788,X
        jmp     L6_A133
L6_A113:
        dec     $07A0,X
        bne     L6_A174
        jsr     L7_C0FF
        sec
        sbc     $0788,X
        beq     L6_A13B
        and     #$0F
        cmp     #$08
        lda     $0788,X
        bcc     L6_A130
        sbc     $0668,X
        jmp     L6_A133
L6_A130:
        adc     $0668,X
L6_A133:
        and     #$0F
        sta     $0788,X
        jsr     L7_C102
L6_A13B:
        lda     $06B0,X
        sta     $07A0,X
        lda     $0680,X
        and     #$7F
        bne     L6_A185
        lda     $0788,X
        and     #$07
        tay
        lda     $A237,Y
        sta     $15
        lda     $0788,X
        lsr     A
        lsr     A
        tay
        lda     $A23F,Y
        sta     $14
L6_A15E:
        lda     $0788,X
        and     #$07
        ldy     #$19
        cmp     #$04
        bne     L6_A170
        lda     $0680,X
        bpl     L6_A170
        ldy     #$37
L6_A170:
        tya
L6_A171:
        jsr     L6_A1D8
L6_A174:
        lda     $0680,X
        cmp     #$03
        bne     L6_A182
        lda     $41
        and     #$04
        jsr     L6_A1E7
L6_A182:
        jmp     L6_9F4F
L6_A185:
        cmp     #$01
        bne     L6_A1A7
        lda     $0788,X
        and     #$0E
        sta     $0788,X
        and     #$07
        lsr     A
        tay
        lda     $A243,Y
        sta     $15
        lda     $0788,X
        lsr     A
        tay
        lda     $A247,Y
        sta     $14
        jmp     L6_A15E
L6_A1A7:
        cmp     #$02
        bne     L6_A1B6
        lda     $0788,X
        lsr     A
        tay
        jsr     L6_A1CB
        jmp     L6_A174
L6_A1B6:
        lda     $0788,X
        lsr     A
        lsr     A
        tay
        lda     $A267,Y
        sta     $14
        lda     $06C8,X
        sta     $15
        lda     #$19
        jmp     L6_A171
L6_A1CB:
        lda     $A24F,Y
        sta     $15
        lda     $A257,Y
        sta     $14
        lda     $A25F,Y
L6_A1D8:
        sta     $0548,X
L6_A1DB:
        lda     $0560,X
        and     #$03
        ora     $14
        sta     $0560,X
        lda     $15
L6_A1E7:
        clc
        adc     $07E8,X
        sta     $06C8,X
        rts

; ---- UNCLAIMED (gap) $A1EF-$A26A, 124 bytes
        .byte   $01,$01,$03,$02,$02,$02,$03,$01,$03,$41,$06,$05,$03,$81,$06,$41
        .byte   $10,$0A,$08,$08,$10,$05,$09,$10,$03,$05,$08,$07,$08,$06,$06,$06
        .byte   $01,$02,$18,$0C,$10,$01,$01,$01,$04,$08,$30,$40,$18,$04,$04,$06
        .byte   $39,$35,$36,$02,$04,$35,$39,$2F,$01,$01,$01,$02,$02,$01,$01,$04
        .byte   $80,$80,$00,$81,$02,$80,$80,$03,$00,$04,$08,$0C,$10,$0C,$08,$04
        .byte   $80,$C0,$40,$00,$00,$06,$04,$06,$40,$40,$00,$00,$80,$80,$C0,$C0
        .byte   $00,$02,$00,$02,$00,$04,$04,$04,$40,$40,$00,$00,$00,$00,$00,$00
        .byte   $4B,$19,$1A,$19,$4B,$7B,$7B,$7B,$C0,$80,$00,$40

; ---- bank6.code_A26B (code) $A26B-$A2C3, 89 bytes
L6_A26B:
        jmp     L7_C090
L6_A26E:
        ldy     $0500,X
        bmi     L6_A294
        lda     $A2B0,Y
        ldy     #$1A
        jsr     L6_A302
        jsr     L7_C0A8
        jsr     L7_C0F3
        jsr     L7_C0A2
        ldy     $0500,X
        cpy     #$94
        bne     L6_A291
        jsr     L6_A2D0
        jmp     L6_A294
L6_A291:
        jsr     L6_A2E8
L6_A294:
        jsr     L7_C009
        lda     #$10
        ldy     $0500,X
        cpy     #$94
        bne     L6_A2A6
        jsr     L7_C09F
        jmp     L6_A2A9
L6_A2A6:
        jsr     L7_C09C
L6_A2A9:
        lda     #$40
        ldy     #$05
        jsr     L7_C0A5
        lda     $A2C6,Y
        sta     $0548,X
        lda     $0560,X
        and     #$3F
        ora     $A2CB,Y
        sta     $0560,X
        jmp     L6_A317

; ---- UNCLAIMED (gap) $A2C4-$A2CF, 12 bytes
        .byte   $00,$02,$1A,$1B,$1C,$1C,$1B,$00,$00,$00,$00,$40

; ---- bank6.code_A2D0 (code) $A2D0-$A30E, 63 bytes
L6_A2D0:
        jsr     L7_C0EA
        and     #$1F
        adc     #$30
        sta     $10
        lda     $0530,X
        bpl     L6_A2E2
        sbc     $10
        bcs     L6_A2E4
L6_A2E2:
        adc     $10
L6_A2E4:
        sta     $0680,X
        rts
L6_A2E8:
        jsr     L7_C0EA
        and     #$1F
        adc     #$20
        sta     $10
        lda     $0518,X
        cmp     #$60
        bcc     L6_A2FC
        sbc     $10
        bcs     L6_A2FE
L6_A2FC:
        adc     $10
L6_A2FE:
        sta     $0668,X
        rts
L6_A302:
        sta     $0560,X
        tya
        sta     $0548,X
        lda     #$3C
        sta     $0788,X
        rts

; ---- UNCLAIMED (gap) $A30F-$A316, 8 bytes
        .byte   $9D,$60,$05,$98,$9D,$48,$05,$60

; ---- bank6.code_A317 (code) $A317-$A3D9, 195 bytes
L6_A317:
        jsr     L7_C08D
        bcc     L6_A31F
        jmp     L6_9B17
L6_A31F:
        jsr     L7_C0C6
        jmp     L7_C0D2
L6_A325:
        lda     $0530,X
        cmp     $0530
        beq     L6_A336
        bcs     L6_A333
        inc     $0530,X
        rts
L6_A333:
        dec     $0530,X
L6_A336:
        rts
L6_A337:
        lda     $0518,X
        cmp     $0518
        beq     L6_A336
        bcs     L6_A345
        inc     $0518,X
        rts
L6_A345:
        dec     $0518,X
        rts
L6_A349:
        ldy     $0500,X
        bmi     L6_A373
        lda     $9D9F,Y
        sta     $0560,X
        lda     $A385,Y
        sta     $07B8,X
        lda     $A388,Y
        sta     $07D0,X
        jsr     L7_C0A8
        jsr     L7_C165
        lda     #$69
        sta     $0548,X
        lda     #$00
        sta     $07A0,X
        jsr     L7_C0A2
L6_A373:
        jsr     L6_A3EA
        lda     #$07
        jsr     L6_9B09
        jsr     L6_A337
        jsr     L7_C090
        lda     $07A0,X
        cmp     #$02
        bne     L6_A3BE
        lda     $07B8,X
        ldy     #$0A
        jsr     L7_C0A5
        lda     $A3E0,Y
        cmp     #$67
        bne     L6_A3BB
        lda     $41
        and     $07D0,X
        bne     L6_A3BB
        jsr     L7_C0FF
        sta     $15
        jsr     L7_C108
        bcs     L6_A3BB
        jsr     L6_AC9F
        jsr     L6_ACCA
        lda     #$E8
        jsr     L6_AECF
        lda     $0530,Y
        sbc     #$08
        sta     $0530,Y
L6_A3BB:
        jsr     L6_A432
L6_A3BE:
        lda     $86
        and     #$03
        sta     $86
        ldy     $0638,X
        lda     $A3E0,Y
        jsr     L7_C093
        lda     $07A0,X
        cmp     #$02
        bne     L6_A3FF
        jsr     L7_C0C6
        jmp     L7_C0D8

; ---- UNCLAIMED (gap) $A3DA-$A3E9, 16 bytes
        .byte   $04,$18,$30,$0F,$03,$00,$68,$68,$67,$68,$68,$67,$68,$67,$68,$67

; ---- bank6.code_A3EA (code) $A3EA-$A4F7, 270 bytes
L6_A3EA:
        lda     $07A0,X
        bne     L6_A400
        jsr     L7_C0F3
        jsr     L6_9A53
        bne     L6_A42F
        lda     #$78
        sta     $0788,X
        inc     $07A0,X
L6_A3FF:
        rts
L6_A400:
        cmp     #$01
        beq     L6_A408
        cmp     #$03
        bne     L6_A41E
L6_A408:
        dec     $0788,X
        beq     L6_A416
        lda     $0788,X
        and     #$01
        beq     L6_A3FF
        bne     L6_A42F
L6_A416:
        inc     $07A0,X
        lda     #$78
        sta     $0788,X
L6_A41E:
        lda     $07A0,X
        cmp     #$02
        beq     L6_A3FF
        dec     $0788,X
        bne     L6_A42F
        lda     #$00
        sta     $07A0,X
L6_A42F:
        pla
        pla
        rts
L6_A432:
        lda     $41
        and     #$01
        bne     L6_A445
        dec     $0788,X
        bne     L6_A445
        lda     #$3C
        sta     $0788,X
        inc     $07A0,X
L6_A445:
        rts
L6_A446:
        lda     $0500,X
        bmi     L6_A46E
        jsr     L7_C0A8
        jsr     L6_9B0F
        lda     $9ADB,Y
        sta     $0560,X
        lda     $A4FB,Y
        sta     $07D0,X
        lda     $A501,Y
        sta     $0590,X
        jsr     L7_C165
        lda     #$00
        sta     $07A0,X
        jsr     L7_C0A2
L6_A46E:
        jsr     L6_A3EA
        ldy     #$23
        lda     $07A0,X
        cmp     #$02
        bne     L6_A485
        lda     #$40
        jsr     L7_C0A5
        bcs     L6_A4B6
        cpy     #$0A
        bcs     L6_A497
L6_A485:
        tya
        and     #$01
        asl     A
        asl     A
        adc     $07E8,X
        sta     $06C8,X
        lda     #$34
        sta     $0548,X
        bcc     L6_A4BE
L6_A497:
        cpy     #$1E
        bcs     L6_A485
        lda     $07E8,X
        sta     $06C8,X
        cpy     #$0C
        bcs     L6_A4AA
        lda     $A4EE,Y
        bne     L6_A4B1
L6_A4AA:
        cpy     #$1C
        bcc     L6_A4BE
        lda     $A4DD,Y
L6_A4B1:
        sta     $0548,X
        bne     L6_A4BE
L6_A4B6:
        lda     #$3C
        sta     $0788,X
        inc     $07A0,X
L6_A4BE:
        jsr     L7_C090
        lda     $07A0,X
        cmp     #$03
        bne     L6_A4EA
        lda     $0788,X
        ldy     $0500,X
        cmp     $07D0,X
        bcs     L6_A4EA
        jsr     L6_9A53
        bne     L6_A4EA
        jsr     L7_C108
        bcs     L6_A4EA
        lda     #$0E
        sta     $0728,Y
        jsr     L7_C105
        lda     #$08
        jsr     L6_AECF
L6_A4EA:
        lda     $07A0,X
        cmp     #$02
        beq     L6_A4F2
        rts
L6_A4F2:
        jsr     L7_C0C6
        jmp     L7_C0D8

; ---- UNCLAIMED (gap) $A4F8-$A506, 15 bytes
        .byte   $35,$36,$35,$04,$06,$08,$0A,$10,$10,$04,$04,$07,$0A,$10,$14

; ---- bank6.code_A507 (code) $A507-$A59F, 153 bytes
L6_A507:
        ldy     $0500,X
        bmi     L6_A541
        lda     $A546,Y
        sta     $0560,X
        lda     $A549,Y
        sta     $0698,X
        lda     $A54C,Y
        sta     $07A0,X
        lda     $A54F,Y
        sta     $07B8,X
        jsr     L7_C0A8
        jsr     L7_C165
L6_A52A:
        jsr     L7_C0F3
        jsr     L7_C0A2
        lda     #$8C
        sta     $0548,X
        lda     #$FF
        sta     $0668,X
        lda     #$78
        sta     $0788,X
        bne     L6_A551
L6_A541:
        jsr     L7_C009
        lda     $05D8,X
        bmi     L6_A563
        lda     $0518,X
        cmp     $07A0,X
        bcc     L6_A563
L6_A551:
        jsr     L7_C0FC
        lda     $05D8,X
        sec
        sbc     #$02
        sta     $05D8,X
        lda     $0518
        sta     $07A0,X
L6_A563:
        lda     #$30
        ldy     #$04
        jsr     L7_C0A5
        lda     $0560,X
        and     #$03
        ora     $A5AC,Y
        sta     $0560,X
        lda     #$18
        jsr     L7_C09C
        lda     $0500,X
        cmp     #$DC
        bne     L6_A58C
        lda     $0530
        sta     $0680,X
        lda     #$10
        jsr     L7_C09F
L6_A58C:
        jsr     L7_C08D
        bcs     L6_A52A
        lda     $0788,X
        beq     L6_A597
        rts
L6_A597:
        jsr     L7_C0C6
        jsr     L6_A5B0
        jmp     L7_C0D8

; ---- UNCLAIMED (gap) $A5A0-$A5AF, 16 bytes
        .byte   $03,$02,$00,$03,$02,$02,$01,$04,$02,$08,$50,$18,$00,$80,$C0,$40

; ---- bank6.code_A5B0 (code) $A5B0-$A765, 438 bytes
L6_A5B0:
        php
        bcc     L6_A5BA
        lda     $6E
        bne     L6_A5BA
        jsr     L7_C123
L6_A5BA:
        plp
        rts
L6_A5BC:
        lda     $0500,X
        bmi     L6_A5E3
        jsr     L7_C0A8
        jsr     L7_C165
        jsr     L7_C0F3
        lda     #$8C
        sta     $0548,X
        lda     #$02
        sta     $0560,X
        lda     #$78
        sta     $0788,X
        lda     #$00
        sta     $07A0,X
        lda     #$3C
        sta     $07B8,X
L6_A5E3:
        jsr     L7_C009
        dec     $07B8,X
        bne     L6_A61E
        lda     #$5A
        sta     $07B8,X
        lda     $0560,X
        eor     #$40
        sta     $0560,X
        jsr     L7_C108
        bcs     L6_A616
        lda     #$5F
        jsr     L7_C105
        lda     #$02
        sta     $0560,Y
        lda     #$04
        sta     $07A0,Y
        lda     #$00
        sta     $0698,Y
        lda     #$10
        sta     $07D0,Y
L6_A616:
        lda     $07A0,X
        eor     #$01
        sta     $07A0,X
L6_A61E:
        jsr     L6_9A53
        beq     L6_A62A
        lda     $41
        and     #$03
        beq     L6_A62A
        rts
L6_A62A:
        lda     $07A0,X
        bne     L6_A635
        jsr     L6_A325
        jmp     L6_A638
L6_A635:
        jsr     L6_A337
L6_A638:
        jsr     L7_C090
        jsr     L7_C0C6
        jmp     L7_C0D8
L6_A641:
        lda     $0500,X
        bmi     L6_A679
        jsr     L7_C0AE
        jsr     L7_C165
        lda     #$61
        sta     $06C8,X
        lda     #$8C
        sta     $0548,X
        lda     #$03
        sta     $0560,X
        lda     #$30
        sta     $0530,X
        lda     #$20
        sta     $0518,X
        lda     #$80
        sta     $0680,X
        lda     #$60
        sta     $0668,X
        lda     #$78
        sta     $0788,X
        lda     #$28
        sta     $07A0,X
L6_A679:
        jsr     L7_C009
        dec     $07A0,X
        bne     L6_A6A4
        lda     #$28
        sta     $07A0,X
        jsr     L7_C108
        bcs     L6_A6A4
        lda     #$5F
        jsr     L7_C105
        lda     #$01
        sta     $0560,Y
        lda     #$00
        sta     $0698,Y
        lda     #$00
        sta     $07A0,Y
        lda     #$28
        sta     $07D0,Y
L6_A6A4:
        lda     #$10
        jsr     L7_C09C
        lda     #$18
        jsr     L7_C09F
        jsr     L7_C08D
        jsr     L7_C0C6
        jmp     L7_C0D8
L6_A6B7:
        lda     $0500,X
        bmi     L6_A6D6
        jsr     L7_C0A8
        jsr     L7_C162
        lda     $07A0,X
        jsr     L6_A1E7
        lda     $0788,X
        jsr     L7_C102
        lda     #$37
        sta     $0548,X
        jsr     L7_C0A2
L6_A6D6:
        lda     $0518
        sta     $0668,X
        lda     $0530
        sta     $0680,X
        lda     $07D0,X
        jsr     L7_C09C
        lda     $07D0,X
        jsr     L7_C09F
        lda     #$20
        ldy     #$04
        jsr     L7_C0A5
        lda     $0560,X
        and     #$03
        ora     $A5AC,Y
        sta     $0560,X
        jmp     L6_9F4F
L6_A703:
        ldy     $0500,X
        bmi     L6_A73B
        lda     $A716,Y
        sta     $0698,X
        lda     $A718,Y
        sta     $0560,X
        lda     $A71A,Y
        sta     $07B8,X
        lda     $A71C,Y
        sta     $07D0,X
        jsr     L7_C0A8
        jsr     L7_C162
        jsr     L7_C0F3
        lda     #$19
        sta     $0548,X
        jsr     L7_C0A2
        lda     #$3C
        sta     $0788,X
        lda     #$01
        sta     $07A0,X
L6_A73B:
        jsr     L7_C009
        dec     $07A0,X
        bne     L6_A755
        lda     $07D0,X
        sta     $07A0,X
        jsr     L7_C0FF
        clc
        adc     $07B8,X
        and     #$0C
        jsr     L7_C102
L6_A755:
        lda     #$0F
        jsr     L6_9B09
        jsr     L6_826D
        jsr     L7_C090
        jsr     L7_C0C6
        jmp     L7_C0D2

; ---- UNCLAIMED (gap) $A766-$A76D, 8 bytes
        .byte   $01,$02,$02,$00,$01,$02,$3C,$1E

; ---- bank6.code_A76E (code) $A76E-$A7F3, 134 bytes
L6_A76E:
        lda     $0500,X
        bmi     L6_A7B0
        jsr     L7_C0A8
        jsr     L7_C162
        lda     #$01
        sta     $0560,X
        jsr     L6_AEE8
        lda     #$1A
        sta     $0548,X
        ldy     #$00
        jsr     L6_AD9A
        beq     L6_A78F
        ldy     #$02
L6_A78F:
        lda     $A7F4,Y
        sta     $0530,X
        sta     $0680,X
        lda     $A7F5,Y
        sta     $0608,X
        lda     #$18
        sta     $0518,X
        lda     #$01
        sta     $05D8,X
        lda     #$28
        sta     $0788,X
        jsr     L7_C0A2
L6_A7B0:
        jsr     L7_C009
        lda     #$30
        ldy     #$02
        jsr     L7_C0A5
        lda     $A7F8,Y
        jsr     L6_A1E7
        lda     #$0A
        jsr     L7_C09F
        jsr     L7_C08D
        bcc     L6_A7CD
        jmp     L6_9B17
L6_A7CD:
        lda     $0530,X
        cmp     $0680,X
        ldy     $0680,X
        bmi     L6_A7E1
        bcs     L6_A7EE
        lda     $0608,X
        bpl     L6_A7EE
        bmi     L6_A7E8
L6_A7E1:
        bcc     L6_A7EE
        lda     $0608,X
        bmi     L6_A7EE
L6_A7E8:
        jsr     L7_C123
        jsr     L7_C126
L6_A7EE:
        jsr     L7_C0C6
        jmp     L7_C0D2

; ---- UNCLAIMED (gap) $A7F4-$A7F9, 6 bytes
        .byte   $20,$03,$E0,$FD,$00,$02

; ---- bank6.code_A7FA (code) $A7FA-$A886, 141 bytes
L6_A7FA:
        ldy     $0500,X
        bmi     L6_A838
        lda     $4B
        cmp     #$03
        bcs     L6_A80E
        tya
        sbc     #$02
        sta     $0500,X
        jmp     L6_A703
L6_A80E:
        lda     $A713,Y
        sta     $0698,X
        lda     $A715,Y
        sta     $0560,X
        lda     $A719,Y
        sta     $07D0,X
        jsr     L7_C0A8
        jsr     L7_C162
        jsr     L7_C0F3
        lda     #$50
        sta     $0548,X
        lda     #$01
        sta     $07A0,X
        lda     #$3C
        sta     $0788,X
L6_A838:
        jsr     L7_C009
        dec     $07A0,X
        bne     L6_A849
        lda     $07D0,X
        sta     $07A0,X
        jsr     L7_C0FC
L6_A849:
        lda     #$10
        ldy     #$02
        jsr     L7_C0A5
        lda     $A887,Y
        sta     $0548,X
        jsr     L6_9A53
        beq     L6_A862
        lda     $41
        and     #$01
        beq     L6_A862
L6_A861:
        rts
L6_A862:
        jsr     L7_C08D
        bcc     L6_A86A
        jmp     L6_9B17
L6_A86A:
        ldy     $6C
        lda     $8425,Y
        bne     L6_A861
        lda     $41
        and     #$1F
        bne     L6_A881
        jsr     L7_C108
        bcs     L6_A881
        lda     #$0B
        jsr     L7_C105
L6_A881:
        jsr     L7_C0C6
        jmp     L7_C0D2

; ---- UNCLAIMED (gap) $A887-$A888, 2 bytes
        .byte   $50,$2B

; ---- bank6.code_A889 (code) $A889-$A9B7, 303 bytes
L6_A889:
        lda     $0500,X
        bmi     L6_A898
        lda     $B8
        ora     $B9
        beq     L6_A895
L6_A894:
        rts
L6_A895:
        jsr     L7_C0AE
L6_A898:
        lda     #$00
        sta     $0518,X
        ldy     #$05
L6_A89F:
        lda     $0500,Y
        beq     L6_A8B9
        and     #$7F
        cmp     #$36
        beq     L6_A8B6
        cmp     #$37
        beq     L6_A8B6
        cmp     #$7E
        beq     L6_A8B6
        cmp     #$7F
        bne     L6_A8B9
L6_A8B6:
        inc     $0518,X
L6_A8B9:
        iny
        cpy     #$18
        bne     L6_A89F
        lda     $0518,X
        bne     L6_A894
        jmp     L7_C048
L6_A8C6:
        lda     $0530,X
        clc
        adc     #$08
        sta     $0530,X
        lda     $0518,X
        adc     #$08
        sta     $0518,X
        rts
L6_A8D8:
        jsr     L6_BA51
        ldy     $0500,X
        bmi     L6_A8FE
        lda     $A982,Y
        sta     $0548,X
        cpy     #$36
        beq     L6_A8ED
        jsr     L6_A8C6
L6_A8ED:
        jsr     L7_C0AE
        txa
        and     #$07
        sta     $0788,X
        jsr     L7_C0A2
        lda     #$01
        sta     $07B8,X
L6_A8FE:
        ldy     $0518,X
        lda     $0500,X
        cmp     #$B6
        bne     L6_A94A
        cpy     #$B8
        bcs     L6_A91F
        ldy     #$03
        jsr     L6_AA35
        bcc     L6_A91F
        lda     $0638,X
        asl     A
        asl     A
        adc     #$21
        ldy     #$AA
        jsr     L6_AA21
L6_A91F:
        lda     $0638,X
        cmp     #$03
        bne     L6_A932
        lda     #$0F
        jsr     L6_AEBF
        bcs     L6_A932
        lda     #$2B
        jsr     L6_AA0F
L6_A932:
        lda     $0638,X
        beq     L6_A949
        jsr     L7_C0CF
        jsr     L7_C0D2
        lda     $0500,X
        bmi     L6_A949
        lda     #$31
        ldy     #$55
        jmp     L6_AA21
L6_A949:
        rts
L6_A94A:
        lda     $B8
        ora     $B9
        bne     L6_A95D
        ldy     #$02
        jsr     L6_AA35
        bcc     L6_A95D
        lda     $0638,X
        jsr     L6_A991
L6_A95D:
        lda     $0638,X
        cmp     #$02
        bne     L6_A97B
        dec     $07B8,X
        bne     L6_A97B
        lda     #$14
        sta     $07B8,X
        jsr     L7_C108
        bcs     L6_A97B
        lda     #$2B
        jsr     L7_C105
        jsr     L6_AA12
L6_A97B:
        lda     $0638,X
        beq     L6_A990
        jsr     L7_C0CF
        jsr     L7_C0D2
        lda     $0500,X
        bmi     L6_A990
        lda     #$03
        jsr     L6_A991
L6_A990:
        rts
L6_A991:
        pha
        lda     #$BF
        sta     $16
        lda     #$A9
        sta     $17
        pla
        asl     A
        asl     A
        asl     A
        asl     A
        adc     $16
        sta     $16
        lda     $17
        adc     #$00
        sta     $17
        jsr     L6_BF71
        lda     #$04
        sta     $15
        sta     $14
        ldy     $0518,X
        jmp     L7_C07E

; ---- UNCLAIMED (gap) $A9B8-$AA0E, 87 bytes
        .byte   $31,$21,$FE,$02,$FF,$01,$00,$CA,$CB,$CC,$CD,$DA,$DB,$DC,$DD,$EA
        .byte   $EB,$EC,$ED,$FA,$FB,$FC,$FD,$CA,$C0,$C1,$CD,$C2,$C3,$C4,$C5,$C6
        .byte   $C7,$C8,$C9,$FA,$CE,$CF,$FD,$CA,$DE,$DF,$CD,$B8,$B9,$BA,$BB,$BC
        .byte   $BD,$BE,$BF,$FA,$EE,$EF,$FD,$CA,$B6,$B7,$CD,$B2,$20,$20,$B3,$B0
        .byte   $20,$20,$B1,$FA,$B4,$B5,$FD,$C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C4
        .byte   $C5,$C6,$C7,$C8,$C9,$CA,$CB

; ---- bank6.code_AA0F (code) $AA0F-$AA7B, 109 bytes
L6_AA0F:
        sta     $0500,Y
L6_AA12:
        tya
        pha
        jsr     L7_C0FF
        sta     $10
        pla
        tay
        lda     $10
        sta     $0788,Y
L6_AA20:
        rts
L6_AA21:
        sty     $17
        pha
        jsr     L6_BF71
        pla
        ldy     $0518,X
        cpy     #$B8
        bcs     L6_AA20
        ldy     $0608,X
        jmp     L7_C054
L6_AA35:
        sty     $10
        ldy     $0788,X
        lda     $0638,X
        bne     L6_AA4B
        lda     $AA7C,Y
        jsr     L6_AA94
        bcc     L6_AA4A
L6_AA47:
        inc     $0638,X
L6_AA4A:
        rts
L6_AA4B:
        cmp     $10
        bne     L6_AA61
        lda     $AA8C,Y
        jsr     L6_AA94
        bcc     L6_AA60
        lda     $0638,X
        sbc     #$81
        sta     $0638,X
        sec
L6_AA60:
        rts
L6_AA61:
        lda     $AA84,Y
        jsr     L6_AA94
        bcc     L6_AA60
        lda     $0638,X
        bpl     L6_AA47
        dec     $0638,X
        lda     $0638,X
        and     #$7F
        bne     L6_AA60
        sta     $0638,X
        rts

; ---- UNCLAIMED (gap) $AA7C-$AA93, 24 bytes
        .byte   $04,$08,$06,$05,$07,$06,$08,$03,$50,$40,$30,$44,$25,$18,$30,$48
        .byte   $10,$0C,$11,$05,$07,$14,$09,$0D

; ---- bank6.code_AA94 (code) $AA94-$AB21, 142 bytes
L6_AA94:
        clc
        adc     $0650,X
        sta     $0650,X
        rts
L6_AA9C:
        lda     $0500,X
        bmi     L6_AAD8
        jsr     L7_C0A8
        jsr     L7_C162
        jsr     L7_C0A2
        jsr     L7_C0F0
        lda     $0530,X
        and     #$0F
        asl     A
        asl     A
        adc     #$60
        sta     $0788,X
        lda     #$1A
        sta     $0548,X
        lda     #$00
        sta     $0560,X
        sta     $07A0,X
        lda     #$04
        jsr     L6_A1E7
        jsr     L6_AEE8
        lda     #$06
        sta     $0698,X
        lda     #$04
        jsr     L7_C102
L6_AAD8:
        lda     $07A0,X
        bne     L6_AAFC
        lda     $0518,X
        cmp     $0788,X
        bcc     L6_AB1F
        ldy     #$0E
        lda     $0530,X
        cmp     #$80
        bcc     L6_AAF0
        ldy     #$0A
L6_AAF0:
        tya
        jsr     L7_C102
        lda     #$01
        sta     $0788,X
        sta     $07A0,X
L6_AAFC:
        dec     $0788,X
        bne     L6_AB0B
        lda     #$14
        sta     $0788,X
        lda     #$06
        jsr     L6_AB32
L6_AB0B:
        lda     #$60
        ldy     #$08
        jsr     L7_C0A5
        lda     $AB22,Y
        sta     $15
        lda     $AB2A,Y
        sta     $14
        jsr     L6_A1DB
L6_AB1F:
        jmp     L6_9F4F

; ---- UNCLAIMED (gap) $AB22-$AB31, 16 bytes
        .byte   $04,$02,$00,$02,$04,$02,$00,$02,$00,$00,$00,$80,$80,$80,$00,$00

; ---- bank6.code_AB32 (code) $AB32-$AC1F, 238 bytes
L6_AB32:
        sta     $17
        jsr     L7_C108
        bcs     L6_AB68
        lda     $07E8,X
        adc     $17
        sta     $17
        lda     #$04
        sta     $16
        lda     $0518,X
        cmp     $0518
        bcc     L6_AB50
        lda     #$FC
        sta     $16
L6_AB50:
        jsr     L7_C13E
        lda     #$18
        jsr     L7_C13B
        lda     #$FF
        sta     $0668,Y
        lda     $05A8,X
        sta     $05A8,Y
        lda     #$40
        jsr     L7_C030
L6_AB68:
        rts
L6_AB69:
        lda     $0500,X
        bmi     L6_AB93
        jsr     L7_C0A8
        jsr     L7_C162
        lda     #$00
        sta     $0560,X
        jsr     L6_AEE8
        lda     #$50
        sta     $0548,X
        ldy     #$00
        jsr     L6_AF39
        lda     #$A8
        sta     $0518,X
        sta     $0668,X
        lda     #$3C
        sta     $0788,X
L6_AB93:
        jsr     L7_C009
        lda     $41
        and     #$01
        bne     L6_AB9F
        jsr     L6_A325
L6_AB9F:
        lda     $05D8,X
        bmi     L6_ABD2
        lda     $0518,X
        cmp     $0668,X
        bcc     L6_ABD2
        lda     #$FC
        sta     $05D8,X
        lda     $0668,X
        sbc     #$10
        cmp     #$40
        bcs     L6_ABBC
        lda     #$A8
L6_ABBC:
        sta     $0668,X
        lda     #$08
        jsr     L6_AB32
        lda     $05A8,X
        sta     $05A8,Y
        lda     $0560,X
        eor     #$40
        sta     $0560,X
L6_ABD2:
        lda     #$30
        jsr     L7_C09C
        jmp     L6_9F4F
L6_ABDA:
        lda     $0500,X
        bmi     L6_ABF8
        jsr     L7_C0A8
        jsr     L7_C162
        jsr     L7_C0A2
        jsr     L7_C0F0
        lda     #$01
        sta     $0560,X
        jsr     L6_AEE8
        lda     #$01
        sta     $05D8,X
L6_ABF8:
        lda     #$40
        ldy     #$04
        jsr     L7_C0A5
        lda     $AC20,Y
        sta     $15
        lda     $AC24,Y
        sta     $14
        lda     $AC28,Y
        jsr     L6_A1D8
        lda     $41
        and     #$03
        bne     L6_AC1D
        jsr     L7_C108
        bcs     L6_AC1D
        jsr     L6_BF61
L6_AC1D:
        jmp     L6_9F4F

; ---- UNCLAIMED (gap) $AC20-$AC2B, 12 bytes
        .byte   $04,$00,$02,$00,$00,$00,$00,$40,$1A,$79,$1A,$79

; ---- bank6.code_AC2C (code) $AC2C-$AC8E, 99 bytes
L6_AC2C:
        jsr     L6_BA51
        lda     $0500,X
        bmi     L6_AC52
        jsr     L7_C0AE
        lda     $0518,X
        clc
        adc     #$10
        sta     $0518,X
        lda     $0530,X
        adc     #$06
        sta     $0530,X
        lda     #$21
        sta     $0548,X
        lda     #$01
        sta     $07A0,X
L6_AC52:
        dec     $07A0,X
        bne     L6_AC6C
        lda     #$10
        sta     $07A0,X
        jsr     L7_C0FF
        sta     $15
        jsr     L7_C108
        bcs     L6_AC6C
        jsr     L6_AC9F
        jsr     L6_ACCA
L6_AC6C:
        jsr     L7_C0CF
        jsr     L7_C0D2
        lda     $0500,X
        bmi     L6_AC8E
        jsr     L6_BF71
        lda     #$8F
        sta     $16
        lda     #$AC
        sta     $17
        lda     #$04
        sta     $15
        sta     $14
        ldy     $0518,X
        jmp     L7_C07E
L6_AC8E:
        rts

; ---- UNCLAIMED (gap) $AC8F-$AC9E, 16 bytes
        .byte   $80,$80,$80,$80,$80,$80,$80,$80,$60,$7D,$7E,$7F,$68,$20,$20,$6F

; ---- bank6.code_AC9F (code) $AC9F-$ACB9, 27 bytes
L6_AC9F:
        lda     #$2A
        jsr     L7_C105
        jsr     L7_C0EA
        sty     $10
        ldy     $15
        pha
        and     #$04
        lsr     A
        lsr     A
        adc     $ACBA,Y
        ldy     $10
        sta     $0788,Y
        pla
        rts

; ---- UNCLAIMED (gap) $ACBA-$ACC9, 16 bytes
        .byte   $01,$01,$00,$00,$FF,$FF,$FE,$FE,$FE,$FE,$FE,$FF,$FF,$00,$00,$01

; ---- bank6.code_ACCA (code) $ACCA-$AD89, 192 bytes
L6_ACCA:
        and     #$03
        sta     $0560,Y
        lda     #$18
        sta     $0728,Y
        sta     $07B8,Y
        lda     #$37
        sta     $0548,Y
        lda     #$00
        sta     $07A0,Y
        rts
L6_ACE2:
        lda     $0500,X
        bmi     L6_AD2F
        jsr     L7_C0A8
        jsr     L7_C162
        ldy     #$18
        jsr     L6_AD9A
        beq     L6_ACF6
        ldy     #$E8
L6_ACF6:
        tya
        sta     $0530,X
        lda     $51
        cmp     #$0B
        bcc     L6_AD02
        sbc     #$08
L6_AD02:
        cmp     #$05
        bcc     L6_AD0C
        sbc     #$01
        and     #$03
        adc     #$00
L6_AD0C:
        sta     $07B8,X
        tay
        lda     $AD89,Y
        sta     $0560,X
        lda     $AD8D,Y
        sta     $05D8,X
        lda     #$C0
        sta     $05C0,X
        lda     $AD91,Y
        sta     $0698,X
        lda     #$00
        sta     $0788,X
        jsr     L7_C0A2
L6_AD2F:
        lda     $0788,X
        bne     L6_AD51
        lda     #$20
        ldy     #$02
        jsr     L7_C0A5
        lda     $AD96,Y
        sta     $0548,X
        lda     $0518,X
        cmp     $0518
        bcc     L6_AD87
        jsr     L7_C0FC
        inc     $0788,X
        bne     L6_AD87
L6_AD51:
        cmp     #$01
        bne     L6_AD82
        lda     #$20
        ldy     #$02
        jsr     L7_C0A5
        lda     $AD98,Y
        sta     $0548,X
        lda     $0530,X
        cmp     #$10
        ldy     #$0E
        bcc     L6_AD71
        cmp     #$F1
        ldy     #$0A
        bcc     L6_AD87
L6_AD71:
        inc     $0788,X
        tya
        jsr     L7_C102
        lda     #$5B
        sta     $0548,X
        lda     #$06
        jsr     L6_A1E7
L6_AD82:
        lda     #$30
        jsr     L6_9AF9
L6_AD87:
        jmp     L6_9F4F

; ---- UNCLAIMED (gap) $AD8A-$AD99, 16 bytes
        .byte   $03,$00,$01,$02,$00,$02,$01,$01,$02,$06,$03,$41,$5B,$5C,$59,$5A

; ---- bank6.code_AD9A (code) $AD9A-$AE44, 171 bytes
L6_AD9A:
        inc     $6A
        lda     $6A
        and     #$01
        rts
L6_ADA1:
        lda     $0500,X
        bmi     L6_ADE0
        jsr     L7_C0A8
        jsr     L7_C162
        ldy     #$00
        jsr     L6_AD9A
        beq     L6_ADB5
        ldy     #$02
L6_ADB5:
        lda     $AE45,Y
        sta     $0530,X
        lda     $AE46,Y
        sta     $0788,X
        lda     #$00
        sta     $0560,X
        jsr     L6_AEE8
        lda     #$03
        sta     $05D8,X
        lda     #$00
        sta     $07A0,X
        jsr     L7_C0A2
        lda     #$56
        sta     $0548,X
        lda     #$00
        sta     $0668,X
L6_ADE0:
        lda     $07A0,X
        bne     L6_ADFF
        lda     #$06
        jsr     L7_C09C
        lda     $05D8,X
        bne     L6_AE42
        inc     $07A0,X
        lda     $0788,X
        sta     $0608,X
        lda     #$40
        sta     $0668,X
        bne     L6_AE03
L6_ADFF:
        cmp     #$01
        bne     L6_AE2E
L6_AE03:
        lda     #$20
        jsr     L7_C09C
        lda     $0548,X
        cmp     #$58
        beq     L6_AE1C
        lda     #$20
        ldy     #$03
        jsr     L7_C0A5
        lda     $AE49,Y
        sta     $0548,X
L6_AE1C:
        lda     $0518,X
        cmp     #$30
        bcs     L6_AE42
        inc     $07A0,X
        lda     #$43
        sta     $0698,X
        jsr     L7_C0FC
L6_AE2E:
        lda     $0548,X
        cmp     #$56
        beq     L6_AE42
        lda     #$20
        ldy     #$03
        jsr     L7_C0A5
        lda     $AE4B,Y
        sta     $0548,X
L6_AE42:
        jmp     L6_9F4F

; ---- UNCLAIMED (gap) $AE45-$AE4D, 9 bytes
        .byte   $28,$01,$D8,$FF,$56,$57,$58,$57,$56

; ---- bank6.code_AE4E (code) $AE4E-$AEBA, 109 bytes
L6_AE4E:
        lda     $0500,X
        bmi     L6_AE8F
        jsr     L7_C0A8
        jsr     L7_C162
        ldy     #$00
        jsr     L6_AD9A
        beq     L6_AE62
        ldy     #$02
L6_AE62:
        lda     $AEBB,Y
        sta     $0530,X
        lda     $AEBC,Y
        sta     $0608,X
        lda     #$01
        sta     $0560,X
        lda     #$5F
        sta     $0548,X
        jsr     L6_AEE8
        jsr     L7_C0EA
        and     #$7F
        adc     #$30
        sta     $0518,X
        lda     #$3C
        sta     $0788,X
        lda     #$00
        sta     $07A0,X
L6_AE8F:
        jsr     L7_C009
        lda     $07A0,X
        bne     L6_AEB8
        lda     $0530,X
        cmp     $0530
        lda     $0608,X
        bpl     L6_AEA6
        ror     A
        eor     #$80
        rol     A
L6_AEA6:
        bcc     L6_AEB8
        inc     $07A0,X
        lda     #$5E
        sta     $0548,X
        lda     #$81
        sta     $0698,X
        jsr     L7_C0FC
L6_AEB8:
        jmp     L6_9F4F

; ---- UNCLAIMED (gap) $AEBB-$AEBE, 4 bytes
        .byte   $18,$01,$E8,$FF

; ---- bank6.code_AEBF (code) $AEBF-$AF34, 118 bytes
L6_AEBF:
        sec
        and     $41
        bne     L6_AECE
        jsr     L7_C108
        bcs     L6_AECE
        lda     #$0B
        jmp     L7_C105
L6_AECE:
        rts
L6_AECF:
        clc
        and     #$FF
        bmi     L6_AEDD
        adc     $0518,Y
        bcc     L6_AEE4
        lda     #$FF
        bne     L6_AEE4
L6_AEDD:
        adc     $0518,Y
        bcs     L6_AEE4
        lda     #$00
L6_AEE4:
        sta     $0518,Y
        rts
L6_AEE8:
        lda     $50
        cmp     #$07
        bcc     L6_AEF3
        lda     #$02
        sta     $0560,X
L6_AEF3:
        rts
L6_AEF4:
        lda     $0500,X
        bmi     L6_AF12
        jsr     L7_C0A8
        jsr     L7_C162
        lda     #$6B
        sta     $0548,X
        lda     #$02
        sta     $0560,X
        sta     $0668,X
        jsr     L6_AF39
        jsr     L6_AEE8
L6_AF12:
        lda     #$06
        jsr     L7_C09C
        lda     #$0C
        jsr     L7_C09F
        lda     #$0F
        and     $41
        bne     L6_AF32
        jsr     L7_C0FF
        sta     $15
        jsr     L7_C108
        bcs     L6_AF32
        jsr     L6_AC9F
        jsr     L6_ACCA
L6_AF32:
        jmp     L6_9F4F

; ---- UNCLAIMED (gap) $AF35-$AF38, 4 bytes
        .byte   $08,$04,$F8,$FC

; ---- bank6.code_AF39 (code) $AF39-$AF56, 30 bytes
L6_AF39:
        ldy     #$00
        jsr     L6_AD9A
        beq     L6_AF42
        ldy     #$02
L6_AF42:
        lda     $AF35,Y
        sta     $0530,X
        sta     $0680,X
        lda     $AF36,Y
        sta     $0608,X
        lda     #$02
        sta     $05D8,X
        rts

; ---- UNCLAIMED (gap) $AF57-$AF81, 43 bytes
        .byte   $BC,$30,$05,$BD,$08,$06,$30,$06,$C0,$F0,$90,$09,$B0,$04,$C0,$10
        .byte   $B0,$03,$4C,$23,$C1,$60,$BC,$18,$05,$BD,$D8,$05,$30,$06,$C0,$B8
        .byte   $90,$F3,$B0,$04,$C0,$10,$B0,$ED,$4C,$26,$C1

; ---- bank6.code_AF82 (code) $AF82-$B021, 160 bytes
L6_AF82:
        lda     $0500,X
        bmi     L6_AFC7
        jsr     L7_C0A8
        jsr     L7_C162
        lda     #$06
        sta     $0698,X
        lda     #$1A
        sta     $0548,X
        lda     #$00
        sta     $0560,X
        lda     $50
        cmp     #$05
        bcc     L6_AFA7
        lda     #$03
        sta     $0560,X
L6_AFA7:
        ldy     #$00
        jsr     L6_AD9A
        beq     L6_AFB0
        ldy     #$02
L6_AFB0:
        lda     $B022,Y
        sta     $0530,X
        lda     $B023,Y
        jsr     L7_C102
        jsr     L7_C0EA
        sta     $07B8,X
        lda     #$FF
        sta     $07A0,X
L6_AFC7:
        lda     $07A0,X
        bpl     L6_AFF2
        lda     $0530,X
        ldy     $0608,X
        bmi     L6_AFDB
        cmp     $07B8,X
        bcs     L6_AFE0
        bcc     L6_B01F
L6_AFDB:
        cmp     $07B8,X
        bcs     L6_B01F
L6_AFE0:
        lda     #$66
        sta     $0548,X
        jsr     L7_C0EA
        and     #$3F
        adc     #$08
        sta     $07B8,X
        inc     $07A0,X
L6_AFF2:
        bne     L6_B01F
        jsr     L7_C12C
        bcc     L6_AFFC
        jmp     L6_9B17
L6_AFFC:
        dec     $07B8,X
        beq     L6_B00A
        jsr     L7_C090
        jsr     L7_C0CF
        jmp     L7_C0D2
L6_B00A:
        ldy     #$0E
        lda     $0530,X
        bpl     L6_B013
        ldy     #$0A
L6_B013:
        tya
        jsr     L7_C102
        inc     $07A0,X
        lda     #$1A
        sta     $0548,X
L6_B01F:
        jmp     L6_9F4F

; ---- UNCLAIMED (gap) $B022-$B025, 4 bytes
        .byte   $08,$02,$F8,$06

; ---- bank6.code_B026 (code) $B026-$B0D4, 175 bytes
L6_B026:
        lda     $0500,X
        bmi     L6_B058
        jsr     L7_C0A8
        jsr     L7_C162
        lda     #$60
        sta     $0548,X
        jsr     L7_C0F0
        ldy     #$F0
        lda     $0530,X
        bmi     L6_B042
        ldy     #$10
L6_B042:
        tya
        adc     $0530,X
        sta     $0680,X
        lda     #$03
        sta     $0560,X
        lda     #$01
        sta     $05D8,X
        lda     #$3C
        sta     $0788,X
L6_B058:
        jsr     L7_C009
        lda     #$40
        jsr     L7_C09F
        lda     #$07
        jsr     L6_9B09
        lda     #$0F
        and     $41
        bne     L6_B084
        jsr     L7_C108
        bcs     L6_B084
        lda     #$0C
        jsr     L7_C105
        lda     $0530,X
        cmp     $0530
        lda     #$00
        bcc     L6_B081
        lda     #$08
L6_B081:
        sta     $0788,Y
L6_B084:
        jmp     L6_9F4F
L6_B087:
        jsr     L6_BA51
        lda     $0500,X
        bmi     L6_B09A
        jsr     L7_C0AE
        jsr     L7_C0A2
        lda     #$31
        sta     $0548,X
L6_B09A:
        lda     #$20
        ldy     #$04
        jsr     L7_C0A5
        bcc     L6_B0B0
        jsr     L7_C108
        bcs     L6_B0B0
        lda     #$2B
        jsr     L7_C105
        jsr     L6_AA12
L6_B0B0:
        lda     $0650,X
        cmp     #$20
        bcs     L6_B0C2
        ldy     $0638,X
        lda     $B0D5,Y
        ldy     #$AA
        jsr     L6_AA21
L6_B0C2:
        jsr     L7_C0CF
        jsr     L7_C0D2
        lda     $0500,X
        bmi     L6_B0D4
        ldy     #$FF
        lda     #$45
        jmp     L6_AA21
L6_B0D4:
        rts

; ---- UNCLAIMED (gap) $B0D5-$B0D8, 4 bytes
        .byte   $39,$3D,$41,$3D

; ---- bank6.code_B0D9 (code) $B0D9-$B11A, 66 bytes
L6_B0D9:
        lda     $0500,X
        bmi     L6_B0EF
        jsr     L7_C0A8
        jsr     L7_C162
        jsr     L7_C0A2
        lda     #$01
        sta     $0560,X
        jsr     L6_AF39
L6_B0EF:
        lda     #$10
        jsr     L7_C09F
        lda     $0638,X
        cmp     #$02
        bne     L6_B105
        lda     $0650,X
        cmp     #$08
        bcs     L6_B105
        jsr     L7_C126
L6_B105:
        lda     #$08
L6_B107:
        ldy     #$04
        jsr     L7_C0A5
        lda     $B11B,Y
        sta     $0548,X
        lda     $B11F,Y
        jsr     L6_A1E7
L6_B118:
        jmp     L6_9F4F

; ---- UNCLAIMED (gap) $B11B-$B122, 8 bytes
        .byte   $54,$54,$55,$54,$00,$0A,$00,$0A

; ---- bank6.code_B123 (code) $B123-$B231, 271 bytes
L6_B123:
        lda     $0500,X
        bmi     L6_B148
        jsr     L7_C0A8
        jsr     L7_C162
        jsr     L7_C0A2
        lda     #$80
        sta     $0530,X
        lda     #$03
        sta     $05D8,X
        lda     #$54
        sta     $0548,X
        lda     #$00
        sta     $0560,X
        sta     $0668,X
L6_B148:
        lda     #$0A
        jsr     L7_C09C
        lda     #$0F
        and     $41
        bne     L6_B15B
        jsr     L7_C108
        bcs     L6_B15B
        jsr     L6_BF61
L6_B15B:
        lda     $05D8,X
        bpl     L6_B118
        lda     $0638,X
        cmp     #$02
        beq     L6_B118
        lda     #$18
        bne     L6_B107
L6_B16B:
        lda     $0500,X
        bmi     L6_B1B3
        jsr     L7_C0A8
        jsr     L7_C162
        lda     #$05
        sta     $0698,X
        lda     $0728,X
        beq     L6_B19B
        jsr     L7_C102
        lda     $0518,X
        sta     $0668,X
        lda     $0530,X
        sta     $0680,X
        lda     #$1E
        sta     $0788,X
        lda     #$00
        sta     $07A0,X
        beq     L6_B1A6
L6_B19B:
        jsr     L7_C0F3
        lda     #$18
        sta     $0788,X
        sta     $07A0,X
L6_B1A6:
        jsr     L7_C0A2
        lda     #$02
        sta     $0560,X
        lda     #$3C
        sta     $0548,X
L6_B1B3:
        lda     $07A0,X
        bne     L6_B1D5
        lda     $0788,X
        beq     L6_B1D5
        dec     $0788,X
        bne     L6_B1C8
        jsr     L7_C147
        jmp     L6_B1D5
L6_B1C8:
        lda     #$0C
        jsr     L7_C09C
        lda     #$0C
        jsr     L7_C09F
        jmp     L6_B224
L6_B1D5:
        jsr     L7_C009
        lda     #$08
        ldy     #$04
        jsr     L7_C0A5
        lda     $B232,Y
        sta     $0560,X
        bcc     L6_B214
        jsr     L7_C0FF
        and     #$0E
        ora     #$80
        sta     $15
        lda     #$07
        sta     $14
L6_B1F4:
        jsr     L7_C108
        bcs     L6_B210
L6_B1F9:
        lda     #$6F
        jsr     L7_C105
        lda     $15
        sta     $0728,Y
        dec     $15
        dec     $15
        dec     $14
        beq     L6_B210
        bpl     L6_B1F4
        jmp     L7_C048
L6_B210:
        txa
        tay
        bne     L6_B1F9
L6_B214:
        cmp     #$02
        bne     L6_B224
        lda     $41
        and     #$07
        bne     L6_B224
        jsr     L6_A325
        jsr     L6_A337
L6_B224:
        lda     $41
        and     #$04
        lsr     A
        lsr     A
        adc     #$3B
        sta     $0548,X
        jmp     L6_9F4F

; ---- UNCLAIMED (gap) $B232-$B235, 4 bytes
        .byte   $02,$02,$01,$00

; ---- bank6.code_B236 (code) $B236-$B453, 542 bytes
L6_B236:
        lda     $0500,X
        bmi     L6_B25C
        jsr     L7_C0A8
        jsr     L7_C0EA
        and     #$3F
        adc     #$50
        sta     $0530,X
        lda     #$60
        sta     $0518,X
        lda     #$03
        sta     $0560,X
        lda     #$50
        sta     $0548,X
        lda     #$3C
        sta     $0788,X
L6_B25C:
        jsr     L7_C009
        lda     #$03
        jsr     L6_9B09
        lda     #$0F
        and     $41
        bne     L6_B27C
        jsr     L7_C0FF
        sta     $15
        jsr     L7_C108
        bcs     L6_B27C
        jsr     L6_AC9F
        lda     #$F0
        jsr     L6_AECF
L6_B27C:
        lda     $41
        and     #$01
        bne     L6_B288
        jsr     L6_A325
        jsr     L6_A337
L6_B288:
        jmp     L6_9F4F
L6_B28B:
        lda     $0500,X
        bmi     L6_B2BA
        jsr     L7_C0A8
        jsr     L7_C162
        ldy     #$20
        jsr     L6_AD9A
        beq     L6_B29F
        ldy     #$E0
L6_B29F:
        tya
        sta     $0530,X
        lda     #$40
        sta     $05C0,X
        lda     #$80
        sta     $0680,X
        lda     #$00
        sta     $0560,X
        jsr     L6_AEE8
        lda     #$73
        sta     $0548,X
L6_B2BA:
        lda     #$80
        jsr     L7_C09F
        jmp     L6_9F4F
L6_B2C2:
        lda     $0500,X
        bmi     L6_B2DD
        jsr     L7_C0A8
        jsr     L7_C162
        jsr     L7_C0F0
        lda     #$00
        sta     $0560,X
        jsr     L6_AEE8
        lda     #$FF
        sta     $0668,X
L6_B2DD:
        jsr     L6_A325
        lda     #$10
        jsr     L7_C09C
        ldy     #$74
        lda     $05D8,X
        bpl     L6_B2ED
        iny
L6_B2ED:
        tya
        sta     $0548,X
        lda     $0518,X
        cmp     #$A0
        bcc     L6_B315
        cpy     #$74
        bne     L6_B315
        lda     #$FC
        sta     $05D8,X
        jsr     L7_C108
        bcs     L6_B315
        lda     #$27
        jsr     L7_C105
        lda     #$07
        sta     $07A0,Y
        lda     #$0C
        sta     $0788,Y
L6_B315:
        jmp     L6_9F4F
L6_B318:
        lda     $0500,X
        bmi     L6_B33F
        jsr     L7_C0A8
        jsr     L7_C162
        lda     #$6C
        sta     $0548,X
        jsr     L6_AF39
        lda     #$00
        sta     $0560,X
        lda     #$5A
        sta     $07A0,X
        lda     #$01
        sta     $05D8,X
        lda     #$10
        sta     $07B8,X
L6_B33F:
        lda     #$10
        jsr     L7_C09F
        lda     $07A0,X
        beq     L6_B35B
        dec     $07A0,X
        bne     L6_B35B
        lda     $0680,X
        eor     #$F8
        sta     $0680,X
        lda     #$FF
        sta     $05D8,X
L6_B35B:
        dec     $07B8,X
        bne     L6_B38D
        lda     #$10
        sta     $07B8,X
        jsr     L7_C108
        bcs     L6_B38D
        lda     #$02
        sta     $16
        lda     $07E8,X
        adc     #$14
        sta     $17
        jsr     L7_C13E
        lda     #$09
        jsr     L7_C13B
        lda     #$FF
        sta     $0668,Y
        lda     $05A8,X
        sta     $05A8,Y
        lda     #$06
        sta     $0590,X
L6_B38D:
        jmp     L6_9F4F
L6_B390:
        lda     $0500,X
        bmi     L6_B3B0
        jsr     L7_C0A8
        jsr     L7_C162
        jsr     L7_C0F3
        lda     #$00
        sta     $0560,X
        jsr     L6_AEE8
        lda     #$50
        sta     $0548,X
        lda     #$3C
        sta     $0788,X
L6_B3B0:
        jsr     L7_C009
        lda     #$07
        jsr     L6_9B09
        lda     $41
        and     #$03
        bne     L6_B3C4
        jsr     L6_A337
        jsr     L6_A325
L6_B3C4:
        jmp     L6_9F4F
L6_B3C7:
        jsr     L6_BA51
        lda     $0500,X
        bmi     L6_B3E8
        jsr     L7_C0AE
        lda     #$00
        sta     $07A0,X
        sta     $15
        lda     #$FE
        sta     $14
        jsr     L6_BBA3
        lda     #$31
        sta     $0548,X
        jsr     L7_C0A2
L6_B3E8:
        lda     $0518,X
        cmp     #$10
        bcs     L6_B3F0
        rts
L6_B3F0:
        lda     $07A0,X
        bne     L6_B3FF
        inc     $07A0,X
        ldy     #$55
        lda     #$49
        jsr     L6_AA21
L6_B3FF:
        lda     #$10
        ldy     #$02
        jsr     L7_C0A5
        bcs     L6_B415
        lda     $0650,X
        cmp     #$10
        bcs     L6_B41C
        lda     #$B4
        ldy     #$60
        bcc     L6_B419
L6_B415:
        lda     #$B4
        ldy     #$58
L6_B419:
        jsr     L6_B43F
L6_B41C:
        lda     $0638,X
        beq     L6_B42F
        lda     $41
        and     #$07
        bne     L6_B42F
        jsr     L7_C108
        bcs     L6_B42F
        jsr     L6_BF61
L6_B42F:
        jsr     L7_C0CF
        jsr     L7_C0D2
        lda     $0500,X
        bpl     L6_B43B
        rts
L6_B43B:
        lda     #$B4
        ldy     #$54
L6_B43F:
        sta     $17
        sty     $16
        lda     #$02
        sta     $15
        lda     #$04
L6_B449:
        sta     $14
        jsr     L6_BF71
        ldy     $0518,X
        jmp     L7_C07E

; ---- UNCLAIMED (gap) $B454-$B477, 36 bytes
        .byte   $FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$E0,$E1,$F0,$F1,$FD,$FD,$B0,$B1
        .byte   $C0,$C1,$D0,$D1,$72,$8C,$73,$8D,$74,$8E,$75,$8F,$68,$82,$6B,$85
        .byte   $6E,$88,$71,$8B

; ---- bank6.code_B478 (code) $B478-$B60E, 407 bytes
L6_B478:
        lda     $0500,X
        bpl     L6_B482
        lda     $07A0,X
        bne     L6_B4D5
L6_B482:
        jsr     L6_BA51
        lda     $0500,X
        bmi     L6_B4B0
        jsr     L7_C0A8
        jsr     L7_C0A2
        lda     #$19
        sta     $0548,X
        lda     $0518,X
        clc
        adc     #$04
        sta     $0518,X
        lda     #$00
        sta     $0560,X
        sta     $07A0,X
        jsr     L7_C0EA
        and     #$7F
        adc     #$30
        sta     $0788,X
L6_B4B0:
        lda     $0518,X
        cmp     $0788,X
        bcc     L6_B4C9
        inc     $07A0,X
        inc     $0560,X
        lda     #$05
        sta     $0698,X
        jsr     L7_C0FC
        jmp     L6_B4D5
L6_B4C9:
        jsr     L6_B4DB
        jsr     L7_C090
        jsr     L7_C0CF
        jmp     L7_C0D2
L6_B4D5:
        jsr     L6_B4DB
        jmp     L6_9F4F
L6_B4DB:
        lda     #$40
        ldy     #$03
        jsr     L7_C0A5
        lda     $0560,X
        and     #$03
        ora     $B9FB,Y
        sta     $0560,X
        rts
L6_B4EE:
        lda     $0500,X
        bmi     L6_B505
        lda     $05D8,X
        bne     L6_B505
        jsr     L7_C0F0
        lda     #$01
        sta     $05D8,X
        sta     $07A0,X
        bne     L6_B51B
L6_B505:
        jsr     L6_BA51
        lda     $0500,X
        bmi     L6_B52E
        lda     $0530,X
        clc
        adc     #$07
        sta     $0530,X
        lda     #$00
        sta     $07A0,X
L6_B51B:
        jsr     L7_C0A8
        jsr     L7_C162
        lda     #$21
        sta     $0548,X
        lda     #$00
        sta     $0560,X
        jsr     L6_AEE8
L6_B52E:
        lda     $07A0,X
        bne     L6_B539
        jsr     L7_C090
        jmp     L6_B53C
L6_B539:
        jsr     L7_C08D
L6_B53C:
        lda     $0518,X
        cmp     #$30
        bcc     L6_B58D
        sbc     $0518
        bcs     L6_B54C
        cmp     #$B0
        bcc     L6_B58D
L6_B54C:
        lda     #$40
        jsr     L7_C030
        jsr     L7_C0FF
        sta     $15
        lda     #$0F
        sta     $14
L6_B55A:
        jsr     L7_C108
        bcc     L6_B565
L6_B55F:
        txa
        tay
        lda     #$00
        sta     $14
L6_B565:
        lda     #$5F
        jsr     L7_C105
        lda     $0560,X
        sta     $0560,Y
        lda     #$41
        sta     $0698,Y
        lda     $15
        sta     $0788,Y
        lda     #$00
        sta     $07A0,Y
        lda     #$20
        sta     $07D0,Y
        dec     $15
        dec     $14
        beq     L6_B55F
        bpl     L6_B55A
        rts
L6_B58D:
        jsr     L7_C0CF
        jmp     L7_C0D2
L6_B593:
        jsr     L6_BA51
        lda     $0500,X
        bmi     L6_B5A6
        jsr     L7_C0AE
        jsr     L7_C0A2
        lda     #$21
        sta     $0548,X
L6_B5A6:
        txa
        ldy     #$02
        jsr     L7_C0A5
        bcs     L6_B5BF
        lda     $0650,X
        cmp     #$10
        bcs     L6_B5E3
        lda     #$B4
        ldy     #$68
        jsr     L6_B43F
        jmp     L6_B5C6
L6_B5BF:
        lda     #$B4
        ldy     #$70
        jsr     L6_B43F
L6_B5C6:
        lda     $0638,X
        asl     A
        asl     A
        adc     #$0A
        sta     $15
        jsr     L7_C108
        bcs     L6_B5E3
        lda     #$27
        jsr     L7_C105
        lda     #$07
        sta     $07A0,Y
        lda     $15
        sta     $0788,Y
L6_B5E3:
        jsr     L7_C0CF
        jsr     L7_C0D2
        lda     $0500,X
        bpl     L6_B5EF
        rts
L6_B5EF:
        lda     #$FE
        sta     $15
        sta     $14
        jsr     L6_BF71
        jsr     L7_C081
        lda     #$06
        sta     $15
        sta     $14
        lda     #$B6
        sta     $17
        lda     #$0F
        sta     $16
        ldy     $0518,X
        jmp     L7_C07E

; ---- UNCLAIMED (gap) $B60F-$B632, 36 bytes
        .byte   $FD,$76,$97,$97,$90,$FD,$77,$96,$96,$96,$96,$91,$97,$96,$96,$96
        .byte   $96,$97,$97,$96,$96,$96,$96,$97,$78,$96,$96,$96,$96,$92,$FD,$79
        .byte   $97,$97,$93,$FD

; ---- bank6.code_B633 (code) $B633-$B79C, 362 bytes
L6_B633:
        lda     $0500,X
        bmi     L6_B658
        jsr     L7_C0A8
        jsr     L7_C162
        jsr     L7_C0F3
        lda     #$19
        sta     $0548,X
        lda     #$01
        sta     $0560,X
        lda     #$81
        sta     $0698,X
        jsr     L7_C0FC
        lda     #$5A
        sta     $0788,X
L6_B658:
        jsr     L7_C009
        lda     $41
        and     #$03
        sta     $0560,X
        jmp     L6_9F4F
L6_B665:
        lda     $0500,X
        bmi     L6_B68F
        jsr     L7_C0A8
        jsr     L7_C162
        jsr     L7_C0F3
        lda     #$19
        sta     $0548,X
        lda     #$02
        sta     $0560,X
        sta     $0668,X
        lda     #$FF
        sta     $0680,X
        lda     #$03
        sta     $0698,X
        lda     #$5A
        sta     $0788,X
L6_B68F:
        jsr     L7_C009
        lda     #$18
        jsr     L7_C144
        jmp     L6_9F4F
L6_B69A:
        lda     $0500,X
        bmi     L6_B6D7
        jsr     L7_C0A8
        jsr     L7_C162
        lda     #$02
        sta     $0560,X
        lda     #$19
        sta     $0548,X
        lda     #$01
        sta     $0698,X
        lda     $0728,X
        bne     L6_B6C5
        jsr     L7_C0F3
        lda     #$3C
        sta     $0788,X
        lda     #$01
        bne     L6_B6D4
L6_B6C5:
        jsr     L7_C0EA
        and     #$03
        sta     $0560,X
        lda     #$00
        sta     $0788,X
        lda     #$1E
L6_B6D4:
        sta     $07A0,X
L6_B6D7:
        jsr     L7_C009
        dec     $07A0,X
        bne     L6_B6EC
        lda     #$1E
        sta     $07A0,X
        jsr     L7_C0EA
        and     #$0C
        jsr     L7_C102
L6_B6EC:
        lda     $41
        and     #$3F
        bne     L6_B6FF
        jsr     L7_C108
        bcs     L6_B6FF
        lda     #$72
        sta     $0728,Y
        jsr     L7_C105
L6_B6FF:
        jsr     L7_C08D
        bcc     L6_B707
        jmp     L6_9B17
L6_B707:
        jsr     L7_C0C6
        bcs     L6_B70D
        rts
L6_B70D:
        ldy     $6E
        bne     L6_B714
        jmp     L7_C0D8
L6_B714:
        jmp     L7_C168
L6_B717:
        jsr     L6_BA51
        lda     $0500,X
        bmi     L6_B72E
        jsr     L7_C0AE
        jsr     L7_C0A2
        lda     $0530,X
        clc
        adc     #$08
        sta     $0530,X
L6_B72E:
        lda     #$20
        ldy     #$04
        jsr     L7_C0A5
        lda     $0650,X
        cmp     #$20
        bcs     L6_B74B
        tya
        cmp     #$03
        bne     L6_B743
        lda     #$01
L6_B743:
        jsr     L6_B787
        lda     #$41
        jsr     L7_C030
L6_B74B:
        lda     $0638,X
        beq     L6_B779
        lda     $41
        and     #$05
        bne     L6_B779
        jsr     L7_C108
        bcs     L6_B779
        lda     #$5F
        jsr     L7_C105
        lda     #$03
        sta     $0560,Y
        lda     #$02
        sta     $07A0,Y
        lda     #$41
        sta     $0698,Y
        lda     $41
        sta     $0788,Y
        lda     #$18
        sta     $07D0,Y
L6_B779:
        jsr     L7_C0CF
        jsr     L7_C0D2
        lda     $0500,X
        bpl     L6_B785
        rts
L6_B785:
        lda     #$03
L6_B787:
        asl     A
        asl     A
        asl     A
        adc     #$9D
        sta     $16
        lda     #$00
        adc     #$B7
        sta     $17
        lda     #$04
        sta     $15
        lda     #$02
        jmp     L6_B449

; ---- UNCLAIMED (gap) $B79D-$B7BC, 32 bytes
        .byte   $20,$F8,$F9,$20,$20,$FA,$FB,$20,$90,$B0,$D0,$F0,$A0,$C0,$E0,$F1
        .byte   $B4,$B5,$B6,$B7,$C4,$C5,$C6,$C7,$20,$20,$20,$20,$20,$20,$20,$20

; ---- bank6.code_B7BD (code) $B7BD-$B838, 124 bytes
L6_B7BD:
        lda     $0500,X
        bmi     L6_B7C8
        jsr     L7_C0AE
        jsr     L7_C0A2
L6_B7C8:
        lda     #$20
        ldy     #$04
        jsr     L7_C0A5
        lda     $0650,X
        cmp     #$20
        bcc     L6_B7D7
L6_B7D6:
        rts
L6_B7D7:
        lda     #$11
        jsr     L7_C039
        bcs     L6_B7D6
        jsr     L7_C03C
        tay
        lda     #$0E
        sta     $0100,Y
        lda     #$1F
        sta     $0101,Y
        lda     #$D1
        sta     $0102,Y
        stx     $15
        lda     $0638,X
        sta     $14
        lda     #$00
        sta     $0109,Y
        sta     $010A,Y
        tax
        lda     $14
        and     #$02
        beq     L6_B809
        ldx     #$05
L6_B809:
        lda     $14
        beq     L6_B816
        cmp     #$03
        beq     L6_B816
        txa
        clc
        adc     #$0C
        tax
L6_B816:
        lda     #$06
        sta     $17
L6_B81A:
        lda     $B839,X
        sta     $0103,Y
        lda     $B83F,X
        sta     $010B,Y
        iny
        inx
        lda     $14
        and     #$02
        beq     L6_B830
        dex
        dex
L6_B830:
        dec     $17
        bne     L6_B81A
        ldx     $15
        jmp     L7_C03F

; ---- UNCLAIMED (gap) $B839-$B850, 24 bytes
        .byte   $0C,$36,$32,$4A,$66,$3C,$3C,$4E,$4A,$7A,$66,$3C,$30,$6C,$4C,$52
        .byte   $66,$3C,$3C,$72,$52,$5E,$66,$3C

; ---- bank6.code_B851 (code) $B851-$B901, 177 bytes
L6_B851:
        jsr     L6_BA51
        lda     $0500,X
        bmi     L6_B890
        jsr     L7_C0AE
        ldy     $0500,X
        lda     $A8BA,Y
        sta     $0548,X
        lda     $B804,Y
        sta     $07B8,X
        lda     #$01
        sta     $07A0,X
        cpy     #$FF
        beq     L6_B883
        lda     $70
        beq     L6_B890
        asl     $0590,X
        asl     $0590,X
        lsr     $07B8,X
        bpl     L6_B890
L6_B883:
        jsr     L6_A8C6
        lda     $70
        beq     L6_B890
        jsr     L7_C165
        lsr     $07B8,X
L6_B890:
        ldy     $0500,X
        dec     $07A0,X
        beq     L6_B89E
        cpy     #$FF
        beq     L6_B8E8
        bne     L6_B8BF
L6_B89E:
        jsr     L7_C0EA
        and     #$1F
        adc     $07B8,X
        sta     $07A0,X
        cpy     #$FF
        beq     L6_B8DB
        jsr     L7_C108
        bcs     L6_B8BF
        lda     #$27
        jsr     L7_C105
        jsr     L6_AA12
        lda     #$04
        sta     $07A0,Y
L6_B8BF:
        jsr     L7_C0CF
        jsr     L7_C0D2
        lda     $0500,X
        bmi     L6_B8DA
        lda     $0698,X
        cmp     #$31
        lda     #$35
        bcc     L6_B8D5
        lda     #$20
L6_B8D5:
        ldy     #$FF
        jmp     L6_AA21
L6_B8DA:
        rts
L6_B8DB:
        jsr     L7_C108
        bcs     L6_B8E8
        lda     #$4E
        jsr     L7_C105
        jsr     L6_AA12
L6_B8E8:
        jsr     L7_C0CF
        lda     $70
        bne     L6_B8F5
        jsr     L7_C0D2
        jmp     L6_B8F8
L6_B8F5:
        jsr     L7_C0D8
L6_B8F8:
        lda     $0500,X
        bmi     L6_B8DA
        lda     #$04
        jmp     L6_A991

; ---- UNCLAIMED (gap) $B902-$B903, 2 bytes
        .byte   $78,$64

; ---- bank6.code_B904 (code) $B904-$B961, 94 bytes
L6_B904:
        lda     $0500,X
        bmi     L6_B929
        jsr     L7_C0A8
        jsr     L7_C0A2
        lda     $0728,X
        bne     L6_B917
        jsr     L7_C0F0
L6_B917:
        lda     #$03
        sta     $0560,X
        lda     #$01
        sta     $0668,X
        sta     $0698,X
        lda     #$14
        sta     $0680,X
L6_B929:
        lda     #$3C
        jsr     L7_C144
        lda     #$40
        ldy     #$04
        jsr     L7_C0A5
        lda     $B962,Y
        sta     $15
        lda     $B966,Y
        sta     $14
        lda     $B96A,Y
        jsr     L6_A1D8
        jsr     L7_C08D
        jsr     L7_C0C6
        bcs     L6_B94E
        rts
L6_B94E:
        ldy     $6E
        bne     L6_B958
        lda     #$08
        sta     $0500,X
        rts
L6_B958:
        lda     #$0A
        sta     $0500,Y
        lda     #$41
        jmp     L7_C030

; ---- UNCLAIMED (gap) $B962-$B96D, 12 bytes
        .byte   $00,$02,$06,$02,$00,$00,$00,$40,$1A,$19,$1A,$19

; ---- bank6.code_B96E (code) $B96E-$B9FA, 141 bytes
L6_B96E:
        lda     $0500,X
        bmi     L6_B996
        jsr     L7_C0A8
        jsr     L7_C0A2
        jsr     L7_C0F3
        lda     #$03
        sta     $0560,X
        lda     #$1E
        sta     $0548,X
        lda     #$02
        sta     $0698,X
        jsr     L6_9A53
        beq     L6_B993
        jmp     L6_9B17
L6_B993:
        jmp     L6_9D26
L6_B996:
        jsr     L7_C009
        dec     $07A0,X
        bne     L6_B9A1
        jmp     L6_9D5F
L6_B9A1:
        jmp     L6_9D95
L6_B9A4:
        lda     $0500,X
        bmi     L6_B9D6
        jsr     L7_C0A2
        jsr     L7_C0F3
        jsr     L6_9A53
        beq     L6_B9B7
        jmp     L6_9B17
L6_B9B7:
        jsr     L7_C0A8
        jsr     L7_C162
        lda     #$19
        sta     $0548,X
        jsr     L6_9B0F
        lda     $9C0D,Y
        sta     $0560,X
        jsr     L6_AEE8
        lda     #$06
        sta     $0698,X
        jmp     L6_9B97
L6_B9D6:
        lda     $0680,X
        bne     L6_B9E5
        jsr     L6_A325
        jsr     L6_A337
        lda     #$00
        beq     L6_B9E7
L6_B9E5:
        lda     #$04
L6_B9E7:
        sta     $15
        lda     #$60
        ldy     #$04
        jsr     L7_C0A5
        lda     $B9FB,Y
        sta     $14
        jsr     L6_A1DB
        jmp     L6_9BA9

; ---- UNCLAIMED (gap) $B9FB-$B9FE, 4 bytes
        .byte   $00,$40,$C0,$80

; ---- bank6.code_B9FF (code) $B9FF-$BBBA, 444 bytes
L6_B9FF:
        jsr     L6_BA51
        lda     $0500,X
        bmi     L6_BA15
        jsr     L7_C0AE
        jsr     L7_C0A2
        inc     $0518,X
        lda     #$00
        sta     $0788,X
L6_BA15:
        lda     $0650,X
        cmp     #$80
        bcs     L6_BA43
        lda     $0638,X
        and     #$01
        bne     L6_BA43
        ldy     #$04
        lda     $0530,X
        bmi     L6_BA2C
        ldy     #$0C
L6_BA2C:
        sty     $15
        jsr     L7_C108
        bcs     L6_BA43
        lda     #$2B
        jsr     L7_C105
        lda     $0788,X
        inc     $0788,X
        adc     $15
        sta     $0788,Y
L6_BA43:
        lda     #$80
        jsr     L6_96AC
        jsr     L7_C090
        jsr     L7_C0CF
        jmp     L7_C0D2
L6_BA51:
        lda     $0500,X
        bmi     L6_BA5E
        jsr     L7_C12C
        bcc     L6_BA5D
        pla
        pla
L6_BA5D:
        rts
L6_BA5E:
        jsr     L7_C12C
        bcc     L6_BA5D
        pla
        pla
        jmp     L7_C048
L6_BA68:
        jsr     L6_BA51
        lda     $0500,X
        bmi     L6_BAA2
        lda     #$01
        sta     $0758,X
        lda     #$52
        jsr     L7_C0AB
        jsr     L7_C162
        lda     $0518,X
        clc
        adc     #$08
        sta     $0518,X
        lda     #$1A
        sta     $0548,X
        lda     #$20
        sta     $0560,X
        lda     #$00
        sta     $07B8,X
        ldy     $B9
        lda     $BBE3,Y
        sta     $07D0,X
        lda     #$14
        sta     $07A0,X
L6_BAA2:
        lda     $07B8,X
        beq     L6_BAAE
        cmp     #$02
        bcc     L6_BAD6
        jmp     L6_BB08
L6_BAAE:
        lda     #$40
        ldy     #$3C
        jsr     L6_BBEC
        bcc     L6_BAB8
L6_BAB7:
        rts
L6_BAB8:
        jsr     L6_BF71
        lda     #$02
        sta     $15
        lda     #$02
        sta     $14
        lda     #$BB
        sta     $16
        lda     #$BB
        sta     $17
        ldy     $0518,X
        jsr     L7_C07E
        lda     #$41
        jmp     L7_C030
L6_BAD6:
        lda     #$90
        ldy     #$01
        jsr     L6_BBEC
        bcc     L6_BAEA
        dec     $07A0,X
        bne     L6_BAB7
        inc     $07B8,X
        inc     $07A0,X
L6_BAEA:
        lda     #$FE
        sta     $15
        sta     $14
        jsr     L6_BBA3
        jsr     L6_BB80
        lda     #$02
        sta     $14
        lda     #$D7
        sta     $16
        lda     #$BB
        sta     $17
        ldy     $0518,X
        jmp     L7_C07E
L6_BB08:
        bne     L6_BB16
        lda     $0518,X
        cmp     #$B0
        bcc     L6_BB4F
        inc     $07B8,X
        bne     L6_BB1B
L6_BB16:
        dec     $0788,X
        bne     L6_BB4F
L6_BB1B:
        lda     $07D0,X
        beq     L6_BB4F
        dec     $07D0,X
        lda     #$04
        ldy     $B9
        cpy     #$02
        bcc     L6_BB2D
        lda     #$01
L6_BB2D:
        sta     $0788,X
        lda     $0518,X
        cmp     #$30
        bcs     L6_BB3C
        dec     $07B8,X
        bcc     L6_BB4F
L6_BB3C:
        sbc     #$08
        sta     $0518,X
        lda     #$00
        sta     $15
        lda     #$FF
        sta     $14
        jsr     L6_BBA3
        jsr     L6_BB84
L6_BB4F:
        dec     $07A0,X
        bne     L6_BB77
        lda     #$28
        sta     $07A0,X
        jsr     L7_C108
        bcs     L6_BB77
        lda     #$27
        jsr     L7_C105
        lda     #$04
        sta     $0788,Y
        lda     $5C
        cmp     #$21
        bne     L6_BB72
        lda     #$00
        beq     L6_BB74
L6_BB72:
        lda     #$03
L6_BB74:
        sta     $07A0,Y
L6_BB77:
        jsr     L7_C090
        jsr     L7_C0CF
        jmp     L7_C0D2
L6_BB80:
        lda     #$03
        bne     L6_BB86
L6_BB84:
        lda     #$04
L6_BB86:
        sta     $14
        lda     #$06
        sta     $15
        lda     #$BF
        sta     $16
        lda     #$BB
        sta     $17
        lda     $0518,X
        sec
        sbc     #$18
        tay
        jsr     L7_C07E
        lda     #$41
        jmp     L7_C030
L6_BBA3:
        jsr     L6_BF71
        ldy     $0608,X
        jsr     L7_C081
        lda     $18
        sta     $05C0,X
        lda     $19
        sta     $05D8,X
        tya
        sta     $0608,X
        rts

; ---- UNCLAIMED (gap) $BBBB-$BBEB, 49 bytes
        .byte   $A1,$A3,$AB,$AC,$80,$9D,$9E,$9E,$9F,$80,$9D,$A1,$A2,$A2,$A3,$9F
        .byte   $A5,$A6,$A7,$A8,$A8,$A9,$A5,$20,$20,$20,$20,$A9,$AA,$AB,$20,$20
        .byte   $AC,$AD,$80,$AA,$AE,$AE,$AD,$80,$64,$96,$C8,$FA,$FA,$FA,$FA,$FA
        .byte   $FA

; ---- bank6.code_BBEC (code) $BBEC-$BD08, 285 bytes
L6_BBEC:
        cmp     $0518,X
        bcs     L6_BBF8
        tya
        sta     $07A0,X
        inc     $07B8,X
L6_BBF8:
        rts
L6_BBF9:
        lda     $0500,X
        bpl     L6_BC08
        lda     $07B8,X
        cmp     #$04
        bcc     L6_BC08
        jmp     L6_BCD8
L6_BC08:
        jsr     L6_BA51
        lda     $0500,X
        bmi     L6_BC1D
        jsr     L7_C0AE
        lda     #$21
        sta     $0548,X
        lda     #$00
        sta     $07B8,X
L6_BC1D:
        lda     $07B8,X
        bne     L6_BC72
        ldy     #$10
        lda     $B9
        cmp     #$02
        bcc     L6_BC2C
        ldy     #$04
L6_BC2C:
        lda     #$30
        jsr     L6_BBEC
        bcc     L6_BC34
        rts
L6_BC34:
        lda     $07A0,X
        sta     $07D0,X
        lda     #$FF
        sta     $15
        lda     #$00
        sta     $14
        jsr     L6_BBA3
        lda     #$01
L6_BC47:
        sta     $14
        lda     #$04
        sta     $15
        lda     #$19
        sta     $16
        lda     #$BD
        sta     $17
        ldy     $0518,X
        jsr     L7_C07E
        lda     $07B8,X
        cmp     #$01
        bne     L6_BC97
        sta     $14
        lda     #$25
        sta     $16
        lda     #$BD
        sta     $17
        jsr     L7_C07E
        jmp     L6_BC97
L6_BC72:
        dec     $07A0,X
        bne     L6_BC97
        lda     $07D0,X
        sta     $07A0,X
        lda     $07B8,X
        inc     $07B8,X
        cmp     #$03
        beq     L6_BCB2
        lda     #$00
        sta     $15
        lda     #$FF
        sta     $14
        jsr     L6_BBA3
        lda     $07B8,X
        bne     L6_BC47
L6_BC97:
        lda     $07B8,X
        cmp     #$03
        bcc     L6_BCB1
        jsr     L7_C0CF
        jsr     L7_C0D2
        lda     $0500,X
        bmi     L6_BCB1
        lda     #$30
        sta     $0500,X
        jmp     L6_BCEA
L6_BCB1:
        rts
L6_BCB2:
        bne     L6_BCD8
        jsr     L6_BCEA
        inc     $07B8,X
        lda     #$71
        sta     $06C8,X
        lda     #$02
        sta     $0560,X
        lda     #$02
        sta     $0698,X
        jsr     L7_C0FF
        tay
        lda     $BD09,Y
        jsr     L7_C102
        lda     #$FF
        sta     $0668,X
L6_BCD8:
        lda     #$08
        jsr     L7_C09C
        lda     $05D8,X
        bmi     L6_BCE7
        lda     #$75
        sta     $06C8,X
L6_BCE7:
        jmp     L6_9F4F
L6_BCEA:
        jsr     L6_BF71
        lda     #$04
        sta     $15
        sta     $14
        lda     #$29
        sta     $16
        lda     #$BD
        sta     $17
        lda     $0518,X
        sec
        sbc     #$10
        bcs     L6_BD05
        lda     #$00
L6_BD05:
        tay
        jmp     L7_C07E

; ---- UNCLAIMED (gap) $BD09-$BD38, 48 bytes
        .byte   $0F,$0E,$0D,$0D,$0C,$0B,$0B,$0A,$09,$0A,$0B,$0B,$0C,$0D,$0E,$0E
        .byte   $B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7,$B8,$B9,$BA,$BB,$BC,$BD,$BE,$BF
        .byte   $80,$81,$80,$81,$81,$80,$81,$80,$80,$81,$80,$81,$81,$80,$81,$80

; ---- bank6.code_BD39 (code) $BD39-$BEAD, 373 bytes
L6_BD39:
        lda     $0500,X
        bpl     L6_BD43
        lda     $07B8,X
        bne     L6_BD8C
L6_BD43:
        jsr     L6_BA51
        lda     $0500,X
        bmi     L6_BD6E
        jsr     L7_C0AE
        lda     $0530,X
        clc
        adc     #$08
        sta     $0530,X
        lda     $0518,X
        adc     #$08
        sta     $0518,X
        lda     #$61
        sta     $06C8,X
        lda     #$8C
        sta     $0548,X
        lda     #$00
        sta     $07B8,X
L6_BD6E:
        lda     $0518
        sbc     #$60
        bcs     L6_BD77
        lda     #$00
L6_BD77:
        ldy     #$08
        jsr     L6_BBEC
        bcs     L6_BDAD
        jsr     L6_BCEA
        lda     #$02
        sta     $0560,X
        sta     $0698,X
        jsr     L7_C0FC
L6_BD8C:
        dec     $07A0,X
        bne     L6_BDAA
        lda     #$0F
        sta     $07A0,X
        jsr     L7_C0FF
        sta     $15
        jsr     L7_C108
        bcs     L6_BDAA
        lda     #$2B
        jsr     L7_C105
        lda     $15
        sta     $0788,Y
L6_BDAA:
        jmp     L6_9F4F
L6_BDAD:
        jsr     L7_C0CF
        jsr     L7_C0D2
        lda     $0500,X
        bmi     L6_BDBB
        jmp     L6_BCEA
L6_BDBB:
        rts
L6_BDBC:
        jsr     L6_BA51
        lda     $0500,X
        bmi     L6_BDE2
        jsr     L7_C0AE
        lda     #$2F
        sta     $0548,X
        lda     $0530,X
        clc
        adc     #$10
        sta     $0530,X
        lda     $0518,X
        adc     #$10
        sta     $0518,X
        lda     #$00
        sta     $07B8,X
L6_BDE2:
        lda     $0518,X
        cmp     #$30
        bcs     L6_BDEA
        rts
L6_BDEA:
        lda     $07B8,X
        bne     L6_BE25
        lda     #$40
        jsr     L6_BBEC
        bcs     L6_BE22
        lda     #$03
L6_BDF8:
        sta     $14
        lda     #$06
        sta     $15
        lda     #$B1
        sta     $16
        lda     #$BE
        sta     $17
        jsr     L6_BF71
        jsr     L6_BEA3
        lda     $07B8,X
        cmp     #$01
        bne     L6_BE22
        lda     #$01
        sta     $14
        lda     #$CF
        sta     $16
        lda     #$BE
        sta     $17
        jsr     L7_C07E
L6_BE22:
        jmp     L6_BE76
L6_BE25:
        cmp     #$01
        bne     L6_BE41
        lda     #$48
        ldy     #$01
        jsr     L6_BBEC
        bcs     L6_BE22
        lda     #$00
        sta     $15
        lda     #$FE
        sta     $14
        jsr     L6_BBA3
        lda     #$05
        bne     L6_BDF8
L6_BE41:
        dec     $07A0,X
        bne     L6_BE76
        lda     #$1E
        sta     $07A0,X
        jsr     L7_C0FF
        sta     $15
        lda     #$02
        sta     $14
L6_BE54:
        ldy     $14
        lda     $BEAE,Y
        clc
        adc     $15
        sta     $17
        jsr     L7_C108
        bcs     L6_BE76
        lda     #$17
        jsr     L7_C105
        lda     #$03
        sta     $0698,Y
        lda     $17
        sta     $0788,Y
        dec     $14
        bpl     L6_BE54
L6_BE76:
        jsr     L7_C0CF
        jsr     L7_C0D2
        lda     $0500,X
        bmi     L6_BEAD
        lda     #$00
        sta     $15
        sta     $14
        lda     $07B8,X
        cmp     #$02
        beq     L6_BE92
        lda     #$FE
        sta     $14
L6_BE92:
        jsr     L6_BBA3
        lda     #$06
        sta     $15
        sta     $14
        lda     #$D5
        sta     $16
        lda     #$BE
        sta     $17
L6_BEA3:
        lda     $0518,X
        sec
        sbc     #$20
        tay
        jmp     L7_C07E
L6_BEAD:
        rts

; ---- UNCLAIMED (gap) $BEAE-$BEF8, 75 bytes
        .byte   $02,$FE,$00,$80,$C0,$C1,$C2,$C3,$80,$C4,$C5,$C6,$C7,$C8,$C9,$CA
        .byte   $CB,$CC,$CD,$CE,$CF,$D0,$D1,$20,$20,$D2,$D3,$D4,$20,$20,$20,$20
        .byte   $D5,$D6,$D7,$20,$20,$D8,$D9,$80,$81,$80,$81,$80,$81,$81,$80,$81
        .byte   $80,$81,$80,$80,$80,$F2,$F3,$F4,$80,$F5,$F6,$F7,$F8,$F9,$FA,$FB
        .byte   $20,$20,$20,$20,$CF,$D6,$D7,$20,$20,$D8,$D9

; ---- bank6.code_BEF9 (code) $BEF9-$BFD0, 216 bytes
L6_BEF9:
        lda     $0500,X
        bmi     L6_BF30
        jsr     L7_C0AE
        jsr     L7_C0F0
        ldy     #$01
        lda     #$80
        sta     $05F0,X
        cmp     $0530,X
        bcs     L6_BF12
        ldy     #$FF
L6_BF12:
        tya
        sta     $0608,X
        lda     #$61
        sta     $06C8,X
        lda     #$00
        sta     $0560,X
        sta     $0668,X
        lda     #$8C
        sta     $0548,X
        lda     #$04
        sta     $05D8,X
        sta     $07A0,X
L6_BF30:
        lda     #$0C
        jsr     L7_C09C
        dec     $07A0,X
        bne     L6_BF5E
        lda     #$0A
        sta     $07A0,X
        jsr     L7_C108
        bcs     L6_BF5E
        jsr     L6_BF61
        lda     #$3A
        sta     $0728,Y
        sta     $07B8,Y
        lda     #$03
        sta     $0560,Y
        lda     #$1A
        sta     $0548,Y
        lda     #$0C
        sta     $07A0,Y
L6_BF5E:
        jmp     L6_9F4F
L6_BF61:
        lda     #$2A
        jsr     L7_C105
        jsr     L7_C0EA
        and     #$03
        adc     #$FE
        sta     $0788,Y
        rts
L6_BF71:
        lda     $05C0,X
        sta     $18
        lda     $05D8,X
        sta     $19
        rts
L6_BF7C:
        lda     $0500,X
        bmi     L6_BFA5
        jsr     L7_C0A8
        lda     #$01
        sta     $0560,X
        lda     #$50
        sta     $0548,X
L6_BF8E:
        jsr     L7_C0F0
        lda     #$20
        sta     $0518,X
        lda     #$06
        sta     $07A0,X
        lda     #$03
        sta     $05D8,X
        lda     #$1E
        sta     $0788,X
L6_BFA5:
        jsr     L7_C009
        dec     $07A0,X
        bne     L6_BFC1
        lda     #$08
        sta     $07A0,X
        jsr     L7_C108
        bcs     L6_BFC1
        lda     #$0F
        jsr     L7_C105
        lda     #$FF
        sta     $0728,Y
L6_BFC1:
        lda     #$07
        jsr     L6_9B09
        jsr     L7_C08D
        bcs     L6_BF8E
        jsr     L7_C0C6
        jmp     L7_C0D5

; ---- UNCLAIMED (gap) $BFD1-$BFFE, 46 bytes
        .fill   46,$FF

; ---- bank6.bank_id_BFFF (data) $BFFF-$BFFF, 1 bytes
; Bank 6 identity byte
        .byte   $06
