IncludeTests = 0
*=$0801
;Basic starter jumping to $1000 (4096)
.byte $0C,$08,$0A,$00,$9E,$20,$34,$30
.byte $39,$36,$00,$00,$00

*=$1000

.include "zeropage-map.asm"
.include "kernal-map.asm"
.include "df-macros.asm"
.include "math-macros.asm"

jmp init

init


gameloop

jmp gameloop

.include "disksubs.asm"
.include "vicsubs.asm"
