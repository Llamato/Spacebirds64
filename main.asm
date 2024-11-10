includeTests = 1
includeTestSave = 0
includeTestLoad = 1

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

    ;Load scores from disk
    jsr clearDiskIoMemory
    jsr LoadHighScores
    #ldi16 r0, diskBuffer
    #ldi16 r2, 1768
    lda #255
    sta r4
    jsr memcpy

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

;Debug!!!!
    #print YouEnteredString
    #crlf

    #print ScoreString
    #print scoreArea
    #crlf

    #print CurrentYearString
    #print yearArea
    #crlf

    #print NameString
    #print nameArea
    #crlf

;Save score to disk
    jsr appendHighscoreToDiskBuffer
    jsr SaveHighScores

    ;Load scores from disk
    jsr LoadHighScores
    #ldi16 r0, diskBuffer
    #ldi16 r2, $400
    lda #$FF
    sta r4
    jsr memcpy
    rts; temp

.include "disksubs.asm"
.include "dataflowsubs.asm"
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

YouEnteredString
.null "You entered"

NameString
.null "Name: "

CurrentYearString
.null "Current Year: "

ScoreString
.null "Score: "
