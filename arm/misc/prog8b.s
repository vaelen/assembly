	/* Convert a number to binary for printing */

	.global _start

_start:
	MOV R6,#251 @ Number to print in R6
	MOV R10,#1 @ set up mask
	MOV R9,R10,LSL #31
	LDR R1,=string

_bits:
	TST R6,R9 @TST no, mask
	BEQ _print0
	MOV R8,R6 @ MOV preserve, no
	MOV R0,#49 @ ASCII '1'
	STR R0,[R1] @ store 1 in string
	BL _write @ write to screen
	MOV R6,R8 @ MOV no, preserve
	BAL _noprint1

_print0:
	MOV R8,R6 @ MOV preserve, no
	MOV R0,#48 @ ASCII '0'
	STR R0,[R1] @ store 0 in string
	BL _write
	MOV R6,R8 @ MOV no, preserve

_noprint1:
	MOVS R9,R9,LSR #1 @ shuffle mask
	BNE _bits

_exit:
	MOV R7, #1
	SWI 0

_write:
	MOV R0,#1
	MOV R2,#1
	MOV R7,#4
	SWI 0
	MOV PC,LR

	.data
string: .ascii ""
