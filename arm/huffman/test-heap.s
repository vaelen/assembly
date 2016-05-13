@ Test heap functions
@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab background=dark: 
@ vim: ft=arm 

@ External Methods
.global heap_init
.global heap_add
.global heap_remove
.global heap_print
.global itoa
.global int_string
.global puts
.global exit

@ Exported Methods
.global _start

_start:
    LDR     R0, =step1          @ Set message
    BL      puts                @ Print message
    BL      newline             @ Print a newline

    MOV     R0, #0              @ Marker for end of test data
    PUSH    {R0}

    MOV     R0, #10             @ Test Data
    MOV     R1, #3              @ Test Data
    MOV     R2, #20             @ Test Data
    MOV     R3, #30             @ Test Data
    MOV     R4, #8              @ Test Data
    MOV     R5, #50             @ Test Data
    MOV     R6, #60             @ Test Data
    MOV     R7, #5              @ Test Data
    MOV     R8, #25             @ Test Data
    MOV     R9, #1              @ Test Data
    MOV     R10, #2             @ Test Data
    MOV     R11, #35            @ Test Data

    PUSH    {R0-R11}            @ Push test data onto the stack

    MOV     R12, #0             @ Starting Value

    LDR     R0, =step2          @ Set message
    BL      puts                @ Print message
    BL      newline             @ Print a newline

    LDR     R0, =heap           @ Set heap address
    MOV     R1, #16             @ Set maximum heap size
    BL      heap_init           @ Initialize the heap

    LDR     R0, =heap           @ Set heap address
    BL      print_heap        	@ Print heap
    BL      newline             @ Print a newline

  add_loop:

    LDR     R0, =step2          @ Set message
    BL      puts                @ Print message

    POP     {R11}               @ Key
    ADDS    R12, #1             @ Value

    CMP     R11, #0             @ Check for the end of the test values
    BEQ     add_done

    LDR     R0, =key            @ Set message
    BL      fputs               @ Print message
    MOV     R0, R11             @ Set value
    LDR     R1, =int_string     @ Set number format
    BL      itoa                @ Convert value to string
    MOV     R0,R1               @ Set value as message
    BL      fputs               @ Print value

    LDR     R0, =value          @ Set message
    BL      fputs               @ Print message
    MOV     R0, R12             @ Set value
    LDR     R1, =int_string     @ Set number format
    BL      itoa                @ Convert value to string
    MOV     R0,R1               @ Set value as message
    BL      puts                @ Print value

    LDR     R0, =heap           @ Set heap address
    MOV     R1, R11             @ Key
    MOV     R2, R12             @ Value
    BL      heap_add        	@ Add to the heap

    LDR     R0, =heap           @ Set heap address
    BL      print_heap        	@ Print heap
    BL      newline             @ Print a newline

    B       add_loop            @ Loop

  add_done:

    BL      newline             @ Print a newline

    LDR     R0, =step3          @ Set message
    BL      puts                @ Print message
    BL      newline             @ Print a newline

    MOV     R2, #1              @ Seed loop value

  remove_loop:
    CMP     R2, #0              @ If the heap is empty
    BEQ     remove_done

    LDR     R0, =step4          @ Set message
    BL      puts                @ Print message

    LDR     R0, =heap           @ Set heap address
    BL      heap_remove     	@ Remove from the heap
    MOV     R11, R0             @ Save key
    MOV     R12, R1             @ Save value

    LDR     R0, =key            @ Set message
    BL      fputs               @ Print message
    MOV     R0, R11             @ Set value
    LDR     R1, =int_string     @ Set number format
    BL      itoa                @ Convert value to string
    MOV     R0,R1               @ Set value as message
    BL      fputs               @ Print value

    LDR     R0, =value          @ Set message
    BL      fputs               @ Print message
    MOV     R0, R12             @ Set value
    LDR     R1, =int_string     @ Set number format
    BL      itoa                @ Convert value to string
    MOV     R0,R1               @ Set value as message
    BL      puts                @ Print value

    LDR     R0, =heap           @ Set heap address
    BL      print_heap        	@ Print heap
    BL      newline             @ Print a newline

    B       remove_loop         @ Loop

  remove_done:

    B       exit                @ exit

.data

@ 16 elements * 8 bytes per element = 128 + 2 = 130
heap: .space 130
step1: .asciz "Building Heap"
step2: .asciz "Adding Value"
step3: .asciz "Deconstructing Heap"
step4: .asciz "Removing Value"
step5: .asciz "Done"
key: .asciz "\tKey: "
value: .asciz "\tValue: "
