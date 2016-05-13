@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab background=dark: 
@ vim: ft=arm 

@ This module includes procedures for working with minimum binary heaps.
@ The current size and maximum size of the heap are stored as part of the heap structure.
@ Each entry in the heap is two words. 
@   The first is the key used for sorting.
@   The second is an optional data value.

@ Exteral Methods
.global div

@ Exported Methods
.global heap_init
.global heap_add
.global heap_remove

@ The heaps 

heap_init:
    @ Initializes a heap structure
    @   R0 = Heap location
    @   R1 = Max heap size
    PUSH    {R2,LR}             @ Push the existing registers on to the stack
    MOV     R2, #0              @ This will be used below
    STR     R2, [R0]            @ Set the initial size to 0
    STR     R1, [R0, #4]        @ Set the maximum size to R1
    POP     {R2,PC}             @ Pop the registers off of the stack and return

heap_add:
    @ Adds a key/value pair to a heap.
    @ Returns 0 on success, 1 on failure
    @ Arguments: 
    @   R0 = Heap location
    @   R1 = Key
    @   R2 = Value
    PUSH    {R3-R12,LR}         @ Push the existing registers on to the stack
    @ Copy input values into variable registers
    MOV     R3, R0              @ R3 = Heap location
    LDR     R4, [R3]            @ R4 = Current heap size
    LDR     R5, [R3, #4]        @ R5 = Maximum heap size
    ADDS    R6, R3, #8          @ R6 = Start of the heap
    MOV     R0, #1              @ R0 = Return value (1 = failure)
    CMP     R4, R5              @ Compare the curret heap size to the maximum heap size
    BGE     heap_add_done       @   If there isn't space in the heap, return failure
    LSL     R7, R4, #3          @ Find the end of the heap by multiplying R4 * 8
    ADDS    R7, R6              @   Then add the start of the heap
    STR     R1, [R7]            @ Store the key in the first word
    STR     R2, [R7, #4]        @ Store the value in the second word
    ADDS    R4, #1              @ Increment heap size
    STR     R4, [R3]            @ Store heap size
    MOV     R8, R4              @ R8 = Current index, R7 = Memory location of current index
  heap_sift:
    MOV     R0, #0              @ Set return code to success (0)
    CMP     R8, #0              @ Is this the root node?
    BEQ     heap_add_done       @   If so then return true
    MOV     R0, R8              @ Divide current position
    MOV     R1, #2              @   by 2
    BL      div
    MOV     R9, R2              @ R9 = Parent node index
    LSL     R10, R9, #3         @ Find the memory location of the parent node by R9 * 8
    ADDS    R10, R6             @   Then add the start of the heap
    LDR     R11, [R7]           @ R11 = Key at current location
    LDR     R1,  [R7, #4]       @ R1  = Value at current location
    LDR     R12, [R10]          @ R12 = Key at parent node location
    LDR     R2,  [R10, #4]      @ R2  = Value at parent node location
    MOV     R0, #0              @ Set return code to success (0)
    CMP     R12, R11            @ Compare parent key with current key
    BLE     heap_add_done       @   If parent key is <= current key, return success
    STR     R11, [R10]          @ Otherwise
    STR     R1,  [R10, #4]      @   swap keys
    STR     R12, [R7]           @   and
    STR     R2,  [R7, #4]       @   swap values
    MOV     R8, R9              @ Set current index to the parent node's index
    MOV     R7, R10             @ Set current location to parent node location
    B       heap_sift           @ Sift again
  heap_add_done:
    POP     {R3-R12,PC}         @ Pop the registers off of the stack and return

heap_remove:
    @ Bubble sort an array of 32bit integers in place
    @ Arguments: R0 = Array location, R1 = Array size
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return
