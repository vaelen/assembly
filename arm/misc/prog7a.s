/* Syscall 4 to write a string */
.global _start

_start:
	MOV R7,#4 @ Syscall number
	MOV R0,#1 @ STDOUT
	MOV R2,#13 @ String is 13 characters long
	LDR R1,=string @ String located at string:
	SWI 0 

_exit:
	@ exit syscall
	MOV R7,#1
	SWI 0

.data

string:
	.ascii "Hello World!\n"
