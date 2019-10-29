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
    .global qsort

// Code Section
qsort:
    // Quick sort an array of 32bit integers
    // Arguments: R0 = Array location, R1 = Array size
	PUSH    {R0-R10,LR}         // Push the existing registers on to the stack
    MOV     R4,R0               // R4 = Array Location
    MOV     R5,R1               // R5 - Array Size
    CMP     R5,#1               // Check for an array of size <= 1
    BL      print_array
    BL      newline
    BL      print_registers
    BL      newline
    BLE     qsort_done          // If array size <= 1, return
    CMP     R5,#2               // Check for an array of size == 2
    BEQ     qsort_check         // If array size == 2, check values
    SUBS    R6,R5,#1
    ADDS    R6,R4,R6,LSL #2     // R6 = End of the array location
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
qsort_recurse_l:
    MOV     R0,R4               // R0 = Location of the start of the array
    SUBS    R1,R9,#1            // R1 = Length of first part of the array
    BL      qsort               // Sort first part of array
qsort_recurse_u:    
    ADDS    R0,R8,#4            // R0 = Location of the second part of the array
    SUBS    R1,R5,R9            // R1 = Length of first second of the array
    ADDS    R1,R1,#1
    BL      qsort               // Sort first half of array
qsort_check:
    LDR     R0,[R4]             // Load first value into R0
    LDR     R1,[R4,#4]          // Load second value into R1
    CMP     R0,R1               // Compare R0 and R1
    BLE     qsort_done          // If R1 <= R0, then we're done
    STR     R1,[R4]             // Otherwise, swap values
    STR     R0,[R4,#4]          // 
qsort_done:
    BL      print_r0_binary
    BL      newline
    POP     {R0-R10,PC}         // Pop the registers off of the stack and return
