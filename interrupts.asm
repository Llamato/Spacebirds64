;----- setup raster interrupt -----
enablerasterint
sei

;turn off cia
        lda #$7f
        sta $dc0d
        sta $dd0d

;set scanline for raster interrupt
        #setuprasterint 100, soundisr

;enable raster interrupt
        lda $d01a
        ora #$01  
        sta $d01a  

cli
rts


;----- disable raster interrupt -----
disrasterirq
        sei
        lda #$00   
        sta $d01a  
        cli
        rts




enablesscolirq
sei
        lda $d01a
        ora #$04
        sta $d01a
cli
rts

; ----- sound  ISR ----------------
soundisr
        php
        pha
        #ackvicirq 1
        plp
        pla

        lda sndenabled
        beq nosound

        jsr sidstart + 6

nosound
        #setuprasterint 0, handlemove
        jmp $ea31





; ----- movement ISR ----------------
handlemove
        php
        pha
        #ackvicirq 1
        plp
        pla

.block
        lda gameflags
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


.bend
        #setuprasterint 100, soundisr
        jmp $ea81


;sprite-sprite collision isr------------
php
pha
sscolirq
#ackvicirq 3
#pushx
#pushy
.block
;check for collision with enemy
    lda $d01e
    and #$1e
    bne enemycollision

;check for collision with fuel
    lda $d01e
    pha
    and #$f0
    bne fuelcollision
    jmp nocollision

enemycollision
    ;reset collision status
    lda #$00
    sta $d01e
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
        pla
        ;ora #1
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
;reset collision status
        lda #$00
        sta $d01e
.bend
#pully
#pullx
pla
plp
rti
