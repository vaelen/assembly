@ Helper functions related to string manipulation
@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab: 
@ vim: ft=arm 

.global newline
.global print_registers
.global print_r0
.global integer_to_string
.global divide
.global strlen
.global print_string

newline:
    @ Print a newline character
    PUSH    {R0,LR}
    LDR     R0,=newline_s
    BL      print_string 
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
    BL      integer_to_string   @ | Get string representation
    MOV     R0,R1               @ Print the character string
    BL      print_string        @ |
    BL      newline             @ Print a newline character
    POP     {R0-R12,PC}         @ Return when loop completes, restore registers

integer_to_string:
    @ Converts an integer to a string
    @ Arguments: integer in R0, memory address in R1
    @ This works by using recursion
    @ It builds the value backwards on the stack then pops it off in the right order
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    MOV     R4,R1               @ Store the memory address in R4
    BL      i_to_s_helper       @ Recurse
    MOV     R6,#0               @ R6 = null terminator
    STREQB  R6,[R4]             @ Add a null terminator
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return

i_to_s_helper:
    @ Arguments: integer in R0, memory address in R4
    @ R
    PUSH    {R5,LR}             @ Push the registers on to the stack
    MOV     R1,#10              @ We will divide R0 by 10
    BL      divide              @ Divide R0 by R1 and return remainder in R0
    MOV     R5,R0               @ Put the remainder in R5
    MOV     R0,R2               @ Move the quotient into R0 for the next iteration
    CMP     R0,#0               @ Is this the end of the string?
    BLNE    i_to_s_helper       @ If not, recurse 
    ADD     R6,R5,#48           @ Add 48 to the remainder to get an ASCII character
    STRB    R6,[R4],#1          @ Store the byte into memory and increment the memory location
    POP     {R5,PC}             @ Pop the registers off of the stack and return

divide:
    @ Divides R0 by R1
    @ Returns the quotient in R2, and the remainder in R0
    PUSH    {R4-R12,LR}         @ Push the existing registers on to the stack
    MOV     R4,R1               @ Put the divisor in R4
    CMP     R4,R0,LSR #1        @ Compare the divisor (R0) with 2xR4
  divide_loop1:
    MOVLS   R4,R4,LSL #1        @ Double R4 if 2xR4 < divisor (R0)
    CMP     R4,R0,LSR #1        @ Compare the divisor (R0) with 2xR4
    BLS     divide_loop1        @ Looop if 2xR4 < divisor (R0)
    MOV     R2,#0               @ Initialize the quotient
  divide_loop2:
    CMP     R0,R4               @ Can we subtract R4?
    SUBCS   R0,R0,R4            @ If we can, then do so
    ADC     R2,R2,R2            @ Double the quotient, add new bit
    MOV     R4,R4,LSR #1        @ Divide R4 by 2
    CMP     R4,R1               @ Check if we've gone past the original divisor
    BHS     divide_loop2        @ If not, loop again
    POP     {R4-R12,PC}         @ Pop the registers off of the stack and return


print_string:
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
