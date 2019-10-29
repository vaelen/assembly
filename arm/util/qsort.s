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

// Quick Sort

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
    BLE     qsort_done          // If array size <= 1, return
    CMP     R5,#2               // Check for an array of size == 2
    BEQ     qsort_check         // If array size == 2, check values
qsort_partition:
    MOV     R1,#2               // Find the middle element
    SDIV    R2,R5,R1            // R2 = The middle element index
    LDR     R6,[R4]             // R6 = Beginning of array value
    LDR     R7,[R4,R2,LSL #2]   // R7 = Middle of array value
    SUB     R8,R5,#1            // R8 = Upper array bound index (len -1 1)
    LDR     R8,[R4,R8,LSL #2]   // R8 = End of the array value
    CMP     R6,R7               // Sort the values
    MOVGT   R9,R6
    MOVGT   R6,R7
    MOVGT   R7,R9
    CMP     R7,R8
    MOVGT   R9,R7
    MOVGT   R7,R8
    MOVGT   R8,R9
    CMP     R6,R7
    MOVGT   R9,R6
    MOVGT   R6,R7
    MOVGT   R7,R9
    MOV     R6,R7               // R6 = Pivot
    MOV     R7,#0               // R7 = Lower array bounds index
    SUB     R8,R5,#1            // R8 = Upper array bounds index (len - 1)
qsort_loop:
    LDR     R0,[R4,R7,LSL #2]   // R0 = Lower value
    LDR     R1,[R4,R8,LSL #2]   // R1 = Upper value
    CMP     R0,R6               // Compare lower value to pivot
    BEQ     qsort_loop_u        // If == pivot, do nothing
    ADDLT   R7,R7,#1            // If < pivot, increment lower index 
    STRGT   R0,[R4,R8,LSL #2]   // If > pivot, swap values
    STRGT   R1,[R4,R7,LSL #2]
    SUBGT   R8,R8,#1            // if > pivot, decrement upper index
    CMP     R7,R8               // if indexes are the same, recurse
    BEQ     qsort_recurse
    LDR     R0,[R4,R7,LSL #2]   // R0 = Lower value
    LDR     R1,[R4,R8,LSL #2]   // R1 = Upper value
qsort_loop_u:
    CMP     R1,R6               // Compare upper value to pivot
    SUBGT   R8,R8,#1            // if > pivot, decrement upper index
    STRLT   R0,[R4,R8,LSL #2]   // If < pivot, swap values
    STRLT   R1,[R4,R7,LSL #2]
    ADDLT   R7,R7,#1            // if < pivot, increment lower index
    CMP     R7,R8               // if indexes are the same, recurse
    BEQ     qsort_recurse
    B       qsort_loop          // Continue loop
qsort_recurse:
    MOV     R0,R4               // R0 = Location of the start of the array
    MOV     R1,R7               // R1 = Length of first part of the array
    BL      qsort               // Sort first part of array
    ADD     R8,R8,#1            // R8 = 1 index past final index
    CMP     R8,R5               // Compare final index to original length
    BGE     qsort_done          // If equal, return
    ADD     R0,R4,R8,LSL #2     // R0 = Location of the second part of the array
    SUB     R1,R5,R8            // R1 = Length of second part of the array
    BL      qsort               // Sort second part of array
    B       qsort_done          // return
qsort_check:
    LDR     R0,[R4]             // Load first value into R0
    LDR     R1,[R4,#4]          // Load second value into R1
    CMP     R0,R1               // Compare R0 and R1
    BLE     qsort_done          // If R1 <= R0, then we're done
    STR     R1,[R4]             // Otherwise, swap values
    STR     R0,[R4,#4]          // 
qsort_done:
    POP     {R0-R10,PC}         // Pop the registers off of the stack and return
