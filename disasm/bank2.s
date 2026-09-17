; PRG bank 2 - not yet established
; $8000-$BFFF
; The switchable window. Every address below exists in seven banks; only this
; one has these bytes at it, which is what the L2_ label prefix records.
.org $8000


; ---- bank2.code_8000 (code) $8000-$8023, 36 bytes
L2_8000:
        jmp     L2_80BB
L2_8003:
        jmp     L2_81B2
L2_8006:
        jmp     L2_8212
L2_8009:
        jmp     L2_82C0
L2_800C:
        jmp     L2_8153
L2_800F:
        jmp     L2_84CB
L2_8012:
        jmp     L2_8158
L2_8015:
        jmp     L2_86BC
L2_8018:
        jmp     L2_8820
L2_801B:
        jmp     L2_8836
L2_801E:
        jmp     L2_8998
L2_8021:
        jmp     L2_8A69

; ---- UNCLAIMED (gap) $8024-$806B, 72 bytes
        .byte   $F8,$8B,$AC,$93,$8B,$95,$9F,$95,$84,$96,$04,$9D,$FC,$A4,$C9,$A5
        .byte   $41,$A6,$44,$A7,$94,$A6,$01,$A7,$2D,$A7,$00,$00,$00,$00,$6C,$80
        .byte   $B5,$A8,$A2,$AB,$F0,$AD,$A4,$AF,$8F,$B3,$C4,$BA,$E3,$BD,$E3,$BD
        .byte   $E3,$BD,$17,$B7,$67,$BE,$A4,$BE,$01,$BF,$45,$BF,$45,$BF,$52,$BF
        .byte   $5F,$BF,$83,$BF,$A7,$BF,$CB,$BF

; ---- bank2.code_806C (code) $806C-$80EB, 128 bytes
L2_806C:
        lda     #$13
        jsr     L7_C04B
        jsr     L7_C03C
        stx     $12
        tax
        lda     #$10
        sta     $0100,X
        lda     $19
        sta     $0101,X
        lda     $18
        sta     $0102,X
        ldy     #$00
L2_8088:
        lda     ($1A),Y
        sta     $0103,X
        lda     #$00
        sta     $010B,X
        inx
        iny
        cpy     #$08
        bne     L2_8088
        sta     $0102,X
        ldx     $12
        lda     $18
        clc
        adc     #$10
        sta     $18
        bcc     L2_80A8
        inc     $19
L2_80A8:
        lda     $1A
        clc
        adc     #$07
        sta     $1A
        bcc     L2_80B3
        inc     $1B
L2_80B3:
        jsr     L7_C03F
        dec     $15
        bne     L2_806C
        rts
L2_80BB:
        ldy     #$00
L2_80BD:
        jsr     L2_80C5
        cmp     #$FF
        bne     L2_80BD
        rts
L2_80C5:
        lda     $80EC,Y
        cmp     #$FF
        beq     L2_80EB
        sta     $15
        lda     $80ED,Y
        sta     $18
        lda     $80EE,Y
        sta     $19
        lda     $80EF,Y
        sta     $1A
        lda     $80F0,Y
        sta     $1B
        tya
        adc     #$05
        pha
        jsr     L2_806C
        pla
        tay
L2_80EB:
        rts

; ---- UNCLAIMED (gap) $80EC-$8152, 103 bytes
        .byte   $01,$B0,$15,$5A,$8C,$0A,$00,$13,$F8,$8B,$1B,$00,$14,$68,$8C,$01
        .byte   $C0,$15,$4C,$8C,$01,$D0,$15,$53,$8C,$01,$E0,$15,$2C,$8D,$FF,$01
        .byte   $80,$10,$4F,$8D,$01,$90,$10,$6B,$8D,$01,$A0,$10,$3E,$8C,$01,$B0
        .byte   $10,$3D,$8D,$01,$C0,$10,$72,$8D,$01,$D0,$10,$87,$8D,$01,$E0,$10
        .byte   $B1,$8D,$01,$F0,$10,$D4,$8D,$FF,$01,$E0,$1A,$41,$8D,$01,$00,$10
        .byte   $25,$8D,$1B,$00,$18,$48,$8D,$01,$B0,$19,$33,$8D,$01,$C0,$19,$61
        .byte   $8C,$01,$00,$13,$05,$8E,$FF

; ---- bank2.code_8153 (code) $8153-$8291, 319 bytes
L2_8153:
        ldy     #$1F
        jmp     L2_80BD
L2_8158:
        ldy     #$48
        jmp     L2_80BD
L2_815D:
        pha
        lda     #$0A
        jsr     L7_C04B
        jsr     L7_C03C
        stx     $12
        tax
        lda     #$07
        sta     $0100,X
        lda     $19
        sta     $0101,X
        lda     $18
        sta     $0102,X
        lda     #$00
        sta     $11
        pla
        tay
        sec
        sbc     #$30
        sta     $10
        asl     A
        rol     $11
        adc     $10
        bcc     L2_818C
        inc     $11
L2_818C:
        asl     A
        rol     $11
        adc     $10
        bcc     L2_8195
        inc     $11
L2_8195:
        clc
        adc     #$F8
        sta     $10
        lda     $11
        adc     #$8B
        sta     $11
        ldy     #$00
L2_81A2:
        lda     ($10),Y
        sta     $0103,X
        inx
        iny
        cpy     #$07
        bne     L2_81A2
        ldx     $12
        jmp     L7_C03F
L2_81B2:
        asl     A
        asl     A
        asl     A
        sta     $10
        lda     #$00
        asl     $10
        rol     A
        asl     $10
        rol     A
        asl     $10
        rol     A
        sta     $11
        lda     #$0C
        adc     $10
        sta     $16
        lda     #$8E
        adc     $11
        sta     $17
        ldy     #$00
L2_81D2:
        lda     #$23
        jsr     L7_C04B
        jsr     L7_C03C
        stx     $10
        tax
        lda     #$20
        sta     $0100,X
        lda     $19
        sta     $0101,X
        lda     $18
        sta     $0102,X
L2_81EC:
        lda     ($16),Y
        sta     $0103,X
        inx
        iny
        cpy     #$40
        beq     L2_820D
        cpy     #$20
        bne     L2_81EC
        ldx     $10
        jsr     L7_C03F
        lda     $18
        clc
        adc     #$20
        sta     $18
        bcc     L2_81D2
        inc     $19
        bcs     L2_81D2
L2_820D:
        ldx     $10
        jmp     L7_C03F
L2_8212:
        asl     A
        asl     A
        asl     A
        asl     A
        asl     A
        adc     #$AC
        sta     $16
        lda     #$92
        adc     #$00
        sta     $17
        ldy     #$00
L2_8223:
        lda     #$23
        jsr     L7_C04B
        jsr     L7_C03C
        stx     $10
        tax
        lda     #$20
        sta     $0100,X
        lda     $19
        sta     $0101,X
        lda     $18
        sta     $0102,X
L2_823D:
        lda     ($16),Y
        sta     $0103,X
        lda     $928C,Y
        sta     $010B,X
        sty     $15
        tya
        clc
        adc     #$08
        tay
        lda     ($16),Y
        sta     $0113,X
        ldy     $15
        lda     $9294,Y
        sta     $011B,X
        inx
        iny
        cpy     #$18
        beq     L2_827A
        cpy     #$08
        bne     L2_823D
        ldx     $10
        jsr     L7_C03F
        ldy     #$10
        lda     $18
        clc
        adc     #$20
        sta     $18
        bcc     L2_8223
        inc     $19
        bcs     L2_8223
L2_827A:
        ldx     $10
        jmp     L7_C03F
L2_827F:
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
L2_8291:
        rts

; ---- UNCLAIMED (gap) $8292-$82BF, 46 bytes
        .byte   $0D,$0D,$08,$0C,$0C,$0D,$0D,$0C,$0B,$09,$0B,$04,$04,$09,$09,$04
        .byte   $0C,$0B,$11,$08,$08,$0B,$0B,$08,$04,$04,$04,$02,$02,$04,$04,$02
        .byte   $A0,$B0,$7C,$00,$00,$A0,$A0,$7C,$68,$7C,$00,$00,$68,$68

; ---- bank2.code_82C0 (code) $82C0-$8344, 133 bytes
L2_82C0:
        lda     $0788,X
        bpl     L2_82C8
        jmp     L2_8375
L2_82C8:
        pha
        bne     L2_82DC
        sta     $0638,X
        ldy     $51
        lda     $8291,Y
        sta     $0680,X
        lda     $8299,Y
        sta     $0668,X
L2_82DC:
        pla
        cmp     #$70
        bcs     L2_8328
        sta     $14
        cmp     #$10
        bcs     L2_82F7
        lda     #$4C
        jsr     L7_C039
        bcs     L2_8291
        jsr     L2_83BE
        lda     #$10
        sta     $0788,X
L2_82F6:
        rts
L2_82F7:
        clc
        adc     #$50
        jsr     L2_827F
        lda     #$8D
        sta     $1B
        lda     #$3D
        sta     $1A
        lda     #$01
        sta     $15
        jsr     L2_806C
        inc     $0788,X
        lda     $0788,X
        cmp     #$30
        bcs     L2_8322
        lda     #$13
        jsr     L7_C039
        bcs     L2_82F6
        lda     $0788,X
        bcc     L2_82F7
L2_8322:
        lda     #$70
        sta     $0788,X
        rts
L2_8328:
        sbc     #$70
        sta     $10
        asl     A
        asl     A
        adc     $10
        adc     #$1F
        tay
        inc     $0788,X
        jsr     L2_80C5
        cmp     #$FF
        bne     L2_82F6
        lda     #$80
        sta     $0788,X
        jsr     L7_C006

; ---- bank2.inline_8345 (data) $8345-$8347, 3 bytes
; Far-call argument at $8345
        .byte   $05,$0B,$80

; ---- bank2.code_8348 (code) $8348-$83F5, 174 bytes
L2_8348:
        lda     #$60
        sta     $0650,X
L2_834D:
        rts
L2_834E:
        lda     $51
        cmp     #$03
        bne     L2_834D
        lda     $F7
        and     #$20
        beq     L2_834D
        lda     $F5
        and     #$C0
        beq     L2_834D
        lda     #$34
        sta     $0500,X
        inc     $0620,X
        lda     $0620,X
        cmp     #$15
        bcc     L2_8371
        lda     #$00
L2_8371:
        sta     $0788,X
        rts
L2_8375:
        cmp     #$80
        beq     L2_83F3
        cmp     #$83
        beq     L2_834E
        cmp     #$81
        bne     L2_83AC
        lda     $F5
        ora     $F6
        and     #$40
        bne     L2_83A9
        lda     $41
        and     #$10
        bne     L2_83A8
        ldy     $51
        lda     $82B1,Y
        sta     $85
        lda     $82B8,Y
        sta     $84
        lda     #$00
        sta     $86
        lda     #$0B
        sta     $87
        lda     #$37
        jmp     L7_C093
L2_83A8:
        rts
L2_83A9:
        inc     $0788,X
L2_83AC:
        lda     #$50
        jsr     L7_C039
        bcs     L2_83F2
        jsr     L2_83BE
        lda     #$80
        sta     $0788,X
        jmp     L2_8348
L2_83BE:
        lda     $0680,X
        sta     $0608,X
        lda     $0668,X
        sta     $05F0,X
        jsr     L2_84B1
        jsr     L2_84A5
        lda     #$20
        sta     $14
        ldy     $51
        lda     $82A1,Y
        sta     $15
        lda     $82A9,Y
        sta     $17
L2_83E0:
        jsr     L7_C036
        lda     $18
        clc
        adc     #$20
        sta     $18
        bcc     L2_83EE
        inc     $19
L2_83EE:
        dec     $17
        bne     L2_83E0
L2_83F2:
        rts
L2_83F3:
        jsr     L7_C006

; ---- bank2.inline_83F6 (data) $83F6-$83F8, 3 bytes
; Far-call argument at $83F6
        .byte   $05,$0E,$80

; ---- bank2.code_83F9 (code) $83F9-$841C, 36 bytes
        lda     $15
        bne     L2_8403
        lda     #$83
        sta     $0788,X
        rts
L2_8403:
        cmp     #$01
        bne     L2_840D
        lda     #$81
        sta     $0788,X
        rts
L2_840D:
        cmp     #$0D
        bne     L2_8429
        lda     $0680,X
        sta     $0608,X
        inc     $05F0,X
        jmp     L2_83F3

; ---- UNCLAIMED (gap) $841D-$8428, 12 bytes
        .byte   $61,$65,$66,$69,$6F,$74,$08,$09,$0C,$0D,$0E,$0F

; ---- bank2.code_8429 (code) $8429-$8587, 351 bytes
L2_8429:
        ldy     #$05
L2_842B:
        cmp     $841D,Y
        bne     L2_8437
        lda     $8423,Y
        sta     $15
        bne     L2_844E
L2_8437:
        dey
        bpl     L2_842B
        cmp     #$5C
        bcs     L2_8462
        cmp     #$40
        bcs     L2_844E
        cmp     #$3A
        bcs     L2_8462
        cmp     #$30
        bcs     L2_844E
        cmp     #$20
        beq     L2_844E
L2_844E:
        lda     #$04
        jsr     L7_C039
        bcc     L2_8459
L2_8455:
        dec     $0638,X
        rts
L2_8459:
        jsr     L2_8482
L2_845C:
        inc     $0608,X
        jmp     L2_83F3
L2_8462:
        lda     #$0E
        jsr     L7_C039
        bcs     L2_8455
        lda     $0650,X
        jsr     L2_827F
        lda     $15
        jsr     L2_815D
        lda     $0650,X
        sta     $15
        jsr     L2_8482
        inc     $0650,X
        jmp     L2_845C
L2_8482:
        lda     #$04
        jsr     L7_C03C
        tay
        lda     #$01
        sta     $0100,Y
        jsr     L2_84B1
        lda     $15
        sta     $0103,Y
        jsr     L2_84A5
        lda     $19
        sta     $0101,Y
        lda     $18
        sta     $0102,Y
        jmp     L7_C03F
L2_84A5:
        lda     $18
        sec
        sbc     #$20
        sta     $18
        bcs     L2_84B0
        dec     $19
L2_84B0:
        rts
L2_84B1:
        lda     #$08
        sta     $10
        lda     $05F0,X
        asl     A
        asl     A
        asl     A
        asl     A
        rol     $10
        asl     A
        rol     $10
        adc     $0608,X
        sta     $18
        lda     $10
        sta     $19
        rts
L2_84CB:
        lda     $0500,X
        bmi     L2_8543
        lda     #$00
        sta     $0668,X
        sta     $07B8,X
        lda     #$31
        sta     $0548,X
        cmp     $0500,X
        bne     L2_84F3
        inc     $07B8,X
        lda     $30
        and     #$60
        beq     L2_84EE
        inc     $07B8,X
L2_84EE:
        lda     $55
        sta     $0680,X
L2_84F3:
        lda     $0500,X
        cmp     #$33
        bne     L2_8521
        lda     #$00
        sta     $07A0,X
        jsr     L7_C0AE
        lda     $0770,X
        sta     $17
        lda     $0758,X
        sta     $16
        lda     $05C0,X
        clc
        adc     #$3F
        sta     $18
        lda     $05D8,X
        adc     #$00
        sta     $19
        jsr     L7_C04E
        jmp     L2_855E
L2_8521:
        lda     $56
        cmp     #$FF
        beq     L2_8532
        cmp     $0680,X
        beq     L2_8532
        jsr     L2_880C
        bcs     L2_8532
        rts
L2_8532:
        lda     $07B8,X
        cmp     #$02
        bne     L2_8540
        lda     #$B1
        sta     $0500,X
        bne     L2_855E
L2_8540:
        jsr     L7_C0AE
L2_8543:
        jsr     L7_C12C
        bcc     L2_854B
        jmp     L7_C048
L2_854B:
        lda     $0668,X
        beq     L2_8553
        jmp     L2_85DE
L2_8553:
        lda     $0590,X
        beq     L2_855E
        jsr     L7_C0CF
        jmp     L7_C0D2
L2_855E:
        inc     $0668,X
        lda     #$25
        sta     $0548,X
        jsr     L2_880C
        tay
        bcc     L2_858E
        jsr     L2_8579
        lda     #$00
        sta     $15
        lda     $8577,Y
        jmp     L2_8812
L2_8579:
        lda     $0530,X
        sta     $19
        lda     $0518,X
        sta     $18
        lda     #$00
        sta     $17
        rts

; ---- UNCLAIMED (gap) $8588-$858D, 6 bytes
        .byte   $0C,$0B,$01,$2C,$24,$28

; ---- bank2.code_858E (code) $858E-$8662, 213 bytes
L2_858E:
        lda     $0500,X
        cmp     #$B3
        bne     L2_85AF
        lda     #$01
        sta     $19
        lda     $0698,X
        asl     A
        rol     $19
        asl     A
        rol     $19
        asl     A
        rol     $19
        asl     A
        rol     $19
        sta     $18
        lda     $0680,X
        bcc     L2_85BC
L2_85AF:
        lda     #$15
        sta     $19
        lda     #$C0
        sta     $18
        lda     $0680,X
        sta     $56
L2_85BC:
        jsr     L2_81B2
        ldy     $07B8,X
        cpy     #$02
        beq     L2_85DE
        jsr     L2_8579
        lda     $0500,X
        cmp     #$B3
        bne     L2_85D5
        lda     $0698,X
        bne     L2_85D7
L2_85D5:
        lda     #$5C
L2_85D7:
        ldy     #$00
        sty     $15
        jmp     L2_8812
L2_85DE:
        lda     $0500,X
        cmp     #$B3
        bne     L2_861C
        lda     $07A0,X
        beq     L2_85F9
        jsr     L2_8579
        lda     #$00
        sta     $15
        lda     #$1C
        jsr     L2_8812
        jmp     L7_C048
L2_85F9:
        jsr     L7_C0C3
        bcc     L2_860D
        lda     $4C
        sec
        sbc     $0758,X
        sta     $10
        lda     $4D
        sbc     $0770,X
        bcs     L2_860E
L2_860D:
        rts
L2_860E:
        sta     $4D
        lda     $10
        sta     $4C
        lda     #$00
        jsr     L7_C12F
        jmp     L2_8621
L2_861C:
        jsr     L7_C0C3
        bcc     L2_860D
L2_8621:
        jsr     L2_880C
        bcs     L2_862A
        lda     #$FF
        sta     $56
L2_862A:
        lda     $07B8,X
        cmp     #$02
        beq     L2_863F
        jsr     L2_8579
        lda     #$00
        sta     $15
        lda     #$1C
        sta     $16
        jsr     L7_C11A
L2_863F:
        txa
        pha
        lda     $07B8,X
        beq     L2_86AE
        cmp     #$01
        beq     L2_8669
        lda     #$60
        sta     $18
        lda     #$50
        jsr     L2_8817
        lda     #$90
        jsr     L2_8817
        lda     #$70
        sta     $19
        lda     #$10
        ldy     #$FF
        jsr     L7_C006

; ---- bank2.inline_8663 (data) $8663-$8665, 3 bytes
; Far-call argument at $8663
        .byte   $01,$05,$80

; ---- bank2.code_8666 (code) $8666-$87BA, 341 bytes
        jmp     L2_866E
L2_8669:
        lda     $5E
        jsr     L7_C066
L2_866E:
        ldx     #$00
L2_8670:
        lda     $87EC,X
        lsr     A
        tay
        lda     $0400,Y
        bcs     L2_867E
        lsr     A
        lsr     A
        lsr     A
        lsr     A
L2_867E:
        and     #$0F
        cmp     #$0E
        bne     L2_86A5
        lda     $87EF,X
        and     $54
        beq     L2_86A5
        lda     $87ED,X
        sta     $15
        lda     $87EE,X
        sta     $17
        lda     $87EC,X
        sta     $18
        asl     A
        asl     A
        asl     A
        asl     A
        sta     $19
        lda     #$14
        jsr     L2_8812
L2_86A5:
        txa
        clc
        adc     #$04
        tax
        cpx     #$20
        bne     L2_8670
L2_86AE:
        pla
        pha
        tax
        lda     $0680,X
        jsr     L2_86BC
        pla
        tax
        jmp     L7_C048
