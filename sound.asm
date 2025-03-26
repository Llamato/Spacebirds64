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


;------------ PlayReadySound -----------
; STOPS the game and plays Start Sound
; assumes that NO other sound is playing
;---------------------------------------
playreadysound
.block
;prepare sid
        #fmb $d400, $d424, 0
        #poke $d400+5, $0f ;AD
        #poke $d400+6, 128 ;SR

;volume to max
        #poke $d400+24, 15 

;set frequency for note 1
        lda #$11
        sta $d400+1 ; hi freq
        lda #$50
        sta $d400   ; lo freq

;play note 1
        lda #%00100001  
        sta $d400+4
        lda #7
        jsr delay
        lda #0
        sta $d400+4

;wait for 7/60 seconds
        lda #7
        jsr delay

;play note 1
        lda #%00100001  
        sta $d400+4
        lda #7
        jsr delay
        lda #0
        sta $d400+4

;set frequency for note 2
        lda #$22
        sta $d400+1 ; hi freq
        lda #$a0
        sta $d400   ; lo freq

;play note 2 
        lda #%00100001  
        sta $d400+4
        lda #7
        jsr delay
        lda #0
        sta $d400+4

        rts
.bend

;------------ PlayCrashSound -----------
; STOPS the game and plays Start Sound
; assumes that NO other sound is playing
;---------------------------------------
playcrashsound
.block
;prepare sid
        #fmb $d400, $d424, 0
        #poke $d400+5, $0f ;AD
        #poke $d400+6, 128 ;SR

;volume to max
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
loop    dex
        sta $d400+24
        lda #4
        jsr delay
        txa
        bne loop

; deactivate voice 1
        lda #0
        sta $d400+4 
        
        rts
.bend

;------------ delay --------------------
; a = count of 1/60 seconds
;---------------------------------------
delay
.block
        clc
        adc $a2
loop    cmp $a2
        bne loop
        rts
.bend


;boolean for sound toggle
sndenabled .byte $0  
