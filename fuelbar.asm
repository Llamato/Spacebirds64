;---------- init fuel ------------------
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
    lda #91
    sta $0400 + 951, x

    ; set the color
    lda #$05
    sta $d800 + 951, x

    inx
    ;fuel bar is 8 characters wide
    cpx #8
    bne loop

    ; draw border on the right side
    lda #84
    sta $0400 + 959

    ; set color of right border
    lda #$01
    sta $d800 + 959

    ;drawleftborder
    lda #92
    sta $0400 + 950

    ; set color of left border
    lda #$01
    sta $d800 + 950


    ldx #0
drawtopborder
    ; draw top border
    lda #93
    sta $0400 + 911, x

    ; set color of top border
    lda #$01
    sta $d800 + 911, x

    inx
    cpx #8
    bne drawtopborder


    ldx #0
drawbottomborder
    ; draw bottom border
    lda #94
    sta $0400 + 991, x

    ; set color of bottom border
    lda #$01
    sta $d800 + 991, x

    inx
    cpx #8
    bne drawbottomborder

    rts
.bend


;---------- reduce fuel ----------------
; reduces fuel by 1 and 
; updates the fuel bar
;---------------------------------------
reducefuel
.block
    inc fuelscaler
    lda fuelscaler
    ; scale consumption down to 1/8
    and #$010
    beq end ; do nothing
    ; reset scaler
    lda #$00
    sta fuelscaler

    lda fuel
    beq outoffuel
    dec fuel

    jsr updatefuelbar

end
    rts

outoffuel
    ; game over
    ;jmp gameover

    ; -- for debugging remove 
    ; -- if we have gameOver
    jsr addfuel
    ; -- end debugging

    rts
.bend


;---------- add fuel -------------------
; adds 16 to fuel and updates the  bar
;---------------------------------------
addfuel
.block
    lda fuel
    adc #16 
    tax
    ; if fuel is greater than max
    ; set fuel to max
    and #64
    bne maxfuel
    txa
    sta fuel
    jsr updatefuelbar
    rts
maxfuel
    lda #64
    sta fuel
    jsr updatefuelbar
    rts

.bend



;---------- update fuel bar ------------
; draws the fuel bar according to the
; current fuel value
;---------------------------------------
updatefuelbar
.block
jsr setfuelcolor
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
    sta $0400 + 951, x

    ; set the color
    lda fuelcolor
    sta $d800 + 951, x

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
    sta $0400 + 951, x

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
sta $0400 + 951, y

;set the color
lda fuelcolor
sta $d800 + 951, y

end
    rts
.bend


;---------- set fuel color -------------
; sets the color of the fuel bar
;---------------------------------------
setfuelcolor
.block
lda fuel
cmp #16
bcc setlowcolor
cmp #32
bcc setmidcolor
lda #$05 ; green
sta fuelcolor
rts
setlowcolor
lda #$02 ; red
sta fuelcolor
rts
setmidcolor
lda #$07 ; yellow
sta fuelcolor
rts

.bend


;---------- fuel bar data --------------
; max fuel is 64
;---------------------------------------
fuel .byte  64
fuelscaler .byte 0
fuelcolor .byte 5
