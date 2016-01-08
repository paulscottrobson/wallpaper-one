; ******************************************************************************************************************
; ******************************************************************************************************************
; ******************************************************************************************************************
;
;												Machine Language Monitor
;
; ******************************************************************************************************************
; ******************************************************************************************************************
; ******************************************************************************************************************

; TODO: 
; 		Assembler (remember Jump adjustment ?)
;		Labels.
; 		Disassembler (if space available)

		cpu	sc/mp

cursor 		= 0xC00 											; cursor position
current 	= 0xC01 											; current address (lo,hi)
parPosn		= 0xC03 											; current param offset in buffer (low addr)
modifier  	= 0xC04 											; instruction modifier (@,Pn)
kbdBuffer 	= 0xC05 											; 12 character keyboard buffer
kbdBufferLn = 12 										

codeStart 	= kbdBuffer+kbdBufferLn								; code starts here.

tapeDelay 	= 4 												; DLY parameter for 1 tape bit width.
																; (smaller = faster tape I/O)

		org 	0x0000
		nop

; ******************************************************************************************************************
;
;									Find Top of Memory to initialise the stack.
;
; ******************************************************************************************************************
		ldi 	0x0F 											; point P2 to theoretical top of RAM on basic m/c
		xpah 	p2 												; e.g. 0xFFF
		ldi 	0xFF 											; ideally you'd make this 0x003F and remove the ld
		xpal 	p2 												; but the emulators don't do 4+12 math. Only matters here.
		ld 		@64(p2) 										; fix the predecrement (wrap around not emulated)
FindTopMemory:
		ldi 	0xA5 											; try to write this to memory
		st 		@-64(p2) 										; predecrementing by 64.
		xor 	(p2) 											; did it write correctly.
		jnz 	FindTopMemory 									; now P2 points to top of memory.

; ******************************************************************************************************************
;
;									Reset cursor position and current address.
;
; ******************************************************************************************************************

		ldi 	Current/256 									; set P1 to current address
		xpah 	p1
		ldi 	Current&255
		xpal 	p1
		ldi 	codeStart & 255 								; reset current address to code start
		st 		@1(p1)
		ldi 	codeStart / 256
		st 		@(p1)

; ******************************************************************************************************************
;
;												Clear the screen
;
; ******************************************************************************************************************

ClearScreen_Command:
		ldi 	0
		xpah 	p1
		ldi 	0
ClearScreenLoop:
		xpal 	p1												; clear screen
		ldi 	' '
		st 		@1(p1)
		xpal 	p1
		jp 		ClearScreenLoop
		ldi 	Cursor/256 										; reset the cursor position to TOS
		xpah 	p1
		ldi 	Cursor&255
		xpal 	p1 
		ldi 	0
		st 		0(p1)											


; ****************************************************************************************************************
;
;													Main Loop
;
; ****************************************************************************************************************

CommandMainLoop:
		ldi 	(PrintAddressData-1)/256						; print Address and Data there
		xpah 	p3
		ldi 	(PrintAddressData-1)&255
		xpal 	p3
		ldi 	0
		xppc 	p3

		ldi 	(PrintCharacter-1)/256 							; set P3 = print character.
		xpah 	p3
		ldi 	(PrintCharacter-1)&255
		xpal 	p3
		ldi 	']'												; print the prompt.
		xppc 	p3

; ****************************************************************************************************************
;
;											Keyboard Line Input
;
; ****************************************************************************************************************

		ldi 	0 												; set E = character position.
		xae 
KeyboardLoop:
		ldi 	0x8 											; set P1 to point to keyboard latch
		xpah 	p1
_KBDWaitRelease:
		ld 		0(p1) 											; wait for strobe to clear
		jp 		_KBDWaitKey
		jmp 	_KBDWaitRelease
_KBDWaitKey:
		ld 		0(p1) 											; wait for strobe, i.e. new key
		jp 		_KBDWaitKey
		ani 	0x7F 											; throw away bit 7
		st 		-1(p2) 											; save key.

		ldi 	kbdBuffer/256 									; set P1 = keyboard buffer
		xpah 	p1
		ldi 	kbdBuffer&255
		xpal 	p1		

		ld 		-1(p2) 											; read key
		xri 	8 												; is it backspace
		jz 		__KBDBackSpace
		xri 	8!13 											; is it CR, then exit
		jz 		__KBDExit

		lde 													; have we a full buffer.
		xri 	kbdBufferLn 									; if so, ignore the key.
		jz 		KeyboardLoop

		ld 		-1(p2) 											; restore the key.
		ccl
		adi 	0x20											; will make lower case -ve
		jp 		__KBDNotLower
		cai 	0x20 											; capitalise
