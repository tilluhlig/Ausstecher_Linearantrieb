#ifndef SRAM_MAKROS
#define SRAM_MAKROS

;#############################################
;########## schiebt SRAM in SRAM  ############
;#############################################
.macro SSR ; (k,Rd,k,Rr,k)    (k ziel sram adresse, Rr ziel anzahl bytes, k quell sram adresse, Rr quell anzahl bytes, k Anzahl der shifts)
ldi r23, @4
mov r6, r23
shiftrightschleife:

ldi xl, low(@0)
ldi xh, high(@0)
ldi zl, low(@2)
ldi zh, high(@2)
mov r3, @3

clr r5
quellshift:
clr r7
ld r4, z
lsr r4
ror r7
or r4, r5
mov r5, r7
st z+, r4
dec r3
brne quellshift

mov r3, @1
zielshift:
clr r7
ld r4, x
lsr r4
ror r7
or r4, r5
mov r5, r7
st x+, r4
dec r3
brne zielshift

dec r6
brne shiftrightschleife

.endm


;#############################################
;############ setzt SRAM auf Null ############
;#############################################
.macro SSN ; (kd, k, [tempRegister, tempRegister2])   (SRAM adresse, Anzahl der bytes (maximal 5), [tempRegister, tempRegister2])
.if @1 <= 7
    .if @1>=1
        sts @0, NULL
     .endif
     .if @1>=2
        sts @0+1, NULL
     .endif
     .if @1>=3
        sts @0+2, NULL
     .endif
     .if @1>=4
        sts @0+3, NULL
     .endif
     .if @1>=5
        sts @0+4, NULL
     .endif
     .if @1>=6
        sts @0+5, NULL
     .endif
     .if @1>=7
        sts @0+6, NULL
     .endif
.else
    .if @1 <= 255
        push zl
        push zh
        setZ @0
        ldi @2, @1
        loop:
            st Z+, NULL
            dec @2
        brne loop
        pop zh
        pop zl
    .else
        //ldi @2, low(@1)
        //ldi @3, low(@1)

    .endif
.endif
.endm

;#############################################
;############ setzt SRAM auf EINS ############
;#############################################
.macro SSE ; (kd, k)   (SRAM adresse, Anzahl der bytes (maximal 5))
.if @1 <= 7
    .if @1>=1
sts @0, EINS
     .endif
     .if @1>=2
sts @0+1, EINS
     .endif
     .if @1>=3
sts @0+2, EINS
     .endif
     .if @1>=4
sts @0+3, EINS
     .endif
     .if @1>=5
sts @0+4, EINS
     .endif
     .if @1>=6
sts @0+5, EINS
     .endif
     .if @1>=7
sts @0+6, EINS
     .endif
.endif
.endm


;#############################################
;######## Addiert ein Register zu SRAM #######
;#############################################
.macro ARS ; (kd,k,Rr)  (SRAM adresse, Anzahl der bytes (maximal 3), zu addierendes Register)
    .if @1==1
    lds r3, @0
    add r3, @2
    sts @0, r3
    .endif

    .if @1==2
    lds r4, @0
    lds r3, @0+1
    add r3,@2
    adc r4,NULL
    sts @0, r4
    sts @0+1, r3
    .endif

    .if @1==3
    lds r5, @0
    lds r4, @0+1
    lds r3, @0+2
    add r3,@2
    adc r4,NULL
    adc r5,NULL
    sts @0, r5
    sts @0+1, r4
    sts @0+2, r3
    .endif
.endm


;#############################################
;######## Addiert Eins zu SRAM #######
;#############################################
.macro IS ; (kd,k)  (SRAM adresse, Anzahl der bytes (maximal 3))
    .if @1==1
    lds r3, @0
    add r3, EINS
    sts @0, r3
    .endif

    .if @1==2
    lds r4, @0
    lds r3, @0+1
    add r3,EINS
    adc r4,NULL
    sts @0, r4
    sts @0+1, r3
    .endif

    .if @1==3
    lds r5, @0
    lds r4, @0+1
    lds r3, @0+2
    add r3,EINS
    adc r4,NULL
    adc r5,NULL
    sts @0, r5
    sts @0+1, r4
    sts @0+2, r3
    .endif
.endm


;#############################################
;######## Verschiebt SRAM in SRAM #######
;#############################################
.macro MSS ; (kd,k,kr)  (SRAM adresse, Anzahl der bytes (maximal 3), SRAM adresse)
    
    .if @1==1
        push r3
        lds r3, @2
        sts @0, r3
        pop r3
    .else
        push r17
        push r16
        push zl
        push zh
        ldi r16, @1
        setZ @0
        setY @2
        loop:
            ld r17, Y+
            st Z+, r17
            dec r16
        brne loop
        pop zh
        pop zl
        pop r16
        pop r17
    .endif
