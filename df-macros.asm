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
    sta \1 +1
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

;getCur = getCursor
;Retives current basic cursor position
;stores column in y and row in x
getCur .macro
    sec; set carry to indicate read
    jsr basicPlot; read cursor position
.endm

;setCur = setCursor
;Sets basic cursor position
;Input
;Y = cursor column
;X = cursor row
setCur .macro
    clc; clear carry to indicate set
    jsr basicPlot; srt cursor position
.endm

;prints string to screen
;Input
;\1 = start address of string
;\2 = length of string
;Output
;String on screeen,cursor at stringEnd+1
printnonenull .macro
ldx #0
printChar
    lda \1, x
    jsr kernalChrout
    inx
    cpx #\2
    beq donePrinting
    jmp printChar
donePrinting
.endm

;Macro wrapper for basic rom PrintNull
;function by max integrated by Tina
;Input 
; \1 = address of null terminated string
;Output
;string from \1
;without the null terminator
;beginning at location of basic cursor
print .macro ;Rename to printNull
    ;put low byte of address in a
    lda  #<\1
    ;put high byte of address in y
    ldy  #>\1
    jsr basicprintnull
.endm

crlf .macro; Carriage Return Line Feed
    #getCur
    ldy #0
    inx
    clc; Clear carry to indicate set
    jsr basicPlot; hit it!
.endm

tab .macro; Tab of IBM PC fame
    lda #32
    jsr kernalChrout
    jsr kernalChrout
    jsr kernalChrout
    jsr kernalChrout
.endm

;The ASM equivalent of basics input func
;Including everything but the forced
;question mark.
;Input
;\1 = Char storage address
;Output
;char storage address + input length =
;Input string
;X = length of input
input .macro
    ldx #0
getNextChar
    jsr KernalGetChr
    cmp #$0D; Carriage return
    beq done; We are done here
    sta \1, X
    inx
    jmp getNextChar
done
.endm

;The ASM equivalent of basics input func
;Including everything but the forced
;question mark and a null terminator
;instead.
;Input
;\1 = char storage address
;Output
;char storage address + input length =
;Input string
;X = length of input
nullinput .macro
    #input \1
    lda #0
    sta \1, x
.endm

;fmb fill memory block
;fills memory block from start address
;to end address with imidiate value.
;Input
;\1 = Start address
;\2 = End address
;\3 = Value
;Output
;Block from start address to end address
;filled with value
fmb .macro 
    #ldi16 r0, \1
    #ldi16 r2, \2
    ldy #0
    fillByte
        lda #\3
        sta (r0), y
        lda r0
        clc
        adc #1
        sta r0
        lda r1
        adc #0
        sta r1
        cmp r3
        bne fillByte
        lda r0
        cmp r2
        bne fillByte
.endm

;mov16 = move 16 bit with LSB frist
;Input
;\1 = destination address of low byte
;\2 = source address of high byte.
mov16 .macro
    lda \2
    sta \1
    lda \2 +1
    sta \1 +1
.endm