__KBDNotLower:
		adi 	0xE0 											; fix up.
		st 		-0x80(p1) 										; save in the buffer using E as index.
		xppc 	p3 												; print the character
		xae 													; increment E
		ccl
		adi 	1
		xae
		jmp 	KeyboardLoop 									; and get the next key.

__KBDBackSpace:
		lde 													; get position
		jz 		KeyboardLoop 									; can't go back if at beginning
		scl 													; go back 1 from E
		cai 	1
		xae 
		ldi 	8 												; print a backspace
		xppc 	p3
		jmp 	KeyboardLoop 									; and go round again.

__CmdMainLoop1:
		jmp 	CommandMainLoop

__KBDExit:
		st 		-0x80(p1) 										; add the ASCIIZ terminator.
		ldi 	13												; print a new line.
		xppc 	p3

; ****************************************************************************************************************
;
;						Extract the 5 bit 3 letter (max command value). P1 points to buffer
;
; ****************************************************************************************************************

		ldi 	0
		xae 													; E contains the LSB of the 5 bit shift
		lde 	
		st 		-1(p2) 											; -1(P2) contains the MSB
		st 		modifier-kbdBuffer(p1)							; clear the modifier.
Extract5Bit:
		ld 		(p1) 											; look at character
		ccl 													; add 128-65, will be +ve if < 64
		adi 	128-65
		jp 		__ExtractEnd
		ldi 	5 												; shift current value left 5 times using -2(p2)
		st 		-2(p2)
__Ex5Shift:
		lde 													; shift E left into CY/L
		ccl
		ade 
		xae
		ld 		-1(p2) 											; shift CY/L into -1(p2) and carry/link
		add 	-1(p2)
		st 		-1(p2)
		dld 	-2(p2) 											; done it 5 times ?
		jnz 	__Ex5Shift
		ld 		@1(p1) 											; re-read character.
		ani 	0x1F 											; lower 5 bits only.
		ore 													; OR into E
		xae
		jmp 	Extract5Bit 									; go and get the next one.

__ExtractEnd:
		ldi 	parPosn & 255 									; P1.L = Parameter Position, A = first non cmd char
		xpal	p1
		st 		(p1) 											; write to parameter position.

; ****************************************************************************************************************
;
;						Find command in -1 (P2) (High) E (Low) in Command table
;	
; ****************************************************************************************************************

		ldi 	__commandList & 255 							; point P1 to the command list
		xpal 	p1
		ldi 	__commandList / 256 		
		xpah 	p1	
__FindCommandLoop:
		ld 		0(p1) 											; reached the end of the table ?
		or 		1(p1)											; which is marked by word 0000
		jz 		__CommandError
		ld 		@3(p1) 											; read low byte, and point to next
		xre
		jnz 	__FindCommandLoop 								; if different to LSB loop back.
		ld 		-2(p1) 											; read the high byte
		xor 	-1(p2) 											; if different to the MSB loop back.
		jnz 	__FindCommandLoop

; ****************************************************************************************************************
;
;				Found command, figure out if ASM or Command, if Command go to that routine
;
; ****************************************************************************************************************

		ldi 	(GetParameter-1) & 255 							; point P3 to the get parameter code.
		xpal 	p3
		ldi 	(GetParameter-1) / 256
		xpah 	p3

		ld 		-1(p1) 											; read the operation code.
		ani 	0xF0 											; look at the m-s-nibble - commands are 0x20.
		xri 	0x20
		jnz 	__Assembler

		ld 		-1(p1) 											; re-read it
		ccl
		add 	-1(p1) 											; double it
		ani 	0x1F 											; lower 5 bits only.
		adi 	__CommandTable & 255 							; make P1 point to the command table entry
		xpal 	p1
		ldi 	__CommandTable / 256 					
		xpah 	p1
		ld 		0(p1) 											; read low address
		xae
		ld 		1(p1) 											; read high address
		xpah 	p1 												; put in P1.H
		lde 													; get low address
		xpal 	p1 												; put in P1.L
		ld 		@-1(p1) 										; fix up for the pre-increment
		xppc 	p1 												; and go there.

