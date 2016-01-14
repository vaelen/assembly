/* Syscall 4 to write a string */
.global _start

_start:
	MOV  R8,#9 @ Initialize loop counter
	B    _loop @ Start loop

_loop:	
	BL   _update_counter_string
	BL   _hello
	SUB  R8,R8,#1 @ Decrement the loop counter
	CMP  R8,#0 @ Check for loop condition
	BEQ  _exit @ Exit when counter=0
	BNE  _loop @ Loop again if counter != 0
	
_hello:
	@ Print hello world
	MOV  R7,#4 @ Syscall number
	MOV  R0,#1 @ STDOUT
	MOV  R2,#16 @ String is 16 characters long
	LDR  R1,=string @ String located at string:
	SWI  0 @ Make system call
	MOV  PC,LR @ Return

_update_counter_string:
	@ Update counter string
	ADD  R9,R8,#48 @ ASCII version of counter
	LDR  R10,=string @ Load memory address
	STRB R9,[R10] @ Overwrite first byte
	MOV  PC,LR @ Return

_exit:
	@ exit syscall
	MOV  R7,#1
	SWI  0

.data

string:
	.ascii "0: Hello World!\n"
