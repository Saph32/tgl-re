; PRG bank 6 - not yet established
; $8000-$BFFF
; The switchable window. Every address below exists in seven banks; only this
; one has these bytes at it, which is what the L6_ label prefix records.
.org $8000


; ---- bank6.code_8000 (code) $8000-$8002, 3 bytes
L6_8000:
        jmp     L6_81FB

; ---- bank6.code_8003 (code) $8003-$8005, 3 bytes
L6_8003:
        jmp     L6_8BCE

; ---- bank6.code_8006 (code) $8006-$8008, 3 bytes
L6_8006:
        jmp     L6_8435

; ---- bank6.code_8009 (code) $8009-$800B, 3 bytes
L6_8009:
        jmp     L6_826D

; ---- bank6.code_800C (code) $800C-$800E, 3 bytes
L6_800C:
        jmp     L6_81F5

; ---- bank6.code_800F (code) $800F-$8011, 3 bytes
L6_800F:
        jmp     L6_8015

; ---- bank6.code_8012 (code) $8012-$8014, 3 bytes
L6_8012:
        jmp     L6_805A

; ---- bank6.code_8015 (code) $8015-$8026, 18 bytes
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

; ---- bank6.code_802A (code) $802A-$803F, 22 bytes
        lda     #$81
        sta     $4010
        sta     $05
        lda     #$00
        sta     $4011
        lda     #$FF
        sta     $4012
        lda     #$01
        sta     $4013

; ---- bank6.code_8040 (code) $8040-$8049, 10 bytes
        ldx     #$05
L6_8042:
        lda     #$00
        sta     $0170,X
        dex
        bpl     L6_8042

; ---- bank6.code_804A (code) $804A-$8054, 11 bytes
        ldx     #$0A
        lda     #$00
L6_804E:
        sta     $00,X
        inx
        cpx     #$F9
        bne     L6_804E

; ---- bank6.code_8055 (code) $8055-$8059, 5 bytes
        lda     #$04
        sta     $83
        rts

; ---- bank6.code_805A (code) $805A-$8070, 23 bytes
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

; ---- bank6.code_8071 (code) $8071-$8080, 16 bytes
        lda     $04B3
        tay
        beq     L6_8081
        ldy     #$C8
        cmp     #$02
        beq     L6_8081
        ldy     #$64
        bcs     L6_8093

; ---- bank6.code_8081 (code) $8081-$8094, 20 bytes
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

; ---- bank6.code_8095 (code) $8095-$80A5, 17 bytes
L6_8095:
        sta     $15
        lda     #$20
        sta     $19
        lda     #$94
        sta     $18
        lda     $15
        beq     L6_80A6
        jsr     L7_C051

; ---- bank6.code_80A6 (code) $80A6-$80DE, 57 bytes
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

; ---- bank6.tbl_80DF (pointer_table) $80DF-$815C, 126 bytes
; Object dispatch, low bytes (types 1-126)
        .byte   $6D,$8F,$6A,$74,$6A,$88,$5E,$5E,$68,$47,$0B,$66,$47,$5B,$56,$1C
        .byte   $1C,$1C,$1C,$6D,$6D,$EE,$7E,$97,$97,$F9,$97,$F9,$09,$09,$09,$B7
        .byte   $35,$A5,$6F,$67,$67,$67,$C5,$71,$18,$CF,$7C,$41,$79,$79,$79,$2B
        .byte   $F0,$F0,$F0,$F7,$11,$D7,$D7,$67,$F8,$38,$86,$C6,$BB,$F8,$2B,$80
        .byte   $80,$E1,$A0,$4D,$87,$87,$19,$DB,$DB,$47,$47,$87,$87,$DC,$04,$02
        .byte   $02,$6D,$F9,$F9,$48,$48,$48,$45,$D8,$06,$06,$06,$BB,$40,$B6,$22
        .byte   $F3,$FA,$81,$25,$7B,$8A,$C1,$17,$9B,$68,$D9,$03,$32,$64,$6A,$35
        .byte   $8F,$99,$6D,$A3,$77,$ED,$47,$47,$47,$FE,$BC,$92,$16,$50

; ---- bank6.tbl_815D (pointer_table) $815D-$81DC, 128 bytes
; Object dispatch, high bytes
        .byte   $50,$84,$84,$86,$84,$A2,$A8,$97,$97,$99,$C0,$96,$96,$C0,$9A,$9B
        .byte   $9C,$9C,$9C,$9C,$A2,$A2,$8B,$8C,$8C,$8C,$9D,$9E,$9D,$9D,$9D,$9D
        .byte   $9F,$A0,$A0,$8D,$8E,$8E,$8E,$A0,$99,$9A,$96,$96,$97,$90,$90,$90
        .byte   $99,$99,$99,$99,$99,$9A,$A8,$A8,$BA,$BB,$BD,$B0,$B3,$BD,$BE,$AC
        .byte   $90,$90,$AC,$AD,$AE,$90,$91,$93,$93,$93,$C0,$C0,$91,$91,$95,$96
        .byte   $A7,$A7,$A7,$A7,$A7,$A3,$A3,$A3,$A4,$B0,$A5,$A5,$A5,$A5,$A6,$A6
        .byte   $B1,$AE,$9F,$AF,$B0,$BF,$B2,$B2,$B3,$AA,$AB,$AB,$B9,$B6,$B6,$B1
        .byte   $B2,$B3,$B6,$B9,$B9,$B4,$B4,$C0,$C0,$C0,$B9,$B7,$B5,$B7,$B8,$B8

; ---- bank6.tbl_81DD (data) $81DD-$81F4, 24 bytes
; Slot order for the reversed pass: 0-4, then 23 down to 5
        .byte   $00,$01,$02,$03,$04,$17,$16,$15,$14,$13,$12,$11,$10,$0F,$0E,$0D
        .byte   $0C,$0B,$0A,$09,$08,$07,$06,$05

; ---- bank6.code_81F5 (code) $81F5-$81FA, 6 bytes
L6_81F5:
        ldx     #$01
        stx     $35
        bne     L6_8204

; ---- bank6.code_81FB (code) $81FB-$8203, 9 bytes
L6_81FB:
        jsr     L7_C096
        ldx     #$00
        stx     $35
        inc     $36

; ---- bank6.code_8204 (code) $8204-$820F, 12 bytes
L6_8204:
        lda     $36
        and     #$02
        beq     L6_820E
        lda     $81DD,X
        tax
L6_820E:
        stx     $37

; ---- bank6.code_8210 (code) $8210-$8226, 23 bytes
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

; ---- bank6.code_8227 (code) $8227-$822E, 8 bytes
L6_8227:
        inc     $35
        ldx     $35
        cpx     #$18
        bne     L6_8204

; ---- bank6.code_822F (code) $822F-$8231, 3 bytes
        jsr     L7_C099

; ---- bank6.code_8232 (code) $8232-$8246, 21 bytes
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

; ---- bank6.code_8247 (code) $8247-$8269, 35 bytes
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

; ---- bank6.code_826D (code) $826D-$8292, 38 bytes
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

; ---- bank6.code_8293 (code) $8293-$82AD, 27 bytes
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

; ---- bank6.code_82AE (code) $82AE-$82CD, 32 bytes
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

; ---- bank6.code_82CE (code) $82CE-$82F1, 36 bytes
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

; ---- bank6.code_82F2 (code) $82F2-$82FA, 9 bytes
        bit     $6F
        bvc     L6_82FB
        lda     $6C
        jmp     L6_8317

; ---- bank6.code_82FB (code) $82FB-$8316, 28 bytes
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

; ---- bank6.code_8317 (code) $8317-$8321, 11 bytes
L6_8317:
        sta     $6D
        bit     $6F
        bpl     L6_8322
        lda     $6C
        jmp     L6_8345

; ---- bank6.code_8322 (code) $8322-$8344, 35 bytes
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

; ---- bank6.code_8345 (code) $8345-$8354, 16 bytes
L6_8345:
        sta     $6E
        ldy     $6C
        lda     $8425,Y
        sta     $10
        ldy     $6D
        lda     $8425,Y
        sta     $11

; ---- bank6.code_8355 (code) $8355-$835B, 7 bytes
        lda     $6E
        lda     $8425,Y
        sta     $12

; ---- bank6.code_835C (code) $835C-$8364, 9 bytes
        ora     $11
        ora     $10
        bne     L6_8365
        jmp     L6_840C

; ---- bank6.code_8365 (code) $8365-$8384, 32 bytes
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

; ---- bank6.code_8385 (code) $8385-$8398, 20 bytes
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

; ---- bank6.code_8399 (code) $8399-$83A6, 14 bytes
        bit     $6F
        bvc     L6_83A7
        lda     $10
        bne     L6_83A4
L6_83A1:
        jmp     L6_840C
L6_83A4:
        jmp     L6_8415

; ---- bank6.code_83A7 (code) $83A7-$83B8, 18 bytes
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

; ---- bank6.code_83B9 (code) $83B9-$83DF, 39 bytes
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

; ---- bank6.code_83E0 (code) $83E0-$83E9, 10 bytes
        lda     $11
        bne     L6_83F6
        lda     $12
        bne     L6_8406
        beq     L6_841A

; ---- bank6.code_83EA (code) $83EA-$83FB, 18 bytes
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

; ---- bank6.code_83FC (code) $83FC-$840B, 16 bytes
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

; ---- bank6.code_840C (code) $840C-$8414, 9 bytes
L6_840C:
        lda     $17
        sec
        sbc     $06B0,X
        sta     $0518,X

; ---- bank6.code_8415 (code) $8415-$8419, 5 bytes
L6_8415:
        lda     $19
        sta     $0530,X

; ---- bank6.code_841A (code) $841A-$8424, 11 bytes
L6_841A:
        lda     $16
        sta     $0758,X
        lda     $18
        sta     $0770,X
        rts

; ---- bank6.tbl_8425 (data) $8425-$8434, 16 bytes
; Blocking by cell class: 16 x 0/1
        .byte   $00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$01,$00

; ---- bank6.code_8435 (code) $8435-$8442, 14 bytes
L6_8435:
        lda     $0530,X
        sta     $1B
        lda     $0518,X
        clc
        adc     $06B0,X
        sta     $1A

; ---- bank6.code_8443 (code) $8443-$8450, 14 bytes
L6_8443:
        bit     $30
        bvs     L6_844D
        lda     $1A
        cmp     #$C0
        bcc     L6_8451
L6_844D:
        lda     #$00
        beq     L6_846B

; ---- bank6.code_8451 (code) $8451-$846D, 29 bytes
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

; ---- bank6.code_846E (code) $846E-$8470, 3 bytes
L6_846E:
        jsr     L7_C006

; ---- bank6.inline_8471 (data) $8471-$8473, 3 bytes
; Far-call argument at $8471
        .byte   $03,$FF,$7F

; ---- bank6.code_8474 (code) $8474-$8474, 1 bytes
        rts

; ---- bank6.code_8475 (code) $8475-$8477, 3 bytes
L6_8475:
        jsr     L7_C006

; ---- bank6.inline_8478 (data) $8478-$847A, 3 bytes
; Far-call argument at $8478
        .byte   $03,$05,$80

; ---- bank6.code_847B (code) $847B-$847B, 1 bytes
        rts

; ---- bank6.tbl_847C (data) $847C-$847F, 4 bytes
; Gun speed class by tier
        .byte   $81,$43,$82,$83

; ---- bank6.tbl_8480 (data) $8480-$8487, 8 bytes
; Gun metasprites, frame A
        .byte   $25,$27,$29,$27,$25,$25,$25,$18

; ---- bank6.tbl_8488 (data) $8488-$848F, 8 bytes
; Gun metasprites, frame B
        .byte   $25,$26,$28,$26,$25,$25,$25,$17

; ---- bank6.code_8490 (code) $8490-$8494, 5 bytes
L6_8490:
        lda     $0500,X
        bmi     L6_84BF

; ---- bank6.code_8495 (code) $8495-$849D, 9 bytes
        jsr     L7_C0AE
        lda     $05A8
        sta     $05A8,X

; ---- bank6.code_849E (code) $849E-$84A5, 8 bytes
        ldy     $3A
        lda     $847C,Y
        sta     $0698,X

; ---- bank6.code_84A6 (code) $84A6-$84B1, 12 bytes
        lda     $0788,X
        bit     $30
        bvc     L6_84AF
        lda     #$0C
L6_84AF:
        sta     $07A0,X

; ---- bank6.code_84B2 (code) $84B2-$84BE, 13 bytes
        jsr     L7_C102
        lda     #$02
        sta     $0560,X
        lda     #$25
        jsr     L7_C030

; ---- bank6.code_84BF (code) $84BF-$84CB, 13 bytes
L6_84BF:
        inc     $0788,X
        lda     $0788,X
        and     #$01
        asl     A
        asl     A
        adc     $3A
        tay

; ---- bank6.code_84CC (code) $84CC-$84E0, 21 bytes
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

; ---- bank6.code_84E1 (code) $84E1-$84E6, 6 bytes
L6_84E1:
        jsr     L7_C08D
        jsr     L7_C0B1

; ---- bank6.code_84E7 (code) $84E7-$84FA, 20 bytes
L6_84E7:
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

; ---- bank6.code_84FB (code) $84FB-$8506, 12 bytes
        jsr     L6_8443
        sty     $14
        ldy     $6C
        lda     $8513,Y
        beq     L6_850A

; ---- bank6.code_8507 (code) $8507-$8509, 3 bytes
        jsr     L6_8523

; ---- bank6.code_850A (code) $850A-$8512, 9 bytes
L6_850A:
        lda     $0590,X
        bne     L6_8512
        jmp     L7_C048
L6_8512:
        rts

; ---- bank6.tbl_8513 (data) $8513-$8522, 16 bytes
; Cell classes a weapon reacts to: 16 x 0/1
        .byte   $00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$00,$00,$00,$01,$00

; ---- bank6.code_8523 (code) $8523-$8532, 16 bytes
L6_8523:
        cpy     #$0E
        beq     L6_852B
        cpy     #$09
        bne     L6_8533
L6_852B:
        lda     #$21
        jsr     L7_C030
        jmp     L6_85E6

; ---- bank6.code_8533 (code) $8533-$8540, 14 bytes
L6_8533:
        cpy     #$05
        bne     L6_8556
        lda     #$01
        sta     $15
        lda     #$00
        sta     $17
        lda     #$28

; ---- bank6.code_8541 (code) $8541-$8555, 21 bytes
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

; ---- bank6.code_8556 (code) $8556-$8567, 18 bytes
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

; ---- bank6.code_8568 (code) $8568-$8569, 2 bytes
        ldy     #$01

; ---- bank6.code_856A (code) $856A-$8574, 11 bytes
L6_856A:
        lda     a:$0058,y
        sec
        sbc     #$10
        sta     a:$0058,y
        bcs     L6_85A8

; ---- bank6.code_8575 (code) $8575-$857E, 10 bytes
        and     #$0F
        cmp     #$08
        beq     L6_859F
        sta     $10
        sty     $11

; ---- bank6.code_857F (code) $857F-$8596, 24 bytes
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

; ---- bank6.code_8597 (code) $8597-$859E, 8 bytes
L6_8597:
        lda     #$00
        beq     L6_8541
L6_859B:
        lda     #$04
        bne     L6_8541

; ---- bank6.code_859F (code) $859F-$85A7, 9 bytes
L6_859F:
        lda     #$00
        sta     $15
        lda     #$1C
        jmp     L6_8541

; ---- bank6.code_85A8 (code) $85A8-$85AF, 8 bytes
L6_85A8:
        lda     #$20
        jsr     L7_C030
        jmp     L6_85E6

; ---- bank6.code_85B0 (code) $85B0-$85C5, 22 bytes
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

; ---- bank6.code_85C6 (code) $85C6-$85DF, 26 bytes
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

; ---- bank6.code_85E0 (code) $85E0-$85E5, 6 bytes
L6_85E0:
        lda     #$55
        sta     $17
        bne     L6_859F

; ---- bank6.code_85E6 (code) $85E6-$85F3, 14 bytes
L6_85E6:
        lda     $0590,X
        sec
        sbc     #$08
        bcs     L6_85F0
        lda     #$00
L6_85F0:
        sta     $0590,X
        rts

; ---- bank6.code_85F4 (code) $85F4-$8605, 18 bytes
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

; ---- bank6.code_8606 (code) $8606-$8612, 13 bytes
L6_8606:
        lda     $45
        jsr     L6_8B8F
        lda     $45
        jsr     L7_C138
        jmp     L7_C072

; ---- bank6.code_8613 (code) $8613-$8615, 3 bytes
L6_8613:
        jmp     L7_C048

; ---- bank6.code_8616 (code) $8616-$861C, 7 bytes
L6_8616:
        ldy     $3C
        lda     $879A,Y
        bmi     L6_8644

; ---- bank6.code_861D (code) $861D-$8620, 4 bytes
        dec     $3F
        bne     L6_8644

; ---- bank6.code_8621 (code) $8621-$862C, 12 bytes
        lda     $3B
        cmp     #$03
        lda     #$3C
        bcs     L6_862B
        lda     #$78
L6_862B:
        sta     $3F

; ---- bank6.code_862D (code) $862D-$862F, 3 bytes
        jsr     L6_8606

; ---- bank6.code_8630 (code) $8630-$8643, 20 bytes
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

; ---- bank6.code_8644 (code) $8644-$864D, 10 bytes
L6_8644:
        lda     $07B8,X
        bne     L6_864E
        lda     #$FF
        sta     $0590,X

; ---- bank6.code_864E (code) $864E-$8652, 5 bytes
L6_864E:
        lda     $3C
        jsr     L6_85F4

; ---- bank6.tbl_8653 (pointer_table) $8653-$866A, 24 bytes
; Weapon object handlers A: 12 entries
        .byte   $47,$C0,$B1,$87,$02,$88,$33,$88,$74,$88,$6F,$89,$B1,$87,$13,$8A
        .byte   $F0,$88,$C3,$8A,$EC,$8A,$EC,$8A

; ---- bank6.code_866B (code) $866B-$866F, 5 bytes
L6_866B:
        lda     $0500,X
        bmi     L6_8616

; ---- bank6.code_8670 (code) $8670-$867D, 14 bytes
        ora     #$80
        sta     $0500,X
        lda     #$13
        sta     $0620,X
        lda     $3E
        beq     L6_8613

; ---- bank6.code_867E (code) $867E-$8687, 10 bytes
        jsr     L7_C0A2
        lda     #$00
        sta     $07A0,X
        ldy     $3C

; ---- bank6.code_8688 (code) $8688-$868F, 8 bytes
        cpy     #$09
        bne     L6_8690
        bit     $30
        bvc     L6_8613

; ---- bank6.code_8690 (code) $8690-$869D, 14 bytes
L6_8690:
        lda     $879A,Y
        pha
        bpl     L6_8699
        jsr     L6_8606
L6_8699:
        pla
        and     #$7F
        beq     L6_86A1

; ---- bank6.code_869E (code) $869E-$86A0, 3 bytes
        jsr     L7_C030

; ---- bank6.code_86A1 (code) $86A1-$86AE, 14 bytes
L6_86A1:
        ldy     $3C
        lda     $878F,Y
        sta     $0560,X
        lda     $8784,Y
        sta     $0548,X

; ---- bank6.code_86AF (code) $86AF-$86BA, 12 bytes
        lda     $3D
        asl     A
        asl     A
        adc     $3D
        asl     A
        adc     $3D
        adc     $3C
        tay

; ---- bank6.code_86BB (code) $86BB-$86C8, 14 bytes
        lda     $05A8
        sta     $05A8,X
        lda     $86F5,Y
        beq     L6_86C9
        sta     $05A8,X

; ---- bank6.code_86C9 (code) $86C9-$86D5, 13 bytes
L6_86C9:
        lda     $8716,Y
        sta     $07B8,X
        bne     L6_86D3
        lda     #$FF
L6_86D3:
        sta     $0590,X

; ---- bank6.code_86D6 (code) $86D6-$86E1, 12 bytes
        lda     $8737,Y
        sta     $0698,X
        lda     $8758,Y
        sta     $0578,X

; ---- bank6.code_86E2 (code) $86E2-$86E6, 5 bytes
        lda     $3C
        jsr     L6_85F4

; ---- bank6.tbl_86E7 (pointer_table) $86E7-$8700, 26 bytes
; Weapon object handlers B: 13 entries
        .byte   $47,$C0,$A6,$87,$ED,$87,$05,$88,$69,$88,$46,$89,$D3,$87,$01,$8A
        .byte   $DD,$88,$99,$8A,$EC,$8A,$EC,$8A,$9E,$8B

; ---- bank6.tbl_8701 (data) $8701-$8721, 33 bytes
; Weapon attack by level (to $05A8)
        .byte   $00,$00,$01,$00,$10,$10,$00,$04,$02,$00,$00,$00,$00,$02,$00,$20
        .byte   $18,$00,$07,$04,$00,$00,$00,$00,$06,$00,$30,$20,$00,$0A,$10,$00
        .byte   $00

; ---- bank6.tbl_8722 (data) $8722-$8742, 33 bytes
; Weapon lifetime by level (to $07B8 / $0590)
        .byte   $03,$02,$08,$00,$00,$80,$80,$00,$00,$00,$00,$10,$04,$20,$00,$00
        .byte   $00,$F0,$00,$00,$00,$00,$30,$10,$00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00

; ---- bank6.tbl_8743 (data) $8743-$8763, 33 bytes
; Weapon value by level (to $0698)
        .byte   $43,$06,$C1,$01,$0C,$02,$03,$01,$02,$00,$00,$82,$42,$85,$00,$1E
        .byte   $41,$81,$01,$03,$00,$00,$83,$43,$C2,$00,$3C,$06,$82,$01,$03,$00
        .byte   $00

; ---- bank6.tbl_8764 (data) $8764-$8783, 32 bytes
; Weapon collision flags by level (to $0578)
        .byte   $30,$10,$10,$14,$30,$30,$30,$10,$18,$30,$30,$30,$10,$30,$14,$30
        .byte   $34,$30,$30,$38,$30,$30,$30,$10,$34,$14,$34,$34,$34,$34,$3C,$34

; ---- bank6.tbl_8784 (data) $8784-$878E, 11 bytes
; Table, 11 bytes
        .byte   $34,$1A,$21,$21,$1A,$37,$1A,$1A,$1A,$00,$00

; ---- bank6.tbl_878F (data) $878F-$8799, 11 bytes
; Table, 11 bytes
        .byte   $00,$02,$01,$00,$01,$00,$00,$00,$00,$02,$01

; ---- bank6.tbl_879A (data) $879A-$87A6, 13 bytes
; Table, 13 bytes (structural extent)
        .byte   $02,$26,$2A,$2B,$26,$AE,$A7,$26,$A6,$28,$2C,$2C,$00

; ---- bank6.code_87A7 (code) $87A7-$87AE, 8 bytes
L6_87A7:
        lda     $0788,X
        jsr     L7_C102
        lda     #$02

; ---- bank6.code_87AF (code) $87AF-$87B1, 3 bytes
L6_87AF:
        jsr     L6_8860

; ---- bank6.code_87B2 (code) $87B2-$87B7, 6 bytes
L6_87B2:
        jsr     L6_87B8
        jmp     L6_84E1

; ---- bank6.code_87B8 (code) $87B8-$87D3, 28 bytes
L6_87B8:
        lda     #$80
        ldy     #$02
        jsr     L7_C0A5
        lda     $0548,X
        cmp     #$1A
        bne     L6_87CD
        lda     $87DE,Y
        sta     $06C8,X
        rts
L6_87CD:
        lda     $87DF,Y
        sta     $06C8,X
        rts

; ---- bank6.code_87D4 (code) $87D4-$87DD, 10 bytes
L6_87D4:
        jsr     L6_87E1
        jsr     L7_C102
        lda     #$01
        bne     L6_87AF

; ---- bank6.tbl_87DE (data) $87DE-$87E0, 3 bytes
; Weapon tile bases by animation phase
        .byte   $76,$78,$7C

; ---- bank6.code_87E1 (code) $87E1-$87ED, 13 bytes
L6_87E1:
        lda     $0788,X
L6_87E4:
        bit     $30
        bvc     L6_87ED
        lda     #$0C
        sta     $0788,X
L6_87ED:
        rts

; ---- bank6.code_87EE (code) $87EE-$8802, 21 bytes
L6_87EE:
        jsr     L6_87E1
        cpx     #$04
        clc
        bne     L6_87FA
        adc     #$0B
        bcc     L6_87FC
L6_87FA:
        adc     #$05
L6_87FC:
        and     #$0F
        sta     $0788,X
        bpl     L6_8815

; ---- bank6.code_8803 (code) $8803-$8805, 3 bytes
L6_8803:
        jmp     L6_84E1

; ---- bank6.code_8806 (code) $8806-$8811, 12 bytes
L6_8806:
        bit     $30
        bvc     L6_8812
        ldy     $32
        lda     $8837,Y
        sta     $0788,X

; ---- bank6.code_8812 (code) $8812-$8814, 3 bytes
L6_8812:
        lda     $0788,X

; ---- bank6.code_8815 (code) $8815-$8833, 31 bytes
L6_8815:
        jsr     L7_C102
        lda     $3D
        cmp     #$03
        bcc     L6_8825
        lda     #$76
        sta     $06C8,X
        bne     L6_8834
L6_8825:
        ldy     $0788,X
        lda     $8840,Y
        sta     $0548,X
        lda     $8850,Y
        sta     $0560,X

; ---- bank6.code_8834 (code) $8834-$8836, 3 bytes
L6_8834:
        jmp     L6_84E1

; ---- bank6.tbl_8837 (data) $8837-$883F, 9 bytes
; Wave Attack direction by pad cell (corridor)
        .byte   $0B,$0B,$0B,$0C,$0C,$0C,$0D,$0D,$0D

; ---- bank6.tbl_8840 (data) $8840-$884F, 16 bytes
; Wave Attack / Back Fire metasprite by direction
        .byte   $2C,$2C,$2D,$2E,$2E,$2E,$2D,$2C,$2C,$2C,$2D,$2E,$2E,$2E,$2D,$2C

; ---- bank6.tbl_8850 (data) $8850-$885F, 16 bytes
; Wave Attack / Back Fire palette and flip by direction
        .byte   $40,$40,$C0,$80,$80,$80,$80,$00,$00,$00,$00,$00,$00,$00,$40,$40

; ---- bank6.code_8860 (code) $8860-$8869, 10 bytes
L6_8860:
        cmp     $3D
        bcs     L6_8869
        lda     #$21
        sta     $0548,X
L6_8869:
        rts

; ---- bank6.code_886A (code) $886A-$8874, 11 bytes
L6_886A:
        lda     $0698,X
        sta     $07D0,X
        lda     #$02
        jsr     L6_8860

; ---- bank6.code_8875 (code) $8875-$8887, 19 bytes
L6_8875:
        lda     $0530
        sta     $0530,X
        lda     $0518
        bit     $30
        bvc     L6_8885
        sec
        sbc     #$10
L6_8885:
        sta     $0518,X

; ---- bank6.code_8888 (code) $8888-$889F, 24 bytes
L6_8888:
        jsr     L6_87B8
        lda     $07A0,X
        inc     $07A0,X
        ldy     $07D0,X
        bne     L6_8897
        asl     A
L6_8897:
        and     #$1F
        tay
        lda     $3C
        cmp     #$04
        beq     L6_88B7

; ---- bank6.code_88A0 (code) $88A0-$88B6, 23 bytes
        jsr     L7_C0F6
        cmp     #$80
        ror     A
        cmp     #$80
        ror     A
        sta     $18
        jsr     L7_C0F9
        cmp     #$80
        ror     A
        cmp     #$80
        ror     A
        jmp     L6_88C5

; ---- bank6.code_88B7 (code) $88B7-$88C4, 14 bytes
L6_88B7:
        jsr     L7_C0F6
        jsr     L6_88CF
        sta     $18
        jsr     L7_C0F9
        jsr     L6_88CF

; ---- bank6.code_88C5 (code) $88C5-$88C6, 2 bytes
L6_88C5:
        sta     $19

; ---- bank6.code_88C7 (code) $88C7-$88CE, 8 bytes
L6_88C7:
        jsr     L6_8908
        bcs     L6_8869
        jmp     L6_84E7

; ---- bank6.code_88CF (code) $88CF-$88DD, 15 bytes
L6_88CF:
        cmp     #$80
        ror     A
        sta     $10
        cmp     #$80
        ror     A
        clc
        adc     $10
        cmp     #$80
        ror     A
        rts

; ---- bank6.code_88DE (code) $88DE-$88F0, 19 bytes
L6_88DE:
        jsr     L6_87E1
        jsr     L7_C102
        lda     #$02
        jsr     L6_8860
        ldy     $3D
        lda     $8904,Y
        sta     $07D0,X

; ---- bank6.code_88F1 (code) $88F1-$8904, 20 bytes
L6_88F1:
        lda     $0548,X
        sta     $15
        lda     #$00
        sta     $0548,X
        jsr     L7_C08D
        lda     $15
        sta     $0548,X
        bne     L6_8888

; ---- bank6.tbl_8905 (data) $8905-$8907, 3 bytes
; Repeller turning rate by level
        .byte   $01,$00,$00

; ---- bank6.code_8908 (code) $8908-$8946, 63 bytes
L6_8908:
        lda     $0530,X
        pha
        clc
        adc     $19
        bit     $19
        bmi     L6_8917
        bcc     L6_8919
        bcs     L6_8941
L6_8917:
        bcc     L6_8941
L6_8919:
        sta     $0530,X
        lda     $0518,X
        pha
        clc
        adc     $18
        bit     $18
        bmi     L6_892B
        bcc     L6_892D
        bcs     L6_8940
L6_892B:
        bcc     L6_8940
L6_892D:
        sta     $0518,X
        jsr     L7_C090
        jsr     L7_C0B1
        pla
        sta     $0518,X
        pla
        sta     $0530,X
        clc
        rts
L6_8940:
        pla
L6_8941:
        pla
        sta     $0530,X
        sec
        rts

; ---- bank6.code_8947 (code) $8947-$896F, 41 bytes
L6_8947:
        lda     $0698,X
        pha
        lda     #$02
        sta     $0698,X
        lda     $0788,X
        jsr     L7_C102
        pla
        sta     $0698,X
        lda     #$FE
        sta     $0668,X
        clc
        adc     $05D8,X
        sta     $05D8,X
        lda     #$3C
        sta     $07A0,X
        lda     #$37
        sta     $0548,X

; ---- bank6.code_8970 (code) $8970-$899A, 43 bytes
L6_8970:
        lda     $07A0,X
        beq     L6_89AA
        lda     #$12
        jsr     L7_C09C
        dec     $07A0,X
        beq     L6_899B
        lda     #$60
        ldy     #$04
        jsr     L7_C0A5
        lda     $89CC,Y
        sta     $06C8,X
        lda     $89D0,Y
        sta     $0560,X
        jsr     L6_AF6D
        jsr     L6_AF57
        jmp     L7_C08D

; ---- bank6.code_899B (code) $899B-$89A9, 15 bytes
L6_899B:
        lda     #$42
        jsr     L7_C030
        lda     #$7C
        sta     $06C8,X
        lda     #$21
        sta     $0548,X

; ---- bank6.code_89AA (code) $89AA-$89CB, 34 bytes
L6_89AA:
        dec     $0698,X
        bne     L6_89B2
        jmp     L7_C048
L6_89B2:
        lda     $0698,X
        ldy     $3D
        and     $89D3,Y
        asl     A
        adc     $89D6,Y
        tay
        lda     $89DA,Y
        sta     $19
        lda     $89DB,Y
        sta     $18
        jmp     L6_88C7

; ---- bank6.tbl_89CC (data) $89CC-$89CF, 4 bytes
; Grenade tile bases by phase
        .byte   $7A,$76,$78,$76

; ---- bank6.tbl_89D0 (data) $89D0-$89D3, 4 bytes
; Grenade palette / flip by phase
        .byte   $00,$00,$00,$40

; ---- bank6.tbl_89D4 (data) $89D4-$89D6, 3 bytes
; Grenade burst mask by level
        .byte   $03,$07,$0F

; ---- bank6.tbl_89D7 (data) $89D7-$89D9, 3 bytes
; Grenade burst base by level
        .byte   $00,$08,$08

; ---- bank6.tbl_89DA (data) $89DA-$8A01, 40 bytes
; Grenade burst hit-box offsets: 20 x [x][y]
        .byte   $00,$00,$00,$EC,$F0,$08,$10,$08,$F4,$F4,$F4,$0C,$0C,$F4,$0C,$0C
        .byte   $E8,$E8,$E8,$18,$18,$E8,$18,$18,$D0,$00,$00,$D0,$30,$00,$00,$30
        .byte   $E8,$00,$00,$E8,$18,$00,$00,$18

