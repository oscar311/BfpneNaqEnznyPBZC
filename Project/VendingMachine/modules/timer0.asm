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
    brne skipDisplay
    
    rcall start_to_select                   ; if the start screen needs to be changed
    rcall empty_to_select                   ; if the empty screen needs to be changed
    rcall deliver_to_select                 ; go from deliver screen to select screen (if t=3 mot off)

    clear DisplayCounter 

    rjmp EndIF

    skipDisplay:

    sts DisplayCounter, r26
    sts DisplayCounter +1, r27


    ;counting 1.5 seconds  to turn off the 10 LEDs
        lds r26, LEDCounter
        lds r27, LEDCounter+1
        adiw r27:r26, 1

        // flashes leds when inEmpty || inSelect
        
        ldi temp, inEmpty
        cp currFlag, temp                         ; if not in EmptyScreen then no need to consider this

        ldi temp, inDeliver
        cp currFlag, temp

        brne skipLED

        cpi r26, low(1500*INTS_PER_MS)        ; 1.5 second check
        ldi temp, high(1500*INTS_PER_MS) 
        cpc r27, temp
        brne skipLED
        
        clear LEDCounter 

        com ledVal                            ; invert to set all bits to zero hence turn LED off (need to set the top 2 LEDS as well)
        out PORTC, ledVal
        out PORTG, ledVal

        rjmp EndIF

        skipLED:

        sts LEDCounter, r26
        sts LEDCounter +1, r27

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