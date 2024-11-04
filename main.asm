*=$0801
.byte $0C,$08,$0A,$00,$9E,$20,$34,$30,$39,$36,$00,$00,$00

*=$1000

.include "zeropage-map.asm"
.include "kernal-map.asm"
.include "dataflow-macros.asm"
.include "math-macros.asm"

jmp init

init
jsr TestHighScoreSaving
jsr TestHighScoreLoading

gameloop

jmp gameloop

.include "disk-subrotines.asm"
.include "vic-subrotines.asm"