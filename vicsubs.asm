;VIC bank 2 constants
screenStart = $4400
screenSize = 40 * 25
screenEnd = screenStart + screenSize

;hires mode constants
bitmapStart = $6000
bitmapSize = 8000
bitmapEnd = bitmapStart + bitmapSize

;Set VIC-II to high res mode
;in accordance with procedure described
;here 
;c64-wiki.com/wiki/Graphics_Modes
enterHighResMode
lda 53265
ora #32
sta 53265
lda 53270
and #239
sta 53270

;Tell VIC-II where bitmap and screen space are
lda 53272
ora #8
sta 53272

;Switch VIC Memory To 16k bank 2
lda 56576
and #252
ora #2
sta 56576

;clear color and pixels
#fmb bitmapStart, bitmapEnd, $00
#fmb screenStart, screenEnd, $F0
rts
