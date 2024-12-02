;pssm = playstartscreenmusic
pssm
         sei

         lda #$7f     ;turn off cia
         sta $dc0d
         sta $dd0d

         ; setup Raster srirq

         lda #$7f   ; clear high bit of
         and $d011  ; raster llne
         sta $d011

         lda #100   ; set raster inter-
         sta $d012  ; rupt to line 100


         lda #<srirq  ; set pointer
         sta $0314        ; to raster
         lda #>srirq  ; interrupt
         sta $0315

         lda #$01   ; enable raster
         sta $d01a  ; interrupt

;---------- init Music -----------------

         lda #0
         tax
         tay
         jsr sidstart

         cli
         rts
srirq
         ; set bit 0 in ISR to ack irq
         inc $d019

         ;actual code goes here
.ifne includetests
         inc $d020
.endif

         ; play music
         jsr sidstart + 6
.ifne includetests
         dec $d020
.endif
         ; Restores A,X,Y register and
         ; CPU flags before returning
         jmp $ea31
