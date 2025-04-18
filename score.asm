;-------------------------------------
;This file contains everything related
;to the score that is not also related
;to disk operations
;--------------------------------------
;Constants
scorepos = 107
scoreslbllen = 6
scoresize = 6
digitoffset = 95

;---------- Draw Scores Label ----------
scoreslabel
.block
    ldx #0
labelloop
    lda scorestext, x  
    sta txtscreenstart+33, x 
    lda #1
    sta colorramstart+33, x  
    inx
    cpx #scoreslbllen  
    bne labelloop
    rts
.bend

;Initializes score by zeroing out
;3 bytes to store 6 digits of packed bcd
initscore
    #poke score, 0
    #poke score+1, 0
    #poke score+2, 0
    jsr dispscore
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
    #dbcdd score, 1141
    #dbcdd score+1, 1139
    #dbcdd score+2, 1137
rts

scorestext
   .byte 69, 53, 65, 68, 55, 69
   .byte 0
   