L2_86BC:
        sta     $10
        cmp     #$0B
        bcs     L2_8711
        ldy     #$FF
        sec
L2_86C5:
        iny
        sbc     #$04
        bcs     L2_86C5
        adc     #$04
        tax
        lda     $04AC,Y
        and     $87C6,X
        cmp     $87C6,X
        bne     L2_86EA
        lda     $4D
        adc     #$07
        bcc     L2_86E0
        lda     #$FF
L2_86E0:
        sta     $4D
        lda     #$D4
        jsr     L7_C12F
        jmp     L2_8706
L2_86EA:
        lda     $04AC,Y
        adc     $87CA,X
        sta     $04AC,Y
L2_86F3:
        lda     $10
        pha
        lda     #$00
        jsr     L7_C12F
        pla
        clc
        adc     #$01
        cmp     $3C
        bne     L2_8706
        jsr     L7_C069
L2_8706:
        lda     #$35
        jsr     L7_C030
L2_870B:
        lda     #$10
L2_870D:
        jmp     L7_C00C
L2_8710:
        rts
L2_8711:
        bne     L2_872A
        lda     $04AE
        ora     #$40
        sta     $04AE
        lda     $04AF
        clc
        adc     #$14
        bcc     L2_8725
        lda     #$FF
L2_8725:
        sta     $04AF
        bne     L2_86F3
L2_872A:
        tay
        lda     $87AF,Y
        beq     L2_8733
        jsr     L7_C030
L2_8733:
        cpy     #$0D
        bcs     L2_873E
        lda     $47
        sta     $48
        jmp     L2_8710
L2_873E:
        bne     L2_8746
        jsr     L7_C033
        jmp     L2_870B
L2_8746:
        cpy     #$0F
        bcs     L2_874E
        inc     $4A
        bne     L2_8756
L2_874E:
        bne     L2_875C
        lda     $4B
        beq     L2_8756
        inc     $4B
L2_8756:
        jsr     L7_C132
        jmp     L2_870B
L2_875C:
        cpy     #$11
        bcs     L2_8772
        inc     $6B
        ldy     $6B
        cpy     #$06
        bcc     L2_876A
        ldy     #$05
L2_876A:
        sty     $6B
        jsr     L2_882E
        jmp     L2_870B
L2_8772:
        bne     L2_8795
        lda     $46
        cmp     #$0A
        bcs     L2_877C
        adc     #$01
L2_877C:
        sta     $46
        jsr     L2_8820
        lda     $4E
        sta     $4C
        lda     $4F
        sta     $4D
        lda     $47
        sta     $48
        lda     #$00
        jsr     L7_C12F
        jmp     L2_870B
L2_8795:
        cpy     #$15
        bcs     L2_87A1
        lda     #$28
        jsr     L7_C00C
        jmp     L2_8710
L2_87A1:
        bne     L2_87B1
        inc     $4D
        bne     L2_87A9
        dec     $4D
L2_87A9:
        lda     #$F4
        jsr     L7_C12F
        jmp     L2_870B
L2_87B1:
        lda     #$0A
        jsr     L7_C12F
        lda     #$08
        jmp     L2_870D

; ---- UNCLAIMED (gap) $87BB-$880B, 81 bytes
        .byte   $32,$00,$35,$35,$35,$31,$00,$00,$30,$34,$33,$03,$0C,$30,$C0,$01
        .byte   $04,$10,$40,$0C,$05,$04,$03,$02,$01,$32,$00,$64,$00,$96,$00,$C8
        .byte   $00,$90,$01,$20,$03,$B0,$04,$40,$06,$60,$09,$A0,$0F,$70,$17,$30
        .byte   $75,$27,$08,$55,$80,$37,$0A,$00,$80,$71,$08,$55,$40,$72,$0A,$00
        .byte   $40,$7E,$08,$55,$20,$7D,$0A,$00,$20,$B7,$08,$55,$10,$A7,$0A,$00
        .byte   $10

; ---- bank2.code_880C (code) $880C-$881B, 16 bytes
L2_880C:
        lda     $0680,X
        cmp     #$14
        rts
L2_8812:
        sta     $16
        jmp     L7_C117
L2_8817:
        sta     $19
        jsr     L7_C006

; ---- bank2.inline_881C (data) $881C-$881E, 3 bytes
; Far-call argument at $881C
        .byte   $01,$02,$80

; ---- bank2.code_881F (code) $881F-$88A5, 135 bytes
        rts
L2_8820:
        lda     $46
        asl     A
        tay
        lda     $87D4,Y
        sta     $4E
        lda     $87D5,Y
        sta     $4F
L2_882E:
        ldy     $6B
        lda     $87CE,Y
        sta     $39
        rts
L2_8836:
        jsr     L7_C063
        lda     #$00
        sta     $0668
        sta     $0680
        sta     $06C8
        sta     $05C0
        lda     #$01
        sta     $0620
        sta     $05D8
        tax
        jsr     L7_C0A2
        lda     #$05
        sta     $0500
        lda     #$B0
        sta     $0518
        lda     #$80
        sta     $0530
        lda     #$0D
        sta     $0548
L2_8867:
        ldy     #$01
        jsr     L7_C021
        jsr     L7_C01E
        jsr     L7_C096
        ldx     #$00
        lda     #$40
        ldy     #$F0
        jsr     L7_C0A5
        cpy     #$10
        bcs     L2_8887
        lda     #$08
L2_8881:
        jsr     L7_C09C
        jmp     L2_8966
L2_8887:
        cpy     #$20
        bcs     L2_8894
        lda     #$FF
        sta     $0668
        lda     #$02
        bne     L2_8881
L2_8894:
        cpy     #$40
        bcs     L2_88CE
        sbc     #$1F
        lsr     A
        lsr     A
        tay
        lda     $88A6,Y
        sta     $0548
        jmp     L2_8966

; ---- UNCLAIMED (gap) $88A6-$88CD, 40 bytes
        .byte   $0D,$0C,$0C,$0B,$0A,$09,$08,$01,$02,$16,$1E,$15,$03,$19,$0F,$13
        .byte   $1F,$07,$01,$17,$0B,$1B,$14,$12,$1D,$0C,$0D,$05,$1A,$10,$06,$09
        .byte   $00,$0A,$0E,$08,$11,$04,$1C,$18

; ---- bank2.code_88CE (code) $88CE-$896C, 159 bytes
L2_88CE:
        cmp     #$80
        bcc     L2_88D5
        jmp     L2_895C
L2_88D5:
        lda     $0650
        cmp     #$40
        bcs     L2_8919
        lda     #$F0
        sta     $05C0
        lda     #$80
        sta     $19
        lda     #$B0
        sta     $18
        lda     #$3F
        sta     $15
        sta     $14
        jsr     L7_C120
        lda     $0638,X
        and     #$03
        bne     L2_8907
        lda     #$23
        jsr     L7_C030
        lda     #$07
        sta     $0500,Y
        lda     #$30
        bne     L2_890E
L2_8907:
        lda     #$22
        jsr     L7_C030
        lda     #$11
L2_890E:
        sta     $0189
        sta     $018C
        lda     #$03
        sta     $017F
L2_8919:
        lda     $0638,X
        cmp     #$60
        bcc     L2_8966
        ldy     $0650
        cpy     #$40
        bcs     L2_8959
        sbc     #$5F
        tay
        lda     $88AE,Y
        sta     $18
        lda     #$18
        sta     $19
        lda     #$A0
        sta     $15
        lda     #$00
        sta     $14
        lda     #$32
        jsr     L7_C0CC
        jsr     L7_C036
        lda     #$1C
        sta     $19
        jsr     L7_C036
        ldy     #$02
        jsr     L7_C021
        lda     #$0F
        jsr     L7_C0CC
        ldy     #$01
        jsr     L7_C021
L2_8959:
        jmp     L2_8966
L2_895C:
        lda     #$00
        sta     $0668
        lda     #$08
        jsr     L7_C09C
L2_8966:
        jsr     L7_C08D
        php
        jsr     L7_C006

; ---- bank2.inline_896D (data) $896D-$896F, 3 bytes
; Far-call argument at $896D
        .byte   $06,$0B,$80

; ---- bank2.code_8970 (code) $8970-$8993, 36 bytes
        plp
        bcs     L2_8976
        jmp     L2_8867
L2_8976:
        jsr     L7_C00F
        lda     #$1F
        sta     $19
        lda     #$E0
        sta     $18
        lda     #$02
        ldy     #$02
        jsr     L7_C042
        jsr     L7_C045
        lda     $49
        beq     L2_8991
        dec     $49
L2_8991:
        jsr     L7_C006

; ---- bank2.inline_8994 (data) $8994-$8996, 3 bytes
; Far-call argument at $8994
        .byte   $05,$32,$80

; ---- bank2.code_8997 (code) $8997-$8A3F, 169 bytes
        rts
L2_8998:
        lda     #$00
        sta     $02F1
        sta     $02F9
        sta     $02F5
        sta     $02FD
        inc     $02F2
        lda     $02F2
        and     #$03
        sta     $02F2
        ora     #$80
        sta     $02F6
        ora     #$40
        sta     $02FE
        eor     #$80
        sta     $02FA
        ldy     $3C
        lda     #$05
        jsr     L7_C10B
        asl     A
        asl     A
        asl     A
        asl     A
        adc     #$AB
        sta     $02F0
        sta     $02F8
        adc     #$08
        sta     $02F4
        sta     $02FC
        tya
        asl     A
        asl     A
        asl     A
        asl     A
        sta     $10
        asl     A
        adc     $10
        adc     #$0E
        sta     $02F3
        sta     $02F7
        adc     #$1B
        sta     $02FB
        sta     $02FF
        lda     #$F8
        sta     $02EC
        inc     $14
        lda     $14
        and     #$04
        bne     L2_8A1E
        lda     #$01
        sta     $02ED
        lda     $52
        asl     A
        asl     A
        adc     #$10
        sta     $02EF
        lda     $53
        asl     A
        asl     A
        adc     #$3B
        sta     $02EC
        lda     #$00
        sta     $02EE
L2_8A1E:
        lda     $14
        and     #$0F
        bne     L2_8A3C
        ldy     #$00
L2_8A26:
        lda     $0200,Y
        pha
        lda     $0283,Y
        sta     $0200,Y
        pla
        sta     $0283,Y
        iny
        iny
        iny
        iny
        cpy     #$60
        bne     L2_8A26
L2_8A3C:
        rts
L2_8A3D:
        jsr     L7_C06C

; ---- bank2.inline_8A40 (data) $8A40-$8A43, 4 bytes
; Inline argument at $8A40
        .byte   $20,$23,$C0,$00

; ---- bank2.code_8A44 (code) $8A44-$8A46, 3 bytes
        jsr     L7_C06C

; ---- bank2.inline_8A47 (data) $8A47-$8A4A, 4 bytes
; Inline argument at $8A47
        .byte   $20,$23,$E0,$FF

; ---- bank2.code_8A4B (code) $8A4B-$8A4D, 3 bytes
        jsr     L7_C06F

; ---- UNCLAIMED (gap) $8A4E-$8A68, 27 bytes
        .byte   $10,$21,$0C,$43,$4F,$4E,$47,$52,$41,$54,$55,$4C,$41,$54,$49,$4F
        .byte   $4E,$53,$5B,$A9,$30,$8D,$81,$01,$4C,$F7,$8A

; ---- bank2.code_8A69 (code) $8A69-$8A8A, 34 bytes
L2_8A69:
        ldx     #$FF
        txs
        lda     $30
        ldx     #$00
        stx     $30
        and     #$02
        beq     L2_8A79
        jmp     L2_8A3D
L2_8A79:
        lda     #$18
        sta     $19
        lda     #$F0
        sta     $18
        lda     #$04
        ldy     #$01
        jsr     L7_C042
        jsr     L7_C06C

; ---- bank2.inline_8A8B (data) $8A8B-$8A8E, 4 bytes
; Inline argument at $8A8B
        .byte   $10,$23,$C0,$00

; ---- bank2.code_8A8F (code) $8A8F-$8A91, 3 bytes
        jsr     L7_C06C

; ---- bank2.inline_8A92 (data) $8A92-$8A95, 4 bytes
; Inline argument at $8A92
        .byte   $20,$23,$D0,$55

; ---- bank2.code_8A96 (code) $8A96-$8A98, 3 bytes
        jsr     L7_C06C

; ---- bank2.inline_8A99 (data) $8A99-$8A9C, 4 bytes
; Inline argument at $8A99
        .byte   $10,$23,$F0,$AA

; ---- bank2.code_8A9D (code) $8A9D-$8A9F, 3 bytes
        jsr     L7_C06C

; ---- bank2.inline_8AA0 (data) $8AA0-$8AA3, 4 bytes
; Inline argument at $8AA0
        .byte   $02,$23,$EC,$A5

; ---- bank2.code_8AA4 (code) $8AA4-$8AA6, 3 bytes
        jsr     L7_C06F

