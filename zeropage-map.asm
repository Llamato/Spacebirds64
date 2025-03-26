;--------------------------------------
;This file maps the zero page to avr
;like registers and ranks them by
;likelyhood of getting overwritten by
;kernal actions
;--------------------------------------

;Completely Save
r0 = $fb
r1 = $fc
r2 = $fd
r3 = $fe

;Most likely save
r4 = $f9
r5 = $fa
r6 = $f7
r7 = $f8

;Less save
r31 = $f6
r30 = r31 -1 
r29 = r30 -1
r28 = r29 -1
r27 = r28 -1
r26 = r27 -1
r25 = r26 -1
r24 = r25 -1
r23 = r24 -1
r22 = r23 -1
r21 = r22 -1
r20 = r21 -1
r19 = r21 -1
r18 = r19 -1
r17 = r18 -1
r16 = r17 -1
r15 = r16 -1
r14 = r15 -1
r13 = r14 -1
r12 = r13 -1
r11 = r12 -1
r10 = r11 -1
r9 = r10 -1
r8 = r9 -1
