; COMP2121
; Project - Vending Machine
;	
; Main

.include "m2560def.inc"

.include "modules/macros.asm"
.include "modules/lcd.asm"
.include "modules/timer0.asm"
.include "modules/keypad.asm"

.include "SelectScreen.asm"	
.include "EmptyScreen.asm"			


.def inStart = r5
.def inSelect = r6
.def inCoin = r7

.def row = r16
.def col = r17
.def rmask = r18                ; mask for row
.def cmask = r19                ; mask for column
.def temp = r20
.def temp1 = r21

; data memory
.dseg 
	TempCounter:
    	.byte 2             ; Temporary counter. Counts milliseconds
	DisplayCounter:
    	.byte 2             ; counts number of milliseconds for displays.
	Inventory:
		.byte 9
	Cost:
		.byte 9	

; program memory
.cseg
.org 0x0000
   jmp RESET
   jmp DEFAULT          ; No handling for IRQ0.
   jmp DEFAULT          ; No handling for IRQ1.
.org INT2addr
    jmp EXT_INT2
.org OVF0addr
   jmp Timer0OVF        ; Jump to the interrupt handler for timer 0

DEFAULT:  
	reti          ; no service

RESET: 
	ldi temp1, high(RAMEND) 		; Initialize stack pointer
	out SPH, temp1
	ldi temp1, low(RAMEND)
	out SPL, temp1
	ldi temp1, PORTLDIR
	sts DDRL, temp1				; sets lower bits as input and upper as output
	ser temp1 					; set Port C as output - reset all bits to 0 (ser = set all bits in register)
	out DDRC, temp1 

    ldi temp, PORTLDIR
    sts DDRL, temp            		; sets lower bits as input and upper as output

    ser r16
    out DDRF, r16
    out DDRA, r16
    clr r16
    out PORTF, r16
    out PORTA, r16              	; setting PORTA & PORTF as output

	ser temp 						; set Port C as output - reset all bits to 0 (ser = set all bits in register)
	out DDRC, temp 

    do_lcd_command 0b00111000 		; 2x5x7 (2 lines, 5x7 is the font)
    rcall sleep_5ms
    do_lcd_command 0b00111000 		; 2x5x7
    rcall sleep_1ms
    do_lcd_command 0b00111000 		; 2x5x7
    do_lcd_command 0b00111000 		; 2x5x7
    do_lcd_command 0b00001000 		; display off?
    do_lcd_command 0b00000001 		; clear display
    do_lcd_command 0b00000110 		; increment, no display shift
    do_lcd_command 0b00001110 		; Cursor on, bar, no blink

    ldi temp, 0b00000000	; timer setup
    out TCCR0A, temp
    ldi temp, 0b00000010
    out TCCR0B, temp        ; Prescaling value=8
    ldi temp, 1<<TOIE0      ; = 128 microseconds
    sts TIMSK0, temp        ; T/C0 interrupt enable
	sei


start:
	set_reg inStart

	do_lcd_data_i '2'
	do_lcd_data_i '1'
	do_lcd_data_i '2'
	do_lcd_data_i '1'
	do_lcd_data_i ' '
	do_lcd_data_i '1'
	do_lcd_data_i '7'
	do_lcd_data_i 's'
	do_lcd_data_i '1'
	do_lcd_data_i ' '
	do_lcd_data_i ' '
	do_lcd_data_i ' '
	do_lcd_data_i 'B'	
	do_lcd_data_i '2'

	do_lcd_command 0b11000000	; break to the next line	
	do_lcd_data_i 'V'
	do_lcd_data_i 'e'
	do_lcd_data_i 'n'
	do_lcd_data_i 'd'
	do_lcd_data_i 'i'
	do_lcd_data_i 'n'
	do_lcd_data_i 'g'
	do_lcd_data_i ' '
	do_lcd_data_i 'M'
	do_lcd_data_i 'a'
	do_lcd_data_i 'c'
	do_lcd_data_i 'h'	
	do_lcd_data_i 'i'	
	do_lcd_data_i 'n'
	do_lcd_data_i 'e'

	clear DisplayCounter

	rjmp main

main:
	mov temp, inStart	; checks if in start screen
	cpi temp, 0xFF
	breq end

	mov temp, inSelect	; check if in select screen
	cpi temp, 0xFF
	brne selectScreen

	/*
	do_lcd_command 0b00000001 		; clear display
    do_lcd_command 0b00000110 		; increment, no display shift
    do_lcd_command 0b00001110 		; Cursor on, bar, no blink
	*/
	
end:
	rjmp init_loop	

EXT_INT2:

		reti










