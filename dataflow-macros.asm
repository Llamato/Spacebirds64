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

lsl .macro
    clc
    rol
.endm

lslz .macro
    clc
    rol \1
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

;Macro wrapper for basic rom PrintNull
;function by max integrated by Tina
;Input 
; \1 = address of null terminated string
;Output
;string from \1
;without the null terminator
;beginning at location of basic cursor
print .macro 
    ;put low byte of address in a
    lda  #<\1
    ;put high byte of address in y
    ldy  #>\1
    jsr BasicPrintNull
.endm

crlf .macro; Carriage Return Line Feed
    ldx $d6; Read current cursor row
    inx; Increment row by one
    ldy #0; Set cursor column to 0
    clc; Clear carry to indicate set
    jsr KernalPlot; hit it!
.endm

;The ASM equivalent of basics input func
;Including everything but the forced
;question mark.
;Input
;\1 = char storage address
input .macro
    ldx #0
GetNextChar
    jsr KernalGetChr
    beq GetNextChar; temp
    cmp #$0D; Carriage return
    beq done; We are done here
    sta \1, x
    jmp GetNextChar
done
.endm