; ---- bank6.code_8A02 (code) $8A02-$8A13, 18 bytes
L6_8A02:
        cpx     #$03
        beq     L6_8A0B
        lda     #$02
        sta     $0560,X
L6_8A0B:
        lda     $0788,X
        jsr     L7_C102
        jmp     L6_8A8C

; ---- bank6.code_8A14 (code) $8A14-$8A18, 5 bytes
L6_8A14:
        dec     $0680,X
        bne     L6_8A94

; ---- bank6.code_8A19 (code) $8A19-$8A2D, 21 bytes
        cpx     #$03
        bne     L6_8A21
        ldy     #$04
        bne     L6_8A23
L6_8A21:
        ldy     #$03
L6_8A23:
        lda     $0500,Y
        cmp     #$83
        bne     L6_8A2E
        lda     $07A0,Y
        tay

; ---- bank6.code_8A2E (code) $8A2E-$8A38, 11 bytes
L6_8A2E:
        sty     $11
        ldy     $07A0,X
        bne     L6_8A37
        ldy     #$05
L6_8A37:
        sty     $10

; ---- bank6.code_8A39 (code) $8A39-$8A5D, 37 bytes
L6_8A39:
        lda     $0500,Y
        bpl     L6_8A53
        cmp     #$B1
        bcc     L6_8A46
        cmp     #$B6
        bcc     L6_8A53
L6_8A46:
        lda     $0578,Y
        bmi     L6_8A53
        and     #$04
        bne     L6_8A53
        cpy     $11
        bne     L6_8A60
L6_8A53:
        iny
        cpy     #$18
        bcc     L6_8A5A
        ldy     #$05
L6_8A5A:
        cpy     $10
        bne     L6_8A39

; ---- bank6.code_8A5E (code) $8A5E-$8A5F, 2 bytes
        ldy     #$00

; ---- bank6.code_8A60 (code) $8A60-$8A63, 4 bytes
L6_8A60:
        tya
        sta     $07A0,X

; ---- bank6.code_8A64 (code) $8A64-$8A6A, 7 bytes
        jsr     L7_C114
        sec
        sbc     $0788,X

; ---- bank6.code_8A6B (code) $8A6B-$8A80, 22 bytes
        beq     L6_8A81
        and     #$0F
        cmp     #$08
        bcc     L6_8A7E
        bne     L6_8A79
        cpx     #$04
        bcc     L6_8A7E
L6_8A79:
        dec     $0788,X
        bcs     L6_8A81
L6_8A7E:
        inc     $0788,X

; ---- bank6.code_8A81 (code) $8A81-$8A8B, 11 bytes
L6_8A81:
        lda     $0788,X
        and     #$0F
        sta     $0788,X
        jsr     L7_C102

; ---- bank6.code_8A8C (code) $8A8C-$8A96, 11 bytes
L6_8A8C:
        ldy     $3D
        lda     $8A96,Y
        sta     $0680,X
L6_8A94:
        jmp     L6_87B2

; ---- bank6.tbl_8A97 (data) $8A97-$8A99, 3 bytes
; Homing missile turning period by level
        .byte   $08,$04,$01

; ---- bank6.code_8A9A (code) $8A9A-$8AA3, 10 bytes
L6_8A9A:
        lda     #$00
        sta     $0668,X
        lda     #$81
        sta     $0680,X

; ---- bank6.code_8AA4 (code) $8AA4-$8AB5, 18 bytes
        ldy     $3D
        lda     $8ADD,Y
        sta     $05D8,X
        lda     $8AE0,Y
        sta     $06C8,X
        lda     $8AE3,Y
        pha

; ---- bank6.code_8AB6 (code) $8AB6-$8ABB, 6 bytes
        txa
        tay
        pla
        jsr     L7_C13B

; ---- bank6.code_8ABC (code) $8ABC-$8AC0, 5 bytes
        lda     #$03
        sta     $0620,X

; ---- bank6.code_8AC1 (code) $8AC1-$8AC3, 3 bytes
        jsr     L7_C141

; ---- bank6.code_8AC4 (code) $8AC4-$8AC8, 5 bytes
L6_8AC4:
        jsr     L7_C129
        bcs     L6_8AF5

; ---- bank6.code_8AC9 (code) $8AC9-$8ADD, 21 bytes
        lda     #$08
        sta     $0578,X
        ldy     $3D
        lda     $8AE6,Y
        and     $41
        bne     L6_8ADD
        lda     $8AE9,Y
        sta     $0578,X
L6_8ADD:
        rts

; ---- bank6.tbl_8ADE (data) $8ADE-$8AE0, 3 bytes
; Hyper Laser y speed by level
        .byte   $FA,$F6,$F8

; ---- bank6.tbl_8AE1 (data) $8AE1-$8AE3, 3 bytes
; Hyper Laser tile base by level
        .byte   $76,$76,$02

; ---- bank6.tbl_8AE4 (data) $8AE4-$8AE6, 3 bytes
; Hyper Laser style record by level
        .byte   $00,$03,$06

; ---- bank6.tbl_8AE7 (data) $8AE7-$8AE9, 3 bytes
; Hyper Laser frame mask by level
        .byte   $01,$00,$00

; ---- bank6.tbl_8AEA (data) $8AEA-$8AEC, 3 bytes
; Hyper Laser collision flags by level
        .byte   $18,$38,$3C

; ---- bank6.code_8AED (code) $8AED-$8AF4, 8 bytes
L6_8AED:
        lda     $F7
        ora     $F8
        and     #$80
        bne     L6_8AF8

; ---- bank6.code_8AF5 (code) $8AF5-$8AF7, 3 bytes
L6_8AF5:
        jmp     L7_C048

; ---- bank6.code_8AF8 (code) $8AF8-$8B03, 12 bytes
L6_8AF8:
        lda     $0530
        sta     $0530,X
        lda     $0518
        sta     $0518,X

; ---- bank6.code_8B04 (code) $8B04-$8B0A, 7 bytes
        lda     $0668
        jsr     L6_87E4
        tay

; ---- bank6.code_8B0B (code) $8B0B-$8B1C, 18 bytes
        lda     $3C
        cmp     #$0A
        beq     L6_8B1D
        tya
        sbc     #$04
        cpx     #$04
        bcc     L6_8B1A
        adc     #$07
L6_8B1A:
        and     #$0F
        tay

; ---- bank6.code_8B1D (code) $8B1D-$8B26, 10 bytes
L6_8B1D:
        lda     $8B6F,Y
        sta     $18
        lda     $8B73,Y
        sta     $19

; ---- bank6.code_8B27 (code) $8B27-$8B30, 10 bytes
        lda     $41
        and     #$01
        beq     L6_8B31
        asl     $19
        asl     $18

; ---- bank6.code_8B31 (code) $8B31-$8B3E, 14 bytes
L6_8B31:
        bit     $30
        bvc     L6_8B3F
        cpy     #$0C
        bne     L6_8B3F
        lda     $18
        sbc     #$08
        sta     $18

; ---- bank6.code_8B3F (code) $8B3F-$8B5A, 28 bytes
L6_8B3F:
        tya
        lsr     A
        and     #$03
        tay
        lda     $8B83,Y
        sta     $0548,X
        lda     $8B87,Y
        sta     $06C8,X
        lda     $0560,X
        and     #$03
        ora     $8B8B,Y
        sta     $0560,X

; ---- bank6.code_8B5B (code) $8B5B-$8B6E, 20 bytes
        lda     $05A8
        asl     A
        ldy     $3D
        dey
        beq     L6_8B69
        asl     A
        dey
        beq     L6_8B69
        asl     A
L6_8B69:
        sta     $05A8,X
        jmp     L6_88C7

; ---- bank6.tbl_8B6F (data) $8B6F-$8B82, 20 bytes
; Blade offsets: a sine of 16 entries, read at two phases
        .byte   $00,$06,$0B,$0F,$10,$0F,$0B,$06,$00,$FA,$F5,$F1,$F0,$F1,$F5,$FA
        .byte   $00,$06,$0B,$0F

; ---- bank6.tbl_8B83 (data) $8B83-$8B86, 4 bytes
; Blade metasprites by phase
        .byte   $1A,$79,$37,$79

; ---- bank6.tbl_8B87 (data) $8B87-$8B8A, 4 bytes
; Blade tile bases by phase
        .byte   $7C,$7A,$7E,$7A

; ---- bank6.tbl_8B8B (data) $8B8B-$8B8E, 4 bytes
; Blade palette / flip by phase
        .byte   $00,$80,$00,$00

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

; ---- bank6.code_8B9F (code) $8B9F-$8BA6, 8 bytes
L6_8B9F:
        lda     $F5
        ora     $F6
        and     #$80
        beq     L6_8BCB

; ---- bank6.code_8BA7 (code) $8BA7-$8BB5, 15 bytes
        lda     #$2F
        jsr     L7_C030
        lda     #$30
        jsr     L7_C0CC
        lda     #$2F
        jsr     L7_C030

; ---- bank6.code_8BB6 (code) $8BB6-$8BBA, 5 bytes
        ldy     #$06
        jsr     L7_C021

; ---- bank6.code_8BBB (code) $8BBB-$8BBD, 3 bytes
        jsr     L6_8BCE

; ---- bank6.code_8BBE (code) $8BBE-$8BC2, 5 bytes
        lda     #$0F
        jsr     L7_C0CC

; ---- bank6.code_8BC3 (code) $8BC3-$8BCA, 8 bytes
        dec     $04AF
        dec     $3E
        jsr     L7_C072

; ---- bank6.code_8BCB (code) $8BCB-$8BCD, 3 bytes
L6_8BCB:
        jmp     L7_C048

; ---- bank6.code_8BCE (code) $8BCE-$8BEE, 33 bytes
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

; ---- bank6.code_8BEF (code) $8BEF-$8BF3, 5 bytes
L6_8BEF:
        lda     $0500,X
        bmi     L6_8C1F

; ---- bank6.code_8BF4 (code) $8BF4-$8BF6, 3 bytes
        jsr     L7_C0A8

; ---- bank6.code_8BF7 (code) $8BF7-$8BFE, 8 bytes
        lda     $0518,X
        bne     L6_8BFF
        jsr     L7_C0F0

; ---- bank6.code_8BFF (code) $8BFF-$8C07, 9 bytes
L6_8BFF:
        lda     $07E8,X
        clc
        adc     #$0C
        sta     $06C8,X

; ---- bank6.code_8C08 (code) $8C08-$8C1E, 23 bytes
        jsr     L7_C0A2
        lda     #$01
        sta     $0560,X
        lda     #$1A
        sta     $0548,X
        jsr     L7_C0EA
        and     #$7F
        adc     #$20
        sta     $0788,X

; ---- bank6.code_8C1F (code) $8C1F-$8C23, 5 bytes
L6_8C1F:
        lda     $0788,X
        beq     L6_8C50

; ---- bank6.code_8C24 (code) $8C24-$8C3D, 26 bytes
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

; ---- bank6.code_8C3E (code) $8C3E-$8C4F, 18 bytes
L6_8C3E:
        lda     #$00
        sta     $0788,X
        lda     #$06
        sta     $0698,X
        jsr     L7_C0FC
        lda     #$02
        sta     $0560,X

; ---- bank6.code_8C50 (code) $8C50-$8C69, 26 bytes
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

; ---- bank6.tbl_8C6A (data) $8C6A-$8C70, 7 bytes
; Wing animation: metasprite by phase
        .byte   $1A,$19,$19,$19,$19,$19,$19

; ---- bank6.tbl_8C71 (data) $8C71-$8C77, 7 bytes
; Wing animation: flip bits by phase
        .byte   $00,$40,$40,$40,$00,$00,$00

; ---- bank6.tbl_8C78 (data) $8C78-$8C7E, 7 bytes
; Wing animation: tile offset by phase
        .byte   $0C,$08,$04,$00,$00,$04,$08

; ---- bank6.code_8C7F (code) $8C7F-$8C97, 25 bytes
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

; ---- bank6.code_8C98 (code) $8C98-$8C9C, 5 bytes
L6_8C98:
        ldy     $0500,X
        bmi     L6_8CC8

; ---- bank6.code_8C9D (code) $8C9D-$8CA8, 12 bytes
        lda     $8D50,Y
        sta     $0560,X
        lda     $8D54,Y
        sta     $07B8,X

; ---- bank6.code_8CA9 (code) $8CA9-$8CAE, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C165

; ---- bank6.code_8CAF (code) $8CAF-$8CC7, 25 bytes
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

; ---- bank6.code_8CC8 (code) $8CC8-$8CCC, 5 bytes
L6_8CC8:
        lda     #$02
        jsr     L7_C09C

; ---- bank6.code_8CCD (code) $8CCD-$8CD1, 5 bytes
        lda     $0788,X
        beq     L6_8CF6

; ---- bank6.code_8CD2 (code) $8CD2-$8CE2, 17 bytes
        lda     $05D8,X
        bpl     L6_8CDF
        lda     $0518,X
        cmp     $0788,X
        bcc     L6_8CE3
L6_8CDF:
        jsr     L7_C08D
        rts

; ---- bank6.code_8CE3 (code) $8CE3-$8CF5, 19 bytes
L6_8CE3:
        lda     #$00
        sta     $0788,X
        lda     #$60
        sta     $0668,X
        ldy     $0500,X
        lda     $8CD2,Y
        sta     $0560,X

; ---- bank6.code_8CF6 (code) $8CF6-$8CFB, 6 bytes
L6_8CF6:
        lda     $41
        and     #$1F
        bne     L6_8D2C

; ---- bank6.code_8CFC (code) $8CFC-$8D2B, 48 bytes
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

; ---- bank6.code_8D2C (code) $8D2C-$8D5E, 51 bytes
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

; ---- bank6.code_8D5F (code) $8D5F-$8D67, 9 bytes
L6_8D5F:
        jsr     L7_C08D
        jsr     L7_C0C6
        jmp     L7_C0D8

; ---- bank6.tbl_8D68 (data) $8D68-$8D6F, 8 bytes
; Eyegore: palettes, summoned type, x offset
        .byte   $01,$03,$02,$00,$16,$27,$E0,$20

; ---- bank6.code_8D70 (code) $8D70-$8D74, 5 bytes
L6_8D70:
        lda     $0500,X
        bmi     L6_8D9B

; ---- bank6.code_8D75 (code) $8D75-$8D7A, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C165

; ---- bank6.code_8D7B (code) $8D7B-$8D82, 8 bytes
        lda     #$00
        sta     $0560,X
        jsr     L7_C0F0

; ---- bank6.code_8D83 (code) $8D83-$8D8C, 10 bytes
        lda     #$78
        sta     $0788,X
        lda     #$C0
        sta     $0518,X

; ---- bank6.code_8D8D (code) $8D8D-$8D9A, 14 bytes
L6_8D8D:
        jsr     L7_C147
        lda     #$FB
        sta     $0668,X
        sta     $05D8,X
        jsr     L7_C0A2

; ---- bank6.code_8D9B (code) $8D9B-$8DA7, 13 bytes
L6_8D9B:
        lda     $0788,X
        beq     L6_8DA8
        dec     $0788,X
        and     #$01
        beq     L6_8E01
        rts

; ---- bank6.code_8DA8 (code) $8DA8-$8DB7, 16 bytes
L6_8DA8:
        lda     #$18
        jsr     L7_C09C
        lda     $0530
        sta     $0680,X
        lda     #$08
        jsr     L7_C09F

; ---- bank6.code_8DB8 (code) $8DB8-$8DC3, 12 bytes
        lda     $05D8,X
        bmi     L6_8E01
        lda     $0518,X
        cmp     #$C0
        bcs     L6_8D8D

; ---- bank6.code_8DC4 (code) $8DC4-$8DCA, 7 bytes
        lda     $0638,X
        cmp     #$02
        bcs     L6_8E01

; ---- bank6.code_8DCB (code) $8DCB-$8DD5, 11 bytes
        lda     #$40
        ldy     #$03
        jsr     L7_C0A5
        cpy     #$02
        bcc     L6_8E01

; ---- bank6.code_8DD6 (code) $8DD6-$8DDE, 9 bytes
        jsr     L7_C0FF
        sta     $14
        lda     #$02
        sta     $15

; ---- bank6.code_8DDF (code) $8DDF-$8E00, 34 bytes
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

; ---- bank6.code_8E01 (code) $8E01-$8E0F, 15 bytes
L6_8E01:
        ldy     $0638,X
        lda     $8E5F,Y
        sta     $0548,X
        lda     $8E62,Y
        jsr     L6_A1E7

; ---- bank6.code_8E10 (code) $8E10-$8E1A, 11 bytes
        lda     $0788,X
        beq     L6_8E1B
        jsr     L7_C090
        jmp     L6_8E30

; ---- bank6.code_8E1B (code) $8E1B-$8E1F, 5 bytes
L6_8E1B:
        jsr     L7_C08D
        bcc     L6_8E30

; ---- bank6.code_8E20 (code) $8E20-$8E2F, 16 bytes
L6_8E20:
        lda     #$00
        sta     $0530,X
        lda     $0608,X
        bmi     L6_8E2D
        dec     $0530,X
L6_8E2D:
        jmp     L7_C123

; ---- bank6.code_8E30 (code) $8E30-$8E42, 19 bytes
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

; ---- bank6.code_8E43 (code) $8E43-$8E48, 6 bytes
L6_8E43:
        lda     $0788,X
        beq     L6_8E49
        rts

; ---- bank6.code_8E49 (code) $8E49-$8E58, 16 bytes
L6_8E49:
        jsr     L7_C0B1
        lda     $0710,X
        sec
        sbc     #$30
        bcs     L6_8E56
        lda     #$00
L6_8E56:
        sta     $0710,X

; ---- bank6.code_8E59 (code) $8E59-$8E5E, 6 bytes
        jsr     L7_C0C9
        jmp     L7_C0D8

; ---- bank6.tbl_8E5F (data) $8E5F-$8E61, 3 bytes
; Zibzub metasprite by phase
        .byte   $80,$80,$81

; ---- bank6.tbl_8E62 (data) $8E62-$8E64, 3 bytes
; Zibzub tile offset by phase
        .byte   $1E,$16,$00

; ---- bank6.tbl_8E65 (data) $8E65-$8E67, 3 bytes
; Zibzub volley direction offsets
        .byte   $00,$04,$0C

; ---- bank6.code_8E68 (code) $8E68-$8E6C, 5 bytes
L6_8E68:
        ldy     $0500,X
        bmi     L6_8E9F

; ---- bank6.code_8E6D (code) $8E6D-$8E7E, 18 bytes
        lda     $900D,Y
        sta     $0560,X
        lda     $9010,Y
        sta     $07A0,X
        lda     $9013,Y
        sta     $07D0,X

; ---- bank6.code_8E7F (code) $8E7F-$8E84, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C165

; ---- bank6.code_8E85 (code) $8E85-$8E9E, 26 bytes
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

; ---- bank6.code_8E9F (code) $8E9F-$8EAE, 16 bytes
L6_8E9F:
        lda     $0788,X
        beq     L6_8EAF
        dec     $0788,X
        lda     $0788,X
        and     #$01
        bne     L6_8EC0
        rts

; ---- bank6.code_8EAF (code) $8EAF-$8EB7, 9 bytes
L6_8EAF:
        lda     $41
        and     #$01
        bne     L6_8EB8
        jsr     L6_A325

; ---- bank6.code_8EB8 (code) $8EB8-$8EBF, 8 bytes
L6_8EB8:
        lda     $07A0,X
        ldy     #$3C
        jsr     L7_C0A5

; ---- bank6.code_8EC0 (code) $8EC0-$8EC2, 3 bytes
L6_8EC0:
        jsr     L7_C090

; ---- bank6.code_8EC3 (code) $8EC3-$8EC7, 5 bytes
        lda     $0740,X
        beq     L6_8ECB

; ---- bank6.code_8EC8 (code) $8EC8-$8ECA, 3 bytes
        jmp     L6_8F50

; ---- bank6.code_8ECB (code) $8ECB-$8ED3, 9 bytes
L6_8ECB:
        lda     $07B8,X
        cmp     #$01
        bcc     L6_8F41
        beq     L6_8EEF

; ---- bank6.code_8ED4 (code) $8ED4-$8EEE, 27 bytes
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

; ---- bank6.code_8EEF (code) $8EEF-$8EF9, 11 bytes
L6_8EEF:
        lda     #$01
        sta     $86
        lda     $0590,X
        cmp     #$14
        bcs     L6_8F50

; ---- bank6.code_8EFA (code) $8EFA-$8F18, 31 bytes
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

; ---- bank6.code_8F19 (code) $8F19-$8F40, 40 bytes
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

; ---- bank6.code_8F41 (code) $8F41-$8F4F, 15 bytes
L6_8F41:
        lda     $0590,X
        cmp     #$14
        bcs     L6_8F50
        lda     #$64
        sta     $0590,X
        inc     $07B8,X

; ---- bank6.code_8F50 (code) $8F50-$8F74, 37 bytes
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

; ---- bank6.code_8F75 (code) $8F75-$8F8F, 27 bytes
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

; ---- bank6.code_8F90 (code) $8F90-$8FA9, 26 bytes
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

; ---- bank6.code_8FAA (code) $8FAA-$8FAF, 6 bytes
L6_8FAA:
        lda     $0788,X
        beq     L6_8FB0
        rts

; ---- bank6.code_8FB0 (code) $8FB0-$8FB6, 7 bytes
L6_8FB0:
        lda     $0638,X
        cmp     #$1C
        bne     L6_8FEC

; ---- bank6.code_8FB7 (code) $8FB7-$8FC2, 12 bytes
        lda     $07E8,X
        clc
        adc     #$1E
        sta     $17
        lda     #$10
        sta     $16

; ---- bank6.code_8FC3 (code) $8FC3-$8FEB, 41 bytes
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

; ---- bank6.code_8FEC (code) $8FEC-$8FF6, 11 bytes
L6_8FEC:
        lda     $0638,X
        cmp     #$1A
        bcs     L6_9018
        and     #$07
        bne     L6_9018

; ---- bank6.code_8FF7 (code) $8FF7-$9017, 33 bytes
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

; ---- bank6.code_9018 (code) $9018-$902A, 19 bytes
L6_9018:
        jsr     L7_C0B1
        lda     $07B8,X
        cmp     #$02
        bcs     L6_902B
        lda     $0728,X
        clc
        adc     #$40
        sta     $0728,X

; ---- bank6.code_902B (code) $902B-$9030, 6 bytes
L6_902B:
        jsr     L7_C0C9
        jmp     L7_C0D8

; ---- bank6.tbl_9031 (data) $9031-$9033, 3 bytes
; Clawbot palette by type
        .byte   $03,$02,$00

; ---- bank6.tbl_9034 (data) $9034-$9036, 3 bytes
; Clawbot animation step by type
        .byte   $20,$40,$80

; ---- bank6.tbl_9037 (data) $9037-$9039, 3 bytes
; Clawbot bullet limit by type
        .byte   $01,$01,$05

; ---- bank6.code_903A (code) $903A-$9079, 64 bytes
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

; ---- bank6.code_907A (code) $907A-$907C, 3 bytes
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

; ---- bank6.tbl_9171 (data) $9171-$9175, 5 bytes
; Table, 5 bytes
        .byte   $40,$40,$00,$00,$00

; ---- bank6.tbl_9176 (data) $9176-$917F, 10 bytes
; Table, 10 bytes (structural extent)
        .byte   $22,$23,$24,$23,$22,$14,$0C,$FC,$F4,$EC

; ---- bank6.tbl_9180 (data) $9180-$9187, 8 bytes
; Table, 8 bytes (structural extent)
        .byte   $00,$01,$02,$03,$04,$03,$02,$01

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

; ---- bank6.tbl_92FD (data) $92FD-$9305, 9 bytes
; Table, 9 bytes
        .byte   $FC,$FD,$FE,$FF,$00,$01,$02,$03,$04

; ---- bank6.tbl_9306 (data) $9306-$930D, 8 bytes
; Table, 8 bytes
        .byte   $00,$00,$00,$01,$01,$01,$00,$00

; ---- bank6.tbl_930E (data) $930E-$930F, 2 bytes
; Table, 2 bytes (structural extent)
        .byte   $00,$04

; ---- bank6.tbl_9310 (data) $9310-$9311, 2 bytes
; Table, 2 bytes (structural extent)
        .byte   $19,$37

; ---- bank6.tbl_9312 (data) $9312-$9315, 4 bytes
; Table, 4 bytes
        .byte   $40,$00,$00,$40

; ---- bank6.tbl_9316 (data) $9316-$9319, 4 bytes
; Table, 4 bytes (structural extent)
        .byte   $8A,$89,$01,$05

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

; ---- bank6.tbl_93D3 (data) $93D3-$93D7, 5 bytes
; Table, 5 bytes (structural extent)
        .byte   $00,$08,$10,$18,$10

; ---- bank6.tbl_93D8 (data) $93D8-$93DB, 4 bytes
; Table, 4 bytes (structural extent)
        .byte   $08,$00,$08,$0C

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

; ---- bank6.tbl_95C3 (data) $95C3-$95CF, 13 bytes
; Table, 13 bytes (structural extent)
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

; ---- bank6.code_960B (code) $960B-$960B, 1 bytes
        rts

; ---- bank6.code_960C (code) $960C-$9610, 5 bytes
L6_960C:
        lda     $0500,X
        bmi     L6_9631

; ---- bank6.code_9611 (code) $9611-$9618, 8 bytes
        lda     #$03
        sta     $0698,X
        jsr     L6_963A

; ---- bank6.code_9619 (code) $9619-$961B, 3 bytes
        jsr     L7_C0FC

; ---- bank6.code_961C (code) $961C-$9630, 21 bytes
L6_961C:
        lda     #$25
        sta     $0548,X
        lda     #$00
        sta     $0560,X
        lda     #$8A
        sta     $06C8,X
        jsr     L7_C0AE
        jsr     L7_C162

; ---- bank6.code_9631 (code) $9631-$9639, 9 bytes
L6_9631:
        jsr     L6_9646
        jsr     L7_C0BD
        jmp     L7_C0D5

; ---- bank6.code_963A (code) $963A-$9645, 12 bytes
L6_963A:
        lda     $4B
        cmp     #$04
        bcc     L6_9645
        lda     #$05
        sta     $0698,X
L6_9645:
        rts

; ---- bank6.code_9646 (code) $9646-$9666, 33 bytes
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

; ---- bank6.code_9667 (code) $9667-$967C, 22 bytes
L6_9667:
        lda     $0500,X
        bmi     L6_9631
        lda     #$03
        sta     $0698,X
        jsr     L6_963A
        lda     $0788,X
        jsr     L7_C102
        jmp     L6_961C

; ---- bank6.code_967D (code) $967D-$969D, 33 bytes
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

; ---- bank6.code_969E (code) $969E-$96AB, 14 bytes
L6_969E:
        lda     #$40
        jsr     L6_96AC
        jsr     L6_9646
        jsr     L7_C0C6
        jmp     L7_C0D5

; ---- bank6.code_96AC (code) $96AC-$96C3, 24 bytes
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

; ---- bank6.tbl_96C4 (data) $96C4-$96C7, 4 bytes
; Shot animation: metasprites
        .byte   $1A,$79,$37,$79

; ---- bank6.tbl_96C8 (data) $96C8-$96CB, 4 bytes
; Shot animation: palettes
        .byte   $00,$01,$02,$43

; ---- bank6.tbl_96CC (data) $96CC-$96CF, 4 bytes
; Shot animation: tile numbers
        .byte   $F8,$FA,$FC,$FA

; ---- bank6.code_96D0 (code) $96D0-$96D4, 5 bytes
L6_96D0:
        lda     $0500,X
        bmi     L6_972A

; ---- bank6.code_96D5 (code) $96D5-$96D9, 5 bytes
        lda     $0728,X
        beq     L6_96FE

; ---- bank6.code_96DA (code) $96DA-$96E5, 12 bytes
        lda     $07B8,X
        jsr     L7_C0AB
        lda     $07A0,X
        jsr     L6_A1E7

; ---- bank6.code_96E6 (code) $96E6-$96FD, 24 bytes
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

; ---- bank6.code_96FE (code) $96FE-$9712, 21 bytes
L6_96FE:
        jsr     L7_C0AE
        lda     #$25
        sta     $0548,X
        lda     #$00
        sta     $0560,X
        sta     $07B8,X
        lda     #$8A
        sta     $06C8,X

; ---- bank6.code_9713 (code) $9713-$9729, 23 bytes
L6_9713:
        jsr     L7_C162
        lda     #$FE
        sta     $05D8,X
        sta     $0668,X
        lda     $0788,X
        sta     $0608,X
        jsr     L7_C0EA
        sta     $05F0,X

; ---- bank6.code_972A (code) $972A-$972E, 5 bytes
L6_972A:
        lda     #$14
        jsr     L7_C09C

; ---- bank6.code_972F (code) $972F-$9741, 19 bytes
L6_972F:
        lda     $0578,X
        and     #$04
        beq     L6_9739
        jmp     L6_9631
L6_9739:
        jsr     L7_C08D
        jsr     L7_C0C6
        jmp     L7_C0D5

; ---- bank6.code_9742 (code) $9742-$975E, 29 bytes
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

; ---- bank6.code_975F (code) $975F-$9763, 5 bytes
L6_975F:
        lda     $0500,X
        bmi     L6_97B1

; ---- bank6.code_9764 (code) $9764-$9779, 22 bytes
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

; ---- bank6.code_977A (code) $977A-$977D, 4 bytes
L6_977A:
        tya
        jsr     L7_C030

; ---- bank6.code_977E (code) $977E-$9783, 6 bytes
L6_977E:
        jsr     L7_C0A2
L6_9781:
        jsr     L7_C02A

; ---- bank6.code_9784 (code) $9784-$9793, 16 bytes
        lda     $0578,X
        and     #$10
        pha
        jsr     L7_C0AE
        pla
        ora     $0578,X
        sta     $0578,X

; ---- bank6.code_9794 (code) $9794-$979E, 11 bytes
        lda     #$00
        sta     $0560,X
        sta     $06C8,X
        sta     $0788,X

; ---- bank6.code_979F (code) $979F-$97AD, 15 bytes
        lda     $0500,X
        cmp     #$88
        bne     L6_97B1
        ldy     $0740,X
        beq     L6_97B1
        jsr     L7_C006

; ---- bank6.inline_97AE (data) $97AE-$97B0, 3 bytes
; Far-call argument at $97AE
        .byte   $01,$08,$80

; ---- bank6.code_97B1 (code) $97B1-$97BF, 15 bytes
L6_97B1:
        lda     $0500,X
        cmp     #$87
        beq     L6_97D4
        lda     $0788,X
        beq     L6_97C0
        jmp     L6_9842

; ---- bank6.code_97C0 (code) $97C0-$97D3, 20 bytes
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

; ---- bank6.code_97D4 (code) $97D4-$97DE, 11 bytes
L6_97D4:
        lda     #$60
        ldy     #$10
        jsr     L7_C0A5
        bcs     L6_9836
        lda     #$0F

; ---- bank6.code_97DF (code) $97DF-$97E2, 4 bytes
L6_97DF:
        sty     $14
        sta     $15

; ---- bank6.code_97E3 (code) $97E3-$9805, 35 bytes
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

; ---- bank6.code_9806 (code) $9806-$9821, 28 bytes
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

; ---- bank6.code_9822 (code) $9822-$982C, 11 bytes
L6_9822:
        dec     $15
        lda     $15
        and     #$0F
        cmp     #$0F
        bne     L6_97E3
        rts

; ---- bank6.code_982D (code) $982D-$9835, 9 bytes
L6_982D:
        lda     #$40
        ldy     #$06
L6_9831:
        jsr     L7_C0A5
        bcc     L6_9839

; ---- bank6.code_9836 (code) $9836-$9838, 3 bytes
L6_9836:
        jmp     L7_C048

; ---- bank6.code_9839 (code) $9839-$9841, 9 bytes
L6_9839:
        lda     $9919,Y
        sta     $0548,X
        jmp     L7_C090

; ---- bank6.code_9842 (code) $9842-$9855, 20 bytes
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

; ---- bank6.code_9856 (code) $9856-$9862, 13 bytes
L6_9856:
        and     #$03
        sta     $0560,X
        tay
        lda     $9915,Y
        sta     $0548,X
        rts

; ---- bank6.code_9863 (code) $9863-$9891, 47 bytes
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

; ---- bank6.code_9892 (code) $9892-$98CA, 57 bytes
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

; ---- bank6.tbl_98CB (data) $98CB-$98E0, 22 bytes
; Big explosion: start phase of each piece
        .byte   $00,$00,$01,$01,$01,$01,$02,$02,$02,$03,$03,$03,$03,$03,$04,$04
        .byte   $00,$01,$01,$02,$03,$04

; ---- bank6.tbl_98E1 (data) $98E1-$98F6, 22 bytes
; Big explosion: x offset of each piece
        .byte   $FC,$08,$F8,$F6,$06,$04,$0C,$FB,$0A,$F4,$F5,$EA,$18,$07,$F3,$14
        .byte   $00,$08,$F7,$05,$FC,$F6

