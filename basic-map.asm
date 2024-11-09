;Positions cursor at (0,0)
;Input none
;Output none
BasicCursorHome = $E566

;Gets or sets the cursor position
;based upon carry flag.
;if the carry flag is set
;the current cursor position will be
;stored in X/Y
;if the carry flag is clear
;the current cursor position will be
;set to X/Y and A destoryed
BasicPlot = $FFF0

;Prints null terminated string
;starting at cursor position
;shifting the cursor to the position of
;the current char up to end including
;the terminator
BasicPrintNull = $AB1E

;Prints 16 bit number stored in X/Y
;to screen at cursor position
;Input
;16 bit binary number in X/Y
;Output
;String of characters representing
;the 16 bit input value starting at
;cursor position
BasicPrintInt16 = $BDCD


;Clear Screen
;Equivalent of MS-DOS cls command.
;Equivalent of Unix clear command.
;Input None
;Output
;Memory region defined as basic
;screen memory filled with #32
BasicCls = $E544
