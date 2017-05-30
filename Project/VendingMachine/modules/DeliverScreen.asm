; COMP2121
; Project - Vending Machine
;	
; Deliver Screen

.include "m2560def.inc"

/*
Having completed payment, the machine should deliver the item to the user by spinning the motor
at full speed for 3 seconds and flash the LEDs in the same way as the ‘empty’ screen. Afterwards the
program should go back to the ‘select’ screen.
This state cannot be aborted – all input should be ignored. The following should be displayed on the
screen:


*/

deliver_screen:
	push temp
	in temp, SREG
	push temp

  	do_lcd_command 0b00000001 		; clear display
  	do_lcd_command 0b00000110 		; increment, no display shift
  	do_lcd_command 0b00001110 		; Cursor on, bar, no blink

	do_lcd_data_i 'D' 
	do_lcd_data_i 'e' 
	do_lcd_data_i 'l' 
	do_lcd_data_i 'i' 
	do_lcd_data_i 'v' 
	do_lcd_data_i 'e' 
	do_lcd_data_i 'r' 
	do_lcd_data_i 'i' 
	do_lcd_data_i 'n' 
	do_lcd_data_i 'g' 
	do_lcd_data_i ' ' 
	do_lcd_data_i 'i' 
	do_lcd_data_i 't'   
	do_lcd_data_i 'e'
	do_lcd_data_i 'm' 


	temp, 0xFF			
	out PORTE, temp		; turn on motor

  	out PORTC, temp		; flash leds like empty screen
  	out PORTG, temp

  	clear displayCounter			; start change display timer 
  	clear LEDCounter 				; start LED change timer

EndDeliver:
	pop temp
	out SREG, temp
	pop temp
ret