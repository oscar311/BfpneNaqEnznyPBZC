; COMP2121
; Project - Vending Machine
;	
; Coin Screen
; - takes in coin

.equ potMax = 2
.equ potMin = 9
.equ potMid = 34

.macro cpMax
	push r16
	ldi r16, low(0x3FD)
  	cp ADCLow, r16
	ldi r16, high(0x3FD)
  	cpc ADCHigh, r16
.endmacro

.macro cpMin
	push r16
	ldi r16, 0x001				; need a threshold for lower bound
  	cp ADCLow, r16
  	clr r16
  	cpc ADCHigh, r16
  	pop r16
.endmacro


coinScreen:
	mov  temp1, keyID 
	get_element temp1, Cost, coinsRequired
	clr coinsEntered

	rcall printCoinScreen

  	set_reg potPos, potMid

  	clear ADCCounter
	set_reg currFlag, ADCCoin				; notify all functions that coins are being counted
  	rcall coinCount

	; remember to move value outta r16 to different one else it'll be overwritten by keypad
ret



  	
coinCount:
  	; the timer constantly polls the flag so when we're in the coin screen, it'll start
  	; enabling the ADC reader which in turn updates temp and temp1 with the
  	; low and high bytes respectively
 		
		
	  	cpMax								; check if POT at max angle
	  	brge highSet

	  	cpMin								; check if POT at min angle	
	  	brlo lowSet
	  	
	  	rjmp init_loop						; POT somewhere in between

	  	lowSet:
			ldi r17, potMax
			cp potPos, r17					

			brne noCoin						; transitioned from high to low so coin entered

			inc coinsEntered
				rcall updateLEDs
	 			cp coinsEntered, coinsRequired
				brne notDone

				rcall removeItem
				set_reg currFlag, inDeliver			
				rjmp main

			notDone:
	  		rcall printCoinScreen			; update screen	

			noCoin:							; else there was no coin entered
			set_reg potPos, potMin			; set flag appropriately

	  		rjmp init_loop

		highSet:
			ldi r17, potMin
			cp potPos, r17					; if we didn't transition from low then ignore

			brne ignore
			
			set_reg potPos, potMax			; otherwise register the high angle
			

			ignore:
			rjmp init_loop
ret


printCoinScreen:
	do_lcd_command 0b00000001 				; clear display
	do_lcd_command 0b00000110 				; increment, no display shift
	do_lcd_command 0b00001110 				; Cursor on, bar, no blink

  	do_lcd_data_i 'I' 
  	do_lcd_data_i 'n' 
	do_lcd_data_i 's' 
	do_lcd_data_i 'e' 
	do_lcd_data_i 'r' 
	do_lcd_data_i 't' 
	do_lcd_data_i ' ' 
	do_lcd_data_i 'C' 
	do_lcd_data_i 'o' 
	do_lcd_data_i 'i' 
	do_lcd_data_i 'n' 
	do_lcd_data_i 's' 

  	do_lcd_command 0b11000000  				; break to the next line 

  	push currFlag
  	set_reg currFlag, inCoin				; pause the ADC so that the temp registers won't be updated		
  	mov r16, coinsRequired	
  	sub r16, coinsEntered
  	rcall print_digits ; row = item id 
  	pop currFlag							; resume the ADC operation		

  	ret

removeItem:
    push r16
    push r17
    mov r17, keyID
    get_element r17, Inventory, r16
    dec r16
    set_element r17, Inventory, r16
    pop r17
    pop r16
	ret

updateLEDS:
	push temp
	in temp, SREG
	push temp
	push coinsEntered
	push temp1
	clr r1

	ldi temp, 0

	LEDloop:
	cp r1, coinsEntered
	breq updateFinish

		lsl temp
		inc temp
		dec coinsEntered
		rjmp LEDloop

	updateFinish:
		out PORTC, temp

	pop temp1
	pop coinsEntered
	pop temp
	out SREG, temp
	pop temp

	ret
