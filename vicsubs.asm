;Text mode constants

;Fills color ram 
;with value in A
;Input
;A = colorcode
recolorscreen
.block
    ldx #0

colorfillloop
    sta $d800,x; first page
    sta $d900,x; second page
    sta $da00,x; third page
    sta $db00,x; fourth page
    inx
    bne colorfillloop
    rts
.bend

;Sets up custom charset space and points
;all pointers to to use new space.
encharram
lda 53272
and #243
ora #$A
sta 53272
rts

;points all pointers to character rom.
encharrom
lda 53272
and #2
ora #21
sta 53272
rts

;Enables first charset
;Uppercase and graphics characters
;in the default character rom.
encharset1
lda 53272
and #$ff-2
sta 53272
rts

;Enables second charset
;Uppercase and lowercase latters
;in the default character rom.
encharset2
lda 53272
ora #$02
sta 53272
rts

;Set VIC-II to high res mode
;in accordance with procedure described
;here 
;c64-wiki.com/wiki/Graphics-Modes
enterhighres
lda 53265
ora #32
sta 53265
lda 53270
and #239
sta 53270

;Switch VIC Memory To 16k bank 2
lda 56576
and #252
ora #2
sta 56576

;Tell VIC-II where bitmap and
;screen space are.
lda 53272
ora #$A
sta 53272

;Clear color and pixels
#fmb bitmapstart, bitmapend, $00
#fmb screenstart, screenend, $f0
rts
