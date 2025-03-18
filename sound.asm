;---------- disable Sound -----------
disablesnd 
        #poke sndenabled, 0

; deactivate all three voices
        #poke $d404, 0     
        #poke $d40b, 0     
        #poke $d412, 0     
        rts


;---------- enable Sound -----------
enablesnd
        #poke sndenabled, 1

; Initialize Player
; with Track Number 0
        lda #0
        tax
        tay
        jsr sidstart

        rts


;----------- PlayCrashSound ------------
; STOPS the game and plays Crash Sound
; assumes that NO other sound is playing
;---------------------------------------
playcrashsound
.block
        ; prepare sid
        #fmb $d400, $d424, 0
        #poke $d400+5, $0f ;AD
        #poke $d400+6, 128 ;SR

        ; set volume to max
        #poke $d400+24, 15 

        ; set frequency
        lda #$10
        sta $d400+1 ; hi freq
        lda #$c8 
        sta $d400   ; lo freq

        ; set waveform to noise
        ; and activate voice 1 
        lda #$81 
        sta $d400+4

        ; reduce volume step by step
        ldx #15
volumeloop
        dex
        sta $d400+24
        jsr wait
        bne volumeloop

        ; deactivate voice 1
        #poke $d400+4, 0
        rts

; wait for 20 * 255 cycles      
wait 
        txa
        pha

        ldx #20
outerwaitloop

        ldy #255
innerwaitloop
        dey
        bne innerwaitloop

        dex
        bne outerwaitloop

        pla
        tax
        rts
.bend

;boolean for sound toggle
sndenabled .byte $0  
