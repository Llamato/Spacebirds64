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

primery_iec_channel_address = 2
device = 8
seconday_address_read_to_xy = 0
seconday_address_write = 1
seconday_address_read_to_prg = 2



;Memory Allocation
;eorp = end of records pointer
eorp = $C000

;Disk buffer for load in and out
diskBuffer = $C000
recListStart = diskBuffer+2
diskBufferEnd = $CF00

;Staging Area
scoreArea = diskBufferEnd +1
;    .text "00000"; temp
yearArea = scoreArea +6
;    .text "2024"
nameArea =  yearArea  +5
;    .repeat 20, 32
nameEnd = nameArea +20

scoreLength = yearArea - scoreArea
yearLength = nameArea - yearArea
nameLength = nameEnd - nameArea
recordLength = nameEnd - scoreArea

;curRecPointer = currentRecordPointer
curRecPointer = nameEnd

;--------------------------------------
;Marcos

;lfd = LoadFileFromDisk(/1,/2,/3,/4,/5)
;Input
;\1 = logical file number
;\2 = device number
;\3 = filename pointer
;\4 = filename_length (less then 40)
;\5 = (0 = r0/r1 addr else prg file adr)
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
    ldx r0
    ldy r1
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
    ldx #<\3
    ldy #>\3
    jsr KernalSetnam
    ldx r2
    ldy r3
    lda #<r0
    jsr KernalSave
    rts
.endm

;Rotines

LoadHighScores
#ldi16 curRecPointer, recListStart
#ldi16 r0, diskBuffer
#lfd 2, 8, FilenameStart, 11, 1
bcs handleReadError
rts

SaveHighScores
#poke r0, <diskBuffer
#poke r1, >diskBuffer
#poke r2, <diskBufferEnd
#poke r3, >diskBufferEnd
#sfd 2, 8, FilenamePrefixOverwrite, 14
bcs handleWriteError
rts

handleReadError
.ifne includeTests
    sta 53280
.endif
    jmp handleReadWriteError

handleWriteError
.ifne includeTests
    sta 53281
.endif
    jmp handleReadWriteError

handleReadWriteError
    ldx #<recListStart
    stx eorp
    ldy #>recListStart
    sty eorp +1
    rts

clearDiskIoMemory
    #fmb $C000, $CFFF, 0
    rts

getNextRecord
    #add16i curRecPointer, recordLength
;Add checks for greater then eorp here
;if so jump to eorr
    rts

;eorr = end of records reached
;warp around back to recListStart
eorr
    #ldi16 curRecPointer, recListStart
    rts

appendHighscoreToDiskBuffer
    #ldi16 r0, scoreArea
    #mov16 r2, eorp
    ldy #recordLength
    sty r4
    jsr memcpy
    #add16i eorp, recordLength
    rts

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
