;Get sprite position
;Input
;\1 = sprite number
;Output
;X = Low byte of sprite x pos
;Y = sprite y pos
;A = high byte of sprite x pos
getspritepos .macro
    xposl = \1 * 2 + $d000
    ypos = xposl +1
    ldx xposl
    ldy ypos
    #bintobinseq \1
    and 53264
.endm

;Set sprite position
;Input
;\1 = sprite number
;\2 = x position
;\3 = y position
;Output
;Sprite at position
setspritepos .macro
    xposv .var \2
    yposv = \3
    xposl = \1 * 2 + $d000
    ypos = xposl +1
.ifpl xposv - 256
    xposv .var xposv - 256
    #bintobinseq \1
    ora 53264
    sta 53264
.endif
    lda #xposv
    sta xposl
    lda #yposv
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

;Move sprite number \1 left
;Input
;\1 = sprite number
;Output
;Sprite one more pixel to left
;Bug in here
;Sprite flickering on
;transition
movespriteleft .macro
    xposl = \1 * 2 + $d000
    ypos = xposl +1
    lda xposl
    sec
    sbc #1
    sta xposl
    bcs done
    lda #255
    sta xposl
    #bintobinseq \1
    eor 53264
    sta 53264
done
.endm

movespriteright .macro
    xposl = \1 * 2 + $d000
    ypos = xposl +1
    lda xposl
    clc
    adc #1
    sta xposl
    bcc done
    #bintobinseq \1
    eor 53264
    sta 53264
done
.endm
