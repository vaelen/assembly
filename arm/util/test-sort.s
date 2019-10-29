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

// Test Sorting Related Methods

// Exteral Methods
    .global bsort
    .global rsort
    .global puts
    .global print_r0
    .global print_r0_binary
    .global newline
    .global getrandom
    .global exit

// Exported Methods
    .global _start
    .global print_array

_start:
    POP     {R2}                // R2 = argument count

_check_args:
    // Check arguments
    CMP     R2,#0
    BEQ     _default            // Use default settings if we run out of arguments

    POP     {R3}                // R3 = next argument
    SUBS    R2,R2,#1
    
    // Check for Help Flag
    MOV     R0,R3
    LDR     R1,=help_flag
    BL      strcmp
    MOV     R4,R0
    CMP     R4,#0
    LDREQ   R0,=help
    BLEQ    puts
    CMP     R4,#0
    BEQ     _done
    
    // Check for Quick Sort Flag
    MOV     R0,R3
    LDR     R1,=qsort_flag
    BL      strcmp
    MOV     R4,R0
    CMP     R4,#0
    LDREQ   R0,=qsort
    LDREQ   R1,=qsort_title     
    BLEQ    test_sort           
    CMP     R4,#0
    BEQ     _done

    // Check for Bubble Sort Flag
    MOV     R0,R3
    LDR     R1,=bsort_flag
    BL      strcmp
    MOV     R4,R0
    CMP     R4,#0
    LDREQ   R0,=bsort
    LDREQ   R1,=bsort_title     
    BLEQ    test_sort           
    CMP     R4,#0
    BEQ     _done

    // Check for Radio Sort Flag
    MOV     R0,R3
    LDR     R1,=rsort_flag
    BL      strcmp
    MOV     R4,R0
    CMP     R4,#0
    LDREQ   R0,=rsort           
    LDREQ   R1,=rsort_title     
    BLEQ    test_sort
    CMP     R4,#0
    BEQ     _done

    // Check next argument
    B       _check_args

_default:   
    // Default to Quick Sort

    LDR     R0,=qsort           // Quick Sort
    LDR     R1,=qsort_title     
    BL      test_sort           

_done:  
    MOV     R0,#0               // Normal return code
    B       exit                // exit

test_binary:
    // Print binary values
    // Arguments: R0 = Max value
    PUSH    {R0-R1,LR}          // Push previous register values onto the stack
    MOV     R1,R0               // R1 = Max value
    MOV     R0,#1               // R0 = Current value
tb_loop:
    CMP     R0,R1               // Are we done?
    BGT     tb_done             // If so, return
    BL      print_r0_binary     // Print value
    ADD     R0,#1               // Increment counter
    B       tb_loop             // Loop
tb_done:    
    POP     {R0-R1,PC}          // Return
    
test_sort:
    // R0 = Address of the sort routine, R1 = Address of title
    PUSH    {R0-R2,LR}          // Push the existing registers on to the stack
    MOV     R2,R0               // R2 = Sort routine
    MOV     R0,R1               // Print title
    BL      puts
    //BL      init_array          // Initialize array
    LDR     R0,=unsorted        // Print the unsorted header string
    BL      puts                // |
    BL      print_array         // Print array
    BL      newline             // Print newline
    LDR     R0,=array           // Set array location
    MOV     R1,#16              // Set array size
    BLX     R2                  // Sort
    LDR     R0,=sorted          // Print the sorted header string
    BL      puts                // |
    BL      print_array         // Print array
    BL      newline             // Print newline
    POP     {R0-R2,PC}          // Pop the registers off of the stack and return
    
init_array:
    // Initialize the array
    PUSH    {R0-R2,LR}          // Push the existing registers on to the stack
    LDR     R0,=array           // Location of the array
    MOV     R1,#1               // Number of random bytes to read
    MOV     R2,#0               // Flags (default values)
    BL      getrandom
    POP     {R0-R2,PC}          // Pop the registers off of the stack and return
    
print_array:
    // Print the array
    PUSH    {R0-R10,LR}         // Push the existing registers on to the stack
    LDR     R9,=array           // Location of the array
    MOV     R10,#16             // Array size
pa_loop:
    MOV     R0,R9               // Load the array data
    LDMIA   R0,{R1-R8}          // 
    MOV     R0,R1               // Print array[0]
    BL      print_r0            // 
    MOV     R0,R2               // Print array[1]
    BL      print_r0            // 
    MOV     R0,R3               // Print array[2]
    BL      print_r0            // 
    MOV     R0,R4               // Print array[3]
    BL      print_r0            // 
    MOV     R0,R5               // Print array[4]
    BL      print_r0            // 
    MOV     R0,R6               // Print array[5]
    BL      print_r0            // 
    MOV     R0,R7               // Print array[6]
    BL      print_r0            // 
    MOV     R0,R8               // Print array[7]
    BL      print_r0            // 
    ADD     R9,#32              // Increment pointer
    SUB     R10,#8              // Decrement counter
    CMP     R10,#0              // Are we done?
    BGT     pa_loop             // If not, continue
    POP     {R0-R10,PC}         // Pop the registers off of the stack and return

.data

unsorted: .asciz "Unsorted List:"
sorted: .asciz "Sorted List:"
bsort_title: .asciz "-=Bubble Sort=-"
rsort_title: .asciz "-=Radix Sort=-"
qsort_title: .asciz "-=Quick Sort=-"
qsort_flag:  .asciz "-q"
bsort_flag:  .asciz "-b"
rsort_flag:  .asciz "-r"
help_flag:   .asciz "-h"
help:        .asciz "Usage: test-sort [-q|-b|-r]\n\nOptions:\n\t-q : quick sort\n\t-b : bubble sort\n\t-r : radix sort"
//array:  .space 32
array:   .word 10, 2, 5, 3, 9, 12, 7, 4, 1, 8, 11, 6, 16, 14, 13, 15, 32, 20, 17, 25, 24, 26, 18, 31, 19, 28, 21, 27, 23, 22, 30, 29, 63, 59, 33, 60, 45, 52, 50, 40, 48, 34, 41, 35, 61, 55, 58, 62, 36, 37, 39, 38, 42, 51, 64, 54, 43, 56, 44, 46, 49, 47, 53, 57
