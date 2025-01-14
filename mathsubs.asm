;-------------------------------
;
; GETRAND
;
; Generate a somewhat random repeating sequence.  I use
; a typical linear congruential algorithm
;      I(n+1) = (I(n)*a + c) mod m
; with m=65536, a=5, and c=13841 ($3611).  c was chosen
; to be a prime number near (1/2 - 1/6 sqrt(3))*m.
;
; Note that in general the higher bits are "more random"
; than the lower bits, so for instance in this program
; since only small integers (0..15, 0..39, etc.) are desired,
; they should be taken from the high byte RANDOM+1, which
; is returned in A.
;
temp = r29
random = r30
getrend                   
    lda random+1     
    sta temp1        
    lda random      
    asl              
    rol temp1        
    asl              
    rol temp1        
    asl
    rol temp1
    asl
    rol temp1
    clc              
    adc random       
    pha              
    lda temp1        
    adc random+1     
    sta random+1     
    pla
    adc #$11         
    sta random       
    lda random+1     
    adc #$36         
    sta random+1     
    rts              
