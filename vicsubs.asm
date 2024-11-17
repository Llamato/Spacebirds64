;VIC bank 2 constants
screenstart = $4400
screensize = 40 * 25
screenend = screenstart + screensize

;hires mode constants
bitmapstart = $6000
bitmapsize = 8000
bitmapend = bitmapstart + bitmapsize

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

;Tell VIC-II where bitmap and 
;screen space are
lda 53272
ora #8
sta 53272

;Switch VIC Memory To 16k bank 2
lda 56576
and #252
ora #2
sta 56576

;clear color and pixels
#fmb bitmapstart, bitmapend, $00
#fmb screenstart, screenend, $f0
rts
