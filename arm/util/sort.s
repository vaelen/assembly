@@@ Sorting Related Methods
@@@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab background=dark: 
@@@ vim: ft=arm 

@@@ Exteral Methods
    .global div
    
@@@ Exported Methods
    @@ Buble sort broke when I increased the array size
    .global bsort
    @@ qsort isn't working yet
    .global qsort

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