__CommandError:
		ldi 	3 												; set the beeper on
		cas
		dly 	0xFF 											; short delay
		ldi 	0 												; set the beeper off
		cas
__CmdMainLoop2:													; and go back to the start.
		jmp 	__CmdMainLoop1

		; TODO: Assembler here, at present it just stops.

__Assembler:
		jmp 	__Assembler

; ****************************************************************************************************************
; ****************************************************************************************************************
;
;												Commands Section
;
; ****************************************************************************************************************
; ****************************************************************************************************************

; ****************************************************************************************************************
;											A : Set Current address
; ****************************************************************************************************************

Address_Command:
		xppc 	p3 												; get parameter if exists
		xppc 	p3 												; update current if exists.
		jmp 	__CmdMainLoop2

; ****************************************************************************************************************
;										G : Go (Address must be specified.)
; ****************************************************************************************************************

Go_Command:
		xppc 	p3 												; get parameter, which should exist.
		csa 													; look at CY/L which is set if it was.
		jz 		__CommandError 									; if it is clear, beep an error.
		xpal 	p1 												; copy P1 to P3
		xpal 	p3
		xpah 	p1
		xpah 	p3
		ld 		@-1(p3) 										; fix up for pre increment
		xppc 	p3 												; call the routine.		
__CmdMainLoop3:
		jmp 	__CmdMainLoop2 									; re-enter monitor.

; ****************************************************************************************************************
;			Write to tape : data mandatory, it is the byte count from the current address.
; ****************************************************************************************************************

PutTape_Command:
		xppc 	p3 												; get the bytes to write.
		csa 													; if CC, no value was provided
		jp 		__CommandError 									; which is an error.
		xpal 	p1 												; store low byte count in -1(P2)
		st 		-1(p2)
		xpah 	p1 												; store high byte count in -2(P2)
		st 		-2(p2)
		ccl 													; skip over the update current address
		xppc 	p3 												; this won't update current address as CY/L = 0
		xppc 	p3 												; and load the current address into P1.
		ldi 	0 												; set the output tape bit low
		xae
		sio
		ldi 	16 												; tape leader
		st 		-3(p2)
_PutTapeLeader:
		dly 	0xFF
		dld 	-3(p2)
		jnz 	_PutTapeLeader
_PutTapeByte:													; output byte at P1
		ldi 	0 												; set output bit to 0
		xae 	
		sio
		dly 	tapeDelay * 4 									; 0 continuation bit + gap between tapes with no signal 
		ldi 	0x80 											; set bit high
		xae
		sio 
		ldi 	0
		dly 	tapeDelay 										; output the start bit.
		ld 		@1(p1) 											; read the byte and put it in E.
		xae
		ldi 	8 												; output 8 bits
		st 		-3(p2)
_PutTapeBit:
		sio 													; output MSB and shift
		ldi 	0
		dly 	tapeDelay 								
		dld 	-3(p2) 											; do all 8 bits.
		dld 	-1(p2) 											; decrement counter
		jnz 	_PutTapeByte
		dld 	-2(p2) 											; note MSB goes 0 to -1 when finished.
		jp 		_PutTapeByte
		ldi 	0x80 											; add the termination bit.
		xae
		sio
		ldi 	0 												; put that out.
		dly 	TapeDelay
		ldi 	0 												; and set the leve back to 0
		xae 
		sio
__CmdMainLoop4:
		jmp 	__CmdMainLoop3

; ****************************************************************************************************************
;						GET [addr] load tape to current position or given address.
; ****************************************************************************************************************

LoadTape_Command:
		xppc	p3 												; get parameter
		xppc 	p3												; update current address
		xppc 	p3 												; current address to P1.
		ldi 	0x8 											; point P3 to the keyboard.
		xpah 	p3
__GetTapeWait:
		ld 		0(p3) 											; check keyboard break
		ani 	0x80
		jnz 	__CommandError
		sio 													; wait for the start bit, examine tape in.
		lde 
		ani 	1
		jz 		__GetTapeWait
		dly 	tapeDelay * 3 / 2 								; half way into the first bit.
		ldi 	8 												; read in 8 bits.
		st 		-1(p2)
__GetTapeBits:
		sio 													; read in one bit
		ldi 	0
		dly 	tapeDelay 										; delay to next bit
		dld 	-1(p2) 											; read 8 bits.
		jnz 	__GetTapeBits 
		lde 													; store byte at current address
		st 		@1(p1)
		sio 													; read in the byte, which is zero if continuing.
		lde  													; examine bit 0
		ani 	1
		jz 		__GetTapeWait 									; go and wait for the next start bit.
		jmp 	__CmdMainLoop4