.endm


;#############################################
;##### Subtrahiert ein Register von SRAM #####
;#############################################
.macro SRS ; (kd,k,Rr)  (SRAM adresse, Anzahl der bytes (maximal 3), zu subtrahierendes Register)
    
    .if @1==1
    lds r3, @0
    sub r3, @2
    sts @0, r3
    .endif

    .if @1==2
    lds r4, @0
    lds r3, @0+1
    sub r3,@2
    sbc r4,NULL
    sts @0, r4
    sts @0+1, r3
    .endif

    .if @1==3
    lds r5, @0
    lds r4, @0+1
    lds r3, @0+2
    sub r3,@2
    sbc r4,NULL
    sbc r5,NULL
    sts @0, r5
    sts @0+1, r4
    sts @0+2, r3
    .endif
.endm


;#############################################
;############## Addiert zwei SRAM ############
;#############################################
.macro ASS ; (kd,k,k,k)  (SRAM adresse, Anzahl der bytes (maximal 3), SRAM adresse, Anzahl der bytes (maximal 3))

    .if @1==1
    lds r3, @0
    lds r4, @2
    add r3, r4
    sts @0,r3
    .endif




    .if @1==2
    lds r3, @0
    lds r4, @0+1
    
    .if @3==1
    lds r5, @2
    add r4, r5
    adc r3, NULL
    .endif

    .if @3==2
    lds r5, @2+1
    lds r6, @2
    add r4, r5
    adc r3, r6
    .endif

    sts @0,r3
    sts @0+1,r4
    .endif




    .if @1==3
    lds r3, @0
    lds r4, @0+1
    lds r5, @0+2

    .if @3==1
    lds r6, @2
    add r5, r6
    adc r4, NULL
    adc r3, NULL
    .endif

    .if @3==2
    lds r6, @2+1
    lds r7, @2
    add r5, r6
    adc r4, r7
    adc r3, NULL
    .endif

    .if @3==3
    lds r6, @2+2
    lds r7, @2+1
    lds r8, @2
    add r5, r6
    adc r4, r7
    adc r3, r8
    .endif

    sts @0,r3
    sts @0+1,r4
    sts @0+2,r5
    .endif
.endm


;#############################################
;########### vergleicht zwei SRAM ############
;#############################################
.macro CSS ; (kd,k,k,k,k)  (SRAM adresse, Anzahl der bytes (maximal 3), SRAM adresse, then label, else label)

    .if @1>=1
lds r6,@0+@1-1  
lds r5,@2+@1-1 
cp r5, r6
breq next 
rjmp @4
next:
    .endif

    .if @1>=2
lds r6,@0+@1-2  
lds r5,@2+@1-2 
cp r5, r6
breq next2 
rjmp @4
next2:
    .endif

    .if @1>=3
lds r6,@0+@1-3
lds r5,@2+@1-3 
cp r5, r6
breq next3 
rjmp @4
next3:
    .endif

rjmp @3
.endm


;#############################################
;########### vergleicht SRAM auf NULL ############
;#############################################
.macro CSN ; (kd,k,k,k)  (SRAM adresse, Anzahl der bytes (maximal 3), then label, else label)

    .if @1==1
    lds r3, @0
    cp r3, NULL
    breq next 
    rjmp @3
    next:
    .endif

    .if @1==2
    lds r3, @0
    cp r3, NULL
    breq next
    rjmp @3
    next:
    lds r3, @0+1
    cp r3, NULL
    breq next2
    rjmp @3
    next2:
    .endif

    .if @1==3
    lds r3, @0
    cp r3, NULL
    breq next
    rjmp @3
    next:
    lds r3, @0+1
    cp r3, NULL
    breq next2
    rjmp @3
    next2:
    lds r3, @0+2
    cp r3, NULL
    breq next3
    rjmp @3
    next3:
    .endif

rjmp @2
.endm


;#############################################
;########### vergleicht SRAM auf EINS ############
;#############################################
.macro CSE ; (kd,k,k,k)  (SRAM adresse, Anzahl der bytes (maximal 3), then label, else label)

    .if @1==1
    lds r3, @0
    cp r3, EINS
    breq next 
    rjmp @3
    next:
    .endif

    .if @1==2
    lds r3, @0
    cp r3, NULL
    breq next
    rjmp @3
    next:
    lds r3, @0+1
    cp r3, EINS
    breq next2
    rjmp @3
    next2:
    .endif

    .if @1==3
    lds r3, @0
    cp r3, NULL
    breq next
    rjmp @3
    next:
    lds r3, @0+1
    cp r3, NULL
    breq next2
    rjmp @3
    next2:
    lds r3, @0+2
    cp r3, EINS
    breq next3
    rjmp @3
    next3:
    .endif

rjmp @2
.endm

#endif
