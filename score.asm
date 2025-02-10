;Constants
scorepos = 107
scoreslbllen = 6
scoresize = 6
digitoffset = 95


;displays packedbcd digits on screen
;Input
;\1 = packed bcd address
;\2 = displaylocation
;Output
;Numerical characters in locations
;\2 and \2+1
disppbcddigits .macro
    lda #$f0
    and \1
    lsr
    lsr
    lsr
    lsr
    clc
    adc #digitoffset
    sta \2
    lda \1
    and #$0f
    clc
    adc #digitoffset
    sta \2+1
.endm

;---------- Draw Scores Label ------------------
scores_label
.block
    ldx #0
label_loop
    lda scores_text, x  
    sta txtscreenstart + scorepos, x 
    lda #1
    sta colorramstart + scorepos, x  
    inx
    cpx #scoreslbllen  
    bne label_loop
    rts
.bend

;Initializes score by zeroing out
;3 bytes to store 6 digits of packed bcd
initscore
    #poke score, 0
    #poke score+1, 0
    #poke score+2, 0
    rts

incscore
    sed; lets go bcd!
    lda score
    clc
    adc #1
    sta score
    lda score+1
    adc #0
    sta score+1
    lda score+2
    adc #0
    sta score+2
    cld; back to bin we go!
    rts

;Convert packed bcd to chargend
;text and put it 
;at scorepos+scoreslbllen
dispscore
.ifne includetests
    #mov 1064, score
    #mov 1063, score+1
    #mov 1062, score+2
.endif
    #disppbcddigits score, txtscreenstart+scorepos+scoreslbllen+4
    #disppbcddigits score+1, txtscreenstart+scorepos+scoreslbllen+2
    #disppbcddigits score+2, txtscreenstart+scorepos+scoreslbllen
rts

scores_text
   .byte 69, 53, 65, 68, 55, 69
   .byte 0
