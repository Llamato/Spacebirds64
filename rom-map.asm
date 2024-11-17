;Please do not use any kernal rotines
;in the game loop.
;They are all extremely inefficant

;For more detailed kernal map see
;https://www.pagetable.com/c64ref/kernal
;---------------------------------------

;Sets filename of file on disk to be 
;written to or read from.
;Input
;A = length of filename
;X/Y = address of first char in
;filename
kernalsetnam = $ffbd

;set logical file number, device number,
;and secondary address.
;A setup rotine used in conjunction with
;setnam to prepere for IO operations
;see disk-subrotines.asm for examples.
;Input 
;A = logical file number
;X = device number
;Y = secondary address
kernalsetlfs = $ffba

;Configure I/O channel as input in prep
;for open command.
;Input
;X = logical file number of channel
;Output
kernalchkin = $ffc6

;Configure I/O channel as output in prep
;for open command.
;Input
;X = logical file number of channel
;Output
kernalchkout = $ffc9

;Output Character
;sends a character (byte) to all active
;output channels configured by
;rotines mapped and described above.
;Input
;A = byte to be send
kernalchrout = $ffd2

;Save block of memory to io device
;Input
;A = Zeropage address of low byte 
;of pointer to start of data block
;X = low byte of end of block of data
;Y = high byte of end of block of data 
;Carry set on Error
kernalsave = $ffd8

;Load block of memory from io device
;Caution length of data to be read can
;not be set. This rotine loads until the
;data stream ends.
;Input
;A = (0 for load, 1 for verify)
;X/Y = Target start address for loaded
;memory
;Output
;X/Y = Address of last byte loaded
;Carry set on Error
kernalload = $ffd5

;Equivalent of basic open command
;maps a logical file number to a
;device with a device number
;Input None (SetLFS and SetNam required)
;Output
;A = Error code
kernalopen = $ffc0

;Reads IO status word into A
;hard to descripe here see online
;resources for a nice table.
kernalreadst = $ffb7

;Get Character from Input Channel
;Reads one char (byte) from active
;input channel as configured using
;Open checkin, setnam and setlfs
;Input None (implicit)
;Output 
;A = char read from active input channel
kernalgetin = $ffe4

;Clear I/O Channels
;resets I/O configureation set by
;Open checkin, setnam and setlfs
;and the like back to default
;The default being the screen as
;active output channel and
;the keyboard as active input channel.
;Input None
;Output None
kernalclrchn = $ffcc

;Close I/O Channel
;Closes an I/0 Channel opend by open
;dues removing it from the list of
;active input channels or
;from the list of active output channels
;depending upon the type of channel
;closed
;Input None
;Output None
kernalclose = $ffc3

;Close All I/O channels
;Input None
;Output None
kernalclall = $ffe7

;Shows flashing cursor and lets the user
;enter up to 80 chars of text
;input gathering ends on return press
;The input is now stored in basic
;user input buffer.
;Rotine can then be called to retrive
;to retrive one byte from the buffer
;per call into A.
;End of Data is denoted by
;carriage return character code in A
kernalgetchr = $ffcf

;Positions cursor at (0,0)
;Input none
;Output none
basiccursorhome = $e566

;Gets or sets the cursor position
;based upon carry flag.
;if the carry flag is set
;the current cursor position will be
;stored in X/Y
;if the carry flag is clear
;the current cursor position will be
;set to X/Y and A destoryed
basicplot = $fff0

;Prints null terminated string
;starting at cursor position
;shifting the cursor to the position of
;the current char up to end including
;the terminator
basicprintnull = $ab1e

;Prints 16 bit number stored in X/Y
;to screen at cursor position
;Input
;16 bit binary number in X/Y
;Output
;String of characters representing
;the 16 bit input value starting at
;cursor position
basicprintint16 = $bdcd


;Clear Screen
;Equivalent of MS-DOS cls command.
;Equivalent of Unix clear command.
;Input None
;Output
;Memory region defined as basic
;screen memory filled with #32
basiccls = $e544
