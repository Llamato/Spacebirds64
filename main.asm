;Build type adjustments
includetests = 0
includechargen = 0


;Game design parameters
gamespeedlimit = 32
gamespeedmin = 128

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
.include "math-macros.asm"

.ifne includetests
    .include "disktests.asm"
.endif

init
;Setup gamestate
    #poke gameflags, 0
    #poke scrollcolumn, 0

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
    #ldi16 r0, $c100 
    lda #$53; S in ascii
    jsr loadtextscreen
.endif

.ifeq includechargen
    #ldi16 r0, txtcharsetstart
    lda #$44; D in ascii

;if I load this with loadchargen
;it does not work.
;Why do we need to load this charset
;like it is a screen here?
    jsr loadtextscreen
.endif

;Load custom font
.ifne includechargen
    jsr encharram
    #ldi16 r0, txtcharsetstart
    lda #$53; S in ascii
    ;jsr loadchargen
.endif

;Temporary solution because I could not
;get copying over of default chars
;from rom to ram to work.
.ifeq includechargen
    jsr encharram
    #ldi16 r0, txtcharsetstart
    lda #$44; D in ascii
    ;jsr loadchargen
.endif


;Set double height for enemy sprites 0-6
;and single height for fuel sprites 7
    #poke $d017, $7f

;Set double width for enemy sprites 0-6
;and single width for fuel sprites 7
    #poke $d01d, $7f

;Enable multicolor for all sprites
    #poke 53276, 255

;spaceship
;Setup sprite 0 for address $2000
    #poke $07f8, $80
    #setspritecolor 0, $0f
    #setspritepos 0, 55, 125
    #enablesprite 0

;enemy 1
;Setup sprite 1 for address $2040
    #poke $07f9, $81
    #setspritecolor 1, 1
    #setspritepos 1, 265, 125
    #enablesprite 1

;enemy 2
;Setup sprite 2 for address $2040
    #poke $07fa, $81
    #setspritecolor 2, 1
    ;#setspritepos 2, 140, 60
    ;#enablesprite 2

;enemy 3
;Setup sprite 3 for address $20c0
    #poke $07fb, $81
    #setspritecolor 3, 1
    ;#setspritepos 3, 360, 170
    ;#enablesprite 3

;enemy 4
;Setup sprite 4 for address $2040
    #poke $07fc, $81
    #setspritecolor 4, 1
    ;#setspritepos 4, 319, 170
    ;#enablesprite 4   


;fuel 1 (alt)
;enemy 5
;Setup sprite 5 for address $2040
    #poke $07fd, $81
    #setspritecolor 5, 1
    ;#setspritepos 5, 359, 125
    ;#enablesprite 5

;fuel 2 (alt)
;enemy 6
;Setup sprite 6 for address $2040
    #poke $07fe, $81
    #setspritecolor 6, 1
    ;#setspritepos 6, 400, 190
    ;#enablesprite 6

;fuel 3 (alt)
;fuel 1
;Setup sprite 7 for address $2040
    #poke $07ff, $82
    #setspritecolor 7, 1
    ;#setspritepos 7, 50, 70
    ;#enablesprite 7

;Set multicolor colors
    #poke $d025, $06
    #poke $d026, $02 


;Load sprites
    #ldi16 r0, sprite0addr
    lda #48
    ;jsr loadsprite
    #ldi16 r0, sprite1addr
    lda #49
    ;jsr loadsprite
    #ldi16 r0, sprite2addr
    lda #50
    ;jsr loadsprite

    ;jsr loadsid
    jsr clrdiskiomem
    jsr enablerasterint
    jsr enablesscolirq
    jsr disablenmi
    jsr playreadysound

waittostart
;Joystick auslesen
    lda $dc00       
    and #%00011111 
;nicht gedrueckt?
    cmp #%00011111  
;weiter warten
    beq waittostart 
    
;starte Spiel  
;start scrolling away from start screen
    #poke gameflags, 2
    jsr initfuel
    jsr enablesnd
    jsr initstars

;reset collision status
    #poke $d01e, 0

gameloop

;Update stars
    lda gameflags
    and #4
    bne skipstarplace
smcplacestars
    jsr placestars

skipstarplace
    lda starposmapptr
    cmp #250
    bne skipstarmove
    #poke starposmapptr, 0
    lda #4
    ora gameflags
    sta gameflags
    jsr movestarsleft

