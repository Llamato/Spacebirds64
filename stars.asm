;--------------------------------------
;This file contains all the code
;Needed to sprinkel nice sparkly stars
;into the darkness of space
;--------------------------------------

;Adds a star to the star map that
;keeps track of stars.
addtostarmap .macro
    txa
    ldx starposmapptr
    cpx #$80
    bcs skyisfull
    sta starposmap, x
    inx
    lda #<pageaddr
    sta starposmap, x
    inx
    stx starposmapptr
.endm

movstarsonpage .macro
    pageaddr .var \1*256+$400
    #ldi16 r0, pageaddr
    lda (r0), y
    cmp #$69
    beq movestarleft
    jmp removestar

movestarleft
    lda #$17; blank char
    sta (r0), y
    cpy #0
    bne makenewstar
    jmp spawnnewstar

removeoldstar
    jmp removestar
    cmp #$04
    bcc removestar
    lda #$69
    sta (r0), y
    iny
    jmp next

makenewstar
    dey
    lda #$69
    sta (r0), y
    jmp next

spawnnewstar
    #pushy
    lda #$69
    ldy #254
    sta (r0), y
    #pully
    jmp removeoldstar

removestar
    lda #$17
    sta (r0), y
next
.endm

;Sets up the star map used to
;keep track of stars.
initstars
.block
    #fmb starposmap, starposmapptr, $bb
    ldx #0
    stx starposmapptr
    rts
.bend

;Adds static stars to the background
placestars
.block
    ldy #0
    lda $d41b
    and #$08
    beq continue
    jmp pageone

continue
    lda $d41b
    and #$04
    bne pagetwo
    lda $d41b
    and #$02
    bne pagethree

pagefour
    pageaddr .var 256*3+$400
    tax
    lda #105
    sta pageaddr, x
    ;#addtostarmap 3
    jmp nextstar

pagethree
    pageaddr .var 256*2+$400
    tax
    lda #105
    sta pageaddr, x
    ;#addtostarmap 2
    jmp nextstar

pagetwo
    pageaddr .var 256*1+$400
    tax
    lda #105
    sta pageaddr, x
    ;#addtostarmap 1
    jmp nextstar

pageone
    pageaddr .var $400
    tax
    lda #105
    sta pageaddr, x
    ;#addtostarmap 0
    
nextstar
    lda starposmapptr
    cmp #$80
    bcs skyisfull
    inc starposmapptr

skyisfull
    rts
.bend

;Moves stars on screen left
movestarsleft
.block
    #push r0
    #push r1
    ldy #0

loop
    #movstarsonpage 0
    #movstarsonpage 1
    #movstarsonpage 2
    ;#movstarsonpage 3
    iny
    beq done
    jmp loop

done
    #pull r1
    #pull r0
    rts
.bend

spawnnewstar
.block

    rts
.bend
