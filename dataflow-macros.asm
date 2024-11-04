poke .macro
    lda #\2
    sta \1
.endm

ldi16 .macro 
    lda \2
    sta \1
    lda #>\2
    sta #<\1
.endm

fmb .macro 
    lda #>\1
    sta r1
    lda #<\1
    sta r0
    ldy #0
FillByte
    lda #\3
    sta (r0), y
    lda r0
    clc
    adc #1
    sta r0
    lda r1
    adc #0
    sta r1
CheckEnd
    lda r1
    cmp #>\2
    bne FillByte
    lda r0
    cmp #<\2
    bne CheckEnd
.endm

cpb .macro
    ldy #0
    lda #<\2
    sta r2
    lda #>\2
    sta r3
    lda #<\1
    sta r0
    lda #>\1
    sta r1

CopyByte
    lda (r0), y
    sta (r2), y
    iny
    cpy #\3
    bne CopyByte
.endm