skipstarmove
    lda starposmapptr
    cmp #240
    bne refrashscore
    ;jsr spawnnewstar
    lda gameflags
    eor #4
    sta gameflags
    lda #<spawnnewstar
    sta smcplacestars+1
    lda #>spawnnewstar
    sta smcplacestars+2

refrashscore
    jsr dispscore

;Determine time to move
checkmove
    inc movetimer
    lda moveth
    cmp movetimer
    bcc setmove
    jmp checkcollision

setmove
    lda #1
    ora gameflags
    sta gameflags
    lda #0
    sta movetimer


;if moveflag set move
;else skip moveloop
checkttm
.block
    lda gameflags
    and #1
    bne gomove
    jmp checkcollision

gomove
    lda #254
    and gameflags
    sta gameflags
.bend


moveloop
spawnsprites
.block
    lda spawntimer
    ;100 bewegt?
    cmp #100            
    ; nein, Timer erhoehen
    bcc updatetimer    
    ; Timer zurücksetzen
    lda #0              
    sta spawntimer

    ; Nächstes Sprite
    lda currentsprite
    ; ueber Sprite 5 
    cmp #6              
    bcc spawnsprite
    ; ja, zurück zu Sprite 1
    lda #1              
    sta currentsprite
    jmp spawnsprite

updatetimer
    inc spawntimer
    jmp movesprites

spawnsprite
    lda $dc04           
    sec
    sbc #30             
    cmp #206            
    bcs spawnsprite     
    adc #30             
    sta spritetemp      

; set xposition
    lda currentsprite
    asl
    tax
    lda #65
    sta $d000,x

    ldx currentsprite
    lda spritebitmask, x
    ora $d010
    sta $d010

;set yposition
    lda currentsprite
    asl
    tax
    lda spritetemp
    sta $d001,x

    ldy currentsprite
    ; hole Bitmask
    lda spritebitmask, y  
    ; Setze Bit
    ora $d015           
    sta $d015

    lda secondenemy
    beq extraasteroid
    jmp skipextraenemy

extraasteroid
    lda $dc04           
    sec
    sbc #30             
    cmp #206            
    bcs extraasteroid    
    adc #30             
    sta fueltemp     

    lda #65           
    sta 6*2+$d000   
    lda #$40
    ora $d010
    sta $d010

    lda fueltemp   
    sta 6*2+$d001

    lda #$40           
    ora $d015
    sta $d015         

    lda $dc04
    and #$03            
    clc
    adc #5
    sta secondenemy

skipextraenemy
    lda fueltimer
    beq fuelspawn
    jmp skipfuel

fuelspawn
    lda $dc04          
    sec
    sbc #30            
    cmp #206           
    bcs fuelspawn     
    adc #30            
    sta fueltemp      

    lda #65             
    sta 7*2+$d000   
    lda #$80
    ora $d010
    sta $d010

    lda fueltemp        
    sta 7*2+$d001

    lda #$80           
    ora $d015
    sta $d015          

    lda $dc04
    and #$03            
    clc
    adc #5
    sta fueltimer


skipfuel
    inc currentsprite  
    inc spawntimer     
    dec secondenemy    
    dec fueltimer      

movesprites
    #movespriteleft 1
    #movespriteleft 2 
    #movespriteleft 3
    #movespriteleft 4
    #movespriteleft 5
    #movespriteleft 6
    #movespriteleft 7
    
end
.bend

inputloop
.block
up
    lda 56320
    and #1
    bne down
    dec $d001
    jsr reducefuel
    jsr incscore
    jsr incspeed

    down
    lda 56320
    and #2
    bne checkcollision
    inc $d001
    jsr reducefuel
    jsr incscore
    jsr incspeed
.bend

checkcollision
.block

;check for collision with enemy
    lda $d01e
    and #$7e
    bne enemycollision

;check for collision with fuel
    lda $d01e
    and #$80
    bne fuelcollision
    jmp nocollision

enemycollision
    lda $d01e
    and #1
    .ifne includetests
        beq ghostcollision
    .endif
    .ifeq includetests
        beq nocollision
    .endif
    #poke 56296, 1
    jmp gameover


;Those caused a lot of trouble in 1.0
.ifne includetests
ghostcollision
    #poke 56296, 5
    #poke 53280, 1
    jmp nocollision
.endif

fuelcollision
;disable sprite colided with
;and add fuel
    eor $d015
    sta $d015
    jsr addfuel
    lda #0
    sta $d01e

