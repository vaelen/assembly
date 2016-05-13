@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab background=dark: 
@ vim: ft=arm 

@ Exteral Methods
.global puts
.global fputs
.global itoa
.global int_string

@ Exported Methods
.global print_heap

print_heap:
    @ Prints a heap
    @ Arguments:
    @   R0 = Memory address of heap
    PUSH    {R0-R7,LR}          @ Push the existing registers on to the stack
    MOV     R6, R0              @ R6 = Memory address of heap
    LDR     R7, [R6]            @ R7 = Heap size
    BL      print_heap_header   @ Print header
    CMP     R7, #0              @ Is the heap empty?
    BEQ     print_heap_done     @ If so, we're done
    ADDS    R4, R6, #8          @ R4 = Start of the heap
    LSL     R5, R7, #3          @ Find the end of the heap by multiplying R7 * 8
    ADDS    R5, R5, R4          @   Then adding the start address
  print_heap_loop:
    LDR     R0, [R4], #4        @ Load key and increment memory location
    LDR     R1, [R4], #4        @ Load value and increment memory location
    BL      print_heap_line     @ Print the heap line if we had a match
    CMP     R4, R5              @ Have we reached the end?
    BLT     print_heap_loop     @ If not, loop again
  print_heap_done:
    POP     {R0-R7,PC}          @ Pop the registers off of the stack and return

print_heap_header:
    PUSH    {R0,LR}             @ Push the existing registers on to the stack
    LDR     R0,=header          @ Print header
    BL      puts                @ |
    POP     {R0,PC}             @ Pop the registers off of the stack and return

print_heap_line:
    @ Arguments:  
    @   R0 = Key
    @   R1 = Value
    PUSH    {R0-R5,LR}          @ Push the existing registers on to the stack
    MOV     R4,R0               @ R4 = Key
    MOV     R5,R1               @ R5 = Value
    LDR     R0,=line_part1      @ Print the first part of the line
    BL      fputs               @ |
    MOV     R0,R4               @ Convert key to a string
    LDR     R1,=int_string      @ | Write to the int_string  memory location
    BL      itoa                @ | Get string representation
    MOV     R0,R1               @ Print the key string
    BL      fputs               @ |
    LDR     R0,=line_part2      @ Print the second part of the line
    BL      fputs               @ |
    MOV     R0,R5               @ Convert value to a string
    LDR     R1,=int_string      @ | Write to the int_string  memory location
    BL      itoa                @ | Get string representation
    MOV     R0,R1               @ Print the value string
    BL      puts                @ |
    POP     {R0-R5,PC}          @ Pop the registers off of the stack and return

.data

header: .asciz "Heap:"
line_part1: .asciz "\tKey: "
line_part2: .asciz "\tValue: "

