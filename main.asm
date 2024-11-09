includeTests = 1
*=2049
;BASIC starter (ldraddr $0801 / 2049)
;Load address for next BASIC line (2064)
.byte $0B, $08
;Line number (10)         
.byte $0A, $00
.byte $9E; SYS token
;PETCII for " 2064"
.byte $20, $32, $30, $36, $34
;End of BASIC line
.byte $00, $00
;End of BASIC program markers
.byte $00, $00, $00

*=2064

.include "zeropage-map.asm"
.include "kernal-map.asm"
.include "basic-map.asm"
.include "df-macros.asm"
.include "math-macros.asm"

jmp init

init

gameloop
    jmp showSaveHighScoreScreen
jmp gameloop

showSaveHighScoreScreen
    jsr BasicCls; Clear screen
;Move cursor to (0, 0)
    jsr BasicCursorHome
    #poke 53272, 23; set charset to 2
    #print ThankYouForPlayingString
;Get name from user
    #print EnterNamePrompt
    #input nameArea
    #crlf
;Get year from user
    #print EnterCurrentYearPrompt
    #input yearArea
    #crlf
;Get score from user
    #print EnterScorePrompt
    #input scoreArea
    #crlf

;Save score to disk
    jsr appendHighscoreToDiskBuffer
    jsr SaveHighScores

;Load scores from disk

rts; temp

.include "dataflowsubs.asm"
.include "disksubs.asm"
;.include "vicsubs.asm" ;error in here

;Data
ThankYouForPlayingString
.text "Thank you for playing"
.byte $0D; \r = line end 
.byte $00
EnterNamePrompt
.null "Please enter your name? "
EnterCurrentYearPrompt
.null "and the current year? "
EnterScorePrompt
.null "and your score for debugging? "
ThankYouString
.null "Thank you!"
