includetests = 0
includechargen = 0
includesound = 0

*=2049
;BASIC starter (ldraddr $0801 / 2049)
;Load address for next BASIC line (2064)
    .byte $0b, $08
;Line number (10)         
    .byte $0a, $00
    .byte $9e; SYS token
;PETCII for " 2064"
    .byte $20, $32, $30, $36, $34
;End of BASIC line
    .byte $00, $00
;End of BASIC program markers
    .byte $00, $00, $00

*=2064

.include "zeropage-map.asm"
.include "rom-map.asm"
.include "rammap.asm"
.include "dfmacros.asm"
.include "vicmacros.asm"

add16i .macro
    lda \1
    clc
    adc #<\2
    sta \1
    lda \1 +1
    adc #>\2
    sta \1 +1
.endm

add16 .macro
    lda \1
    clc
    adc <\2
    sta \1
    lda \1 +1
    adc >\2
    sta \1 +1
.endm

sub16i .macro
    lda \1
    sec
    sbc #<\2
    sta \1
    lda \1 +1
    sbc #>\2
    sta \1 +1
.endm

;.include "math-macros.asm"

.ifne includetests
    .include "disktests.asm"
.endif

;sss = show start screen
sss
;Set border color
    #poke 53280, 0

;Set background color
    #poke 53281, 0

;Set text color for all chars
;on screen;
    lda #7; Yellow
    jsr recolorscreen

;Load start screen content
.ifne includechargen
    #ldi16 r0, txtscreenstart 
    lda #$53; S in ascii
    jsr loadtextscreen
.endif

.ifeq includechargen
    #ldi16 r0, txtcharsetstart
    lda #$44
    jsr loadtextscreen
.endif

;Load custom font
.ifne includechargen
    jsr encharram
    #ldi16 r0, txtcharsetstart
    lda #$53; S in ascii
    jsr loadchargen
.endif

;Temporary solution because I could not
;get copying over of default chars
;from rom to ram to work.
.ifeq includechargen
    jsr encharram
    #ldi16 r0, txtcharsetstart
    lda #$44; D in ascii
    jsr loadchargen
.endif

;Enable double height for all sprites
    #poke $d017, $ff

;Enable double width for all sprites
    #poke $d01d, $ff

;Enable multicolor for all sprites
    #poke 53276, 255

;Setup sprite 0 for address $2000
    #poke $07f8, $80
    #setspritecolor 0, $0f
    #setspritepos 0, 55, 125
    #enablesprite 0

;Setup sprite 1 for address $2040
    #poke $07f9, $81
    #setspritecolor 1, 1
    #setspritepos 1, 265, 125
    #enablesprite 1

;Set multicolor colors
    #poke $d025, $06
    #poke $d026, $02
    #ldi16 r0, sprite0addr
    lda #48
    jsr loadsprite
    #ldi16 r0, sprite1addr
    lda #49
    jsr loadsprite

;Add stars to background
    lda #69
    sta r0
    ldx #10
    stx r1
    jsr placestars
;For some reason enemy movement breaks
;at the low byte, high byte boundry
;if the registeres are not cleared like
;done here. if anybody got any idea on
;why that might be please let me know.
;stranger still if any of those is not
;cleared then the whole programm
;crashes
    lda #0
    ldx #0
    ldy #0
.ifne includesound
    jsr loadsid
    jsr playsound
.endif

gameloop
;Check for raster line to
;determine if enemies should
;move
lda $d012
cmp #$ff
beq moveloop
jmp jumppad

;move enemies one to the left
moveloop
.block
    #movespriteleft 1
    #movespriteleft 2
    #movespriteleft 3
    #movespriteleft 4
    #movespriteleft 5
    #movespriteleft 6
    #movespriteleft 7
.bend

inputloop
.block
    up
    lda 56320
    and #1
    bne down
    dec $d001

    down
    lda 56320
    and #2
    bne jumppad
    inc $d001
.bend

jumppad
lda 198
bne sshss
#poke 198, 0
jmp gameloop

;sshss = show save high score screen
sshss
; Disable all sprites
    #poke $d015, 0
    
    jsr basiccls

.ifne includetests
    #ddbts
.endif

;Set border color
    #poke 53280, 0

;Set background color
    #poke 53281, 0

;Set basic text color
    #poke 646, 7
    

.ifeq includechargen
    jsr encharrom
.endif

.ifne includesound
    jsr disablesound
.endif

;Load custom font
.ifne includechargen
    jsr encharram
    #ldi16 r0, txtcharsetstart
    lda #$45; E in ascii
    jsr loadchargen
.endif

;Set charset to 2
.ifeq includechargen
    jsr encharset2
.endif

