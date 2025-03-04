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

;Score Staging Area
sca = diskbufferend +1
;    .text "00000"; temp
yeararea = sca +6
;    .text "2024"
namearea =  yeararea  +5
;    .repeat 20, 32
nameend = namearea +20

scorelength = yeararea - sca
yearlength = namearea - yeararea
namelength = nameend - namearea
recordlength = nameend - sca


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
.ifne \2
    ldx #\2
.endif
.ifeq \2
    ldx $ba; last used drive id
.endif
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
.ifne \2
    ldx #\2
.endif
.ifeq \2
    ldx $ba; last used drive id
.endif
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
;Loads high scores from disk.
;No external parameters needed.
loadhighscores
#ldi16 currrecptr, recliststart
#ldi16 r0, diskbuffer
#lfd 2, 0, hsfilename, 11, 1
bcs hreaderr
rts

;Saves high scores to disk.
;No external parameters needed.
savehighscores
    #poke r0, <diskbuffer
    #poke r1, >diskbuffer
    #poke r2, <diskbufferend
    #poke r3, >diskbufferend
    #sfd 2, 0, filenameprefow, 13
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

;addhstodb = append high score to
;disk buffer
;Appends high score in staging Area to
;disk Buffer
addhstodb
    #ldi16 r0, sca
    #mov16 r2, eorp
    ldy #recordlength
    sty r4
    jsr memcpy
    #add16i eorp, recordlength
    rts

;Loads character generator rom from disk
;Input
;a = chargen id (last char of file name)
;r0 = Lowbyte of target address.
;r1 = Highbyte of target address
loadchargen
    sta fontfn+7
    #add16i r0, 2
    #lfd 2, 0, fontfn, 8, 0
    rts

;Loads sprite from disk
;Input
;a = sprite id (last char of file name)
;r0 = Lowbyte of target address
;r1 = Highbyte of target address
loadsprite
    sta spritefn+6
    #lfd 2, 0, spritefn, 7, 0
    rts

;Loads (40*25=1000) bytes
;directly onto the text screen
;a = screen id (last char of file name)
loadtextscreen
    sta screenfn+6
    ;What is up with those +2
    ;offsets needed for
    ;correct load address?
    ;Must be that c1541 interprets
    ;the first two bytes as prg load 
    ;address. I will get to it!
    #ldi16 r0, txtscreenstart
    #lfd 2, 0, screenfn, 7, 0
    rts

;Loads sid file from disk
loadsid
    #lfd 2, 0, sidfn, 3, 1
    rts

;Loads and displays qr code
;Warning: ireversable actionrun
;Overwrites programm
loadqrcode
.block
destaddr = $c000
jsr disrasterirq

    #ldi16 r0, startddr
    #ldi16 r2, destaddr
    #poke r4, endaddr-startddr+1
    jsr memcpy
    jmp destaddr
startddr = *
    #lfd 2, 0, qrcodefn, 6, 1
    jmp 2061
endaddr = *
.bend

;Data
;filenameprefow=filenameprefixOverwrite
filenameprefow
    .byte $40
    .text ":"
hsfilename
    .text "high scores"

;Fonts by Patrick Mollohan
;https://github.com/Llamato/c64-fonts
fontfn
    .text "chargen0"

screenfn
    .text "screen0"

spritefn
    .text "sprite0"

sidfn
    .text "sid"

;QR code created with
;https://qrcode-generator.de
;And converted with
;https://digartroks.be/img2c64mc
qrcodefn
    .text "qrcode"
