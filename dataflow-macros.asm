;Effectively equivalent to basics
;poke command. Even the syntax is much
;the same.
;Input
;\1 = target address
;\2 = value to be loded into address
;Output
;\2 value in \1 address
poke .macro
    lda #\2
    sta \1
.endm

;ldi16 load imidiate 16 bit.
;Meaning load a value present in memory
;directly after the instuction.
;As in the value supplied as an argument
;Input
;\1 = target address of lower byte
;\2 = value to be loaded into \1
;Output
;\2 value \in 1
ldi16 .macro 
    lda #<\2
    sta \1
    lda #>\2
    sta #\1 +1
.endm

;lsl logical shift left
;shifts left without rolling over carry
;Input A
;Output A shifted left by 1
lsl .macro
    clc
    rol
.endm

;lslz logical shift left zero page
;Behaves exectly like lsl execpt it
;shifts the value of a zeropage address
;instead of the accumulator.
;Input
;\1 = address of value to be shifted
;Output
;value of \1 shifted right by 1
lslz .macro
    clc
    rol \1
.endm

;fmb fill memory block
;fills memory block from start address
;to end address with imidiate value.
;Input
;\1 = Start address
;\2 = end address
;\3 = value
;Output
;Block from start address to end address
;filled with value
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
