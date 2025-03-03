
playsound
         sei

         lda #$7f     ;turn off cia
         sta $dc0d
         sta $dd0d

;---------- init Music -----------------

         #poke sndenabled, 1

         lda #0
         tax
         tay
         jsr sidstart

         cli
         rts

;---------- Sound Interrupt ------------
srirq
         ; set bit 0 in ISR to ack irq
         inc $d019

.ifne includetests
         inc $d020
.endif

        lda sndenabled
        beq skip


         ; play music
         jsr sidstart + 6


.ifne includetests
         dec $d020
.endif
         ; Restores A,X,Y register and
         ; CPU flags before returning
skip         
        jmp $ea31

sndenabled
        ;boolean for sound toggle
        .byte $0  

disablesound
        sei
        #poke sndenabled, 0
        #poke $d404, 0; deactivate Voice1
        #poke $d40b, 0; deactivate Voice2
        #poke $d412, 0; deactivate Voice3
        cli
        rts

enablesound
        sei
        #poke sndenabled, 1
        ; reinitialize sound
        lda #0
        tax
        tay
        jsr sidstart
        cli
        rts

disrasterirq
        sei
        lda #$00   ; disable raster
        sta $d01a  ; interrupt
        cli
        rts
