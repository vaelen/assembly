@ Test heap functions
@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab background=dark: 
@ vim: ft=arm 

@ External Methods
.global heap_init
.global heap_add
.global heap_remove
.global heap_print
.global exit

@ Exported Methods
.global _start

_start:
    LDR     R0, =heap           @ Set heap address
    MOV     R1, #16             @ Set maximum heap size
    BL      heap_init           @ Initialize the heap
    LDR     R0, =heap           @ Set heap address
    BL      print_heap        	@ Print heap

    LDR     R0, =heap           @ Set heap address
    MOV     R1, #10             @ Key
    MOV     R2, #1              @ Value
    BL      heap_add        	@ Add to the heap
    LDR     R0, =heap           @ Set heap address
    BL      print_heap        	@ Print heap

    LDR     R0, =heap           @ Set heap address
    MOV     R1, #3              @ Key
    MOV     R2, #2              @ Value
    BL      heap_add        	@ Add to the heap
    LDR     R0, =heap           @ Set heap address
    BL      print_heap        	@ Print heap

    LDR     R0, =heap           @ Set heap address
    MOV     R1, #30             @ Key
    MOV     R2, #3              @ Value
    BL      heap_add        	@ Add to the heap
    LDR     R0, =heap           @ Set heap address
    BL      print_heap        	@ Print heap

    LDR     R0, =heap           @ Set heap address
    MOV     R1, #20             @ Key
    MOV     R2, #4              @ Value
    BL      heap_add        	@ Add to the heap
    LDR     R0, =heap           @ Set heap address
    BL      print_heap        	@ Print heap

    LDR     R0, =heap           @ Set heap address
    MOV     R1, #2              @ Key
    MOV     R2, #5              @ Value
    BL      heap_add        	@ Add to the heap
    LDR     R0, =heap           @ Set heap address
    BL      print_heap        	@ Print heap

    B       exit                @ exit

.data

@ 16 elements * 8 bytes per element = 128 + 2 = 130
heap: .space 130
