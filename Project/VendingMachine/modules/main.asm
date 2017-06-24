.equ inStart =  1
.equ inSelect = 2
.equ inCoin = 3
.equ inEmpty = 4
.equ ADCCoin = 6
.equ inReturn = 5
.equ inDeliver = 7
.equ inAdmin = 8

.equ aKey = 20
.equ bKey = 21
.equ cKey = 22
.equ dKey = 23
.equ asterix = 24
.equ hash = 25
.equ zeroButton = 26

.equ turnLEDOff = 0b11010000
.equ turnLEDOn =  0b00101111
.equ turnMotOn = 0b11010000

.def currFlag = r4
.def oldFlag = r5
.def keyPress = r6
.def keyID = r7
.def potPos = r8
.def coinsToReturn = r9 
.def coinsEntered = r10	
.def coinsRequired = r11
.def keyDebounce = r12
.def currItem = r13
.def asterixPressed = r14

.def row = r16
.def col = r17
.def rmask = r18                ; mask for row
.def cmask = r19                ; mask for column
.def temp = r20
.def temp1 = r21
.def ADCLow = r22
.def ADCHigh = r23

								;we have up to and including r25

.dseg 
LEDCounter:
    .byte 2             ; Temporary counter. Counts milliseconds
DisplayCounter:
    .byte 2             ; counts number of milliseconds for displays.
ReturnCounter:
	.byte 2
AsterixCounter:
	.byte 2
SoundCounter:
	.byte 2
ADCCounter:
	.byte 2
Inventory:
	.byte 9
Cost:
	.byte 9	


.cseg
.org 0x0000
   jmp RESET
.org INT0addr
	jmp EXT_INT0		
.org INT1addr
   jmp EXT_INT1
.org OVF0addr
   jmp Timer0OVF        ; Jump to the interrupt handler for timer 0
.org ADCCaddr
	jmp EXT_POT


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
	sts DDRL, temp1					; sets lower bits as input and upper as output

	rcall InitArrays				; initializes the Cost & Inventory arrays with appropriate values



	ser temp1 						; set Port C,B & D as output - reset all bits to 0 (ser = set all bits in register)
	out DDRC, temp1 
	out DDRE, temp1
	out DDRB, temp1
	out DDRG, temp1

	ser temp1
	out PORTG, temp1

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

	clr temp
	out DDRD, temp					; set PORTD (external interrupts) as input

	ldi temp, (1 << INT0) | (1 << INT1)
	out EIMSK, temp

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
	clear SoundCounter
	clr asterixPressed

    ldi temp, 0b00000000
    out TCCR0A, temp
    ldi temp, 0b00000010
    out TCCR0B, temp        ; Prescaling value=8
    ldi temp, 1<<TOIE0      ; = 128 microseconds
    sts TIMSK0, temp        ; T/C0 interrupt enable

	clr coinsToReturn

	// REFS0: sets up voltage reference, 0b01 provides the reference with the best range
	// setting ADLAR to 1 left aligns the 10 output bits within the 16 bit output register
	// MUX0 to MUX5 choose the input pin/mode/gain. 0b10000 chooses PK8 on the board
	// ADIE enables the ADC interrupt, which interrupts when a conversion is finished
	// ADPS0 chooses the ADC clock divider. 0b111 uses a 128 divider to get a 125 kHz ADC
	//      clock which is within the recommended range of 50 - 200 kHz
	ldi temp, (0b01 << REFS0) | (0 << ADLAR) | (0 << MUX0)
	sts ADMUX, temp

	ldi temp, (1 << MUX5)
	sts ADCSRB, temp

	ldi temp, (1 << ADEN) | (1 << ADIE) | (0b111 << ADPS0) 
	sts ADCSRA, temp

	sei



main:
	cp currFlag, oldFlag
	brne update				; screen update needed 
	
	ldi temp, 0xFF
	cp keyPress, temp
	brne end				; if key not pressed no update needed 
							; else if is pressed then one of the screens might need updating
	update:
	mov oldFlag, currFlag	; update flags

	mov temp, currFlag
	
	cpi temp, inStart		; checking which screen to update to
	brne checkAdmin
	rcall startScreen
checkAdmin:
	cpi temp, inAdmin		; checking which screen to update to
	brne checkSelect
	rcall adminScreen
checkSelect:
	cpi temp, inSelect
	brne checkEmpty
	rcall selectScreen		
checkEmpty:
	cpi temp, inEmpty
	brne checkCoin
	rcall emptyScreen
checkCoin:
	cpi temp, inCoin
	brne checkReturn
	rcall coinScreen