; ---- bank6.tbl_98F7 (data) $98F7-$990C, 22 bytes
; Big explosion: y offset of each piece
        .byte   $FA,$E8,$10,$F0,$02,$19,$F8,$EC,$0C,$06,$E4,$F6,$E6,$F2,$16,$0B
        .byte   $00,$F7,$08,$0C,$F4,$06

; ---- bank6.tbl_990D (data) $990D-$9914, 8 bytes
; Big explosion: metasprite by age
        .byte   $30,$30,$31,$31,$32,$32,$33,$33

; ---- bank6.tbl_9915 (data) $9915-$9918, 4 bytes
; Explosion: four-picture cycle
        .byte   $30,$31,$32,$31

; ---- bank6.tbl_9919 (data) $9919-$991E, 6 bytes
; Small explosion: metasprite by phase
        .byte   $30,$30,$31,$31,$32,$33

; ---- bank6.code_991F (code) $991F-$9924, 6 bytes
L6_991F:
        clc
        bmi     L6_9925
        adc     $17
        rts

; ---- bank6.code_9925 (code) $9925-$992B, 7 bytes
L6_9925:
        adc     $17
        rol     A
        eor     #$01
        ror     A
        rts

; ---- bank6.code_992C (code) $992C-$9930, 5 bytes
L6_992C:
        lda     $0500,X
        bmi     L6_994F

; ---- bank6.code_9931 (code) $9931-$993A, 10 bytes
        lda     $0740,X
        bne     L6_993B
        sta     $0578,X
        beq     L6_9940

; ---- bank6.code_993B (code) $993B-$993F, 5 bytes
L6_993B:
        lda     #$23
        jsr     L7_C030

; ---- bank6.code_9940 (code) $9940-$994E, 15 bytes
L6_9940:
        jsr     L7_C0A2
        lda     $0518,X
        clc
        adc     $B7
        sta     $0518,X
        jmp     L6_9781

; ---- bank6.code_994F (code) $994F-$9957, 9 bytes
L6_994F:
        lda     $0518,X
        clc
        adc     $B7
        sta     $0518,X

; ---- bank6.code_9958 (code) $9958-$9961, 10 bytes
        lda     $0578,X
        and     #$10
        beq     L6_9962
        jmp     L6_97C7

; ---- bank6.code_9962 (code) $9962-$9968, 7 bytes
L6_9962:
        lda     #$80
        ldy     #$06
        jmp     L6_9831

; ---- bank6.code_9969 (code) $9969-$9971, 9 bytes
L6_9969:
        dec     $0578,X
        beq     L6_996F
        rts
L6_996F:
        jmp     L7_C048

; ---- bank6.code_9972 (code) $9972-$9987, 22 bytes
L6_9972:
        lda     $0500,X
        bmi     L6_9988
        lda     $0578,X
        sta     $0788,X
        jsr     L7_C0AE
        jsr     L7_C0A2
        lda     #$02
        sta     $0560,X

; ---- bank6.code_9988 (code) $9988-$9990, 9 bytes
L6_9988:
        lda     #$60
        ldy     #$10
        jsr     L7_C0A5
        bcs     L6_996F

; ---- bank6.code_9991 (code) $9991-$999C, 12 bytes
        lda     $99C9,Y
        sta     $0548,X
        lda     $99D9,Y
        sta     $06C8,X

; ---- bank6.code_999D (code) $999D-$999F, 3 bytes
        jsr     L7_C090

; ---- bank6.code_99A0 (code) $99A0-$99A6, 7 bytes
        lda     $0788,X
        and     #$10
        beq     L6_99C8

; ---- bank6.code_99A7 (code) $99A7-$99C7, 33 bytes
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

; ---- bank6.code_99C8 (code) $99C8-$99C8, 1 bytes
L6_99C8:
        rts

; ---- bank6.tbl_99C9 (data) $99C9-$99D8, 16 bytes
; Dissolve: metasprite by phase
        .byte   $79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$37,$37,$37,$37

; ---- bank6.tbl_99D9 (data) $99D9-$99E8, 16 bytes
; Dissolve: tile base by phase
        .byte   $01,$03,$01,$03,$01,$03,$01,$03,$01,$03,$05,$07,$09,$0B,$0D,$0F

; ---- bank6.tbl_99E9 (data) $99E9-$99EC, 4 bytes
; Dissolve: corner x offsets
        .byte   $F6,$0A,$F6,$0A

; ---- bank6.tbl_99ED (data) $99ED-$99F0, 4 bytes
; Dissolve: corner y offsets
        .byte   $F6,$F6,$0A,$0A

; ---- bank6.code_99F1 (code) $99F1-$99F3, 3 bytes
L6_99F1:
        jsr     L7_C006

; ---- bank6.inline_99F4 (data) $99F4-$99F6, 3 bytes
; Far-call argument at $99F4
        .byte   $02,$0E,$80

; ---- bank6.code_99F7 (code) $99F7-$99F7, 1 bytes
        rts

; ---- bank6.code_99F8 (code) $99F8-$9A0A, 19 bytes
L6_99F8:
        lda     $0500,X
        bmi     L6_9A0B
        jsr     L7_C0AE
        lda     $0788,X
        sta     $0620,X
        lda     #$00
        sta     $0788,X

; ---- bank6.code_9A0B (code) $9A0B-$9A0D, 3 bytes
L6_9A0B:
        jsr     L7_C006

; ---- bank6.inline_9A0E (data) $9A0E-$9A10, 3 bytes
; Far-call argument at $9A0E
        .byte   $02,$08,$80

; ---- bank6.code_9A11 (code) $9A11-$9A11, 1 bytes
        rts

; ---- bank6.code_9A12 (code) $9A12-$9A14, 3 bytes
L6_9A12:
        jsr     L7_C006

; ---- bank6.inline_9A15 (data) $9A15-$9A17, 3 bytes
; Far-call argument at $9A15
        .byte   $05,$11,$80

; ---- bank6.code_9A18 (code) $9A18-$9A18, 1 bytes
        rts

; ---- bank6.code_9A19 (code) $9A19-$9A2D, 21 bytes
L6_9A19:
        lda     $0500,X
        bmi     L6_9A2E
        jsr     L7_C0AE
        lda     #$01
        sta     $0698,X
        jsr     L7_C0F0
        lda     #$00
        sta     $0518,X

; ---- bank6.code_9A2E (code) $9A2E-$9A33, 6 bytes
L6_9A2E:
        lda     $60
        and     #$08
        bne     L6_9A52

; ---- bank6.code_9A34 (code) $9A34-$9A38, 5 bytes
        dec     $0698,X
        bne     L6_9A52

; ---- bank6.code_9A39 (code) $9A39-$9A51, 25 bytes
        lda     $07A0,X
        sta     $0698,X
        jsr     L7_C108
        bcs     L6_9A52
        lda     $0548,X
        jsr     L7_C105
        dec     $0560,X
        bne     L6_9A52
        jmp     L7_C048

; ---- bank6.code_9A52 (code) $9A52-$9A52, 1 bytes
L6_9A52:
        rts

; ---- bank6.code_9A53 (code) $9A53-$9A5B, 9 bytes
L6_9A53:
        jsr     L6_8435
        ldy     $6C
        lda     $8425,Y
        rts

; ---- bank6.code_9A5C (code) $9A5C-$9A60, 5 bytes
L6_9A5C:
        lda     $0500,X
        bmi     L6_9AA7

; ---- bank6.code_9A61 (code) $9A61-$9A65, 5 bytes
        lda     $0728,X
        bne     L6_9A71

; ---- bank6.code_9A66 (code) $9A66-$9A70, 11 bytes
        jsr     L7_C0F3
        jsr     L6_9A53
        beq     L6_9A71
        jmp     L6_9B17

; ---- bank6.code_9A71 (code) $9A71-$9A73, 3 bytes
L6_9A71:
        jsr     L7_C0A8

; ---- bank6.code_9A74 (code) $9A74-$9A78, 5 bytes
        lda     #$01
        sta     $0680,X

; ---- bank6.code_9A79 (code) $9A79-$9A7B, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_9A7C (code) $9A7C-$9A80, 5 bytes
        lda     #$3C
        sta     $0548,X

; ---- bank6.code_9A81 (code) $9A81-$9A83, 3 bytes
        jsr     L6_9B0F

; ---- bank6.code_9A84 (code) $9A84-$9A8F, 12 bytes
        lda     $9ADB,Y
        sta     $0560,X
        lda     $9AE1,Y
        sta     $0698,X

; ---- bank6.code_9A90 (code) $9A90-$9A9B, 12 bytes
        lda     $9AE7,Y
        sta     $0668,X
        lda     $9AED,Y
        sta     $05A8,X

; ---- bank6.code_9A9C (code) $9A9C-$9AA1, 6 bytes
        lda     $9AF3,Y
        sta     $0590,X

; ---- bank6.code_9AA2 (code) $9AA2-$9AA6, 5 bytes
        lda     #$28
        sta     $0788,X

; ---- bank6.code_9AA7 (code) $9AA7-$9AAE, 8 bytes
L6_9AA7:
        jsr     L7_C009
        lda     #$40
        jsr     L6_9AF9

; ---- bank6.code_9AAF (code) $9AAF-$9AB3, 5 bytes
        dec     $0680,X
        bne     L6_9AC6

; ---- bank6.code_9AB4 (code) $9AB4-$9AC5, 18 bytes
        jsr     L7_C0EA
        tay
        and     #$3F
        adc     $0668,X
        sta     $0680,X
        tya
        and     #$0F
        jsr     L7_C102

; ---- bank6.code_9AC6 (code) $9AC6-$9AC8, 3 bytes
L6_9AC6:
        jsr     L6_9B2A

; ---- bank6.code_9AC9 (code) $9AC9-$9AD4, 12 bytes
        ldy     $6C
        lda     $8425,Y
        beq     L6_9AD5
        lda     #$01
        sta     $0680,X

; ---- bank6.code_9AD5 (code) $9AD5-$9AD7, 3 bytes
L6_9AD5:
        jsr     L7_C0C6

; ---- bank6.code_9AD8 (code) $9AD8-$9ADA, 3 bytes
        jmp     L7_C0D2

; ---- bank6.tbl_9ADB (data) $9ADB-$9AE0, 6 bytes
; Type $0E palette by area tier
        .byte   $00,$00,$00,$01,$02,$03

; ---- bank6.tbl_9AE1 (data) $9AE1-$9AE6, 6 bytes
; Type $0E speed class by area tier
        .byte   $01,$02,$02,$02,$03,$41

; ---- bank6.tbl_9AE7 (data) $9AE7-$9AEC, 6 bytes
; Type $0E turn interval by area tier
        .byte   $40,$30,$20,$20,$10,$08

; ---- bank6.tbl_9AED (data) $9AED-$9AF2, 6 bytes
; Types $0E and $0F attack by area tier
        .byte   $04,$08,$10,$20,$30,$50

; ---- bank6.tbl_9AF3 (data) $9AF3-$9AF8, 6 bytes
; Types $0E and $0F hit points by area tier
        .byte   $01,$02,$06,$0C,$18,$30

; ---- bank6.code_9AF9 (code) $9AF9-$9B08, 16 bytes
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

; ---- bank6.code_9B09 (code) $9B09-$9B0E, 6 bytes
L6_9B09:
        and     $41
        beq     L6_9B00
        bne     L6_9B08

; ---- bank6.code_9B0F (code) $9B0F-$9B16, 8 bytes
L6_9B0F:
        lda     $50
        clc
        adc     #$01
        lsr     A
        tay
        rts

; ---- bank6.code_9B17 (code) $9B17-$9B29, 19 bytes
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

; ---- bank6.code_9B2A (code) $9B2A-$9B33, 10 bytes
L6_9B2A:
        bit     $30
        bvs     L6_9B34
        jsr     L6_826D
        jmp     L7_C090

; ---- bank6.code_9B34 (code) $9B34-$9B47, 20 bytes
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

; ---- bank6.code_9B48 (code) $9B48-$9B52, 11 bytes
L6_9B48:
        jsr     L6_9B53
        lda     $0500,X
        bmi     L6_9B52
        pla
        pla
L6_9B52:
        rts

; ---- bank6.code_9B53 (code) $9B53-$9B56, 4 bytes
L6_9B53:
        jsr     L7_C08D
        rts

; ---- bank6.code_9B57 (code) $9B57-$9B5B, 5 bytes
L6_9B57:
        lda     $0500,X
        bmi     L6_9BA9

; ---- bank6.code_9B5C (code) $9B5C-$9B60, 5 bytes
        lda     $0728,X
        bne     L6_9B6C

; ---- bank6.code_9B61 (code) $9B61-$9B6B, 11 bytes
        jsr     L7_C0F3
        jsr     L6_9A53
        beq     L6_9B6C
        jmp     L6_9B17

; ---- bank6.code_9B6C (code) $9B6C-$9B6E, 3 bytes
L6_9B6C:
        jsr     L7_C0A8

; ---- bank6.code_9B6F (code) $9B6F-$9B78, 10 bytes
        lda     #$03
        sta     $0698,X
        lda     #$37
        sta     $0548,X

; ---- bank6.code_9B79 (code) $9B79-$9B7B, 3 bytes
        jsr     L6_9B0F

; ---- bank6.code_9B7C (code) $9B7C-$9B87, 12 bytes
        lda     $9C0D,Y
        sta     $0560,X
        lda     $9C13,Y
        sta     $07A0,X

; ---- bank6.code_9B88 (code) $9B88-$9B90, 9 bytes
        lda     $9AED,Y
        lsr     A
        ora     #$01
        sta     $05A8,X

; ---- bank6.code_9B91 (code) $9B91-$9B96, 6 bytes
        lda     $9AF3,Y
        sta     $0590,X

; ---- bank6.code_9B97 (code) $9B97-$9BA8, 18 bytes
L6_9B97:
        lda     #$28
        sta     $0788,X
        lda     #$01
        sta     $0668,X
        jsr     L7_C0A2
        lda     #$00
        sta     $0680,X

; ---- bank6.code_9BA9 (code) $9BA9-$9BAB, 3 bytes
L6_9BA9:
        jsr     L7_C009

; ---- bank6.code_9BAC (code) $9BAC-$9BB0, 5 bytes
        dec     $0668,X
        bne     L6_9BDF

; ---- bank6.code_9BB1 (code) $9BB1-$9BBC, 12 bytes
        inc     $0680,X
        lda     $0680,X
        and     #$03
        sta     $0680,X
        tay

; ---- bank6.code_9BBD (code) $9BBD-$9BC9, 13 bytes
        bne     L6_9BC4
        lda     $07A0,X
        bne     L6_9BC7
L6_9BC4:
        lda     $9C19,Y
L6_9BC7:
        sta     $0668,X

; ---- bank6.code_9BCA (code) $9BCA-$9BCD, 4 bytes
        cpy     #$02
        bne     L6_9BDF

; ---- bank6.code_9BCE (code) $9BCE-$9BDE, 17 bytes
        jsr     L7_C0FF
        sta     $15
        jsr     L7_C0EA
        and     #$03
        adc     $15
        and     #$0C
        jsr     L7_C102

; ---- bank6.code_9BDF (code) $9BDF-$9BF6, 24 bytes
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

; ---- bank6.code_9BF7 (code) $9BF7-$9C03, 13 bytes
L6_9BF7:
        lda     $0680,X
        cmp     #$02
        beq     L6_9C04
        jsr     L7_C090
        jmp     L6_9C07

; ---- bank6.code_9C04 (code) $9C04-$9C06, 3 bytes
L6_9C04:
        jsr     L6_9B2A

; ---- bank6.code_9C07 (code) $9C07-$9C0C, 6 bytes
L6_9C07:
        jsr     L7_C0C6
        jmp     L7_C0D2

; ---- bank6.tbl_9C0D (data) $9C0D-$9C12, 6 bytes
; Type $0F palette by area tier
        .byte   $02,$01,$01,$02,$03,$00

; ---- bank6.tbl_9C13 (data) $9C13-$9C18, 6 bytes
; Type $0F rest time by area tier
        .byte   $50,$3C,$28,$14,$0A,$01

; ---- bank6.tbl_9C19 (data) $9C19-$9C1C, 4 bytes
; Type $0F phase lengths
        .byte   $50,$28,$14,$14

; ---- bank6.code_9C1D (code) $9C1D-$9C21, 5 bytes
L6_9C1D:
        ldy     $0500,X
        bmi     L6_9C67

; ---- bank6.code_9C22 (code) $9C22-$9C2D, 12 bytes
        lda     $9CDE,Y
        sta     $0560,X
        lda     $9CF2,Y
        sta     $07D0,X

; ---- bank6.code_9C2E (code) $9C2E-$9C30, 3 bytes
        jsr     L7_C0A8

; ---- bank6.code_9C31 (code) $9C31-$9C33, 3 bytes
        jsr     L7_C162

; ---- bank6.code_9C34 (code) $9C34-$9C3B, 8 bytes
        lda     $0728,X
        bne     L6_9C3C
        jsr     L7_C0F3

; ---- bank6.code_9C3C (code) $9C3C-$9C40, 5 bytes
L6_9C3C:
        lda     #$19
        sta     $0548,X

; ---- bank6.code_9C41 (code) $9C41-$9C45, 5 bytes
        lda     #$01
        sta     $0698,X

; ---- bank6.code_9C46 (code) $9C46-$9C4A, 5 bytes
        lda     #$FF
        sta     $0668,X

; ---- bank6.code_9C4B (code) $9C4B-$9C4F, 5 bytes
        lda     #$28
        sta     $0788,X

; ---- bank6.code_9C50 (code) $9C50-$9C58, 9 bytes
        lda     $07E8,X
        clc
        adc     #$08
        sta     $06C8,X

; ---- bank6.code_9C59 (code) $9C59-$9C5E, 6 bytes
        lda     $0518,X
        sta     $07A0,X

; ---- bank6.code_9C5F (code) $9C5F-$9C61, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_9C62 (code) $9C62-$9C66, 5 bytes
        lda     #$00
        sta     $07B8,X

; ---- bank6.code_9C67 (code) $9C67-$9C69, 3 bytes
L6_9C67:
        jsr     L7_C009

; ---- bank6.code_9C6A (code) $9C6A-$9C6E, 5 bytes
        lda     $05D8,X
        bmi     L6_9CC7

; ---- bank6.code_9C6F (code) $9C6F-$9C77, 9 bytes
        lda     $07E8,X
        clc
        adc     #$04
        sta     $06C8,X

; ---- bank6.code_9C78 (code) $9C78-$9C7F, 8 bytes
        lda     $0518,X
        cmp     $07A0,X
        bcc     L6_9CC7

; ---- bank6.code_9C80 (code) $9C80-$9C82, 3 bytes
        inc     $07B8,X

; ---- bank6.code_9C83 (code) $9C83-$9C8A, 8 bytes
        lda     $07B8,X
        and     $07D0,X
        beq     L6_9C8F

; ---- bank6.code_9C8B (code) $9C8B-$9C8E, 4 bytes
        lda     #$04
        bne     L6_9C92

; ---- bank6.code_9C8F (code) $9C8F-$9C91, 3 bytes
L6_9C8F:
        jsr     L7_C0FF

; ---- bank6.code_9C92 (code) $9C92-$9C92, 1 bytes
L6_9C92:
        pha

; ---- bank6.code_9C93 (code) $9C93-$9C95, 3 bytes
        jsr     L7_C102

; ---- bank6.code_9C96 (code) $9C96-$9CA4, 15 bytes
        jsr     L7_C0EA
        and     #$1F
        sta     $15
        lda     $05C0,X
        sbc     $15
        sta     $05C0,X

; ---- bank6.code_9CA5 (code) $9CA5-$9CAD, 9 bytes
        lda     $05D8,X
        sec
        sbc     #$03
        sta     $05D8,X

; ---- bank6.code_9CAE (code) $9CAE-$9CAF, 2 bytes
        pla
        tay

; ---- bank6.code_9CB0 (code) $9CB0-$9CB9, 10 bytes
        lda     $07B8,X
        and     $07D0,X
        beq     L6_9CBA
        ldy     #$00

; ---- bank6.code_9CBA (code) $9CBA-$9CC3, 10 bytes
L6_9CBA:
        lda     $0518,X
        clc
        adc     $9CF2,Y
        sta     $07A0,X

; ---- bank6.code_9CC4 (code) $9CC4-$9CC6, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_9CC7 (code) $9CC7-$9CCB, 5 bytes
L6_9CC7:
        lda     #$20
        jsr     L7_C09C

; ---- bank6.code_9CCC (code) $9CCC-$9CD2, 7 bytes
        lda     $0638,X
        cmp     #$03
        bcs     L6_9CE0

; ---- bank6.code_9CD3 (code) $9CD3-$9CD9, 7 bytes
        lda     #$40
        ldy     #$04
        jsr     L7_C0A5

; ---- bank6.code_9CDA (code) $9CDA-$9CDF, 6 bytes
        lda     $9D06,Y
        jsr     L6_A1E7

; ---- bank6.code_9CE0 (code) $9CE0-$9CE2, 3 bytes
L6_9CE0:
        jsr     L7_C08D

; ---- bank6.code_9CE3 (code) $9CE3-$9CE4, 2 bytes
        bcc     L6_9CE8

; ---- bank6.code_9CE5 (code) $9CE5-$9CE7, 3 bytes
        jmp     L6_9B17

; ---- bank6.code_9CE8 (code) $9CE8-$9CEA, 3 bytes
L6_9CE8:
        jsr     L7_C0C6

; ---- bank6.code_9CEB (code) $9CEB-$9CED, 3 bytes
        jmp     L7_C0D2

; ---- bank6.tbl_9CEE (data) $9CEE-$9CF1, 4 bytes
; Types $10-$13 palette
        .byte   $01,$02,$00,$03

; ---- bank6.tbl_9CF2 (data) $9CF2-$9D01, 16 bytes
; Hop landing offset by direction
        .byte   $00,$04,$08,$0C,$10,$0C,$08,$04,$00,$FC,$F8,$F4,$F0,$F4,$F8,$FC

; ---- bank6.tbl_9D02 (data) $9D02-$9D05, 4 bytes
; Types $10-$13 aim mask
        .byte   $03,$01,$00,$05

; ---- bank6.tbl_9D06 (data) $9D06-$9D09, 4 bytes
; Hop picture tile offset by phase
        .byte   $08,$08,$04,$00

; ---- bank6.code_9D0A (code) $9D0A-$9D0E, 5 bytes
L6_9D0A:
        ldy     $0500,X
        bmi     L6_9D46

; ---- bank6.code_9D0F (code) $9D0F-$9D1A, 12 bytes
        lda     $9DD7,Y
        sta     $0560,X
        lda     $9DDA,Y
        sta     $0698,X

; ---- bank6.code_9D1B (code) $9D1B-$9D1D, 3 bytes
        jsr     L7_C0A8

; ---- bank6.code_9D1E (code) $9D1E-$9D20, 3 bytes
        jsr     L7_C165

; ---- bank6.code_9D21 (code) $9D21-$9D25, 5 bytes
        lda     #$1F
        sta     $0548,X

; ---- bank6.code_9D26 (code) $9D26-$9D28, 3 bytes
L6_9D26:
        jsr     L7_C0A2

; ---- bank6.code_9D29 (code) $9D29-$9D2E, 6 bytes
        jsr     L7_C0F3
        jsr     L6_9A53

; ---- bank6.code_9D2F (code) $9D2F-$9D30, 2 bytes
        beq     L6_9D34

; ---- bank6.code_9D31 (code) $9D31-$9D33, 3 bytes
        jmp     L6_9B17

; ---- bank6.code_9D34 (code) $9D34-$9D38, 5 bytes
L6_9D34:
        lda     #$3C
        sta     $0788,X

; ---- bank6.code_9D39 (code) $9D39-$9D3B, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_9D3C (code) $9D3C-$9D40, 5 bytes
        lda     #$1E
        sta     $07A0,X

; ---- bank6.code_9D41 (code) $9D41-$9D45, 5 bytes
        lda     #$04
        sta     $0668,X

; ---- bank6.code_9D46 (code) $9D46-$9D48, 3 bytes
L6_9D46:
        jsr     L7_C009

; ---- bank6.code_9D49 (code) $9D49-$9D4D, 5 bytes
        dec     $07A0,X
        bne     L6_9D95

; ---- bank6.code_9D4E (code) $9D4E-$9D54, 7 bytes
        lda     $0500,X
        cmp     #$9E
        bcc     L6_9D5F

; ---- bank6.code_9D55 (code) $9D55-$9D59, 5 bytes
        jsr     L7_C108
        bcs     L6_9D5F

; ---- bank6.code_9D5A (code) $9D5A-$9D5E, 5 bytes
        lda     #$0B
        jsr     L7_C105

; ---- bank6.code_9D5F (code) $9D5F-$9D68, 10 bytes
L6_9D5F:
        jsr     L7_C0EA
        and     #$1F
        adc     #$18
        sta     $07A0,X

; ---- bank6.code_9D69 (code) $9D69-$9D72, 10 bytes
        lda     $0500,X
        cmp     #$9F
        bcc     L6_9D73
        lsr     $07A0,X

; ---- bank6.code_9D73 (code) $9D73-$9D7C, 10 bytes
L6_9D73:
        jsr     L7_C0FF
        clc
        adc     #$02
        and     #$0C
        sta     $15

; ---- bank6.code_9D7D (code) $9D7D-$9D85, 9 bytes
        adc     #$08
        and     #$0C
        cmp     $0668,X
        bne     L6_9D8D

; ---- bank6.code_9D86 (code) $9D86-$9D8C, 7 bytes
        adc     $15
        lsr     A
        and     #$0C
        sta     $15

; ---- bank6.code_9D8D (code) $9D8D-$9D91, 5 bytes
L6_9D8D:
        lda     $15
        sta     $0668,X

; ---- bank6.code_9D92 (code) $9D92-$9D94, 3 bytes
        jsr     L7_C102

; ---- bank6.code_9D95 (code) $9D95-$9D9B, 7 bytes
L6_9D95:
        lda     $0500,X
        cmp     #$F3
        bne     L6_9DA4

; ---- bank6.code_9D9C (code) $9D9C-$9D9D, 2 bytes
        lda     #$03

; ---- bank6.code_9D9E (code) $9D9E-$9DA0, 3 bytes
        jsr     L6_9B09

; ---- bank6.code_9DA1 (code) $9DA1-$9DA3, 3 bytes
        jmp     L6_9DB1

; ---- bank6.code_9DA4 (code) $9DA4-$9DAA, 7 bytes
L6_9DA4:
        lda     #$20
        ldy     #$02
        jsr     L7_C0A5

; ---- bank6.code_9DAB (code) $9DAB-$9DB0, 6 bytes
        lda     $9DF2,Y
        sta     $0548,X

; ---- bank6.code_9DB1 (code) $9DB1-$9DB3, 3 bytes
L6_9DB1:
        jsr     L6_826D

; ---- bank6.code_9DB4 (code) $9DB4-$9DB8, 5 bytes
        ldy     $6C
        lda     $8425,Y

; ---- bank6.code_9DB9 (code) $9DB9-$9DBA, 2 bytes
        beq     L6_9DE9

; ---- bank6.code_9DBB (code) $9DBB-$9DC1, 7 bytes
        lda     $07A0,X
        cmp     #$04
        bcs     L6_9DE9

; ---- bank6.code_9DC2 (code) $9DC2-$9DCB, 10 bytes
        jsr     L7_C0EA
        and     #$3F
        adc     #$08
        sta     $07A0,X

; ---- bank6.code_9DCC (code) $9DCC-$9DD6, 11 bytes
        and     #$08
        sta     $15
        lda     $0668,X
        adc     $15
        sbc     #$03

; ---- bank6.code_9DD7 (code) $9DD7-$9DDB, 5 bytes
        and     #$0C
        sta     $0668,X

; ---- bank6.code_9DDC (code) $9DDC-$9DDE, 3 bytes
        jsr     L7_C102

; ---- bank6.code_9DDF (code) $9DDF-$9DE8, 10 bytes
        lda     $0500,X
        cmp     #$9F
        bne     L6_9DE9
        lsr     $07A0,X

; ---- bank6.code_9DE9 (code) $9DE9-$9DEB, 3 bytes
L6_9DE9:
        jsr     L7_C090

; ---- bank6.code_9DEC (code) $9DEC-$9DEE, 3 bytes
        jsr     L7_C0C6

; ---- bank6.code_9DEF (code) $9DEF-$9DF1, 3 bytes
        jmp     L7_C0D8

; ---- bank6.tbl_9DF2 (data) $9DF2-$9DF3, 2 bytes
; Types $1D-$1F metasprite by phase
        .byte   $1F,$20

; ---- bank6.tbl_9DF4 (data) $9DF4-$9DF6, 3 bytes
; Types $1D-$1F palette
        .byte   $03,$02,$00

; ---- bank6.tbl_9DF7 (data) $9DF7-$9DF9, 3 bytes
; Types $1D-$1F speed class
        .byte   $01,$02,$03

; ---- bank6.code_9DFA (code) $9DFA-$9DFE, 5 bytes
L6_9DFA:
        lda     $0500,X
        bmi     L6_9E5C

; ---- bank6.code_9DFF (code) $9DFF-$9E01, 3 bytes
        jsr     L7_C0A8

; ---- bank6.code_9E02 (code) $9E02-$9E04, 3 bytes
        jsr     L7_C162

; ---- bank6.code_9E05 (code) $9E05-$9E07, 3 bytes
        jsr     L7_C0F0

; ---- bank6.code_9E08 (code) $9E08-$9E0C, 5 bytes
        lda     #$01
        sta     $0560,X

; ---- bank6.code_9E0D (code) $9E0D-$9E11, 5 bytes
        lda     #$03
        sta     $05D8,X

; ---- bank6.code_9E12 (code) $9E12-$9E16, 5 bytes
        lda     #$00
        sta     $0668,X

; ---- bank6.code_9E17 (code) $9E17-$9E1B, 5 bytes
        lda     #$19
        sta     $0548,X

; ---- bank6.code_9E1C (code) $9E1C-$9E20, 5 bytes
        lda     $0530,X
        ldy     #$01

; ---- bank6.code_9E21 (code) $9E21-$9E25, 5 bytes
        cmp     $0530
        bcc     L6_9E28

; ---- bank6.code_9E26 (code) $9E26-$9E27, 2 bytes
        ldy     #$FF

; ---- bank6.code_9E28 (code) $9E28-$9E2B, 4 bytes
L6_9E28:
        tya
        sta     $0608,X

; ---- bank6.code_9E2C (code) $9E2C-$9E2E, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_9E2F (code) $9E2F-$9E35, 7 bytes
        lda     $0500,X
        cmp     #$9C
        beq     L6_9E48

; ---- bank6.code_9E36 (code) $9E36-$9E3B, 6 bytes
        lda     $50
        cmp     #$09
        bcc     L6_9E5C

; ---- bank6.code_9E3C (code) $9E3C-$9E40, 5 bytes
        lda     #$00
        sta     $0560,X

; ---- bank6.code_9E41 (code) $9E41-$9E47, 7 bytes
        lda     #$FF
        sta     $0590,X
        bne     L6_9E5C

; ---- bank6.code_9E48 (code) $9E48-$9E4C, 5 bytes
L6_9E48:
        lda     #$04
        sta     $05D8,X

; ---- bank6.code_9E4D (code) $9E4D-$9E51, 5 bytes
        lda     #$37
        sta     $0548,X

; ---- bank6.code_9E52 (code) $9E52-$9E56, 5 bytes
        lda     #$03
        sta     $0560,X

; ---- bank6.code_9E57 (code) $9E57-$9E5B, 5 bytes
        lda     #$02
        sta     $0788,X

; ---- bank6.code_9E5C (code) $9E5C-$9E62, 7 bytes
L6_9E5C:
        lda     $0500,X
        cmp     #$9C
        bne     L6_9E66

; ---- bank6.code_9E63 (code) $9E63-$9E65, 3 bytes
        jmp     L6_9E8A

; ---- bank6.code_9E66 (code) $9E66-$9E69, 4 bytes
L6_9E66:
        lda     #$40
        ldy     #$04

; ---- bank6.code_9E6A (code) $9E6A-$9E6C, 3 bytes
        jsr     L7_C0A5

; ---- bank6.code_9E6D (code) $9E6D-$9E71, 5 bytes
        lda     $9E82,Y
        sta     $15

; ---- bank6.code_9E72 (code) $9E72-$9E76, 5 bytes
        lda     $9E86,Y
        sta     $14

; ---- bank6.code_9E77 (code) $9E77-$9E79, 3 bytes
        jsr     L6_A1DB

; ---- bank6.code_9E7A (code) $9E7A-$9E7B, 2 bytes
        lda     #$07

