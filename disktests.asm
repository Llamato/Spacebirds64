;print first 256 bytes of disk buffer
;to right bottom corner of the screen.
dumpDiskBufferToScreen .macro
    #ldi16 r0, diskBuffer
    #ldi16 r2, 1768
    lda #255
    sta r4
    jsr memcpy
.endm
