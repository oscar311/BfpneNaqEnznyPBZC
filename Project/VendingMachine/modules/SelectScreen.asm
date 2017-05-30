; COMP2121
; Project - Vending Machine
; 
; Empty Screen

selectScreen:
	push temp
	in temp, SREG
	push temp
  push temp1

  do_lcd_command 0b00000001 		; clear display
  do_lcd_command 0b00000110 		; increment, no display shift
  do_lcd_command 0b00001110 		; Cursor on, bar, no blink

  do_lcd_data_i 'S' 
  do_lcd_data_i 'e' 
  do_lcd_data_i 'l' 
  do_lcd_data_i 'e' 
  do_lcd_data_i 'c' 
  do_lcd_data_i 't' 
  do_lcd_data_i ' ' 
  do_lcd_data_i 'i' 
  do_lcd_data_i 't' 
  do_lcd_data_i 'e' 
  do_lcd_data_i 'm' 
  do_lcd_data_i ' ' 
  do_lcd_data_i ' '   
  do_lcd_data_i ' ' 

  mov temp1, keyPress
  cpi temp1, 0xFF
  brne EndSelect

  clr keyPress
  mov r16, keyID
  get_element r16, Inventory, temp1

  out PORTC,  temp1
  //rcall belay

  cpi temp1, 0
  breq empty 
  set_reg currFlag, inCoin
  jmp EndSelect

  empty:
    set_reg currFlag, inEmpty


	EndSelect:
  pop temp1
	pop temp
	out SREG, temp
	pop temp
	ret


belay:
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
    rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
    rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
    rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
    rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
    rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  rcall debounce_sleep
  ret