checkReturn:
	cpi temp, inReturn
	brne checkDeliver
	rcall returnScreen
checkDeliver:
	cpi temp, inDeliver
	brne end
	rcall deliverScreen
	
end:
	rjmp init_loop

	
checkCoins:
    push temp
    in temp, SREG
    push temp

	ldi temp, ADCCoin
	cp currFlag, temp
	brne endFunction

	clr temp
	cp coinsEntered, temp
	brne retCoin

	set_reg currFlag, inSelect			; no coins have been entered
	rjmp endF

	retCoin:							; coins have been entered
	set_reg currFlag, inReturn

	endFunction:
	rjmp endF	

start_to_select:
    push temp
    in temp, SREG
    push temp

    mov temp, currFlag
    cpi temp, inStart              ; checking whether the start screen is open
    brne endFunction
                                ; not in start screen, so keep going
    
    set_reg currFlag, inSelect
	clr_reg keyPress					; ignore this key press
	rjmp endF

empty_to_select:
    push temp
    in temp, SREG
    push temp

    mov temp, currFlag
    cpi temp, inEmpty              ; checking whether the empty screen is open
    brne endF 
									; not in empty screen, so keep going
	clr temp
	out PORTC, temp                     
	out PORTE, temp
    
    set_reg currFlag, inSelect
	clr_reg keyPress					; ignore this key press
	rjmp endF

select_to_admin:
    push temp
    in temp, SREG
    push temp
	push r26
	push r27

    mov temp, oldFlag
    cpi temp, inSelect              ; checking whether the empty screen is open
    brne endF 

	lds r26, AsterixCounter
    lds r27, AsterixCounter+1

	cpi r26, low(5000*INTS_PER_MS)        
    ldi temp, high(5000*INTS_PER_MS) 
    cpc r27, temp

	pop r27
	pop r26

	brne endF						; button not held down for 5 seconds yet

									; not in empty screen, so keep going    
    set_reg currFlag, inAdmin
	clr_reg keyPress					; ignore this key press
	rjmp endF

deliver_to_select:
	push temp
    in temp, SREG
	push temp

	mov temp, currFlag
    cpi temp, inDeliver              ; checking whether the empty screen is open
    brne endF 

    set_reg currFlag, inSelect
	ldi temp, 0
	out PORTE, temp     ; turn off moter 

    endF:
    pop temp
    out SREG, temp
    pop temp
    ret 

.include "modules/AdminScreen.asm"
.include "modules/CoinReturn.asm"
.include "modules/CoinScreen.asm"
.include "modules/DeliverScreen.asm"
.include "modules/EmptyScreen.asm"
.include "modules/SelectScreen.asm"
.include "modules/StartScreen.asm"

initArrays:
	push temp
	in temp, SREG
	push temp
	push temp1
	
	ldi temp1, 1

	loop:
	cpi temp1, 10
	breq endLoop
	mov r16, temp1
	set_element temp1 ,Inventory, r16
	rcall odd_or_even
	set_element temp1 ,Cost, r16
	inc temp1
	rjmp loop

	endLoop:
	pop temp1
	pop temp
	out SREG, temp
	pop temp
	ret


odd_or_even:
    push temp1
	push temp
    in temp, SREG
	push temp
    /*
        9 ->       1 0 0 1
        1 ->     & 0 0 0 1
                   -------
                   0 0 0 1

        14 ->      1 1 1 0
        1 ->     & 0 0 0 1
                   -------
                   0 0 0 0          
    */
                
    andi temp1, 1                   
    cpi temp1, 0
    breq even
    cpi temp1, 1
    breq odd

    even:
        ldi r16, 2
        rjmp endOop
    odd: 
        ldi r16, 1

	endOop:
	pop temp
    out SREG, temp
	pop temp
    pop temp1
	ret

EXT_POT:
	push temp
	in temp, SREG
	push temp

	lds ADCLow, ADCL
    lds ADCHigh, ADCH

	pop temp
	out SREG, temp
	pop temp

	reti

EXT_INT0:
	push temp
	in temp, SREG
	push temp

	rcall empty_to_select					; to abort the empty screen if needed
	rcall adminAddItem						; to add an item if in Admin mode
	rcall debounce_sleep

	pop temp
	out SREG, temp
	pop temp
	reti

EXT_INT1:
	push temp
	in temp, SREG
	push temp

	rcall empty_to_select					; to abort the empty screen if needed
	rcall adminRemoveItem					; to remove an item if in Admin mode
	rcall debounce_sleep

	pop temp
	out SREG, temp
	pop temp
	reti
