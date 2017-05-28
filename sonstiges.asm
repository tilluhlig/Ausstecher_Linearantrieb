#ifndef SONSTIGES
#define SONSTIGES

// skip if equal
.macro sreq ; (reg0, reg1) 3 Takte
    cp @0, @1
    brbs SREG_Z, pc+3
    nop
.endm

// skip if not equal
.macro srne ; (reg0, reg1) 3 Takte
    cp @0, @1
    brbc SREG_Z, pc+3
    nop
.endm

.macro clearBit ; (QuellRegister, BitRegister)
    push zh
    push zl

    setZ Aktionstabelle
    addZ @1
    ijmp                                ; indirekter Aufruf

    Aktionstabelle:
        rjmp bit0
        rjmp bit1
        rjmp bit2
        rjmp bit3
        rjmp bit4
        rjmp bit5
        rjmp bit6
        rjmp bit7
    bit0:
        andi @1, 0b00000001
        rjmp ende
    bit1:
        andi @1, 0b00000010 
        rjmp ende
    bit2:
        andi @1, 0b00000100
        rjmp ende
    bit3:
        andi @1, 0b00001000
        rjmp ende
    bit4:
        andi @1, 0b00010000
        rjmp ende
    bit5:
        andi @1, 0b00100000
        rjmp ende
    bit6:
        andi @1, 0b01000000
        rjmp ende
    bit7:
        andi @1, 0b10000000
        rjmp ende

    ende:
    pop zl
.endm

.macro setBit ; (QuellRegister, BitRegister)
    push zh
    push zl

    setZ Aktionstabelle
    addZ @1
    ijmp                                ; indirekter Aufruf

    Aktionstabelle:
        rjmp bit0
        rjmp bit1
        rjmp bit2
        rjmp bit3
        rjmp bit4
        rjmp bit5
        rjmp bit6
        rjmp bit7
    bit0:
        ori @1, 0b00000001
        rjmp ende
    bit1:
        ori @1, 0b00000010 
        rjmp ende
    bit2:
        ori @1, 0b00000100
        rjmp ende
    bit3:
        ori @1, 0b00001000
        rjmp ende
    bit4:
        ori @1, 0b00010000
        rjmp ende
    bit5:
        ori @1, 0b00100000
        rjmp ende
    bit6:
        ori @1, 0b01000000
        rjmp ende
    bit7:
        ori @1, 0b10000000
        rjmp ende

    ende:
    pop zl
    pop zh
.endm

.macro getBit ; (QuellRegister, BitRegister, ZielRegister)
    push zh
    push zl

    mov @2, NULL
    setZ Aktionstabelle
    addZ @1
    ijmp                                ; indirekter Aufruf

    Aktionstabelle:
        rjmp bit0
        rjmp bit1
        rjmp bit2
        rjmp bit3
        rjmp bit4
        rjmp bit5
        rjmp bit6
        rjmp bit7
    bit0:
        sbrc @0, 0
        mov @2, EINS 
        rjmp ende
    bit1:
        sbrc @0, 1
        mov @2, EINS 
        rjmp ende
    bit2:
        sbrc @0, 2
        mov @2, EINS 
        rjmp ende
    bit3:
        sbrc @0, 3
        mov @2, EINS 
        rjmp ende
    bit4:
        sbrc @0, 4
        mov @2, EINS 
        rjmp ende
    bit5:
        sbrc @0, 5
        mov @2, EINS 
        rjmp ende
    bit6:
        sbrc @0, 6
        mov @2, EINS 
        rjmp ende
    bit7:
        sbrc @0, 7
        mov @2, EINS 
        rjmp ende

    ende:
    pop zl
    pop zh
.endm

.macro lsr2
    lsr @0
    lsr @0
.endm

.macro lsr3
    lsr @0
    lsr @0
    lsr @0
.endm

.macro lsr4
    swap @0
    andi @0, 0b00001111
.endm

.macro lsr5
    lsr @0
    lsr @0
    lsr @0
    lsr @0
    lsr @0
.endm

.macro lsr6
lsr @0
lsr @0
lsr @0
lsr @0
lsr @0
lsr @0
.endm

.macro lsr7
rol @0
andi @0, 0b00000001
.endm

.macro lsl2
lsl @0
lsl @0
.endm

.macro lsl3
lsl @0
lsl @0
lsl @0
.endm

.macro lsl4
lsl @0
lsl @0
lsl @0
lsl @0
.endm

.macro lsl5
lsl @0
lsl @0
lsl @0
lsl @0
lsl @0
.endm

.macro lsl6
lsl @0
lsl @0
lsl @0
lsl @0
lsl @0
lsl @0
.endm

.macro lsl7
lsl @0
lsl @0
lsl @0
lsl @0
lsl @0
lsl @0
lsl @0
.endm

.macro input
  .if @1 < 0x40
    in    @0, @1
  .else
      lds    @0, @1
  .endif
.endm

.macro output
  .if @0 < 0x40
    out    @0, @1
  .else
    sts    @0, @1
  .endif
.endm

.macro bbis ;port,bit,target
  .if @0 < 0x20
    sbic    @0, @1
    rjmp    @2
  .elif @0 < 0x40
    in        r2, @0
    sbrc    r2, @1
    rjmp    @2
  .else
    lds        r2, @0
    sbrc    r2, @1
    rjmp    @2
  .endif
.endm

