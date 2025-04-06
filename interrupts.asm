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
        .ifne includetests
                inc 53280
        .endif
        inc $d019

        lda sndenabled
        beq nosound

        jsr sidstart + 6

nosound
        #setuprasterint 0, handlemove
        .ifne includetests
                dec 53280
        .endif
        jmp $ea31





; ----- movement ISR ----------------
handlemove
        .ifne includetests
                inc 53280
        .endif
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
;Addenum
;Well actually,
;It turns out to not be a problem
;at all. At least not in this specific
;instance
        jsr initscore
        jsr initfuel

scrollcolumnend
        sty scrollcolumn
        #pull r1
        #pull r0
        jmp isrend

hwscroll
        dec $d016

noscroll
        inc starposmapptr
isrend   
.bend
        #setuprasterint 100, soundisr
        .ifne includetests
                dec 53280
        .endif
        jmp $ea81

;--------;Enable restart on NMI--------
enablenmi
        #poke 792, <nmisr
        #poke 793, >nmisr
        rts

;--------;disabled restart on NMI------
disablenmi
.ifeq webversion
        #poke 792, <$fe47
        #poke 793, >$fe47
.endif
.ifne webversion
        #poke 792, <nothingnmi
        #poke 793, >nothingnmi
.endif
        rts

;---;Restart Interrupt handler---------
nmisr
;Reset gamestate
;Calling this here. Breaks the software
;for some reason
        ;jsr disablesnd

;undo smc
        lda #<placestars
        sta smcplacestars+1
        lda #>placestars
        sta smcplacestars+2
        #fmb stackstart, stackend, $00
        cli
        jmp init

nothingnmi
        rti