nocollision
.bend

;loop around!
jmp gameloop

gameover
jsr disablesnd
jsr enablenmi

;Clear stack
#fmb stackstart, stackend, $00

;sshss = show save high score screen
sshss
;Disable all sprites
    #poke $d015, 0 
    jsr basiccls

.ifne includetests
    #ddbts
.endif

;Set border color
    #poke 53280, 0

;Set background color
    #poke 53281, 0
    
.ifeq includechargen
    jsr encharrom
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

;Load scores from disk
    jsr clrdiskiomem
    jsr loadhighscores

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

;Set text color
    #fillcolorram 7
    #poke 646, 7

printtyfps
;Print thank you for playing string
    #print tyfps

;Print score
    #print playerscorestr
    #crlf
    #unpackbcd score+2, sca, sca+1
    #bcdtoascii sca, sca
    #bcdtoascii sca+1, sca+1
    #unpackbcd score+1, sca+2, sca+3
    #bcdtoascii sca+2, sca+2
    #bcdtoascii sca+3, sca+3
    #unpackbcd score, sca+4, sca+5
    #bcdtoascii sca+4, sca+4
    #bcdtoascii sca+5, sca+5
    #mov $400+40+15, sca
    #mov $400+40+16, sca+1
    #mov $400+40+17, sca+2
    #mov $400+40+18, sca+3
    #mov $400+40+19, sca+4
    #mov $400+40+20, sca+5

;Print reason for death
    lda 56296
    cmp #2
    beq fueldeath
    jmp enemydeath

fueldeath
    #print fueldeathstr
    #crlf
    jmp getuserinput

enemydeath
    #print enemydeathstr
    #crlf

getuserinput
;Get name from user
    #print enternameprompt
    #nullinput namearea
    #crlf

;Get year from user
    #print ecyp
    #nullinput yeararea
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
    #tabfive
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
    
jsr savehighscores

.ifne includetests
    #ddbts
.endif

;Wait for keyboard input
;Output
;Input Matrix keycode in X
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
    tax
    #poke 198, 0
.bend

displayqrcode
    jsr basiccls
    jsr encharrom
    jsr encharset1
    jmp loadqrcode
    rts

;Please put game mechanic
;subrotines here.

;increase game speed
incspeed
.block
    lda moveth
    beq done

;Speed control logic is here
    lda score+1
    cmp scorecp
    beq done
    lda moveth
    sec
    sbc #10
    cmp #gamespeedlimit
    bcs storemoveth
    lda #gamespeedlimit
storemoveth
    sta moveth
    lda score+1
    sta scorecp

.ifne includetests
    clc
    adc #$5f
    sta $405
.endif
done
    rts
.bend

;------------------------------

.include "vicsubs.asm"
.include "dataflowsubs.asm"
.include "interrupts.asm"
.include "disksubs.asm"
.include "fuelbar.asm"
.include "score.asm"
.include "sound.asm"
.include "stars.asm"

;Data
playerscorestr
.null "Your score is: "

fueldeathstr
.null "You died from lack of fuel"

enemydeathstr
.text "You died from colliding with a "
.null "snowman."

;tyfps = thank you for playing string
tyfps
.text "Thank you for playing."
;line end
.byte $0d
.byte $00

enternameprompt
.text "Please "
.null "enter your name? "

;ecyp = enter current year prompt
ecyp
.null "and the current year? "

namestring
.null "Name: "

yearstring
.null "Year: "

scorestring
.null "Score: "

; Timer fur das 60-Pixel-Intervall
spawntimer .byte 0
secondenemy .byte 0
fueltimer .byte 0
; Temporare Variable fuer den Y-Wert
spritetemp .byte 0   
currentsprite .byte 2
spritebitmask
    .byte 1, 2, 4, 8, 16, 32, 64, 128  

;Controls game speed
;increase moveth
;to decrease game speed.
movetimer .byte 0
moveth .byte gamespeedmin
scorecp .byte 0
fueltemp .byte 0

;Statically loading assets
*=sprite0addr
.binary "assets/sprite0", 2

*=sprite1addr
.binary "assets/sprite1", 2

*=sprite2addr
.binary "assets/sprite2", 2

;*=$0400
;.binary "assets/screend", 2

*=charsetstart
.binary "assets/chargend"

*=$3000
.binary "assets/sid", 2
