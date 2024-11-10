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

*=$810 ;2064

.include "zeropage-map.asm"
.include "kernal-map.asm"
.include "basic-map.asm"
.include "df-macros.asm"
.include "math-macros.asm"

.ifne includeTests
    .include "disktests.asm"
.endif

jmp init

init

gameloop
    jmp showSaveHighScoreScreen
jmp gameloop

showSaveHighScoreScreen
    jsr BasicCls

.ifne includeTests
    #dumpDiskBufferToScreen
.endif

    #poke 53272, 23; set charset to 2

    ;Load scores from disk
    jsr clearDiskIoMemory
    jsr LoadHighScores
.ifne includeTests
    #dumpDiskBufferToScreen
.endif
    lda #0
    cmp eorp
    bne skipCleanupForSubsequent
    cmp eorp +1
    bne skipCleanupForSubsequent

;Cleaning twice for the first score
;written to disk helps erase garbage
;handed to us by the failed load attempt
    jsr clearDiskIoMemory

    skipCleanupForSubsequent
.ifne includeTests
    #dumpDiskBufferToScreen
.endif
    #print ThankYouForPlayingString

;Get name from user
    #print EnterNamePrompt
    #nullinput nameArea
    #crlf
;Get year from user
    #print EnterCurrentYearPrompt
    #nullinput yearArea
    #crlf

;Get score from user
    #print EnterScorePrompt
    #nullinput scoreArea
    #crlf

;Debug!!!!
.ifne includeTests
    #dumpDiskBufferToScreen
.endif
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

    #dumpDiskBufferToScreen

    jsr SaveHighScores

    #dumpDiskBufferToScreen

    ;Load scores from disk
    jsr LoadHighScores
.ifne includeTests
    #dumpDiskBufferToScreen
.endif
;Debug!!!
    #print iSavedString
    #crlf

    #print ScoreString
    #print recListStart
    #crlf
    
    #print CurrentYearString
    #print recListStart+scoreLength
    #crlf

    #print NameString
    #print recListStart+scoreLength+yearLength
    #crlf

    #dumpDiskBufferToScreen
    rts

.include "disksubs.asm"
.include "dataflowsubs.asm"
.include "vicsubs.asm" ;error in here

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

iSavedString
.null "I saved"
