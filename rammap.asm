;Text graphics
txtscreenstart = $0400
txtscreensize = 40 * 25
txtcharsetstart = $2000
charsetend = $3000

colorramstart = $d800
colorramend = $dbe7
colorramsize = 512

;Highres graphics
screenstart = $4400
screensize = 40 * 25
screenend = screenstart + screensize
charsetstart = $2c00
bitmapstart = $6000
bitmapsize = 8000
bitmapend = bitmapstart + bitmapsize

;Disk buffer for load in and out
diskbuffer = $c000
recliststart = diskbuffer+2
diskbufferend = $cf00

;Music 
sidstart = $3000
