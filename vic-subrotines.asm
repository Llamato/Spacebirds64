;VIC bank 2 constants
ScreenStart = $4400
ScreenSize = 40 * 25
ScreenEnd = ScreenStart + ScreenSize

;hires mode constants
BitmapStart = $6000
BitmapSize = 8000
BitmapEnd = BitmapStart + BitmapSize

EnterHighResMode
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
#fmb BitmapStart, BitmapEnd, $00
#fmb ScreenStart, ScreenEnd, $F0
rts