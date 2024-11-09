;---------------------------------------
;This file handles all disk io
;Saving, loading,
;complaining about melfunctions
;you name it

;Tina Guessbacher 2024

;---------------------------------------
;Constants

ActionKernalLoad = 0
ActionKernalSave = 1

LoadToAdressInFile = 0
LoadToAddressInAX = 1

DataStart = 1024
DataLength = 40 * 25
DataEnd = DataStart + DataLength + 1

primery_iec_channel_address = 2
device = 8
seconday_address_read_to_xy = 0
seconday_address_write = 1
seconday_address_read_to_prg = 2

;--------------------------------------
;Marcos

;lfd = LoadFileFromDisk(/1,/2,/3,/4,/5)
;Input
;\1 = logical file number
;\2 = device number
;\3 = filename pointer
;\4 = filename_length (less then 40)
;\5 = (0 prg file addr, else r0/r1 addr)
;Output
;carry set on error with A = error code
lfd .macro
    lda #\1
    ldx #\2
    ldy #\5
    jsr KernalSetlfs
    lda #\4
    ldx #<\3
    ldy #>\3
    jsr KernalSetnam
    lda #0
    .ifeq \5
        ldx #0
        ldy #0
    .endif
    .ifne \5
        ldx r0
        ldy r1
    .endif
    jsr KernalLoad
.endm

;sfd SaveFileToDisk(/1,/2,/3,/4,/5)
;\1 = logical file number
;\2 = device number
;\3 = filename pointer
;\4 = filename_length (less then 40)
;r0 = LB of DataStart
;r1 = HB of DataStart
;r2 = LB of DataEnd
;r3 = HB of DataEnd
;Output
;carry set on error with A = error code
sfd .macro
    lda #\1
    ldx #\2
    ldy #seconday_address_write
    jsr KernalSetlfs
    lda #\4
    ldx #<FilenameStart
    ldy #>FilenameStart
    jsr KernalSetnam
    ldx r2
    ldy r3
    lda #<r0
    jsr KernalSave
    rts
.endm

;Rotines

LoadHighScores
    #lfd 2, 8, FilenameStart, 11, 2, 0
    rts

SaveHighScores
    #poke r0, <DataStart
    #poke r1, >DataStart
    #poke r2, <DataEnd
    #poke r3, >DataEnd
    #sfd 2, 8, FilenameStart, 11
    rts

SaveError
    sta 53280
    jsr $BDCD
    rts
    
;--------------------------------------
;Tests
.ifne IncludeTests

TestHighScoreSaving
    #poke 53280, 1
    jsr SaveHighScores
    rts

TestHighScoreLoading
    #poke 53280, 0
    jsr LoadHighScores
    rts
.endif
;---------------------------------------
;Data

FilenamePrefixOverwrite
    .byte $40
FilenamePrefix
    .text "0:"
FilenameStart
    .text "high scores"
FilenameSuffix
    .text ",s,w"
FilenameEnd
    .byte 0

PlayerScore
.word 0
