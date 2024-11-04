ActionKernalLoad = 0
ActionKernalSave = 1

LoadToAdressInFile = 0
LoadToAddressInAX = 1

DataStart = PlayerName
DataLength = 40
DataEnd = PlayerName + DataLength

Filenumber = 8
device = 8
channel = 2

;Testing KernalSave to disk
.ifeq DebugAssembly
TestHighScoreSaving
    lda #42
    sta PlayerScore
    lda #0
    sta PlayerScore +1
    ;#cpb MyName, PlayerName, LenMyName
    jsr SaveHighScores
    ldx #0
    jsr KernalPrintInt16
    rts

TestHighScoreLoading
    jsr LoadHighScores
    ldx #0
    jsr KernalPrintInt16
    ldx #0
printChar
    lda DataStart, x
    jsr KernalPrintChar
    inx
    cpx #DataLength
    bne printChar
    rts
.endif

LoadHighScores
    lda #device
    ldx #Filenumber
    ldy #0
    jsr KernalSetlfs
    ldx #<FilenamePrefix
    ldy #>FilenamePrefix
    lda #>FilenamePrefix - FilenameEnd
    jsr KernalSetnam
    lda #ActionKernalLoad
    ldx #<PlayerName
    ldy #>PlayerName
    jsr KernalLoad
    BCS HandleKernalLoadError
    jsr KernalClose
    jsr KernalClearIO
    rts

HandleKernalLoadError
    ldx #0
.ifeq DebugAssembly
    sta 53280
.endif
    rts

SaveHighScores
    cli
    lda #FilenameEnd-FilenamePrefixOverwrite
    ldx #<FilenamePrefixOverwrite
    ldy #>FilenamePrefixOverwrite
    jsr KernalSetnam
    ldx $BA ;get last used drive number
    bne FoundLastUsedDrive
    ldx #8 ;default to drive 8

FoundLastUsedDrive
    ldy #0
    jsr KernalSetlfs
    lda #<DataStart
    sta $C1 ;start address container
    lda #>DataStart
    sta $C2
    ldx #<DataEnd
    ldy #>DataEnd
    lda $C1
    jsr KernalSave
    bcs HandleKernalSaveError
    rts

HandleKernalSaveError
    ldx #0
.ifeq DebugAssembly
    sta 53280
.endif
    rts

.ifeq DebugAssembly

FilenameLength = FilenameEnd - FilenameStart
FilenamePrefixOverwrite
    .byte $40
FilenamePrefix
    .text "0:"
FilenameStart
    .text "high scores"
FilenameSuffix

FilenameEnd
    .byte 0