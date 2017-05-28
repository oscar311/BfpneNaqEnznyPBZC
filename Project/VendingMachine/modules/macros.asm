; The macro clears a word (2 bytes) in a memory
; the parameter @0 is the memory address for that word
.macro clear
    ldi YL, low(@0)     ; load the memory address to Y
    ldi YH, high(@0)
    clr temp 
    st Y+, temp         ; clear the two bytes at @0 in SRAM
    st Y, temp
.endmacro


.macro do_lcd_command
    ldi r16, @0
    rcall lcd_command
    rcall lcd_wait
.endmacro

/*
Usage:
    ldi r24, 4
    ldi temp1, 2
    set_element r24,Inventory, temp1
    ldi r24, 6
    ldi temp1, 9
    set_element r24,Inventory, temp1
    clr temp1
    ldi r24, 4
    get_element r24,Inventory, temp1
    ldi r24, 6
    get_element r24,Inventory, temp1
*/

/*
    @0 - register containing desired index (not temp!)
    @1 - address of array to read from
    @2 - register to write value to
*/
.macro get_element
    push XL
    push XH
    push @0
    push temp
    in temp, SREG
    push temp   
    
    ldi XL, low(@1)
    ldi XH, high(@1)

    loop:
    cpi @0, 0
    breq getVal
    subi @0, 1
    adiw XL:XH, 1
    jmp loop
    
    getVal:
    ld @2, X
    
    pop temp
    out SREG, temp
    pop temp
    pop @0
    pop XH
    pop XL
.endmacro

/*
    @0 - register containing desired index (not temp!)
    @1 - address of array to write to
    @2 - register to write value from
*/
.macro set_element
    push XL
    push XH
    push @0
    push temp
    in temp, SREG
    push temp
    
    ldi XL, low(@1)
    ldi XH, high(@1)

    loop:
    cpi @0, 0
    breq setVal
    subi @0, 1
    adiw XL:XH, 1
    jmp loop
    
    setVal:
    st X, @2

    pop temp
    out SREG, temp
    pop temp
    pop @0
    pop XH
    pop XL
.endmacro

.macro set_reg
    push temp
    ldi temp, @1
    mov @0, temp
    pop temp
.endmacro

.macro clr_reg
    push temp
    clr temp
    mov @0, temp
    pop temp
.endmacro

.macro do_lcd_data
    push r16
    mov r16, @0
    subi r16, -'0'
    rcall lcd_data
    rcall lcd_wait
    pop r16
.endmacro

.macro do_lcd_data_i
	push r16
	ldi r16, @0
	rcall lcd_data
	rcall lcd_wait
	pop r16
.endmacro

.macro lcd_set
    sbi PORTA, @0           //set a bit (specified by @0) in portA
.endmacro

.macro lcd_clr
    cbi PORTA, @0           //clear a bit (specified by @0) in portA
.endmacro

