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
;Rotines

LoadHighScores
    lda #primery_iec_channel_address
    ldx #device
    ldy #seconday_address_read_to_prg
    jsr KernalSetlfs
    lda #FilenameSuffix-FilenameStart
    ldx #<FilenameStart
    ldy #>FilenameStart
    jsr KernalSetnam
    lda #0
    ldx #$00
    ldy #$00
    jsr KernalLoad
    bcs LoadError
    rts

LoadError
    sta 53281
    rts

SaveHighScores
    lda #primery_iec_channel_address
    ldx #device
    ldy #seconday_address_write
    jsr KernalSetlfs
    lda #FilenameSuffix-FilenameStart
    ldx #<FilenameStart
    ldy #>FilenameStart
    jsr KernalSetnam
    #poke r0, $00
    #poke r1, $04
    ldx #<DataEnd
    ldy #>DataEnd
    lda #<r0
    jsr KernalSave
    bcs SaveError
    rts

SaveError
    sta 53280
    jsr $BDCD
    rts

;--------------------------------------
;Tests

TestHighScoreSaving
    #poke 53280, 1
    jsr SaveHighScores
    rts

TestHighScoreLoading
    #poke 53280, 0
    jsr LoadHighScores
    rts
;---------------------------------------
;Data

FilenamePrefixOverwrite
    .byte $40
FilenamePrefix
    .text "0:"
FilenameStart
    .text "high scores"
FilenameSuffix
    .text ".S.W"
FilenameEnd
    .byte 0

PlayerScore
.word 0