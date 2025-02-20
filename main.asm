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
.include "math-macros.asm"

.ifne includetests
    .include "disktests.asm"
.endif

;Setup gamestate
    #poke gameflags, 0
    #poke scrollcolumn, 0
sei
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

;Set double height for enemy sprites 0-4
;and single height for fuel sprites 5-7
    #poke $d017, $1f

;Set double width for enemy sprites 0-4
;and single width for fuel sprites 5-7
    #poke $d01d, $1f

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


;fuel 1
;Setup sprite 5 for address $2040
    #poke $07fd, $82
    #setspritecolor 5, 1
    ;#setspritepos 5, 359, 125
    ;#enablesprite 5

;fuel 2
;Setup sprite 6 for address $2040
    #poke $07fe, $82
    #setspritecolor 6, 1
    ;#setspritepos 6, 400, 190
    ;#enablesprite 6

;fuel 3
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
    jsr loadsprite
    #ldi16 r0, sprite1addr
    lda #49
    jsr loadsprite
    #ldi16 r0, sprite2addr
    lda #50
    jsr loadsprite

;Add stars to background
    ;lda #69
    ;ldx #10
    ;jsr placestars


;Setup interrupts

    #setuprasterint 0, handleirq

    ; enable raster interrupt
    lda #$01  
    sta $d01a 

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
    jsr clrdiskiomem
    cli


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

gameloop

;refrash score display
    jsr dispscore

;if moveflag set move
;else skip moveloop
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
    
;move enemies one to the left
moveloop
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
    ; ueber Sprite 7 
    cmp #8              
    bcc spawnsprite
    ; ja, zurück zu Sprite 1
    lda #1              
    sta currentsprite

spawnsprite
    ; Zufallszahl CIA-Timer
    lda $dc04           
    ; Begrenzen auf 0-127
    and #$7f            
    ; Mindestens Y = 50 setzen
    adc #50             
    ; Speichern
    sta spritetemp      



; set xposition
    lda currentsprite
    asl
    tax
    lda #65
    sta $d000,x

;also set high byte of xposition
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
    ; naechster Sprite
    inc currentsprite 

updatetimer
    inc spawntimer

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
    down
    lda 56320
    and #2
    bne checkcollision
    inc $d001
    jsr reducefuel
    jsr incscore

.bend

checkcollision
.block
;reset collision status
    lda #$00
    sta $d01e

;check for collision with enemy
    lda $d01e
    and #$1e
    bne enemycollision

;check for collision with fuel
    lda $d01e
    and #$f0
    bne fuelcollision
    jmp nocollision

enemycollision
    jmp gameover

;potential bug. Fuel only added
;once if multiple fuels collide 
;within one frame (loop cycle)
fuelcollision
.ifne includetests
    pha
    lsr
    lsr
    lsr
    lsr
    sta 53280
    pla
.endif
;disable sprite colided with
;and add fuel
;bug in fuelbar.addfuel?
    eor $d015
    sta $d015
    lda fuel
    clc
    adc #16
    cmp #64
    bcs fuelfull
    sta fuel
    jmp nocollision

fuelfull
    lda #64
    sta fuel
nocollision
.bend

;loop around!
jmp gameloop


gameover
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
    #nullinput namearea
    #crlf

;Get year from user
    #print ecyp
    #nullinput yeararea
    #crlf

;Get score from memory
    #unpackbcd score+2, sca, sca+1
    #bcdtoascii sca, sca
    #bcdtoascii sca+1, sca+1
    #unpackbcd score+1, sca+2, sca+3
    #bcdtoascii sca+2, sca+2
    #bcdtoascii sca+3, sca+3
    lda score+3
    lsr
    lsr
    lsr
    lsr
    sta sca+4
    #bcdtoascii sca+4, sca+4

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

;Interrupt service rotine
handleirq
; set bit 0 in ISR to ack IRQ
inc $d019 
.block
    lda #1
    ora gameflags
    sta gameflags
    and #2
    beq noscroll
    
scrollscreen
    lda $d016
    and #$07
    bne hwscroll

fillcolumn
;calculate start address
    #push r0
    #push r1
    #ldi16 r0, txtscreenstart

;loop though lines and fill in
;blanks
    ldy scrollcolumn
    ldx #25
fillloop
    lda #23
    sta (r0), y
    #add16i r0, 40
    dex
    bne fillloop
    iny
    cpy #40
    bne scrollcolumnend

stopscrolling
    #poke scrollcolumn, 255
    lda gameflags
    and #253
    sta gameflags
;This is a bad way to handle things.
;Let's see if we can move this outside
;of ISR to prevent IRQ flooding.
    jsr initscore
    jsr initfuel

scrollcolumnend
    sty scrollcolumn
    #pull r1
    #pull r0
    jmp noscroll

hwscroll
    dec $d016

noscroll

; JUMP to KERNAL return routine that
; restores registers/status and returns
jmp $ea31


.bend

;Please put game mechanic
;subrotines here.

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

;---------------------------------------
;Complex Bug in here
;Breaks upon sprite2 load
;Might require full recode...

;Place background stars
;procedually with seed and density
;with the density given in
;stars per screen page (40x25 chars).
;Input
;A = star density (amount of stars)
;X = seed
;Output
;Stars on screen
placestars
.block
setup
    pha
    #ldi16 r2, 1024
    #poke r1, 0
    pla
    sta r0
    pha
    lda #0
    sta r1
    #ldi16 r2, 1024
    phx
    ;#div16 r2, r0, r4, r6
    ldx #0
    ldy #0
placestar

    #add16 r2, r0

clamp
checklow
    lda r2
    cmp #>1024
    beq checklowlb
    bcc outlow
    bcs notlow

checklowlb
    lda r2
    cmp #<1024
    beq eqlow
    bcc outlow
    bcs notlow

notlow
checkhigh
    lda r3
    cmp #>2024
    beq checkhighlb
    bcc in
    bcs outhigh

checkhighlb
    lda r2
    cmp #<2024
    beq eqhigh
    bcc in
    bcs outhigh

in
    lda #78
    sta (r2),y
    jmp next

outhigh
    #sub16i r2, 1000
    jmp clamp
eqhigh
    jmp in; temp

outlow
    #add16i r2, 1000

eqlow
    jmp in; temp

next
    inx
    cpx r4+1
    bne placestar
    plx
    pla
    rts
.bend
;------------------------------

.include "vicsubs.asm"
.include "dataflowsubs.asm"
.include "playsid.asm"
.include "disksubs.asm"
.include "fuelbar.asm"
.include "score.asm"
;.include "mathsubs.asm"

;Data
;tyfps = thank you for playing string
tyfps
.text "Thank you for playing"
;line end
.byte $0d
.byte $00


enternameprompt
.text "Please "
.null "enter your name? "

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

; Timer fur das 60-Pixel-Intervall
spawntimer .byte 0
; Temporare Variable fuer den Y-Wert
spritetemp .byte 0   
currentsprite .byte 2
spritebitmask
    .byte 1, 2, 4, 8, 16, 32, 64, 128  
