; COMP2121
; Project - Vending Machine
;	
; Select Screen
;
; - screenFlag = SELECT
; -  
; - 
; - 


selectScreen:
	push temp
	in temp, SREG
	push temp

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



  	EndSelect:
  	pop temp
  	out SREG, temp
  	pop temp
	ret

select_screen:


  push temp
    in temp, SREG
    push temp
    push temp1
    ;push row ; row = item id
    push ZH
    push ZL
    push XH
    push XL

    // id = array index of item
/*
    mov temp, inSelect
    cpi temp, 0xFF                ; checking whether the select screen is open
    
    brne end 
  */                              ; not in start screen, so keep going
    pop temp
    out SREG, temp
    pop temp

    
    /* load  */

  ldi ZH, high(Inventory<<1)
  ldi ZL, low(Inventory<<1)

  ldi XH, high(Cost<<1)
  ldi XL, low(Cost<<1)

  search:
    lpm temp, Z+  ; load id item in from program memory pointed to by Z (r31:r30)
    lpm temp1, X+   ; load cost in
    cp temp, row
    breq display 
  rjmp search

  /* search unsuccessful - go to empty screen */
  rcall emptyScreen
  rjmp end
  /* no. = item */
  
  display:
    out PORTC, 0b00000100   ; debugging -> bit placement marks where porgram's up to
    print_digits temp

    /* inCoin unfinished */

    set_reg inCoin ; set coin reg 
  
  rjmp end

end:
  push XL
    push XH
    push ZL
    push ZH
    ;pop row    ; not necessary but safe coding and all that
    push temp1
    pop temp
    out SREG, temp
    pop temp

ret