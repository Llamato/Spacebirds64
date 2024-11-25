;print first 256 bytes of disk buffer
;to right bottom corner of the screen.
;ddbts = dump disk buffer to screen.
ddbts .macro
    #ldi16 r0, diskbuffer
    #ldi16 r2, 1768+1
    lda #255
    sta r4
    jsr memcpy
.endm
