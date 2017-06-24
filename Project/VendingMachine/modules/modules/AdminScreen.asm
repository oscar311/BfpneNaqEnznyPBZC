; COMP2121
; Project - Vending Machine
;	
; Admin Screen

adminScreen:
  push temp
  in temp, SREG
  push temp
  push temp1


  ser temp1
  cp keyPress, temp1
  

  breq notDefault

  defaultItem:
  ldi temp, 1
  mov currItem, temp

  notDefault:						; a key has been pressed so assume item has been changed if needed

  //out PORTC, currItem

  do_lcd_command 0b00000001 		; clear display
  do_lcd_command 0b00000110 		; increment, no display shift
  do_lcd_command 0b00001110 		; Cursor on, bar, no blink

  do_lcd_data_i 'A' 
  do_lcd_data_i 'd' 
  do_lcd_data_i 'm' 
  do_lcd_data_i 'i' 
  do_lcd_data_i 'n' 
  do_lcd_data_i ' ' 
  do_lcd_data_i 'm' 
  do_lcd_data_i 'o' 
  do_lcd_data_i 'd' 
  do_lcd_data_i 'e' 
  do_lcd_data_i ' '

  mov r16, currItem
  rcall print_digits 

  do_lcd_command 0b11000000  		; break to the next line 

  mov temp1, currItem
  get_element temp1, Inventory, r16
  rcall print_digits 				; print inventory

  rcall addSpaces					; print spaces to move cost to the end of line

  mov temp1, currItem
  get_element temp1, Cost , r16
  rcall print_digits 				; print inventory

  rcall AdminUpdateLEDs
  clr keyPress

  pop temp1
  pop temp
  out SREG, temp
  pop temp

  ret 


updateAdminItem:
	push temp
	in temp, SREG
	push temp

	ldi temp, inAdmin
	cp oldFlag, temp
	brne noUpdate

	mov currItem, keyID

	noUpdate:
  	pop temp
 	out SREG, temp
  	pop temp

  	ret

addSpaces:
	push temp
	in temp, SREG
	push temp

	do_lcd_data_i ' ' 
	do_lcd_data_i ' ' 
	do_lcd_data_i ' ' 
	do_lcd_data_i ' ' 
	do_lcd_data_i ' ' 
	do_lcd_data_i ' ' 
	do_lcd_data_i ' ' 
	do_lcd_data_i ' ' 
	do_lcd_data_i ' '  
	do_lcd_data_i '$'

  	pop temp
 	out SREG, temp
  	pop temp 

  	ret

exitAdmin:
	push temp
	in temp, SREG
	push temp	

	ldi temp, inAdmin
	cp oldFlag, temp

	brne noAdminExit

	set_reg currFlag, inSelect

	clr temp1
	out PORTC, temp1
	out PORTE, temp1					; turn off LEDs

	noAdminExit:
  	pop temp
 	out SREG, temp
  	pop temp 

  	ret

adminRemoveItem:
	push temp
	in temp, SREG
	push temp	
    push r16
    push r17

	ldi temp, inAdmin
	cp oldFlag, temp
	brne endRemove

    set_reg keyPress, 0xFF					; set flag to update the screen

    mov r17, currItem
    get_element r17, Inventory, r16

    cpi r16, 0
    breq endRemove

    dec r16
    set_element r17, Inventory, r16

    endRemove:
    pop r17
    pop r16
  	pop temp
 	out SREG, temp
  	pop temp 
ret

adminAddItem:
	push temp
	in temp, SREG
	push temp	
    push r16
    push r17

	ldi temp, inAdmin
	cp oldFlag, temp
	brne endAdd

    set_reg keyPress, 0xFF					; set flag to update the screen

    mov r17, currItem
    get_element r17, Inventory, r16

    cpi r16, 255
    breq endAdd

    inc r16
    set_element r17, Inventory, r16

    endAdd:
    pop r17
    pop r16
  	pop temp
 	out SREG, temp
  	pop temp 
ret

adminIncCost:
	push temp
	in temp, SREG
	push temp	
    push r16
    push r17

	ldi temp, inAdmin
	cp oldFlag, temp
	brne endIncCost

    set_reg keyPress, 0xFF					; set flag to update the screen

    mov r17, currItem
    get_element r17, Cost, r16

    cpi r16, 3
    breq endIncCost

    inc r16
    set_element r17, Cost, r16

    endIncCost:
    pop r17
    pop r16
  	pop temp
 	out SREG, temp
  	pop temp 
ret

adminDecCost:
	push temp
	in temp, SREG
	push temp	
    push r16
    push r17

	ldi temp, inAdmin
	cp oldFlag, temp
	brne endDecCost

    set_reg keyPress, 0xFF					; set flag to update the screen

    mov r17, currItem
    get_element r17, Cost, r16

    cpi r16, 1
    breq endDecCost

    dec r16
    set_element r17, Cost, r16

    endDecCost:
    pop r17
    pop r16
  	pop temp
 	out SREG, temp
  	pop temp 
ret

resetNumItems:
	push temp
	in temp, SREG
	push temp	
    push r16
    push r17

	ldi temp, inAdmin
	cp oldFlag, temp
	brne endReset

    set_reg keyPress, 0xFF					; set flag to update the screen

    mov r17, currItem
    clr r16
    set_element r17, Inventory, r16

    endReset:
    pop r17
    pop r16
  	pop temp
 	out SREG, temp
  	pop temp 
ret

AdminUpdateLEDs:
	push temp
	in temp, SREG
	push temp
	push r17
	push temp1

	clr r1
	ldi temp, 0

	mov r17, currItem
	get_element r17, Inventory, temp1
	push temp1

	AdminLEDloop:
	cp r1, temp1
	breq LEDFinish

		lsl temp
		inc temp
		dec temp1
		rjmp AdminLEDloop
	LEDFinish:
		out PORTC, temp
	
	pop temp1
	
	cpi temp1, 9

	brlo noOtherLights
	breq oneLight
	rjmp twoLights

	oneLight:
	ldi temp1, 0b00001000
	jmp printLights

	twoLights:
	ldi temp1, 0b00101000
	jmp printLights

	noOtherLights:
	clr temp1

	printLights:
	out PORTE, temp1

	endLEDUpdate:
	pop temp1
	pop r17
	pop temp
	out SREG, temp
	pop temp

	ret