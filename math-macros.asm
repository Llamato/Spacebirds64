;---------------------------------------
;This file contains verious macros
;implementing basic arithmetic ops.

;Note: 6502 byte order is always
;lsb first, unless specified otherwise.
;---------------------------------------

;Add two 16 bit numbers in memory
;Input
;\1 = Source address of first number
;\2 = Source address of second number
;Output
;result of addition in \1 and \1+1
add16 .macro
    lda \1
    clc
    adc \2
    sta \1
    lda \1 +1
    adc \2 +1
    sta \1 +1
.endm

;Add a 16 bit imidiate to a 16 bit
;number in memory.
;Input
;\1 = Source adddress of first number
;\2 = Imidiate value to be added to \1
;Output
;result of addition in \1 and \1 +1
add16i .macro
    lda \1
    clc
    adc #<\2
    sta \1
    lda \1 +1
    adc #>\2
    sta \1 +1
.endm

;Standard implementation of S and A alg
;Input
;/1 multiplicant lb of 16 bit word
;/2 multipicator lb of 16 bit word
;Output
;result of multiplication in /1
mulbbw .macro 
    lda #0
    ldx  #$8
    lsr  \1
loop
    bcc  noadd
    clc
    adc  \2
noadd
    ror
    ror  \1
    dex
    bne  loop
    sta  \2
.endm

;As stated in original description
;Algorithm originally developed by
;Bregalad a member of the NES dev
;community. 
;http://www.nesdev.org/wiki/8-bit-Divide
;Input 
;\1 = Devident
;\2 = Devisior
;\3 = result
;Caution \3+1 is used for calculation
;Output
;result of devision in \3
;remainder in A
div .macro
dvd = \1
dvs = \2
res = >\3
reshi = <\3

;16 bit subtraction algorithm originally
;by Neil Parker
;developed for the apple ii in 2005
;https://llx.com/Neil/a2/mult.html
;Input
;\1 = LB of 16 bit enumerator
;\2 = LB of 16 bit denominator
;\3 = LB of 16 bit loc for remainder
;Output
;Quotient in \1
;remainder in \3
div16 .macro
num1 = \1
num2 = \2
rem = \3
lda #0; Initialize rem to 0
sta rem
sta rem+1
;There are 16 bits in num1
ldx #16
l1
;Shift hi bit of num1 into rem
asl num1
;(vacating the lo bit, which will
;be used for the quotient)
rol num1+1
rol rem
rol rem+1
lda rem
sec; Trial subtraction
sbc num2
tay
lda rem+1
sbc num2+1
;Did subtraction succeed?
bcc l2
sta rem+1; If yes, save it
sty rem
;and record a 1 in the quotient
inc num1
l2      
dex
bne l1
.endm