; ---- bank6.code_9E7C (code) $9E7C-$9E7E, 3 bytes
        jsr     L7_C09C

; ---- bank6.code_9E7F (code) $9E7F-$9E81, 3 bytes
        jmp     L6_9F4F

; ---- bank6.tbl_9E82 (data) $9E82-$9E85, 4 bytes
; Type $1A tile offset by phase
        .byte   $00,$04,$08,$04

; ---- bank6.tbl_9E86 (data) $9E86-$9E89, 4 bytes
; Type $1A flip bits by phase
        .byte   $00,$00,$00,$80

; ---- bank6.code_9E8A (code) $9E8A-$9E8C, 3 bytes
L6_9E8A:
        lda     $0530,X

; ---- bank6.code_9E8D (code) $9E8D-$9E8F, 3 bytes
        sta     $0680,X

; ---- bank6.code_9E90 (code) $9E90-$9E91, 2 bytes
        lda     #$08

; ---- bank6.code_9E92 (code) $9E92-$9E94, 3 bytes
        jsr     L7_C09F

; ---- bank6.code_9E95 (code) $9E95-$9E97, 3 bytes
        jmp     L6_9F03

; ---- bank6.code_9E98 (code) $9E98-$9E9C, 5 bytes
L6_9E98:
        lda     $0500,X
        bmi     L6_9F03

; ---- bank6.code_9E9D (code) $9E9D-$9E9F, 3 bytes
        jsr     L7_C0A8

; ---- bank6.code_9EA0 (code) $9EA0-$9EA4, 5 bytes
        lda     #$37
        sta     $0548,X

; ---- bank6.code_9EA5 (code) $9EA5-$9EA9, 5 bytes
        lda     $0728,X
        bne     L6_9EF1

; ---- bank6.code_9EAA (code) $9EAA-$9EAE, 5 bytes
        lda     #$74
        sta     $0530,X

; ---- bank6.code_9EAF (code) $9EAF-$9EB3, 5 bytes
        lda     #$20
        sta     $0518,X

; ---- bank6.code_9EB4 (code) $9EB4-$9EB8, 5 bytes
        lda     #$81
        sta     $0560,X

; ---- bank6.code_9EB9 (code) $9EB9-$9EBD, 5 bytes
        lda     #$00
        sta     $0788,X

; ---- bank6.code_9EBE (code) $9EBE-$9EC2, 5 bytes
        lda     #$81
        sta     $0698,X

; ---- bank6.code_9EC3 (code) $9EC3-$9EC4, 2 bytes
        ldy     $4B

; ---- bank6.code_9EC5 (code) $9EC5-$9ECD, 9 bytes
        lda     $9EDE,Y
        sta     $07B8,X
        sta     $07A0,X

; ---- bank6.code_9ECE (code) $9ECE-$9ED3, 6 bytes
        lda     $9EE5,Y
        sta     $07D0,X

; ---- bank6.code_9ED4 (code) $9ED4-$9ED8, 5 bytes
        lda     #$00
        sta     $0680,X

; ---- bank6.code_9ED9 (code) $9ED9-$9EDB, 3 bytes
        jsr     L7_C102

; ---- bank6.code_9EDC (code) $9EDC-$9EDE, 3 bytes
        jmp     L6_9F03

; ---- bank6.tbl_9EDF (data) $9EDF-$9EE5, 7 bytes
; Ring-maker tick length by shield level
        .byte   $04,$05,$06,$07,$08,$08,$08

; ---- bank6.tbl_9EE6 (data) $9EE6-$9EEC, 7 bytes
; Ring-maker orb mask by shield level
        .byte   $00,$03,$01,$01,$03,$01,$00

; ---- bank6.tbl_9EED (data) $9EED-$9EF0, 4 bytes
; Orb speed class by attack level
        .byte   $03,$04,$05,$06

; ---- bank6.code_9EF1 (code) $9EF1-$9EF5, 5 bytes
L6_9EF1:
        lda     #$02
        sta     $0560,X

; ---- bank6.code_9EF6 (code) $9EF6-$9EF7, 2 bytes
        ldy     $4A

; ---- bank6.code_9EF8 (code) $9EF8-$9EFD, 6 bytes
        lda     $9EEC,Y
        sta     $0698,X

; ---- bank6.code_9EFE (code) $9EFE-$9F02, 5 bytes
        lda     #$01
        sta     $0788,X

; ---- bank6.code_9F03 (code) $9F03-$9F09, 7 bytes
L6_9F03:
        lda     #$30
        ldy     #$04
        jsr     L7_C0A5

; ---- bank6.code_9F0A (code) $9F0A-$9F0F, 6 bytes
        lda     $9FB4,Y
        jsr     L6_A1E7

; ---- bank6.code_9F10 (code) $9F10-$9F14, 5 bytes
        lda     $0788,X
        beq     L6_9F58

; ---- bank6.code_9F15 (code) $9F15-$9F18, 4 bytes
        cmp     #$02
        beq     L6_9F4F

; ---- bank6.code_9F19 (code) $9F19-$9F1C, 4 bytes
        lda     $0668,X
        tay

; ---- bank6.code_9F1D (code) $9F1D-$9F23, 7 bytes
        lda     $0500,Y
        cmp     #$9B
        bne     L6_9F3C

; ---- bank6.code_9F24 (code) $9F24-$9F28, 5 bytes
        lda     $0788,Y
        bne     L6_9F3C

; ---- bank6.code_9F29 (code) $9F29-$9F38, 16 bytes
        lda     $0680,X
        and     #$F0
        sta     $10
        lda     $0680,Y
        and     #$F0
        cmp     $10
        bne     L6_9F3C

; ---- bank6.code_9F39 (code) $9F39-$9F3B, 3 bytes
        jmp     L7_C090

; ---- bank6.code_9F3C (code) $9F3C-$9F3E, 3 bytes
L6_9F3C:
        jsr     L7_C0FC

; ---- bank6.code_9F3F (code) $9F3F-$9F43, 5 bytes
        lda     #$01
        sta     $0590,X

; ---- bank6.code_9F44 (code) $9F44-$9F46, 3 bytes
        jsr     L7_C162

; ---- bank6.code_9F47 (code) $9F47-$9F4B, 5 bytes
        lda     #$00
        sta     $0560,X

; ---- bank6.code_9F4C (code) $9F4C-$9F4E, 3 bytes
        inc     $0788,X

; ---- bank6.code_9F4F (code) $9F4F-$9F51, 3 bytes
L6_9F4F:
        jsr     L7_C08D

; ---- bank6.code_9F52 (code) $9F52-$9F54, 3 bytes
        jsr     L7_C0C6

; ---- bank6.code_9F55 (code) $9F55-$9F57, 3 bytes
        jmp     L7_C0D2

; ---- bank6.code_9F58 (code) $9F58-$9F5A, 3 bytes
L6_9F58:
        dec     $07A0,X

; ---- bank6.code_9F5B (code) $9F5B-$9F5C, 2 bytes
        beq     L6_9F66

; ---- bank6.code_9F5D (code) $9F5D-$9F5F, 3 bytes
        jsr     L7_C08D

; ---- bank6.code_9F60 (code) $9F60-$9F62, 3 bytes
        jsr     L7_C0CF

; ---- bank6.code_9F63 (code) $9F63-$9F65, 3 bytes
        jmp     L7_C0D2

; ---- bank6.code_9F66 (code) $9F66-$9F6B, 6 bytes
L6_9F66:
        lda     $07B8,X
        sta     $07A0,X

; ---- bank6.code_9F6C (code) $9F6C-$9F6E, 3 bytes
        inc     $0680,X

; ---- bank6.code_9F6F (code) $9F6F-$9F75, 7 bytes
        lda     $0680,X
        and     #$0F
        bne     L6_9F80

; ---- bank6.code_9F76 (code) $9F76-$9F7B, 6 bytes
        ldy     $51
        cpy     #$15
        beq     L6_9F80

; ---- bank6.code_9F7C (code) $9F7C-$9F7F, 4 bytes
        txa
        tay
        bpl     L6_9F93

; ---- bank6.code_9F80 (code) $9F80-$9F82, 3 bytes
L6_9F80:
        jsr     L7_C102

; ---- bank6.code_9F83 (code) $9F83-$9F85, 3 bytes
        jsr     L7_C08D

; ---- bank6.code_9F86 (code) $9F86-$9F8D, 8 bytes
        lda     $0680,X
        and     $07D0,X
        bne     L6_9FB3

; ---- bank6.code_9F8E (code) $9F8E-$9F92, 5 bytes
        jsr     L7_C108
        bcs     L6_9FB3

; ---- bank6.code_9F93 (code) $9F93-$9FB3, 33 bytes
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

; ---- bank6.tbl_9FB4 (data) $9FB4-$9FB7, 4 bytes
; Orb tile offset by phase
        .byte   $00,$02,$04,$06

; ---- bank6.code_9FB8 (code) $9FB8-$9FBC, 5 bytes
L6_9FB8:
        lda     $0500,X
        bmi     L6_9FD5

; ---- bank6.code_9FBD (code) $9FBD-$9FBF, 3 bytes
        jsr     L7_C0A8

; ---- bank6.code_9FC0 (code) $9FC0-$9FC2, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_9FC3 (code) $9FC3-$9FC5, 3 bytes
        jsr     L7_C0F0

; ---- bank6.code_9FC6 (code) $9FC6-$9FCC, 7 bytes
        lda     $0530,X
        and     #$3F
        adc     #$28

; ---- bank6.code_9FCD (code) $9FCD-$9FCF, 3 bytes
        sta     $05C0,X

; ---- bank6.code_9FD0 (code) $9FD0-$9FD4, 5 bytes
        lda     #$02
        sta     $0560,X

; ---- bank6.code_9FD5 (code) $9FD5-$9FD8, 4 bytes
L6_9FD5:
        lda     #$30
        ldy     #$04

; ---- bank6.code_9FD9 (code) $9FD9-$9FDB, 3 bytes
        jsr     L7_C0A5

; ---- bank6.code_9FDC (code) $9FDC-$9FE0, 5 bytes
        lda     $9FF3,Y
        sta     $15

; ---- bank6.code_9FE1 (code) $9FE1-$9FE5, 5 bytes
        lda     $9FF7,Y
        sta     $14

; ---- bank6.code_9FE6 (code) $9FE6-$9FEB, 6 bytes
        lda     $9FEF,Y
        jsr     L6_A1D8

; ---- bank6.code_9FEC (code) $9FEC-$9FEE, 3 bytes
        jmp     L6_9F4F

; ---- bank6.tbl_9FEF (data) $9FEF-$9FF2, 4 bytes
; Type $20 metasprite by phase
        .byte   $19,$79,$19,$79

; ---- bank6.tbl_9FF3 (data) $9FF3-$9FF6, 4 bytes
; Type $20 tile offset by phase
        .byte   $00,$04,$00,$06

; ---- bank6.tbl_9FF7 (data) $9FF7-$9FFA, 4 bytes
; Type $20 flip bits by phase
        .byte   $00,$00,$40,$00

; ---- bank6.code_9FFB (code) $9FFB-$9FFF, 5 bytes
L6_9FFB:
        lda     $0500,X
        bmi     L6_A019

; ---- bank6.code_A000 (code) $A000-$A002, 3 bytes
        jsr     L7_C0A8

; ---- bank6.code_A003 (code) $A003-$A005, 3 bytes
        jsr     L7_C162

; ---- bank6.code_A006 (code) $A006-$A008, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_A009 (code) $A009-$A00B, 3 bytes
        jsr     L7_C0F0

; ---- bank6.code_A00C (code) $A00C-$A010, 5 bytes
        lda     #$41
        sta     $0698,X

; ---- bank6.code_A011 (code) $A011-$A013, 3 bytes
        jsr     L7_C0FC

; ---- bank6.code_A014 (code) $A014-$A018, 5 bytes
        lda     #$00
        sta     $0560,X

; ---- bank6.code_A019 (code) $A019-$A01B, 3 bytes
L6_A019:
        jsr     L6_A01F

; ---- bank6.code_A01C (code) $A01C-$A01E, 3 bytes
        jmp     L6_9F4F

; ---- bank6.code_A01F (code) $A01F-$A022, 4 bytes
L6_A01F:
        lda     #$20
        ldy     #$04

; ---- bank6.code_A023 (code) $A023-$A025, 3 bytes
        jsr     L7_C0A5

; ---- bank6.code_A026 (code) $A026-$A02D, 8 bytes
        lda     $A09E,Y
        sta     $15
        lda     $A0A2,Y

; ---- bank6.code_A02E (code) $A02E-$A035, 8 bytes
        sta     $14
        lda     $A09A,Y
        jmp     L6_A1D8

; ---- bank6.code_A036 (code) $A036-$A03A, 5 bytes
L6_A036:
        lda     $0500,X
        bmi     L6_A06E

; ---- bank6.code_A03B (code) $A03B-$A03D, 3 bytes
        jsr     L7_C0A8

; ---- bank6.code_A03E (code) $A03E-$A040, 3 bytes
        jsr     L7_C162

; ---- bank6.code_A041 (code) $A041-$A043, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_A044 (code) $A044-$A048, 5 bytes
        lda     #$40
        sta     $0668,X

; ---- bank6.code_A049 (code) $A049-$A04A, 2 bytes
        ldy     #$00

; ---- bank6.code_A04B (code) $A04B-$A04D, 3 bytes
        jsr     L6_AD9A

; ---- bank6.code_A04E (code) $A04E-$A04F, 2 bytes
        beq     L6_A052

; ---- bank6.code_A050 (code) $A050-$A051, 2 bytes
        ldy     #$04

; ---- bank6.code_A052 (code) $A052-$A054, 3 bytes
L6_A052:
        lda     $A092,Y

; ---- bank6.code_A055 (code) $A055-$A057, 3 bytes
        sta     $0530,X

; ---- bank6.code_A058 (code) $A058-$A05D, 6 bytes
        lda     $A093,Y
        sta     $0608,X

; ---- bank6.code_A05E (code) $A05E-$A063, 6 bytes
        lda     $A094,Y
        sta     $0680,X

; ---- bank6.code_A064 (code) $A064-$A068, 5 bytes
        lda     #$02
        sta     $0560,X

; ---- bank6.code_A069 (code) $A069-$A06D, 5 bytes
        lda     #$14
        sta     $07A0,X

; ---- bank6.code_A06E (code) $A06E-$A06F, 2 bytes
L6_A06E:
        lda     #$08

; ---- bank6.code_A070 (code) $A070-$A072, 3 bytes
        jsr     L7_C09C

; ---- bank6.code_A073 (code) $A073-$A074, 2 bytes
        lda     #$0E

; ---- bank6.code_A075 (code) $A075-$A077, 3 bytes
        jsr     L7_C09F

; ---- bank6.code_A078 (code) $A078-$A07A, 3 bytes
        jsr     L6_A01F

; ---- bank6.code_A07B (code) $A07B-$A07D, 3 bytes
        dec     $07A0,X

; ---- bank6.code_A07E (code) $A07E-$A07F, 2 bytes
        bne     L6_A08F

; ---- bank6.code_A080 (code) $A080-$A084, 5 bytes
        lda     #$1E
        sta     $07A0,X

; ---- bank6.code_A085 (code) $A085-$A087, 3 bytes
        jsr     L7_C108

; ---- bank6.code_A088 (code) $A088-$A089, 2 bytes
        bcs     L6_A08F

; ---- bank6.code_A08A (code) $A08A-$A08E, 5 bytes
        lda     #$0B
        jsr     L7_C105

; ---- bank6.code_A08F (code) $A08F-$A091, 3 bytes
L6_A08F:
        jmp     L6_9F4F

; ---- bank6.tbl_A092 (data) $A092-$A099, 8 bytes
; Type $21 start: 2 x [x][x speed][x target][unused]
        .byte   $60,$FD,$FF,$00,$A0,$03,$00,$00

; ---- bank6.tbl_A09A (data) $A09A-$A09D, 4 bytes
; Types $62 and $21 metasprite by phase
        .byte   $19,$37,$19,$1A

; ---- bank6.tbl_A09E (data) $A09E-$A0A1, 4 bytes
; Types $62 and $21 tile offset by phase
        .byte   $00,$04,$00,$06

; ---- bank6.tbl_A0A2 (data) $A0A2-$A0A5, 4 bytes
; Types $62 and $21 flip bits by phase
        .byte   $00,$00,$40,$00

; ---- bank6.code_A0A6 (code) $A0A6-$A0AA, 5 bytes
L6_A0A6:
        lda     $0500,X
        bmi     L6_A0B8

; ---- bank6.code_A0AB (code) $A0AB-$A0B7, 13 bytes
        ora     #$80
        sta     $0500,X
        lda     #$4E
        sta     $0578,X
        jsr     L7_C141

; ---- bank6.code_A0B8 (code) $A0B8-$A0C5, 14 bytes
L6_A0B8:
        jsr     L7_C129
        bcc     L6_A0C0
        jmp     L7_C048
L6_A0C0:
        jsr     L7_C0C0
        jmp     L7_C0D5

; ---- bank6.code_A0C6 (code) $A0C6-$A0CA, 5 bytes
L6_A0C6:
        lda     $0500,X
        bmi     L6_A113

; ---- bank6.code_A0CB (code) $A0CB-$A0D3, 9 bytes
        ldy     $07A0,X
        lda     $A21F,Y
        sta     $07B8,X

; ---- bank6.code_A0D4 (code) $A0D4-$A0D6, 3 bytes
        jsr     L7_C0AB

; ---- bank6.code_A0D7 (code) $A0D7-$A0DF, 9 bytes
        ldy     $07A0,X
        lda     $A1EF,Y
        sta     $0560,X

; ---- bank6.code_A0E0 (code) $A0E0-$A0EB, 12 bytes
        lda     $A1F7,Y
        sta     $0698,X
        lda     $A1FF,Y
        sta     $06B0,X

; ---- bank6.code_A0EC (code) $A0EC-$A0F7, 12 bytes
        lda     $A207,Y
        sta     $07D0,X
        lda     $A227,Y
        sta     $0668,X

; ---- bank6.code_A0F8 (code) $A0F8-$A103, 12 bytes
        lda     $A22F,Y
        sta     $0680,X
        lda     $A20F,Y
        sta     $0590,X

; ---- bank6.code_A104 (code) $A104-$A109, 6 bytes
        lda     $A217,Y
        sta     $05A8,X

; ---- bank6.code_A10A (code) $A10A-$A112, 9 bytes
        jsr     L7_C0A2
        lda     $0788,X
        jmp     L6_A133

; ---- bank6.code_A113 (code) $A113-$A117, 5 bytes
L6_A113:
        dec     $07A0,X
        bne     L6_A174

; ---- bank6.code_A118 (code) $A118-$A132, 27 bytes
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

; ---- bank6.code_A133 (code) $A133-$A13A, 8 bytes
L6_A133:
        and     #$0F
        sta     $0788,X
        jsr     L7_C102

; ---- bank6.code_A13B (code) $A13B-$A140, 6 bytes
L6_A13B:
        lda     $06B0,X
        sta     $07A0,X

; ---- bank6.code_A141 (code) $A141-$A147, 7 bytes
        lda     $0680,X
        and     #$7F
        bne     L6_A185

; ---- bank6.code_A148 (code) $A148-$A15D, 22 bytes
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

; ---- bank6.code_A15E (code) $A15E-$A170, 19 bytes
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

; ---- bank6.code_A171 (code) $A171-$A173, 3 bytes
L6_A171:
        jsr     L6_A1D8

; ---- bank6.code_A174 (code) $A174-$A181, 14 bytes
L6_A174:
        lda     $0680,X
        cmp     #$03
        bne     L6_A182
        lda     $41
        and     #$04
        jsr     L6_A1E7

; ---- bank6.code_A182 (code) $A182-$A184, 3 bytes
L6_A182:
        jmp     L6_9F4F

; ---- bank6.code_A185 (code) $A185-$A1A6, 34 bytes
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

; ---- bank6.code_A1A7 (code) $A1A7-$A1B5, 15 bytes
L6_A1A7:
        cmp     #$02
        bne     L6_A1B6
        lda     $0788,X
        lsr     A
        tay
        jsr     L6_A1CB
        jmp     L6_A174

; ---- bank6.code_A1B6 (code) $A1B6-$A1CA, 21 bytes
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

; ---- bank6.code_A1CB (code) $A1CB-$A1D7, 13 bytes
L6_A1CB:
        lda     $A24F,Y
        sta     $15
        lda     $A257,Y
        sta     $14
        lda     $A25F,Y

; ---- bank6.code_A1D8 (code) $A1D8-$A1E4, 13 bytes
L6_A1D8:
        sta     $0548,X
L6_A1DB:
        lda     $0560,X
        and     #$03
        ora     $14
        sta     $0560,X

; ---- bank6.code_A1E5 (code) $A1E5-$A1EE, 10 bytes
        lda     $15
L6_A1E7:
        clc
        adc     $07E8,X
        sta     $06C8,X
        rts

; ---- bank6.tbl_A1EF (data) $A1EF-$A1F6, 8 bytes
; Bullet palette by kind
        .byte   $01,$01,$03,$02,$02,$02,$03,$01

; ---- bank6.tbl_A1F7 (data) $A1F7-$A1FE, 8 bytes
; Bullet speed class by kind
        .byte   $03,$41,$06,$05,$03,$81,$06,$41

; ---- bank6.tbl_A1FF (data) $A1FF-$A206, 8 bytes
; Bullet re-aim interval by kind
        .byte   $10,$0A,$08,$08,$10,$05,$09,$10

; ---- bank6.tbl_A207 (data) $A207-$A20E, 8 bytes
; Bullet value for `$07D0` by kind
        .byte   $03,$05,$08,$07,$08,$06,$06,$06

; ---- bank6.tbl_A20F (data) $A20F-$A216, 8 bytes
; Bullet hit points by kind
        .byte   $01,$02,$18,$0C,$10,$01,$01,$01

; ---- bank6.tbl_A217 (data) $A217-$A21E, 8 bytes
; Bullet attack by kind
        .byte   $04,$08,$30,$40,$18,$04,$04,$06

; ---- bank6.tbl_A21F (data) $A21F-$A226, 8 bytes
; Bullet art block by kind
        .byte   $39,$35,$36,$02,$04,$35,$39,$2F

; ---- bank6.tbl_A227 (data) $A227-$A22E, 8 bytes
; Bullet turn step by kind
        .byte   $01,$01,$01,$02,$02,$01,$01,$04

; ---- bank6.tbl_A22F (data) $A22F-$A236, 8 bytes
; Bullet picture mode by kind
        .byte   $80,$80,$00,$81,$02,$80,$80,$03

; ---- bank6.tbl_A237 (data) $A237-$A23E, 8 bytes
; Bullet tile offset by direction (mode 0)
        .byte   $00,$04,$08,$0C,$10,$0C,$08,$04

; ---- bank6.tbl_A23F (data) $A23F-$A242, 4 bytes
; Bullet flips by quadrant (mode 0)
        .byte   $80,$C0,$40,$00

; ---- bank6.tbl_A243 (data) $A243-$A246, 4 bytes
; Bullet tile offset by direction (mode 1)
        .byte   $00,$06,$04,$06

; ---- bank6.tbl_A247 (data) $A247-$A24E, 8 bytes
; Bullet flips by direction (mode 1)
        .byte   $40,$40,$00,$00,$80,$80,$C0,$C0

; ---- bank6.tbl_A24F (data) $A24F-$A256, 8 bytes
; Bullet tile offset by octant (mode 2)
        .byte   $00,$02,$00,$02,$00,$04,$04,$04

; ---- bank6.tbl_A257 (data) $A257-$A25E, 8 bytes
; Bullet flips by octant (mode 2)
        .byte   $40,$40,$00,$00,$00,$00,$00,$00

; ---- bank6.tbl_A25F (data) $A25F-$A266, 8 bytes
; Bullet metasprite by octant (mode 2)
        .byte   $4B,$19,$1A,$19,$4B,$7B,$7B,$7B

; ---- bank6.tbl_A267 (data) $A267-$A26A, 4 bytes
; Bullet flips by quadrant (mode 3 and others)
        .byte   $C0,$80,$00,$40

; ---- bank6.code_A26B (code) $A26B-$A26D, 3 bytes
L6_A26B:
        jmp     L7_C090

; ---- bank6.code_A26E (code) $A26E-$A272, 5 bytes
L6_A26E:
        ldy     $0500,X
        bmi     L6_A294

; ---- bank6.code_A273 (code) $A273-$A275, 3 bytes
        lda     $A2B0,Y

; ---- bank6.code_A276 (code) $A276-$A277, 2 bytes
        ldy     #$1A

; ---- bank6.code_A278 (code) $A278-$A27A, 3 bytes
        jsr     L6_A302

; ---- bank6.code_A27B (code) $A27B-$A27D, 3 bytes
        jsr     L7_C0A8

; ---- bank6.code_A27E (code) $A27E-$A280, 3 bytes
        jsr     L7_C0F3

; ---- bank6.code_A281 (code) $A281-$A283, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_A284 (code) $A284-$A288, 5 bytes
        ldy     $0500,X
        cpy     #$94

; ---- bank6.code_A289 (code) $A289-$A28A, 2 bytes
        bne     L6_A291

; ---- bank6.code_A28B (code) $A28B-$A28D, 3 bytes
        jsr     L6_A2D0

; ---- bank6.code_A28E (code) $A28E-$A290, 3 bytes
        jmp     L6_A294

; ---- bank6.code_A291 (code) $A291-$A293, 3 bytes
L6_A291:
        jsr     L6_A2E8

; ---- bank6.code_A294 (code) $A294-$A296, 3 bytes
L6_A294:
        jsr     L7_C009

; ---- bank6.code_A297 (code) $A297-$A298, 2 bytes
        lda     #$10

; ---- bank6.code_A299 (code) $A299-$A29D, 5 bytes
        ldy     $0500,X
        cpy     #$94

; ---- bank6.code_A29E (code) $A29E-$A29F, 2 bytes
        bne     L6_A2A6

; ---- bank6.code_A2A0 (code) $A2A0-$A2A2, 3 bytes
        jsr     L7_C09F

; ---- bank6.code_A2A3 (code) $A2A3-$A2A5, 3 bytes
        jmp     L6_A2A9

; ---- bank6.code_A2A6 (code) $A2A6-$A2A8, 3 bytes
L6_A2A6:
        jsr     L7_C09C

; ---- bank6.code_A2A9 (code) $A2A9-$A2AC, 4 bytes
L6_A2A9:
        lda     #$40
        ldy     #$05

; ---- bank6.code_A2AD (code) $A2AD-$A2AF, 3 bytes
        jsr     L7_C0A5

; ---- bank6.code_A2B0 (code) $A2B0-$A2B5, 6 bytes
        lda     $A2C6,Y
        sta     $0548,X

; ---- bank6.code_A2B6 (code) $A2B6-$A2C0, 11 bytes
        lda     $0560,X
        and     #$3F
        ora     $A2CB,Y
        sta     $0560,X

; ---- bank6.code_A2C1 (code) $A2C1-$A2C3, 3 bytes
        jmp     L6_A317

; ---- bank6.tbl_A2C4 (data) $A2C4-$A2C5, 2 bytes
; Types $14 / $15 palette
        .byte   $00,$02

; ---- bank6.tbl_A2C6 (data) $A2C6-$A2CA, 5 bytes
; Types $14 / $15 metasprite by phase
        .byte   $1A,$1B,$1C,$1C,$1B

; ---- bank6.tbl_A2CB (data) $A2CB-$A2CF, 5 bytes
; Types $14 / $15 flip bit by phase
        .byte   $00,$00,$00,$00,$40

; ---- bank6.code_A2D0 (code) $A2D0-$A2D8, 9 bytes
L6_A2D0:
        jsr     L7_C0EA
        and     #$1F
        adc     #$30
        sta     $10

; ---- bank6.code_A2D9 (code) $A2D9-$A2DD, 5 bytes
        lda     $0530,X
        bpl     L6_A2E2

; ---- bank6.code_A2DE (code) $A2DE-$A2E1, 4 bytes
        sbc     $10
        bcs     L6_A2E4

; ---- bank6.code_A2E2 (code) $A2E2-$A2E3, 2 bytes
L6_A2E2:
        adc     $10

; ---- bank6.code_A2E4 (code) $A2E4-$A2E7, 4 bytes
L6_A2E4:
        sta     $0680,X
        rts

; ---- bank6.code_A2E8 (code) $A2E8-$A2F0, 9 bytes
L6_A2E8:
        jsr     L7_C0EA
        and     #$1F
        adc     #$20
        sta     $10

; ---- bank6.code_A2F1 (code) $A2F1-$A2F7, 7 bytes
        lda     $0518,X
        cmp     #$60
        bcc     L6_A2FC

; ---- bank6.code_A2F8 (code) $A2F8-$A2FB, 4 bytes
        sbc     $10
        bcs     L6_A2FE

; ---- bank6.code_A2FC (code) $A2FC-$A2FD, 2 bytes
L6_A2FC:
        adc     $10

; ---- bank6.code_A2FE (code) $A2FE-$A301, 4 bytes
L6_A2FE:
        sta     $0668,X
        rts

; ---- bank6.code_A302 (code) $A302-$A30E, 13 bytes
L6_A302:
        sta     $0560,X
        tya
        sta     $0548,X
        lda     #$3C
        sta     $0788,X
        rts

; ---- bank6.code_A30F (code) $A30F-$A316, 8 bytes
        sta     $0560,X
        tya
        sta     $0548,X
        rts

; ---- bank6.code_A317 (code) $A317-$A319, 3 bytes
L6_A317:
        jsr     L7_C08D

; ---- bank6.code_A31A (code) $A31A-$A31B, 2 bytes
        bcc     L6_A31F

; ---- bank6.code_A31C (code) $A31C-$A31E, 3 bytes
        jmp     L6_9B17

; ---- bank6.code_A31F (code) $A31F-$A321, 3 bytes
L6_A31F:
        jsr     L7_C0C6

; ---- bank6.code_A322 (code) $A322-$A324, 3 bytes
        jmp     L7_C0D2

; ---- bank6.code_A325 (code) $A325-$A336, 18 bytes
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

; ---- bank6.code_A337 (code) $A337-$A348, 18 bytes
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

; ---- bank6.code_A349 (code) $A349-$A34D, 5 bytes
L6_A349:
        ldy     $0500,X
        bmi     L6_A373

; ---- bank6.code_A34E (code) $A34E-$A353, 6 bytes
        lda     $9D9F,Y
        sta     $0560,X

; ---- bank6.code_A354 (code) $A354-$A359, 6 bytes
        lda     $A385,Y
        sta     $07B8,X

; ---- bank6.code_A35A (code) $A35A-$A35F, 6 bytes
        lda     $A388,Y
        sta     $07D0,X

; ---- bank6.code_A360 (code) $A360-$A362, 3 bytes
        jsr     L7_C0A8

; ---- bank6.code_A363 (code) $A363-$A365, 3 bytes
        jsr     L7_C165

; ---- bank6.code_A366 (code) $A366-$A36A, 5 bytes
        lda     #$69
        sta     $0548,X

; ---- bank6.code_A36B (code) $A36B-$A36F, 5 bytes
        lda     #$00
        sta     $07A0,X

; ---- bank6.code_A370 (code) $A370-$A372, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_A373 (code) $A373-$A375, 3 bytes
L6_A373:
        jsr     L6_A3EA

; ---- bank6.code_A376 (code) $A376-$A37A, 5 bytes
        lda     #$07
        jsr     L6_9B09

; ---- bank6.code_A37B (code) $A37B-$A37D, 3 bytes
        jsr     L6_A337

; ---- bank6.code_A37E (code) $A37E-$A380, 3 bytes
        jsr     L7_C090

; ---- bank6.code_A381 (code) $A381-$A387, 7 bytes
        lda     $07A0,X
        cmp     #$02
        bne     L6_A3BE

; ---- bank6.code_A388 (code) $A388-$A38F, 8 bytes
        lda     $07B8,X
        ldy     #$0A
        jsr     L7_C0A5

; ---- bank6.code_A390 (code) $A390-$A396, 7 bytes
        lda     $A3E0,Y
        cmp     #$67
        bne     L6_A3BB

; ---- bank6.code_A397 (code) $A397-$A39D, 7 bytes
        lda     $41
        and     $07D0,X
        bne     L6_A3BB

; ---- bank6.code_A39E (code) $A39E-$A3A2, 5 bytes
        jsr     L7_C0FF
        sta     $15

; ---- bank6.code_A3A3 (code) $A3A3-$A3A7, 5 bytes
        jsr     L7_C108
        bcs     L6_A3BB

; ---- bank6.code_A3A8 (code) $A3A8-$A3AA, 3 bytes
        jsr     L6_AC9F

; ---- bank6.code_A3AB (code) $A3AB-$A3AD, 3 bytes
        jsr     L6_ACCA

