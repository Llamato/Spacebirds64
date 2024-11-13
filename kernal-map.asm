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
KernalSetnam = $FFBD

;set logical file number, device number,
;and secondary address.
;A setup rotine used in conjunction with
;setnam to prepere for IO operations
;see disk-subrotines.asm for examples.
;Input 
;A = logical file number
;X = device number
;Y = secondary address
KernalSetlfs = $FFBA

;Configure I/O channel as input in prep
;for open command.
;Input
;X = logical file number of channel
;Output
KernalChkin = $FFC6

;Configure I/O channel as output in prep
;for open command.
;Input
;X = logical file number of channel
;Output
KernalChkout = $FFC9

;Output Character
;sends a character (byte) to all active
;output channels configured by
;rotines mapped and described above.
;Input
;A = byte to be send
kernalChrout = $FFD2

;Save block of memory to io device
;Input
;A = Zeropage address of low byte 
;of pointer to start of data block
;X = low byte of end of block of data
;Y = high byte of end of block of data 
;Carry set on Error
KernalSave = $FFD8

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
KernalLoad = $FFD5

;Equivalent of basic open command
;maps a logical file number to a
;device with a device number
;Input None (SetLFS and SetNam required)
;Output
;A = Error code
KernalOpen = $FFC0

;Reads IO status word into A
;hard to descripe here see online
;resources for a nice table.
KernalReadst = $FFB7

;Get Character from Input Channel
;Reads one char (byte) from active
;input channel as configured using
;Open checkin, setnam and setlfs
;Input None (implicit)
;Output 
;A = char read from active input channel
KernalGetin = $FFE4

;Clear I/O Channels
;Resets I/O configureation set by
;Open checkin, setnam and setlfs
;and the like back to default
;The default being the screen as
;active output channel and
;the keyboard as active input channel.
;Input None
;Output None
KernalClrChn = $FFCC

;Close I/O Channel
;Closes an I/0 Channel opend by open
;dues removing it from the list of
;active input channels or
;from the list of active output channels
;depending upon the type of channel
;closed
;Input None
;Output None
KernalClose = $FFC3

;Close All I/O channels
;Input None
;Output None
KernalClall = $FFE7; 

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
KernalGetChr = $FFCF
