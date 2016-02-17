@ Count characters from STDIN
@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab: 
@ vim: ft=arm 

.global _start

_start:
    BL      status              @ Print status
    BL      init_counts         @ Initialize memory
    MOV     R0, #0              @ Set file handle to STDIN
    BL      count_from_file     @ Count characters from file handle
    BL      print_counts        @ Print counts
    B       exit                @ exit

count_from_file:
    @ Count characters from the given file handle
    @ Arguments: R0 = File handle
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    MOV     R4,R0               @ R4 = File handle
  cff_loop:
    MOV     R0,R4               @ Set file handle for syscall
    LDR     R1,=buffer          @ Write to buffer for syscall
    MOV     R2,#4096            @ Set buffer size for syscall
    MOV     R7,#3               @ Syscall number: 3 is read()
    SWI     0                   @ Read from file handle
    BLEQ    check_read_error    @ Warn about a bad address
    CMP     R0,#0               @ Check for EOF
    BGT     cff_helper          @ Count characters and loop if not EOF
    POP     {R0-R12,PC}         @ Return when loop completes, restore registers
  cff_helper:
    @ Arguments: R0 = Character count
    MOV     R1,R0               @ Move character count to R1
    LDR     R0,=buffer          @ Read from the buffer
    BL      count_characters    @ Count characters
    B       cff_loop            @ Loop 

status:
    @ Print status
    PUSH    {R0,LR}
    LDR     R0,=status_s
    BL      print_string
    BL      newline
    POP     {R0,PC}


newline:
    @ Print a newline character
    PUSH    {R0,LR}
    LDR     R0,=newline_s
    BL      print_string 
    POP     {R0,PC}

check_read_error:
    PUSH    {R0,R1,LR}
    MOV     R1,R0
    MOV     R0,#0
    CMP     R1,#-4              @ Check for interrupted system call
    LDREQ   R0,=eintr
    CMP     R1,#-5              @ Check for IO error
    LDREQ   R0,=eio   
    CMP     R1,#-9              @ Check for bad file descriptor
    LDREQ   R0,=ebadf
    CMP     R1,#-11             @ Check for try again
    LDREQ   R0,=efault
    CMP     R1,#-14             @ Check for bad address
    LDREQ   R0,=eagain
    CMP     R1,#-21             @ Check for a directory
    LDREQ   R0,=eisdir
    CMP     R1,#-22             @ Check for invalid
    LDREQ   R0,=einval
    CMP     R0,#0               @ If we have a message to print, then print it
    BLNE    print_string 
    CMP     R0,#0
    BLNE    newline
    POP     {R0,R1,PC}

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
    LDR     R1,=count_string    @ | Write to the char_string memory location
    BL      integer_to_string   @ | Get string representation
    MOV     R0,R1               @ Print the character string
    BL      print_string        @ |
    BL      newline             @ Print a newline character
    POP     {R0-R12,PC}         @ Return when loop completes, restore registers

count_characters:
    @ Counts characters 
    @ Arguments: 
    @   R0 = Address of buffer
    @   R1 = Length of buffer
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    LDR     R5,=counts          @ R5 = Address of the count array
    SUBS    R2,R0,#1            @ R2 = One byte before the first memory location
  count_loop:
    ADDS    R2,R2,#1            @ R2 = Current memory location
    LDRB    R3,[R2]             @ R3 = Current byte
    LDR     R4,[R5,R3,LSL #2]   @ R4 = Current count (R5 + (R3*4))
    ADDS    R4,#1               @ Increment the count
    STR     R4,[R5,R3,LSL #2]   @ Store the count back into the array
    SUBS    R1,#1               @ Reduce loop counter by 1
    BNE     count_loop          @ Loop if counter != 0
    POP     {R0-R12,PC}         @ Return when loop completes, restore registers

init_counts:
    @ Initialize the memory used for counting
    PUSH    {R0-R12,LR}         @ Push registers on to stack
    MOV     R0,#0               @ value to store
    MOV     R1,#0               @ value to store
    MOV     R2,#0               @ value to store
    MOV     R3,#0               @ value to store
    MOV     R4,#0               @ value to store
    MOV     R5,#0               @ value to store
    MOV     R6,#0               @ value to store
    MOV     R7,#0               @ value to store
    LDR     R11,=counts         @ Starting memory location
    LDR     R12,=counts_end     @ Ending memory location
  init_counts_loop:
    STMIA   R11!,{R0-R7}        @ Store 0 in the next 8 words of memory
    CMP     R11,R12
    BNE     init_counts_loop    @ Loop again if current != end
    POP     {R0-R12,PC}         @ Return when loop completes, restore registers

print_counts:
    @ Prints a list of counts
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    BL      print_count_header  @ Print header
    MOV     R0,#0               @ Character value
    LDR     R4,=counts          @ Starting memory location
    LDR     R5,=counts_end      @ Ending memory location
  print_counts_loop:
    LDR     R1,[R4],#4          @ Load count and increment memory location
    CMP     R1,#0               @ Did we have any matches?
    BLNE    print_count_line    @ Print the count line if we had a match
    ADDS    R0,R0,#1            @ Increment character number
    CMP     R4,R5               @ Have we reached the end?
    BNE     print_counts_loop   @ If not, loop again
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return

print_count_header:
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    LDR     R0,=header          @ Print header
    BL      print_string        @ |
    BL      newline             @ Print a newline character
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return

print_count_line:
    @ Arguments: Character in R0, Count in R1
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    MOV     R4,R0               @ R4 = Character
    MOV     R5,R1               @ R5 = Count
    LDR     R0,=line_part1      @ Print the first part of the line
    BL      print_string        @ |
    MOV     R0,R4               @ Convert character to a string
    LDR     R1,=char_string     @ | Write to the char_string memory location
    BL      integer_to_string   @ | Get string representation
    MOV     R0,R1               @ Print the character string
    BL      print_string        @ |
    LDR     R0,=line_part2      @ Print the second part of the line
    BL      print_string        @ |
    MOV     R0,R5               @ Convert count to a string
    LDR     R1,=count_string    @ | Write to the count_string memory location
    BL      integer_to_string   @ | Get string representation
    MOV     R0,R1               @ Print the count string
    BL      print_string        @ |
    BL      newline             @ Print a newline character
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return

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
    

exit:
    MOV     R0,#0               @ Return code, 0 = success
    MOV     R7,#1               @ Syscall numbe, 1 = exit
    SWI     0                   @ Perform system call

.data

counts: .space 1024
counts_end: .word 0
done: .byte 0
char: .word 0
buffer: .space 4096
count_string: .asciz "0000000000" @ max 4294967296
char_string: .asciz "000" @ max 256
newline_s: .asciz "\n"
status_s: .asciz "Counting Characters"
header: .asciz "Character Counts:"
line_part1: .asciz "\tCharacter: "
line_part2: .asciz "\tCount: "

@ Error Codes
eintr:  .asciz "[ERROR] Interrupted System Call: The call was interrupted by a signal before any data was read."
eio:    .asciz "[ERROR] I/O Error"
ebadf:  .asciz "[ERROR] Bad File Number: Not a valid file descriptor"
eagain: .asciz "[ERROR] Try Again: Read would block but file is marked non-blocking"
efault: .asciz "[ERROR] Bad Address: Buffer is outside your addressible address space"
eisdir: .asciz "[ERROR] Trying to Read From a Directory Instead of a File"
einval: .asciz "[ERROR] Invalid Argument: Could not read file"