; ****************************************************************************************************************
;											D :	Dump Memory
; ****************************************************************************************************************

Dump_Command:
		xppc 	p3 												; get parameter if exists
		xppc 	p3 												; update current if exists.
		ldi 	7 												; print seven rows
		st 		@-1(p2)
__DCLoop:
		ldi 	(PrintAddressData-1)/256						; print one row of address and data.
		xpah 	p3
		ldi 	(PrintAddressData-1)&255
		xpal 	p3
		ldi 	4
		xppc 	p3
		ldi 	Current/256 									; point P1 to current
		xpah 	p1
		ldi 	Current&255 
		xpal 	p1
		ld 		0(p1) 											; add 4 to current address
		ccl
		adi 	4
		st 		0(p1)
		ld 		1(p1)
		adi 	0
		st 		1(p1)
		dld 	(p2) 											; do it 7 times
		jnz 	__DCLoop
		ld 		@1(p2) 											; fix up stack.

		jmp 	__CmdMainLoop4

; ****************************************************************************************************************
;											 B: Enter Bytes (no address)
; ****************************************************************************************************************

EnterBytes_Command:
		ldi 	(GetParameter-1) & 255 							; P3 = Get Parameter routine
		xpal 	p3
		ldi 	(GetParameter-1) / 256 	
		xpah 	p3
		xppc 	p3 												; get the parameter.
		csa 													; look at carry
		jp 		__CmdMainLoop4 									; carry clear, no value.
		ldi 	Current/256 									; make P1 point to current
		xpah 	p1
		ldi 	Current&255 										
		xpal 	p1 												; this pulls the byte value into A
		xae 													; save it in E
		ld 		0(p1) 											; copy address to save to into P3
		xpal 	p3
		ld 		1(p1) 
		xpah 	p3 
		lde 													; get byte back
		st 		(p3) 											; save it in that location
		ild 	0(p1) 											; bump current address and go back and try again.
		jnz 	EnterBytes_Command
		ild 	1(p1)
		jmp 	EnterBytes_Command


; ****************************************************************************************************************
; ****************************************************************************************************************
;
;						Print A as a hexadecimal 2 digit value. If CY/L set precede with space
;
; ****************************************************************************************************************
; ****************************************************************************************************************

PrintHexByte:
		st 		@-1(p2) 										; push A and P3, set P3 up to print character
		ldi 	(PrintCharacter-1)/256
		xpah 	p3
		st 		@-1(p2)
		ldi 	(PrintCharacter-1)&255
		xpal 	p3
		st 		@-1(p2)
		csa 													; check carry
		jp 		__PHBNoSpace									; if clear, no space.
		ldi 	' '												; print leading space
		xppc 	p3 
__PHBNoSpace:
		ld 		2(p2) 											; read digit
		sr 														; convert MSB
		sr
		sr
		sr
		ccl
		dai 	0x90
		dai 	0x40
		xppc 	p3 												; print
		ld 		2(p2) 											; read digit
		ani 	0x0F 											; convert LSB
		ccl
		dai 	0x90
		dai 	0x40
		xppc 	p3 												; print

		ld 		@1(p2) 											; restore P3 & A and Return
		xpal 	p3
		ld 		@1(p2)
		xpah 	p3
		ld 		@1(p2)
		xppc 	p3
		jmp 	PrintHexByte

; ****************************************************************************************************************
; ****************************************************************************************************************
;
;		Print Character in A, preserves all registers, re-entrant. Handles 13 (New Line), 8 (Backspace)
;		Characters 32 - 95 only.
;	
;		Rolls to screen top rather than scrolling.
;
; ****************************************************************************************************************
; ****************************************************************************************************************

