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

    #poke 53280, 0; set border color
    #poke 53281, 0; set background color
    #poke 646, 7; set basic text color
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

;Save score to disk
    jsr appendHighscoreToDiskBuffer

;Print high score table to screen
.block ;print high scores table
;(game) design parameters‹
    tableHeaderColor = 4; Pink
    tableEntryColor = 1; White
    tableOwnEntryColor = 7; Yellow
    tabstopWidth = 4
    jsr BasicCls; Clear screen

;print table header
    #poke 646, tableHeaderColor
    #printNoneNull ScoreString, 5
    #tab
    #printNoneNull YearString, 4
    #tab
    #printNoneNull NameString, 4
    #crlf

;print table entries
    #poke 646, 1; set text color black

printTableEntry
;print Score
    lda curRecPointer
    ldy curRecPointer +1
    jsr BasicPrintNull
    #tab
    #add16i curRecPointer, scoreLength 

;print Year
    lda curRecPointer
    ldy curRecPointer +1
    jsr BasicPrintNull
    #tab
    #add16i curRecPointer, yearLength
;print Name
    lda curRecPointer
    ldy curRecPointer +1
    jsr BasicPrintNull
    #tab
    #add16i curRecPointer, nameLength
    #crlf

;Check for next record
;Optimized with Claude ai. Good stuff!
    lda curRecPointer +1 ; Load high byte of eorp
    cmp eorp +1 ; Compare with high byte of curRecPointer
    bcc jumppad  ; If eorp > curRecPointer, continue to print
    bne done     ; If eorp < curRecPointer, branch to done
    lda curRecPointer   ; If high bytes equal, load low byte of eorp
    cmp  eorp  ; Compare with low byte of curRecPointer
    bcc jumppad  ; If eorp > curRecPointer, continue to print
    beq done  ; If equal, continue to print
    jmp done
jumppad; needed because of long branch
    jmp printTableEntry
done
.bend

.ifne includeTests
    #dumpDiskBufferToScreen
.endif
    
    jsr SaveHighScores

.ifne includeTests
    #dumpDiskBufferToScreen
.endif
    rts

.include "disksubs.asm"
.include "dataflowsubs.asm"
.include "vicsubs.asm"

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

YearString
.null "Year: "

ScoreString
.null "Score: "

iSavedString
.null "I saved"
