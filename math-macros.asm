mul .macro 
    LDA #0
    LDX  #$8
    LSR  \1
loop
    BCC  no_add
    CLC
    ADC  \2
no_add
    ROR
    ROR  \1
    DEX
    BNE  loop
    STA  \2
.endm