; ---- bank6.code_A3AE (code) $A3AE-$A3B2, 5 bytes
        lda     #$E8
        jsr     L6_AECF

; ---- bank6.code_A3B3 (code) $A3B3-$A3BA, 8 bytes
        lda     $0530,Y
        sbc     #$08
        sta     $0530,Y

; ---- bank6.code_A3BB (code) $A3BB-$A3BD, 3 bytes
L6_A3BB:
        jsr     L6_A432

; ---- bank6.code_A3BE (code) $A3BE-$A3C3, 6 bytes
L6_A3BE:
        lda     $86
        and     #$03
        sta     $86

; ---- bank6.code_A3C4 (code) $A3C4-$A3CC, 9 bytes
        ldy     $0638,X
        lda     $A3E0,Y
        jsr     L7_C093

; ---- bank6.code_A3CD (code) $A3CD-$A3D3, 7 bytes
        lda     $07A0,X
        cmp     #$02
        bne     L6_A3FF

; ---- bank6.code_A3D4 (code) $A3D4-$A3D6, 3 bytes
        jsr     L7_C0C6

; ---- bank6.code_A3D7 (code) $A3D7-$A3D9, 3 bytes
        jmp     L7_C0D8

; ---- bank6.tbl_A3DA (data) $A3DA-$A3DC, 3 bytes
; Cannon animation step by type
        .byte   $04,$18,$30

; ---- bank6.tbl_A3DD (data) $A3DD-$A3DF, 3 bytes
; Cannon shot mask by type
        .byte   $0F,$03,$00

; ---- bank6.tbl_A3E0 (data) $A3E0-$A3E9, 10 bytes
; Cannon head picture by phase
        .byte   $68,$68,$67,$68,$68,$67,$68,$67,$68,$67

; ---- bank6.code_A3EA (code) $A3EA-$A3F6, 13 bytes
L6_A3EA:
        lda     $07A0,X
        bne     L6_A400
        jsr     L7_C0F3
        jsr     L6_9A53
        bne     L6_A42F

; ---- bank6.code_A3F7 (code) $A3F7-$A3FF, 9 bytes
        lda     #$78
        sta     $0788,X
        inc     $07A0,X
L6_A3FF:
        rts

; ---- bank6.code_A400 (code) $A400-$A40C, 13 bytes
L6_A400:
        cmp     #$01
        beq     L6_A408
        cmp     #$03
        bne     L6_A41E
L6_A408:
        dec     $0788,X
        beq     L6_A416

; ---- bank6.code_A40D (code) $A40D-$A415, 9 bytes
        lda     $0788,X
        and     #$01
        beq     L6_A3FF
        bne     L6_A42F

; ---- bank6.code_A416 (code) $A416-$A41D, 8 bytes
L6_A416:
        inc     $07A0,X
        lda     #$78
        sta     $0788,X

; ---- bank6.code_A41E (code) $A41E-$A424, 7 bytes
L6_A41E:
        lda     $07A0,X
        cmp     #$02
        beq     L6_A3FF

; ---- bank6.code_A425 (code) $A425-$A42E, 10 bytes
        dec     $0788,X
        bne     L6_A42F
        lda     #$00
        sta     $07A0,X

; ---- bank6.code_A42F (code) $A42F-$A431, 3 bytes
L6_A42F:
        pla
        pla
        rts

; ---- bank6.code_A432 (code) $A432-$A445, 20 bytes
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

; ---- bank6.code_A446 (code) $A446-$A44A, 5 bytes
L6_A446:
        lda     $0500,X
        bmi     L6_A46E

; ---- bank6.code_A44B (code) $A44B-$A44D, 3 bytes
        jsr     L7_C0A8

; ---- bank6.code_A44E (code) $A44E-$A450, 3 bytes
        jsr     L6_9B0F

; ---- bank6.code_A451 (code) $A451-$A456, 6 bytes
        lda     $9ADB,Y
        sta     $0560,X

; ---- bank6.code_A457 (code) $A457-$A45C, 6 bytes
        lda     $A4FB,Y
        sta     $07D0,X

; ---- bank6.code_A45D (code) $A45D-$A462, 6 bytes
        lda     $A501,Y
        sta     $0590,X

; ---- bank6.code_A463 (code) $A463-$A465, 3 bytes
        jsr     L7_C165

; ---- bank6.code_A466 (code) $A466-$A46A, 5 bytes
        lda     #$00
        sta     $07A0,X

; ---- bank6.code_A46B (code) $A46B-$A46D, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_A46E (code) $A46E-$A470, 3 bytes
L6_A46E:
        jsr     L6_A3EA

; ---- bank6.code_A471 (code) $A471-$A472, 2 bytes
        ldy     #$23

; ---- bank6.code_A473 (code) $A473-$A479, 7 bytes
        lda     $07A0,X
        cmp     #$02
        bne     L6_A485

; ---- bank6.code_A47A (code) $A47A-$A47E, 5 bytes
        lda     #$40
        jsr     L7_C0A5

; ---- bank6.code_A47F (code) $A47F-$A480, 2 bytes
        bcs     L6_A4B6

; ---- bank6.code_A481 (code) $A481-$A484, 4 bytes
        cpy     #$0A
        bcs     L6_A497

; ---- bank6.code_A485 (code) $A485-$A48F, 11 bytes
L6_A485:
        tya
        and     #$01
        asl     A
        asl     A
        adc     $07E8,X
        sta     $06C8,X

; ---- bank6.code_A490 (code) $A490-$A494, 5 bytes
        lda     #$34
        sta     $0548,X

; ---- bank6.code_A495 (code) $A495-$A496, 2 bytes
        bcc     L6_A4BE

; ---- bank6.code_A497 (code) $A497-$A49A, 4 bytes
L6_A497:
        cpy     #$1E
        bcs     L6_A485

; ---- bank6.code_A49B (code) $A49B-$A4A0, 6 bytes
        lda     $07E8,X
        sta     $06C8,X

; ---- bank6.code_A4A1 (code) $A4A1-$A4A9, 9 bytes
        cpy     #$0C
        bcs     L6_A4AA
        lda     $A4EE,Y
        bne     L6_A4B1

; ---- bank6.code_A4AA (code) $A4AA-$A4AD, 4 bytes
L6_A4AA:
        cpy     #$1C
        bcc     L6_A4BE

; ---- bank6.code_A4AE (code) $A4AE-$A4B0, 3 bytes
        lda     $A4DD,Y

; ---- bank6.code_A4B1 (code) $A4B1-$A4B5, 5 bytes
L6_A4B1:
        sta     $0548,X
        bne     L6_A4BE

; ---- bank6.code_A4B6 (code) $A4B6-$A4BD, 8 bytes
L6_A4B6:
        lda     #$3C
        sta     $0788,X
        inc     $07A0,X

; ---- bank6.code_A4BE (code) $A4BE-$A4C0, 3 bytes
L6_A4BE:
        jsr     L7_C090

; ---- bank6.code_A4C1 (code) $A4C1-$A4C7, 7 bytes
        lda     $07A0,X
        cmp     #$03
        bne     L6_A4EA

; ---- bank6.code_A4C8 (code) $A4C8-$A4D2, 11 bytes
        lda     $0788,X
        ldy     $0500,X
        cmp     $07D0,X
        bcs     L6_A4EA

; ---- bank6.code_A4D3 (code) $A4D3-$A4D7, 5 bytes
        jsr     L6_9A53
        bne     L6_A4EA

; ---- bank6.code_A4D8 (code) $A4D8-$A4DC, 5 bytes
        jsr     L7_C108
        bcs     L6_A4EA

; ---- bank6.code_A4DD (code) $A4DD-$A4E1, 5 bytes
        lda     #$0E
        sta     $0728,Y

; ---- bank6.code_A4E2 (code) $A4E2-$A4E4, 3 bytes
        jsr     L7_C105

; ---- bank6.code_A4E5 (code) $A4E5-$A4E9, 5 bytes
        lda     #$08
        jsr     L6_AECF

; ---- bank6.code_A4EA (code) $A4EA-$A4F0, 7 bytes
L6_A4EA:
        lda     $07A0,X
        cmp     #$02
        beq     L6_A4F2

; ---- bank6.code_A4F1 (code) $A4F1-$A4F1, 1 bytes
        rts

; ---- bank6.code_A4F2 (code) $A4F2-$A4F4, 3 bytes
L6_A4F2:
        jsr     L7_C0C6

; ---- bank6.code_A4F5 (code) $A4F5-$A4F7, 3 bytes
        jmp     L7_C0D8

; ---- bank6.tbl_A4F8 (data) $A4F8-$A4FA, 3 bytes
; Nest picture by phase
        .byte   $35,$36,$35

; ---- bank6.tbl_A4FB (data) $A4FB-$A500, 6 bytes
; Nest hatching threshold by area tier
        .byte   $04,$06,$08,$0A,$10,$10

; ---- bank6.tbl_A501 (data) $A501-$A506, 6 bytes
; Nest hit points by area tier
        .byte   $04,$04,$07,$0A,$10,$14

; ---- bank6.code_A507 (code) $A507-$A50B, 5 bytes
L6_A507:
        ldy     $0500,X
        bmi     L6_A541

; ---- bank6.code_A50C (code) $A50C-$A511, 6 bytes
        lda     $A546,Y
        sta     $0560,X

; ---- bank6.code_A512 (code) $A512-$A517, 6 bytes
        lda     $A549,Y
        sta     $0698,X

; ---- bank6.code_A518 (code) $A518-$A51D, 6 bytes
        lda     $A54C,Y
        sta     $07A0,X

; ---- bank6.code_A51E (code) $A51E-$A523, 6 bytes
        lda     $A54F,Y
        sta     $07B8,X

; ---- bank6.code_A524 (code) $A524-$A526, 3 bytes
        jsr     L7_C0A8

; ---- bank6.code_A527 (code) $A527-$A529, 3 bytes
        jsr     L7_C165

; ---- bank6.code_A52A (code) $A52A-$A52C, 3 bytes
L6_A52A:
        jsr     L7_C0F3

; ---- bank6.code_A52D (code) $A52D-$A52F, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_A530 (code) $A530-$A534, 5 bytes
        lda     #$8C
        sta     $0548,X

; ---- bank6.code_A535 (code) $A535-$A539, 5 bytes
        lda     #$FF
        sta     $0668,X

; ---- bank6.code_A53A (code) $A53A-$A540, 7 bytes
        lda     #$78
        sta     $0788,X
        bne     L6_A551

; ---- bank6.code_A541 (code) $A541-$A543, 3 bytes
L6_A541:
        jsr     L7_C009

; ---- bank6.code_A544 (code) $A544-$A548, 5 bytes
        lda     $05D8,X
        bmi     L6_A563

; ---- bank6.code_A549 (code) $A549-$A550, 8 bytes
        lda     $0518,X
        cmp     $07A0,X
        bcc     L6_A563

; ---- bank6.code_A551 (code) $A551-$A553, 3 bytes
L6_A551:
        jsr     L7_C0FC

; ---- bank6.code_A554 (code) $A554-$A55C, 9 bytes
        lda     $05D8,X
        sec
        sbc     #$02
        sta     $05D8,X

; ---- bank6.code_A55D (code) $A55D-$A562, 6 bytes
        lda     $0518
        sta     $07A0,X

; ---- bank6.code_A563 (code) $A563-$A569, 7 bytes
L6_A563:
        lda     #$30
        ldy     #$04
        jsr     L7_C0A5

; ---- bank6.code_A56A (code) $A56A-$A574, 11 bytes
        lda     $0560,X
        and     #$03
        ora     $A5AC,Y
        sta     $0560,X

; ---- bank6.code_A575 (code) $A575-$A579, 5 bytes
        lda     #$18
        jsr     L7_C09C

; ---- bank6.code_A57A (code) $A57A-$A580, 7 bytes
        lda     $0500,X
        cmp     #$DC
        bne     L6_A58C

; ---- bank6.code_A581 (code) $A581-$A586, 6 bytes
        lda     $0530
        sta     $0680,X

; ---- bank6.code_A587 (code) $A587-$A58B, 5 bytes
        lda     #$10
        jsr     L7_C09F

; ---- bank6.code_A58C (code) $A58C-$A590, 5 bytes
L6_A58C:
        jsr     L7_C08D
        bcs     L6_A52A

; ---- bank6.code_A591 (code) $A591-$A595, 5 bytes
        lda     $0788,X
        beq     L6_A597

; ---- bank6.code_A596 (code) $A596-$A596, 1 bytes
        rts

; ---- bank6.code_A597 (code) $A597-$A599, 3 bytes
L6_A597:
        jsr     L7_C0C6

; ---- bank6.code_A59A (code) $A59A-$A59C, 3 bytes
        jsr     L6_A5B0

; ---- bank6.code_A59D (code) $A59D-$A59F, 3 bytes
        jmp     L7_C0D8

; ---- bank6.tbl_A5A0 (data) $A5A0-$A5A2, 3 bytes
; Types $5A-$5C palette
        .byte   $03,$02,$00

; ---- bank6.tbl_A5A3 (data) $A5A3-$A5A5, 3 bytes
; Types $5A-$5C speed class
        .byte   $03,$02,$02

; ---- bank6.tbl_A5A6 (data) $A5A6-$A5A8, 3 bytes
; Types $5A-$5C first landing level
        .byte   $01,$04,$02

; ---- bank6.tbl_A5A9 (data) $A5A9-$A5AB, 3 bytes
; Types $5A-$5C stored value
        .byte   $08,$50,$18

; ---- bank6.tbl_A5AC (data) $A5AC-$A5AF, 4 bytes
; Tumble flips by phase
        .byte   $00,$80,$C0,$40

; ---- bank6.code_A5B0 (code) $A5B0-$A5BB, 12 bytes
L6_A5B0:
        php
        bcc     L6_A5BA
        lda     $6E
        bne     L6_A5BA
        jsr     L7_C123
L6_A5BA:
        plp
        rts

; ---- bank6.code_A5BC (code) $A5BC-$A5C0, 5 bytes
L6_A5BC:
        lda     $0500,X
        bmi     L6_A5E3

; ---- bank6.code_A5C1 (code) $A5C1-$A5C6, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C165

; ---- bank6.code_A5C7 (code) $A5C7-$A5C9, 3 bytes
        jsr     L7_C0F3

; ---- bank6.code_A5CA (code) $A5CA-$A5CE, 5 bytes
        lda     #$8C
        sta     $0548,X

; ---- bank6.code_A5CF (code) $A5CF-$A5D3, 5 bytes
        lda     #$02
        sta     $0560,X

; ---- bank6.code_A5D4 (code) $A5D4-$A5D8, 5 bytes
        lda     #$78
        sta     $0788,X

; ---- bank6.code_A5D9 (code) $A5D9-$A5DD, 5 bytes
        lda     #$00
        sta     $07A0,X

; ---- bank6.code_A5DE (code) $A5DE-$A5E2, 5 bytes
        lda     #$3C
        sta     $07B8,X

; ---- bank6.code_A5E3 (code) $A5E3-$A5E5, 3 bytes
L6_A5E3:
        jsr     L7_C009

; ---- bank6.code_A5E6 (code) $A5E6-$A5EA, 5 bytes
        dec     $07B8,X
        bne     L6_A61E

; ---- bank6.code_A5EB (code) $A5EB-$A5EF, 5 bytes
        lda     #$5A
        sta     $07B8,X

; ---- bank6.code_A5F0 (code) $A5F0-$A5F7, 8 bytes
        lda     $0560,X
        eor     #$40
        sta     $0560,X

; ---- bank6.code_A5F8 (code) $A5F8-$A5FC, 5 bytes
        jsr     L7_C108
        bcs     L6_A616

; ---- bank6.code_A5FD (code) $A5FD-$A601, 5 bytes
        lda     #$5F
        jsr     L7_C105

; ---- bank6.code_A602 (code) $A602-$A606, 5 bytes
        lda     #$02
        sta     $0560,Y

; ---- bank6.code_A607 (code) $A607-$A60B, 5 bytes
        lda     #$04
        sta     $07A0,Y

; ---- bank6.code_A60C (code) $A60C-$A610, 5 bytes
        lda     #$00
        sta     $0698,Y

; ---- bank6.code_A611 (code) $A611-$A615, 5 bytes
        lda     #$10
        sta     $07D0,Y

; ---- bank6.code_A616 (code) $A616-$A61D, 8 bytes
L6_A616:
        lda     $07A0,X
        eor     #$01
        sta     $07A0,X

; ---- bank6.code_A61E (code) $A61E-$A622, 5 bytes
L6_A61E:
        jsr     L6_9A53
        beq     L6_A62A

; ---- bank6.code_A623 (code) $A623-$A628, 6 bytes
        lda     $41
        and     #$03
        beq     L6_A62A

; ---- bank6.code_A629 (code) $A629-$A629, 1 bytes
        rts

; ---- bank6.code_A62A (code) $A62A-$A62E, 5 bytes
L6_A62A:
        lda     $07A0,X
        bne     L6_A635

; ---- bank6.code_A62F (code) $A62F-$A631, 3 bytes
        jsr     L6_A325

; ---- bank6.code_A632 (code) $A632-$A634, 3 bytes
        jmp     L6_A638

; ---- bank6.code_A635 (code) $A635-$A637, 3 bytes
L6_A635:
        jsr     L6_A337

; ---- bank6.code_A638 (code) $A638-$A63A, 3 bytes
L6_A638:
        jsr     L7_C090

; ---- bank6.code_A63B (code) $A63B-$A63D, 3 bytes
        jsr     L7_C0C6

; ---- bank6.code_A63E (code) $A63E-$A640, 3 bytes
        jmp     L7_C0D8

; ---- bank6.code_A641 (code) $A641-$A645, 5 bytes
L6_A641:
        lda     $0500,X
        bmi     L6_A679

; ---- bank6.code_A646 (code) $A646-$A648, 3 bytes
        jsr     L7_C0AE

; ---- bank6.code_A649 (code) $A649-$A64B, 3 bytes
        jsr     L7_C165

; ---- bank6.code_A64C (code) $A64C-$A650, 5 bytes
        lda     #$61
        sta     $06C8,X

; ---- bank6.code_A651 (code) $A651-$A655, 5 bytes
        lda     #$8C
        sta     $0548,X

; ---- bank6.code_A656 (code) $A656-$A65A, 5 bytes
        lda     #$03
        sta     $0560,X

; ---- bank6.code_A65B (code) $A65B-$A65F, 5 bytes
        lda     #$30
        sta     $0530,X

; ---- bank6.code_A660 (code) $A660-$A664, 5 bytes
        lda     #$20
        sta     $0518,X

; ---- bank6.code_A665 (code) $A665-$A669, 5 bytes
        lda     #$80
        sta     $0680,X

; ---- bank6.code_A66A (code) $A66A-$A66E, 5 bytes
        lda     #$60
        sta     $0668,X

; ---- bank6.code_A66F (code) $A66F-$A673, 5 bytes
        lda     #$78
        sta     $0788,X

; ---- bank6.code_A674 (code) $A674-$A678, 5 bytes
        lda     #$28
        sta     $07A0,X

; ---- bank6.code_A679 (code) $A679-$A67B, 3 bytes
L6_A679:
        jsr     L7_C009

; ---- bank6.code_A67C (code) $A67C-$A680, 5 bytes
        dec     $07A0,X
        bne     L6_A6A4

; ---- bank6.code_A681 (code) $A681-$A685, 5 bytes
        lda     #$28
        sta     $07A0,X

; ---- bank6.code_A686 (code) $A686-$A68A, 5 bytes
        jsr     L7_C108
        bcs     L6_A6A4

; ---- bank6.code_A68B (code) $A68B-$A68F, 5 bytes
        lda     #$5F
        jsr     L7_C105

; ---- bank6.code_A690 (code) $A690-$A694, 5 bytes
        lda     #$01
        sta     $0560,Y

; ---- bank6.code_A695 (code) $A695-$A699, 5 bytes
        lda     #$00
        sta     $0698,Y

; ---- bank6.code_A69A (code) $A69A-$A69E, 5 bytes
        lda     #$00
        sta     $07A0,Y

; ---- bank6.code_A69F (code) $A69F-$A6A3, 5 bytes
        lda     #$28
        sta     $07D0,Y

; ---- bank6.code_A6A4 (code) $A6A4-$A6A8, 5 bytes
L6_A6A4:
        lda     #$10
        jsr     L7_C09C

; ---- bank6.code_A6A9 (code) $A6A9-$A6AD, 5 bytes
        lda     #$18
        jsr     L7_C09F

; ---- bank6.code_A6AE (code) $A6AE-$A6B0, 3 bytes
        jsr     L7_C08D

; ---- bank6.code_A6B1 (code) $A6B1-$A6B3, 3 bytes
        jsr     L7_C0C6

; ---- bank6.code_A6B4 (code) $A6B4-$A6B6, 3 bytes
        jmp     L7_C0D8

; ---- bank6.code_A6B7 (code) $A6B7-$A6BB, 5 bytes
L6_A6B7:
        lda     $0500,X
        bmi     L6_A6D6

; ---- bank6.code_A6BC (code) $A6BC-$A6BE, 3 bytes
        jsr     L7_C0A8

; ---- bank6.code_A6BF (code) $A6BF-$A6C1, 3 bytes
        jsr     L7_C162

; ---- bank6.code_A6C2 (code) $A6C2-$A6C7, 6 bytes
        lda     $07A0,X
        jsr     L6_A1E7

; ---- bank6.code_A6C8 (code) $A6C8-$A6CD, 6 bytes
        lda     $0788,X
        jsr     L7_C102

; ---- bank6.code_A6CE (code) $A6CE-$A6D2, 5 bytes
        lda     #$37
        sta     $0548,X

; ---- bank6.code_A6D3 (code) $A6D3-$A6D5, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_A6D6 (code) $A6D6-$A6DB, 6 bytes
L6_A6D6:
        lda     $0518
        sta     $0668,X

; ---- bank6.code_A6DC (code) $A6DC-$A6E1, 6 bytes
        lda     $0530
        sta     $0680,X

; ---- bank6.code_A6E2 (code) $A6E2-$A6E7, 6 bytes
        lda     $07D0,X
        jsr     L7_C09C

; ---- bank6.code_A6E8 (code) $A6E8-$A6ED, 6 bytes
        lda     $07D0,X
        jsr     L7_C09F

; ---- bank6.code_A6EE (code) $A6EE-$A6F4, 7 bytes
        lda     #$20
        ldy     #$04
        jsr     L7_C0A5

; ---- bank6.code_A6F5 (code) $A6F5-$A6FF, 11 bytes
        lda     $0560,X
        and     #$03
        ora     $A5AC,Y
        sta     $0560,X

; ---- bank6.code_A700 (code) $A700-$A702, 3 bytes
        jmp     L6_9F4F

; ---- bank6.code_A703 (code) $A703-$A707, 5 bytes
L6_A703:
        ldy     $0500,X
        bmi     L6_A73B

; ---- bank6.code_A708 (code) $A708-$A70D, 6 bytes
        lda     $A716,Y
        sta     $0698,X

; ---- bank6.code_A70E (code) $A70E-$A713, 6 bytes
        lda     $A718,Y
        sta     $0560,X

; ---- bank6.code_A714 (code) $A714-$A719, 6 bytes
        lda     $A71A,Y
        sta     $07B8,X

; ---- bank6.code_A71A (code) $A71A-$A71F, 6 bytes
        lda     $A71C,Y
        sta     $07D0,X

; ---- bank6.code_A720 (code) $A720-$A722, 3 bytes
        jsr     L7_C0A8

; ---- bank6.code_A723 (code) $A723-$A725, 3 bytes
        jsr     L7_C162

; ---- bank6.code_A726 (code) $A726-$A728, 3 bytes
        jsr     L7_C0F3

; ---- bank6.code_A729 (code) $A729-$A72D, 5 bytes
        lda     #$19
        sta     $0548,X

; ---- bank6.code_A72E (code) $A72E-$A730, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_A731 (code) $A731-$A735, 5 bytes
        lda     #$3C
        sta     $0788,X

; ---- bank6.code_A736 (code) $A736-$A73A, 5 bytes
        lda     #$01
        sta     $07A0,X

; ---- bank6.code_A73B (code) $A73B-$A73D, 3 bytes
L6_A73B:
        jsr     L7_C009

; ---- bank6.code_A73E (code) $A73E-$A742, 5 bytes
        dec     $07A0,X
        bne     L6_A755

; ---- bank6.code_A743 (code) $A743-$A748, 6 bytes
        lda     $07D0,X
        sta     $07A0,X

; ---- bank6.code_A749 (code) $A749-$A74B, 3 bytes
        jsr     L7_C0FF

; ---- bank6.code_A74C (code) $A74C-$A751, 6 bytes
        clc
        adc     $07B8,X
        and     #$0C

; ---- bank6.code_A752 (code) $A752-$A754, 3 bytes
        jsr     L7_C102

; ---- bank6.code_A755 (code) $A755-$A759, 5 bytes
L6_A755:
        lda     #$0F
        jsr     L6_9B09

; ---- bank6.code_A75A (code) $A75A-$A75C, 3 bytes
        jsr     L6_826D

; ---- bank6.code_A75D (code) $A75D-$A75F, 3 bytes
        jsr     L7_C090

; ---- bank6.code_A760 (code) $A760-$A762, 3 bytes
        jsr     L7_C0C6

; ---- bank6.code_A763 (code) $A763-$A765, 3 bytes
        jmp     L7_C0D2

; ---- bank6.tbl_A766 (data) $A766-$A767, 2 bytes
; Types $50 / $51 (and $53 / $54) speed class
        .byte   $01,$02

; ---- bank6.tbl_A768 (data) $A768-$A769, 2 bytes
; Types $50 / $51 palette
        .byte   $02,$00

; ---- bank6.tbl_A76A (data) $A76A-$A76B, 2 bytes
; Types $50 / $51 rounding bias
        .byte   $01,$02

; ---- bank6.tbl_A76C (data) $A76C-$A76D, 2 bytes
; Types $50 / $51 / $53 / $54 decision interval
        .byte   $3C,$1E

; ---- bank6.code_A76E (code) $A76E-$A772, 5 bytes
L6_A76E:
        lda     $0500,X
        bmi     L6_A7B0

; ---- bank6.code_A773 (code) $A773-$A778, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_A779 (code) $A779-$A77D, 5 bytes
        lda     #$01
        sta     $0560,X

; ---- bank6.code_A77E (code) $A77E-$A780, 3 bytes
        jsr     L6_AEE8

; ---- bank6.code_A781 (code) $A781-$A785, 5 bytes
        lda     #$1A
        sta     $0548,X

; ---- bank6.code_A786 (code) $A786-$A787, 2 bytes
        ldy     #$00

; ---- bank6.code_A788 (code) $A788-$A78A, 3 bytes
        jsr     L6_AD9A

; ---- bank6.code_A78B (code) $A78B-$A78C, 2 bytes
        beq     L6_A78F

; ---- bank6.code_A78D (code) $A78D-$A78E, 2 bytes
        ldy     #$02

; ---- bank6.code_A78F (code) $A78F-$A797, 9 bytes
L6_A78F:
        lda     $A7F4,Y
        sta     $0530,X
        sta     $0680,X

; ---- bank6.code_A798 (code) $A798-$A79D, 6 bytes
        lda     $A7F5,Y
        sta     $0608,X

; ---- bank6.code_A79E (code) $A79E-$A7A2, 5 bytes
        lda     #$18
        sta     $0518,X

; ---- bank6.code_A7A3 (code) $A7A3-$A7A7, 5 bytes
        lda     #$01
        sta     $05D8,X

; ---- bank6.code_A7A8 (code) $A7A8-$A7AC, 5 bytes
        lda     #$28
        sta     $0788,X

; ---- bank6.code_A7AD (code) $A7AD-$A7AF, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_A7B0 (code) $A7B0-$A7B2, 3 bytes
L6_A7B0:
        jsr     L7_C009

; ---- bank6.code_A7B3 (code) $A7B3-$A7B9, 7 bytes
        lda     #$30
        ldy     #$02
        jsr     L7_C0A5

; ---- bank6.code_A7BA (code) $A7BA-$A7BF, 6 bytes
        lda     $A7F8,Y
        jsr     L6_A1E7

; ---- bank6.code_A7C0 (code) $A7C0-$A7C4, 5 bytes
        lda     #$0A
        jsr     L7_C09F

; ---- bank6.code_A7C5 (code) $A7C5-$A7C9, 5 bytes
        jsr     L7_C08D
        bcc     L6_A7CD

; ---- bank6.code_A7CA (code) $A7CA-$A7CC, 3 bytes
        jmp     L6_9B17

; ---- bank6.code_A7CD (code) $A7CD-$A7D7, 11 bytes
L6_A7CD:
        lda     $0530,X
        cmp     $0680,X
        ldy     $0680,X
        bmi     L6_A7E1

; ---- bank6.code_A7D8 (code) $A7D8-$A7D9, 2 bytes
        bcs     L6_A7EE

; ---- bank6.code_A7DA (code) $A7DA-$A7DE, 5 bytes
        lda     $0608,X
        bpl     L6_A7EE

; ---- bank6.code_A7DF (code) $A7DF-$A7E0, 2 bytes
        bmi     L6_A7E8

; ---- bank6.code_A7E1 (code) $A7E1-$A7E2, 2 bytes
L6_A7E1:
        bcc     L6_A7EE

; ---- bank6.code_A7E3 (code) $A7E3-$A7E7, 5 bytes
        lda     $0608,X
        bmi     L6_A7EE

; ---- bank6.code_A7E8 (code) $A7E8-$A7ED, 6 bytes
L6_A7E8:
        jsr     L7_C123
        jsr     L7_C126

; ---- bank6.code_A7EE (code) $A7EE-$A7F0, 3 bytes
L6_A7EE:
        jsr     L7_C0C6

; ---- bank6.code_A7F1 (code) $A7F1-$A7F3, 3 bytes
        jmp     L7_C0D2

; ---- bank6.tbl_A7F4 (data) $A7F4-$A7F7, 4 bytes
; Type $52 start: 2 x [x][x speed]
        .byte   $20,$03,$E0,$FD

; ---- bank6.tbl_A7F8 (data) $A7F8-$A7F9, 2 bytes
; Type $52 tile offset by phase
        .byte   $00,$02

; ---- bank6.code_A7FA (code) $A7FA-$A7FE, 5 bytes
L6_A7FA:
        ldy     $0500,X
        bmi     L6_A838

; ---- bank6.code_A7FF (code) $A7FF-$A804, 6 bytes
        lda     $4B
        cmp     #$03
        bcs     L6_A80E

; ---- bank6.code_A805 (code) $A805-$A80A, 6 bytes
        tya
        sbc     #$02
        sta     $0500,X

; ---- bank6.code_A80B (code) $A80B-$A80D, 3 bytes
        jmp     L6_A703

; ---- bank6.code_A80E (code) $A80E-$A813, 6 bytes
L6_A80E:
        lda     $A713,Y
        sta     $0698,X

; ---- bank6.code_A814 (code) $A814-$A819, 6 bytes
        lda     $A715,Y
        sta     $0560,X

; ---- bank6.code_A81A (code) $A81A-$A81F, 6 bytes
        lda     $A719,Y
        sta     $07D0,X

; ---- bank6.code_A820 (code) $A820-$A822, 3 bytes
        jsr     L7_C0A8

; ---- bank6.code_A823 (code) $A823-$A825, 3 bytes
        jsr     L7_C162

; ---- bank6.code_A826 (code) $A826-$A828, 3 bytes
        jsr     L7_C0F3

; ---- bank6.code_A829 (code) $A829-$A82D, 5 bytes
        lda     #$50
        sta     $0548,X

; ---- bank6.code_A82E (code) $A82E-$A832, 5 bytes
        lda     #$01
        sta     $07A0,X

; ---- bank6.code_A833 (code) $A833-$A837, 5 bytes
        lda     #$3C
        sta     $0788,X

; ---- bank6.code_A838 (code) $A838-$A83A, 3 bytes
L6_A838:
        jsr     L7_C009

; ---- bank6.code_A83B (code) $A83B-$A83F, 5 bytes
        dec     $07A0,X
        bne     L6_A849

; ---- bank6.code_A840 (code) $A840-$A845, 6 bytes
        lda     $07D0,X
        sta     $07A0,X

; ---- bank6.code_A846 (code) $A846-$A848, 3 bytes
        jsr     L7_C0FC

; ---- bank6.code_A849 (code) $A849-$A84F, 7 bytes
L6_A849:
        lda     #$10
        ldy     #$02
        jsr     L7_C0A5

; ---- bank6.code_A850 (code) $A850-$A855, 6 bytes
        lda     $A887,Y
        sta     $0548,X

; ---- bank6.code_A856 (code) $A856-$A85A, 5 bytes
        jsr     L6_9A53
        beq     L6_A862

; ---- bank6.code_A85B (code) $A85B-$A860, 6 bytes
        lda     $41
        and     #$01
        beq     L6_A862

