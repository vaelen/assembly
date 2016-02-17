@ Test Sorting Related Methods
@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab: 
@ vim: ft=arm 

@ Exteral Methods
.global bsort
.global qsort
.global puts
.global print_r0
.global exit

@ Exported Methods
.global _start

_start:
    BL      init_array          @ Initialize array
    LDR     R0,=unsorted        @ Print the unsorted header string
    BL      puts                @ |
    BL      print_array         @ Print array
    LDR     R0,=array           @ Set array location
    MOV     R1,#8               @ Set array size
    BL      bsort               @ Bubble sort
    LDR     R0,=sorted          @ Print the sorted header string
    BL      puts                @ |
    BL      print_array         @ Print array
    MOV     R0, #0              @ Normal return code
    B       exit                @ exit

init_array:
    @ Initialize the array
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    LDR     R0,=array           @ Location of the array
    MOV     R1,#5               @ array[0]
    MOV     R2,#1               @ array[1]
    MOV     R3,#2               @ array[2]
    MOV     R4,#8               @ array[3]
    MOV     R5,#4               @ array[4]
    MOV     R6,#3               @ array[5]
    MOV     R7,#6               @ array[6]
    MOV     R8,#7               @ array[7]
    STMIA   R0,{R1-R8}          @ Store the array data
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return

print_array:
    @ Print the array
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    LDR     R0,=array           @ Location of the array
    LDMIA   R0,{R1-R8}          @ Load the array data
    MOV     R0,R1               @ Print array[0]
    BL      print_r0            @ |
    MOV     R0,R2               @ Print array[1]
    BL      print_r0            @ |
    MOV     R0,R3               @ Print array[2]
    BL      print_r0            @ |
    MOV     R0,R4               @ Print array[3]
    BL      print_r0            @ |
    MOV     R0,R5               @ Print array[4]
    BL      print_r0            @ |
    MOV     R0,R6               @ Print array[5]
    BL      print_r0            @ |
    MOV     R0,R7               @ Print array[6]
    BL      print_r0            @ |
    MOV     R0,R8               @ Print array[7]
    BL      print_r0            @ |
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return

.data

array: .space 8
unsorted: .asciz "Unsorted List:"
sorted: .asciz "Sorted List:"
