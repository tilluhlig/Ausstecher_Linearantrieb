.include "m8def.inc"

; REGISTER										
.def NULL 	= R10
.def EINS 	= R11
.def VOLL	= R12
.def ALL	= R12

.def temp 	= R16
.def temp1 	= R17
.def temp2 	= R18
.def temp3 	= R19
.def temp4 	= R20
.def temp5 	= R21
.def temp6 	= R22
.def temp7 	= R23
.def temp8 	= R24
.def temp9 	= R25

.equ FAKTOR = 16

.equ XTAL = 1000000 * FAKTOR
.equ F_CPU = 1000000 * FAKTOR                        ; Systemtakt in Hz
.equ BAUD  = 9600  		                             ; Baudrate

; Berechnungen
.equ UBRR_VAL   = ((F_CPU+BAUD*8)/(BAUD*16)-1)  ; clever runden
.equ BAUD_REAL  = (F_CPU/(16*(UBRR_VAL+1)))      ; Reale Baudrate
.equ BAUD_ERROR = ((BAUD_REAL*1000)/BAUD-1000)  ; Fehler in Promille
 
.if ((BAUD_ERROR>10) || (BAUD_ERROR<-10))       ; max. +/-10 Promille Fehler
  .error "Systematischer Fehler der Baudrate grösser 1 Prozent und damit zu hoch!"
.endif

.org 0x0000
rjmp reset
.org OC1Aaddr  
rjmp loop

.include "sonstiges.asm"
.include "sram/sram_makros.asm"

.macro motor_sleep ; (const) 8 Takte
    push r16
    ldi r16, high(@0)
    sts MotorSleep, r16
    ldi r16, low(@0)
    sts MotorSleep+1, r16
    pop r16
.endm

// fährt den Motor hoch
.macro motor_hoch ; 3 Takte
    cbi PORTD, 6
    sbi PORTD, 7
    sbi PORTD, 5
.endm

// fährt den Motor runter
.macro motor_runter ; 3 Takte
    sbi PORTD, 6
    cbi PORTD, 7
    sbi PORTD, 5
.endm

// stoppt 
.macro motor_stop ; 3 Takte
    sbi PORTD, 6
    sbi PORTD, 7
    cbi PORTD, 5
.endm

.macro ausstecher_stop ; 1 Takt
    sbi PORTC, 3
.endm

.macro ausstecher_start ; 1 Takt
    cbi PORTC, 3
.endm

reset:
						
; NULL				
    clr NULL

; EINS				
    ldi temp,1
    mov EINS,temp

; VOLL				
    ldi temp,255
    mov VOLL,temp
	
; Baudrate einstellen
    ldi     temp, HIGH(UBRR_VAL)
    out     UBRRH, temp
    ldi     temp, LOW(UBRR_VAL)
    out     UBRRL, temp

;RS232 initialisieren
    ldi r16, LOW(UBRR_VAL)
    out UBRRL,r16
    ldi r16, HIGH(UBRR_VAL)
    out UBRRH,r16
    ldi r16, (1<<URSEL)|(3<<UCSZ0) ; Frame-Format: 8 Bit // 8 bit, 1 stop // 
    out UCSRC,r16
    sbi UCSRB, RXEN			; RX (Empfang) aktivieren
    sbi UCSRB, TXEN			; TX (Senden)  aktivieren


; Init
    ldi      temp, HIGH(RAMEND)     ; Stackpointer initialisieren
    out      SPH, temp
    ldi      temp, LOW(RAMEND)
    out      SPL, temp

; Taster und Kontakte initialisieren
    cbi DDRC, 1
    sbi PORTC, 1
    cbi DDRC, 2
    sbi PORTC, 2
    cbi DDRC, 4
    sbi PORTC, 4
    cbi DDRC, 5
    sbi PORTC, 5
    SSN MotorSleep, 2
    SSN MotorRichtung, 1

    ;Ausgänge
    sbi DDRC, 3
    sbi PORTC, 3

    sbi DDRD, 6
    sbi PORTD, 6
    sbi DDRD, 7
    sbi PORTD, 7
    sbi DDRD, 5
    sbi PORTD, 5

    out  ADCSRA, NULL

; Timer 1
    ldi     temp, high( 10000 - 1 )
    out     OCR1AH, temp
    ldi     temp, low( 10000 - 1 )
    out     OCR1AL, temp
    ldi     temp, ( 1 << WGM12 )| ( 1 << CS10 )
    out     TCCR1B, temp

    ldi     temp, 1 << OCIE1A  ; OCIE1A: Interrupt bei Timer Compare
    out     TIMSK, temp
    sei

; Sleep-Mode
    in  r16, MCUCR
    ori r16, (1<<SE)
    out MCUCR, r16

do: 
sleep
rjmp do

loop:
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
cli

CSN MotorSleep, 2, keinPresseSleep, presseSchlaeft
presseSchlaeft:
SRS MotorSleep, 2, EINS
rjmp ende
keinPresseSleep:

sbic PINC, 5
rjmp hoch_fahren
rjmp runter_fahren

hoch_fahren:
sbis PINC, 1
rjmp motor_ist_oben

// wir müssen hoch fahren
CSE MotorRichtung, 1, A, B
A:
motor_sleep 600
SSN MotorRichtung, 1
ausstecher_stop
motor_stop
rjmp ende

B:
SSN MotorRichtung, 1
ausstecher_stop
motor_hoch
rjmp ende

motor_ist_oben:
// der Motor ist bereits oben
sts MotorRichtung, ALL
ausstecher_stop
motor_stop
rjmp ende

runter_fahren:
sbis PINC, 2
rjmp motor_ist_unten

// der Motor muss runter fahren
CSN MotorRichtung, 1, A2, B2
A2:
motor_sleep 600
SSE MotorRichtung, 1
motor_stop
ausstecher_stop
rjmp ende

B2:
SSE MotorRichtung, 1
motor_runter
ausstecher_stop
rjmp ende

motor_ist_unten:
sts MotorRichtung, ALL
motor_stop
ausstecher_start
rjmp ende

ende:

sei
reti

.DSEG
MotorSleep: .BYTE 2
MotorRichtung: .BYTE 1