; ---- bank6.code_A861 (code) $A861-$A861, 1 bytes
L6_A861:
        rts

; ---- bank6.code_A862 (code) $A862-$A866, 5 bytes
L6_A862:
        jsr     L7_C08D
        bcc     L6_A86A

; ---- bank6.code_A867 (code) $A867-$A869, 3 bytes
        jmp     L6_9B17

; ---- bank6.code_A86A (code) $A86A-$A870, 7 bytes
L6_A86A:
        ldy     $6C
        lda     $8425,Y
        bne     L6_A861

; ---- bank6.code_A871 (code) $A871-$A876, 6 bytes
        lda     $41
        and     #$1F
        bne     L6_A881

; ---- bank6.code_A877 (code) $A877-$A87B, 5 bytes
        jsr     L7_C108
        bcs     L6_A881

; ---- bank6.code_A87C (code) $A87C-$A880, 5 bytes
        lda     #$0B
        jsr     L7_C105

; ---- bank6.code_A881 (code) $A881-$A883, 3 bytes
L6_A881:
        jsr     L7_C0C6

; ---- bank6.code_A884 (code) $A884-$A886, 3 bytes
        jmp     L7_C0D2

; ---- bank6.tbl_A887 (data) $A887-$A888, 2 bytes
; Types $53 / $54 metasprite by phase
        .byte   $50,$2B

; ---- bank6.code_A889 (code) $A889-$A88D, 5 bytes
L6_A889:
        lda     $0500,X
        bmi     L6_A898

; ---- bank6.code_A88E (code) $A88E-$A893, 6 bytes
        lda     $B8
        ora     $B9
        beq     L6_A895

; ---- bank6.code_A894 (code) $A894-$A894, 1 bytes
L6_A894:
        rts

; ---- bank6.code_A895 (code) $A895-$A897, 3 bytes
L6_A895:
        jsr     L7_C0AE

; ---- bank6.code_A898 (code) $A898-$A89C, 5 bytes
L6_A898:
        lda     #$00
        sta     $0518,X

; ---- bank6.code_A89D (code) $A89D-$A89E, 2 bytes
        ldy     #$05

; ---- bank6.code_A89F (code) $A89F-$A8A3, 5 bytes
L6_A89F:
        lda     $0500,Y
        beq     L6_A8B9

; ---- bank6.code_A8A4 (code) $A8A4-$A8B5, 18 bytes
        and     #$7F
        cmp     #$36
        beq     L6_A8B6
        cmp     #$37
        beq     L6_A8B6
        cmp     #$7E
        beq     L6_A8B6
        cmp     #$7F
        bne     L6_A8B9

; ---- bank6.code_A8B6 (code) $A8B6-$A8B8, 3 bytes
L6_A8B6:
        inc     $0518,X

; ---- bank6.code_A8B9 (code) $A8B9-$A8BD, 5 bytes
L6_A8B9:
        iny
        cpy     #$18
        bne     L6_A89F

; ---- bank6.code_A8BE (code) $A8BE-$A8C2, 5 bytes
        lda     $0518,X
        bne     L6_A894

; ---- bank6.code_A8C3 (code) $A8C3-$A8C5, 3 bytes
        jmp     L7_C048

; ---- bank6.code_A8C6 (code) $A8C6-$A8D7, 18 bytes
L6_A8C6:
        lda     $0530,X
        clc
        adc     #$08
        sta     $0530,X
        lda     $0518,X
        adc     #$08
        sta     $0518,X
        rts

; ---- bank6.code_A8D8 (code) $A8D8-$A8DA, 3 bytes
L6_A8D8:
        jsr     L6_BA51

; ---- bank6.code_A8DB (code) $A8DB-$A8DF, 5 bytes
        ldy     $0500,X
        bmi     L6_A8FE

; ---- bank6.code_A8E0 (code) $A8E0-$A8E5, 6 bytes
        lda     $A982,Y
        sta     $0548,X

; ---- bank6.code_A8E6 (code) $A8E6-$A8EC, 7 bytes
        cpy     #$36
        beq     L6_A8ED
        jsr     L6_A8C6

; ---- bank6.code_A8ED (code) $A8ED-$A8EF, 3 bytes
L6_A8ED:
        jsr     L7_C0AE

; ---- bank6.code_A8F0 (code) $A8F0-$A8F5, 6 bytes
        txa
        and     #$07
        sta     $0788,X

; ---- bank6.code_A8F6 (code) $A8F6-$A8F8, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_A8F9 (code) $A8F9-$A8FD, 5 bytes
        lda     #$01
        sta     $07B8,X

; ---- bank6.code_A8FE (code) $A8FE-$A907, 10 bytes
L6_A8FE:
        ldy     $0518,X
        lda     $0500,X
        cmp     #$B6
        bne     L6_A94A

; ---- bank6.code_A908 (code) $A908-$A90B, 4 bytes
        cpy     #$B8
        bcs     L6_A91F

; ---- bank6.code_A90C (code) $A90C-$A90D, 2 bytes
        ldy     #$03

; ---- bank6.code_A90E (code) $A90E-$A912, 5 bytes
        jsr     L6_AA35
        bcc     L6_A91F

; ---- bank6.code_A913 (code) $A913-$A919, 7 bytes
        lda     $0638,X
        asl     A
        asl     A
        adc     #$21

; ---- bank6.code_A91A (code) $A91A-$A91E, 5 bytes
        ldy     #$AA
        jsr     L6_AA21

; ---- bank6.code_A91F (code) $A91F-$A925, 7 bytes
L6_A91F:
        lda     $0638,X
        cmp     #$03
        bne     L6_A932

; ---- bank6.code_A926 (code) $A926-$A92C, 7 bytes
        lda     #$0F
        jsr     L6_AEBF
        bcs     L6_A932

; ---- bank6.code_A92D (code) $A92D-$A931, 5 bytes
        lda     #$2B
        jsr     L6_AA0F

; ---- bank6.code_A932 (code) $A932-$A936, 5 bytes
L6_A932:
        lda     $0638,X
        beq     L6_A949

; ---- bank6.code_A937 (code) $A937-$A939, 3 bytes
        jsr     L7_C0CF

; ---- bank6.code_A93A (code) $A93A-$A93C, 3 bytes
        jsr     L7_C0D2

; ---- bank6.code_A93D (code) $A93D-$A941, 5 bytes
        lda     $0500,X
        bmi     L6_A949

; ---- bank6.code_A942 (code) $A942-$A948, 7 bytes
        lda     #$31
        ldy     #$55
        jmp     L6_AA21

; ---- bank6.code_A949 (code) $A949-$A949, 1 bytes
L6_A949:
        rts

; ---- bank6.code_A94A (code) $A94A-$A94F, 6 bytes
L6_A94A:
        lda     $B8
        ora     $B9
        bne     L6_A95D

; ---- bank6.code_A950 (code) $A950-$A951, 2 bytes
        ldy     #$02

; ---- bank6.code_A952 (code) $A952-$A956, 5 bytes
        jsr     L6_AA35
        bcc     L6_A95D

; ---- bank6.code_A957 (code) $A957-$A95C, 6 bytes
        lda     $0638,X
        jsr     L6_A991

; ---- bank6.code_A95D (code) $A95D-$A963, 7 bytes
L6_A95D:
        lda     $0638,X
        cmp     #$02
        bne     L6_A97B

; ---- bank6.code_A964 (code) $A964-$A968, 5 bytes
        dec     $07B8,X
        bne     L6_A97B

; ---- bank6.code_A969 (code) $A969-$A96D, 5 bytes
        lda     #$14
        sta     $07B8,X

; ---- bank6.code_A96E (code) $A96E-$A972, 5 bytes
        jsr     L7_C108
        bcs     L6_A97B

; ---- bank6.code_A973 (code) $A973-$A977, 5 bytes
        lda     #$2B
        jsr     L7_C105

; ---- bank6.code_A978 (code) $A978-$A97A, 3 bytes
        jsr     L6_AA12

; ---- bank6.code_A97B (code) $A97B-$A97F, 5 bytes
L6_A97B:
        lda     $0638,X
        beq     L6_A990

; ---- bank6.code_A980 (code) $A980-$A982, 3 bytes
        jsr     L7_C0CF

; ---- bank6.code_A983 (code) $A983-$A985, 3 bytes
        jsr     L7_C0D2

; ---- bank6.code_A986 (code) $A986-$A98A, 5 bytes
        lda     $0500,X
        bmi     L6_A990

; ---- bank6.code_A98B (code) $A98B-$A98F, 5 bytes
        lda     #$03
        jsr     L6_A991

; ---- bank6.code_A990 (code) $A990-$A990, 1 bytes
L6_A990:
        rts

; ---- bank6.code_A991 (code) $A991-$A9B7, 39 bytes
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

; ---- bank6.tbl_A9B8 (data) $A9B8-$A9B9, 2 bytes
; Cannon picture by type
        .byte   $31,$21

; ---- bank6.tbl_A9BA (data) $A9BA-$A9BE, 5 bytes
; Five bytes after the cannon tables, no reader found
        .byte   $FE,$02,$FF,$01,$00

; ---- bank6.tbl_A9BF (data) $A9BF-$A9FE, 64 bytes
; Type $37 tile blocks: 4 x [4 x 4 tiles]
        .byte   $CA,$CB,$CC,$CD,$DA,$DB,$DC,$DD,$EA,$EB,$EC,$ED,$FA,$FB,$FC,$FD
        .byte   $CA,$C0,$C1,$CD,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,$FA,$CE,$CF,$FD
        .byte   $CA,$DE,$DF,$CD,$B8,$B9,$BA,$BB,$BC,$BD,$BE,$BF,$FA,$EE,$EF,$FD
        .byte   $CA,$B6,$B7,$CD,$B2,$20,$20,$B3,$B0,$20,$20,$B1,$FA,$B4,$B5,$FD

; ---- bank6.tbl_A9FF (data) $A9FF-$AA0E, 16 bytes
; A fifth 4 x 4 tile block
        .byte   $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C4,$C5,$C6,$C7,$C8,$C9,$CA,$CB

; ---- bank6.code_AA0F (code) $AA0F-$AA11, 3 bytes
L6_AA0F:
        sta     $0500,Y

; ---- bank6.code_AA12 (code) $AA12-$AA20, 15 bytes
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

; ---- bank6.code_AA21 (code) $AA21-$AA34, 20 bytes
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

; ---- bank6.code_AA35 (code) $AA35-$AA46, 18 bytes
L6_AA35:
        sty     $10
        ldy     $0788,X
        lda     $0638,X
        bne     L6_AA4B
        lda     $AA7C,Y
        jsr     L6_AA94
        bcc     L6_AA4A

; ---- bank6.code_AA47 (code) $AA47-$AA49, 3 bytes
L6_AA47:
        inc     $0638,X

; ---- bank6.code_AA4A (code) $AA4A-$AA4A, 1 bytes
L6_AA4A:
        rts

; ---- bank6.code_AA4B (code) $AA4B-$AA56, 12 bytes
L6_AA4B:
        cmp     $10
        bne     L6_AA61
        lda     $AA8C,Y
        jsr     L6_AA94
        bcc     L6_AA60

; ---- bank6.code_AA57 (code) $AA57-$AA60, 10 bytes
        lda     $0638,X
        sbc     #$81
        sta     $0638,X
        sec
L6_AA60:
        rts

; ---- bank6.code_AA61 (code) $AA61-$AA7B, 27 bytes
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

; ---- bank6.tbl_AA7C (data) $AA7C-$AA83, 8 bytes
; Cannon closed-phase step by index
        .byte   $04,$08,$06,$05,$07,$06,$08,$03

; ---- bank6.tbl_AA84 (data) $AA84-$AA8B, 8 bytes
; Cannon opening / closing step by index
        .byte   $50,$40,$30,$44,$25,$18,$30,$48

; ---- bank6.tbl_AA8C (data) $AA8C-$AA93, 8 bytes
; Cannon open-phase step by index
        .byte   $10,$0C,$11,$05,$07,$14,$09,$0D

; ---- bank6.code_AA94 (code) $AA94-$AA9B, 8 bytes
L6_AA94:
        clc
        adc     $0650,X
        sta     $0650,X
        rts

; ---- bank6.code_AA9C (code) $AA9C-$AAA0, 5 bytes
L6_AA9C:
        lda     $0500,X
        bmi     L6_AAD8

; ---- bank6.code_AAA1 (code) $AAA1-$AAA3, 3 bytes
        jsr     L7_C0A8

; ---- bank6.code_AAA4 (code) $AAA4-$AAA6, 3 bytes
        jsr     L7_C162

; ---- bank6.code_AAA7 (code) $AAA7-$AAA9, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_AAAA (code) $AAAA-$AAAC, 3 bytes
        jsr     L7_C0F0

; ---- bank6.code_AAAD (code) $AAAD-$AAB8, 12 bytes
        lda     $0530,X
        and     #$0F
        asl     A
        asl     A
        adc     #$60
        sta     $0788,X

; ---- bank6.code_AAB9 (code) $AAB9-$AABD, 5 bytes
        lda     #$1A
        sta     $0548,X

; ---- bank6.code_AABE (code) $AABE-$AAC2, 5 bytes
        lda     #$00
        sta     $0560,X

; ---- bank6.code_AAC3 (code) $AAC3-$AAC5, 3 bytes
        sta     $07A0,X

; ---- bank6.code_AAC6 (code) $AAC6-$AACA, 5 bytes
        lda     #$04
        jsr     L6_A1E7

; ---- bank6.code_AACB (code) $AACB-$AACD, 3 bytes
        jsr     L6_AEE8

; ---- bank6.code_AACE (code) $AACE-$AAD2, 5 bytes
        lda     #$06
        sta     $0698,X

; ---- bank6.code_AAD3 (code) $AAD3-$AAD7, 5 bytes
        lda     #$04
        jsr     L7_C102

; ---- bank6.code_AAD8 (code) $AAD8-$AADC, 5 bytes
L6_AAD8:
        lda     $07A0,X
        bne     L6_AAFC

; ---- bank6.code_AADD (code) $AADD-$AAE4, 8 bytes
        lda     $0518,X
        cmp     $0788,X
        bcc     L6_AB1F

; ---- bank6.code_AAE5 (code) $AAE5-$AAED, 9 bytes
        ldy     #$0E
        lda     $0530,X
        cmp     #$80
        bcc     L6_AAF0

; ---- bank6.code_AAEE (code) $AAEE-$AAEF, 2 bytes
        ldy     #$0A

; ---- bank6.code_AAF0 (code) $AAF0-$AAF3, 4 bytes
L6_AAF0:
        tya
        jsr     L7_C102

; ---- bank6.code_AAF4 (code) $AAF4-$AAFB, 8 bytes
        lda     #$01
        sta     $0788,X
        sta     $07A0,X

; ---- bank6.code_AAFC (code) $AAFC-$AB00, 5 bytes
L6_AAFC:
        dec     $0788,X
        bne     L6_AB0B

; ---- bank6.code_AB01 (code) $AB01-$AB05, 5 bytes
        lda     #$14
        sta     $0788,X

; ---- bank6.code_AB06 (code) $AB06-$AB0A, 5 bytes
        lda     #$06
        jsr     L6_AB32

; ---- bank6.code_AB0B (code) $AB0B-$AB11, 7 bytes
L6_AB0B:
        lda     #$60
        ldy     #$08
        jsr     L7_C0A5

; ---- bank6.code_AB12 (code) $AB12-$AB16, 5 bytes
        lda     $AB22,Y
        sta     $15

; ---- bank6.code_AB17 (code) $AB17-$AB1B, 5 bytes
        lda     $AB2A,Y
        sta     $14

; ---- bank6.code_AB1C (code) $AB1C-$AB1E, 3 bytes
        jsr     L6_A1DB

; ---- bank6.code_AB1F (code) $AB1F-$AB21, 3 bytes
L6_AB1F:
        jmp     L6_9F4F

; ---- bank6.tbl_AB22 (data) $AB22-$AB29, 8 bytes
; Type $69 tile offset by phase
        .byte   $04,$02,$00,$02,$04,$02,$00,$02

; ---- bank6.tbl_AB2A (data) $AB2A-$AB31, 8 bytes
; Type $69 flip bits by phase
        .byte   $00,$00,$00,$80,$80,$80,$00,$00

; ---- bank6.code_AB32 (code) $AB32-$AB68, 55 bytes
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

; ---- bank6.code_AB69 (code) $AB69-$AB6D, 5 bytes
L6_AB69:
        lda     $0500,X
        bmi     L6_AB93

; ---- bank6.code_AB6E (code) $AB6E-$AB73, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_AB74 (code) $AB74-$AB78, 5 bytes
        lda     #$00
        sta     $0560,X

; ---- bank6.code_AB79 (code) $AB79-$AB7B, 3 bytes
        jsr     L6_AEE8

; ---- bank6.code_AB7C (code) $AB7C-$AB80, 5 bytes
        lda     #$50
        sta     $0548,X

; ---- bank6.code_AB81 (code) $AB81-$AB85, 5 bytes
        ldy     #$00
        jsr     L6_AF39

; ---- bank6.code_AB86 (code) $AB86-$AB8D, 8 bytes
        lda     #$A8
        sta     $0518,X
        sta     $0668,X

; ---- bank6.code_AB8E (code) $AB8E-$AB92, 5 bytes
        lda     #$3C
        sta     $0788,X

; ---- bank6.code_AB93 (code) $AB93-$AB95, 3 bytes
L6_AB93:
        jsr     L7_C009

; ---- bank6.code_AB96 (code) $AB96-$AB9E, 9 bytes
        lda     $41
        and     #$01
        bne     L6_AB9F
        jsr     L6_A325

; ---- bank6.code_AB9F (code) $AB9F-$ABA3, 5 bytes
L6_AB9F:
        lda     $05D8,X
        bmi     L6_ABD2

; ---- bank6.code_ABA4 (code) $ABA4-$ABAB, 8 bytes
        lda     $0518,X
        cmp     $0668,X
        bcc     L6_ABD2

; ---- bank6.code_ABAC (code) $ABAC-$ABB0, 5 bytes
        lda     #$FC
        sta     $05D8,X

; ---- bank6.code_ABB1 (code) $ABB1-$ABB9, 9 bytes
        lda     $0668,X
        sbc     #$10
        cmp     #$40
        bcs     L6_ABBC

; ---- bank6.code_ABBA (code) $ABBA-$ABBB, 2 bytes
        lda     #$A8

; ---- bank6.code_ABBC (code) $ABBC-$ABBE, 3 bytes
L6_ABBC:
        sta     $0668,X

; ---- bank6.code_ABBF (code) $ABBF-$ABC3, 5 bytes
        lda     #$08
        jsr     L6_AB32

; ---- bank6.code_ABC4 (code) $ABC4-$ABC9, 6 bytes
        lda     $05A8,X
        sta     $05A8,Y

; ---- bank6.code_ABCA (code) $ABCA-$ABD1, 8 bytes
        lda     $0560,X
        eor     #$40
        sta     $0560,X

; ---- bank6.code_ABD2 (code) $ABD2-$ABD6, 5 bytes
L6_ABD2:
        lda     #$30
        jsr     L7_C09C

; ---- bank6.code_ABD7 (code) $ABD7-$ABD9, 3 bytes
        jmp     L6_9F4F

; ---- bank6.code_ABDA (code) $ABDA-$ABDE, 5 bytes
L6_ABDA:
        lda     $0500,X
        bmi     L6_ABF8

; ---- bank6.code_ABDF (code) $ABDF-$ABE4, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_ABE5 (code) $ABE5-$ABE7, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_ABE8 (code) $ABE8-$ABEA, 3 bytes
        jsr     L7_C0F0

; ---- bank6.code_ABEB (code) $ABEB-$ABEF, 5 bytes
        lda     #$01
        sta     $0560,X

; ---- bank6.code_ABF0 (code) $ABF0-$ABF2, 3 bytes
        jsr     L6_AEE8

; ---- bank6.code_ABF3 (code) $ABF3-$ABF7, 5 bytes
        lda     #$01
        sta     $05D8,X

; ---- bank6.code_ABF8 (code) $ABF8-$ABFE, 7 bytes
L6_ABF8:
        lda     #$40
        ldy     #$04
        jsr     L7_C0A5

; ---- bank6.code_ABFF (code) $ABFF-$AC03, 5 bytes
        lda     $AC20,Y
        sta     $15

; ---- bank6.code_AC04 (code) $AC04-$AC08, 5 bytes
        lda     $AC24,Y
        sta     $14

; ---- bank6.code_AC09 (code) $AC09-$AC0E, 6 bytes
        lda     $AC28,Y
        jsr     L6_A1D8

; ---- bank6.code_AC0F (code) $AC0F-$AC14, 6 bytes
        lda     $41
        and     #$03
        bne     L6_AC1D

; ---- bank6.code_AC15 (code) $AC15-$AC19, 5 bytes
        jsr     L7_C108
        bcs     L6_AC1D

; ---- bank6.code_AC1A (code) $AC1A-$AC1C, 3 bytes
        jsr     L6_BF61

; ---- bank6.code_AC1D (code) $AC1D-$AC1F, 3 bytes
L6_AC1D:
        jmp     L6_9F4F

; ---- bank6.tbl_AC20 (data) $AC20-$AC23, 4 bytes
; Type $6B tile offset by phase
        .byte   $04,$00,$02,$00

; ---- bank6.tbl_AC24 (data) $AC24-$AC27, 4 bytes
; Type $6B flip bits by phase
        .byte   $00,$00,$00,$40

; ---- bank6.tbl_AC28 (data) $AC28-$AC2B, 4 bytes
; Type $6B metasprite by phase
        .byte   $1A,$79,$1A,$79

; ---- bank6.code_AC2C (code) $AC2C-$AC2E, 3 bytes
L6_AC2C:
        jsr     L6_BA51

; ---- bank6.code_AC2F (code) $AC2F-$AC33, 5 bytes
        lda     $0500,X
        bmi     L6_AC52

; ---- bank6.code_AC34 (code) $AC34-$AC36, 3 bytes
        jsr     L7_C0AE

; ---- bank6.code_AC37 (code) $AC37-$AC3F, 9 bytes
        lda     $0518,X
        clc
        adc     #$10
        sta     $0518,X

; ---- bank6.code_AC40 (code) $AC40-$AC47, 8 bytes
        lda     $0530,X
        adc     #$06
        sta     $0530,X

; ---- bank6.code_AC48 (code) $AC48-$AC4C, 5 bytes
        lda     #$21
        sta     $0548,X

; ---- bank6.code_AC4D (code) $AC4D-$AC51, 5 bytes
        lda     #$01
        sta     $07A0,X

; ---- bank6.code_AC52 (code) $AC52-$AC56, 5 bytes
L6_AC52:
        dec     $07A0,X
        bne     L6_AC6C

; ---- bank6.code_AC57 (code) $AC57-$AC5B, 5 bytes
        lda     #$10
        sta     $07A0,X

; ---- bank6.code_AC5C (code) $AC5C-$AC60, 5 bytes
        jsr     L7_C0FF
        sta     $15

; ---- bank6.code_AC61 (code) $AC61-$AC65, 5 bytes
        jsr     L7_C108
        bcs     L6_AC6C

; ---- bank6.code_AC66 (code) $AC66-$AC6B, 6 bytes
        jsr     L6_AC9F
        jsr     L6_ACCA

; ---- bank6.code_AC6C (code) $AC6C-$AC6E, 3 bytes
L6_AC6C:
        jsr     L7_C0CF

; ---- bank6.code_AC6F (code) $AC6F-$AC71, 3 bytes
        jsr     L7_C0D2

; ---- bank6.code_AC72 (code) $AC72-$AC76, 5 bytes
        lda     $0500,X
        bmi     L6_AC8E

; ---- bank6.code_AC77 (code) $AC77-$AC79, 3 bytes
        jsr     L6_BF71

; ---- bank6.code_AC7A (code) $AC7A-$AC87, 14 bytes
        lda     #$8F
        sta     $16
        lda     #$AC
        sta     $17
        lda     #$04
        sta     $15
        sta     $14

; ---- bank6.code_AC88 (code) $AC88-$AC8D, 6 bytes
        ldy     $0518,X
        jmp     L7_C07E

; ---- bank6.code_AC8E (code) $AC8E-$AC8E, 1 bytes
L6_AC8E:
        rts

; ---- bank6.tbl_AC8F (data) $AC8F-$AC9E, 16 bytes
; Gun emplacement rubble block (4 x 4 tiles)
        .byte   $80,$80,$80,$80,$80,$80,$80,$80,$60,$7D,$7E,$7F,$68,$20,$20,$6F

; ---- bank6.code_AC9F (code) $AC9F-$ACA3, 5 bytes
L6_AC9F:
        lda     #$2A
        jsr     L7_C105

; ---- bank6.code_ACA4 (code) $ACA4-$ACB9, 22 bytes
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

; ---- bank6.tbl_ACBA (data) $ACBA-$ACC9, 16 bytes
; Fragment x speed by direction
        .byte   $01,$01,$00,$00,$FF,$FF,$FE,$FE,$FE,$FE,$FE,$FF,$FF,$00,$00,$01

; ---- bank6.code_ACCA (code) $ACCA-$ACCE, 5 bytes
L6_ACCA:
        and     #$03
        sta     $0560,Y

; ---- bank6.code_ACCF (code) $ACCF-$ACD6, 8 bytes
        lda     #$18
        sta     $0728,Y
        sta     $07B8,Y

; ---- bank6.code_ACD7 (code) $ACD7-$ACE1, 11 bytes
        lda     #$37
        sta     $0548,Y
        lda     #$00
        sta     $07A0,Y
        rts

; ---- bank6.code_ACE2 (code) $ACE2-$ACE6, 5 bytes
L6_ACE2:
        lda     $0500,X
        bmi     L6_AD2F

; ---- bank6.code_ACE7 (code) $ACE7-$ACEC, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_ACED (code) $ACED-$ACF9, 13 bytes
        ldy     #$18
        jsr     L6_AD9A
        beq     L6_ACF6
        ldy     #$E8
L6_ACF6:
        tya
        sta     $0530,X

; ---- bank6.code_ACFA (code) $ACFA-$AD0B, 18 bytes
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

; ---- bank6.code_AD0C (code) $AD0C-$AD0F, 4 bytes
L6_AD0C:
        sta     $07B8,X
        tay

; ---- bank6.code_AD10 (code) $AD10-$AD15, 6 bytes
        lda     $AD89,Y
        sta     $0560,X

; ---- bank6.code_AD16 (code) $AD16-$AD1B, 6 bytes
        lda     $AD8D,Y
        sta     $05D8,X

; ---- bank6.code_AD1C (code) $AD1C-$AD20, 5 bytes
        lda     #$C0
        sta     $05C0,X

; ---- bank6.code_AD21 (code) $AD21-$AD26, 6 bytes
        lda     $AD91,Y
        sta     $0698,X

; ---- bank6.code_AD27 (code) $AD27-$AD2B, 5 bytes
        lda     #$00
        sta     $0788,X

; ---- bank6.code_AD2C (code) $AD2C-$AD2E, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_AD2F (code) $AD2F-$AD33, 5 bytes
L6_AD2F:
        lda     $0788,X
        bne     L6_AD51

; ---- bank6.code_AD34 (code) $AD34-$AD3A, 7 bytes
        lda     #$20
        ldy     #$02
        jsr     L7_C0A5

; ---- bank6.code_AD3B (code) $AD3B-$AD40, 6 bytes
        lda     $AD96,Y
        sta     $0548,X

; ---- bank6.code_AD41 (code) $AD41-$AD48, 8 bytes
        lda     $0518,X
        cmp     $0518
        bcc     L6_AD87

; ---- bank6.code_AD49 (code) $AD49-$AD4B, 3 bytes
        jsr     L7_C0FC

; ---- bank6.code_AD4C (code) $AD4C-$AD50, 5 bytes
        inc     $0788,X
        bne     L6_AD87

; ---- bank6.code_AD51 (code) $AD51-$AD54, 4 bytes
L6_AD51:
        cmp     #$01
        bne     L6_AD82

; ---- bank6.code_AD55 (code) $AD55-$AD5B, 7 bytes
        lda     #$20
        ldy     #$02
        jsr     L7_C0A5

; ---- bank6.code_AD5C (code) $AD5C-$AD61, 6 bytes
        lda     $AD98,Y
        sta     $0548,X

; ---- bank6.code_AD62 (code) $AD62-$AD70, 15 bytes
        lda     $0530,X
        cmp     #$10
        ldy     #$0E
        bcc     L6_AD71
        cmp     #$F1
        ldy     #$0A
        bcc     L6_AD87

; ---- bank6.code_AD71 (code) $AD71-$AD73, 3 bytes
L6_AD71:
        inc     $0788,X

; ---- bank6.code_AD74 (code) $AD74-$AD77, 4 bytes
        tya
        jsr     L7_C102

; ---- bank6.code_AD78 (code) $AD78-$AD81, 10 bytes
        lda     #$5B
        sta     $0548,X
        lda     #$06
        jsr     L6_A1E7

; ---- bank6.code_AD82 (code) $AD82-$AD86, 5 bytes
L6_AD82:
        lda     #$30
        jsr     L6_9AF9

; ---- bank6.code_AD87 (code) $AD87-$AD89, 3 bytes
L6_AD87:
        jmp     L6_9F4F

; ---- bank6.tbl_AD8A (data) $AD8A-$AD8D, 4 bytes
; Type $42 palette by variant
        .byte   $03,$00,$01,$02

; ---- bank6.tbl_AD8E (data) $AD8E-$AD91, 4 bytes
; Type $42 fall speed by variant
        .byte   $00,$02,$01,$01

; ---- bank6.tbl_AD92 (data) $AD92-$AD95, 4 bytes
; Type $42 dash speed class by variant
        .byte   $02,$06,$03,$41

; ---- bank6.tbl_AD96 (data) $AD96-$AD97, 2 bytes
; Type $42 picture, state 0
        .byte   $5B,$5C

; ---- bank6.tbl_AD98 (data) $AD98-$AD99, 2 bytes
; Type $42 picture, state 1
        .byte   $59,$5A

; ---- bank6.code_AD9A (code) $AD9A-$ADA0, 7 bytes
L6_AD9A:
        inc     $6A
        lda     $6A
        and     #$01
        rts

; ---- bank6.code_ADA1 (code) $ADA1-$ADA5, 5 bytes
L6_ADA1:
        lda     $0500,X
        bmi     L6_ADE0

; ---- bank6.code_ADA6 (code) $ADA6-$ADAB, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_ADAC (code) $ADAC-$ADB4, 9 bytes
        ldy     #$00
        jsr     L6_AD9A
        beq     L6_ADB5
        ldy     #$02

; ---- bank6.code_ADB5 (code) $ADB5-$ADBA, 6 bytes
L6_ADB5:
        lda     $AE45,Y
        sta     $0530,X

; ---- bank6.code_ADBB (code) $ADBB-$ADC0, 6 bytes
        lda     $AE46,Y
        sta     $0788,X

; ---- bank6.code_ADC1 (code) $ADC1-$ADC5, 5 bytes
        lda     #$00
        sta     $0560,X

; ---- bank6.code_ADC6 (code) $ADC6-$ADC8, 3 bytes
        jsr     L6_AEE8

; ---- bank6.code_ADC9 (code) $ADC9-$ADCD, 5 bytes
        lda     #$03
        sta     $05D8,X

; ---- bank6.code_ADCE (code) $ADCE-$ADD2, 5 bytes
        lda     #$00
        sta     $07A0,X

; ---- bank6.code_ADD3 (code) $ADD3-$ADD5, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_ADD6 (code) $ADD6-$ADDA, 5 bytes
        lda     #$56
        sta     $0548,X

; ---- bank6.code_ADDB (code) $ADDB-$ADDF, 5 bytes
        lda     #$00
        sta     $0668,X

; ---- bank6.code_ADE0 (code) $ADE0-$ADE4, 5 bytes
L6_ADE0:
        lda     $07A0,X
        bne     L6_ADFF

; ---- bank6.code_ADE5 (code) $ADE5-$ADE9, 5 bytes
        lda     #$06
        jsr     L7_C09C

; ---- bank6.code_ADEA (code) $ADEA-$ADEE, 5 bytes
        lda     $05D8,X
        bne     L6_AE42

; ---- bank6.code_ADEF (code) $ADEF-$ADF1, 3 bytes
        inc     $07A0,X

; ---- bank6.code_ADF2 (code) $ADF2-$ADF7, 6 bytes
        lda     $0788,X
        sta     $0608,X

; ---- bank6.code_ADF8 (code) $ADF8-$ADFC, 5 bytes
        lda     #$40
        sta     $0668,X

; ---- bank6.code_ADFD (code) $ADFD-$ADFE, 2 bytes
        bne     L6_AE03

