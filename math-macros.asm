;--------------------------------------
;This file contains basic math rotines
;--------------------------------------
 
;adds a 16 bit imidiate to a value
;stored in memory
;Input
;\1 = Operant and storage
;\2 = Operant
;Output
;\1+#\2 in \1 
add16i .macro
    lda \1
    clc
    adc #<\2
    sta \1
    lda \1+1
    adc #>\2
    sta \1+1
.endm

;adds two 16 bit values from
;memory together
;Input
;\1 = Operant and storage
;\2 = Operant
;Output
;\1+\2 in \1
add16 .macro
    lda \1
    clc
    adc <\2
    sta \1
    lda \1+1
    adc >\2
    sta \1+1
.endm

;subtracts a 16 bit imidiate from a value
;stored in memory
;Input
;\1 = Operant and storage
;\2 = Operant
;Output
;\1-#\2 in \1
sub16i .macro
    lda \1
    sec
    sbc #<\2
    sta \1
    lda \1+1
    sbc #>\2
    sta \1+1
.endm
