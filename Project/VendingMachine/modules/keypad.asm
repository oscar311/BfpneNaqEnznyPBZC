.equ PORTLDIR = 0xF0            ; 1111 0000 to set lower pins to input and upper pins to output
.equ INITCOLMASK = 0xEF         ; 1110 1111 to check the rightmost column (0 for logic low & 1 for logic high)
.equ INITROWMASK = 0x01         ; 0000 0001 to check the top row (1 to read input) 
.equ ROWMASK = 0x0F             ; for obtaining input from port L

init_loop:
    ldi cmask, INITCOLMASK
    clr col 
    

colloop:
    cpi col, 4                  ; if it reached the end of the columns
    breq init_loop              ; restart whole loop again
    sts PORTL, cmask            ; send logic low to certain column to read by row port

    ldi temp, 0xFF   

delay:  
    dec temp
    brne delay                  ; delays process for 255 clocks

    lds temp, PINL
    andi temp, ROWMASK          ; masking the higher bits (which will be set to output hence garbage)
    cpi temp, 0xF               ; Check if any of the rows is low (0xF = 0000 1111)
    breq nextCol                ; all rows are high
    out PORTC, temp

    rcall start_to_select     ; if any button is pressed, change (if applicable) startScreen to selectScreen
               

    ldi rmask, INITROWMASK      ;Initialize for row check
    clr row

rowLoop:
    cpi row, 4                  ; goes to the end of the rows
    breq nextCol                ; the row scan is over
    mov temp1, temp             ; copying input from pins into temp1
    and temp1, rmask            ; to only check a certain row  (if output is 00 then the Z flag is set)
    breq convert                ; if temp1 is zero (checks zero flag) then jump to convert
    inc row
    lsl rmask                   ; to unmask the next row
    jmp rowLoop

nextCol:
    lsl cmask                   ; to unmask the next col
    inc col                     
    jmp colloop                 ; in no button pressed jump back to start

convert:
    cpi col, 3              
    breq letters                ; if one of the letters have been pressed
    cpi row, 3
    brne isNumber               ; row != 3 & col != 3, then its a number
    cpi col, 0
    breq resetButton            ; row == 3 & col == 0, then the * has been pressed
    cpi col, 1                  
    breq zero                   ; row == 3 & col == 1, then the 0 has been pressed

    

    isNumber:                   ; else we convert the binary to an ASCII value

    lsl temp                    ; multiply by 2
    add temp, row               ; multiply 3
    add temp, col
    subi temp, -1               ; temp now contains the actual number

    mov row, temp      ; result is moved into row
    // now check 
    set_reg inSelect
    rjmp main

zero:
    clr temp
                  ; add_to_num adds temp (which has current digit) to current number

letters:
    cpi row, 0                  ; if its an A
    breq aButton
    cpi row, 1                  ; if its a B
    breq bButton
    cpi row, 2                  ; if its a C
    breq cButton
    cpi row, 3                  ; if its a D
    breq dButton
    
aButton:

bButton:

cButton:
    
dButton: 

resetButton:

write_out:

