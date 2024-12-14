;Set sprite position
;Input
;/1 = sprite number
;/2 = x position
;/3 = y position
;Output
;Sprite at position
setspritepos .macro 
        xpos = \1 * 2 + $d000
        ypos = xpos +1
        lda #\2
        sta xpos
        lda #\3
        sta ypos
.endm

;Displays sprite \1 on screen
;Input
;\1 = sprite id
;Output
;Sprite \1 on screen
enablesprite .macro
    #bintobinseq \1
    ora $d015
    sta $d015
.endm

;Removes sprite \1 from screen
;Input
;\1 = sprite id
;Output
;Sprite \1 no longer on screen
disablesprite .macro
    #bintobinseq \1
;Can we do this using preprocessor vars?
    eor #$ff
    and $d015
    sta $d015
.endm

;Sets the individual sprite color
;Input
;\1 = sprite id
;\2 = color
;Output
;Sprite color set to \2
setspritecolor .macro
    coloraddr = \1 + $d027
    lda #\2
    sta coloraddr
.endm
