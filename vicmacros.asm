;--------------------------------------
;This file contains macros for
;interfacing with the vic chip
;--------------------------------------

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

enspritedheight .macro
    #bintobinseq \1
    ora $d017
    sta $d017
.endm

enspritedwidth .macro
    #bintobinseq \1
    ora $d01d
    sta $d01d
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

disspritedheight .macro
    #bintobinseq \1
    eor #$ff
    and $d017
    sta $d017
.endm

disspritedwidth .macro
    #bintobinseq \1
    eor #$ff
    and $d01d
    sta $d01d
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
movespriteleft .macro
    xposl = \1 * 2 + $d000
    lda xposl
    beq remove

continue
    lda xposl
    sec
    sbc #1
    sta xposl
    bcs done
    lda #255
    sta xposl
    #bintobinseq \1   
    eor $d010         
    sta $d010
    jmp done

remove 
#bintobinseq \1
and $d010
bne continue
#disablesprite \1

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

;Fills one screen row with char in \2
;Input
;\1 = screen row number
;\2 = fillent char
;Output
;Screen row filled with \2
fillscreenrow .macro
rowaddr = 40*\1+txtscreenstart
    ldx #0
    lda #\2
fillchar
    cpx #40
    beq done
    sta rowaddr, x
    inx
    jmp fillchar
done
.endm

;Fills one screen column with char in \2
;Input
;\1 = screen column number
;\2 = fillent char
;Output
;Screen column filled with \2
fillscreencol .macro
startaddr = txtscreenstart+\1
    #ldi16 r0, startaddr
    ldy #0
    ldx #25
fillloop
    lda #\2
    sta (r0), y
    #add16i r0, 40
    dex
    bne fillloop
done
.endm
