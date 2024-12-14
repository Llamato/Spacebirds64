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
sprite1addr = $2040

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
