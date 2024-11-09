;copyBlock
;copies a block of data 
;(max 256 byte size) from one location
;in memory to another
;Input
;r0/r1 = source address pointer
;r2/r3 = destination address pointer
;Y = size of data block

memcpy
    lda (r0), y
    sta (r2), y
    dey
    bne memcpy
    lda (r0), y
    sta (r2), y
    rts
