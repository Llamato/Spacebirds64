;Text mode constants
txtscreenstart = $0400
txtscreensize = 40 * 25
txtcharsetstart = $2000


;Sets up custom charset space and points
;all basic pointers to to use new space.
encharram
lda 53272
and #243
ora #$08
sta 53272
rts

encharrom
lda 53272
and #243
sta 53272
rts

encharset1
lda 53272
and #$FF-$02
sta 53272
rts

encharset2
lda 53272
ora #$02
sta 53272
rts

;Hires mode constants
screenstart = $4400
screensize = 40 * 25
screenend = screenstart + screensize
charsetstart = $2c00
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

;Switch VIC Memory To 16k bank 2
lda 56576
and #252
ora #2
sta 56576

;Tell VIC-II where bitmap and
;screen space are.
lda 53272
ora #8
sta 53272

;Clear color and pixels
#fmb bitmapstart, bitmapend, $00
#fmb screenstart, screenend, $f0
rts
