;---------------------------------------
;This file handles all disk io
;Saving, loading,
;complaining about melfunctions
;you name it
;---------------------------------------

;Constants
device = 8

;Memory Allocation
;eorp = end of records pointer
eorp = $c000

;Disk buffer for load in and out
diskbuffer = $c000
recliststart = diskbuffer+2
diskbufferend = $cf00

;Staging Area
scorearea = diskbufferend +1
;    .text "00000"; temp
yeararea = scorearea +6
;    .text "2024"
namearea =  yeararea  +5
;    .repeat 20, 32
nameend = namearea +20

scorelength = yeararea - scorearea
yearlength = namearea - yeararea
namelength = nameend - namearea
recordlength = nameend - scorearea


;This variable seems redundent to me.
;Once the first completely working
;version of the save and retiveal system
;is done, I will try to optimize it away
;currrecptr = currentRecordPointer
currrecptr = $cffe

;--------------------------------------
;Marcos

;lfd = LoadFileFromDisk(/1,/2,/3,/4,/5)
;Input
;\1 = logical file number
;\2 = device number
;\3 = filename pointer
;\4 = filename-length (less then 40)
;\5 = (0 = r0/r1 addr else prg file adr)
;Output
;carry set on error with A = error code
lfd .macro
    lda #\1
    ldx #\2
    ldy #\5
    jsr kernalsetlfs
    lda #\4
    ldx #<\3
    ldy #>\3
    jsr kernalsetnam
    lda #0
    ldx r0
    ldy r1
    jsr kernalload
.endm

;sfd SaveFileToDisk(/1,/2,/3,/4,/5)
;\1 = logical file number
;\2 = device number
;\3 = filename pointer
;\4 = filenamelength (less then 40)
;r0 = LB of DataStart
;r1 = HB of DataStart
;r2 = LB of DataEnd
;r3 = HB of DataEnd
;Output
;carry set on error with A = error code
sfd .macro
    lda #\1
    ldx #\2
    ldy #1
    jsr kernalsetlfs
    lda #\4
    ldx #<\3
    ldy #>\3
    jsr kernalsetnam
    ldx r2
    ldy r3
    lda #<r0
    jsr kernalsave
    rts
.endm

;Rotines

loadhighscores
#ldi16 currrecptr, recliststart
#ldi16 r0, diskbuffer
#lfd 2, 8, filenamestart, 11, 1
bcs hreaderr
rts

savehighscores
#poke r0, <diskbuffer
#poke r1, >diskbuffer
#poke r2, <diskbufferend
#poke r3, >diskbufferend
#sfd 2, 8, filenameprefow, 14
bcs hwriteerr
rts

hreaderr; handle read error
.ifne includetests
    sta 53280
.endif
    jmp hreadwriteerr;

hwriteerr; handle write error
.ifne includetests
    sta 53281
.endif
    jmp hreadwriteerr

hreadwriteerr; handle read write error
    ldx #<recliststart
    stx eorp
    ldy #>recliststart
    sty eorp +1
    rts

clrdiskiomem
    #fmb $c000, $cfff, 0
    rts

.ifne includetests
getnextrecord
    #add16i currrecptr, recordlength
;Add checks for greater then eorp here
;if so jump to eorr
    rts
.endif

;eorr = end of records reached
;warp around back to recliststart
eorr
    #ldi16 currrecptr, recliststart
    rts

;addhstodb = append high score to
;disk buffer
;Appends high score in staging Area to
;disk Buffer
addhstodb
    #ldi16 r0, scorearea
    #mov16 r2, eorp
    ldy #recordlength
    sty r4
    jsr memcpy
    #add16i eorp, recordlength
    rts

;Data
;filenameprefow=filenameprefixOverwrite
filenameprefow
    .byte $40
filenameprefix
    .text "0:"
filenamestart
    .text "high scores"
filenamesuffix
    .text ",s,w"
filenameend
    .byte 0
