;Adds static stars to the background
;might crash game somehow. 
;might not. .-)
placestar
.block
    pha
    #pushx
    #pushy
    ldy #0
    lda $d41b
    and #$08
    bne pageone
    lda $d41b
    and #$04
    bne pagetwo
    lda $d41b
    and #$02
    bne pagethree

pagefour
    tax
    lda #105
    sta 256*3+$400, x
    jmp done

pagethree
    tax
    lda #105
    sta 256*2+$400, x
    jmp done

pagetwo
    tax
    lda #105
    sta 256+$400, x
    jmp done

pageone
    tax
    lda #105
    sta $400, x
    
done
    #pully
    #pullx
    pla
    rts
.bend
