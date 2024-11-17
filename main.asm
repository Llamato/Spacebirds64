includetests = 0

*=2049
;BASIC starter (ldraddr $0801 / 2049)
;Load address for next BASIC line (2064)
    .byte $0b, $08
;Line number (10)         
    .byte $0a, $00
    .byte $9e; SYS token
;PETCII for " 2064"
    .byte $20, $32, $30, $36, $34
;End of BASIC line
    .byte $00, $00
;End of BASIC program markers
    .byte $00, $00, $00

*=$810 ;2064

.include "zeropage-map.asm"
.include "rom-map.asm"
.include "df-macros.asm"

add16i .macro
    lda \1
    clc
    adc #<\2
    sta \1
    lda \1 +1
    adc #>\2
    sta \1 +1
.endm

;.include "math-macros.asm"

.ifne includetests
    .include "disktests.asm"
.endif

jmp init

init

gameloop
    jmp sshss
jmp gameloop

;sshss = show save high score screen
sshss
    jsr basiccls

.ifne includetests
    #ddbts
.endif

;set border color
#poke 53280, 0
;set background color
#poke 53281, 0
;set basic text color
#poke 646, 7
;set charset to 2
#poke 53272, 23

    ;load scores from disk
    jsr clrdiskiomem
    jsr loadhighscores

.ifne includetests
    #ddbts
.endif

    lda #0
    cmp eorp
    bne scfs
    cmp eorp +1
    bne scfs

;Cleaning twice for the first score
;written to disk helps erase garbage
;handed to us by the failed load attempt
    jsr clrdiskiomem

    ;scfs = skip cleanup for subsequent
    scfs

.ifne includetests
    #ddbts
.endif

    #print tyfps

;Get name from user
    #print enternameprompt
    #nullinput namearea
    #crlf

;Get year from user
    #print ecyp
    #nullinput yeararea
    #crlf

;Get score from user
    #print esp
    #nullinput scorearea
    #crlf

;Save score to disk
    jsr addhstodb

;Print high score table to screen
.block ;print high scores table
;(game) design parameters

    theadcolor = 4; Pink
    tentrycolor = 1; White
    townentrycolor = 7; Yellow
    tabstopwidth = 4
    jsr basiccls; Clear screen

;print table header
    #poke 646, theadcolor
    #printlen scorestring, 5
    #tab
    #printlen yearstring, 4
    #tab
    #printlen namestring, 4
    #crlf

;print table entries
;set text color black
    #poke 646, 1

printtableentry
;print Score
    lda currrecptr
    ldy currrecptr +1
    jsr basicprintnull
    #tab
    #add16i currrecptr, scorelength 

;print Year
    lda currrecptr
    ldy currrecptr +1
    jsr basicprintnull
    #tab
    #add16i currrecptr, yearlength
    
;print Name
    lda currrecptr
    ldy currrecptr +1
    jsr basicprintnull
    #tab
    #add16i currrecptr, namelength
    #crlf

;Check for next record
;Optimized with Claude ai. Good stuff!
    ;Load high byte
    lda currrecptr +1
    ;Compare with high byte
    cmp eorp +1
    ;If eorp > currrecptr
    bcc jumppad
    ;If eorp < currrecptr
    bne done
    ;If high bytes
    lda currrecptr
    ;Compare with low byte
    cmp  eorp
    bcc jumppad
    ;If equal, continue
    beq done
    jmp done
jumppad; needed because of long branch
    jmp printtableentry
done
.bend

.ifne includetests
    #ddbts
.endif
    
    jsr savehighscores

.ifne includetests
    #ddbts
.endif
    rts

;.include "vicsubs.asm"
.include "dataflowsubs.asm"
.include "disksubs.asm"

;Data
;tyfps = thank you for playing string
tyfps
.text "Thank you for playing"
; line end
.byte $0d
.byte $00

enternameprompt
.text "Please "
.null "enter your name? "

;ecyp = enter current year prompt
ecyp
.null "and the current year? "

;esp = enter score prompt
esp
.text "and your score "
.null "for debugging? "

namestring
.null "Name: "

yearstring
.null "Year: "

scorestring
.null "Score: "

