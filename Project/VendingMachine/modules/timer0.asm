.equ INTS_PER_MS = 8        ; time per interrupt = (1/(16E6)) * (2^8 - 1) * 8 <- pre scaler = 127.5 us
                            ; number of interrupts per second = (1E-3) / (127.5)E-6 = 7.843 ~ 8

Timer0OVF: ; interrupt subroutine to Timer0
    push temp
    in temp, SREG
    push temp                               ; Prologue starts.
    push YH                                 ; Save all conflict registers in the prologue.
    push YL
    push r24
    push r25
    push r26
    push r27
    
    ;counting 3 seconds until the Start screen can be cleared
        lds r26, DisplayCounter
        lds r27, DisplayCounter+1
        adiw r27:r26, 1
        
        
        
        cpi r26, low(3000*INTS_PER_MS)        ; 3 second check
		ldi temp, high(3000*INTS_PER_MS) 
        cpc r27, temp
        brne skip
        
        
        clear DisplayCounter
        start_to_select
        /*mov temp, inStart
        cpi temp, 0xFF                 ; checking whether the start screen is open
                                ; not in start screen, so keep going
        brne skip   
        clr inStart
        //ser inSelect
        set_reg inSelect
        //rjmp main            ; if it is, tell main to change to Select screen
        */

skip:

    sts DisplayCounter, r26
    sts DisplayCounter +1, r27



EndIF:
    pop r27
    pop r26
    pop r25                                 ; Epilogue starts;
    pop r24                                 ; Restore all conflict registers from the stack.
    pop YL
    pop YH
    pop temp
    out SREG, temp
    pop temp
    reti                                    ; Return from the interrupt.