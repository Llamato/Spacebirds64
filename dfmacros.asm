;--------------------------------------
;This file contains dataflow related
;macros.
;--------------------------------------

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

;Effectively equivalent to basics
;poke command. Even the syntax is much
;the same.
;Input
;\1 = address to monitor
;\2 = value to wait for
wait .macro
    waitmore
    lda \1
    cmp #\2
    bne waitmore
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

;getcur = getcursor
;Retives current basic cursor position
;stores column in y and row in x
getcur .macro
    sec; clear carry means read
    jsr basicplot; do the reading
.endm

;setcur = setcursor
;Sets basic cursor position
;Input
;Y = cursor column
;X = cursor row
setcur .macro
    clc; clear carry means set
    jsr basicplot; set cursor pos
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

;Carriage Return Line Feed
crlf .macro
    #getcur
    ldy #0
    inx
    clc; set means clear carry
    jsr basicplot; hit it!
.endm

tab .macro; Tab of IBM PC fame
    lda #32
    jsr kernalchrout
    jsr kernalchrout
    jsr kernalchrout
    jsr kernalchrout
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
getnextchar
    jsr kernalgetchr
    cmp #$0d; Carriage return
    beq done; We are done here
    sta \1, X
    inx
    jmp getnextchar
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
    fillbyte
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
        bne fillbyte
        lda r0
        cmp r2
        bne fillbyte
.endm

;mov = move
;Input
;\1 = destination address
;\2 = source address
mov .macro
    lda \2
    sta \1
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

;prints string to screen
;Input
;\1 = start address of string
;\2 = length of string
;Output
;String on screeen,cursor at stringEnd+1
printlen .macro
ldx #0
printchar
    lda \1, x
    jsr kernalchrout
    inx
    cpx #\2
    beq doneprinting
    jmp printchar
doneprinting
.endm

;Number to sequence
;Converts a binary number in to a
;binary sequence so for example
;11 (3) becomes 100 (4)
; up to 8 becomes 128
;Input
;\1 = Number to convert
;Output
; A = Binary sequence representing /1
bintobinseq .macro 
    .ifeq \1
        lda #1
    .endif
    .ifeq \1 - 1
        lda #2
    .endif
    .ifeq \1 - 2
        lda #4
    .endif
    .ifeq \1 - 3
        lda #8
    .endif
    .ifeq \1 - 4
        lda #16
    .endif
    .ifeq \1 -5
        lda #32
    .endif
    .ifeq \1 - 6
        lda #64
    .endif
    .ifeq \1 -7
        lda #128
    .endif
.endm

;Converts packed bcd to bcd
;Input
;\1 = address of packed bcd
;\2 = more significant digit storage
;\3 = less significant digit storage
;Output
;seperated bcd in \2 and \3
unpackbcd .macro
    lda \1
    lsr
    lsr
    lsr
    lsr
    sta \2
    lda \1
    and #$0f
    sta \3
.endm

;Converts bcd to ascii code
;Input
;\1 = address of bcd
;\2 = address of ascii
;(\1 and \2 can be equal)
;Output
;Ascii in \2
bcdtoascii .macro
    lda \1
    ora #$30
    sta \2
.endm

;Pushes byte from address \1 onto stack
;Input
;\1 = address holding contents to push
;Output
;Contents of \1 at stack pointer address
push .macro
    lda \1
    pha
.endm

;Pushes x to stack
;Input
;None
;Output
;Contents of x at stack pointer address
pushx .macro
    txa
    pha
.endm

;Pushes y to stack
;Input
;None
;Output
;Contents of y at stack pointer address
pushy .macro
    tya
    pha
.endm

;Pulls byte from stack into location \1
;Input
;\1 = address to store contents pulled
;Output
;contents of stack top in \1
pull .macro
    pla
    sta \1
.endm

;Pulls byte from stack into x
;Input
;None
;Output 
;Contents of stack top in x
pullx .macro
    pla
    tax
.endm

;Pulls byte from stack into y
;Input
;None
;Output 
;Contents of stack top in y
pully .macro
    pla
    tay 
.endm

; Setup an Interrupt at specific
; Rasterline 
; Input:
;   \1 - Raster Line
;   \2 - Address to ISR
setuprasterint .macro
; clear high bit of raster line
    lda #$7f  
    and $d011      
    sta $d011

; set raster interrupt to
; trigger on given  line
    lda #\1   
    sta $d012     

; set pointer to ISR
    lda #<\2      
    sta $0314     
    lda #>\2
    sta $0315
.endm

;ack vic irq
;\1 = irq id
;0 = Raster compare IRQ
;1 = Sprite to background collision IRQ
;2 = Sprite to Sprite Collision IRQ
;3 = Light-Pen Triggered IRQ Flag
;7 = IRQ has been generated
ackvicirq .macro
    #bintobinseq \1
    ora $d019
    ora #128
    sta $d019
.endm
