@ Count characters from STDIN
@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab: 
@ vim: ft=arm 

@ External Functions
.global newline
.global check_read_error
.global fputs
.global puts
.global itoa

@ Exported Functions
.global count_from_file
.global init_counts
.global count_characters
.global print_counts
.global status

count_from_file:
    @ Count characters from the given file handle
    @ Arguments: R0 = File handle
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    MOV     R4,R0               @ R4 = File handle
  cff_loop:
    MOV     R0,#0
    MOV     R1,R4               @ Set file handle for syscall
    LDR     R2,=buffer          @ Write to buffer for syscall
    MOV     R3,#4096            @ Set buffer size for syscall
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
    @ print status
    PUSH    {R0,LR}
    LDR     R0,=status_s
    BL      puts
    POP     {R0,PC}

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
    BL      puts                @ |
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return

print_count_line:
    @ Arguments: Character in R0, Count in R1
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    MOV     R4,R0               @ R4 = Character
    MOV     R5,R1               @ R5 = Count
    LDR     R0,=line_part1      @ Print the first part of the line
    BL      fputs               @ |
    MOV     R0,R4               @ Convert character to a string
    LDR     R1,=char_string     @ | Write to the char_string memory location
    BL      itoa                @ | Get string representation
    MOV     R0,R1               @ Print the character string
    BL      fputs               @ |
    LDR     R0,=line_part2      @ Print the second part of the line
    BL      fputs               @ |
    MOV     R0,R5               @ Convert count to a string
    LDR     R1,=count_string    @ | Write to the count_string memory location
    BL      itoa                @ | Get string representation
    MOV     R0,R1               @ Print the count string
    BL      puts                @ |
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return

.data

counts: .space 1024
counts_end: .word 0
char: .word 0
buffer: .space 4096
count_string: .asciz "0000000000" @ max 4294967296
char_string: .asciz "000" @ max 256
status_s: .asciz "Counting Characters"
header: .asciz "Character Counts:"
line_part1: .asciz "\tCharacter: "
line_part2: .asciz "\tCount: "

