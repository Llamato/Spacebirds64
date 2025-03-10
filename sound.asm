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

;boolean for sound toggle
sndenabled .byte $0  