@@@ Sorting Related Methods
@@@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab background=dark: 
@@@ vim: ft=arm 

@@@ Exteral Methods
    .global div
    .global print_memory_binary
    .global newline
    
@@@ Exported Methods
    .global bsort
    @@ Radix sort runs but doesn't work right
    .global rsort
    @@ qsort isn't working yet
    .global qsort

@@@ Code Section
    
bsort:
    @ Bubble sort an array of 32bit integers in place
    @ Arguments: R0 = Array location, R1 = Array size
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    MOV     R4,R0               @ R4 = Array Location
    MOV     R5,R1               @ R5 = Array size
bsort_check:                  @ Check for a sorted array
    MOV     R6,#0               @ R6 = Current Element Number
bsort_check_loop:             @ Start check loop
    ADDS    R7,R6,#1            @ R7 = Next Element Number
    CMP     R7,R5               @ Check for the end of the array
    BGE     bsort_done          @ Exit method if we reach the end of the array
    LDR     R8,[R4,R6,LSL #2]   @ R8 = Current Element Value
    LDR     R9,[R4,R7,LSL #2]   @ R9 = Next Element Value
    CMP     R8,R9               @ Compare element values
    BGT     bsort_swap          @ If R8 > R9, swap
    MOV     R6,R7               @ Advance to the next element
    B       bsort_check_loop    @ End check loop
bsort_swap:                   @ Swap values
    STR     R9,[R4,R6,LSL #2]   @ Store current element at next location
    STR     R8,[R4,R7,LSL #2]   @ Store next element at current location
    B       bsort_check         @ Check again for a sorted array
bsort_done:                   @ Return
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return

qsort:
    @@ Quick sort an array of 32bit integers
    @@ Arguments: R0 = Array location, R1 = Array size
    PUSH    {R0-R6,LR}          @ Push the existing registers on to the stack
    MOV     R4,R0               @ R4 = Array Location
    MOV     R5,R1               @ R5 = Array size
    CMP     R5,#1               @ Check for an array of size <= 1
    BLS     qsort_done          @ If array size <= 1, return
    MOV     R0,R5               @ Divide the array size by two
    MOV     R1,#2               @ |
    BL      div                 @ |
    MOV     R6,R2               @ R6 = Midpoint
    MOV     R0,R4               @ Location of the start of the array
    MOV     R1,R6               @ Size of the first half of the array
    BL      qsort               @ Sort first half of array
    ADDS    R0,R4,R6,LSL #2     @ Location of the middle of the array (R4 + (R6*4))
    SUBS    R1,R5,R6            @ Size of the second half of the array (R5 - R6)
    BL      qsort               @ Sort first half of array
qsort_done:
    POP     {R0-R6,PC}          @ Pop the registers off of the stack and return

rsort:
    @@ Radix MSD sort an array of 32bit integers
    @@ Arguments: R0 = Array location, R1 = Array size
    CMP     R1,#1               @ Check for an empty or single member array
    BXLE    LR                  @ If so, return to where we came from
    PUSH    {R0-R5,LR}          @ Push the existing registers on to the stack
    ADD     R1,R0,R1,LSL #2     @ R1 = End of the array (R0 + (R1*4))
    SUB     R1,R1,#4            @ 
    MOV     R2,#1               @ R2 = Bitmask
    LSL     R2,R2,#4            @   most significant bit
    BL      rsort_recurse       @ Begin recursion
    POP     {R0-R5,PC}          @ Pop the registers off of the stack and return

rsort_debug:
    @@ Print rsort debugging information
    @@ Arguments: R0 = Start of array, R1 = End of array, R2 = Bitmask
    PUSH    {R0-R3,LR}          @ Stack frame
    MOV     R3,R0               @ R3 = Start of array
    LDR     R0,=bitmask_header  @ Print bitmask header
    BL      puts                @
    MOV     R0,R2               @ Print bitmask
    BL      print_r0_binary     @
    LDR     R0,=memory_header   @ Print memory header
    BL      puts                @
    MOV     R0,R3               @ Print memory contents
    BL      print_memory_binary @
    BL      newline             @ Print an empty line
    POP     {R0-R3,PC}          @ Return
    
rsort_recurse:
    @@ Radix MSD sort an array of 32bit integers (recursive helper)
    @@ Arguments: R0 = Array start, R1 = Array end, R2 = Bitmask
    PUSH    {LR}                @ Store previous values
    BL      rsort_debug         @ Debug output
    CMP     R0,R1               @ Check array length
    BEQ     rr_done             @ Return if array is empty
    MOV     R3,R0               @ R3 = 0's bin pointer (start of array)
    MOV     R4,R1               @ R4 = 1's bin pointer (end of array)
    MOV     R5,#0               @ R5 = Current value
rr_0loop:
    LDR     R5,[R3]             @ Load current value from pointer
    TST     R5,R2               @ Check bitmask
    BEQ     rr_0loop_next       @ If the value is 0, loop
    BL      rr_swap             @ If not, swap the 0's and 1's bin values
    B       rr_1loop_next       @ Switch to the 1's bin
rr_0loop_next:
    ADD     R3,R3,#4            @ Increment the pointer
    CMP     R3,R4               @ Check if pointers are the same
    BEQ     rr_next_bit         @ If so, move to the next bit
    B       rr_0loop            @ If not, check the next value
rr_1loop:
    LDR     R5,[R4]             @ Load current value from pointer
    TST     R5,R2               @ Check bitmask
    BNE     rr_1loop_next       @ If the value is 1, loop
    BL      rr_swap             @ Swap the 0's and 1's bin values
    B       rr_0loop_next       @ Switch to the 0's bin
rr_1loop_next:
    SUB     R4,R4,#4            @ Decrement the pointer
    CMP     R3,R4               @ Check if pointers are the same
    BEQ     rr_next_bit         @ If so, move to the next bit
    B       rr_1loop            @ If not, check the next value
rr_next_bit:
    LSR     R2,R2,#1            @ Update bitmask to next bit
    CMP     R2,#0               @ Check to see if we've shifted all bits to 0
    BEQ     rr_done             @ If so, don't recurse anymore
    PUSH    {R0-R3}             @ Push values onto stack
    MOV     R1,R3               @ 0's bin array end
    BL      rsort_recurse       @ Sort 0's bin (R0-R8 are lost)
    POP     {R0-R3}             @ Pop values back off the stack
    MOV     R0,R3               @ 1's bin array start
    BL      rsort_recurse       @ Sort 1's bin (R0-R8 are lost)
    B       rr_done             @ All done
rr_swap:
    PUSH    {R5,LR}             @ Store previous values
    LDR     R5,[R3]             @ Grab the value from the 0's bin
    PUSH    {R5}                @ Store that value on the stack
    LDR     R5,[R4]             @ Grab the value from the 1's bin
    STR     R5,[R3]             @ Place the 1's bin value into the 0's bin
    POP     {R5}                @ Pull the current value off the stack
    STR     R5,[R4]             @ Place the 0's bin value into the 1's bin
    POP     {R5,PC}             @ Return
rr_done: 
    POP     {PC}                @ Restore previous values   

@@@  Data Section
    .data
memory_header:  .asciz "Bin:"
bitmask_header: .asciz "Bitmask:"
    
