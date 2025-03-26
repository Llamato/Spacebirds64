;--------------------------------------
;This file contains all interrupt
;service rotines.
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
        inc $d019

        lda sndenabled
        beq nosound

        jsr sidstart + 6

nosound
        #setuprasterint 0, handlemove
        jmp $ea31





; ----- movement ISR ----------------
handlemove
        inc $d019

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
