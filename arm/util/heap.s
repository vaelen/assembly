/*
    Copyright 2019, Andrew C. Young <andrew@vaelen.org>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/


// This module includes procedures for working with minimum binary heaps.
// The current size and maximum size of the heap are stored as part of the heap structure.
// Each entry in the heap is two words. 
//   The first is the key used for sorting.
//   The second is an optional data value.

// Exteral Methods
    .global div

// Exported Methods
    .global heap_init
    .global heap_add
    .global heap_remove

// Code Section
    
heap_init:
    // Initializes a heap structure
    //   R0 = Heap location
    //   R1 = Max heap size
    PUSH    {R2,LR}             // Push the existing registers on to the stack
    MOV     R2, #0              // This will be used below
    STR     R2, [R0]            // Set the initial size to 0
    STR     R1, [R0, #4]        // Set the maximum size to R1
    POP     {R2,PC}             // Pop the registers off of the stack and return

heap_add:
    // Adds a key/value pair to a heap.
    // Returns 0 on success, 1 on failure
    // Arguments: 
    //   R0 = Heap location
    //   R1 = Key
    //   R2 = Value
    PUSH    {R3-R12,LR}         // Push the existing registers on to the stack
    MOV     R3, R0              // R3 = Heap location
    LDR     R4, [R3]            // R4 = Current heap size
    LDR     R5, [R3, #4]        // R5 = Maximum heap size
    ADDS    R6, R3, #8          // R6 = Start of the heap
    CMP     R4, R5              // Compare the curret heap size to the maximum heap size
    BGE     heap_add_err        //   If there isn't space in the heap, return failure
    LSL     R7, R4, #3          // Find the end of the heap by multiplying R4 * 8
    ADDS    R7, R6              //   Then add the start of the heap
    STR     R1, [R7]            // Store the key in the first word
    STR     R2, [R7, #4]        // Store the value in the second word
    MOV     R8, R4              // R8 = Current index, R7 = Memory location of current index
    ADDS    R4, #1              // Increment heap size
    STR     R4, [R3]            // Store heap size
heap_sift_up:
    CMP     R8, #0              // Is this the root node?
    BEQ     heap_add_done       //   If so then return true
    MOV     R0, R8              // Divide current position
    MOV     R1, #2              //   by 2
    BL      div
    MOV     R9, R2              // R9 = Parent node index
    LSL     R10, R9, #3         // Find the memory location of the parent node by R9 * 8
    ADDS    R10, R6             //   Then add the start of the heap
    LDR     R11, [R7]           // R11 = Key at current location
    LDR     R1,  [R7, #4]       // R1  = Value at current location
    LDR     R12, [R10]          // R12 = Key at parent node location
    LDR     R2,  [R10, #4]      // R2  = Value at parent node location
    CMP     R12, R11            // Compare parent key with current key
    BLE     heap_add_done       //   If parent key is <= current key, return success
    STR     R11, [R10]          // Otherwise
    STR     R1,  [R10, #4]      //   swap keys
    STR     R12, [R7]           //   and
    STR     R2,  [R7, #4]       //   swap values
    MOV     R8, R9              // Set current index to the parent node's index
    MOV     R7, R10             // Set current location to parent node location
    B       heap_sift_up        // Sift again
heap_add_err:
    MOV     R0, #1              // Failure
    B       heap_add_exit       // Return
heap_add_done:
    MOV     R0, #0              // Success
heap_add_exit:
    POP     {R3-R12,PC}         // Pop the registers off of the stack and return

heap_remove:
    // Remove the lowest key/value pair from the heap.
    // Arguments: 
    //   R0 = Heap location
    // Returns:
    //   R0 = Returned Key
    //   R1 = Returned Value
    //   R2 = New Heap Size
    PUSH    {R3-R12,LR}         // Push the existing registers on to the stack
    MOV     R3, R0              // R3 = Heap location
    LDR     R4, [R3]            // R4 = Current heap size
    LDR     R5, [R3, #4]        // R5 = Maximum heap size
    ADDS    R6, R3, #8          // R6 = Start of the heap
    MOV     R0, #0              // R0 = Returned Key
    MOV     R1, #0              // R1 = Returned Value
    MOV     R2, #0              // R2 = Remaining Heap Size
    PUSH    {R0,R1,R2}          // Push the default return values onto the stack
    CMP     R4, #0              // Compare the curret heap size to 0
    BEQ     heap_remove_done    //   If there are no items in the heap, return
    POP     {R0,R1,R2}          // Pop the default return values back off the stack
    LDR     R0, [R6]            // Load the key at the top of the heap
    LDR     R1, [R6, #4]        // Load the value at the top of the heap
    PUSH    {R0,R1}             // Push the top-of-the-heap values onto the stack
    LSL     R7, R4, #3          // Find the end of the heap by multiplying R4 * 8
    ADDS    R7, R6              //   Then add the start of the heap
    SUBS    R7, #8              //   Then back up two words to the last element
    LDR     R1, [R7]            // Load the key from the first word
    LDR     R2, [R7, #4]        // Load the value from the second word
    STR     R1, [R6]            // Store the key at the top of the heap
    STR     R2, [R6, #4]        // Store the value at the top of the heap
    SUBS    R4, #1              // Decrement heap size
    STR     R4, [R3]            // Store heap size
    PUSH    {R4}                // Push new heap size onto the stack
    MOV     R7, R6              // R7 = Memory location of current index
    MOV     R8, #0              // R8 = Current index
heap_sift_down:
    LSL     R9, R8, #1          // R9 = Left child index (R8 * 2)
    ADDS    R9, #1              //   + 1
    CMP     R9, R4              // Is the left child past the last node?
    BGT     heap_remove_done    //   If so then return
    LSL     R10, R9, #3         // Find the memory location of the left child node by R9 * 8
    ADDS    R10, R6             //   Then add the start of the heap
    CMP     R9, R4              // Is the left child the last node? (is R9 == R4?)
    BEQ     heap_sift_one_node  //   If so then no need to find smallest node
    ADDS    R11, R9, #1         // R11 = Right child index (R9 + 1)
    LSL     R12, R11, #3        // Find the memory location of the right child node by R11 * 8
    ADDS    R12, R6             //   Then add the start of the heap
    LDR     R0, [R10]           // R0 = Left child key
    LDR     R1, [R12]           // R1 = Right child key
    CMP     R0, R1              // Find the smaller of the two keys
    MOVGE   R2, R1              // Right child is smaller, R2 = Key
    MOVGE   R0, R11             // Right child is smaller, R0 = Index
    MOVGE   R1, R12             // Right child is smaller, R1 = Location
    MOVLT   R2, R0              // Left child is smaller, R2 = Key
    MOVLT   R0, R9              // Left child is smaller, R0 = Index
    MOVLT   R1, R10             // Left child is smaller, R1 = Location
    B       heap_sift_down2     // Continue the sifting
heap_sift_one_node:
    MOV     R0, R9              // R0 = Left child index
    MOV     R1, R10             // R1 = Left child location
    LDR     R2, [R10]           // R2 = Left child key
heap_sift_down2:
    LDR     R9,  [R7]           // Key at current location
    LDR     R10, [R7, #4]       // Value at current location
    CMP     R2, R9              // Compare smallest child key with current key
    BGE     heap_remove_done    //   If smallest child key is >= current key, return
    LDR     R11, [R1]           // Key at smallest child location
    LDR     R12, [R1, #4]       // Value at smallest child location
    STR     R11, [R7]           // Swap key at current location
    STR     R12, [R7, #4]       // Swap value at current location
    STR     R9,  [R1]           // Swap key at smallest child location
    STR     R10, [R1, #4]       // Swap value at smallest child location
    MOV     R8, R0              // Change current index to smallest child index
    MOV     R7, R1              // Change current location to smallest child location
    B       heap_sift_down      // Sift again
heap_remove_done:
    POP     {R2}                // Pop the new heap size back off the stack
    POP     {R0,R1}             // Pop the return values back off the stack
    POP     {R3-R12,PC}         // Pop the registers off of the stack and return
