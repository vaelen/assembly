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


// This module implements heap sort of 32bit ints using a max heap

// Exported Methods
    .global hsort

// Code Section

hsort:  
    // R0 = Array location
    // R1 = Array length
    PUSH    {R2-R12,LR}         // Push the existing registers on to the stack
    CMP     R1, #1              // If the array is empty or only has 1 entry, return
    BLE     hsort_done
    CMP     R1, #2              // If the array has only 2 entires, do a simple comparison
    BLE     hsort_simple
    MOV     R11, #1             // R11 = 1 (constant)
    MOV     R12, #2             // R12 = 2 (constant)
    MOV     R10, #-1            // R10 = -1 (temporarily)
    UDIV    R10, R1, R12        // R10 = (len / 2) - 1 (starting heapify index)
    SUB     R10, R10, #1
    SUB     R9, R1, #1          // R9 = len - 1 (starting pop index)
    MOV     R2, R10             // R2 = Starting heapify index
heapify:
    // R2 = Index
    MOV     R3, R2              // R3 = Index of largest value
    MLA     R4, R2, R12, R11    // R4 = Left index (2i+1)
    MLA     R5, R2, R12, R12    // R5 = Right index (2i+2)
    LDR     R6, [R0, R2, LSL#2] // R6 = Index value (R0 + (R2 * 4))
    MOV     R7, R6              // R7 = Current largest value
heapify_check_left: 
    CMP     R4, R9              // Check to make sure the left node is within the array bounds
    BGT     heapify_check_right // If not then check the right node
    LDR     R8, [R0, R4, LSL#2] // R8 = Left value (R0 + (R4 * 4)
    CMP     R8, R7              // Compare left value to current largest value
    BLE     heapify_check_right // If left value <= largest value then check the right value
    MOV     R3, R4              // If left value > largest, change largest index to left node index
    MOV     R7, R8              //    and copy the value in preparation for right node comparison
heapify_check_right:    
    CMP     R5, R9              // Check to make sure the right node is within the array bounds
    BGT     heapify_swap        // If not then continue
    LDR     R8, [R0, R5, LSL#2] // R8 = Right value (R0 + (R5 * 4))
    CMP     R8, R7              // Compare right value to current largest value
    BLE     heapify_swap        // If right value <= largest value then continue
    MOV     R3, R5              // If right value > largest, change largest index to right node index
    MOV     R7, R8              //    and copy the value in preparation for swap operation
heapify_swap:
    CMP     R2, R3              // Check to see if the largest is the initial index or not
    BEQ     heapify_next        // If so, exit the heapify loop
    STR     R7, [R0, R2, LSL#2] // If not, store largest value at index (R0 + (R2 * 4))
    STR     R6, [R0, R3, LSL#2] //    and store index value at largest value index (R0 + (R3 * 4))
    MOV     R2, R3              //    and change index to largest index
    B       heapify             //    and recurse
heapify_next:
    CMP     R10, #0             // If last index was 0, the heap has been finished
    BEQ     heapify_pop
    SUB     R10, R10, #1        // Else, heapify next index
    MOV     R2, R10
    B       heapify
heapify_pop:
    LDR     R3, [R0]            // R3 = Largest value (front of heap)
    LDR     R4, [R0, R9, LSL#2] // R4 = Value from end of heap
    STR     R3, [R0, R9, LSL#2] // Store largest value at end of heap
    STR     R4, [R0]            // Store previous last value at start of heap
    SUB     R9, #1              // Decrement end of heap index
    CMP     R9, #1              // If there are only two items left in the heap, compare
    BEQ     hsort_simple
    MOV     R2, #0              // Else, heapify from the start of the heap
    B       heapify
hsort_simple:
    // Sort a list of exactly 2 elements
    LDR     R2, [R0]            // First value
    LDR     R3, [R0, #4]        // Second value
    CMP     R2, R3              // Compare values
    STRGT   R3, [R0]            // Swap if out of order
    STRGT   R2, [R0, #4]
hsort_done:
    POP     {R2-R12,PC}         // Pop the registers off of the stack and return
