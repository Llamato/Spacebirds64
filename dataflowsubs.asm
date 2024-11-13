;memcpy = memory copy
;copies a block of data 
;(max 256 byte size) from one location
;in memory to another
;Input
;r0/r1 = source address pointer
;r2/r3 = destination address pointer
;r4 = size of data block
;Needs recode.
;While at it. Add 16 bit support please.
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
