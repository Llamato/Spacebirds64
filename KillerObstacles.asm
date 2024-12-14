; SpriteSet Data...
; 1 images, 64 bytes per image, total size is 64 ($40) bytes.
addr_spriteset_attrib_data = $
* = addr_spriteset_data
spriteset_data

sprite_image_0
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$AA,$00,$02,$AA,$80,$06
.byte $EA,$A0,$36,$AB,$A0,$36,$AF,$E0,$36,$AA,$A0,$36,$AA,$A0,$36,$8A
.byte $20,$36,$A5,$A0,$3E,$EA,$A0,$3F,$AA,$80,$0F,$D5,$00,$03,$FF,$30
.byte $00,$FC,$30,$00,$00,$3C,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$C1



; SpriteSet Attribute Data...
; 1 attributes, 1 per image, 8 bits each, total size is 1 ($1) bytes.
; nb. Upper nybbles = MYXV, lower nybbles = colour (0-15).

* = addr_spriteset_attrib_data
spriteset_attrib_data

.byte $C1