.ifne includesound
    jsr disablesound
.endif

;Load scores from disk
    jsr clrdiskiomem
    jsr loadhighscores

.ifne includesound
    jsr enablesound
.endif

.ifne includetests
    #ddbts
.endif

    lda #0
    cmp eorp
    bne scfs
    cmp eorp +1
    bne scfs

;Cleaning twice for the first score
;written to disk helps erase garbage
;handed to us by the failed load attempt
    jsr clrdiskiomem

;scfs = skip cleanup for subsequent
    scfs

.ifne includetests
    #ddbts
.endif

    #print tyfps

;Get name from user
    #print enternameprompt
    jsr kernalgetchr
    #nullinput namearea
    #crlf

;Get year from user
    #print ecyp
    #nullinput yeararea
    #crlf

;Get score from user
    #print esp
    #nullinput scorearea
    #crlf

;Save score to disk
    jsr addhstodb

;Print high score table to screen
.block 
;Print high scores table
;(game) design parameters
    theadcolor = 4; Pink
    tentrycolor = 1; White
    townentrycolor = 7; Yellow
    tabstopwidth = 4
    jsr basiccls; Clear screen

;Print table header
    #poke 646, theadcolor
    #printlen scorestring, 5
    #tab
    #printlen yearstring, 4
    #tab 
    #printlen namestring, 4
    #crlf

;Print table entries
;set text color black
    #poke 646, 1

printtableentry
;Print Score
    lda currrecptr
    ldy currrecptr +1
    jsr basicprintnull
    #tab
    #add16i currrecptr, scorelength 

;Print Year
    lda currrecptr
    ldy currrecptr +1
    jsr basicprintnull
    #tab
    #add16i currrecptr, yearlength
    
;Print Name
    lda currrecptr
    ldy currrecptr +1
    jsr basicprintnull
    #add16i currrecptr, namelength
    #crlf

;Check for next record
;Optimized with Claude ai. Good stuff!
    ;Load high byte
    lda currrecptr +1
    ;Compare with high byte
    cmp eorp +1
    ;If eorp > currrecptr
    bcc jumppad
    ;If eorp < currrecptr
    bne done
    ;If high bytes
    lda currrecptr
    ;Compare with low byte
    cmp  eorp
    bcc jumppad
    ;If equal, continue
    beq done
    jmp done
jumppad; Needed because of long branch
    jmp printtableentry
done
.bend

.ifne includetests
    #ddbts
.endif

.ifne includesound
    jsr disablesound
.endif
    
    jsr savehighscores
    
.ifne includesound
    jsr enablesound
.endif

.ifne includetests
    #ddbts
.endif

jsr waitforinput

displayqrcode
    jsr basiccls
    jsr encharrom
    jsr encharset1
    jmp loadqrcode
    rts

;Wait for user to press any key
;or fire button
;before continueing.
waitforinput
.block
    #poke 198, 0
waitsomemore
;Char in keyboard buffer?
;Aka. Keyboard key pressed?
    lda 198
    bne continue

;Nothing pressed
    jmp waitsomemore 
continue
    #poke 198, 0
    rts
.bend

;Bug in here!!!
;Place background stars
;procedually with seed and density
;with the density given in
;stars per screen page (40x25 chars).
;Input
;r0 = seed
;r1 = star density
;Output
;Stars on screen
placestars
.block
setup
    #ldi16 r2, 1024
    ldx #0
placestar
    lda #255
    sec
    sbc r0
    clc
    adc r2
    sta r2
    lda #0
    sta r3
    ora r0
    sta r0
clamp
    lda r3
    cmp #>2025
    bcc bgte
    lda r3
    cmp #>1024
    bcc bgin
    jmp blt
bgte
    beq bgt
    lda r2
    cmp #<2025
    bcc bgt
    lda r2
    cmp #<1024
    bcc bgin
    jmp blt
bgt
    #sub16i r2, 2024
    #add16i r2, 1024
    jmp bgin
blt
    #add16i r2, 1024
bgin
    lda #78
    ldy #0
    sta (r2), y
next
    inx
    cpx r1
    bne placestar
    rts
.bend

.include "vicsubs.asm"
.include "dataflowsubs.asm"
.include "playsid.asm"
.include "disksubs.asm"

;Data
;tyfps = thank you for playing string
tyfps
.text "Thank you for playing"
;line end
.byte $0d
.byte $00

enternameprompt
.text "Please "
.null "enter your name?"

;ecyp = enter current year prompt
ecyp
.null "and the current year? "

;esp = enter score prompt
esp
.text "and your score "
.null "for debugging? "

namestring
.null "Name: "

yearstring
.null "Year: "

scorestring
.null "Score: "
