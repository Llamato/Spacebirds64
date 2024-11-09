;---------------------------------------
;This file contains verious macros
;implementing basic arithmetic ops

;Tina Guessbacher
;Claude.ai

;WS2024

;---------------------------------------

;Standard implementation of S and A alg
;Input
;/1 multiplicant lb of 16 bit word
;/2 multipicator lb of 16 bit word
;Output
;Result of multiplication in /1
mul_8_8_16 .macro 
    LDA #0
    LDX  #$8
    LSR  \1
loop
    BCC  no_add
    CLC
    ADC  \2
no_add
    ROR
    ROR  \1
    DEX
    BNE  loop
    STA  \2
.endm

;S and A expended to 16x16 by claude.ai
;I know I can not belive it either
;Claude does not even mind leaving
; a sea of comments. A plus Teammate
;I love it! Tina Guessbacher 2024
mul_16_16_32 .macro
factor1 = \1; 16-bit number (2 bytes)
factor2 = \2; 16-bit number (2 bytes)
;Where to store the 32-bit result (4 by)
result = \3

LDA #0; Clear accumulator
STA result+2; Clear high word of result
STA result+3
LDX #16; 16 bits to process

LSR factor1+1; Start with LSB of high by
ROR factor1; Roll into low byte

loop
BCC no_add
CLC
LDA result+2;Add factor2 to HW of result
ADC factor2+1
STA result+2
LDA result+3
ADC #0; Handle any carry
STA result+3

LDA result;Add factor2 to LW of result
ADC factor2
STA result
LDA result+1
ADC factor2+1
STA result+1
BCC no_add;Handle any carry to high word
INC result+2
BNE no_add
INC result+3

no_add
ROR result+3;Rotate all 32 bits right
ROR result+2
ROR result+1
ROR result
ROR factor1+1
ROR factor1
DEX
BNE loop
.endm

;As stated in original description
;Algorithm originally developed by
;Bregalad a member of the NES dev
;community. 
;http://www.nesdev.org/wiki/8-bit_Divide
;Found by Tina
;Input 
;\1 = Devident
;\2 = Devisior
;\3 = Result
;Caution \3+1 is used for calculation
;Output
;Result of devision in \3
;Remainder in A
div .macro
Dvd = \1
Dvs = \2
Res = >\3
ResHi = <\3

;8-bit divide
;by Bregalad
;Enter with A = Dividend, Y=Divisor
;Output with YX = (A/Y) << 8, A = remain

sta Dvd	;Stores dividend
sty Dvs	;Stores divisor
lda #$00
sta ResHi;setting up a ring counter
ldy #$01;by initializing the result to 1
sty Res;done when the 1 gets shifted out
sl
asl Dvd
rol;Shift in 1 bit of dividend
;If carry is set, the dividend is greate
bcs fg
cmp Dvs
;Check if fractional dividend is greater
;then devisor
bcc fdgg
fg	
sbc Dvs;Subtract (C is always set)
;Necessary if we reached here
sec
fdgg
;Shift result 1 if subtraction was done
;Otherwise 0
rol Res
rol ResHi
bcc sl
ldx Res
ldy ResHi
.endm

;16 bit subtraction algorithm originally
;by Neil Parker
;developed for the apple ii in 2005
;https://llx.com/Neil/a2/mult.html
;Found by Tina 
;Input
;\1 = LB of 16 bit enumerator
;\2 = LB of 16 bit denominator
;\3 = LB of 16 bit loc for remainder
;Output
;Quotient in \1
;Remainder in \3
div16 .macro
NUM1 = \1
NUM2 = \2
REM = \3
LDA #0;Initialize REM to 0
STA REM
STA REM+1
LDX #16;There are 16 bits in NUM1
L1      
ASL NUM1;Shift hi bit of NUM1 into REM
;(vacating the lo bit, which will
;be used for the quotient)
ROL NUM1+1
ROL REM
ROL REM+1
LDA REM
SEC; Trial subtraction
SBC NUM2
TAY
LDA REM+1
SBC NUM2+1
BCC L2; Did subtractio n succeed?
STA REM+1; If yes, save it
STY REM
INC NUM1; and record a 1 in the quotient
L2      
DEX
BNE L1
.endm

add16 .macro
    lda \1
    adc \2
    sta \1
    lda \1 +1
    adc \2 +1
    sta \1 +1
.endm
