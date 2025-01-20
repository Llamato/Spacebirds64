;---------- init fuel bar --------------
; sets  fuel to max 
; and draws the fuel bar
;---------------------------------------
initfuel
.block
;set fuel to max (64)
#poke fuel, 64
ldx #0
loop
    ; draw full characters
    lda #92
    sta $0400 + 911, x

    ; set the color
    lda #$02
    sta $d800 + 911, x

    inx
    ;fuel bar is 8 characters wide
    cpx #8
    bne loop

    ; draw border on the right side
    lda #84
    sta $0400 + 919

    ; set color of the border
    lda #$01
    sta $d800 + 919

    rts
.bend


;---------- reduce fuel ----------------
; reduces fuel by 1 and 
; updates the fuel bar
;---------------------------------------
reducefuel
.block
    lda fuel
    beq outoffuel
    dec fuel

;divide by 8 to know how many
;full characters we have to draw
    lda fuel
    lsr
    lsr
    lsr

    ; save the result in x and y
    tax 
    tay 

drawfullfuel
    cpx #0
    beq finishdrawing
    dex 

;draw full characters
    lda #92
    sta $0400 + 911, x

    ; set the color
    lda #$05
    sta $d800 + 911, x

    jmp drawfullfuel
finishdrawing


;transfer the division result to x
tya
tax
drawemptyfuel
    cpx #8
    beq finishdrawempty
;draw space -> empty fuel
    lda #23  
    sta $0400 + 911, x

    inx
    jmp drawemptyfuel

finishdrawempty

;get remainder {x AND (y-1)}
lda fuel
and #$07
beq end ;zero was already drawn

;draw the last character
;add offset to get the right character
adc #83
sta $0400 + 911, y

;set the color
lda #$07
sta $d800 + 911, y


end
    rts

outoffuel
    ; game over
    ;jmp gameover

    rts
.bend

;set fuel to max (64)
fuel .byte  64
