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

// Sorting Related Methods

// Exteral Methods
    .global div
    
// Exported Methods
    .global bsort
    // qsort isn't working yet
    .global qsort

// Code Section
    
bsort:
    // Bubble sort an array of 32bit integers in place
    // Arguments: R0 = Array location, R1 = Array size
    PUSH    {R0-R12,LR}         // Push the existing registers on to the stack
    MOV     R4,R0               // R4 = Array Location
    MOV     R5,R1               // R5 = Array size
bsort_check:                   // Check for a sorted array
    MOV     R6,#0               // R6 = Current Element Number
bsort_check_loop:              // Start check loop
    ADDS    R7,R6,#1            // R7 = Next Element Number
    CMP     R7,R5               // Check for the end of the array
    BGE     bsort_done          // Exit method if we reach the end of the array
    LDR     R8,[R4,R6,LSL #2]   // R8 = Current Element Value
    LDR     R9,[R4,R7,LSL #2]   // R9 = Next Element Value
    CMP     R8,R9               // Compare element values
    BGT     bsort_swap          // If R8 > R9, swap
    MOV     R6,R7               // Advance to the next element
    B       bsort_check_loop    // End check loop
bsort_swap:                    // Swap values
    STR     R9,[R4,R6,LSL #2]   // Store current element at next location
    STR     R8,[R4,R7,LSL #2]   // Store next element at current location
    B       bsort_check         // Check again for a sorted array
bsort_done:                    // Return
    POP     {R0-R12,PC}         // Pop the registers off of the stack and return

qsort:
    // Quick sort an array of 32bit integers
    // Arguments: R0 = Array location, R1 = Array size
    PUSH    {R0-R10,LR}         // Push the existing registers on to the stack
    MOV     R4,R0               // R4 = Array Location
    MOV     R5,R1               // R5 - Array Size
    CMP     R5,#1               // Check for an array of size <= 1
    BLE     qsort_done          // If array size <= 1, return
    CMP     R5,#2               // Check for an array of size == 2
    BEQ     qsort_check         // If array size == 2, check values
    ADDS    R6,R4,R5,LSL #2     // R6 = End of the array location
qsort_partition:
    MOV     R7,R4               // R7 = Lower array bounds
    MOV     R8,R6               // R8 = Upper array bounds
    MOV     R9,R5               // R9 = Length of first part of array
    LDR     R10,[R4]            // R10 = Pivot value
qsort_p_loop:
    LDR     R0,[R7]             // R0 = Lower value
    LDR     R1,[R8]             // R1 = Upper value
	CMP     R0,R10              // Compare lower value to pivot
    BNE     qsort_p_u           // If not equal, branch
qsort_p_l:                     // Pivot is lower value
    CMP     R1,R0               // Compare
    BGE     qsort_p_l_ge        // If upper >= lower (p), leave it alone
    STR     R0,[R8]             // If upper < lower (p), swap values
    STR     R1,[R7]
	ADDS    R7,R7,#4            // If upper < lower (p), increment lower
    B       qsort_p_next        // Continue loop
qsort_p_l_ge:    
    SUBS    R8,R8,#4            // If upper >= lower (p), decrement upper
    SUBS    R9,R9,#1
    B       qsort_p_next        // Continue loop
qsort_p_u:                     // Pivot is upper value
	CMP     R1,R0               // Compare
	BGE     qsort_p_u_ge        // If upper (p) >= lower, leave it alone
	STR     R0,[R8]             // If upper (p) < lower, swap values
	STR     R1,[R7]
	SUBS    R8,R8,#4            // If upper (p) < lower, decrement upper
	SUBS    R9,R9,#1
	B       qsort_p_next        // Continue loop
qsort_p_u_ge:    
	ADDS    R7,R7,#4            // If upper (p) >= lower, increment lower
	B       qsort_p_next        // Continue loop    
qsort_p_next:   
    CMP     R7,R8               // Compare upper location to lower location
    BLT     qsort_p_loop        // If lower location < upper location, loop
qsort_recurse:      
    MOV     R0,R4               // R0 = Location of the start of the array
    MOV     R1,R9               // R1 = Length of first part of the array
    BL      qsort               // Sort first part of array
    ADDS    R0,R8               // R0 = Location of the second part of the array
    SUBS    R1,R5,R9            // R1 = Length of first part of the array
    BL      qsort               // Sort first half of array
qsort_check:
    LDR     R0,[R4]             // Load first value into R0
    LDR     R1,[R4,#4]          // Load second value into R1
    CMP     R0,R1               // Compare R0 and R1
    BLE     qsort_done          // If R1 <= R0, then we're done
    STR     R1,[R4]             // Otherwise, swap values
    STR     R0,[R4,#4]          // 
qsort_done:
    POP     {R0-R10,PC}         // Pop the registers off of the stack and return
