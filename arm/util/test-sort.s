@@@ Test Sorting Related Methods
@@@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab: 
@@@ vim: ft=arm 

@@@ Exteral Methods
    .global bsort
    .global rsort
    .global puts
    .global print_r0
    .global print_r0_binary
    .global newline
    .global getrandom
    .global exit

@@@ Exported Methods
.global _start

_start:
/*
    MOV     R0,#128
    BL      test_binary
*/  

    LDR     R0,=bsort           @ Bubble Sort
    LDR     R1,=bsort_title     @
    BL      test_sort           @

/*
    LDR     R0,=qsort           @ Quick Sort
    LDR     R1,=qsort_title     @
    BL      test_sort           @
*/
    
    LDR     R0,=rsort           @ Radix Sort
    LDR     R1,=rsort_title     @
    BL      test_sort           @

    MOV     R0,#0               @ Normal return code
    B       exit                @ exit

test_binary:
    @@ Print binary values
    @@ Arguments: R0 = Max value
    PUSH    {R0-R1,LR}          @ Push previous register values onto the stack
    MOV     R1,R0               @ R1 = Max value
    MOV     R0,#1               @ R0 = Current value
tb_loop:
    CMP     R0,R1               @ Are we done?
    BGT     tb_done             @ If so, return
    BL      print_r0_binary     @ Print value
    ADD     R0,#1               @ Increment counter
    B       tb_loop             @ Loop
tb_done:    
    POP     {R0-R1,PC}          @ Return
    
test_sort:
    @@ R0 = Address of the sort routine, R1 = Address of title
    PUSH    {R0-R2,LR}          @ Push the existing registers on to the stack
    MOV     R2,R0               @ R2 = Sort routine
    MOV     R0,R1               @ Print title
    BL      puts
    BL      init_array          @ Initialize array
    LDR     R0,=unsorted        @ Print the unsorted header string
    BL      puts                @ |
    BL      print_array         @ Print array
    BL      newline             @ Print newline
    LDR     R0,=array           @ Set array location
    MOV     R1,#64              @ Set array size
    BLX     R2                  @ Sort
    LDR     R0,=sorted          @ Print the sorted header string
    BL      puts                @ |
    BL      print_array         @ Print array
    BL      newline             @ Print newline
    POP     {R0-R2,PC}          @ Pop the registers off of the stack and return
    
init_array:
    @@ Initialize the array
    PUSH    {R0-R2,LR}          @ Push the existing registers on to the stack
    LDR     R0,=array           @ Location of the array
    MOV     R1,#256             @ Number of random bytes to read
    MOV     R2,#0               @ Flags (default values)
    BL      getrandom
    POP     {R0-R2,PC}          @ Pop the registers off of the stack and return
    
print_array:
    @@ Print the array
    PUSH    {R0-R10,LR}         @ Push the existing registers on to the stack
    LDR     R9,=array           @ Location of the array
    MOV     R10,#64             @ Array size
pa_loop:
    MOV     R0,R9               @ Load the array data
    LDMIA   R0,{R1-R8}          @ 
    MOV     R0,R1               @ Print array[0]
    BL      print_r0            @ 
    MOV     R0,R2               @ Print array[1]
    BL      print_r0            @ 
    MOV     R0,R3               @ Print array[2]
    BL      print_r0            @ 
    MOV     R0,R4               @ Print array[3]
    BL      print_r0            @ 
    MOV     R0,R5               @ Print array[4]
    BL      print_r0            @ 
    MOV     R0,R6               @ Print array[5]
    BL      print_r0            @ 
    MOV     R0,R7               @ Print array[6]
    BL      print_r0            @ 
    MOV     R0,R8               @ Print array[7]
    BL      print_r0            @ 
    ADD     R9,#32              @ Increment pointer
    SUB     R10,#8              @ Decrement counter
    CMP     R10,#0              @ Are we done?
    BGT     pa_loop             @ If not, continue
    POP     {R0-R10,PC}          @ Pop the registers off of the stack and return

.data

unsorted: .asciz "Unsorted List:"
sorted: .asciz "Sorted List:"
bsort_title: .asciz "-=Bubble Sort=-"
rsort_title: .asciz "-=Radix Sort=-"
qsort_title: .asciz "-=Quick Sort=-"
array: .space 256
