;---------- Draw Scores Label ------------------
scores_label
    ldx #0                    ; X register for loop
label_loop
    lda scores_text, x        ; Load character from "SCORES: "
    sta $0400 + 107, x      ;Store it on screen memory
    lda #1
    sta $d800 + 107, x        ;Set color to white
    inx
    cpx #6     ;"SCORES: " is 7 characters long
    bne label_loop
    rts

scores_text
   .byte 69, 53, 65, 68, 55, 69
   ;.byte $45,53, $41, $44, 55, $45
    .byte 0


; Initialize Score Subroutine
initscore
    lda #0
    sta score          ; Initialize low byte
    lda #0
    sta score+1        ; Initialize high byte
    lda #0
    sta score+2        ; Initialize high byte
    lda #0
    sta score+3        ; Initialize high byte
    lda #0
    sta score+4        ; Initialize high byte
    lda #0
    sta score+5        ; Initialize high byte
    rts

; Update Score Subroutine for increments divisible by 10
updatescore
    clc
    lda score          ; Load current score (low byte)
    adc #$48            ; Add 10 (increment value)
    sta score          ; Store updated low byte
    bcc update_high1   ; Branch if no carry
    inc score+1        ; Increment high byte if carry occurred
update_high1
    lda score+1        ; Load high byte
    adc #0             ; Add carry (if any)
    sta score+1        ; Store updated high byte
    bcc update_high2   ; Branch if no carry
    inc score+2        ; Increment next high byte if carry occurred
update_high2
    lda score+2        ; Load next high byte
    adc #0             ; Add carry (if any)
    sta score+2        ; Store updated next high byte
    bcc update_high3   ; Branch if no carry
    inc score+3        ; Increment highest byte if carry occurred
update_high3
    lda score+3        ; Load highest byte
    adc #0             ; Add carry (if any)
    sta score+3        ; Store updated highest byte
    bcc update_high4   ; Branch if no carry
    inc score+4        ; Increment next highest byte if carry occurred
update_high4
    lda score+4        ; Load next highest byte
    adc #0             ; Add carry (if any)
    sta score+4        ; Store updated next highest byte
    bcc update_high5   ; Branch if no carry
    inc score+5        ; Increment highest byte if carry occurred
update_high5
    lda score+5        ; Load highest byte
    adc #0             ; Add carry (if any)
    sta score+5        ; Store updated highest byte
    jsr displayscore   ; Update the score display
    rts

; Display Score Subroutine remains the same
displayscore
    ldx #0
    lda score
    jsr display_digit  ; Display low byte of score
    lda score+1
    jsr display_digit  ; Display next byte of score
    lda score+2
    jsr display_digit  ; Display next byte of score
    lda score+3
    jsr display_digit  ; Display highest byte of score
    lda score+4
    jsr display_digit  ; Display next highest byte of score
    lda score+5
    jsr display_digit  ; Display highest byte of score
    rts


display_digit
    pha
    lsr
    lsr
    lsr
    lsr                ; Divide by 10 to get the decimal value
    adc #$30           ; Add offset for display (not ASCII)
    sta $0400 + 114, x ; Display digit at screen memory location (e.g., $0400+x)
    lda #1             ; Set character color to white
    sta $d800 + 114,x        ; Set color RAM memory location (e.g., $d800+x)
    inx
    cpx #5     ;is 5 characters long
    pla
    rts
