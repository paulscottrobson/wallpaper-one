; ****************************************************************************************************************
; ****************************************************************************************************************
;
;												Minol Maths Test
;
; ****************************************************************************************************************
; ****************************************************************************************************************

	cpu 	sc/mp

	include ..\minol\source\memorymacros.asm 					; Memory allocation and Macro definition.	

; ****************************************************************************************************************
;													Main Program
; ****************************************************************************************************************

	org 	0x9000 												; the ROM starts here

	db 		0x68												; this makes it boot straight into this ROM.
	lpi 	p3,Variables
	setv 	'C',10
	setv 	'D',20
	setv 	'Z',33
	lpi 	p1,Tests
Loop:
	ld 		(p1)												; have we finished ?
	jz 		DoneA
	lpi 	p2,0xFF8											; set up stack default value
	lpi 	p3,EvaluateExpression-1
	xppc 	p3
	jp 		Done 												; error occured
Skip:
	ld 		@1(p1) 												; find end of string
	jnz 	Skip
	ld 		@1(p1) 												; get correct answer and skip over it
	xre 														; same as returned answer
	jz 		Loop 												; true, go do next question.
	ldi 	0xFF 												; error $FF wrong answer
DoneA:
	xae
Done:
	lde 
	jmp 	Done

	include ..\minol\source\errors.asm 							; errors
	include ..\minol\source\expression.asm 						; expression evaluator (e.g. RHS)

Tests:
	include tests.inc 											; include autogenerated tests.
	db 		0
