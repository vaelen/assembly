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

// Bubble Sort

// Exported Methods
    .global bsort

// Code Section
    
bsort:
    // Bubble sort an array of 32bit integers in place
    // Arguments: R0 = Array location, R1 = Array size
    PUSH    {R0-R6,LR}          // Push the existing registers on to the stack
bsort_next:                    // Check for a sorted array
    MOV     R2,#0               // R2 = Current Element Number
    MOV     R6,#0               // R6 = Number of swaps
bsort_loop:                    // Start loop
    ADD     R3,R2,#1            // R3 = Next Element Number
    CMP     R3,R1               // Check for the end of the array
    BGE     bsort_check         // When we reach the end, check for changes
	LDR     R4,[R0,R2,LSL #2]   // R4 = Current Element Value
    LDR     R5,[R0,R3,LSL #2]   // R5 = Next Element Value
    CMP     R4,R5               // Compare element values
    STRGT   R5,[R0,R2,LSL #2]   // If R4 > R5, store current element at next location
    STRGT   R4,[R0,R3,LSL #2]   // If R4 > R5, Store next element at current location
    ADDGT   R6,R6,#1            // If R4 > R5, Increment swap counter
    MOV     R2,R3               // Advance to the next element
    B       bsort_loop          // End loop
bsort_check:                   // Check for changes
    CMP     R6,#0               // Were there changes this iteration?
    SUBGT   R1,R1,#1            // Optimization: skip last value in next iteration
    BGT     bsort_next          // If there were changes, do it again
bsort_done:                    // Return
    POP     {R0-R6,PC}          // Pop the registers off of the stack and return