PrintCharacter:
		st 		@-1(p2) 										; save A
		ldi 	Cursor/256 										; save P1, setting up P1 -> Cursor at same time.
		xpah 	p1
		st 		@-1(p2)
		ldi 	Cursor&255
		xpal 	p1
		st 		@-1(p2)
		ldi 	0 												; save P3, setting up P3 -> Page 0 (Video RAM Write)
		xpah 	p3
		st 		@-1(p2)
		xpal 	p3
		st 		@-1(p2)

		ld 		(p1) 											; read cursor position
		xpal 	p3 												; put in P3.Low

		ldi 	' ' 											; erase the cursor.
		st 		0(p3)

		ld 		4(p2) 											; read character to print.
		xri 	13 												; is it CR ?
		jz 		__PCNewLine 									; if so, go to new line.
		xri 	13!8 											; is it Backspace ?
		jz 		__PCBackSpace

		ld 		4(p2) 											; get character to print
		ani 	0x3F 											; make 6 bit ASCII
		st 		@1(p3) 											; write into P3, e.g. the screen and bump it.
		ild 	(p1) 											; increment cursor position and load
		ani 	15 												; are we at line start ?
		jnz 	__PCExit 										; if so, erase the current line.

__PCBlankNewLine:
		ldi 	16 												; count to 16, the number of spaces to write out.
		st 		-1(p2) 
__PCBlankNewLineLoop:
		ldi 	' '
		st 		@1(p3)
		dld 	-1(p2)
		jnz 	__PCBlankNewLineLoop

__PCExit:
		ld 		(p1) 											; read cursor
		xpal 	p3 												; put in P3.L
		ldi 	0x9B 											; shaded block cursor on screen
		st 		(p3)
		ld 		@1(p2)											; restore P3
		xpal 	p3
		ld 		@1(p2)
		xpah 	p3
		ld 		@1(p2)											; restore P1
		xpal 	p1
		ld 		@1(p2)
		xpah 	p1
		ld 		@1(p2) 											; restore A and Return.	
		xppc 	p3
		jmp 	PrintCharacter 									; and it is re-entrant.

__PCBackSpace:
		xpal 	p3 												; get current cursor position
		jz 		__PCExit 										; if top of screen then exit.
		dld 	(p1) 											; backspace and load cursor
		xpal 	p3 												; put in P3
		ldi 	' '												; erase character there
		st 		(p3)
		jmp 	__PCExit 										; and exit.

__PCNewLine:
		ld 		(p1) 											; read cursor position
		ani 	0x70 											; line
		ccl 													; next line
		adi 	0x10
		st 		(p1) 											; write back
		xpal 	p3 												; put in P3.L
		jmp 	__PCBlankNewLine

; ****************************************************************************************************************
; ****************************************************************************************************************
;
;					Print current address followed by A data bytes. Doesn't update current address
;
; ****************************************************************************************************************
; ****************************************************************************************************************

PrintAddressData:
		st 		@-1(p2) 										; save count, we don't restore this.
		ldi 	(PrintHexByte-1)/256 							; save and set up P3
		xpah 	p3
		st 		@-1(p2)
		ldi 	(PrintHexByte-1)&255
		xpal 	p3
		st 		@-1(p2)
		ldi 	current / 256 									; point P1 to current address
		xpah 	p1
		ldi 	current & 255
		xpal 	p1
		ld 		1(p1) 											; read high byte of address
		ccl
		xppc 	p3												; print w/o leading space
		ld 		0(p1)											; read low byte of address
		ccl 	
		xppc 	p3 												; print w/o leading space.
		xae 													; put in E
		ld 		1(p1) 											; high byte to P1.H
		xpah 	p1
		lde 													; low byte to P1.H
		xpal 	p1
_PADLoop:
		dld 	2(p2) 											; decrement counter
		jp 		_PADPrint 										; if +ve print another byte

		ld 		@1(p2) 											; restore P3, skipping A hence @2
		xpal 	p3
		ld 		@2(p2)
		xpah 	p3
		xppc 	p3
		jmp 	PrintAddressData

_PADPrint:
		ld 		@1(p1) 											; read byte advance pointer
		scl
		xppc 	p3 												; print with space.
		jmp 	_PADLoop

; ****************************************************************************************************************
;
;		Look at the parameter string for a parameter, processing @ and Pn as you go, CS if parameter found
; 		CC otherwise. Return parameter value in P1. Falls through
;
; ****************************************************************************************************************

GetParameter:
		ldi 	parPosn/256 									; current position into P1
		xpah 	p1
		ldi 	parPosn&255 					
		xpal 	p1
		ldi 	0 												; -1(p2) is the low byte result
		st 		-1(p2) 											; -2(p2) is the high byte result
		st 		-2(p2)
		ld 		(p1) 											; read the current position,P1 points to character
		xpal 	p1 												; when we put it in P1.L

