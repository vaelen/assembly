@@@ Sorting Related Methods
@@@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab background=dark: 
@@@ vim: ft=arm 

@@@ Exteral Methods
    .global div
    .global print_memory_binary
    .global newline
    .global itoa
    .global fputs
    .global puts
    
@@@ Exported Methods
    @@ Buble sort broke when I increased the array size
    .global bsort
    @@ Radix sort works properly
    .global rsort
    @@ qsort isn't working yet
    .global qsort
    .global swap

@@@ Code Section
    
bsort:
    @ Bubble sort an array of 32bit integers in place
    @ Arguments: R0 = Array location, R1 = Array size
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    MOV     R4,R0               @ R4 = Array Location
    MOV     R5,R1               @ R5 = Array size
bsort_check:                   @ Check for a sorted array
    MOV     R6,#0               @ R6 = Current Element Number
bsort_check_loop:              @ Start check loop
    ADDS    R7,R6,#1            @ R7 = Next Element Number
    CMP     R7,R5               @ Check for the end of the array
    BGE     bsort_done          @ Exit method if we reach the end of the array
    LDR     R8,[R4,R6,LSL #2]   @ R8 = Current Element Value
    LDR     R9,[R4,R7,LSL #2]   @ R9 = Next Element Value
    CMP     R8,R9               @ Compare element values
    BGT     bsort_swap          @ If R8 > R9, swap
    MOV     R6,R7               @ Advance to the next element
    B       bsort_check_loop    @ End check loop
bsort_swap:                    @ Swap values
    STR     R9,[R4,R6,LSL #2]   @ Store current element at next location
    STR     R8,[R4,R7,LSL #2]   @ Store next element at current location
    B       bsort_check         @ Check again for a sorted array
bsort_done:                    @ Return
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return

qsort:
    @@ Quick sort an array of 32bit integers
    @@ Arguments: R0 = Array location, R1 = Array size
    PUSH    {R0-R6,LR}          @ Push the existing registers on to the stack
    MOV     R4,R0               @ R4 = Array Location
    MOV     R5,R1               @ R5 = Array size
    CMP     R5,#1               @ Check for an array of size <= 1
    BLE     qsort_done          @ If array size <= 1, return
    CMP     R5,#2               @ Check for an array of size == 2
    BEQ     qsort_check         @ If array size == 2, check values
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
qsort_check:
    LDR     R0,[R4]             @ Load first value into R0
    LDR     R1,[R4,#4]          @ Load second value into R1
    CMP     R0,R1               @ Compare R0 and R1
    STRGT   R1,[R4]             @ If R0 > R1, swap values
    STRGT   R0,[R4,#4]          @ 
qsort_done:
    POP     {R0-R6,PC}          @ Pop the registers off of the stack and return

rsort:
    @@ Radix MSD sort an array of 32bit integers
    @@ Arguments: R0 = Array location, R1 = Array size
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    CMP     R1,#1               @ Check for an empty or single member array
    POPLE   {R0-R7,PC}          @ If so, return to where we came from
    ADD     R1,R0,R1,LSL #2     @ R1 = End of the array (R0 + (R1*4))
    SUB     R1,R1,#4            @ 
    MOV     R2,#1               @ R2 = Bitmask
    LSL     R2,R2,#31           @   most significant bit
    MOV     R8,#0               @ R8 = recursion depth (debug)
    MOV     R12,#0              @ R12 = Loop counter (debug)
    BL      rsort_recurse       @ Begin recursion
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return

rsort_debug:
    @@ Print rsort debugging information
    @@ Arguments: R6 = Start of array, R7 = End of array, R2 = Bitmask
    @@            R8 = Recursion Depth
    PUSH    {R0-R1,LR}          @ Stack frame
    MOV     R0,R8               @ Convert depth to string
    LDR     R1,=depth_value     @
    BL      itoa                @
    LDR     R0,=depth_header    @ Print depth header
    BL      fputs               @
    LDR     R0,=depth_value     @ Print depth
    BL      puts                @
    MOV     R0,R12              @ Convert loop counter to string
    LDR     R1,=loop_value      @
    BL      itoa                @
    LDR     R0,=loop_header     @ Print loop header
    BL      fputs               @
    LDR     R0,=loop_value      @ Print loop counter
    BL      puts                @
    LDR     R0,=bitmask_header  @ Print bitmask header
    BL      fputs               @
    MOV     R0,R2               @ Print bitmask
    BL      print_r0_binary     @
    LDR     R0,=memory_header   @ Print memory header
    BL      puts                @
    MOV     R0,R6               @ Print memory contents
    MOV     R1,R7               @
    BL      print_memory_binary @
    BL      newline             @ Print an empty line
    POP     {R0-R1,PC}          @ Return
    
rsort_recurse:
    @@ Radix MSD sort an array of 32bit integers (recursive helper)
    @@ Arguments: R0 = Array start, R1 = Array end, R2 = Bitmask, R8 = Recursion Depth (debug)
    PUSH    {R0-R9,LR}          @ Store previous values
    SUB     R9,R1,R0            @ Check array length
    CMP     R9,#4               @ 
    BLT     rr_done             @ Return if array is empty or only has 1 entry
    MOV     R3,R0               @ R3 = 0's bin pointer (start of array)
    MOV     R4,R1               @ R4 = 1's bin pointer (end of array)
    MOV     R5,#0               @ R5 = Current value
    MOV     R6,R0               @ Set original array start (debug)
    MOV     R7,R1               @ Set original array end (debug)
    ADD     R8,#1               @ Increase recursion depth (debug)
rr_0loop:
    ADD     R12,#1              @ Increment loop counter (debug)
    LDR     R5,[R3]             @ Load next value from pointer
    TST     R5,R2               @ Check bitmask
    BEQ     rr_0loop_next       @ If the value is 0, loop
    BL      rr_swap             @ If not, swap values
    B       rr_1loop_next       @ Switch to the 1's bin
rr_0loop_next:
    ADD     R3,R3,#4            @ Increment the pointer
    CMP     R3,R4               @ Check if pointers are the same
    BGT     rr_next_bit         @ If so, move to the next bit
    B       rr_0loop            @ If not, check the next value
rr_1loop:
    ADD     R12,#1              @ Increment loop counter (debug)
    LDR     R5,[R4]             @ Load current value from pointer
    TST     R5,R2               @ Check bitmask
    BNE     rr_1loop_next       @ If the value is 1, loop
    BL      rr_swap             @ If not, swap values
    B       rr_0loop_next       @ Switch to the 0's bin
rr_1loop_next:
    SUB     R4,R4,#4            @ Decrement the pointer
    CMP     R3,R4               @ Check if pointers are the same
    BGT     rr_next_bit         @ If so, move to the next bit
    B       rr_1loop            @ If not, check the next value
rr_next_bit:
    LSR     R2,R2,#1            @ Update bitmask to next bit
    CMP     R2,#0               @ Check to see if we've shifted all bits to 0
    BEQ     rr_done             @ If so, don't recurse anymore
    MOV     R0,R6               @ Array start
    MOV     R1,R3               @ 0's bin array end
    SUB     R1,#4               @
    BL      rsort_recurse       @ Sort 0's bin
    MOV     R0,R4               @ 1's bin array start
    ADD     R0,#4               @
    MOV     R1,R7               @ Array end
    BL      rsort_recurse       @ Sort 1's bin
    B       rr_done             @ All done
rr_swap:
    PUSH    {LR}                @ Store LR
    MOV     R0,R3               @ End of 0's bin
    MOV     R1,R4               @ End of 1's bin
    BL      swap                @ Swap values
    POP     {PC}                @ Return
rr_done:
    //BL      rsort_debug
    POP     {R0-R9,PC}          @ Restore previous values   

swap:
    @@ Swaps the values from 2 memory locations
    @@ R0 = 1st memory location
    @@ R1 = 2nd memory location
    PUSH    {R0-R4,LR}          @ Store previous values
    LDR     R3,[R0]             @ Grab the value from the first memory location
    LDR     R4,[R1]             @ Grab the value from the second memory location
    STR     R3,[R1]             @ Store value 2 in memory location 1
    STR     R4,[R0]             @ Store value 1 in memory location 2
    POP     {R0-R4,PC}          @ Return

    
@@@  Data Section
    .data
depth_header:       .asciz "Depth:   "
depth_value:        .asciz "00000"
memory_header:      .asciz "Bin:"
bitmask_header:     .asciz "Bitmask: "    
loop_header:        .asciz "Loop: "
loop_value:         .asciz "000000000000"
