;--------------------------------------
;This file contains a bunch of general
;use subrotines related to dataflow
;--------------------------------------

;memcpy = memory copy
;copies a block of data 
;(max 256 byte size) from one location
;in memory to another
;Input
;r0/r1 = source address pointer
;r2/r3 = destination address pointer
;r4 = length of data block 
memcpy
.block
    ldy #0
copybyte
    lda (r0),y
    sta (r2),y
    iny
    cpy r4
    bne copybyte
    rts
.bend

;Tabulator function. Behaviour is
;comperable to the one found on MS-DOS
;systems.
;Input
;x = initial spacing size
;r0 = value string length
;r1 = header string length
dtab
.block
    lda #32
distancingloop
    jsr kernalchrout
    dex
    bne distancingloop
;Filling to size needed
    lda r0
    clc
    sbc r1
    beq done
    sta r0
    lda #32
fillingloop
    jsr kernalchrout
    dec r0
    bne fillingloop
done
    rts
.bend
