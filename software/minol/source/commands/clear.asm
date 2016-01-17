; ****************************************************************************************************************
; ****************************************************************************************************************
;
;													CLEAR
;	
; ****************************************************************************************************************
; ****************************************************************************************************************

	jmp	CCL_Over

; ****************************************************************************************************************
;												CLEAR command
; ****************************************************************************************************************

CMD_Clear:
	lpi 	p3,Variables 										; point P3 to variables
	ldi 	26 													; loop counter to 26
	st 		-1(p2)
CCL_Loop:
	ldi 	0x00												; clear a variable
	st 		@1(p3)
	dld 	-1(p2) 												; done all
	jnz 	CCL_Loop											; loop back
	scl 														; no error

CCL_Over: