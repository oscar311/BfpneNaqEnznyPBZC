; COMP2121
; Project - Vending Machine
;	
; Start Screen
;
; - initialises lcd / keypad / timers -> (note: maybe group them into modules we .include when needed  )
; - jmps to select screen if 3 secs pass or until any keypad input
;


.include "m2560def.inc"

start:

	rjmp start