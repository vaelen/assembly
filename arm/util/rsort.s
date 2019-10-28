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

// Radix Most Significant Bit In-Place Sorting Algorithm
    
// Exported Methods
    // Radix sort works properly
    .global rsort
    .global swap

// Code Section

rsort:
    // Radix MSD sort an array of 32bit integers
    // Arguments: R0 = Array location, R1 = Array size
    PUSH    {R0-R2,LR}          // Push the existing registers on to the stack
    CMP     R1,#1               // Check for an empty or single member array
    POPLE   {R0-R7,PC}          // If so, return to where we came from
    ADD     R1,R0,R1,LSL #2     // R1 = End of the array (R0 + (R1*4))
    SUB     R1,R1,#4            // 
    MOV     R2,#1               // R2 = Bitmask
    LSL     R2,R2,#31           //   most significant bit
    BL      rsort_recurse       // Begin recursion
    POP     {R0-R2,PC}          // Pop the registers off of the stack and return
    
rsort_recurse:
    // Radix MSD sort an array of 32bit integers (recursive helper)
    // Arguments: R0 = Array start, R1 = Array end, R2 = Bitmask
    PUSH    {R0-R8,LR}          // Store previous values
    SUB     R8,R1,R0            // Check array length
    CMP     R8,#4               // 
    BLT     rr_done             // Return if array is empty or only has 1 entry
    MOV     R3,R0               // R3 = 0's bin pointer (start of array)
    MOV     R4,R1               // R4 = 1's bin pointer (end of array)
    MOV     R5,#0               // R5 = Current value
    MOV     R6,R0               // Set original array start (debug)
    MOV     R7,R1               // Set original array end (debug)
rr_0loop:
    LDR     R5,[R3]             // Load next value from pointer
    TST     R5,R2               // Check bitmask
    BEQ     rr_0loop_next       // If the value is 0, loop
    BL      rr_swap             // If not, swap values
    B       rr_1loop_next       // Switch to the 1's bin
rr_0loop_next:
    ADD     R3,R3,#4            // Increment the pointer
    CMP     R3,R4               // Check if pointers are the same
    BGT     rr_next_bit         // If so, move to the next bit
    B       rr_0loop            // If not, check the next value
rr_1loop:
    ADD     R12,#1              // Increment loop counter (debug)
    LDR     R5,[R4]             // Load current value from pointer
    TST     R5,R2               // Check bitmask
    BNE     rr_1loop_next       // If the value is 1, loop
    BL      rr_swap             // If not, swap values
    B       rr_0loop_next       // Switch to the 0's bin
rr_1loop_next:
    SUB     R4,R4,#4            // Decrement the pointer
    CMP     R3,R4               // Check if pointers are the same
    BGT     rr_next_bit         // If so, move to the next bit
    B       rr_1loop            // If not, check the next value
rr_next_bit:
    LSR     R2,R2,#1            // Update bitmask to next bit
    CMP     R2,#0               // Check to see if we've shifted all bits to 0
    BEQ     rr_done             // If so, don't recurse anymore
    MOV     R0,R6               // Array start
    MOV     R1,R3               // 0's bin array end
    SUB     R1,#4               
    BL      rsort_recurse       // Sort 0's bin
    MOV     R0,R4               // 1's bin array start
    ADD     R0,#4               
    MOV     R1,R7               // Array end
    BL      rsort_recurse       // Sort 1's bin
    B       rr_done             // All done
rr_swap:
    PUSH    {LR}                // Store LR
    MOV     R0,R3               // End of 0's bin
    MOV     R1,R4               // End of 1's bin
    BL      swap                // Swap values
    POP     {PC}                // Return
rr_done:
    POP     {R0-R8,PC}          // Restore previous values   

swap:
    // Swaps the values from 2 memory locations
    // R0 = 1st memory location
    // R1 = 2nd memory location
    PUSH    {R0-R4,LR}          // Store previous values
    LDR     R3,[R0]             // Grab the value from the first memory location
    LDR     R4,[R1]             // Grab the value from the second memory location
    STR     R3,[R1]             // Store value 2 in memory location 1
    STR     R4,[R0]             // Store value 1 in memory location 2
    POP     {R0-R4,PC}          // Return
