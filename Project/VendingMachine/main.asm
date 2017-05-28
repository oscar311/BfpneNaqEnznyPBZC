.equ inStart =  1
.equ inSelect = 2
.equ inCoin = 3
.equ inEmpty = 4

.def currFlag = r5
.def oldFlag = r6

.def row = r16
.def col = r17
.def rmask = r18                ; mask for row
.def cmask = r19                ; mask for column
.def temp = r20
.def temp1 = r21

								;we have up to and including r25

.dseg 
TempCounter:
    .byte 2             ; Temporary counter. Counts milliseconds
DisplayCounter:
    .byte 2             ; counts number of milliseconds for displays.
Inventory:
	.byte 9
Cost:
	.byte 9	

.cseg
.org 0x0000
   jmp RESET
   jmp DEFAULT          ; No handling for IRQ0.
   jmp DEFAULT          ; No handling for IRQ1.
.org OVF0addr
   jmp Timer0OVF        ; Jump to the interrupt handler for timer 0


jmp DEFAULT          ; default service for all other interrupts.
DEFAULT:  reti          ; no service

.include "m2560def.inc"
.include "modules/macros.asm"
.include "modules/lcd.asm"
.include "modules/timer0.asm"
.include "modules/keypad.asm"


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

	set_reg currFlag, inStart
	clr oldFlag
	clear DisplayCounter

    ldi temp, 0b00000000
    out TCCR0A, temp
    ldi temp, 0b00000010
    out TCCR0B, temp        ; Prescaling value=8
    ldi temp, 1<<TOIE0      ; = 128 microseconds
    sts TIMSK0, temp        ; T/C0 interrupt enable
	sei


	rjmp main

main:
	cp currFlag, oldFlag
	breq end				; no screen update needed 
	mov oldFlag, currFlag	; the screen needs updating

	mov temp, currFlag

	cpi temp, inStart		; checking which screen to update to
	brne checkSelect
	rcall startScreen
checkSelect:
	cpi temp, inSelect
	brne end
	rcall selectScreen		; TODO tell Oscar to add stuff to it 
checkEmpty:
	cpi temp, inEmpty
	rcall emptyScreen

	
	
end:
	rjmp init_loop

start_to_select:
    push temp
    in temp, SREG
    push temp

    mov temp, currFlag
    cpi temp, inStart              ; checking whether the start screen is open
    brne endF 
                                ; not in start screen, so keep going
    /*pop temp
    out SREG, temp
    pop temp*/

    
    set_reg currFlag, inSelect
    //rjmp main            ; if it is, tell main to change to Select screen

    endF:
    pop temp
    out SREG, temp
    pop temp
    ret 

.include "modules/AdminScreen.asm"
.include "modules/CoinReturn.asm"
.include "modules/DeliverScreen.asm"
.include "modules/EmptyScreen.asm"
.include "modules/SelectScreen.asm"
.include "modules/StartScreen.asm"

	










