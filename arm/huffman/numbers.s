@@@ Helper functions related to number manipulation
@@@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab: 
@@@ vim: ft=arm 

@@ Exported Methods
    .global itoa
    .global div
    .global word_to_binary

@@@ Code Section
    
itoa:
    @@ Converts an integer to a string
    @@ Arguments: integer in R0, memory address in R1
    @@ This works by using recursion
    @@ It builds the value backwards on the stack then pops it off in the right order
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    MOV     R4,R1               @ Store the memory address in R4
    BL      itoa_helper         @ Recurse
    MOV     R6,#0               @ R6 = null terminator
    STREQB  R6,[R4]             @ Add a null terminator
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return

itoa_helper:
    @@ Arguments: integer in R0, memory address in R4
    PUSH    {R5,LR}             @ Push the registers on to the stack
    MOV     R1,#10              @ We will divide R0 by 10
    BL      div                 @ Divide R0 by R1 and return remainder in R0
    MOV     R5,R0               @ Put the remainder in R5
    MOV     R0,R2               @ Move the quotient into R0 for the next iteration
    CMP     R0,#0               @ Is this the end of the string?
    BLNE    itoa_helper         @ If not, recurse 
    ADD     R6,R5,#48           @ Add 48 to the remainder to get an ASCII character
    STRB    R6,[R4],#1          @ Store the byte into memory and increment the memory location
    POP     {R5,PC}             @ Pop the registers off of the stack and return

word_to_binary:
    @@ Converts a word to a binary string
    @@ Arguments: word in R0, string memory address in R1 (must be 32 bytes long)
    PUSH    {R0-R12,LR}         @ Push existing registers on to the stack
    MOV     R2,#1               @ R2 = bitmask
    LSL     R2,#31              @   Most significant digit
wtb_loop:
    CMP     R2,#0               @ Check to see if we're finished
    BEQ     wtb_done            @ If so, return
    TST     R0,R2               @ Check if bit is set
    MOVNE   R3,#49              @ If 1, place an ASCII 1 in R3
    MOVEQ   R3,#48              @ If 0, place an ASCII 0 in R3
    STRB    R3,[R1]             @ Store the value of R3 into the string
    ADD     R1,#1               @ Move to the next byte of the output string
    LSR     R2,#1               @ Shift bitmask to next bit of input
    B       wtb_loop            @ Loop
wtb_done:   
    POP     {R0-R12,PC}         @ Return    
    
div:
    @@ Divides R0 by R1
    @@ Returns the quotient in R2, and the remainder in R0
    PUSH    {R4-R12,LR}         @ Push the existing registers on to the stack
    MOV     R4,R1               @ Put the divisor in R4
    CMP     R4,R0,LSR #1        @ Compare the divisor (R0) with 2xR4
div_loop1:
    MOVLS   R4,R4,LSL #1        @ Double R4 if 2xR4 < divisor (R0)
    CMP     R4,R0,LSR #1        @ Compare the divisor (R0) with 2xR4
    BLS     div_loop1           @ Loop if 2xR4 < divisor (R0)
    MOV     R2,#0               @ Initialize the quotient
div_loop2:
    CMP     R0,R4               @ Can we subtract R4?
    SUBCS   R0,R0,R4            @ If we can, then do so
    ADC     R2,R2,R2            @ Double the quotient, add new bit
    MOV     R4,R4,LSR #1        @ Divide R4 by 2
    CMP     R4,R1               @ Check if we've gone past the original divisor
    BHS     div_loop2           @ If not, loop again
    POP     {R4-R12,PC}         @ Pop the registers off of the stack and return
