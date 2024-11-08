;Please do not use any kernal rotines
;in the game loop.
;They are all extremely inefficant

KernalPrintInt16 = $BDCD
KernalSetnam = $FFBD
KernalSetlfs = $FFBA
KernalChrout = $FFD2

;Gets or sets the cursor position
;based upon carry flag.
;if the carry flag is set
;the current cursor position will be
;stored in X/Y
;if the carry flag is clear
;the current cursor position will be
;set to X/Y and A destoryed
KernalPlot = $FFF0

KernalSave = $FFD8
KernalLoad = $FFD5
KernalReadst = $FFB7
KernalOpen = $FFC0; Open File
KernalChkin = $FFC6; Set Input Channel
KernalChkout = $FFC9; Set Output Channel

;Get Character from Input Channel
KernalGetin = $FFE4

KernalClrChn = $FFCC; Clear I/O Channels
KernalClose = $FFC3; Close File
KernalClall = $FFE7; Close All Files
KernalCls = $E544; Clear Screen

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

KernalListen = $FFB1
