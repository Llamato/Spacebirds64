
enablesprite0
         lda #$0f
         sta $d027 ;color Sprite0

         lda #$06
         sta $d025 ;multicol1

         lda #$02
         sta $d026 ;multicol2

         lda #$80
         sta $07f8 ;Pointer Sprite0

         lda #%00000001
         sta $d01c ;bin multicol

         lda #%00000001
         sta $d015 ;bin sprites active

         lda #%00000001
         sta $d017 ;bin double height

         lda #%00000001
         sta $d01d ;bin double width
        rts

              *= $2000
spritenull
         .byte $0a,$f0,$00,$02,$00,$00
         .byte $02,$00,$00,$02,$80,$00
         .byte $00,$80,$00,$00,$af,$00
         .byte $3c,$20,$00,$3f,$a9,$00
         .byte $0a,$ba,$80,$2a,$be,$a0
         .byte $aa,$ae,$aa,$2a,$be,$a0
         .byte $0a,$ba,$80,$3f,$a9,$00
         .byte $3c,$20,$00,$00,$af,$00
         .byte $00,$80,$00,$02,$80,$00
         .byte $02,$00,$00,$02,$00,$00
         .byte $0a,$f0,$00,$80
