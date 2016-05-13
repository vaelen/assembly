@ Helper functions related to string manipulation
@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab: 
@ vim: ft=arm 

@ External Methods
.global itoa

@ Exported Methods
.global newline
.global print_registers
.global print_r0
.global strlen
.global fputs
.global puts
.global int_string

newline:
    @ Print a newline character
    PUSH    {R0,LR}
    LDR     R0,=newline_s
    BL      fputs 
    POP     {R0,PC}

print_registers:
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    BL      print_r0
    MOV     R0,R1
    BL      print_r0
    MOV     R0,R2
    BL      print_r0
    MOV     R0,R3
    BL      print_r0
    MOV     R0,R4
    BL      print_r0
    MOV     R0,R5
    BL      print_r0
    MOV     R0,R6
    BL      print_r0
    MOV     R0,R7
    BL      print_r0
    MOV     R0,R8
    BL      print_r0
    MOV     R0,R9
    BL      print_r0
    MOV     R0,R10
    BL      print_r0
    MOV     R0,R11
    BL      print_r0
    MOV     R0,R12
    BL      print_r0
    POP     {R0-R12,PC}         @ Return when loop completes, restore registers

print_r0:
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    LDR     R1,=int_string      @ | Write to the int_string memory location
    BL      itoa                @ | Get string representation
    MOV     R0,R1               @ Print the character string
    BL      puts                @ |
    POP     {R0-R12,PC}         @ Return when loop completes, restore registers

puts:
    @ Print the null terminated string at R0, followed by a newline
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    BL      fputs               @ Print the null terminated string at R0
    BL      newline             @ Print a newline character
    POP     {R0-R12,PC}         @ Return when loop completes, restore registers

fputs:
    @ Print the null terminated string at R0
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    BL      strlen              @ Get the length of the string
    MOV     R2,R1               @ String length is in R1
    MOV     R1,R0               @ String starts at R0
    MOV     R0,#1               @ Write to STDOUT
    MOV     R7,#4               @ Syscall number
    SWI     0                   @ Perform system call
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return

strlen:
    @ Finds the length of the string at address R0
    @ Returns the length in R1
    PUSH    {R2,LR}             @ Push the existing registers on to the stack
    SUBS    R1,R0,#1            @ R1 = One byte before the first memory location
  strlen_loop:
    ADDS    R1,R1,#1            @ R1 = Current memory location
    LDRB    R2,[R1]             @ R2 = Current byte
    CMP     R2,#0               @ Check for null
    BNE     strlen_loop         @ Loop if not null
    SUBS    R1,R1,R0            @ R1 = Length of string
    POP     {R2,PC}             @ Pop the registers off of the stack and return

.data

int_string: .asciz "0000000000" @ max 4294967296
newline_s: .asciz "\n"
