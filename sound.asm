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




;------------ PlayReadySound -----------
; STOPS the game and plays Start Sound
; assumes that NO other sound is playing
;---------------------------------------
playreadysound
.block
; prepare sid
        #fmb $d400, $d424, 0
        #poke $d400+5, $0f ;AD
        #poke $d400+6, 128 ;SR

        ; set volume to max
        #poke $d400+24, 15 


; set frequency for note 1
        lda #$11
        sta $d400+1 ; hi freq
        lda #$50
        sta $d400   ; lo freq


; play note 1 
        lda #%00100001  
        sta $d400+4
        jsr wait
        lda #0
        sta $d400+4

;wait for next note
        jsr wait

; play note 1 
        lda #%00100001  
        sta $d400+4
        jsr wait
        lda #0
        sta $d400+4


; set frequency
        lda #$22
        sta $d400+1 ; hi freq
        lda #$a0
        sta $d400   ; lo freq
        

; play note 2
        lda #%00100001  
        sta $d400+4
        jsr wait
        lda #0
        sta $d400+4


; wait for 60 * 255 cycles      
wait 
        txa
        pha

        ldx #100
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

rts
.bend

;boolean for sound toggle
sndenabled .byte $0  