; ---- bank6.code_ADFF (code) $ADFF-$AE02, 4 bytes
L6_ADFF:
        cmp     #$01
        bne     L6_AE2E

; ---- bank6.code_AE03 (code) $AE03-$AE07, 5 bytes
L6_AE03:
        lda     #$20
        jsr     L7_C09C

; ---- bank6.code_AE08 (code) $AE08-$AE0E, 7 bytes
        lda     $0548,X
        cmp     #$58
        beq     L6_AE1C

; ---- bank6.code_AE0F (code) $AE0F-$AE15, 7 bytes
        lda     #$20
        ldy     #$03
        jsr     L7_C0A5

; ---- bank6.code_AE16 (code) $AE16-$AE1B, 6 bytes
        lda     $AE49,Y
        sta     $0548,X

; ---- bank6.code_AE1C (code) $AE1C-$AE22, 7 bytes
L6_AE1C:
        lda     $0518,X
        cmp     #$30
        bcs     L6_AE42

; ---- bank6.code_AE23 (code) $AE23-$AE25, 3 bytes
        inc     $07A0,X

; ---- bank6.code_AE26 (code) $AE26-$AE2A, 5 bytes
        lda     #$43
        sta     $0698,X

; ---- bank6.code_AE2B (code) $AE2B-$AE2D, 3 bytes
        jsr     L7_C0FC

; ---- bank6.code_AE2E (code) $AE2E-$AE34, 7 bytes
L6_AE2E:
        lda     $0548,X
        cmp     #$56
        beq     L6_AE42

; ---- bank6.code_AE35 (code) $AE35-$AE3B, 7 bytes
        lda     #$20
        ldy     #$03
        jsr     L7_C0A5

; ---- bank6.code_AE3C (code) $AE3C-$AE41, 6 bytes
        lda     $AE4B,Y
        sta     $0548,X

; ---- bank6.code_AE42 (code) $AE42-$AE44, 3 bytes
L6_AE42:
        jmp     L6_9F4F

; ---- bank6.tbl_AE45 (data) $AE45-$AE48, 4 bytes
; Type $43 start: 2 x [x][x speed]
        .byte   $28,$01,$D8,$FF

; ---- bank6.tbl_AE49 (data) $AE49-$AE4D, 5 bytes
; Type $43 picture sequences
        .byte   $56,$57,$58,$57,$56

; ---- bank6.code_AE4E (code) $AE4E-$AE52, 5 bytes
L6_AE4E:
        lda     $0500,X
        bmi     L6_AE8F

; ---- bank6.code_AE53 (code) $AE53-$AE58, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_AE59 (code) $AE59-$AE61, 9 bytes
        ldy     #$00
        jsr     L6_AD9A
        beq     L6_AE62
        ldy     #$02

; ---- bank6.code_AE62 (code) $AE62-$AE67, 6 bytes
L6_AE62:
        lda     $AEBB,Y
        sta     $0530,X

; ---- bank6.code_AE68 (code) $AE68-$AE6D, 6 bytes
        lda     $AEBC,Y
        sta     $0608,X

; ---- bank6.code_AE6E (code) $AE6E-$AE72, 5 bytes
        lda     #$01
        sta     $0560,X

; ---- bank6.code_AE73 (code) $AE73-$AE77, 5 bytes
        lda     #$5F
        sta     $0548,X

; ---- bank6.code_AE78 (code) $AE78-$AE7A, 3 bytes
        jsr     L6_AEE8

; ---- bank6.code_AE7B (code) $AE7B-$AE84, 10 bytes
        jsr     L7_C0EA
        and     #$7F
        adc     #$30
        sta     $0518,X

; ---- bank6.code_AE85 (code) $AE85-$AE89, 5 bytes
        lda     #$3C
        sta     $0788,X

; ---- bank6.code_AE8A (code) $AE8A-$AE8E, 5 bytes
        lda     #$00
        sta     $07A0,X

; ---- bank6.code_AE8F (code) $AE8F-$AE91, 3 bytes
L6_AE8F:
        jsr     L7_C009

; ---- bank6.code_AE92 (code) $AE92-$AE96, 5 bytes
        lda     $07A0,X
        bne     L6_AEB8

; ---- bank6.code_AE97 (code) $AE97-$AEA7, 17 bytes
        lda     $0530,X
        cmp     $0530
        lda     $0608,X
        bpl     L6_AEA6
        ror     A
        eor     #$80
        rol     A
L6_AEA6:
        bcc     L6_AEB8

; ---- bank6.code_AEA8 (code) $AEA8-$AEAA, 3 bytes
        inc     $07A0,X

; ---- bank6.code_AEAB (code) $AEAB-$AEAF, 5 bytes
        lda     #$5E
        sta     $0548,X

; ---- bank6.code_AEB0 (code) $AEB0-$AEB4, 5 bytes
        lda     #$81
        sta     $0698,X

; ---- bank6.code_AEB5 (code) $AEB5-$AEB7, 3 bytes
        jsr     L7_C0FC

; ---- bank6.code_AEB8 (code) $AEB8-$AEBA, 3 bytes
L6_AEB8:
        jmp     L6_9F4F

; ---- bank6.tbl_AEBB (data) $AEBB-$AEBE, 4 bytes
; Type $44 start: 2 x [x][x speed]
        .byte   $18,$01,$E8,$FF

; ---- bank6.code_AEBF (code) $AEBF-$AECE, 16 bytes
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

; ---- bank6.code_AECF (code) $AECF-$AEE7, 25 bytes
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

; ---- bank6.code_AEE8 (code) $AEE8-$AEF3, 12 bytes
L6_AEE8:
        lda     $50
        cmp     #$07
        bcc     L6_AEF3
        lda     #$02
        sta     $0560,X
L6_AEF3:
        rts

; ---- bank6.code_AEF4 (code) $AEF4-$AEF8, 5 bytes
L6_AEF4:
        lda     $0500,X
        bmi     L6_AF12

; ---- bank6.code_AEF9 (code) $AEF9-$AEFE, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_AEFF (code) $AEFF-$AF03, 5 bytes
        lda     #$6B
        sta     $0548,X

; ---- bank6.code_AF04 (code) $AF04-$AF0B, 8 bytes
        lda     #$02
        sta     $0560,X
        sta     $0668,X

; ---- bank6.code_AF0C (code) $AF0C-$AF0E, 3 bytes
        jsr     L6_AF39

; ---- bank6.code_AF0F (code) $AF0F-$AF11, 3 bytes
        jsr     L6_AEE8

; ---- bank6.code_AF12 (code) $AF12-$AF16, 5 bytes
L6_AF12:
        lda     #$06
        jsr     L7_C09C

; ---- bank6.code_AF17 (code) $AF17-$AF1B, 5 bytes
        lda     #$0C
        jsr     L7_C09F

; ---- bank6.code_AF1C (code) $AF1C-$AF21, 6 bytes
        lda     #$0F
        and     $41
        bne     L6_AF32

; ---- bank6.code_AF22 (code) $AF22-$AF26, 5 bytes
        jsr     L7_C0FF
        sta     $15

; ---- bank6.code_AF27 (code) $AF27-$AF2B, 5 bytes
        jsr     L7_C108
        bcs     L6_AF32

; ---- bank6.code_AF2C (code) $AF2C-$AF31, 6 bytes
        jsr     L6_AC9F
        jsr     L6_ACCA

; ---- bank6.code_AF32 (code) $AF32-$AF34, 3 bytes
L6_AF32:
        jmp     L6_9F4F

; ---- bank6.tbl_AF35 (data) $AF35-$AF38, 4 bytes
; Side start: 2 x [x][x speed]
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

; ---- bank6.code_AF57 (code) $AF57-$AF6C, 22 bytes
L6_AF57:
        ldy     $0530,X
        lda     $0608,X
        bmi     L6_AF65
        cpy     #$F0
        bcc     L6_AF6C
        bcs     L6_AF69
L6_AF65:
        cpy     #$10
        bcs     L6_AF6C
L6_AF69:
        jmp     L7_C123
L6_AF6C:
        rts

; ---- bank6.code_AF6D (code) $AF6D-$AF81, 21 bytes
L6_AF6D:
        ldy     $0518,X
        lda     $05D8,X
        bmi     L6_AF7B
        cpy     #$B8
        bcc     L6_AF6C
        bcs     L6_AF7F
L6_AF7B:
        cpy     #$10
        bcs     L6_AF6C
L6_AF7F:
        jmp     L7_C126

; ---- bank6.code_AF82 (code) $AF82-$AF86, 5 bytes
L6_AF82:
        lda     $0500,X
        bmi     L6_AFC7

; ---- bank6.code_AF87 (code) $AF87-$AF8C, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_AF8D (code) $AF8D-$AF91, 5 bytes
        lda     #$06
        sta     $0698,X

; ---- bank6.code_AF92 (code) $AF92-$AF96, 5 bytes
        lda     #$1A
        sta     $0548,X

; ---- bank6.code_AF97 (code) $AF97-$AFA6, 16 bytes
        lda     #$00
        sta     $0560,X
        lda     $50
        cmp     #$05
        bcc     L6_AFA7
        lda     #$03
        sta     $0560,X

; ---- bank6.code_AFA7 (code) $AFA7-$AFAF, 9 bytes
L6_AFA7:
        ldy     #$00
        jsr     L6_AD9A
        beq     L6_AFB0
        ldy     #$02

; ---- bank6.code_AFB0 (code) $AFB0-$AFB5, 6 bytes
L6_AFB0:
        lda     $B022,Y
        sta     $0530,X

; ---- bank6.code_AFB6 (code) $AFB6-$AFBB, 6 bytes
        lda     $B023,Y
        jsr     L7_C102

; ---- bank6.code_AFBC (code) $AFBC-$AFC1, 6 bytes
        jsr     L7_C0EA
        sta     $07B8,X

; ---- bank6.code_AFC2 (code) $AFC2-$AFC6, 5 bytes
        lda     #$FF
        sta     $07A0,X

; ---- bank6.code_AFC7 (code) $AFC7-$AFCB, 5 bytes
L6_AFC7:
        lda     $07A0,X
        bpl     L6_AFF2

; ---- bank6.code_AFCC (code) $AFCC-$AFDF, 20 bytes
        lda     $0530,X
        ldy     $0608,X
        bmi     L6_AFDB
        cmp     $07B8,X
        bcs     L6_AFE0
        bcc     L6_B01F
L6_AFDB:
        cmp     $07B8,X
        bcs     L6_B01F

; ---- bank6.code_AFE0 (code) $AFE0-$AFE4, 5 bytes
L6_AFE0:
        lda     #$66
        sta     $0548,X

; ---- bank6.code_AFE5 (code) $AFE5-$AFEE, 10 bytes
        jsr     L7_C0EA
        and     #$3F
        adc     #$08
        sta     $07B8,X

; ---- bank6.code_AFEF (code) $AFEF-$AFF1, 3 bytes
        inc     $07A0,X

; ---- bank6.code_AFF2 (code) $AFF2-$AFF3, 2 bytes
L6_AFF2:
        bne     L6_B01F

; ---- bank6.code_AFF4 (code) $AFF4-$AFF8, 5 bytes
        jsr     L7_C12C
        bcc     L6_AFFC

; ---- bank6.code_AFF9 (code) $AFF9-$AFFB, 3 bytes
        jmp     L6_9B17

; ---- bank6.code_AFFC (code) $AFFC-$B000, 5 bytes
L6_AFFC:
        dec     $07B8,X
        beq     L6_B00A

; ---- bank6.code_B001 (code) $B001-$B009, 9 bytes
        jsr     L7_C090
        jsr     L7_C0CF
        jmp     L7_C0D2

; ---- bank6.code_B00A (code) $B00A-$B012, 9 bytes
L6_B00A:
        ldy     #$0E
        lda     $0530,X
        bpl     L6_B013
        ldy     #$0A

; ---- bank6.code_B013 (code) $B013-$B016, 4 bytes
L6_B013:
        tya
        jsr     L7_C102

; ---- bank6.code_B017 (code) $B017-$B019, 3 bytes
        inc     $07A0,X

; ---- bank6.code_B01A (code) $B01A-$B01E, 5 bytes
        lda     #$1A
        sta     $0548,X

; ---- bank6.code_B01F (code) $B01F-$B021, 3 bytes
L6_B01F:
        jmp     L6_9F4F

; ---- bank6.tbl_B022 (data) $B022-$B025, 4 bytes
; Type $63 start: 2 x [x][direction]
        .byte   $08,$02,$F8,$06

; ---- bank6.code_B026 (code) $B026-$B02A, 5 bytes
L6_B026:
        lda     $0500,X
        bmi     L6_B058

; ---- bank6.code_B02B (code) $B02B-$B030, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_B031 (code) $B031-$B035, 5 bytes
        lda     #$60
        sta     $0548,X

; ---- bank6.code_B036 (code) $B036-$B038, 3 bytes
        jsr     L7_C0F0

; ---- bank6.code_B039 (code) $B039-$B048, 16 bytes
        ldy     #$F0
        lda     $0530,X
        bmi     L6_B042
        ldy     #$10
L6_B042:
        tya
        adc     $0530,X
        sta     $0680,X

; ---- bank6.code_B049 (code) $B049-$B04D, 5 bytes
        lda     #$03
        sta     $0560,X

; ---- bank6.code_B04E (code) $B04E-$B052, 5 bytes
        lda     #$01
        sta     $05D8,X

; ---- bank6.code_B053 (code) $B053-$B057, 5 bytes
        lda     #$3C
        sta     $0788,X

; ---- bank6.code_B058 (code) $B058-$B05A, 3 bytes
L6_B058:
        jsr     L7_C009

; ---- bank6.code_B05B (code) $B05B-$B05F, 5 bytes
        lda     #$40
        jsr     L7_C09F

; ---- bank6.code_B060 (code) $B060-$B064, 5 bytes
        lda     #$07
        jsr     L6_9B09

; ---- bank6.code_B065 (code) $B065-$B06A, 6 bytes
        lda     #$0F
        and     $41
        bne     L6_B084

; ---- bank6.code_B06B (code) $B06B-$B06F, 5 bytes
        jsr     L7_C108
        bcs     L6_B084

; ---- bank6.code_B070 (code) $B070-$B074, 5 bytes
        lda     #$0C
        jsr     L7_C105

; ---- bank6.code_B075 (code) $B075-$B083, 15 bytes
        lda     $0530,X
        cmp     $0530
        lda     #$00
        bcc     L6_B081
        lda     #$08
L6_B081:
        sta     $0788,Y

; ---- bank6.code_B084 (code) $B084-$B086, 3 bytes
L6_B084:
        jmp     L6_9F4F

; ---- bank6.code_B087 (code) $B087-$B089, 3 bytes
L6_B087:
        jsr     L6_BA51

; ---- bank6.code_B08A (code) $B08A-$B08E, 5 bytes
        lda     $0500,X
        bmi     L6_B09A

; ---- bank6.code_B08F (code) $B08F-$B094, 6 bytes
        jsr     L7_C0AE
        jsr     L7_C0A2

; ---- bank6.code_B095 (code) $B095-$B099, 5 bytes
        lda     #$31
        sta     $0548,X

; ---- bank6.code_B09A (code) $B09A-$B0A0, 7 bytes
L6_B09A:
        lda     #$20
        ldy     #$04
        jsr     L7_C0A5

; ---- bank6.code_B0A1 (code) $B0A1-$B0A2, 2 bytes
        bcc     L6_B0B0

; ---- bank6.code_B0A3 (code) $B0A3-$B0A7, 5 bytes
        jsr     L7_C108
        bcs     L6_B0B0

; ---- bank6.code_B0A8 (code) $B0A8-$B0AC, 5 bytes
        lda     #$2B
        jsr     L7_C105

; ---- bank6.code_B0AD (code) $B0AD-$B0AF, 3 bytes
        jsr     L6_AA12

; ---- bank6.code_B0B0 (code) $B0B0-$B0B6, 7 bytes
L6_B0B0:
        lda     $0650,X
        cmp     #$20
        bcs     L6_B0C2

; ---- bank6.code_B0B7 (code) $B0B7-$B0C1, 11 bytes
        ldy     $0638,X
        lda     $B0D5,Y
        ldy     #$AA
        jsr     L6_AA21

; ---- bank6.code_B0C2 (code) $B0C2-$B0C4, 3 bytes
L6_B0C2:
        jsr     L7_C0CF

; ---- bank6.code_B0C5 (code) $B0C5-$B0C7, 3 bytes
        jsr     L7_C0D2

; ---- bank6.code_B0C8 (code) $B0C8-$B0CC, 5 bytes
        lda     $0500,X
        bmi     L6_B0D4

; ---- bank6.code_B0CD (code) $B0CD-$B0D3, 7 bytes
        ldy     #$FF
        lda     #$45
        jmp     L6_AA21

; ---- bank6.code_B0D4 (code) $B0D4-$B0D4, 1 bytes
L6_B0D4:
        rts

; ---- bank6.tbl_B0D5 (data) $B0D5-$B0D8, 4 bytes
; Type $3B first tile by phase
        .byte   $39,$3D,$41,$3D

; ---- bank6.code_B0D9 (code) $B0D9-$B0DD, 5 bytes
L6_B0D9:
        lda     $0500,X
        bmi     L6_B0EF

; ---- bank6.code_B0DE (code) $B0DE-$B0E3, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_B0E4 (code) $B0E4-$B0E6, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_B0E7 (code) $B0E7-$B0EB, 5 bytes
        lda     #$01
        sta     $0560,X

; ---- bank6.code_B0EC (code) $B0EC-$B0EE, 3 bytes
        jsr     L6_AF39

; ---- bank6.code_B0EF (code) $B0EF-$B0F3, 5 bytes
L6_B0EF:
        lda     #$10
        jsr     L7_C09F

; ---- bank6.code_B0F4 (code) $B0F4-$B101, 14 bytes
        lda     $0638,X
        cmp     #$02
        bne     L6_B105
        lda     $0650,X
        cmp     #$08
        bcs     L6_B105

; ---- bank6.code_B102 (code) $B102-$B104, 3 bytes
        jsr     L7_C126

; ---- bank6.code_B105 (code) $B105-$B106, 2 bytes
L6_B105:
        lda     #$08

; ---- bank6.code_B107 (code) $B107-$B10B, 5 bytes
L6_B107:
        ldy     #$04
        jsr     L7_C0A5

; ---- bank6.code_B10C (code) $B10C-$B111, 6 bytes
        lda     $B11B,Y
        sta     $0548,X

; ---- bank6.code_B112 (code) $B112-$B117, 6 bytes
        lda     $B11F,Y
        jsr     L6_A1E7

; ---- bank6.code_B118 (code) $B118-$B11A, 3 bytes
L6_B118:
        jmp     L6_9F4F

; ---- bank6.tbl_B11B (data) $B11B-$B11E, 4 bytes
; Types $59 / $60 metasprite by phase
        .byte   $54,$54,$55,$54

; ---- bank6.tbl_B11F (data) $B11F-$B122, 4 bytes
; Types $59 / $60 tile offset by phase
        .byte   $00,$0A,$00,$0A

; ---- bank6.code_B123 (code) $B123-$B127, 5 bytes
L6_B123:
        lda     $0500,X
        bmi     L6_B148

; ---- bank6.code_B128 (code) $B128-$B12D, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_B12E (code) $B12E-$B130, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_B131 (code) $B131-$B135, 5 bytes
        lda     #$80
        sta     $0530,X

; ---- bank6.code_B136 (code) $B136-$B13A, 5 bytes
        lda     #$03
        sta     $05D8,X

; ---- bank6.code_B13B (code) $B13B-$B13F, 5 bytes
        lda     #$54
        sta     $0548,X

; ---- bank6.code_B140 (code) $B140-$B147, 8 bytes
        lda     #$00
        sta     $0560,X
        sta     $0668,X

; ---- bank6.code_B148 (code) $B148-$B14C, 5 bytes
L6_B148:
        lda     #$0A
        jsr     L7_C09C

; ---- bank6.code_B14D (code) $B14D-$B152, 6 bytes
        lda     #$0F
        and     $41
        bne     L6_B15B

; ---- bank6.code_B153 (code) $B153-$B157, 5 bytes
        jsr     L7_C108
        bcs     L6_B15B

; ---- bank6.code_B158 (code) $B158-$B15A, 3 bytes
        jsr     L6_BF61

; ---- bank6.code_B15B (code) $B15B-$B15F, 5 bytes
L6_B15B:
        lda     $05D8,X
        bpl     L6_B118

; ---- bank6.code_B160 (code) $B160-$B166, 7 bytes
        lda     $0638,X
        cmp     #$02
        beq     L6_B118

; ---- bank6.code_B167 (code) $B167-$B16A, 4 bytes
        lda     #$18
        bne     L6_B107

; ---- bank6.code_B16B (code) $B16B-$B16F, 5 bytes
L6_B16B:
        lda     $0500,X
        bmi     L6_B1B3

; ---- bank6.code_B170 (code) $B170-$B175, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_B176 (code) $B176-$B17A, 5 bytes
        lda     #$05
        sta     $0698,X

; ---- bank6.code_B17B (code) $B17B-$B17F, 5 bytes
        lda     $0728,X
        beq     L6_B19B

; ---- bank6.code_B180 (code) $B180-$B182, 3 bytes
        jsr     L7_C102

; ---- bank6.code_B183 (code) $B183-$B18E, 12 bytes
        lda     $0518,X
        sta     $0668,X
        lda     $0530,X
        sta     $0680,X

; ---- bank6.code_B18F (code) $B18F-$B193, 5 bytes
        lda     #$1E
        sta     $0788,X

; ---- bank6.code_B194 (code) $B194-$B198, 5 bytes
        lda     #$00
        sta     $07A0,X

; ---- bank6.code_B199 (code) $B199-$B19A, 2 bytes
        beq     L6_B1A6

; ---- bank6.code_B19B (code) $B19B-$B19D, 3 bytes
L6_B19B:
        jsr     L7_C0F3

; ---- bank6.code_B19E (code) $B19E-$B1A5, 8 bytes
        lda     #$18
        sta     $0788,X
        sta     $07A0,X

; ---- bank6.code_B1A6 (code) $B1A6-$B1A8, 3 bytes
L6_B1A6:
        jsr     L7_C0A2

; ---- bank6.code_B1A9 (code) $B1A9-$B1AD, 5 bytes
        lda     #$02
        sta     $0560,X

; ---- bank6.code_B1AE (code) $B1AE-$B1B2, 5 bytes
        lda     #$3C
        sta     $0548,X

; ---- bank6.code_B1B3 (code) $B1B3-$B1B7, 5 bytes
L6_B1B3:
        lda     $07A0,X
        bne     L6_B1D5

; ---- bank6.code_B1B8 (code) $B1B8-$B1BC, 5 bytes
        lda     $0788,X
        beq     L6_B1D5

; ---- bank6.code_B1BD (code) $B1BD-$B1C1, 5 bytes
        dec     $0788,X
        bne     L6_B1C8

; ---- bank6.code_B1C2 (code) $B1C2-$B1C7, 6 bytes
        jsr     L7_C147
        jmp     L6_B1D5

; ---- bank6.code_B1C8 (code) $B1C8-$B1D1, 10 bytes
L6_B1C8:
        lda     #$0C
        jsr     L7_C09C
        lda     #$0C
        jsr     L7_C09F

; ---- bank6.code_B1D2 (code) $B1D2-$B1D4, 3 bytes
        jmp     L6_B224

; ---- bank6.code_B1D5 (code) $B1D5-$B1D7, 3 bytes
L6_B1D5:
        jsr     L7_C009

; ---- bank6.code_B1D8 (code) $B1D8-$B1DE, 7 bytes
        lda     #$08
        ldy     #$04
        jsr     L7_C0A5

; ---- bank6.code_B1DF (code) $B1DF-$B1E4, 6 bytes
        lda     $B232,Y
        sta     $0560,X

; ---- bank6.code_B1E5 (code) $B1E5-$B1E6, 2 bytes
        bcc     L6_B214

; ---- bank6.code_B1E7 (code) $B1E7-$B1E9, 3 bytes
        jsr     L7_C0FF

; ---- bank6.code_B1EA (code) $B1EA-$B1EF, 6 bytes
        and     #$0E
        ora     #$80
        sta     $15

; ---- bank6.code_B1F0 (code) $B1F0-$B1F3, 4 bytes
        lda     #$07
        sta     $14

; ---- bank6.code_B1F4 (code) $B1F4-$B1F8, 5 bytes
L6_B1F4:
        jsr     L7_C108
        bcs     L6_B210

; ---- bank6.code_B1F9 (code) $B1F9-$B1FD, 5 bytes
L6_B1F9:
        lda     #$6F
        jsr     L7_C105

; ---- bank6.code_B1FE (code) $B1FE-$B202, 5 bytes
        lda     $15
        sta     $0728,Y

; ---- bank6.code_B203 (code) $B203-$B208, 6 bytes
        dec     $15
        dec     $15
        dec     $14

; ---- bank6.code_B209 (code) $B209-$B20A, 2 bytes
        beq     L6_B210

; ---- bank6.code_B20B (code) $B20B-$B20C, 2 bytes
        bpl     L6_B1F4

; ---- bank6.code_B20D (code) $B20D-$B20F, 3 bytes
        jmp     L7_C048

; ---- bank6.code_B210 (code) $B210-$B211, 2 bytes
L6_B210:
        txa
        tay

; ---- bank6.code_B212 (code) $B212-$B213, 2 bytes
        bne     L6_B1F9

; ---- bank6.code_B214 (code) $B214-$B217, 4 bytes
L6_B214:
        cmp     #$02
        bne     L6_B224

; ---- bank6.code_B218 (code) $B218-$B21D, 6 bytes
        lda     $41
        and     #$07
        bne     L6_B224

; ---- bank6.code_B21E (code) $B21E-$B223, 6 bytes
        jsr     L6_A325
        jsr     L6_A337

; ---- bank6.code_B224 (code) $B224-$B22E, 11 bytes
L6_B224:
        lda     $41
        and     #$04
        lsr     A
        lsr     A
        adc     #$3B
        sta     $0548,X

; ---- bank6.code_B22F (code) $B22F-$B231, 3 bytes
        jmp     L6_9F4F

; ---- bank6.tbl_B232 (data) $B232-$B235, 4 bytes
; Type $6F palette by phase
        .byte   $02,$02,$01,$00

; ---- bank6.code_B236 (code) $B236-$B23A, 5 bytes
L6_B236:
        lda     $0500,X
        bmi     L6_B25C

; ---- bank6.code_B23B (code) $B23B-$B23D, 3 bytes
        jsr     L7_C0A8

; ---- bank6.code_B23E (code) $B23E-$B247, 10 bytes
        jsr     L7_C0EA
        and     #$3F
        adc     #$50
        sta     $0530,X

; ---- bank6.code_B248 (code) $B248-$B24C, 5 bytes
        lda     #$60
        sta     $0518,X

; ---- bank6.code_B24D (code) $B24D-$B251, 5 bytes
        lda     #$03
        sta     $0560,X

; ---- bank6.code_B252 (code) $B252-$B256, 5 bytes
        lda     #$50
        sta     $0548,X

; ---- bank6.code_B257 (code) $B257-$B25B, 5 bytes
        lda     #$3C
        sta     $0788,X

; ---- bank6.code_B25C (code) $B25C-$B25E, 3 bytes
L6_B25C:
        jsr     L7_C009

; ---- bank6.code_B25F (code) $B25F-$B263, 5 bytes
        lda     #$03
        jsr     L6_9B09

; ---- bank6.code_B264 (code) $B264-$B269, 6 bytes
        lda     #$0F
        and     $41
        bne     L6_B27C

; ---- bank6.code_B26A (code) $B26A-$B26E, 5 bytes
        jsr     L7_C0FF
        sta     $15

; ---- bank6.code_B26F (code) $B26F-$B273, 5 bytes
        jsr     L7_C108
        bcs     L6_B27C

; ---- bank6.code_B274 (code) $B274-$B276, 3 bytes
        jsr     L6_AC9F

; ---- bank6.code_B277 (code) $B277-$B27B, 5 bytes
        lda     #$F0
        jsr     L6_AECF

; ---- bank6.code_B27C (code) $B27C-$B287, 12 bytes
L6_B27C:
        lda     $41
        and     #$01
        bne     L6_B288
        jsr     L6_A325
        jsr     L6_A337

; ---- bank6.code_B288 (code) $B288-$B28A, 3 bytes
L6_B288:
        jmp     L6_9F4F

; ---- bank6.code_B28B (code) $B28B-$B28F, 5 bytes
L6_B28B:
        lda     $0500,X
        bmi     L6_B2BA

; ---- bank6.code_B290 (code) $B290-$B295, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_B296 (code) $B296-$B2A2, 13 bytes
        ldy     #$20
        jsr     L6_AD9A
        beq     L6_B29F
        ldy     #$E0
L6_B29F:
        tya
        sta     $0530,X

; ---- bank6.code_B2A3 (code) $B2A3-$B2A7, 5 bytes
        lda     #$40
        sta     $05C0,X

; ---- bank6.code_B2A8 (code) $B2A8-$B2AC, 5 bytes
        lda     #$80
        sta     $0680,X

; ---- bank6.code_B2AD (code) $B2AD-$B2B1, 5 bytes
        lda     #$00
        sta     $0560,X

; ---- bank6.code_B2B2 (code) $B2B2-$B2B4, 3 bytes
        jsr     L6_AEE8

; ---- bank6.code_B2B5 (code) $B2B5-$B2B9, 5 bytes
        lda     #$73
        sta     $0548,X

; ---- bank6.code_B2BA (code) $B2BA-$B2BE, 5 bytes
L6_B2BA:
        lda     #$80
        jsr     L7_C09F

; ---- bank6.code_B2BF (code) $B2BF-$B2C1, 3 bytes
        jmp     L6_9F4F

; ---- bank6.code_B2C2 (code) $B2C2-$B2C6, 5 bytes
L6_B2C2:
        lda     $0500,X
        bmi     L6_B2DD

; ---- bank6.code_B2C7 (code) $B2C7-$B2CC, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_B2CD (code) $B2CD-$B2CF, 3 bytes
        jsr     L7_C0F0

; ---- bank6.code_B2D0 (code) $B2D0-$B2D4, 5 bytes
        lda     #$00
        sta     $0560,X

; ---- bank6.code_B2D5 (code) $B2D5-$B2D7, 3 bytes
        jsr     L6_AEE8

; ---- bank6.code_B2D8 (code) $B2D8-$B2DC, 5 bytes
        lda     #$FF
        sta     $0668,X

; ---- bank6.code_B2DD (code) $B2DD-$B2DF, 3 bytes
L6_B2DD:
        jsr     L6_A325

; ---- bank6.code_B2E0 (code) $B2E0-$B2E4, 5 bytes
        lda     #$10
        jsr     L7_C09C

; ---- bank6.code_B2E5 (code) $B2E5-$B2F0, 12 bytes
        ldy     #$74
        lda     $05D8,X
        bpl     L6_B2ED
        iny
L6_B2ED:
        tya
        sta     $0548,X

; ---- bank6.code_B2F1 (code) $B2F1-$B2FB, 11 bytes
        lda     $0518,X
        cmp     #$A0
        bcc     L6_B315
        cpy     #$74
        bne     L6_B315

; ---- bank6.code_B2FC (code) $B2FC-$B300, 5 bytes
        lda     #$FC
        sta     $05D8,X

; ---- bank6.code_B301 (code) $B301-$B305, 5 bytes
        jsr     L7_C108
        bcs     L6_B315

; ---- bank6.code_B306 (code) $B306-$B30A, 5 bytes
        lda     #$27
        jsr     L7_C105

; ---- bank6.code_B30B (code) $B30B-$B30F, 5 bytes
        lda     #$07
        sta     $07A0,Y

; ---- bank6.code_B310 (code) $B310-$B314, 5 bytes
        lda     #$0C
        sta     $0788,Y

; ---- bank6.code_B315 (code) $B315-$B317, 3 bytes
L6_B315:
        jmp     L6_9F4F

; ---- bank6.code_B318 (code) $B318-$B31C, 5 bytes
L6_B318:
        lda     $0500,X
        bmi     L6_B33F

; ---- bank6.code_B31D (code) $B31D-$B322, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_B323 (code) $B323-$B327, 5 bytes
        lda     #$6C
        sta     $0548,X

; ---- bank6.code_B328 (code) $B328-$B32A, 3 bytes
        jsr     L6_AF39

; ---- bank6.code_B32B (code) $B32B-$B32F, 5 bytes
        lda     #$00
        sta     $0560,X

; ---- bank6.code_B330 (code) $B330-$B334, 5 bytes
        lda     #$5A
        sta     $07A0,X

; ---- bank6.code_B335 (code) $B335-$B339, 5 bytes
        lda     #$01
        sta     $05D8,X

; ---- bank6.code_B33A (code) $B33A-$B33E, 5 bytes
        lda     #$10
        sta     $07B8,X