__GPASkip:														; skip over spaces to first alphanumeric.
		ld 		(p1) 											; read character
		jz 		__GPAExitFail 									; if zero, then end of the input string.
		ld 		@1(p1) 											; read it, advancing.
		xri 	32 												; is it space ?
		jz 		__GPASkip 

		; TODO: when doing assembler, at this point check for @ and P[0-3] and adjust modifier accordingly.

__GPANextCharacter:

		ld 		-1(p1) 											; get value back after post increment.
		ccl
		adi 	128-48 											; this will be +ve if A < '0'
		jp 		__GPAExitFail
		cai 	9 												; will be +ve if A < '9', CY/L was clear.	
		jp 		__GPAFoundHex
		cai 	7 												; will be +ve if A < 'A', CY/L was set
		jp 		__GPAExitFail
		adi 	0xFF-0x85-1 									; will be +ve if A > 'F', CY/L was set.
		jp 		__GPAExitFail 					
		adi 	(0x70-0xFA) & 0xFF 								; make the range as below, CY/L was clear
__GPAFoundHex: 													; enter here 0-9 = $76..$7F, A-F = $70..$75
		ccl  													; convert that to a hex nibble.
		adi 	10
		ani 	0xF
		xae 													; save in E, temporarily
		ldi 	4 												; now shift the result 4 bits to the left.
		st 		-3(p2) 											; -3(p2) is the counter
__GPAShift:
		ccl
		ld 		-1(p2) 											; shift 16 bit result 1 bit to the left.
		add 	-1(p2)
		st 		-1(p2)
		ld 		-2(p2)
		add 	-2(p2)
		st 		-2(p2)
		dld 	-3(p2) 											; do it four times
		jnz 	__GPAShift 	
		ld 		-1(p2) 											; Or E into the LSB
		ore
		st 		-1(p2)

		ld 		@1(p1) 											; look at next character, post incrementing.
		scl
		cai 	33 												; if it is after space
		jp 		__GPANextCharacter 								; go back and put it in place.
		ld 		@-1(p1) 										; undo the increment, incase we've just read zero.

		ldi 	parPosn & 255 									; put the parPosn address in P1.L, new posn into A
		xpal 	p1
		st 		(p1) 											; and write it back
		ld 		-1(p2) 											; put the result into P1
		xpal 	p1
		ld 		-2(p2)
		xpah 	p1
		scl 													; set CY/L to indicate okay
		jmp 	__GPAExit

__GPAExitFail:
		ccl 													; carry clear, e.g. nothing read in / error.
__GPAExit:
		xppc 	p3

; ****************************************************************************************************************
;
;		Store parameter value in P1 in the current address, if CS. Falls through.
;
; ****************************************************************************************************************

UpdateCurrentAddress:
		csa 													; get status reg
		jp 		_UCAExit 										; if carry flag clear then exit.

		ldi 	current & 255 									; current address to P1.L, acquired address to E
		xpal 	p1
		xae
		ldi 	current / 256 									; current address to P1.H, acquired to A
		xpah 	p1
		st 		1(p1) 											; store address back
		lde
		st 		0(p1)
_UCAExit:
		xppc 	p3

; ****************************************************************************************************************
;
;		Get current address into P1.
;
; ****************************************************************************************************************

GetCurrentAddress:
		ldi 	current/256 									; current address ptr in P1
		xpah 	p1
		ldi 	current&255
		xpal 	p1
		ld 		0(p1) 											; low byte to E
		xae
		ld 		1(p1) 											; high byte to A
		xpah 	p1 												; then to P1.H
		lde 													; low byte to P1.L
		xpal 	p1 
		xppc 	p3

; ****************************************************************************************************************
;
;											List of commands and Jump Table
;
; ****************************************************************************************************************

		include commands.inc 									; must be at the end, so the command table is in
																; the same page.

; ****************************************************************************************************************
;
;													Tape Format. 
;
; ****************************************************************************************************************
;
;		1 x start bit 		'1' value is held for period of time.
;		8 x data bits  		'0 or 1' value is held for a period of time.
;		1 x continuation	'0' if another bit follows, '1' if end.
;		at least 2 bit times between bytes.
;
;		Use DLY 4 with A = 0 (DLY 6 to skip half-start)
; 		= 13 + 2 * 0 + 514 * 4 microcycles
;		= 2,069 microcycles
;	
;		which is about 240 bits per second.
;
; ****************************************************************************************************************