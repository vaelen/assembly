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

// Exported Methods
    .global bsort

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