.macro bbns ;port,bit,target
  .if @0 < 0x20
    sbis    @0, @1
    rjmp    @2
  .elif @0 < 0x40
    in        r2, @0
    sbrs    r2, @1
    rjmp    @2
  .else
    lds        r2, @0
    sbrs    r2, @1
    rjmp    @2
  .endif
.endm


; ##############################################################################
; ##############################################################################
; ##############################################################################
;Längere Pause für manche Befehle;5ms Pause	5004*FAKTOR									
wait5ms:
    ldi temp2,5 * FAKTOR // von 6
    wait5ms_2:
	    ldi temp1, 249
        wait5ms_:
	        NOP
	        NOP
	        dec  temp1
        brne wait5ms_

        dec  temp2
    brne wait5ms_2                   
ret

; ##############################################################################
; ##############################################################################
; ##############################################################################
;Längere Pause für manche Befehle;500ms Pause										
wait500ms:                               
	push temp1           ; temp1 auf dem Stack sichern            
	ldi temp1, 100
	sh:
	rcall wait5ms
	dec temp1
	brne sh	                 
	pop temp1      		; temp1 wiederherstellen                    
ret


; ##############################################################################
; ##############################################################################
; ##############################################################################
; INP: temp3																
; OUT: temp3+2 (z.B."FF") 		!!!Achtung Rückwärts, erst temp3, dann temp2!!!											
FUNKTION_HEX:
	; SICHERUNGSKOPIE						
	push temp
	; 1-er STELLE		
	mov temp2,temp3
	mov temp,temp3	

	rcall FUNKTION_HEX_UMWANDLUNG
	mov temp3,temp
	; 10-er STELLE		
	mov temp,temp2	
	; NIBBLES tausch	
	swap temp
	rcall FUNKTION_HEX_UMWANDLUNG
	mov temp2,temp
	; SICHERUNGSKOPIE wieder herstellen		
	pop temp
	ret
;-------------------------------------------------------------------------------
FUNKTION_HEX_UMWANDLUNG:
	; BITMUSTER	
	andi temp,0b00001111
	; vergleich	
	cpi temp,0
	breq FUNKTION_HEX_0
	cpi temp,1
	breq FUNKTION_HEX_1
	cpi temp,2
	breq FUNKTION_HEX_2
	cpi temp,3
	breq FUNKTION_HEX_3
	cpi temp,4
	breq FUNKTION_HEX_4
	cpi temp,5
	breq FUNKTION_HEX_5
	cpi temp,6
	breq FUNKTION_HEX_6
	cpi temp,7
	breq FUNKTION_HEX_7
	cpi temp,8
	breq FUNKTION_HEX_8
	cpi temp,9
	breq FUNKTION_HEX_9
	cpi temp,10
	breq FUNKTION_HEX_A
	cpi temp,11
	breq FUNKTION_HEX_B
	cpi temp,12
	breq FUNKTION_HEX_C
	cpi temp,13
	breq FUNKTION_HEX_D
	cpi temp,14
	breq FUNKTION_HEX_E
	cpi temp,15
	breq FUNKTION_HEX_F

FUNKTION_HEX_0:
	ldi temp,'0'
	ret
FUNKTION_HEX_1:
	ldi temp,'1'
	ret
FUNKTION_HEX_2:
	ldi temp,'2'
	ret
FUNKTION_HEX_3:
	ldi temp,'3'
	ret
FUNKTION_HEX_4:
	ldi temp,'4'
	ret
FUNKTION_HEX_5:
	ldi temp,'5'
	ret
FUNKTION_HEX_6:
	ldi temp,'6'
	ret
FUNKTION_HEX_7:
	ldi temp,'7'
	ret
FUNKTION_HEX_8:
	ldi temp,'8'
	ret
FUNKTION_HEX_9:
	ldi temp,'9'
	ret
FUNKTION_HEX_A:
	ldi temp,'A'
	ret
FUNKTION_HEX_B:
	ldi temp,'B'
	ret
FUNKTION_HEX_C:
	ldi temp,'C'
	ret
FUNKTION_HEX_D:
	ldi temp,'D'
	ret
FUNKTION_HEX_E:
	ldi temp,'E'
	ret
FUNKTION_HEX_F:
	ldi temp,'F'
ret


.macro setX ; (Wert) 2 Takte
ldi XL, low(@0)
ldi XH, high(@0)
.endm

.macro addX ; (Register) 2 Takte
add XL, @0
adc XH, NULL
.endm

.macro incX ; 2 Takte
add XL, EINS
adc XH, NULL
.endm

.macro addiX ; (Wert) 2 Takte
subi XL, -@0
adc XH, NULL
.endm

.macro addiY ; (Wert) 2 Takte
subi YL, -@0
adc YH, NULL
.endm

.macro addY ; (Register) 2 Takte
add YL, @0
adc YH, NULL
.endm

.macro incY ; 2 Takte
add YL, EINS
adc YH, NULL
.endm

.macro setY ; (Wert) 2 Takte
ldi YL, low(@0)
ldi YH, high(@0)
.endm

.macro addiZ ; (Wert) 2 Takte
subi ZL, -@0
adc ZH, NULL
.endm

.macro addZ ; (Register) 2 Takte
add ZL, @0
adc ZH, NULL
.endm

.macro incZ ; 2 Takte
add ZL, EINS
adc ZH, NULL
.endm

.macro setZ ; (Wert) 2 Takte
ldi ZL, low(@0)
ldi ZH, high(@0)
.endm

#endif