; ---- UNCLAIMED (gap) $8AA7-$BFFE, 13656 bytes
        .byte   $01,$23,$F5,$A8,$20,$6C,$C0,$04,$23,$E0,$FF,$20,$6C,$C0,$04,$23
        .byte   $E8,$FF,$20,$6C,$C0,$04,$23,$F0,$FF,$A9,$21,$85,$19,$A9,$F1,$85
        .byte   $18,$A9,$8B,$85,$17,$A9,$05,$85,$16,$A9,$0A,$85,$15,$A9,$0D,$85
        .byte   $14,$A0,$00,$20,$7E,$C0,$A0,$00,$B9,$87,$8B,$99,$00,$02,$C8,$C0
        .byte   $58,$D0,$F5,$A0,$00,$B9,$DF,$8B,$99,$80,$01,$C8,$C0,$19,$D0,$F5
        .byte   $20,$DE,$C0,$A9,$0F,$20,$30,$C0,$20,$06,$C0,$00,$14,$80,$F4,$F6
        .byte   $F6,$F6,$F6,$F6,$F6,$F6,$F6,$F5,$F4,$20,$B0,$B1,$B2,$B3,$B4,$20
        .byte   $20,$F5,$F4,$20,$B5,$B6,$F7,$F7,$F8,$B7,$20,$F5,$F4,$20,$B8,$B9
        .byte   $BA,$BB,$F7,$BD,$20,$F5,$F4,$20,$BE,$BF,$C0,$C1,$BC,$C2,$C3,$F5
        .byte   $F4,$20,$C4,$C5,$C6,$C7,$C8,$C9,$CA,$F5,$F4,$20,$CB,$CC,$CD,$CE
        .byte   $CF,$D0,$D1,$F5,$F4,$20,$D2,$D3,$D4,$D5,$D6,$D7,$D8,$F5,$F4,$20
        .byte   $D9,$DA,$DB,$DC,$DD,$DE,$20,$F5,$F4,$20,$DF,$E0,$E1,$E2,$E3,$E4
        .byte   $E5,$E6,$F4,$20,$E7,$E8,$E9,$EA,$EB,$EC,$ED,$EE,$F2,$F6,$F6,$F6
        .byte   $F6,$F6,$EF,$F0,$F1,$F3,$20,$20,$20,$20,$20,$20,$F9,$FA,$FB,$20
        .byte   $F8,$AD,$00,$F7,$F8,$AF,$01,$FF,$8F,$A1,$03,$A0,$8F,$A3,$03,$A8
        .byte   $9F,$A5,$02,$A0,$A7,$A9,$00,$B1,$A7,$AB,$00,$C0,$C7,$A7,$03,$B0
        .byte   $4D,$97,$02,$24,$50,$99,$01,$40,$50,$9B,$01,$48,$48,$91,$01,$60
        .byte   $68,$95,$01,$50,$6C,$95,$01,$28,$72,$93,$01,$68,$70,$93,$01,$08
        .byte   $78,$95,$01,$80,$60,$95,$01,$A8,$70,$95,$01,$B0,$50,$91,$01,$98
        .byte   $54,$95,$01,$C0,$58,$93,$01,$CC,$0F,$30,$07,$15,$36,$06,$07,$36
        .byte   $07,$15,$0F,$0F,$0F,$30,$15,$0F,$21,$12,$02,$30,$26,$16,$30,$3C
        .byte   $12,$38,$4C,$C6,$C6,$C6,$64,$38,$18,$78,$18,$18,$18,$18,$7E,$7C
        .byte   $C6,$06,$7C,$C0,$C0,$FE,$7C,$C6,$06,$7C,$06,$C6,$7C,$7C,$CC,$CC
        .byte   $CC,$CC,$FE,$0C,$FE,$C0,$FC,$06,$06,$C6,$7C,$7C,$C0,$C0,$FC,$C6
        .byte   $C6,$7C,$FE,$C6,$0C,$18,$30,$30,$30,$7C,$C6,$C6,$7C,$C6,$C6,$7C
        .byte   $7C,$C6,$C6,$7E,$06,$C6,$7C,$FE,$FE,$7C,$38,$10,$00,$00,$00,$30
        .byte   $30,$00,$30,$30,$60,$00,$00,$00,$00,$00,$60,$20,$00,$00,$00,$7E
        .byte   $00,$00,$00,$00,$00,$00,$00,$60,$60,$00,$3C,$46,$06,$0C,$18,$00
        .byte   $18,$7C,$82,$BA,$A2,$BA,$82,$7C,$7C,$C6,$C6,$C6,$FE,$C6,$C6,$FC
        .byte   $C6,$C6,$FC,$C6,$C6,$FC,$7E,$C0,$C0,$C0,$C0,$C0,$7E,$F8,$CC,$C6
        .byte   $C6,$C6,$CC,$F8,$7E,$C0,$C0,$FE,$C0,$C0,$7E,$FE,$C0,$C0,$FC,$C0
        .byte   $C0,$C0,$7E,$C0,$C0,$DE,$C6,$C6,$7E,$C6,$C6,$C6,$FE,$C6,$C6,$C6
        .byte   $3C,$18,$18,$18,$18,$18,$3C,$06,$06,$06,$06,$06,$C6,$7C,$C6,$CC
        .byte   $D8,$F0,$D8,$CC,$C6,$C0,$C0,$C0,$C0,$C0,$C0,$FE,$82,$C6,$EE,$FE
        .byte   $D6,$C6,$C6,$C6,$E6,$F6,$DE,$CE,$C6,$C2,$7C,$C6,$C6,$C6,$C6,$C6
        .byte   $7C,$FC,$C6,$C6,$C6,$FC,$C0,$C0,$7C,$C6,$C6,$C6,$DE,$CC,$76,$FC
        .byte   $C6,$C6,$C6,$FC,$CC,$C6,$7E,$C0,$C0,$7C,$06,$06,$FC,$7E,$18,$18
        .byte   $18,$18,$18,$18,$C6,$C6,$C6,$C6,$C6,$C6,$7C,$C6,$C6,$C6,$C6,$CC
        .byte   $D8,$F0,$C6,$C6,$C6,$D6,$FE,$EE,$C6,$C6,$EE,$7C,$38,$7C,$EE,$C6
        .byte   $66,$66,$66,$3C,$18,$18,$18,$FE,$0E,$1C,$38,$70,$E0,$FE,$10,$38
        .byte   $7C,$00,$00,$00,$00,$FC,$D6,$D6,$D6,$D6,$D6,$D6,$18,$18,$18,$10
        .byte   $10,$00,$18,$6C,$6C,$48,$00,$00,$00,$00,$00,$00,$00,$00,$00,$6C
        .byte   $6C,$60,$60,$30,$00,$00,$00,$00,$00,$7C,$06,$7E,$C6,$C6,$7E,$C0
        .byte   $C0,$FC,$C6,$C6,$C6,$FC,$00,$7E,$C0,$C0,$C0,$C0,$7E,$06,$06,$7E
        .byte   $C6,$C6,$C6,$7E,$00,$7C,$C6,$C6,$FC,$C0,$7E,$1E,$30,$30,$FE,$30
        .byte   $30,$30,$00,$7E,$C6,$C6,$7C,$06,$FC,$C0,$C0,$FC,$C6,$C6,$C6,$C6
        .byte   $18,$00,$18,$18,$18,$18,$18,$06,$00,$06,$06,$C6,$C6,$7C,$60,$66
        .byte   $6C,$78,$78,$6C,$66,$38,$18,$18,$18,$18,$18,$1C,$00,$7C,$D6,$D6
        .byte   $D6,$D6,$D6,$00,$F8,$CC,$C6,$C6,$C6,$C6,$00,$7C,$C6,$C6,$C6,$C6
        .byte   $7C,$00,$FC,$C6,$C6,$C6,$FC,$C0,$00,$7E,$C6,$C6,$C6,$7E,$06,$00
        .byte   $7C,$C6,$C0,$C0,$C0,$C0,$00,$7E,$C0,$7C,$06,$06,$FC,$30,$30,$FE
        .byte   $30,$30,$30,$1E,$00,$C6,$C6,$C6,$C6,$C6,$7E,$00,$C6,$C6,$C6,$C6
        .byte   $6C,$38,$00,$C6,$C6,$D6,$FE,$EE,$C6,$00,$C6,$6C,$38,$38,$6C,$C6
        .byte   $00,$C6,$C6,$C6,$7E,$06,$FC,$00,$FE,$0C,$18,$30,$60,$FE,$38,$4C
        .byte   $DE,$F6,$E6,$64,$38,$38,$00,$00,$05,$0F,$06,$0C,$1C,$00,$27,$20
        .byte   $45,$4B,$24,$2C,$50,$0C,$06,$0F,$05,$30,$2A,$40,$00,$2C,$24,$2B
        .byte   $25,$00,$14,$3F,$00,$4E,$12,$82,$D2,$F8,$30,$18,$1C,$81,$21,$81
        .byte   $51,$69,$11,$19,$05,$1A,$32,$F8,$D2,$86,$12,$01,$00,$19,$11,$69
        .byte   $50,$81,$2D,$FE,$00,$38,$00,$00,$01,$01,$01,$01,$13,$00,$27,$20
        .byte   $41,$41,$21,$21,$52,$1F,$1F,$1E,$1F,$00,$28,$40,$00,$0C,$01,$02
        .byte   $01,$00,$14,$3F,$00,$4E,$12,$C2,$E2,$E0,$E0,$E0,$F4,$81,$21,$C1
        .byte   $21,$21,$21,$21,$15,$FC,$3C,$3C,$7C,$00,$12,$01,$00,$C9,$21,$21
        .byte   $41,$01,$0D,$FE,$00,$38,$01,$07,$0F,$0F,$1E,$1D,$1B,$00,$21,$26
        .byte   $48,$49,$12,$15,$5A,$17,$06,$04,$00,$30,$28,$40,$00,$15,$06,$04
        .byte   $00,$00,$14,$3F,$00,$0E,$C2,$F2,$FA,$F8,$3C,$DC,$EC,$01,$C1,$31
        .byte   $09,$C9,$25,$D5,$2D,$F4,$30,$10,$00,$06,$02,$01,$00,$D5,$31,$11
        .byte   $00,$01,$0D,$FE,$00,$38,$01,$03,$03,$0D,$1E,$1E,$0C,$00,$21,$22
        .byte   $42,$4D,$12,$12,$4C,$03,$07,$03,$00,$30,$2B,$40,$00,$20,$24,$23
        .byte   $20,$00,$14,$3F,$00,$0E,$82,$C2,$DA,$BC,$3C,$18,$20,$01,$81,$41
        .byte   $59,$A5,$25,$19,$21,$BA,$BA,$30,$02,$06,$12,$01,$00,$89,$89,$31
        .byte   $00,$01,$6D,$FE,$00,$38,$00,$07,$08,$15,$15,$00,$15,$00,$20,$27
        .byte   $48,$50,$15,$00,$55,$00,$15,$00,$03,$31,$28,$40,$00,$00,$15,$00
        .byte   $23,$01,$10,$3F,$00,$4E,$02,$F2,$08,$B4,$B4,$00,$B4,$81,$01,$C1
        .byte   $09,$01,$21,$01,$21,$00,$B4,$00,$E2,$C6,$12,$01,$00,$01,$21,$01
        .byte   $80,$01,$0D,$FE,$00,$38,$00,$01,$07,$07,$0F,$0F,$07,$00,$20,$21
        .byte   $46,$44,$28,$08,$44,$07,$0B,$05,$09,$20,$28,$40,$00,$06,$2A,$25
        .byte   $29,$00,$14,$3F,$00,$4E,$02,$C2,$F2,$F0,$F8,$F8,$F0,$81,$01,$C1
        .byte   $31,$11,$09,$09,$11,$F2,$EA,$D0,$CA,$86,$02,$01,$00,$31,$29,$51
        .byte   $48,$81,$0D,$7E,$00,$30,$06,$0F,$0F,$06,$00,$01,$06,$00,$26,$29
        .byte   $49,$46,$20,$21,$46,$0C,$07,$00,$00,$30,$2B,$40,$00,$2C,$27,$20
        .byte   $20,$00,$14,$3F,$00,$4E,$02,$F2,$1A,$18,$70,$80,$00,$81,$01,$F1
        .byte   $19,$19,$71,$81,$01,$00,$F8,$00,$02,$06,$12,$01,$00,$01,$F9,$01
        .byte   $00,$01,$6D,$FE,$00,$38,$00,$06,$0C,$08,$18,$18,$08,$00,$20,$26
        .byte   $4C,$48,$18,$18,$48,$0C,$07,$01,$00,$30,$28,$40,$00,$0C,$07,$01
        .byte   $20,$00,$14,$3F,$00,$0E,$62,$F2,$FA,$68,$0C,$0C,$08,$01,$61,$91
        .byte   $99,$69,$0D,$0D,$09,$1A,$72,$C0,$02,$06,$12,$01,$00,$19,$71,$C1
        .byte   $00,$01,$6D,$FE,$00,$38,$01,$03,$03,$03,$03,$03,$03,$00,$21,$22
        .byte   $42,$42,$22,$22,$42,$03,$03,$02,$00,$34,$2B,$40,$00,$22,$23,$22
        .byte   $20,$00,$14,$3F,$00,$8E,$C2,$E2,$E2,$E0,$E0,$E0,$E0,$81,$41,$21
        .byte   $21,$21,$21,$21,$21,$E2,$62,$20,$02,$26,$12,$01,$00,$A1,$61,$21
        .byte   $00,$01,$6D,$FE,$00,$70,$78,$7C,$3E,$1F,$0F,$07,$03,$70,$49,$44
        .byte   $22,$11,$08,$04,$42,$01,$00,$00,$00,$34,$2B,$40,$00,$21,$20,$20
        .byte   $20,$00,$14,$3F,$00,$4E,$12,$02,$02,$00,$80,$C0,$E0,$81,$21,$01
        .byte   $01,$01,$81,$41,$21,$F0,$C0,$48,$0C,$02,$03,$00,$00,$31,$C1,$51
        .byte   $18,$0C,$46,$E3,$00,$38,$00,$1C,$1C,$1E,$1E,$0F,$0F,$00,$01,$04
        .byte   $44,$52,$12,$09,$49,$07,$07,$03,$03,$30,$2A,$40,$00,$24,$24,$22
        .byte   $22,$00,$14,$3F,$00,$4E,$00,$1C,$1C,$3C,$3C,$78,$78,$81,$01,$11
        .byte   $11,$25,$25,$49,$49,$F2,$F2,$E0,$E2,$86,$12,$01,$00,$91,$91,$21
        .byte   $20,$01,$2D,$FE,$00,$38,$00,$00,$05,$0F,$07,$0F,$1F,$00,$27,$20
        .byte   $45,$4B,$24,$28,$50,$0F,$07,$0F,$05,$30,$2A,$40,$00,$2C,$24,$2A
        .byte   $25,$00,$14,$3F,$00,$4E,$12,$82,$D2,$F8,$F0,$F8,$FC,$81,$21,$81
        .byte   $51,$29,$11,$09,$05,$F8,$F0,$F8,$D2,$86,$12,$01,$00,$19,$11,$69
        .byte   $50,$81,$2D,$FE,$00,$38,$00,$00,$06,$10,$05,$15,$11,$00,$20,$07
        .byte   $50,$44,$11,$01,$45,$01,$00,$00,$00,$20,$28,$40,$00,$15,$14,$16
        .byte   $07,$00,$10,$3F,$00,$46,$00,$00,$30,$84,$D0,$D4,$C4,$81,$01,$F1
        .byte   $05,$91,$C5,$41,$51,$C0,$80,$00,$00,$02,$02,$01,$00,$D5,$95,$35
        .byte   $F0,$01,$0D,$FE,$00,$00,$00,$00,$1C,$3E,$3E,$38,$38,$07,$1F,$3F
        .byte   $63,$41,$C1,$C1,$C1,$1C,$00,$0F,$07,$03,$00,$00,$00,$E3,$FF,$7F
        .byte   $7F,$3F,$BF,$C7,$60,$00,$00,$00,$38,$7C,$7C,$1C,$1C,$E0,$F8,$FC
        .byte   $C6,$82,$83,$83,$83,$38,$00,$F0,$E0,$C0,$00,$00,$00,$C7,$FF,$FE
        .byte   $FE,$FC,$FD,$E3,$06,$08,$00,$3B,$5D,$5D,$39,$01,$05,$30,$00,$3B
        .byte   $04,$1D,$39,$00,$44,$04,$03,$00,$00,$34,$2B,$40,$00,$24,$23,$20
        .byte   $20,$00,$14,$3F,$00,$4A,$00,$F4,$56,$F6,$20,$DC,$00,$85,$00,$F4
        .byte   $00,$F4,$20,$00,$38,$00,$80,$00,$40,$38,$02,$01,$00,$20,$B9,$21
        .byte   $38,$03,$01,$FE,$00,$20,$08,$0C,$0F,$0F,$0F,$0F,$0F,$00,$21,$28
        .byte   $4C,$47,$23,$28,$4C,$0F,$07,$03,$00,$34,$2B,$40,$00,$2F,$27,$23
        .byte   $20,$00,$14,$3F,$00,$40,$04,$0C,$FC,$FC,$FC,$FC,$FC,$81,$21,$05
        .byte   $0D,$39,$31,$05,$0D,$FC,$F8,$F0,$C2,$06,$12,$01,$00,$3D,$39,$31
        .byte   $00,$01,$6D,$FE,$00,$30,$01,$03,$06,$04,$01,$03,$06,$00,$20,$21
        .byte   $42,$44,$20,$21,$42,$04,$01,$03,$06,$34,$21,$43,$00,$24,$20,$21
        .byte   $22,$04,$10,$31,$00,$86,$C2,$62,$32,$90,$C0,$60,$30,$01,$81,$41
        .byte   $21,$11,$81,$41,$21,$92,$C2,$60,$32,$96,$C2,$61,$00,$11,$81,$41
        .byte   $20,$11,$85,$46,$00,$07,$1F,$3F,$7F,$7F,$FF,$F9,$F9,$07,$1F,$3F
        .byte   $63,$41,$C1,$C1,$C1,$FF,$FF,$70,$78,$3C,$BF,$C7,$60,$E3,$FF,$70
        .byte   $78,$3C,$BF,$C7,$60,$E0,$F8,$FC,$FE,$FE,$FF,$9F,$9F,$E0,$F8,$FC
        .byte   $C6,$82,$83,$83,$83,$FF,$FF,$0E,$1E,$3C,$FD,$E3,$06,$C7,$FF,$0E
        .byte   $1E,$3C,$FD,$E3,$06,$27,$58,$A7,$58,$50,$A0,$A0,$A0,$A0,$A0,$A0
        .byte   $50,$58,$A7,$58,$27,$E4,$1A,$E5,$1A,$0A,$05,$05,$05,$05,$05,$05
        .byte   $0A,$1A,$E5,$1A,$E4,$00,$00,$07,$18,$10,$20,$20,$20,$20,$20,$20
        .byte   $10,$18,$07,$00,$00,$00,$00,$E0,$18,$08,$04,$04,$04,$04,$04,$04
        .byte   $08,$18,$E0,$00,$00,$00,$00,$07,$18,$13,$21,$20,$20,$20,$20,$21
        .byte   $13,$18,$07,$00,$00,$00,$00,$E0,$18,$88,$44,$A4,$A4,$A4,$A4,$44
        .byte   $88,$18,$E0,$00,$00,$00,$00,$07,$18,$13,$24,$24,$22,$21,$20,$20
        .byte   $11,$18,$07,$00,$00,$00,$00,$E0,$18,$C8,$24,$24,$04,$04,$84,$84
        .byte   $88,$18,$E0,$00,$00,$00,$00,$07,$18,$14,$29,$29,$24,$22,$22,$24
        .byte   $19,$18,$07,$00,$00,$00,$00,$E0,$18,$98,$24,$24,$94,$4C,$4C,$94
        .byte   $28,$18,$E0,$00,$00,$00,$00,$07,$18,$10,$27,$24,$24,$24,$24,$27
        .byte   $10,$18,$07,$00,$00,$00,$00,$E0,$18,$08,$E4,$24,$24,$24,$24,$E4
        .byte   $08,$18,$E0,$00,$00,$00,$00,$07,$18,$13,$22,$2E,$28,$28,$2E,$22
        .byte   $13,$18,$07,$00,$00,$00,$00,$E0,$18,$C8,$44,$74,$14,$14,$74,$44
        .byte   $C8,$18,$E0,$00,$00,$00,$00,$07,$1C,$16,$25,$24,$24,$24,$24,$27
        .byte   $10,$18,$07,$00,$00,$00,$00,$E0,$18,$08,$04,$84,$44,$24,$14,$FC
        .byte   $08,$18,$E0,$00,$00,$00,$00,$07,$18,$10,$20,$21,$22,$24,$28,$25
        .byte   $12,$18,$07,$00,$00,$00,$00,$E0,$18,$48,$A4,$14,$24,$44,$84,$04
        .byte   $08,$18,$E0,$00,$00,$04,$05,$1F,$03,$00,$00,$00,$03,$03,$07,$1F
        .byte   $03,$00,$01,$00,$03,$03,$07,$07,$0F,$0F,$1F,$1F,$3F,$3F,$00,$07
        .byte   $0F,$0F,$1F,$1F,$3F,$3F,$00,$FF,$FF,$04,$3F,$03,$FF,$03,$04,$FC
        .byte   $E0,$00,$80,$00,$C0,$C0,$E0,$04,$FF,$07,$04,$00,$E0,$F0,$F0,$F8
        .byte   $F8,$FC,$FC,$00,$00,$00,$10,$11,$04,$10,$04,$04,$18,$03,$10,$11
        .byte   $10,$13,$13,$17,$04,$00,$08,$04,$07,$08,$0F,$1F,$1F,$3F,$3F,$00
        .byte   $03,$17,$37,$B7,$37,$37,$37,$17,$1C,$E0,$00,$80,$00,$C0,$C0,$E0
        .byte   $17,$0F,$0F,$07,$07,$03,$03,$00,$E0,$10,$F0,$F8,$F8,$FC,$FC,$00
        .byte   $00,$40,$43,$04,$47,$05,$04,$3F,$58,$53,$04,$57,$05,$04,$47,$43
        .byte   $40,$40,$0F,$1F,$00,$00,$57,$53,$58,$5F,$3F,$7F,$7F,$00,$03,$0F
        .byte   $E7,$04,$F7,$05,$04,$FC,$02,$E2,$92,$D2,$F2,$D2,$F2,$F7,$E7,$0F
        .byte   $07,$F7,$FB,$03,$00,$F2,$E2,$02,$FA,$FA,$FC,$FC,$00,$38,$04,$00
        .byte   $08,$04,$27,$20,$40,$42,$25,$22,$45,$04,$00,$04,$04,$34,$2B,$40
        .byte   $00,$22,$25,$22,$20,$00,$14,$3F,$00,$4E,$12,$02,$02,$04,$00,$04
        .byte   $04,$81,$21,$01,$01,$A1,$51,$A1,$51,$02,$02,$00,$02,$26,$12,$01
        .byte   $00,$A1,$51,$A1,$00,$01,$6D,$FE,$04,$00,$11,$04,$FF,$11,$01,$00
        .byte   $00,$11,$FF,$00,$00,$EE,$FE,$FF,$FF,$EE,$00,$00,$FF,$11,$01,$00
        .byte   $00,$11,$FF,$04,$00,$0A,$6C,$01,$FE,$03,$04,$7C,$38,$10,$00,$6C
        .byte   $F2,$FA,$FE,$7C,$38,$10,$38,$01,$07,$0F,$0F,$1F,$1F,$0F,$00,$21
        .byte   $27,$4F,$4F,$1F,$1F,$4F,$0F,$07,$01,$00,$30,$28,$40,$00,$2F,$27
        .byte   $21,$20,$00,$14,$3F,$00,$0E,$C2,$F2,$FA,$F8,$FC,$FC,$F8,$01,$C1
        .byte   $B1,$19,$B9,$FD,$FD,$F9,$FA,$F2,$C0,$02,$06,$02,$01,$00,$F9,$F1
        .byte   $C1,$00,$01,$0D,$FE,$00,$38,$04,$00,$08,$04,$21,$27,$4F,$4F,$1F
        .byte   $1F,$4F,$04,$00,$04,$04,$30,$2A,$40,$00,$2F,$27,$21,$20,$00,$14
        .byte   $3F,$00,$0E,$02,$42,$E2,$40,$00,$00,$00,$01,$C1,$B1,$19,$B9,$FD
        .byte   $FD,$F9,$02,$02,$00,$02,$06,$12,$01,$00,$F9,$F1,$C1,$00,$01,$2D
        .byte   $FE,$00,$38,$00,$0E,$04,$1F,$04,$04,$0F,$00,$20,$0E,$5F,$5F,$1F
        .byte   $1F,$4F,$07,$03,$01,$00,$34,$2B,$40,$00,$27,$23,$21,$20,$00,$14
        .byte   $3F,$00,$4E,$02,$38,$7C,$FC,$FC,$FC,$F8,$81,$01,$39,$6D,$C5,$ED
        .byte   $FD,$F9,$F2,$E2,$C0,$82,$06,$12,$01,$00,$F1,$E1,$C1,$80,$01,$6D
        .byte   $FE,$00,$04,$04,$02,$03,$02,$00,$08,$FF,$08,$02,$FF,$11,$01,$00
        .byte   $00,$11,$FF,$02,$00,$09,$02,$02,$FD,$FE,$00,$60,$60,$FD,$00,$05
        .byte   $FD,$F0,$90,$90,$F0,$FD,$00,$05,$FD,$06,$06,$FD,$00,$05,$FD,$0F
        .byte   $09,$09,$0F,$FD,$00,$05,$FD,$66,$66,$FD,$00,$05,$FD,$FF,$99,$99
        .byte   $FF,$FD,$00,$09,$FD,$60,$60,$FD,$00,$05,$FD,$F0,$90,$90,$F0,$00
        .byte   $60,$60,$00,$00,$60,$60,$00,$F0,$90,$90,$F0,$F0,$90,$90,$F0,$00
        .byte   $06,$06,$00,$00,$60,$60,$00,$0F,$09,$09,$0F,$F0,$90,$90,$F0,$00
        .byte   $66,$66,$00,$00,$60,$60,$00,$FF,$99,$99,$FF,$F0,$90,$90,$F0,$FD
        .byte   $00,$05,$FD,$06,$06,$FD,$00,$05,$FD,$0F,$09,$09,$0F,$00,$60,$60
        .byte   $00,$00,$06,$06,$00,$F0,$90,$90,$F0,$0F,$09,$09,$0F,$00,$06,$06
        .byte   $00,$00,$06,$06,$00,$0F,$09,$09,$0F,$0F,$09,$09,$0F,$00,$66,$66
        .byte   $00,$00,$06,$06,$00,$FF,$99,$99,$FF,$0F,$09,$09,$0F,$FD,$00,$05
        .byte   $FD,$66,$66,$FD,$00,$05,$FD,$FF,$99,$99,$FF,$00,$60,$60,$00,$00
        .byte   $66,$66,$00,$F0,$90,$90,$F0,$FF,$99,$99,$FF,$00,$06,$06,$00,$00
        .byte   $66,$66,$00,$0F,$09,$09,$0F,$FF,$99,$99,$FF,$00,$66,$66,$00,$00
        .byte   $66,$66,$00,$FF,$99,$99,$FF,$FF,$99,$99,$FF,$FD,$FD,$F5,$FB,$00
        .byte   $87,$4F,$2C,$2B,$1F,$3F,$2F,$00,$C7,$6F,$3F,$3F,$1F,$2F,$3E,$37
        .byte   $1F,$4F,$47,$2B,$39,$4C,$5F,$3A,$F8,$7C,$7E,$3C,$3E,$7F,$6C,$00
        .byte   $C2,$E4,$68,$A8,$F0,$F8,$E8,$00,$C6,$EC,$F8,$F8,$F0,$E8,$F8,$D8
        .byte   $F0,$E6,$CE,$BC,$38,$78,$C4,$B8,$36,$7E,$FE,$7C,$E8,$F8,$7C,$19
        .byte   $36,$17,$17,$0F,$0F,$0C,$08,$2E,$39,$18,$18,$08,$0B,$0F,$0F,$08
        .byte   $08,$3C,$7C,$7C,$7F,$3C,$0F,$0F,$0F,$3F,$7F,$7F,$7F,$3F,$0F,$F4
        .byte   $70,$70,$E0,$E0,$E0,$A0,$E0,$4C,$C8,$B0,$A0,$A0,$A0,$E0,$E0,$A0
        .byte   $B0,$FC,$FE,$FE,$FE,$FC,$F0,$E0,$F0,$FC,$FE,$FE,$FE,$FC,$F0,$C7
        .byte   $4F,$2C,$2B,$1F,$3F,$2F,$37,$87,$6F,$3F,$3F,$1F,$2F,$3E,$3A,$1F
        .byte   $8F,$47,$2B,$29,$7C,$87,$BB,$D8,$FC,$7E,$3C,$3E,$7F,$F4,$CC,$C6
        .byte   $E4,$68,$A8,$F0,$F8,$E8,$D8,$C2,$EC,$F8,$F8,$F0,$E8,$F8,$B8,$F0
        .byte   $E2,$C4,$A8,$28,$7C,$C2,$BA,$36,$7E,$FC,$78,$F8,$FC,$5E,$66,$3C
        .byte   $36,$17,$0F,$0F,$09,$09,$0F,$4B,$39,$19,$09,$09,$0F,$0F,$0F,$09
        .byte   $19,$79,$F9,$F9,$FF,$79,$1F,$0F,$1F,$7F,$FF,$FF,$FF,$7F,$1F,$78
        .byte   $D8,$D0,$E0,$20,$E0,$20,$20,$A4,$38,$30,$20,$F5,$E0,$05,$F5,$F0
        .byte   $FC,$FE,$FE,$FE,$FC,$F0,$E0,$F0,$FC,$FE,$FE,$FE,$FC,$F0,$00,$C7
        .byte   $CF,$7F,$7F,$0F,$3F,$3F,$00,$87,$8F,$5F,$5F,$3F,$2F,$37,$3F,$1F
        .byte   $57,$63,$23,$73,$57,$57,$36,$FD,$7C,$7E,$3F,$5E,$7D,$7C,$00,$C6
        .byte   $E6,$FC,$FC,$E0,$F8,$F8,$00,$C2,$E2,$F4,$F4,$F8,$E8,$D8,$F8,$F0
        .byte   $D6,$8E,$8C,$98,$D8,$DC,$D8,$76,$7E,$FE,$FC,$F8,$78,$74,$33,$1B
        .byte   $1A,$1B,$0B,$0F,$0C,$0B,$3E,$1F,$1F,$1E,$F5,$0F,$04,$F5,$08,$08
        .byte   $3C,$7C,$7C,$7F,$3C,$0F,$0F,$0F,$3F,$7F,$7F,$7F,$3F,$0F,$94,$A8
        .byte   $B0,$B0,$A0,$E0,$A0,$E0,$EC,$F8,$F0,$F0,$F5,$E0,$04,$F5,$A0,$F0
        .byte   $FC,$FE,$FE,$FE,$FC,$F0,$E0,$F0,$FC,$FE,$FE,$FE,$FC,$F0,$C7,$CF
        .byte   $7F,$7F,$0F,$3F,$3F,$3F,$87,$8F,$5F,$5F,$3F,$2F,$37,$36,$1F,$97
        .byte   $63,$23,$33,$37,$77,$53,$DD,$FC,$7E,$3F,$3E,$3D,$5C,$7E,$C6,$E6
        .byte   $FC,$FC,$E0,$F8,$F8,$F8,$C2,$E2,$F4,$F4,$F8,$E8,$D8,$D8,$F0,$D2
        .byte   $8C,$88,$98,$D8,$DC,$94,$76,$7E,$FC,$F8,$F8,$78,$74,$FC,$4B,$3A
        .byte   $1B,$0B,$0F,$09,$0F,$09,$7F,$3F,$1E,$F5,$0F,$05,$F5,$09,$19,$7F
        .byte   $FF,$FF,$FF,$7F,$1F,$0F,$1F,$7F,$FF,$FF,$FF,$7F,$1F,$A4,$B8,$B0
        .byte   $A0,$E0,$E0,$20,$E0,$FC,$F8,$F0,$F5,$E0,$05,$F5,$20,$30,$3C,$FE
        .byte   $3E,$FE,$FC,$F0,$E0,$F0,$FC,$FE,$FE,$FE,$FC,$F0,$00,$03,$0F,$1F
        .byte   $07,$3B,$3D,$3E,$00,$03,$0F,$1F,$1F,$3F,$3F,$3F,$1F,$1E,$1E,$0D
        .byte   $06,$04,$09,$17,$1E,$17,$13,$0B,$07,$03,$0F,$1F,$00,$C0,$AC,$BC
        .byte   $BC,$78,$68,$FC,$00,$C0,$E4,$F4,$F4,$E8,$F8,$EC,$7E,$7E,$F6,$2E
        .byte   $D7,$DF,$5F,$6E,$DA,$D2,$FA,$FE,$FD,$F9,$FD,$BE,$16,$0F,$0C,$0B
        .byte   $0F,$1F,$2F,$27,$19,$09,$0F,$0C,$08,$11,$3A,$3F,$21,$13,$31,$71
        .byte   $65,$4D,$3F,$1F,$3D,$1F,$3F,$7F,$7F,$7F,$3F,$1F,$EC,$E8,$28,$28
        .byte   $B0,$E0,$E0,$90,$3C,$78,$F8,$F8,$F0,$20,$60,$F0,$10,$88,$C4,$E6
        .byte   $CA,$FE,$FC,$F8,$F0,$F8,$FC,$FE,$FE,$FE,$FC,$F8,$03,$0F,$1F,$07
        .byte   $3B,$3D,$3E,$1F,$03,$0F,$1F,$1F,$3F,$3F,$3F,$1E,$1E,$1E,$0E,$05
        .byte   $05,$0A,$1F,$3B,$17,$13,$0B,$07,$03,$0F,$1E,$24,$C0,$EC,$BC,$BC
        .byte   $78,$68,$FC,$7E,$C0,$A4,$F4,$F4,$E8,$F8,$EC,$DA,$7E,$F6,$6E,$B7
        .byte   $AF,$A7,$AE,$EC,$D2,$FA,$FE,$FD,$F9,$FD,$7E,$7C,$3F,$1C,$0B,$0F
        .byte   $07,$07,$04,$06,$24,$1F,$0C,$08,$04,$04,$07,$07,$06,$0E,$1E,$3D
        .byte   $3C,$39,$1F,$0F,$07,$0F,$1F,$3F,$3F,$3F,$1F,$0F,$E8,$68,$68,$F0
        .byte   $C0,$C0,$C0,$40,$F8,$F8,$F8,$70,$40,$40,$40,$C0,$20,$28,$58,$7C
        .byte   $BC,$BC,$F8,$F0,$E0,$F8,$F8,$FC,$FC,$FC,$F8,$F0,$00,$03,$0F,$1F
        .byte   $07,$3B,$3D,$3E,$00,$03,$0F,$1F,$1F,$3F,$3F,$3F,$1F,$1E,$1F,$0C
        .byte   $02,$0B,$3B,$77,$1E,$17,$13,$0B,$07,$0F,$3D,$48,$00,$C0,$AC,$BC
        .byte   $BC,$78,$68,$FC,$00,$C0,$E4,$F4,$F4,$E8,$F8,$EC,$7E,$7E,$F6,$6E
        .byte   $37,$2F,$27,$EE,$DA,$D2,$FA,$FE,$FD,$F9,$FD,$FE,$6F,$2F,$1C,$0B
        .byte   $0F,$1F,$27,$23,$51,$37,$1F,$0C,$0C,$12,$3F,$3F,$13,$11,$39,$71
        .byte   $65,$7F,$3F,$1F,$1F,$1F,$3F,$7F,$7F,$7F,$3F,$1F,$AC,$A8,$68,$A8
        .byte   $F0,$E0,$E0,$10,$FC,$B8,$F8,$78,$30,$20,$20,$F0,$90,$88,$C8,$C4
        .byte   $C4,$94,$FC,$F8,$F0,$F8,$F8,$F5,$FC,$04,$F5,$F8,$00,$13,$17,$0F
        .byte   $08,$07,$0F,$1F,$00,$1B,$1F,$F5,$0F,$04,$F5,$1F,$1F,$17,$2F,$17
        .byte   $0B,$0F,$1D,$1C,$1D,$3D,$38,$1C,$0E,$0C,$16,$17,$00,$E0,$F2,$F7
        .byte   $F6,$2E,$DC,$FC,$00,$E0,$F6,$FD,$FE,$FA,$FC,$DC,$CE,$D0,$E2,$C4
        .byte   $D8,$AC,$32,$7A,$FE,$7E,$3E,$7C,$F8,$74,$FE,$E6,$0F,$05,$06,$07
        .byte   $07,$07,$04,$04,$0E,$06,$05,$06,$06,$07,$07,$07,$04,$0C,$3C,$7C
        .byte   $7E,$7A,$31,$1F,$07,$0F,$3F,$7F,$7F,$7F,$3F,$1F,$F8,$18,$D0,$F0
        .byte   $E0,$E0,$C0,$40,$24,$F8,$30,$10,$20,$20,$C0,$C0,$60,$50,$DC,$FE
        .byte   $FE,$FE,$FC,$F0,$E0,$F0,$FC,$FE,$FE,$FE,$FC,$F0,$1B,$17,$0F,$08
        .byte   $07,$0F,$1F,$1F,$13,$1F,$F5,$0F,$04,$F5,$1F,$1D,$37,$2F,$17,$0B
        .byte   $07,$05,$0E,$0B,$3D,$38,$1C,$0E,$04,$06,$0B,$0E,$E0,$F6,$F7,$F6
        .byte   $2E,$DC,$FC,$CE,$E0,$F2,$FD,$FE,$FA,$FC,$DC,$FE,$D0,$E6,$CC,$D8
        .byte   $A8,$2C,$74,$F4,$7E,$3E,$7C,$F8,$78,$F4,$FC,$4C,$05,$06,$F5,$07
        .byte   $04,$F5,$03,$05,$06,$F5,$05,$05,$F5,$03,$07,$05,$0F,$1D,$3F,$3F
        .byte   $3E,$1F,$0F,$07,$0F,$1F,$3F,$3F,$3F,$1F,$0F,$70,$F5,$F0,$04,$F5
        .byte   $E0,$E0,$20,$C8,$30,$10,$10,$10,$20,$E0,$E0,$10,$10,$38,$BC,$7C
        .byte   $3C,$F8,$E0,$F0,$F0,$F8,$FC,$FC,$FC,$F8,$E0,$00,$13,$17,$0F,$08
        .byte   $07,$0F,$1F,$00,$1B,$1F,$F5,$0F,$04,$F5,$1F,$1F,$17,$0F,$07,$0B
        .byte   $07,$05,$04,$1D,$1D,$08,$0C,$0E,$04,$06,$07,$00,$E0,$F2,$F7,$F6
        .byte   $2E,$DC,$FC,$00,$E0,$F6,$FD,$FE,$FA,$FC,$DC,$CE,$D0,$EE,$DC,$B8
        .byte   $B0,$58,$68,$FE,$7E,$3E,$7C,$F8,$78,$E8,$F8,$03,$01,$06,$07,$0F
        .byte   $0F,$13,$11,$02,$02,$05,$05,$08,$0D,$1F,$1F,$11,$13,$33,$7B,$6B
        .byte   $47,$3F,$1F,$1F,$1F,$3F,$7F,$7F,$7F,$3F,$1F,$E8,$F5,$F0,$04,$F5
        .byte   $B0,$C8,$C8,$98,$90,$70,$10,$90,$D0,$F8,$F8,$D8,$E8,$DC,$FE,$FE
        .byte   $FE,$FC,$F0,$F8,$F8,$FC,$FE,$FE,$FE,$FC,$F0,$00,$F5,$17,$04,$F5
        .byte   $1F,$2C,$3F,$00,$1F,$1D,$1D,$1D,$0D,$3F,$3E,$7F,$0F,$46,$24,$1C
        .byte   $76,$FA,$DE,$7E,$7F,$7F,$3F,$1F,$7F,$97,$A7,$08,$CE,$EE,$FC,$F4
        .byte   $E8,$F8,$F8,$18,$DA,$FA,$F4,$FC,$F8,$E8,$F8,$FA,$FA,$FC,$F4,$64
        .byte   $F4,$F8,$F8,$DE,$AE,$8C,$DC,$FC,$DC,$A8,$88,$45,$39,$0B,$0F,$07
        .byte   $07,$03,$02,$7F,$3F,$0D,$09,$05,$04,$03,$03,$06,$0A,$3F,$7F,$7E
        .byte   $7F,$3F,$0F,$07,$0F,$3F,$7F,$7F,$7F,$3F,$0F,$F5,$68,$04,$F5,$70
        .byte   $E0,$A0,$60,$D8,$F8,$F8,$F8,$F0,$E0,$E0,$E0,$20,$38,$3C,$7E,$9E
        .byte   $5E,$FC,$F8,$E0,$F8,$FC,$FE,$FE,$FE,$FC,$F8,$1F,$17,$17,$17,$1F
        .byte   $2C,$3F,$7F,$17,$1D,$1D,$1D,$0D,$3F,$3E,$7E,$0F,$66,$34,$1C,$16
        .byte   $3A,$6E,$65,$7F,$7F,$3F,$1F,$1F,$37,$57,$5F,$DE,$EE,$FC,$F4,$E8
        .byte   $F8,$F8,$FA,$CA,$FA,$F4,$FC,$F8,$E8,$F8,$DE,$FA,$FC,$F4,$64,$F4
        .byte   $F8,$F8,$68,$AE,$8C,$DC,$FC,$DC,$A8,$88,$D8,$39,$0B,$0F,$F5,$07
        .byte   $04,$F5,$04,$3F,$0D,$09,$05,$04,$04,$07,$07,$09,$0C,$1C,$3A,$3C
        .byte   $3E,$1F,$07,$0F,$0F,$1F,$3F,$3F,$3F,$1F,$07,$68,$68,$68,$70,$E0
        .byte   $E0,$E0,$A0,$F8,$F8,$F8,$F0,$A0,$A0,$E0,$E0,$A0,$B0,$F8,$FC,$7C
        .byte   $7C,$F8,$F0,$E0,$F0,$F8,$FC,$FC,$FC,$F8,$F0,$00,$F5,$17,$04,$F5
        .byte   $1F,$2C,$3F,$00,$1F,$1D,$1D,$1D,$0D,$3F,$3E,$7F,$0F,$76,$3A,$1A
        .byte   $16,$1E,$2E,$7E,$7F,$7F,$3F,$1F,$1F,$13,$33,$08,$CE,$EE,$FC,$F4
        .byte   $E8,$F8,$F8,$18,$DA,$FA,$F4,$FC,$F8,$E8,$F8,$FA,$FA,$FC,$F4,$64
        .byte   $F4,$F8,$F8,$DE,$AE,$8C,$DC,$FC,$DC,$A8,$88,$25,$19,$0B,$0F,$0F
        .byte   $0B,$09,$09,$3F,$1F,$0D,$09,$09,$0F,$0F,$0F,$09,$17,$39,$7F,$7F
        .byte   $7F,$3F,$0F,$0F,$1F,$3F,$7F,$7F,$7F,$3F,$0F,$F5,$68,$04,$F5,$70
        .byte   $F0,$C8,$B8,$D8,$F8,$F8,$F8,$D0,$B0,$F8,$F8,$88,$C8,$CC,$CE,$DE
        .byte   $AE,$CC,$F8,$F8,$F8,$FC,$FE,$FE,$FE,$FC,$F8,$F5,$F5,$25,$2E,$44
        .byte   $00,$AA,$44,$25,$00,$05,$EE,$02,$44,$01,$00,$24,$25,$01,$03,$06
        .byte   $0B,$25,$00,$05,$25,$01,$03,$07,$25,$00,$04,$01,$01,$03,$08,$01
        .byte   $05,$05,$02,$07,$03,$25,$CB,$4B,$CB,$4E,$FD,$05,$01,$01,$45,$C5
        .byte   $4D,$CF,$77,$DF,$BF,$FB,$FF,$FF,$F7,$E3,$C7,$72,$EE,$65,$52,$8A
        .byte   $9E,$3F,$7E,$9F,$69,$C0,$C0,$25,$00,$04,$25,$F9,$EF,$C0,$40,$25
        .byte   $00,$0B,$01,$01,$00,$08,$25,$01,$02,$03,$25,$00,$05,$01,$02,$03
        .byte   $01,$00,$05,$25,$04,$06,$25,$0E,$06,$25,$06,$0C,$25,$04,$04,$05
        .byte   $02,$0F,$02,$25,$1F,$1E,$CE,$4E,$D3,$4D,$05,$04,$04,$05,$55,$D5
        .byte   $5F,$DF,$BF,$FF,$EE,$FF,$FF,$FF,$D6,$AF,$6A,$5B,$55,$6A,$B2,$A3
        .byte   $7F,$F7,$7F,$A9,$80,$25,$00,$05,$25,$E9,$BF,$25,$00,$19,$25,$98
        .byte   $90,$98,$90,$D8,$00,$00,$00,$10,$18,$90,$98,$50,$D8,$E8,$25,$F8
        .byte   $04,$25,$38,$9C,$70,$B8,$30,$50,$88,$C8,$E0,$F0,$EC,$16,$1B,$06
        .byte   $01,$00,$00,$00,$F8,$1C,$16,$07,$01,$00,$00,$00,$02,$03,$03,$03
        .byte   $07,$07,$06,$06,$03,$02,$02,$06,$02,$02,$03,$03,$07,$07,$0F,$0E
        .byte   $0E,$1E,$1B,$35,$03,$04,$04,$05,$15,$15,$1F,$2F,$3F,$3F,$36,$3F
        .byte   $1F,$3F,$2A,$3F,$3A,$2B,$2D,$2A,$12,$23,$3F,$37,$1F,$29,$40,$25
        .byte   $00,$05,$25,$29,$7F,$40,$25,$00,$18,$25,$B0,$A0,$B0,$A0,$F0,$00
        .byte   $00,$00,$20,$30,$A0,$B0,$60,$B0,$D0,$25,$F0,$04,$25,$30,$98,$E0
        .byte   $70,$20,$50,$90,$C0,$E0,$F0,$EC,$34,$14,$02,$25,$00,$04,$25,$F8
        .byte   $2C,$16,$02,$25,$00,$05,$25,$01,$00,$03,$25,$00,$06,$25,$01,$03
        .byte   $25,$00,$15,$02,$01,$03,$03,$07,$02,$25,$4F,$02,$00,$01,$01,$05
        .byte   $05,$01,$09,$07,$47,$1F,$5B,$7F,$77,$6B,$5E,$4D,$1A,$73,$36,$2A
        .byte   $4F,$1E,$3F,$AF,$40,$C0,$25,$00,$05,$25,$69,$C0,$80,$25,$00,$16
        .byte   $02,$04,$25,$06,$13,$03,$02,$00,$00,$00,$04,$00,$01,$16,$17,$17
        .byte   $1F,$1D,$1B,$37,$20,$40,$01,$0D,$0A,$13,$06,$0D,$10,$20,$25,$00
        .byte   $04,$02,$03,$03,$01,$00,$03,$02,$01,$00,$03,$25,$01,$0B,$0F,$0F
        .byte   $0B,$17,$00,$00,$00,$03,$05,$0A,$06,$0D,$10,$25,$00,$07,$28,$02
        .byte   $38,$01,$00,$07,$25,$10,$7C,$54,$28,$25,$00,$05,$28,$02,$82,$01
        .byte   $00,$0C,$10,$01,$00,$08,$38,$01,$00,$16,$10,$01,$00,$1A,$01,$02
        .byte   $00,$03,$01,$01,$00,$02,$01,$02,$00,$02,$25,$01,$03,$06,$01,$02
        .byte   $04,$25,$00,$04,$07,$02,$25,$0E,$1C,$25,$00,$04,$02,$06,$25,$07
        .byte   $04,$25,$06,$06,$0F,$02,$25,$0B,$0F,$3F,$EF,$77,$DF,$4F,$C7,$1F
        .byte   $1F,$2F,$7E,$FA,$58,$FC,$7E,$EB,$D7,$F9,$FF,$D1,$F1,$F1,$D1,$7C
        .byte   $FE,$3F,$2F,$FF,$7F,$7F,$7F,$FF,$CE,$C0,$C0,$25,$00,$04,$25,$79
        .byte   $4E,$40,$40,$25,$00,$04,$44,$02,$25,$00,$AA,$44,$25,$00,$04,$AA
        .byte   $01,$EE,$02,$44,$01,$00,$15,$10,$02,$25,$38,$10,$00,$00,$00,$10
        .byte   $28,$6C,$44,$6C,$7C,$38,$25,$00,$08,$38,$01,$10,$02,$00,$07,$10
        .byte   $01,$38,$04,$10,$02,$25,$38,$6C,$44,$C6,$C6,$C6,$EE,$25,$00,$08
        .byte   $7C,$03,$38,$02,$10,$03,$00,$07,$03,$01,$00,$05,$01,$04,$25,$04
        .byte   $0F,$0C,$07,$0D,$05,$0F,$03,$03,$0E,$07,$0F,$07,$0F,$07,$0D,$0D
        .byte   $0F,$0E,$0D,$0F,$0D,$0F,$17,$37,$07,$07,$17,$16,$36,$37,$7D,$1C
        .byte   $2C,$40,$80,$00,$00,$00,$75,$74,$E4,$C0,$80,$25,$00,$03,$40,$05
        .byte   $25,$F0,$F8,$C4,$C0,$C0,$E0,$E0,$E0,$F0,$F8,$FC,$38,$FC,$FE,$FE
        .byte   $FA,$FC,$FE,$F4,$FC,$FC,$FE,$EE,$AE,$06,$8C,$DE,$7E,$3F,$CA,$BE
        .byte   $8A,$8A,$8A,$CB,$8D,$FD,$7E,$FE,$FE,$FF,$FF,$FF,$7E,$FF,$06,$25
        .byte   $00,$05,$25,$95,$FD,$04,$25,$00,$0E,$80,$01,$00,$05,$80,$01,$00
        .byte   $02,$25,$80,$40,$25,$00,$04,$80,$02,$25,$C0,$40,$25,$00,$09,$01
        .byte   $03,$00,$09,$25,$02,$01,$07,$02,$03,$02,$03,$01,$01,$03,$02,$07
        .byte   $06,$03,$02,$03,$07,$02,$06,$0B,$1F,$03,$0F,$06,$06,$03,$03,$06
        .byte   $06,$06,$0E,$07,$0B,$13,$20,$25,$00,$04,$25,$1E,$1A,$32,$20,$25
        .byte   $00,$04,$40,$05,$25,$70,$78,$70,$C0,$C0,$C0,$E0,$E0,$F0,$F8,$FC
        .byte   $CC,$BE,$7E,$7E,$FC,$FC,$FC,$F4,$FC,$FE,$FE,$FE,$D4,$84,$C8,$DC
        .byte   $B8,$98,$E6,$FE,$C4,$C4,$C6,$C4,$CC,$FE,$7E,$7C,$25,$FE,$04,$25
        .byte   $BC,$3A,$01,$25,$00,$05,$25,$CE,$3B,$01,$25,$00,$05,$01,$01,$03
        .byte   $08,$01,$05,$05,$02,$25,$07,$05,$0D,$05,$05,$17,$07,$0A,$05,$03
        .byte   $03,$0B,$0B,$0B,$07,$0F,$0C,$0F,$0D,$35,$77,$F7,$16,$16,$0F,$17
        .byte   $17,$25,$1F,$05,$0D,$01,$08,$03,$10,$01,$00,$03,$1D,$01,$18,$03
        .byte   $10,$01,$00,$08,$25,$C0,$F0,$F8,$25,$00,$05,$25,$C0,$F0,$F8,$E0
        .byte   $DC,$BC,$FC,$78,$F8,$78,$F0,$F8,$FC,$FC,$7C,$F8,$68,$C8,$50,$A0
        .byte   $B8,$F4,$6C,$64,$C4,$E4,$DA,$60,$58,$7C,$BC,$BC,$7C,$7C,$7E,$FD
        .byte   $FF,$C0,$C0,$25,$00,$04,$25,$67,$7F,$40,$40,$25,$00,$04,$25,$01
        .byte   $02,$25,$03,$03,$01,$04,$03,$01,$02,$03,$01,$04,$00,$07,$01,$01
        .byte   $00,$08,$25,$80,$8F,$57,$F7,$F7,$BB,$FA,$00,$80,$8F,$DF,$7F,$7F
        .byte   $7F,$3F,$DD,$D3,$D5,$FF,$E9,$76,$1E,$17,$3F,$BD,$BF,$BD,$BF,$7D
        .byte   $1D,$1D,$29,$3B,$57,$77,$77,$F7,$EB,$2F,$3E,$3E,$7E,$7A,$5E,$9E
        .byte   $FE,$3E,$29,$10,$25,$00,$06,$25,$39,$10,$25,$00,$09,$25,$C0,$E0
        .byte   $80,$70,$F0,$00,$00,$00,$C0,$E0,$E0,$25,$F0,$03,$E0,$03,$25,$F0
        .byte   $C8,$A8,$78,$F0,$E0,$A0,$20,$70,$D8,$38,$F8,$E8,$E8,$E4,$C4,$E4
        .byte   $EA,$D2,$D9,$F8,$B8,$BC,$FC,$FC,$FE,$FE,$FF,$26,$25,$00,$07,$26
        .byte   $01,$00,$08,$25,$0C,$0A,$05,$06,$03,$03,$01,$00,$0C,$0E,$07,$05
        .byte   $02,$02,$01,$25,$00,$10,$25,$57,$6F,$DF,$7F,$F4,$7B,$BF,$FB,$77
        .byte   $7F,$FF,$5F,$DF,$EF,$6B,$6F,$DF,$FF,$77,$3F,$2F,$34,$3C,$1F,$F6
        .byte   $F4,$7E,$33,$32,$2F,$27,$3C,$06,$79,$1B,$27,$C3,$02,$02,$01,$7F
        .byte   $7E,$7C,$E4,$C3,$03,$03,$01,$25,$00,$10,$25,$C8,$E8,$F0,$10,$E0
        .byte   $F0,$F8,$F8,$D8,$F8,$25,$F0,$04,$25,$F8,$B8,$E8,$F4,$E8,$D8,$F8
        .byte   $A0,$30,$B0,$BC,$1C,$38,$68,$28,$70,$F0,$70,$48,$BC,$8C,$8C,$88
        .byte   $C8,$C8,$D8,$F8,$25,$FC,$03,$F8,$04,$25,$A4,$A2,$5C,$25,$00,$05
        .byte   $25,$FC,$FE,$5C,$25,$00,$06,$25,$87,$4F,$2C,$2B,$1F,$3F,$2F,$00
        .byte   $C7,$6F,$3F,$3F,$1F,$2F,$3E,$37,$1F,$8F,$47,$2B,$29,$7C,$87,$3A
        .byte   $D8,$FC,$7E,$3C,$3E,$7F,$F4,$BB,$3C,$77,$16,$6F,$8A,$0E,$0A,$CC
        .byte   $4B,$79,$7B,$EB,$8F,$0F,$0F,$0A,$06,$03,$02,$01,$00,$00,$00,$0F
        .byte   $07,$03,$03,$01,$25,$00,$04,$25,$C2,$E4,$68,$A8,$F0,$F8,$E8,$00
        .byte   $C6,$EC,$F8,$F8,$F0,$E8,$F8,$D8,$F0,$E2,$C4,$A8,$28,$7C,$C2,$B8
        .byte   $36,$7E,$FC,$78,$F8,$FC,$5E,$3A,$F8,$D8,$70,$AC,$22,$20,$40,$E6
        .byte   $24,$B8,$DC,$EE,$E2,$E0,$C0,$40,$40,$C0,$40,$80,$25,$00,$03,$C0
        .byte   $04,$80,$01,$00,$04,$25,$4F,$5F,$3F,$23,$1C,$3F,$7F,$00,$6F,$7F
        .byte   $25,$3F,$04,$7F,$02,$25,$5F,$BF,$5F,$2F,$3E,$34,$71,$77,$F5,$E0
        .byte   $71,$3B,$31,$3B,$5F,$7F,$35,$1B,$1F,$27,$3B,$22,$23,$59,$3B,$14
        .byte   $18,$3E,$3F,$3E,$3F,$26,$26,$35,$56,$88,$70,$00,$00,$3F,$3F,$3F
        .byte   $7E,$F8,$70,$00,$00,$00,$80,$C8,$DC,$D8,$B8,$77,$F9,$00,$80,$D8
        .byte   $F4,$F8,$E8,$F7,$7F,$32,$4E,$94,$38,$60,$B0,$B8,$D4,$FE,$FA,$FC
        .byte   $F8,$F0,$F0,$D8,$FC,$DC,$FA,$C6,$C0,$80,$00,$00,$00,$34,$3E,$C6
        .byte   $40,$80,$00,$00,$00,$80,$80,$25,$00,$06,$80,$02,$00,$07,$25,$0F
        .byte   $3E,$7E,$1E,$ED,$F5,$FB,$00,$0F,$3F,$7F,$7F,$FF,$FF,$FF,$7D,$79
        .byte   $7B,$39,$16,$16,$2A,$7E,$7B,$5F,$4F,$2F,$1F,$0F,$3F,$79,$EF,$FF
        .byte   $71,$2D,$3F,$1F,$1F,$13,$91,$93,$7F,$33,$21,$11,$1D,$1F,$09,$08
        .byte   $08,$09,$15,$12,$26,$19,$25,$0F,$04,$1F,$02,$25,$3F,$19,$00,$00
        .byte   $B0,$F0,$F0,$E0,$A0,$F0,$00,$00,$90,$D0,$D0,$A0,$E0,$B0,$F8,$FC
        .byte   $FA,$BD,$DE,$BF,$9D,$9C,$68,$5C,$C6,$E3,$F9,$F6,$E5,$F4,$B8,$A0
        .byte   $A0,$A0,$C0,$00,$00,$00,$F8,$E0,$E0,$E0,$C0,$25,$00,$04,$80,$02
        .byte   $00,$02,$80,$02,$00,$02,$80,$02,$00,$02,$80,$02,$00,$15,$25,$80
        .byte   $C0,$A0,$60,$25,$00,$04,$25,$80,$40,$E0,$60,$00,$25,$2F,$04,$25
        .byte   $3F,$59,$7F,$00,$3F,$3B,$3B,$3B,$1B,$7F,$7D,$FF,$1F,$CD,$68,$38
        .byte   $2C,$76,$DF,$FD,$FF,$FF,$7F,$3F,$3F,$6D,$AE,$CB,$70,$16,$1F,$0F
        .byte   $0F,$07,$04,$BF,$7F,$19,$10,$08,$09,$07,$07,$04,$0C,$14,$0E,$06
        .byte   $05,$02,$01,$07,$0F,$1F,$0F,$07,$07,$03,$01,$10,$9C,$DC,$F8,$E8
        .byte   $D0,$F0,$F0,$30,$B4,$F4,$E8,$F8,$F0,$D0,$F0,$F4,$F4,$F8,$E8,$C8
        .byte   $64,$64,$34,$BC,$5C,$18,$B8,$F8,$FC,$FC,$FC,$BA,$DE,$F6,$F0,$C0
        .byte   $C0,$40,$C0,$76,$BA,$D6,$F0,$25,$C0,$04,$40,$04,$25,$C0,$20,$A0
        .byte   $25,$C0,$06,$E0,$02,$25,$C0,$10,$73,$77,$3F,$2F,$17,$1F,$1F,$18
        .byte   $5B,$5F,$2F,$3F,$1F,$17,$1F,$5F,$5F,$3F,$2F,$26,$2F,$1F,$1F,$7B
        .byte   $75,$31,$3B,$3F,$3B,$15,$11,$25,$16,$04,$25,$0E,$07,$05,$06,$1B
        .byte   $1F,$1F,$1F,$0F,$25,$07,$03,$04,$04,$25,$06,$09,$0A,$25,$07,$06
        .byte   $0F,$02,$25,$07,$00,$25,$E8,$04,$25,$F8,$34,$FC,$00,$F8,$B8,$B8
        .byte   $B8,$B0,$FC,$7C,$FE,$F0,$66,$2C,$38,$68,$5C,$76,$7E,$FE,$FE,$FC
        .byte   $F8,$F8,$EC,$EA,$A6,$9C,$D0,$F0,$E0,$E0,$C0,$40,$FA,$FC,$B0,$90
        .byte   $A0,$20,$C0,$C0,$40,$60,$50,$E0,$C0,$40,$80,$00,$C0,$E0,$F0,$E0
        .byte   $C0,$C0,$80,$00,$00,$01,$13,$3B,$1B,$1D,$0E,$0F,$00,$01,$1B,$2F
        .byte   $1F,$17,$0F,$0E,$1C,$02,$11,$08,$06,$05,$0D,$0B,$1F,$1F,$1F,$0F
        .byte   $07,$07,$0B,$0F,$0B,$03,$03,$03,$01,$01,$00,$00,$0C,$04,$03,$02
        .byte   $01,$01,$00,$00,$01,$02,$02,$01,$25,$00,$04,$01,$01,$03,$02,$01
        .byte   $01,$00,$04,$25,$FE,$AC,$D8,$F8,$F8,$F8,$C8,$88,$9A,$DC,$28,$18
        .byte   $18,$38,$F8,$F8,$88,$88,$C8,$C8,$58,$54,$22,$1C,$25,$F8,$04,$25
        .byte   $78,$7C,$7E,$1C,$B9,$3E,$37,$17,$0F,$0F,$0C,$08,$CE,$49,$38,$18
        .byte   $08,$08,$0B,$0F,$08,$08,$04,$04,$04,$07,$04,$03,$0F,$0F,$25,$07
        .byte   $05,$25,$03,$BA,$78,$58,$D0,$E0,$A0,$E0,$A0,$66,$A4,$B8,$B0,$A0
        .byte   $E0,$E0,$E0,$A0,$A0,$C0,$25,$80,$04,$00,$01,$E0,$02,$C0,$01,$80
        .byte   $04,$25,$00,$25,$25,$0B,$0D,$00,$00,$00,$01,$09,$03,$07,$1F,$00
        .byte   $01,$03,$0A,$16,$0C,$38,$60,$07,$03,$05,$09,$11,$00,$00,$00,$38
        .byte   $1C,$1A,$16,$0A,$01,$00,$00,$00,$06,$0F,$19,$33,$31,$10,$24,$0F
        .byte   $39,$70,$66,$CC,$CE,$6F,$5B,$27,$03,$10,$3A,$1D,$09,$00,$00,$58
        .byte   $3C,$EF,$C5,$62,$36,$1F,$06,$00,$00,$30,$30,$06,$04,$60,$40,$03
        .byte   $11,$4F,$88,$B0,$12,$00,$22,$00,$06,$06,$00,$18,$0C,$01,$00,$44
        .byte   $40,$11,$B8,$84,$42,$10,$03,$00,$00,$00,$48,$02,$04,$01,$04,$00
        .byte   $02,$00,$48,$02,$16,$01,$14,$02,$24,$00,$22,$04,$00,$00,$00,$42
        .byte   $24,$12,$22,$0C,$00,$02,$00,$00,$00,$01,$02,$04,$08,$10,$20,$00
        .byte   $00,$00,$01,$03,$05,$0C,$1A,$20,$0B,$40,$03,$80,$04,$0B,$10,$24
        .byte   $28,$24,$50,$40,$48,$40,$0F,$70,$80,$0B,$00,$06,$0B,$0F,$70,$84
        .byte   $20,$02,$20,$0B,$00,$09,$80,$01,$00,$0D,$0B,$18,$3C,$0B,$00,$05
        .byte   $0B,$18,$24,$42,$3C,$18,$0B,$00,$06,$0B,$42,$24,$18,$0B,$00,$05
        .byte   $0B,$0B,$05,$06,$00,$00,$07,$1A,$15,$3A,$35,$2B,$00,$00,$07,$1F
        .byte   $1F,$3D,$3A,$3C,$33,$2D,$36,$1A,$1D,$07,$00,$00,$3C,$3A,$3D,$1F
        .byte   $1F,$07,$00,$00,$07,$1E,$35,$5D,$7A,$C5,$AB,$D7,$07,$1F,$3F,$7A
        .byte   $75,$FA,$F4,$E8,$B7,$CB,$E5,$5A,$69,$36,$1D,$07,$E8,$F4,$FA,$75
        .byte   $7E,$3D,$1F,$07,$05,$00,$07,$01,$01,$00,$06,$05,$01,$02,$03,$07
        .byte   $0E,$1C,$38,$70,$E0,$C0,$04,$08,$11,$22,$44,$88,$10,$20,$05,$00
        .byte   $07,$FF,$01,$00,$06,$05,$FF,$00,$FF,$05,$00,$08,$FF,$01,$00,$06
        .byte   $18,$08,$24,$08,$18,$08,$24,$08,$05,$05,$01,$02,$01,$00,$04,$01
        .byte   $60,$C8,$D4,$62,$01,$00,$04,$01,$60,$F8,$BC,$BE,$72,$1D,$0F,$06
        .byte   $01,$00,$04,$01,$4E,$27,$1B,$0E,$01,$00,$08,$01,$18,$0C,$3C,$0C
        .byte   $01,$00,$04,$01,$18,$30,$3C,$30,$0C,$3C,$0C,$18,$01,$00,$04,$01
        .byte   $30,$3C,$30,$18,$01,$00,$0A,$01,$24,$A5,$01,$00,$06,$7E,$01,$FF
        .byte   $02,$7E,$01,$00,$06,$01,$A5,$24,$01,$00,$06,$01,$01,$06,$0C,$06
        .byte   $00,$0E,$02,$01,$00,$07,$06,$01,$00,$0A,$01,$01,$17,$03,$03,$16
        .byte   $07,$06,$00,$07,$04,$01,$00,$03,$06,$12,$80,$27,$3F,$7B,$00,$2E
        .byte   $9F,$7D,$EF,$7E,$57,$3F,$FF,$D1,$60,$82,$10,$81,$A8,$C0,$06,$00
        .byte   $0A,$06,$01,$08,$00,$01,$17,$4F,$00,$01,$08,$05,$03,$15,$0B,$03
        .byte   $0F,$1E,$97,$1A,$BC,$2A,$74,$BC,$06,$00,$04,$06,$08,$02,$A4,$19
        .byte   $09,$00,$21,$1F,$F7,$FD,$5B,$E6,$AD,$7F,$DD,$F7,$BF,$FB,$5F,$FF
        .byte   $52,$80,$22,$08,$40,$04,$A0,$00,$06,$06,$03,$04,$00,$00,$01,$02
        .byte   $05,$0A,$14,$29,$03,$00,$08,$03,$2A,$52,$54,$55,$B5,$03,$AA,$03
        .byte   $00,$08,$03,$0F,$70,$8F,$70,$87,$38,$C7,$18,$03,$00,$08,$60,$01
        .byte   $80,$02,$00,$0D,$03,$03,$FE,$FF,$00,$10,$FE,$38,$06,$FE,$10,$28
        .byte   $FE,$44,$06,$10,$06,$00,$02,$28,$06,$10,$02,$FE,$FE,$04,$05,$04
        .byte   $00,$10,$04,$40,$E1,$E0,$E1,$F0,$B7,$BF,$DF,$40,$E1,$61,$61,$71
        .byte   $77,$7F,$3F,$0F,$3E,$3F,$5F,$7F,$FE,$FE,$FC,$0F,$39,$2E,$6E,$5E
        .byte   $BD,$BD,$BB,$FD,$7D,$3F,$39,$7F,$7B,$71,$A4,$7B,$F3,$F0,$C7,$81
        .byte   $84,$8F,$DB,$FE,$83,$3E,$7E,$7E,$7F,$FE,$FC,$FE,$FF,$F9,$FF,$FF
        .byte   $FE,$FD,$FF,$FB,$E7,$1F,$FC,$FD,$FB,$FA,$FB,$F7,$DF,$FF,$FF,$7E
        .byte   $3C,$DD,$FC,$00,$80,$80,$90,$E8,$F8,$FC,$6C,$00,$80,$80,$F0,$F8
        .byte   $F8,$FC,$FC,$9E,$EE,$F6,$76,$3E,$1C,$1A,$1C,$04,$FE,$05,$FC,$01
        .byte   $FE,$02,$04,$EB,$EF,$F6,$AD,$7B,$7A,$46,$C8,$1F,$1F,$BF,$7E,$3C
        .byte   $7D,$79,$F7,$BA,$E7,$CF,$FF,$3F,$1F,$06,$00,$C5,$9F,$B6,$96,$57
        .byte   $3F,$1F,$00,$7D,$4B,$9F,$FF,$77,$7F,$FD,$DD,$8B,$BC,$6F,$26,$BF
        .byte   $B9,$5E,$FA,$FD,$FA,$FC,$F1,$E7,$08,$F0,$00,$EA,$ED,$BB,$CF,$DF
        .byte   $FF,$F0,$00,$E6,$F6,$F8,$E1,$57,$E7,$8F,$9F,$D9,$C9,$C7,$1F,$AF
        .byte   $1F,$7F,$7F,$1F,$3C,$73,$EC,$C0,$00,$00,$00,$FE,$FB,$FF,$FC,$F0
        .byte   $80,$00,$00,$3C,$7C,$FC,$FC,$F8,$FA,$F0,$CC,$FE,$FE,$FF,$FE,$FE
        .byte   $F6,$EC,$BC,$30,$C0,$04,$00,$06,$04,$F0,$C0,$04,$00,$08,$04,$01
        .byte   $02,$0F,$1A,$14,$1A,$00,$00,$01,$03,$0F,$1F,$1F,$17,$20,$3C,$3E
        .byte   $27,$47,$53,$49,$6F,$3F,$33,$3D,$3C,$7F,$6F,$77,$7F,$1F,$35,$EA
        .byte   $F5,$FD,$7E,$B8,$58,$1F,$3F,$DF,$EF,$F3,$FF,$FF,$FF,$BC,$16,$0F
        .byte   $5C,$F8,$FB,$FF,$FF,$FF,$EF,$F7,$BF,$9F,$FF,$55,$FF,$00,$00,$07
        .byte   $18,$39,$2E,$5F,$47,$00,$00,$07,$1F,$3E,$3F,$67,$7E,$6C,$72,$C7
        .byte   $8E,$FB,$EF,$7F,$FF,$7B,$7F,$BF,$FF,$BE,$FB,$EF,$FF,$3A,$E8,$3F
        .byte   $E5,$47,$8E,$F4,$EA,$25,$DF,$FF,$7F,$FC,$F9,$FB,$75,$6F,$FB,$BB
        .byte   $BF,$04,$FF,$05,$04,$FD,$DD,$D9,$DD,$FF,$FF,$FF,$04,$04,$0B,$0C
        .byte   $0B,$00,$04,$0B,$D0,$AA,$5C,$62,$00,$00,$05,$05,$E2,$DF,$BF,$BF
        .byte   $A5,$DA,$4D,$65,$A7,$B3,$93,$73,$7B,$7D,$FE,$FE,$FE,$DF,$FF,$FF
        .byte   $0B,$00,$05,$0B,$80,$C0,$66,$28,$28,$10,$11,$09,$98,$48,$BE,$9B
        .byte   $CB,$49,$3D,$67,$99,$23,$4E,$ED,$FD,$FE,$FF,$FB,$E7,$DF,$BF,$0B
        .byte   $00,$0B,$0B,$40,$C0,$82,$85,$46,$00,$00,$80,$00,$70,$70,$30,$A4
        .byte   $88,$90,$E0,$F0,$B8,$B8,$FE,$79,$7A,$4A,$6B,$2B,$6B,$49,$5C,$D1
        .byte   $F7,$F7,$F6,$F6,$F7,$F7,$E3,$EE,$A6,$5B,$90,$73,$C4,$68,$41,$17
        .byte   $DF,$BF,$7F,$FC,$FB,$97,$BF,$FF,$3E,$CC,$B9,$48,$39,$F3,$02,$DE
        .byte   $FF,$FF,$CE,$BF,$FF,$FF,$FF,$2D,$74,$C9,$67,$D8,$31,$63,$C6,$91
        .byte   $FB,$F7,$9F,$3F,$FE,$FC,$F9,$EF,$6A,$56,$D4,$AC,$8B,$7B,$F7,$73
        .byte   $F7,$EF,$EF,$DF,$FF,$BF,$6B,$FD,$F4,$9E,$16,$24,$CD,$1F,$73,$C1
        .byte   $FB,$FD,$ED,$DF,$3E,$FF,$FF,$FE,$0B,$00,$08,$0B,$06,$18,$66,$40
        .byte   $40,$C0,$A0,$A6,$80,$80,$A0,$A0,$C0,$A0,$00,$00,$EC,$E6,$F0,$F0
        .byte   $E0,$C0,$C0,$D0,$0B,$00,$04,$0B,$10,$29,$54,$2E,$00,$11,$09,$38
        .byte   $6B,$DA,$B7,$FF,$22,$59,$4A,$4A,$AD,$A4,$96,$73,$FF,$FF,$FD,$FD
        .byte   $DE,$DF,$EF,$FF,$0B,$00,$06,$0B,$B0,$98,$05,$45,$C2,$82,$84,$D4
        .byte   $7C,$7C,$4D,$2B,$8A,$61,$43,$E9,$92,$8E,$BB,$DD,$FD,$FF,$FF,$D7
        .byte   $EF,$FF,$0B,$00,$0B,$0B,$28,$38,$10,$10,$A0,$80,$80,$80,$10,$70
        .byte   $6C,$2C,$C4,$C3,$E4,$EB,$F8,$B8,$B4,$F4,$7D,$92,$94,$95,$D7,$56
        .byte   $D6,$93,$B8,$FF,$EF,$EF,$ED,$ED,$EF,$EF,$C7,$A3,$4C,$B7,$20,$E6
        .byte   $88,$D0,$83,$DC,$BF,$7F,$FF,$F9,$F7,$2F,$7F,$BE,$49,$99,$33,$55
        .byte   $73,$EE,$05,$7F,$FF,$FF,$DD,$BB,$FF,$F7,$FE,$BA,$ED,$83,$4E,$30
        .byte   $62,$C7,$8D,$5D,$F3,$FF,$BF,$FF,$FD,$F9,$F3,$84,$94,$1A,$3C,$3B
        .byte   $67,$B2,$31,$FF,$EF,$ED,$DB,$FF,$FE,$EF,$FF,$35,$12,$58,$5B,$D5
        .byte   $7F,$F3,$C1,$FB,$FD,$BF,$BD,$3B,$FF,$FF,$FE,$00,$00,$80,$80,$80
        .byte   $00,$40,$40,$00,$00,$98,$E4,$47,$C2,$E3,$E0,$80,$00,$A0,$A0,$C0
        .byte   $B0,$30,$20,$E0,$E0,$73,$F2,$E7,$D8,$F0,$F0,$98,$C9,$0F,$F8,$62
        .byte   $4F,$CF,$DF,$7F,$3F,$FF,$FF,$FD,$F0,$F0,$E0,$4F,$6F,$E7,$99,$04
        .byte   $9B,$71,$93,$F0,$F0,$F8,$FE,$FF,$7F,$FF,$FF,$0F,$F0,$0A,$B7,$FE
        .byte   $0B,$FF,$05,$0B,$F5,$48,$01,$00,$70,$F8,$FF,$FF,$FF,$FD,$7F,$8A
        .byte   $E0,$1F,$F8,$98,$70,$02,$80,$F5,$FF,$FF,$F0,$0F,$C4,$FB,$DF,$F7
        .byte   $DF,$FF,$FF,$FF,$3B,$04,$20,$08,$20,$00,$FF,$FD,$FE,$FF,$EA,$F1
        .byte   $07,$F8,$00,$02,$01,$00,$15,$0F,$FF,$FF,$19,$93,$F0,$9F,$46,$D2
        .byte   $93,$D3,$FE,$FC,$FF,$7F,$BF,$2F,$6F,$2F,$E2,$D6,$A7,$59,$20,$D9
        .byte   $8E,$C9,$1F,$2F,$5F,$BF,$FF,$FE,$FF,$FF,$98,$C9,$0F,$F9,$65,$57
        .byte   $EE,$DF,$7F,$3F,$FF,$FE,$FA,$E8,$D1,$E0,$57,$6F,$EA,$9D,$0F,$9B
        .byte   $71,$93,$E8,$F0,$F5,$FA,$FE,$7F,$FF,$FF,$0F,$F2,$55,$FF,$BF,$0B
        .byte   $FF,$04,$0B,$FD,$AA,$00,$40,$00,$00,$03,$0B,$FF,$05,$0B,$BE,$FB
        .byte   $1F,$06,$07,$03,$00,$00,$C1,$F4,$FF,$98,$C9,$0F,$F8,$66,$69,$D4
        .byte   $DF,$7F,$3F,$FF,$FF,$FF,$F7,$EB,$E0,$4E,$6B,$E7,$9A,$05,$9B,$71
        .byte   $93,$F1,$F4,$F8,$FD,$FE,$7F,$FF,$FF,$0F,$F0,$20,$C5,$3F,$DF,$E4
        .byte   $1F,$FF,$FF,$FF,$FA,$FF,$E2,$FF,$FF,$E7,$FF,$FF,$BF,$F7,$FF,$ED
        .byte   $1F,$1E,$07,$03,$40,$08,$80,$F2,$FF,$98,$C9,$0F,$F8,$60,$60,$F8
        .byte   $CD,$7F,$3F,$0B,$FF,$04,$0B,$DF,$FE,$5A,$65,$E6,$9E,$04,$9B,$71
        .byte   $93,$F7,$FF,$FD,$FD,$FF,$7F,$FF,$FF,$0F,$F0,$30,$07,$2C,$97,$EA
        .byte   $18,$FF,$FF,$FF,$FA,$D3,$68,$15,$E7,$2A,$82,$F8,$DF,$A4,$B6,$E2
        .byte   $1F,$D5,$FD,$FF,$BF,$FF,$ED,$FF,$FF,$0B,$0B,$F3,$F9,$01,$01,$02
        .byte   $03,$02,$05,$05,$05,$01,$01,$03,$02,$03,$07,$07,$06,$0D,$0A,$0B
        .byte   $09,$0E,$0E,$0B,$13,$0E,$0F,$0F,$0F,$0D,$0D,$0E,$1F,$13,$1B,$15
        .byte   $1A,$1E,$07,$2B,$21,$1F,$1D,$1E,$1D,$1F,$1F,$3F,$3F,$2C,$33,$6C
        .byte   $76,$FE,$EB,$E0,$C1,$3B,$3D,$7B,$7F,$F3,$FF,$04,$F3,$D5,$E2,$D5
        .byte   $E3,$DF,$FF,$FB,$F5,$FA,$FD,$FA,$F3,$FF,$05,$F3,$E8,$D5,$E4,$CA
        .byte   $A0,$C7,$BE,$FA,$FF,$FA,$FB,$F5,$F3,$FF,$04,$F3,$FC,$F2,$E9,$D5
        .byte   $EA,$D5,$A2,$F5,$F3,$FF,$04,$F3,$F7,$FA,$FD,$FA,$FC,$F2,$E8,$DA
        .byte   $E5,$DA,$A1,$D5,$FF,$FF,$FF,$FD,$FA,$F5,$FE,$FA,$55,$62,$55,$61
        .byte   $58,$7D,$7B,$35,$7A,$7D,$7A,$F3,$7F,$04,$F3,$3F,$DF,$B9,$B6,$AF
        .byte   $AF,$96,$49,$26,$E3,$C7,$CF,$DD,$DF,$EF,$76,$39,$CA,$B7,$80,$22
        .byte   $11,$06,$A5,$53,$FD,$FE,$7F,$DF,$EF,$FD,$FA,$FE,$A2,$D9,$FA,$69
        .byte   $74,$BE,$7E,$FF,$FD,$FF,$FD,$FE,$BF,$7F,$FF,$FF,$F3,$00,$05,$F3
        .byte   $02,$05,$0D,$F3,$00,$05,$F3,$03,$06,$0B,$1A,$08,$28,$18,$10,$00
        .byte   $20,$43,$16,$18,$38,$38,$30,$20,$61,$42,$1B,$0A,$14,$58,$B2,$6D
        .byte   $8B,$96,$1F,$0E,$1C,$7B,$77,$EF,$8F,$9E,$2E,$2C,$55,$30,$E2,$62
        .byte   $41,$C6,$3E,$1C,$35,$71,$63,$E3,$C3,$C5,$F6,$4D,$96,$40,$CA,$9C
        .byte   $2E,$74,$FF,$7F,$FA,$EF,$CE,$92,$32,$68,$CC,$AC,$78,$F0,$60,$C0
        .byte   $80,$80,$FC,$DC,$B8,$70,$E0,$C0,$80,$80,$00,$07,$05,$06,$0E,$0E
        .byte   $02,$04,$03,$05,$07,$02,$0A,$0A,$0E,$0C,$04,$00,$08,$08,$F3,$00
        .byte   $04,$F3,$0C,$08,$08,$08,$F3,$00,$04,$F3,$85,$05,$0F,$08,$02,$0E
        .byte   $08,$08,$87,$03,$0B,$0E,$0E,$0A,$0E,$0E,$05,$05,$04,$02,$02,$00
        .byte   $00,$00,$07,$07,$06,$02,$02,$00,$00,$00,$01,$02,$05,$0B,$06,$15
        .byte   $0C,$1A,$01,$03,$07,$0F,$0F,$1E,$1F,$3B,$6D,$93,$E5,$23,$EE,$02
        .byte   $4E,$C4,$5E,$F5,$A7,$E5,$6A,$CE,$C6,$4C,$FE,$CD,$97,$01,$4F,$D8
        .byte   $8A,$34,$FF,$FF,$FB,$EF,$CB,$D6,$96,$2C,$04,$2C,$08,$18,$28,$60
        .byte   $68,$38,$3C,$1C,$38,$38,$38,$50,$78,$58,$5C,$4C,$5C,$5C,$54,$C4
        .byte   $48,$CC,$D4,$DC,$D4,$D4,$DC,$CC,$CC,$CE,$06,$42,$02,$02,$F3,$00
        .byte   $04,$F3,$46,$42,$02,$02,$F3,$00,$04,$F3,$58,$70,$50,$70,$10,$30
        .byte   $10,$10,$78,$50,$70,$50,$30,$10,$30,$30,$20,$20,$10,$08,$00,$08
        .byte   $00,$00,$30,$30,$10,$18,$08,$08,$00,$00,$3F,$13,$11,$11,$05,$0D
        .byte   $0D,$05,$3F,$1F,$1D,$1D,$1D,$15,$15,$1D,$0D,$02,$06,$06,$02,$00
        .byte   $03,$01,$15,$0E,$0A,$02,$06,$06,$05,$07,$BD,$BB,$B5,$BA,$F4,$B9
        .byte   $B5,$A8,$FF,$FF,$7F,$7F,$FF,$7F,$FF,$6E,$E2,$E8,$8E,$CC,$CA,$8C
        .byte   $A8,$CE,$6E,$AE,$CC,$AE,$AC,$EE,$CE,$EC,$01,$00,$02,$F3,$00,$05
        .byte   $03,$03,$01,$03,$00,$12,$F3,$E4,$D6,$E4,$D0,$78,$6A,$78,$0A,$C6
        .byte   $E4,$D6,$66,$EA,$F8,$EA,$DA,$4A,$9A,$D8,$48,$42,$44,$32,$08,$98
        .byte   $DA,$9A,$0A,$6A,$64,$32,$18,$F3,$F3,$02,$04,$00,$00,$06,$0C,$34
        .byte   $78,$50,$A0,$00,$00,$06,$0E,$3A,$64,$68,$D0,$02,$A0,$05,$02,$90
        .byte   $DF,$56,$D0,$D0,$D0,$D8,$DC,$EE,$E3,$6F,$02,$00,$13,$02,$07,$38
        .byte   $F2,$95,$2F,$00,$00,$00,$07,$3F,$FD,$FA,$DC,$60,$C0,$60,$F9,$BF
        .byte   $56,$24,$3A,$20,$40,$A0,$99,$C7,$6F,$3F,$3D,$31,$3D,$31,$6A,$59
        .byte   $8F,$BF,$FF,$3E,$3F,$3E,$75,$66,$F0,$F8,$FE,$DC,$A8,$98,$C8,$F8
        .byte   $28,$45,$83,$EF,$DF,$EF,$FF,$FF,$FF,$BF,$7F,$47,$AF,$D9,$F0,$F2
        .byte   $F7,$F7,$FB,$BF,$DF,$FF,$7F,$3D,$38,$79,$FD,$1F,$AF,$5F,$BF,$7F
        .byte   $F3,$D9,$2F,$E6,$5F,$BF,$78,$B0,$FD,$BF,$DF,$17,$AE,$97,$C3,$65
        .byte   $30,$9C,$DF,$EF,$D1,$E8,$FC,$FA,$FF,$7F,$BF,$80,$C0,$C1,$A1,$E3
        .byte   $B3,$DF,$66,$80,$C0,$C1,$E1,$A3,$F3,$BF,$5F,$73,$78,$24,$36,$1A
        .byte   $0D,$07,$03,$4F,$67,$3B,$39,$1D,$0F,$07,$03,$EF,$CF,$EB,$E7,$B1
        .byte   $1F,$18,$5E,$FF,$FF,$F7,$FB,$FF,$FF,$FF,$AF,$23,$9D,$AE,$9C,$99
        .byte   $39,$BD,$D9,$DF,$E2,$D1,$E3,$E7,$C7,$C3,$E7,$B9,$DC,$BF,$DF,$AB
        .byte   $43,$26,$9B,$DE,$A7,$C3,$A3,$D7,$BF,$DF,$FF,$FB,$D1,$89,$6C,$FF
        .byte   $E3,$C1,$C4,$FF,$3F,$7E,$02,$FF,$04,$02,$FB,$BF,$77,$FF,$FF,$FA
        .byte   $D7,$FA,$53,$78,$E8,$C0,$E0,$9D,$2E,$07,$AF,$0F,$DF,$F8,$F3,$B7
        .byte   $57,$AB,$D7,$FF,$FF,$FF,$7C,$79,$B9,$DC,$EF,$CC,$DC,$77,$61,$65
        .byte   $49,$59,$93,$F3,$FF,$7F,$7F,$7B,$77,$67,$EF,$A7,$A4,$EA,$DB,$BD
        .byte   $A5,$E2,$C1,$DF,$DF,$9D,$BC,$FE,$E6,$E3,$C1,$CF,$EF,$6F,$B6,$98
        .byte   $5F,$47,$E0,$F0,$F6,$F6,$F9,$FF,$BF,$BF,$9F,$D5,$8B,$97,$C3,$E2
        .byte   $F1,$F0,$B6,$AA,$F4,$E8,$FC,$DD,$EE,$EF,$FB,$6B,$35,$33,$73,$E6
        .byte   $C9,$A9,$17,$F7,$FA,$FC,$FC,$F9,$F7,$D7,$EB,$33,$67,$E7,$67,$EF
        .byte   $2F,$5F,$1E,$CF,$9F,$1F,$9F,$1F,$DF,$AE,$E5,$9F,$DF,$4B,$5F,$4F
        .byte   $43,$33,$39,$FB,$FF,$77,$67,$76,$7E,$2C,$36,$1C,$0E,$0D,$06,$01
        .byte   $01,$00,$00,$1B,$0D,$0E,$07,$01,$01,$00,$00,$AC,$B5,$5B,$B3,$D7
        .byte   $FF,$5F,$EB,$73,$7B,$B7,$DF,$FF,$FF,$FF,$DF,$AB,$AB,$2B,$84,$3F
        .byte   $9F,$C1,$3F,$DD,$DD,$DD,$7B,$C0,$E0,$FF,$3F,$02,$02,$04,$09,$04
        .byte   $00,$11,$04,$01,$03,$06,$0B,$0E,$15,$1B,$00,$01,$03,$05,$0F,$0D
        .byte   $1A,$14,$00,$00,$00,$03,$05,$1B,$1F,$7B,$00,$00,$00,$03,$06,$1C
        .byte   $1A,$66,$A7,$DF,$3C,$DA,$B9,$6B,$EE,$DE,$D9,$A1,$C3,$E5,$5F,$9D
        .byte   $1E,$26,$07,$3B,$E6,$5C,$98,$D0,$A0,$C0,$07,$3D,$DA,$A4,$68,$30
        .byte   $60,$40,$43,$85,$8D,$8B,$15,$3A,$22,$6A,$C3,$87,$8F,$8D,$1B,$36
        .byte   $3E,$76,$0C,$12,$15,$25,$27,$2F,$25,$4F,$0C,$1E,$1B,$3B,$3D,$35
        .byte   $3F,$75,$AB,$95,$BB,$BE,$B1,$EF,$F6,$6D,$FD,$FB,$D7,$D3,$FF,$F7
        .byte   $EF,$5E,$24,$3B,$27,$5B,$59,$F2,$E5,$DB,$3B,$25,$3F,$6C,$7E,$FD
        .byte   $DA,$A4,$A5,$5F,$7D,$FB,$D9,$43,$A7,$DB,$DA,$AF,$FE,$F4,$E6,$BC
        .byte   $58,$24,$66,$DA,$E7,$DB,$9D,$C7,$A5,$DB,$9A,$A6,$7B,$35,$6F,$3F
        .byte   $5B,$24,$A4,$FA,$3C,$5F,$9B,$42,$A5,$DB,$5B,$F5,$FB,$AF,$67,$BD
        .byte   $5A,$24,$DE,$B4,$B4,$6C,$68,$38,$D0,$F0,$EE,$DC,$FC,$BC,$B8,$F8
        .byte   $70,$F0,$E0,$60,$60,$40,$A0,$F0,$B8,$8C,$E0,$E0,$E0,$C0,$E0,$F0
        .byte   $78,$7C,$58,$7A,$65,$BF,$DF,$FA,$E5,$5B,$7F,$75,$7B,$E7,$EE,$FD
        .byte   $FA,$64,$A4,$9F,$B7,$FA,$D9,$C2,$A5,$DF,$DB,$FF,$FB,$E5,$E6,$FD
        .byte   $DA,$E7,$2F,$7E,$E6,$5A,$9B,$42,$A7,$DB,$DF,$BF,$F9,$A5,$64,$BD
        .byte   $58,$24,$26,$5A,$E6,$7A,$9F,$43,$A5,$DB,$D9,$A5,$D9,$FD,$7F,$BC
        .byte   $5A,$A4,$E4,$5E,$27,$5A,$99,$42,$A5,$DB,$FB,$BF,$DF,$A5,$66,$BD
        .byte   $5A,$24,$24,$5A,$27,$5E,$F9,$42,$A5,$DB,$DB,$A5,$DB,$BF,$F6,$BD
        .byte   $5A,$25,$24,$52,$A2,$DB,$F9,$5F,$A5,$DF,$DC,$AE,$DE,$E5,$77,$BD
        .byte   $5F,$27,$27,$5B,$FD,$5B,$9D,$46,$A6,$FA,$DF,$A7,$FB,$AD,$67,$BE
        .byte   $5A,$F6,$EF,$BF,$FF,$FF,$FA,$54,$A8,$45,$17,$5F,$FE,$F0,$05,$AB
        .byte   $57,$BA,$AA,$45,$AA,$94,$2B,$77,$FF,$FE,$55,$BA,$55,$6B,$D5,$EB
        .byte   $04,$FF,$05,$04,$3F,$BB,$35,$BA,$35,$FF,$FF,$2F,$E3,$65,$EA,$65
        .byte   $EA,$3A,$7D,$DA,$DD,$8E,$AF,$56,$F7,$E5,$F2,$F5,$FA,$FD,$DE,$AF
        .byte   $0B,$BD,$E5,$51,$A9,$51,$21,$D1,$A2,$7F,$1B,$AF,$57,$AF,$DF,$2F
        .byte   $5E,$04,$00,$10,$04,$A4,$DA,$E4,$FA,$F9,$E2,$E5,$FB,$DB,$E5,$DB
        .byte   $E5,$E6,$FD,$FA,$E5,$E7,$DE,$FC,$CA,$D1,$82,$A5,$7B,$FB,$E5,$FF
        .byte   $F5,$EE,$FD,$DA,$E4,$E6,$FC,$F4,$B8,$F0,$F8,$DC,$6E,$9E,$C4,$E4
        .byte   $78,$30,$78,$FC,$96,$D2,$A6,$C4,$8C,$4C,$9C,$34,$E8,$2E,$5E,$3C
        .byte   $7C,$BC,$7C,$FC,$F8,$FC,$F3,$C2,$DE,$C0,$83,$FF,$87,$FF,$FC,$FD
        .byte   $21,$3F,$7F,$FF,$FE,$7D,$B5,$B5,$BD,$DE,$DD,$FB,$FF,$FE,$CE,$CE
        .byte   $CE,$ED,$EF,$EF,$FF,$73,$BB,$1F,$BD,$3B,$FF,$F7,$F7,$BD,$5F,$FF
        .byte   $7F,$FD,$EC,$CD,$4F,$EF,$7F,$04,$FF,$06,$04,$5F,$DF,$9F,$BF,$04
        .byte   $FF,$04,$04,$C8,$8C,$4C,$9C,$3A,$F6,$FD,$FB,$F8,$FC,$BC,$7C,$F6
        .byte   $9A,$BF,$BD,$FD,$FD,$FF,$FD,$FB,$FA,$E6,$F4,$FF,$F7,$F5,$F3,$B7
        .byte   $96,$9E,$8C,$04,$FF,$0E,$04,$FE,$FA,$FF,$FF,$B7,$F7,$FC,$49,$25
        .byte   $FF,$FA,$DA,$DA,$9A,$93,$B6,$DB,$04,$FF,$04,$04,$FE,$FC,$F9,$FA
        .byte   $D5,$FD,$FC,$FC,$DD,$DF,$CE,$CD,$EB,$C9,$86,$9C,$58,$30,$60,$C0
        .byte   $00,$77,$7E,$6C,$B8,$F0,$E0,$C0,$00,$CC,$38,$50,$B0,$60,$40,$80
        .byte   $80,$BC,$D8,$B0,$70,$E0,$C0,$80,$80,$04,$00,$11,$80,$03,$A0,$02
        .byte   $04,$F0,$D0,$00,$80,$C0,$E0,$C0,$D0,$C8,$E8,$B0,$A8,$D8,$F4,$5A
        .byte   $6A,$55,$6B,$E8,$F4,$B4,$D8,$6C,$7C,$7E,$5E,$3D,$2D,$14,$1A,$16
        .byte   $0B,$07,$02,$2B,$37,$1F,$17,$1B,$0D,$05,$03,$04,$00,$12,$04,$C0
        .byte   $A0,$C0,$60,$74,$EC,$80,$C0,$80,$C0,$F0,$D0,$EC,$F4,$76,$7E,$F7
        .byte   $6B,$25,$2B,$13,$1F,$FA,$FE,$FB,$75,$3B,$35,$1F,$1F,$30,$48,$A8
        .byte   $A4,$E4,$F4,$A4,$F2,$30,$78,$D8,$DC,$BC,$AC,$FC,$AE,$AA,$EA,$E2
        .byte   $B2,$D5,$BF,$D5,$BF,$F6,$B6,$BE,$DE,$BF,$D5,$BF,$D5,$DD,$B5,$9D
        .byte   $D3,$93,$BE,$C6,$E6,$B7,$DF,$F7,$BF,$FF,$F6,$FE,$FE,$EE,$7C,$E8
        .byte   $D4,$A4,$D4,$C8,$F8,$DE,$7C,$D8,$AC,$DC,$AC,$F8,$F8,$FF,$FC,$E0
        .byte   $C0,$80,$81,$07,$0F,$04,$FF,$05,$04,$FE,$F8,$F0,$08,$00,$00,$80
        .byte   $80,$C0,$F0,$FC,$F7,$04,$FF,$08,$04,$3F,$07,$03,$01,$81,$E0,$F8
        .byte   $04,$FF,$05,$7F,$01,$1F,$02,$3C,$02,$18,$01,$01,$02,$04,$03,$0F
        .byte   $3F,$04,$FF,$09,$04,$3F,$07,$03,$01,$81,$E0,$F0,$04,$FF,$05,$04
        .byte   $7F,$1F,$0F,$90,$C0,$C0,$81,$01,$03,$0F,$3F,$EF,$04,$FF,$27,$04
        .byte   $C8,$8C,$4E,$9B,$3D,$FD,$FD,$FF,$F8,$FC,$BE,$7F,$FF,$9F,$BF,$BD
        .byte   $FF,$FD,$FD,$FF,$F9,$F9,$FB,$F9,$FF,$FF,$FF,$FD,$FF,$FF,$FD,$FF
        .byte   $F9,$FB,$FB,$F9,$FB,$F9,$F9,$F9,$FF,$FD,$FD,$F7,$F5,$FF,$FF,$FF
        .byte   $F9,$FB,$FB,$F9,$FA,$FA,$E2,$D6,$FF,$FD,$ED,$E7,$E6,$E6,$FE,$EE
        .byte   $04,$FF,$0E,$04,$FE,$FA,$FF,$FF,$B7,$F7,$FC,$49,$25,$FF,$FA,$DA
        .byte   $DA,$9A,$93,$B6,$DB,$04,$FF,$04,$04,$FE,$FC,$F9,$FA,$D5,$FD,$FC
        .byte   $FC,$DD,$DF,$CE,$CD,$EB,$C9,$86,$9C,$58,$30,$60,$C0,$00,$77,$7E
        .byte   $6C,$B8,$F0,$E0,$C0,$00,$04,$04,$11,$14,$18,$28,$28,$78,$50,$50
        .byte   $F0,$80,$18,$38,$38,$78,$70,$70,$F0,$E0,$70,$50,$48,$38,$24,$24
        .byte   $3C,$3E,$70,$70,$78,$38,$3C,$3C,$3C,$3E,$12,$12,$13,$0F,$0D,$08
        .byte   $04,$07,$1E,$1E,$1F,$0F,$0F,$0F,$07,$07,$06,$06,$02,$03,$03,$01
        .byte   $01,$01,$07,$07,$11,$03,$03,$01,$03,$00,$05,$80,$03,$00,$05,$80
        .byte   $03,$11,$40,$20,$30,$70,$98,$08,$88,$FC,$C0,$E0,$F0,$F0,$F8,$F8
        .byte   $F8,$FC,$11,$01,$05,$03,$02,$02,$01,$01,$05,$03,$03,$07,$02,$11
        .byte   $0E,$1C,$38,$38,$64,$6F,$07,$07,$0F,$1F,$3F,$3F,$7F,$7F,$CC,$84
        .byte   $86,$82,$FA,$8C,$07,$07,$FC,$FC,$11,$FE,$04,$FF,$02,$11,$3D,$E9
        .byte   $39,$1D,$0D,$0F,$33,$E3,$11,$FF,$08,$00,$13,$11,$18,$1D,$3F,$2E
        .byte   $7E,$00,$00,$00,$18,$1D,$3F,$3F,$7F,$11,$00,$10,$11,$07,$39,$48
        .byte   $CC,$9E,$F3,$C3,$43,$07,$3F,$7F,$11,$FF,$05,$11,$F9,$A1,$A7,$DC
        .byte   $D0,$F0,$B0,$D8,$11,$FF,$08,$11,$9F,$F4,$C4,$C4,$C6,$A7,$FC,$E8
        .byte   $11,$FF,$08,$11,$93,$92,$EE,$36,$1C,$08,$0C,$1E,$FF,$FE,$FE,$FE
        .byte   $FC,$F8,$FC,$FE,$F9,$2F,$23,$23,$63,$E5,$3F,$17,$11,$FF,$08,$11
        .byte   $6D,$57,$CC,$E5,$FE,$DF,$AE,$6C,$7F,$7F,$FF,$FE,$BF,$0F,$0F,$07
        .byte   $45,$06,$05,$0A,$0C,$1A,$15,$2A,$07,$07,$07,$0F,$0F,$1F,$1F,$3F
        .byte   $E6,$3D,$BE,$3A,$FC,$C6,$8A,$CF,$FF,$FE,$7D,$FD,$FF,$FF,$F7,$F3
        .byte   $35,$19,$2D,$4E,$32,$EB,$5E,$B8,$FB,$FF,$FF,$BF,$DF,$BF,$BF,$7F
        .byte   $1F,$74,$C4,$DC,$D6,$E7,$7C,$F8,$FF,$FF,$FF,$E7,$EF,$FF,$FF,$FF
        .byte   $65,$CA,$81,$CF,$FC,$91,$52,$D8,$FA,$F5,$FF,$FF,$FF,$FE,$BD,$3F
        .byte   $35,$28,$76,$6C,$5D,$EA,$D5,$EA,$3E,$3F,$7D,$7B,$73,$F7,$FB,$F7
        .byte   $C9,$EB,$C5,$EB,$75,$6B,$55,$6B,$F7,$11,$FF,$03,$7F,$04,$11,$66
        .byte   $A3,$64,$A9,$77,$E5,$5D,$FD,$11,$FF,$08,$11,$F7,$F2,$BE,$0E,$03
        .byte   $03,$01,$00,$FF,$FF,$BF,$0F,$03,$03,$01,$00,$1F,$74,$C4,$C4,$C6
        .byte   $A7,$7C,$E8,$11,$FF,$08,$11,$DC,$AF,$5C,$FC,$68,$DC,$EC,$FE,$11
        .byte   $FF,$08,$11,$5F,$EF,$FF,$EF,$DB,$D9,$98,$0C,$7F,$FF,$BD,$B9,$08
        .byte   $11,$00,$15,$11,$01,$41,$61,$61,$51,$51,$00,$00,$01,$41,$61,$61
        .byte   $71,$71,$51,$41,$69,$2B,$27,$33,$1B,$1B,$71,$71,$59,$1B,$1F,$2F
        .byte   $17,$17,$6B,$75,$6B,$FE,$6A,$7F,$5E,$FF,$7F,$7F,$7F,$FF,$FF,$FE
        .byte   $FF,$7E,$FD,$9D,$FB,$D9,$EB,$FE,$A9,$D5,$BE,$FE,$9C,$FE,$9E,$DD
        .byte   $DE,$EE,$1B,$15,$1A,$09,$0A,$0D,$07,$05,$17,$1B,$1F,$0F,$0D,$0E
        .byte   $06,$07,$13,$0B,$0E,$0B,$06,$05,$06,$05,$13,$0B,$0F,$0F,$11,$07
        .byte   $04,$11,$AA,$D7,$AE,$DD,$EF,$57,$BA,$74,$FF,$FF,$FF,$FE,$FE,$FF
        .byte   $FF,$FF,$EA,$F4,$EA,$ED,$FE,$FB,$FE,$7D,$F7,$EF,$F7,$F7,$F3,$FD
        .byte   $FD,$EE,$03,$02,$02,$03,$01,$01,$00,$00,$11,$03,$04,$01,$02,$00
        .byte   $12,$11,$BE,$DF,$DD,$EE,$F4,$79,$FB,$7D,$E7,$F7,$BF,$BF,$DF,$EE
        .byte   $BE,$F7,$BF,$5F,$6F,$37,$17,$0D,$07,$01,$DD,$7F,$77,$3D,$19,$0E
        .byte   $07,$01,$00,$01,$01,$00,$06,$00,$0C,$15,$00,$01,$03,$02,$02,$04
        .byte   $04,$0D,$2B,$32,$35,$3B,$55,$3A,$75,$AB,$3A,$13,$16,$7F,$7F,$7F
        .byte   $BF,$FE,$2F,$3B,$37,$3E,$4F,$FF,$BF,$FF,$3F,$3F,$3F,$2F,$7F,$9F
        .byte   $FF,$7E,$7B,$EB,$DF,$AF,$5E,$BF,$FD,$D3,$FD,$F7,$E7,$FF,$FF,$FF
        .byte   $FE,$FE,$57,$AE,$5F,$FE,$F5,$EE,$7E,$FF,$FF,$FE,$FF,$FF,$FF,$DE
        .byte   $BE,$FF,$FE,$FA,$F5,$8A,$BF,$DF,$BF,$79,$FF,$FF,$FB,$F6,$CF,$7F
        .byte   $7E,$FF,$01,$C3,$0E,$94,$08,$50,$A0,$44,$01,$C3,$8E,$9C,$18,$70
        .byte   $E0,$C4,$4C,$90,$20,$50,$A0,$C0,$80,$80,$CC,$98,$30,$70,$E0,$40
        .byte   $80,$80,$01,$03,$03,$01,$00,$03,$03,$01,$00,$02,$01,$00,$03,$03
        .byte   $03,$01,$03,$06,$07,$06,$0F,$0E,$1D,$13,$03,$07,$05,$07,$0D,$0B
        .byte   $13,$1F,$5F,$FB,$77,$EF,$5F,$FF,$FF,$FE,$F1,$E7,$DF,$3F,$FF,$FB
        .byte   $F7,$E7,$FD,$FE,$D5,$EB,$D7,$AF,$5F,$11,$FF,$06,$11,$FE,$FA,$F3
        .byte   $DD,$EA,$D7,$AA,$D7,$AA,$55,$BA,$FA,$F7,$EF,$FF,$EC,$FF,$FE,$FF
        .byte   $7D,$FA,$F5,$FB,$F7,$FA,$F4,$E8,$FF,$DF,$BF,$FF,$7F,$EE,$FC,$B8
        .byte   $FF,$EE,$DE,$EE,$F4,$FC,$B0,$B0,$FB,$F6,$EE,$5E,$BC,$7C,$F0,$F0
        .byte   $60,$C0,$80,$80,$11,$00,$04,$11,$E0,$C0,$80,$80,$11,$00,$04,$1F
        .byte   $02,$11,$1B,$05,$11,$00,$04,$11,$1F,$1D,$10,$11,$00,$15,$FF,$03
        .byte   $11,$3F,$7E,$F8,$60,$00,$97,$DE,$FA,$1B,$4E,$F8,$60,$11,$00,$11
        .byte   $11,$F8,$E0,$80,$11,$00,$05,$11,$B8,$60,$80,$11,$00,$15,$11,$11
        .byte   $15,$22,$15,$00,$05,$15,$20,$70,$20,$00,$80,$C0,$E0,$E0,$70,$70
        .byte   $70,$20,$78,$38,$18,$00,$08,$37,$1F,$58,$68,$3C,$3C,$3C,$36,$3B
        .byte   $3F,$0E,$11,$1A,$1D,$17,$11,$10,$08,$1F,$1E,$1D,$1E,$1F,$1F,$1F
        .byte   $0F,$0C,$07,$00,$08,$08,$0C,$06,$07,$0F,$07,$07,$0F,$0F,$0F,$07
        .byte   $07,$00,$00,$80,$00,$E0,$E0,$00,$60,$80,$C0,$40,$E0,$A0,$F0,$F8
        .byte   $98,$00,$EC,$FC,$38,$50,$58,$34,$59,$F8,$9C,$FE,$FE,$AF,$A7,$CB
        .byte   $A7,$0B,$08,$08,$04,$04,$06,$03,$09,$15,$0F,$03,$07,$04,$0F,$01
        .byte   $08,$02,$15,$0C,$04,$07,$03,$01,$00,$15,$0F,$03,$07,$03,$0F,$02
        .byte   $15,$A7,$FF,$3C,$2A,$54,$2A,$DC,$D6,$DF,$FF,$FF,$D5,$AB,$D5,$A3
        .byte   $E9,$F8,$7F,$2F,$56,$2D,$9E,$E5,$EA,$FF,$BF,$DF,$A9,$D2,$E1,$DA
        .byte   $F5,$80,$15,$00,$06,$15,$20,$80,$15,$C0,$04,$E0,$05,$15,$C0,$80
        .byte   $50,$90,$30,$70,$E0,$F0,$B0,$70,$B0,$70,$F8,$F8,$15,$01,$05,$15
        .byte   $05,$49,$25,$03,$07,$07,$0F,$0F,$0B,$D7,$FB,$69,$A9,$21,$3D,$B7
        .byte   $F5,$50,$14,$B7,$77,$FF,$FF,$FF,$FB,$FF,$FB,$E0,$C3,$95,$89,$27
        .byte   $1F,$3E,$6D,$FF,$FC,$EA,$F7,$DF,$FE,$F9,$F2,$6B,$45,$CF,$9E,$9D
        .byte   $B1,$E2,$C1,$F4,$FB,$FF,$FF,$FE,$FE,$FD,$FE,$03,$A8,$56,$FE,$EB
        .byte   $55,$BB,$FE,$FF,$57,$A9,$FF,$D7,$AA,$44,$01,$7F,$FF,$FF,$AB,$75
        .byte   $9F,$76,$BF,$80,$FF,$FF,$55,$8A,$60,$89,$40,$C0,$40,$00,$00,$80
        .byte   $E0,$20,$80,$15,$C0,$03,$E0,$04,$15,$70,$A0,$40,$C0,$F0,$3C,$0C
        .byte   $84,$42,$58,$B8,$15,$FC,$04,$15,$7C,$BE,$0C,$08,$0C,$0C,$0E,$14
        .byte   $10,$0C,$0A,$0E,$0A,$0B,$09,$1B,$1F,$0F,$24,$2B,$51,$42,$AC,$50
        .byte   $90,$23,$3F,$37,$6F,$7E,$FC,$B0,$70,$E3,$15,$00,$10,$15,$01,$06
        .byte   $0C,$30,$68,$50,$80,$40,$01,$07,$0E,$3E,$76,$6C,$F8,$F0,$00,$04
        .byte   $12,$0B,$26,$24,$52,$59,$00,$1C,$0E,$17,$6F,$67,$35,$3A,$34,$25
        .byte   $13,$0F,$04,$00,$00,$00,$3F,$3D,$2F,$17,$0F,$03,$00,$00,$9E,$33
        .byte   $6D,$4A,$C8,$A7,$5C,$35,$7F,$F7,$FB,$79,$BB,$DF,$FF,$EC,$3B,$D7
        .byte   $58,$AC,$D3,$31,$0F,$02,$E7,$FF,$BF,$DF,$FF,$FF,$7F,$3F,$C3,$E1
        .byte   $F8,$9E,$87,$C5,$C2,$67,$FC,$FE,$FF,$FF,$FF,$FB,$FD,$F8,$72,$F9
        .byte   $DE,$7F,$E0,$89,$06,$AF,$FD,$FE,$BF,$FF,$FF,$F6,$F9,$50,$DE,$76
        .byte   $AF,$7C,$80,$FF,$FF,$2B,$21,$89,$50,$83,$FF,$FF,$FE,$D4,$FE,$B5
        .byte   $50,$F3,$FF,$07,$2B,$10,$01,$4A,$AF,$FF,$FF,$FF,$D7,$EE,$80,$83
        .byte   $06,$3F,$F3,$83,$44,$EE,$7E,$7F,$FE,$FF,$FF,$FF,$BF,$1D,$14,$30
        .byte   $57,$E2,$81,$00,$00,$00,$F4,$F0,$FB,$FD,$87,$00,$00,$00,$0C,$7C
        .byte   $20,$00,$1B,$E4,$8C,$90,$0F,$77,$D8,$E0,$9B,$FF,$F7,$E8,$00,$00
        .byte   $03,$FE,$28,$15,$00,$05,$15,$03,$FD,$D6,$FC,$00,$00,$02,$02,$0E
        .byte   $D4,$30,$D0,$00,$00,$C3,$83,$0D,$DB,$FE,$38,$E0,$15,$00,$11,$15
        .byte   $02,$04,$08,$0B,$17,$16,$10,$1C,$03,$07,$0F,$0F,$1D,$1F,$1F,$1F
        .byte   $3F,$6B,$B5,$8A,$57,$6B,$BB,$CF,$3F,$57,$CB,$F5,$68,$74,$FC,$CF
        .byte   $1A,$C5,$28,$42,$08,$63,$F7,$F7,$E5,$3A,$D7,$BD,$F7,$FF,$DD,$FF
        .byte   $63,$81,$D3,$CE,$F5,$E5,$62,$81,$FF,$FF,$EF,$F7,$EE,$7E,$FB,$81
        .byte   $41,$05,$39,$FD,$7B,$36,$8E,$BC,$BF,$FB,$F7,$5B,$FF,$FE,$FE,$FC
        .byte   $E2,$A9,$55,$A9,$72,$E7,$DD,$F7,$FE,$D7,$AB,$57,$8E,$1F,$3F,$F7
        .byte   $02,$01,$06,$02,$08,$04,$10,$08,$05,$07,$0A,$0E,$14,$1C,$28,$38
        .byte   $20,$10,$40,$20,$80,$40,$00,$80,$50,$70,$A0,$E0,$40,$C0,$80,$80
        .byte   $07,$02,$19,$10,$20,$03,$26,$0C,$0D,$3F,$67,$6F,$5F,$FF,$DF,$FE
        .byte   $58,$10,$50,$50,$15,$10,$04,$15,$BE,$FE,$BE,$BE,$7C,$7C,$7C,$38
        .byte   $15,$00,$0E,$15,$01,$03,$01,$02,$03,$03,$01,$00,$00,$00,$06,$0D
        .byte   $0D,$0D,$07,$06,$00,$00,$40,$40,$88,$08,$04,$C0,$24,$F0,$D0,$FC
        .byte   $F6,$F6,$FA,$FF,$FB,$7F,$F2,$B8,$3A,$1A,$18,$08,$08,$08,$FD,$BF
        .byte   $3D,$1D,$1E,$0E,$0E,$0C,$15,$00,$0F,$01,$02,$15,$03,$06,$0C,$18
        .byte   $30,$60,$40,$02,$05,$0A,$14,$28,$50,$A0,$C0,$02,$02,$04,$00,$06
        .byte   $00,$06,$00,$00,$05,$07,$07,$05,$07,$05,$07,$06,$04,$02,$04,$04
        .byte   $02,$04,$02,$05,$07,$05,$07,$07,$05,$07,$00,$01,$1A,$09,$0C,$07
        .byte   $03,$01,$02,$0E,$1D,$1E,$1F,$1E,$1F,$1F,$0D,$02,$07,$03,$01,$00
        .byte   $00,$03,$01,$0D,$06,$07,$07,$07,$03,$03,$01,$F1,$BF,$5F,$AE,$5D
        .byte   $AA,$FE,$5F,$FF,$5F,$AE,$51,$A2,$D5,$F9,$BF,$BE,$6F,$AA,$FF,$FF
        .byte   $55,$AA,$FF,$41,$90,$55,$FF,$FC,$AA,$55,$FF,$E0,$A0,$50,$A8,$50
        .byte   $B0,$68,$D0,$F8,$D8,$A8,$58,$B8,$7C,$F4,$EC,$E8,$F2,$EE,$F8,$48
        .byte   $F9,$AB,$FF,$14,$0E,$DE,$FE,$B6,$07,$57,$FF,$15,$15,$11,$21,$00
        .byte   $07,$0F,$0E,$19,$35,$39,$34,$00,$07,$0E,$0D,$1F,$3B,$37,$3B,$7A
        .byte   $5D,$44,$76,$F2,$E2,$E6,$E5,$7D,$5E,$47,$77,$C3,$D3,$D7,$F6,$FE
        .byte   $8E,$78,$80,$00,$0E,$32,$D8,$FE,$F0,$F8,$80,$00,$0E,$3C,$E0,$40
        .byte   $80,$80,$A6,$80,$D4,$40,$48,$B0,$70,$60,$66,$46,$58,$D0,$E8,$11
        .byte   $00,$10,$11,$3E,$4E,$B8,$60,$40,$CE,$B2,$D8,$3E,$72,$F8,$E0,$C0
        .byte   $CE,$BC,$E0,$00,$07,$0F,$0E,$19,$35,$39,$34,$00,$07,$0E,$0D,$1F
        .byte   $3B,$37,$3B,$7A,$5D,$44,$76,$F2,$E2,$E6,$E7,$7D,$5E,$47,$77,$C3
        .byte   $D3,$D7,$E6,$C0,$8E,$7F,$8E,$03,$1F,$32,$DF,$FF,$F1,$FC,$8F,$1F
        .byte   $3F,$3D,$E0,$EE,$DA,$B0,$78,$08,$EA,$28,$30,$EA,$52,$78,$98,$FA
        .byte   $FA,$32,$79,$0D,$BA,$E9,$7B,$C6,$9C,$39,$E1,$CE,$BD,$F7,$87,$3E
        .byte   $7C,$F9,$E3,$EE,$DA,$B1,$FA,$4D,$6A,$26,$38,$EA,$52,$7A,$D9,$7B
        .byte   $76,$3E,$79,$FE,$8E,$7F,$8E,$03,$1F,$32,$C7,$FE,$F1,$FC,$8F,$1F
        .byte   $3F,$3D,$F8,$1E,$60,$CF,$77,$41,$D4,$40,$C8,$E1,$9F,$3F,$B6,$86
        .byte   $58,$D0,$68,$73,$35,$0C,$1C,$20,$33,$73,$2B,$73,$37,$0B,$08,$39
        .byte   $34,$74,$2D,$2B,$0F,$5D,$52,$13,$5C,$F8,$AB,$2F,$0E,$5E,$5F,$5B
        .byte   $5C,$F8,$FB,$51,$7A,$2E,$19,$1B,$89,$89,$8B,$38,$3E,$2E,$0F,$8A
        .byte   $19,$81,$81,$EE,$DA,$B0,$78,$08,$EA,$28,$30,$EA,$52,$78,$98,$FA
        .byte   $FA,$32,$79,$0D,$BA,$E9,$7B,$C6,$9C,$39,$E1,$CE,$BD,$F7,$87,$3E
        .byte   $7C,$F9,$E3,$EE,$DA,$B0,$78,$08,$EA,$28,$30,$EA,$52,$78,$98,$FA
        .byte   $FA,$32,$79,$0A,$0B,$17,$28,$15,$3C,$DF,$7C,$0A,$0B,$17,$2F,$3A
        .byte   $73,$E8,$40,$B9,$F3,$F1,$34,$72,$3B,$5C,$57,$C3,$86,$84,$44,$46
        .byte   $23,$58,$56,$38,$38,$0D,$06,$31,$08,$0A,$06,$28,$28,$15,$3B,$38
        .byte   $0B,$0D,$07,$43,$49,$58,$66,$4C,$49,$65,$ED,$43,$45,$6C,$5E,$7C
        .byte   $6B,$6D,$ED,$A6,$A6,$C4,$C4,$64,$C4,$93,$B3,$E6,$E6,$44,$44,$E6
        .byte   $C6,$92,$B2,$1A,$1B,$19,$41,$61,$41,$81,$00,$3B,$7B,$19,$C1,$E1
        .byte   $41,$81,$00,$51,$7A,$2E,$19,$1B,$89,$89,$8B,$38,$3E,$2E,$0F,$8A
        .byte   $19,$81,$81,$89,$01,$81,$E1,$E0,$E0,$A0,$A4,$83,$0A,$A0,$C0,$80
        .byte   $C0,$E0,$E0,$80,$C0,$00,$60,$E8,$E2,$82,$B0,$80,$C0,$E0,$90,$98
        .byte   $DA,$F3,$F8,$2A,$9C,$44,$29,$20,$22,$02,$02,$3A,$9D,$0C,$69,$04
        .byte   $04,$00,$00,$B1,$DC,$88,$0A,$12,$66,$C4,$84,$F1,$9C,$98,$3A,$72
        .byte   $E6,$CC,$9C,$94,$2C,$58,$D8,$D0,$B4,$E6,$C6,$AC,$3C,$78,$F8,$B0
        .byte   $F4,$E6,$CE,$E4,$75,$65,$28,$30,$1C,$0A,$0F,$E0,$78,$70,$39,$39
        .byte   $1D,$0E,$0D,$03,$03,$11,$00,$06,$03,$02,$00,$06,$02,$01,$00,$02
        .byte   $11,$20,$A0,$A4,$A4,$04,$11,$00,$06,$11,$10,$12,$C0,$FC,$D6,$5D
        .byte   $32,$0E,$00,$00,$C2,$7C,$EF,$66,$3F,$0F,$11,$00,$12,$11,$02,$00
        .byte   $03,$03,$03,$09,$0C,$02,$02,$00,$03,$03,$04,$08,$00,$01,$03,$06
        .byte   $0D,$09,$1F,$3F,$2F,$60,$03,$06,$0D,$0F,$1F,$23,$31,$7F,$DB,$B7
        .byte   $26,$36,$15,$87,$30,$23,$E7,$CF,$56,$0E,$8E,$44,$71,$23,$31,$DC
        .byte   $08,$0A,$12,$66,$C4,$84,$F1,$1C,$98,$3A,$72,$E6,$CC,$9C,$94,$2C
        .byte   $58,$58,$50,$B4,$E6,$C6,$AC,$1C,$38,$B8,$B0,$74,$66,$CE,$01,$18
        .byte   $04,$33,$3B,$13,$05,$84,$19,$24,$02,$33,$5B,$0B,$CD,$64,$C1,$E4
        .byte   $74,$34,$48,$49,$69,$73,$31,$DD,$6D,$3D,$C9,$BB,$9B,$97,$A1,$81
        .byte   $40,$00,$00,$80,$80,$60,$A1,$81,$40,$00,$00,$80,$80,$60,$60,$20
        .byte   $88,$98,$80,$80,$00,$00,$60,$20,$A8,$98,$B8,$8C,$02,$00,$2A,$CB
        .byte   $52,$12,$10,$14,$0C,$10,$3D,$CD,$74,$96,$18,$1E,$0C,$10,$1A,$16
        .byte   $16,$38,$08,$10,$60,$C0,$1E,$1A,$1A,$30,$10,$20,$40,$80,$CC,$CA
        .byte   $FA,$77,$4B,$39,$2A,$47,$FC,$BA,$9A,$57,$4F,$77,$6D,$04,$03,$50
        .byte   $00,$08,$16,$05,$00,$00,$02,$30,$00,$18,$06,$03,$11,$00,$07,$11
        .byte   $80,$C0,$60,$11,$00,$05,$11,$80,$C0,$E0,$B0,$B8,$68,$30,$00,$6A
        .byte   $A3,$01,$70,$D8,$58,$38,$00,$6E,$67,$03,$11,$11,$07,$09,$01,$03
        .byte   $06,$64,$3E,$FF,$FF,$F3,$00,$02,$05,$13,$4B,$FD,$D7,$9D,$F7,$FB
        .byte   $EF,$E7,$EE,$FB,$F5,$97,$BF,$FD,$CF,$85,$8F,$DF,$FF,$FF,$80,$C4
        .byte   $EC,$7E,$FC,$FC,$FC,$FC,$00,$43,$36,$A6,$BC,$7C,$D8,$B8,$FE,$FC
        .byte   $DC,$B8,$70,$E0,$70,$78,$58,$BC,$F0,$70,$F0,$F8,$FC,$CC,$8F,$6E
        .byte   $0E,$1C,$0C,$04,$14,$6C,$EB,$68,$0C,$10,$18,$1C,$3C,$5C,$78,$74
        .byte   $78,$7F,$1F,$7F,$3F,$0F,$64,$6C,$78,$7F,$1F,$7F,$3F,$0F,$F8,$78
        .byte   $38,$1C,$08,$18,$1C,$1C,$CC,$40,$30,$1C,$04,$0C,$1C,$10,$14,$98
        .byte   $F8,$E4,$B8,$BE,$F8,$F8,$18,$94,$F4,$FC,$FC,$D4,$D4,$F0,$07,$07
        .byte   $02,$05,$02,$00,$07,$01,$01,$00,$06,$02,$03,$06,$00,$07,$03,$06
        .byte   $04,$04,$0E,$3F,$07,$07,$0F,$1F,$1F,$02,$3F,$03,$00,$04,$02,$18
        .byte   $70,$A7,$BC,$02,$00,$04,$02,$1F,$FF,$7F,$7F,$F0,$F1,$3D,$5E,$CF
        .byte   $1C,$38,$F1,$FF,$FE,$FE,$BF,$3F,$FF,$FF,$FE,$02,$02,$01,$02,$01
        .byte   $00,$04,$01,$20,$54,$8E,$9C,$01,$00,$04,$01,$3C,$6A,$F1,$E3,$8A
        .byte   $A1,$C6,$7C,$01,$00,$04,$01,$F5,$FF,$FE,$7C,$01,$00,$07,$01,$08
        .byte   $0C,$4C,$2B,$17,$00,$00,$00,$10,$30,$72,$F4,$F8,$E8,$D4,$32,$30
        .byte   $10,$00,$00,$00,$F7,$FB,$7C,$3C,$18,$01,$00,$07,$01,$0C,$0E,$17
        .byte   $33,$01,$00,$04,$01,$30,$70,$F8,$FC,$FC,$F8,$70,$30,$01,$00,$04
        .byte   $01,$CF,$EF,$7E,$3C,$01,$00,$04,$01,$01,$02,$04,$30,$38,$18,$00
        .byte   $00,$0C,$6C,$ED,$00,$08,$18,$0C,$06,$03,$63,$2F,$C9,$0D,$07,$1E
        .byte   $38,$31,$01,$00,$1F,$0F,$01,$19,$0D,$01,$01,$00,$00,$30,$70,$60
        .byte   $00,$07,$07,$C4,$00,$00,$40,$60,$C0,$C4,$EC,$3C,$C8,$80,$30,$76
        .byte   $67,$83,$C0,$C0,$38,$F0,$C0,$CE,$E4,$C0,$00,$00,$02,$02,$00,$01
        .byte   $00,$10,$08,$28,$08,$10,$08,$28,$08,$00,$00,$00,$01,$00,$38,$08
        .byte   $44,$08,$38,$08,$44,$08,$00,$00,$00,$01,$34,$2C,$18,$34,$2C,$18
        .byte   $34,$28,$4A,$52,$66,$4A,$52,$66,$4A,$56,$34,$2C,$18,$34,$2C,$18
        .byte   $34,$28,$4A,$52,$66,$4A,$52,$66,$4A,$56,$00,$00,$00,$01,$17,$2F
        .byte   $17,$2F,$17,$2F,$17,$2F,$E8,$D0,$E8,$D0,$E8,$D0,$E8,$D0,$17,$2F
        .byte   $17,$2F,$17,$2F,$17,$2F,$E8,$D0,$E8,$D0,$E8,$D0,$E8,$D0,$00,$00
        .byte   $01,$02,$00,$03,$0C,$10,$21,$21,$41,$43,$00,$03,$0F,$1F,$3E,$3E
        .byte   $7F,$7F,$43,$41,$20,$20,$10,$0C,$03,$00,$7F,$7F,$3F,$3F,$1F,$0F
        .byte   $03,$00,$01,$01,$00,$01,$22,$14,$22,$22,$04,$22,$41,$41,$44,$28
        .byte   $44,$44,$38,$44,$82,$82,$22,$0C,$24,$24,$08,$24,$42,$42,$44,$30
        .byte   $48,$48,$30,$48,$84,$84,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

; ---- bank2.bank_id_BFFF (data) $BFFF-$BFFF, 1 bytes
; Bank 2 identity byte
        .byte   $02
