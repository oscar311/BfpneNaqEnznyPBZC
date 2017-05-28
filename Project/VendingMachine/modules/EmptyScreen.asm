; COMP2121
; Project - Vending Machine
;	
; Empty Screen

emptyScreen:
	do_lcd_command 0b00000001 		; clear display
	do_lcd_command 0b00000110 		; increment, no display shift
	do_lcd_command 0b00001110 		; Cursor on, bar, no blink

  	do_lcd_data_i 'O' 
  	do_lcd_data_i 'u' 
	do_lcd_data_i 't' 
	do_lcd_data_i ' ' 
	do_lcd_data_i ' ' 
	do_lcd_data_i 'O' 
	do_lcd_data_i 'f' 
	do_lcd_data_i ' ' 
	do_lcd_data_i 'S' 
	do_lcd_data_i 't' 
	do_lcd_data_i 'o' 
	do_lcd_data_i 'c' 
	do_lcd_data_i 'k'   
	do_lcd_data_i ' ' 

  	do_lcd_command 0b11000000  ; break to the next line   
  	print_digits row ; row = item id 
  	
	ret