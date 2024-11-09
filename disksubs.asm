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

diskBuffer = $C000
diskBufferS = 1024
diskBufferEnd = diskBuffer + diskBufferS
LastLoadAddress = diskBufferEnd -2

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
    #ldi16 r0, 1024
    #lfd 2, 8, FilenameStart, 11, 0
    bcs handleReadError
    stx diskBufferEnd -2
    sty diskBufferEnd -1
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
    sta 5320
    jmp handleReadWriteError

handleWriteError
    sta 53281
    jmp handleReadWriteError

handleReadWriteError
    ldx #0
    stx diskBufferEnd-2
    ldy #0
    sty diskBufferEnd-1
    rts

appendHighscoreToDiskBuffer
    #ldi16 r0, scoreArea
    #ldi16 r2, diskBuffer
    #add16 r2, diskBufferEnd-2
    ldy #scoreArea-nameEnd
    jsr memcpy
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

scoreArea
    .text "00000"; temp
    .byte $00
yearArea
    .text "2024"
    .byte $00
nameArea
    .repeat 20, 32
    .byte $00
nameEnd
    .byte 0
