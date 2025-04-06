;--------------------------------------
;This file maps ram to game variable
;and hardware register names
;--------------------------------------
;gamestate
starposmap = $9f00; -> 9f80
starposmapptr = $9f81
score = $9ff0; -> 9ff4
scrollcolumn = $9ff5; -> 99f6
gameflags = $9fff
;bit 7 = None
;bit 6 = None
;bit 5 = None
;bit 4 = None
;bit 3 = None
;bit 2 = skip star placement
;bit 1 = on start screen
;bit 0 = time to move

;Programm flow
stackstart = $100
stackend = $1ff

;Text graphics
txtscreenstart = $0400
txtscreensize = 40 * 25
txtcharsetstart = $2800
spriteptr0 = txtscreenstart+$03f8
spriteptr1 = txtscreenstart+$03f9 
spriteptr2 = txtscreenstart+$03fa
spriteptr3 = txtscreenstart+$03fb
spriteptr4 = txtscreenstart+$03fc
spriteptr5 = txtscreenstart+$03fd
spriteptr6 = txtscreenstart+$03fe
spriteptr7 = txtscreenstart+$03ff
sprite0addr = $2000
sprite1addr = sprite0addr + $40
sprite2addr = sprite1addr + $40
sprite3addr = sprite2addr + $40
sprite4addr = sprite3addr + $40
sprite5addr = sprite4addr + $40
sprite6addr = sprite5addr + $40
sprite7addr = sprite6addr + $40

;primmulticolloc = primeray multiclor 
;location
primmulticolloc = $d025

;secmulticolloc = secondary multicolor
;location
secmulticolloc = $d026

colorramstart = $d800
colorramend = $dbe7
colorramsize = 512

;Highres graphics
screenstart = $4400
screensize = 40 * 25
screenend = screenstart + screensize

;sccharsetstart = start screen
;charset start
charromstart = 53248
charsetstart = $2800
bitmapstart = $6000
bitmapsize = 8000
bitmapend = bitmapstart + bitmapsize

;Disk buffer for load in and out
diskbuffer = $c000
recliststart = diskbuffer+2
diskbufferend = $cf00

;Music 
sidstart = $3000
