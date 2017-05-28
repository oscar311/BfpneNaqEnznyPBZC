; COMP2121
; Project - Vending Machine
;	
; Start Screen
;
; - initialises lcd / keypad / timers -> (note: maybe group them into modules we .include when needed  )
; - jmps to select screen if 3 secs pass or until any keypad input
;

startScreen:
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
	do_lcd_data_i ' '					; not sure how many spaces needed
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
	ret