; ---- bank6.code_B33F (code) $B33F-$B343, 5 bytes
L6_B33F:
        lda     #$10
        jsr     L7_C09F

; ---- bank6.code_B344 (code) $B344-$B348, 5 bytes
        lda     $07A0,X
        beq     L6_B35B

; ---- bank6.code_B349 (code) $B349-$B34D, 5 bytes
        dec     $07A0,X
        bne     L6_B35B

; ---- bank6.code_B34E (code) $B34E-$B355, 8 bytes
        lda     $0680,X
        eor     #$F8
        sta     $0680,X

; ---- bank6.code_B356 (code) $B356-$B35A, 5 bytes
        lda     #$FF
        sta     $05D8,X

; ---- bank6.code_B35B (code) $B35B-$B35F, 5 bytes
L6_B35B:
        dec     $07B8,X
        bne     L6_B38D

; ---- bank6.code_B360 (code) $B360-$B364, 5 bytes
        lda     #$10
        sta     $07B8,X

; ---- bank6.code_B365 (code) $B365-$B369, 5 bytes
        jsr     L7_C108
        bcs     L6_B38D

; ---- bank6.code_B36A (code) $B36A-$B37C, 19 bytes
        lda     #$02
        sta     $16
        lda     $07E8,X
        adc     #$14
        sta     $17
        jsr     L7_C13E
        lda     #$09
        jsr     L7_C13B

; ---- bank6.code_B37D (code) $B37D-$B387, 11 bytes
        lda     #$FF
        sta     $0668,Y
        lda     $05A8,X
        sta     $05A8,Y

; ---- bank6.code_B388 (code) $B388-$B38C, 5 bytes
        lda     #$06
        sta     $0590,X

; ---- bank6.code_B38D (code) $B38D-$B38F, 3 bytes
L6_B38D:
        jmp     L6_9F4F

; ---- bank6.code_B390 (code) $B390-$B394, 5 bytes
L6_B390:
        lda     $0500,X
        bmi     L6_B3B0

; ---- bank6.code_B395 (code) $B395-$B39A, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_B39B (code) $B39B-$B39D, 3 bytes
        jsr     L7_C0F3

; ---- bank6.code_B39E (code) $B39E-$B3A2, 5 bytes
        lda     #$00
        sta     $0560,X

; ---- bank6.code_B3A3 (code) $B3A3-$B3A5, 3 bytes
        jsr     L6_AEE8

; ---- bank6.code_B3A6 (code) $B3A6-$B3AA, 5 bytes
        lda     #$50
        sta     $0548,X

; ---- bank6.code_B3AB (code) $B3AB-$B3AF, 5 bytes
        lda     #$3C
        sta     $0788,X

; ---- bank6.code_B3B0 (code) $B3B0-$B3B2, 3 bytes
L6_B3B0:
        jsr     L7_C009

; ---- bank6.code_B3B3 (code) $B3B3-$B3B7, 5 bytes
        lda     #$07
        jsr     L6_9B09

; ---- bank6.code_B3B8 (code) $B3B8-$B3C3, 12 bytes
        lda     $41
        and     #$03
        bne     L6_B3C4
        jsr     L6_A337
        jsr     L6_A325

; ---- bank6.code_B3C4 (code) $B3C4-$B3C6, 3 bytes
L6_B3C4:
        jmp     L6_9F4F

; ---- bank6.code_B3C7 (code) $B3C7-$B3C9, 3 bytes
L6_B3C7:
        jsr     L6_BA51

; ---- bank6.code_B3CA (code) $B3CA-$B3CE, 5 bytes
        lda     $0500,X
        bmi     L6_B3E8

; ---- bank6.code_B3CF (code) $B3CF-$B3D1, 3 bytes
        jsr     L7_C0AE

; ---- bank6.code_B3D2 (code) $B3D2-$B3DC, 11 bytes
        lda     #$00
        sta     $07A0,X
        sta     $15
        lda     #$FE
        sta     $14

; ---- bank6.code_B3DD (code) $B3DD-$B3DF, 3 bytes
        jsr     L6_BBA3

; ---- bank6.code_B3E0 (code) $B3E0-$B3E4, 5 bytes
        lda     #$31
        sta     $0548,X

; ---- bank6.code_B3E5 (code) $B3E5-$B3E7, 3 bytes
        jsr     L7_C0A2

; ---- bank6.code_B3E8 (code) $B3E8-$B3EE, 7 bytes
L6_B3E8:
        lda     $0518,X
        cmp     #$10
        bcs     L6_B3F0

; ---- bank6.code_B3EF (code) $B3EF-$B3EF, 1 bytes
        rts

; ---- bank6.code_B3F0 (code) $B3F0-$B3F4, 5 bytes
L6_B3F0:
        lda     $07A0,X
        bne     L6_B3FF

; ---- bank6.code_B3F5 (code) $B3F5-$B3F7, 3 bytes
        inc     $07A0,X

; ---- bank6.code_B3F8 (code) $B3F8-$B3FE, 7 bytes
        ldy     #$55
        lda     #$49
        jsr     L6_AA21

; ---- bank6.code_B3FF (code) $B3FF-$B405, 7 bytes
L6_B3FF:
        lda     #$10
        ldy     #$02
        jsr     L7_C0A5

; ---- bank6.code_B406 (code) $B406-$B407, 2 bytes
        bcs     L6_B415

; ---- bank6.code_B408 (code) $B408-$B40E, 7 bytes
        lda     $0650,X
        cmp     #$10
        bcs     L6_B41C

; ---- bank6.code_B40F (code) $B40F-$B414, 6 bytes
        lda     #$B4
        ldy     #$60
        bcc     L6_B419

; ---- bank6.code_B415 (code) $B415-$B418, 4 bytes
L6_B415:
        lda     #$B4
        ldy     #$58

; ---- bank6.code_B419 (code) $B419-$B41B, 3 bytes
L6_B419:
        jsr     L6_B43F

; ---- bank6.code_B41C (code) $B41C-$B420, 5 bytes
L6_B41C:
        lda     $0638,X
        beq     L6_B42F

; ---- bank6.code_B421 (code) $B421-$B426, 6 bytes
        lda     $41
        and     #$07
        bne     L6_B42F

; ---- bank6.code_B427 (code) $B427-$B42B, 5 bytes
        jsr     L7_C108
        bcs     L6_B42F

; ---- bank6.code_B42C (code) $B42C-$B42E, 3 bytes
        jsr     L6_BF61

; ---- bank6.code_B42F (code) $B42F-$B431, 3 bytes
L6_B42F:
        jsr     L7_C0CF

; ---- bank6.code_B432 (code) $B432-$B434, 3 bytes
        jsr     L7_C0D2

; ---- bank6.code_B435 (code) $B435-$B439, 5 bytes
        lda     $0500,X
        bpl     L6_B43B

; ---- bank6.code_B43A (code) $B43A-$B43A, 1 bytes
        rts

; ---- bank6.code_B43B (code) $B43B-$B43E, 4 bytes
L6_B43B:
        lda     #$B4
        ldy     #$54

; ---- bank6.code_B43F (code) $B43F-$B453, 21 bytes
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

; ---- bank6.tbl_B454 (data) $B454-$B467, 20 bytes
; Type $3C tile blocks (2 x 4, overlapping)
        .byte   $FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$E0,$E1,$F0,$F1,$FD,$FD,$B0,$B1
        .byte   $C0,$C1,$D0,$D1

; ---- bank6.tbl_B468 (data) $B468-$B477, 16 bytes
; Tile blocks of the next two handlers
        .byte   $72,$8C,$73,$8D,$74,$8E,$75,$8F,$68,$82,$6B,$85,$6E,$88,$71,$8B

; ---- bank6.code_B478 (code) $B478-$B481, 10 bytes
L6_B478:
        lda     $0500,X
        bpl     L6_B482
        lda     $07A0,X
        bne     L6_B4D5

; ---- bank6.code_B482 (code) $B482-$B484, 3 bytes
L6_B482:
        jsr     L6_BA51

; ---- bank6.code_B485 (code) $B485-$B489, 5 bytes
        lda     $0500,X
        bmi     L6_B4B0

; ---- bank6.code_B48A (code) $B48A-$B48F, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C0A2

; ---- bank6.code_B490 (code) $B490-$B494, 5 bytes
        lda     #$19
        sta     $0548,X

; ---- bank6.code_B495 (code) $B495-$B49D, 9 bytes
        lda     $0518,X
        clc
        adc     #$04
        sta     $0518,X

; ---- bank6.code_B49E (code) $B49E-$B4A5, 8 bytes
        lda     #$00
        sta     $0560,X
        sta     $07A0,X

; ---- bank6.code_B4A6 (code) $B4A6-$B4AF, 10 bytes
        jsr     L7_C0EA
        and     #$7F
        adc     #$30
        sta     $0788,X

; ---- bank6.code_B4B0 (code) $B4B0-$B4B7, 8 bytes
L6_B4B0:
        lda     $0518,X
        cmp     $0788,X
        bcc     L6_B4C9

; ---- bank6.code_B4B8 (code) $B4B8-$B4BA, 3 bytes
        inc     $07A0,X

; ---- bank6.code_B4BB (code) $B4BB-$B4BD, 3 bytes
        inc     $0560,X

; ---- bank6.code_B4BE (code) $B4BE-$B4C2, 5 bytes
        lda     #$05
        sta     $0698,X

; ---- bank6.code_B4C3 (code) $B4C3-$B4C5, 3 bytes
        jsr     L7_C0FC

; ---- bank6.code_B4C6 (code) $B4C6-$B4C8, 3 bytes
        jmp     L6_B4D5

; ---- bank6.code_B4C9 (code) $B4C9-$B4CB, 3 bytes
L6_B4C9:
        jsr     L6_B4DB

; ---- bank6.code_B4CC (code) $B4CC-$B4CE, 3 bytes
        jsr     L7_C090

; ---- bank6.code_B4CF (code) $B4CF-$B4D1, 3 bytes
        jsr     L7_C0CF

; ---- bank6.code_B4D2 (code) $B4D2-$B4D4, 3 bytes
        jmp     L7_C0D2

; ---- bank6.code_B4D5 (code) $B4D5-$B4D7, 3 bytes
L6_B4D5:
        jsr     L6_B4DB

; ---- bank6.code_B4D8 (code) $B4D8-$B4DA, 3 bytes
        jmp     L6_9F4F

; ---- bank6.code_B4DB (code) $B4DB-$B4E1, 7 bytes
L6_B4DB:
        lda     #$40
        ldy     #$03
        jsr     L7_C0A5

; ---- bank6.code_B4E2 (code) $B4E2-$B4EC, 11 bytes
        lda     $0560,X
        and     #$03
        ora     $B9FB,Y
        sta     $0560,X

; ---- bank6.code_B4ED (code) $B4ED-$B4ED, 1 bytes
        rts

; ---- bank6.code_B4EE (code) $B4EE-$B4F2, 5 bytes
L6_B4EE:
        lda     $0500,X
        bmi     L6_B505

; ---- bank6.code_B4F3 (code) $B4F3-$B4F7, 5 bytes
        lda     $05D8,X
        bne     L6_B505

; ---- bank6.code_B4F8 (code) $B4F8-$B4FA, 3 bytes
        jsr     L7_C0F0

; ---- bank6.code_B4FB (code) $B4FB-$B504, 10 bytes
        lda     #$01
        sta     $05D8,X
        sta     $07A0,X
        bne     L6_B51B

; ---- bank6.code_B505 (code) $B505-$B507, 3 bytes
L6_B505:
        jsr     L6_BA51

; ---- bank6.code_B508 (code) $B508-$B50C, 5 bytes
        lda     $0500,X
        bmi     L6_B52E

; ---- bank6.code_B50D (code) $B50D-$B515, 9 bytes
        lda     $0530,X
        clc
        adc     #$07
        sta     $0530,X

; ---- bank6.code_B516 (code) $B516-$B51A, 5 bytes
        lda     #$00
        sta     $07A0,X

; ---- bank6.code_B51B (code) $B51B-$B520, 6 bytes
L6_B51B:
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_B521 (code) $B521-$B525, 5 bytes
        lda     #$21
        sta     $0548,X

; ---- bank6.code_B526 (code) $B526-$B52A, 5 bytes
        lda     #$00
        sta     $0560,X

; ---- bank6.code_B52B (code) $B52B-$B52D, 3 bytes
        jsr     L6_AEE8

; ---- bank6.code_B52E (code) $B52E-$B532, 5 bytes
L6_B52E:
        lda     $07A0,X
        bne     L6_B539

; ---- bank6.code_B533 (code) $B533-$B535, 3 bytes
        jsr     L7_C090

; ---- bank6.code_B536 (code) $B536-$B538, 3 bytes
        jmp     L6_B53C

; ---- bank6.code_B539 (code) $B539-$B53B, 3 bytes
L6_B539:
        jsr     L7_C08D

; ---- bank6.code_B53C (code) $B53C-$B542, 7 bytes
L6_B53C:
        lda     $0518,X
        cmp     #$30
        bcc     L6_B58D

; ---- bank6.code_B543 (code) $B543-$B54B, 9 bytes
        sbc     $0518
        bcs     L6_B54C
        cmp     #$B0
        bcc     L6_B58D

; ---- bank6.code_B54C (code) $B54C-$B550, 5 bytes
L6_B54C:
        lda     #$40
        jsr     L7_C030

; ---- bank6.code_B551 (code) $B551-$B555, 5 bytes
        jsr     L7_C0FF
        sta     $15

; ---- bank6.code_B556 (code) $B556-$B559, 4 bytes
        lda     #$0F
        sta     $14

; ---- bank6.code_B55A (code) $B55A-$B55E, 5 bytes
L6_B55A:
        jsr     L7_C108
        bcc     L6_B565

; ---- bank6.code_B55F (code) $B55F-$B564, 6 bytes
L6_B55F:
        txa
        tay
        lda     #$00
        sta     $14

; ---- bank6.code_B565 (code) $B565-$B569, 5 bytes
L6_B565:
        lda     #$5F
        jsr     L7_C105

; ---- bank6.code_B56A (code) $B56A-$B56F, 6 bytes
        lda     $0560,X
        sta     $0560,Y

; ---- bank6.code_B570 (code) $B570-$B574, 5 bytes
        lda     #$41
        sta     $0698,Y

; ---- bank6.code_B575 (code) $B575-$B579, 5 bytes
        lda     $15
        sta     $0788,Y

; ---- bank6.code_B57A (code) $B57A-$B57E, 5 bytes
        lda     #$00
        sta     $07A0,Y

; ---- bank6.code_B57F (code) $B57F-$B583, 5 bytes
        lda     #$20
        sta     $07D0,Y

; ---- bank6.code_B584 (code) $B584-$B58B, 8 bytes
        dec     $15
        dec     $14
        beq     L6_B55F
        bpl     L6_B55A

; ---- bank6.code_B58C (code) $B58C-$B58C, 1 bytes
        rts

; ---- bank6.code_B58D (code) $B58D-$B592, 6 bytes
L6_B58D:
        jsr     L7_C0CF
        jmp     L7_C0D2

; ---- bank6.code_B593 (code) $B593-$B595, 3 bytes
L6_B593:
        jsr     L6_BA51

; ---- bank6.code_B596 (code) $B596-$B59A, 5 bytes
        lda     $0500,X
        bmi     L6_B5A6

; ---- bank6.code_B59B (code) $B59B-$B5A0, 6 bytes
        jsr     L7_C0AE
        jsr     L7_C0A2

; ---- bank6.code_B5A1 (code) $B5A1-$B5A5, 5 bytes
        lda     #$21
        sta     $0548,X

; ---- bank6.code_B5A6 (code) $B5A6-$B5AB, 6 bytes
L6_B5A6:
        txa
        ldy     #$02
        jsr     L7_C0A5

; ---- bank6.code_B5AC (code) $B5AC-$B5AD, 2 bytes
        bcs     L6_B5BF

; ---- bank6.code_B5AE (code) $B5AE-$B5B4, 7 bytes
        lda     $0650,X
        cmp     #$10
        bcs     L6_B5E3

; ---- bank6.code_B5B5 (code) $B5B5-$B5BB, 7 bytes
        lda     #$B4
        ldy     #$68
        jsr     L6_B43F

; ---- bank6.code_B5BC (code) $B5BC-$B5BE, 3 bytes
        jmp     L6_B5C6

; ---- bank6.code_B5BF (code) $B5BF-$B5C5, 7 bytes
L6_B5BF:
        lda     #$B4
        ldy     #$70
        jsr     L6_B43F

; ---- bank6.code_B5C6 (code) $B5C6-$B5CE, 9 bytes
L6_B5C6:
        lda     $0638,X
        asl     A
        asl     A
        adc     #$0A
        sta     $15

; ---- bank6.code_B5CF (code) $B5CF-$B5D3, 5 bytes
        jsr     L7_C108
        bcs     L6_B5E3

; ---- bank6.code_B5D4 (code) $B5D4-$B5D8, 5 bytes
        lda     #$27
        jsr     L7_C105

; ---- bank6.code_B5D9 (code) $B5D9-$B5DD, 5 bytes
        lda     #$07
        sta     $07A0,Y

; ---- bank6.code_B5DE (code) $B5DE-$B5E2, 5 bytes
        lda     $15
        sta     $0788,Y

; ---- bank6.code_B5E3 (code) $B5E3-$B5E5, 3 bytes
L6_B5E3:
        jsr     L7_C0CF

; ---- bank6.code_B5E6 (code) $B5E6-$B5E8, 3 bytes
        jsr     L7_C0D2

; ---- bank6.code_B5E9 (code) $B5E9-$B5ED, 5 bytes
        lda     $0500,X
        bpl     L6_B5EF

; ---- bank6.code_B5EE (code) $B5EE-$B5EE, 1 bytes
        rts

; ---- bank6.code_B5EF (code) $B5EF-$B5FA, 12 bytes
L6_B5EF:
        lda     #$FE
        sta     $15
        sta     $14
        jsr     L6_BF71
        jsr     L7_C081

; ---- bank6.code_B5FB (code) $B5FB-$B608, 14 bytes
        lda     #$06
        sta     $15
        sta     $14
        lda     #$B6
        sta     $17
        lda     #$0F
        sta     $16

; ---- bank6.code_B609 (code) $B609-$B60E, 6 bytes
        ldy     $0518,X
        jmp     L7_C07E

; ---- bank6.tbl_B60F (data) $B60F-$B632, 36 bytes
; Type $7C rubble block (6 x 6 tiles)
        .byte   $FD,$76,$97,$97,$90,$FD,$77,$96,$96,$96,$96,$91,$97,$96,$96,$96
        .byte   $96,$97,$97,$96,$96,$96,$96,$97,$78,$96,$96,$96,$96,$92,$FD,$79
        .byte   $97,$97,$93,$FD

; ---- bank6.code_B633 (code) $B633-$B637, 5 bytes
L6_B633:
        lda     $0500,X
        bmi     L6_B658

; ---- bank6.code_B638 (code) $B638-$B63D, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_B63E (code) $B63E-$B640, 3 bytes
        jsr     L7_C0F3

; ---- bank6.code_B641 (code) $B641-$B645, 5 bytes
        lda     #$19
        sta     $0548,X

; ---- bank6.code_B646 (code) $B646-$B64A, 5 bytes
        lda     #$01
        sta     $0560,X

; ---- bank6.code_B64B (code) $B64B-$B64F, 5 bytes
        lda     #$81
        sta     $0698,X

; ---- bank6.code_B650 (code) $B650-$B652, 3 bytes
        jsr     L7_C0FC

; ---- bank6.code_B653 (code) $B653-$B657, 5 bytes
        lda     #$5A
        sta     $0788,X

; ---- bank6.code_B658 (code) $B658-$B65A, 3 bytes
L6_B658:
        jsr     L7_C009

; ---- bank6.code_B65B (code) $B65B-$B661, 7 bytes
        lda     $41
        and     #$03
        sta     $0560,X

; ---- bank6.code_B662 (code) $B662-$B664, 3 bytes
        jmp     L6_9F4F

; ---- bank6.code_B665 (code) $B665-$B669, 5 bytes
L6_B665:
        lda     $0500,X
        bmi     L6_B68F

; ---- bank6.code_B66A (code) $B66A-$B66F, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_B670 (code) $B670-$B672, 3 bytes
        jsr     L7_C0F3

; ---- bank6.code_B673 (code) $B673-$B677, 5 bytes
        lda     #$19
        sta     $0548,X

; ---- bank6.code_B678 (code) $B678-$B67F, 8 bytes
        lda     #$02
        sta     $0560,X
        sta     $0668,X

; ---- bank6.code_B680 (code) $B680-$B684, 5 bytes
        lda     #$FF
        sta     $0680,X

; ---- bank6.code_B685 (code) $B685-$B689, 5 bytes
        lda     #$03
        sta     $0698,X

; ---- bank6.code_B68A (code) $B68A-$B68E, 5 bytes
        lda     #$5A
        sta     $0788,X

; ---- bank6.code_B68F (code) $B68F-$B691, 3 bytes
L6_B68F:
        jsr     L7_C009

; ---- bank6.code_B692 (code) $B692-$B696, 5 bytes
        lda     #$18
        jsr     L7_C144

; ---- bank6.code_B697 (code) $B697-$B699, 3 bytes
        jmp     L6_9F4F

; ---- bank6.code_B69A (code) $B69A-$B69E, 5 bytes
L6_B69A:
        lda     $0500,X
        bmi     L6_B6D7

; ---- bank6.code_B69F (code) $B69F-$B6A4, 6 bytes
        jsr     L7_C0A8
        jsr     L7_C162

; ---- bank6.code_B6A5 (code) $B6A5-$B6A9, 5 bytes
        lda     #$02
        sta     $0560,X

; ---- bank6.code_B6AA (code) $B6AA-$B6AE, 5 bytes
        lda     #$19
        sta     $0548,X

; ---- bank6.code_B6AF (code) $B6AF-$B6B3, 5 bytes
        lda     #$01
        sta     $0698,X

; ---- bank6.code_B6B4 (code) $B6B4-$B6B8, 5 bytes
        lda     $0728,X
        bne     L6_B6C5

; ---- bank6.code_B6B9 (code) $B6B9-$B6BB, 3 bytes
        jsr     L7_C0F3

; ---- bank6.code_B6BC (code) $B6BC-$B6C0, 5 bytes
        lda     #$3C
        sta     $0788,X

; ---- bank6.code_B6C1 (code) $B6C1-$B6C4, 4 bytes
        lda     #$01
        bne     L6_B6D4

; ---- bank6.code_B6C5 (code) $B6C5-$B6CC, 8 bytes
L6_B6C5:
        jsr     L7_C0EA
        and     #$03
        sta     $0560,X

; ---- bank6.code_B6CD (code) $B6CD-$B6D1, 5 bytes
        lda     #$00
        sta     $0788,X

; ---- bank6.code_B6D2 (code) $B6D2-$B6D3, 2 bytes
        lda     #$1E

; ---- bank6.code_B6D4 (code) $B6D4-$B6D6, 3 bytes
L6_B6D4:
        sta     $07A0,X

; ---- bank6.code_B6D7 (code) $B6D7-$B6D9, 3 bytes
L6_B6D7:
        jsr     L7_C009

; ---- bank6.code_B6DA (code) $B6DA-$B6DE, 5 bytes
        dec     $07A0,X
        bne     L6_B6EC

; ---- bank6.code_B6DF (code) $B6DF-$B6E3, 5 bytes
        lda     #$1E
        sta     $07A0,X

; ---- bank6.code_B6E4 (code) $B6E4-$B6EB, 8 bytes
        jsr     L7_C0EA
        and     #$0C
        jsr     L7_C102

; ---- bank6.code_B6EC (code) $B6EC-$B6F1, 6 bytes
L6_B6EC:
        lda     $41
        and     #$3F
        bne     L6_B6FF

; ---- bank6.code_B6F2 (code) $B6F2-$B6F6, 5 bytes
        jsr     L7_C108
        bcs     L6_B6FF

; ---- bank6.code_B6F7 (code) $B6F7-$B6FE, 8 bytes
        lda     #$72
        sta     $0728,Y
        jsr     L7_C105

; ---- bank6.code_B6FF (code) $B6FF-$B703, 5 bytes
L6_B6FF:
        jsr     L7_C08D
        bcc     L6_B707

; ---- bank6.code_B704 (code) $B704-$B706, 3 bytes
        jmp     L6_9B17

; ---- bank6.code_B707 (code) $B707-$B70B, 5 bytes
L6_B707:
        jsr     L7_C0C6
        bcs     L6_B70D

; ---- bank6.code_B70C (code) $B70C-$B70C, 1 bytes
        rts

; ---- bank6.code_B70D (code) $B70D-$B710, 4 bytes
L6_B70D:
        ldy     $6E
        bne     L6_B714

; ---- bank6.code_B711 (code) $B711-$B713, 3 bytes
        jmp     L7_C0D8

; ---- bank6.code_B714 (code) $B714-$B716, 3 bytes
L6_B714:
        jmp     L7_C168

; ---- bank6.code_B717 (code) $B717-$B719, 3 bytes
L6_B717:
        jsr     L6_BA51

; ---- bank6.code_B71A (code) $B71A-$B71E, 5 bytes
        lda     $0500,X
        bmi     L6_B72E

; ---- bank6.code_B71F (code) $B71F-$B724, 6 bytes
        jsr     L7_C0AE
        jsr     L7_C0A2

; ---- bank6.code_B725 (code) $B725-$B72D, 9 bytes
        lda     $0530,X
        clc
        adc     #$08
        sta     $0530,X

; ---- bank6.code_B72E (code) $B72E-$B734, 7 bytes
L6_B72E:
        lda     #$20
        ldy     #$04
        jsr     L7_C0A5

; ---- bank6.code_B735 (code) $B735-$B73B, 7 bytes
        lda     $0650,X
        cmp     #$20
        bcs     L6_B74B

; ---- bank6.code_B73C (code) $B73C-$B740, 5 bytes
        tya
        cmp     #$03
        bne     L6_B743

; ---- bank6.code_B741 (code) $B741-$B742, 2 bytes
        lda     #$01

; ---- bank6.code_B743 (code) $B743-$B745, 3 bytes
L6_B743:
        jsr     L6_B787

; ---- bank6.code_B746 (code) $B746-$B74A, 5 bytes
        lda     #$41
        jsr     L7_C030

; ---- bank6.code_B74B (code) $B74B-$B74F, 5 bytes
L6_B74B:
        lda     $0638,X
        beq     L6_B779

; ---- bank6.code_B750 (code) $B750-$B755, 6 bytes
        lda     $41
        and     #$05
        bne     L6_B779

; ---- bank6.code_B756 (code) $B756-$B75A, 5 bytes
        jsr     L7_C108
        bcs     L6_B779

; ---- bank6.code_B75B (code) $B75B-$B75F, 5 bytes
        lda     #$5F
        jsr     L7_C105

; ---- bank6.code_B760 (code) $B760-$B764, 5 bytes
        lda     #$03
        sta     $0560,Y

; ---- bank6.code_B765 (code) $B765-$B769, 5 bytes
        lda     #$02
        sta     $07A0,Y

; ---- bank6.code_B76A (code) $B76A-$B76E, 5 bytes
        lda     #$41
        sta     $0698,Y

; ---- bank6.code_B76F (code) $B76F-$B773, 5 bytes
        lda     $41
        sta     $0788,Y

; ---- bank6.code_B774 (code) $B774-$B778, 5 bytes
        lda     #$18
        sta     $07D0,Y

; ---- bank6.code_B779 (code) $B779-$B77B, 3 bytes
L6_B779:
        jsr     L7_C0CF

; ---- bank6.code_B77C (code) $B77C-$B77E, 3 bytes
        jsr     L7_C0D2

; ---- bank6.code_B77F (code) $B77F-$B783, 5 bytes
        lda     $0500,X
        bpl     L6_B785

; ---- bank6.code_B784 (code) $B784-$B784, 1 bytes
        rts

; ---- bank6.code_B785 (code) $B785-$B786, 2 bytes
L6_B785:
        lda     #$03

; ---- bank6.code_B787 (code) $B787-$B79C, 22 bytes
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

; ---- bank6.tbl_B79D (data) $B79D-$B7BC, 32 bytes
; Type $7D tile frames: 4 x [4 x 2 tiles]
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

; ---- bank6.tbl_B839 (data) $B839-$B83E, 6 bytes
; Table, 6 bytes
        .byte   $0C,$36,$32,$4A,$66,$3C

; ---- bank6.tbl_B83F (data) $B83F-$B850, 18 bytes
; Table, 18 bytes (structural extent)
        .byte   $3C,$4E,$4A,$7A,$66,$3C,$30,$6C,$4C,$52,$66,$3C,$3C,$72,$52,$5E
        .byte   $66,$3C

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

; ---- bank6.tbl_B902 (data) $B902-$B903, 2 bytes
; Two bytes between two handlers, no reader found
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

; ---- bank6.tbl_B962 (data) $B962-$B965, 4 bytes
; Table, 4 bytes
        .byte   $00,$02,$06,$02

; ---- bank6.tbl_B966 (data) $B966-$B969, 4 bytes
; Table, 4 bytes
        .byte   $00,$00,$00,$40

; ---- bank6.tbl_B96A (data) $B96A-$B96D, 4 bytes
; Table, 4 bytes (structural extent)
        .byte   $1A,$19,$1A,$19

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

; ---- bank6.tbl_B9FB (data) $B9FB-$B9FE, 4 bytes
; Table, 4 bytes (structural extent)
        .byte   $00,$40,$C0,$80

; ---- bank6.code_B9FF (code) $B9FF-$BBA2, 420 bytes
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

; ---- bank6.code_BBA3 (code) $BBA3-$BBBA, 24 bytes
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

; ---- bank6.tbl_BBBB (data) $BBBB-$BBBE, 4 bytes
; Tile rectangle 2 x 2
        .byte   $A1,$A3,$AB,$AC

; ---- bank6.tbl_BBBF (data) $BBBF-$BBD6, 24 bytes
; Tile rectangle 6 x 4 (or its first 3 rows)
        .byte   $80,$9D,$9E,$9E,$9F,$80,$9D,$A1,$A2,$A2,$A3,$9F,$A5,$A6,$A7,$A8
        .byte   $A8,$A9,$A5,$20,$20,$20,$20,$A9

; ---- bank6.tbl_BBD7 (data) $BBD7-$BBE2, 12 bytes
; Tile rectangle 6 x 2
        .byte   $AA,$AB,$20,$20,$AC,$AD,$80,$AA,$AE,$AE,$AD,$80

; ---- bank6.tbl_BBE3 (data) $BBE3-$BBEB, 9 bytes
; Table indexed by $B9, the scroll speed high byte
        .byte   $64,$96,$C8,$FA,$FA,$FA,$FA,$FA,$FA

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

; ---- bank6.tbl_BD09 (data) $BD09-$BD38, 48 bytes
; Table, 48 bytes (structural extent)
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

; ---- bank6.tbl_BEAE (data) $BEAE-$BEB0, 3 bytes
; Three direction offsets
        .byte   $02,$FE,$00

; ---- bank6.tbl_BEB1 (level) $BEB1-$BECE, 30 bytes
; Tile rectangle 6 x 5
        .byte   $80,$C0,$C1,$C2,$C3,$80,$C4,$C5,$C6,$C7,$C8,$C9,$CA,$CB,$CC,$CD
        .byte   $CE,$CF,$D0,$D1,$20,$20,$D2,$D3,$D4,$20,$20,$20,$20,$D5

; ---- bank6.tbl_BECF (level) $BECF-$BED4, 6 bytes
; Tile rectangle 6 x 1
        .byte   $D6,$D7,$20,$20,$D8,$D9

; ---- bank6.tbl_BED5 (level) $BED5-$BEF8, 36 bytes
; Tile rectangle 6 x 6
        .byte   $80,$81,$80,$81,$80,$81,$81,$80,$81,$80,$81,$80,$80,$80,$F2,$F3
        .byte   $F4,$80,$F5,$F6,$F7,$F8,$F9,$FA,$FB,$20,$20,$20,$20,$CF,$D6,$D7
        .byte   $20,$20,$D8,$D9

; ---- bank6.code_BEF9 (code) $BEF9-$BF60, 104 bytes
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

; ---- bank6.code_BF61 (code) $BF61-$BF70, 16 bytes
L6_BF61:
        lda     #$2A
        jsr     L7_C105
        jsr     L7_C0EA
        and     #$03
        adc     #$FE
        sta     $0788,Y
        rts

; ---- bank6.code_BF71 (code) $BF71-$BFD0, 96 bytes
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

; ---- bank6.pad_BFD1 (padding) $BFD1-$BFFE, 46 bytes
; Fill: 46 x $FF
        .fill   46,$FF

; ---- bank6.bank_id_BFFF (data) $BFFF-$BFFF, 1 bytes
; Bank 6 identity byte
        .byte   $06
