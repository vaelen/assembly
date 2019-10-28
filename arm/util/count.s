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

// Count characters from STDIN

// External Functions
    .global fputs
    .global puts
    .global itoa
    .global read
    .global check_read_error

// Exported Functions
    .global count_from_file
    .global init_counts
    .global count_characters
    .global print_counts
    .global status
    .global init_sorted_chars
    .global sort_chars
    .global print_sorted

// Code Section
    
count_from_file:
    // Count characters from the given file handle
    // Arguments: R0 = File handle
    PUSH    {R0-R12,LR}         // Push the existing registers on to the stack
    MOV     R4,R0               // R4 = File handle
cff_loop:
    MOV     R0,R4               // Set file handle
    LDR     R1,=buffer          // Set buffer location
    MOV     R2,#4096            // Set buffer size
    BL      read                // Read bytes
    MOV     R5, R0              // R5 = Bytes read
    CMP     R0,#0               // Check for Errors
    BLLT    check_read_error    // Warn about a bad address
    CMP     R0,#0               // Check for EOF
    BGT     cff_helper          // Count characters and loop if not EOF
    POP     {R0-R12,PC}         // Return when loop completes, restore registers
cff_helper:
    // Arguments: R0 = Character count
    MOV     R1,R0               // Move character count to R1
    LDR     R0,=buffer          // Read from the buffer
    BL      count_characters    // Count characters
    B       cff_loop            // Loop 

status:
    // print status
    PUSH    {R0,LR}
    LDR     R0,=status_s
    BL      puts
    POP     {R0,PC}

count_characters:
    // Counts characters 
    // Arguments: 
    //   R0 = Address of buffer
    //   R1 = Length of buffer
    PUSH    {R0-R12,LR}         // Push the existing registers on to the stack
    LDR     R5,=counts          // R5 = Address of the count array
    SUBS    R2,R0,#1            // R2 = One byte before the first memory location
count_loop:
    ADDS    R2,#1               // R2 = Current memory location
    LDRB    R3,[R2]             // R3 = Current byte
    LDR     R4,[R5,R3,LSL #2]   // R4 = Current count (R5 + (R3*4))
    ADDS    R4,#1               // Increment the count
    STR     R4,[R5,R3,LSL #2]   // Store the count back into the array
    SUBS    R1,#1               // Reduce loop counter by 1
    BNE     count_loop          // Loop if counter != 0
    POP     {R0-R12,PC}         // Return when loop completes, restore registers

sort_chars:
    // Copies the characters into an array sorted by occurance
    PUSH    {R0-R12,LR}         // Push the existing registers on to the stack
    LDR     R0,=sorted_chars    // R0 = Memory location of sorted array
    MOV     R1,#1280            // R1 = Length of sorted array
    LDR     R2,=counts          // R2 = Memory location of counts array
    MOV     R3,#256             // R3 = Length of counts array
    MOV     R4,#0               // R4 = Current sorted array index
sort_chars_next:
    MOV     R5,#0               // R5 = Current character value
    MOV     R6,R2               // R6 = Current memory location
    ADDS    R7,R2,R3,LSL #2     // R7 = Ending memory location (R2 + (R3 * 4)
    MOV     R8,#0               // R8 = Value at current memory location
    MOV     R9,#0               // R9 = Character with max count
    MOV     R10,#0              // R10 = Memory location of max count
    MOV     R11,#0              // R11 = Value at max count memory location
sort_chars_loop:
    LDR     R8,[R6]             // Load value
    CMP     R8,R11              // Compare current value to max value
    MOVGT   R9,R5               // If current > max, update max character
    MOVGT   R10,R6              // If current > max, update max memory location
    MOVGT   R11,R8              // If current > max, update max value
    ADDS    R5,#1               // Increment character number
    ADDS    R6,#4               // Increment the memory location
    CMP     R6,R7               // Have we reached the end?
    BNE     sort_chars_loop     // If not, loop again
sort_chars_loop_done:
    CMP     R10,#0              // Did we find a max count?
    BLEQ    sort_chars_l_exit   // If not, we're done
    STRB    R9,[R0,R4]          // Store max char at current sorted array index
    ADDS    R4,#1               // Increment sorted array index
    STR     R11,[R0,R4]         // Store max count at current sorted array index + 1
    ADDS    R4,#4               // Increment sorted array index
    MOV     R11,#0              // Set max count to 0
    STR     R11,[R10]           // Write 0 into the max count memory location
    CMP     R4,R3               // Have we reached the end of the sorted array?
    BLT     sort_chars_next     // If not, do the whole thing again
sort_chars_l_exit:
    POP     {R0-R12,PC}         // Pop the registers off of the stack and return

init_counts:
    // Initialize the memory used for counting
    PUSH    {R0-R12,LR}         // Push registers on to stack
    LDR     R0,=counts          // Starting memory location
    MOV     R1,#1024            // Array size
    MOV     R2,#0               // Initial value
    BL      init_array          // Initialize array
    POP     {R0-R12,PC}         // Return when loop completes, restore registers

init_sorted_chars:
    // Initialize the memory used for sorting
    PUSH    {R0-R12,LR}         // Push registers on to stack
    LDR     R0,=sorted_chars    // Starting memory location
    MOV     R1,#1280            // Array size
    MOV     R2,#0xFFFFFFFF      // Initial value
    BL      init_array          // Initialize array
    POP     {R0-R12,PC}         // Return when loop completes, restore registers

init_array:
    // Initialize an array - Array size must be divisible by 32
    // Arguments: R0 = Memory location of array, R1 = Array length in bytes, R2 = Value
    PUSH    {R0-R12,LR}         // Push registers on to stack
    ADDS    R3,R0,R1            // R3 = Ending memory location
    MOV     R4,R0               // R4 = Current memory location
    MOV     R5,R2               // value to store
    MOV     R6,R2               // value to store
    MOV     R7,R2               // value to store
    MOV     R8,R2               // value to store
    MOV     R9,R2               // value to store
    MOV     R10,R2              // value to store
    MOV     R11,R2              // value to store
    MOV     R12,R2              // value to store
init_array_loop:
    STMIA   R4!,{R5-R12}        // Store 0 in the next 8 words of memory
    CMP     R4,R3               // Have we reached the end of the array?
    BNE     init_array_loop     // Loop again if current != end
    POP     {R0-R12,PC}         // Return when loop completes, restore registers

print_counts:
    // Prints a list of counts
    PUSH    {R0-R12,LR}         // Push the existing registers on to the stack
    BL      print_count_header  // Print header
    MOV     R0,#0               // Character value
    LDR     R4,=counts          // Starting memory location
    LDR     R5,=counts_end      // Ending memory location
print_counts_loop:
    LDR     R1,[R4],#4          // Load count and increment memory location
    CMP     R1,#0               // Did we have any matches?
    BLNE    print_count_line    // Print the count line if we had a match
    ADDS    R0,R0,#1            // Increment character number
    CMP     R4,R5               // Have we reached the end?
    BNE     print_counts_loop   // If not, loop again
    POP     {R0-R12,PC}         // Pop the registers off of the stack and return

print_count_header:
    PUSH    {R0-R12,LR}         // Push the existing registers on to the stack
    LDR     R0,=header          // Print header
    BL      puts                // |
    POP     {R0-R12,PC}         // Pop the registers off of the stack and return

print_count_line:
    // Arguments: Character in R0, Count in R1
    PUSH    {R0-R12,LR}         // Push the existing registers on to the stack
    MOV     R4,R0               // R4 = Character
    MOV     R5,R1               // R5 = Count
    LDR     R0,=line_part1      // Print the first part of the line
    BL      fputs               // |
    MOV     R0,R4               // Convert character to a string
    LDR     R1,=char_string     // | Write to the char_string memory location
    BL      itoa                // | Get string representation
    MOV     R0,R1               // Print the character string
    BL      fputs               // |
    LDR     R0,=line_part2      // Print the second part of the line
    BL      fputs               // |
    MOV     R0,R5               // Convert count to a string
    LDR     R1,=count_string    // | Write to the count_string memory location
    BL      itoa                // | Get string representation
    MOV     R0,R1               // Print the count string
    BL      puts                // |
    POP     {R0-R12,PC}         // Pop the registers off of the stack and return

print_sorted:
    // Prints a list of counts
    PUSH    {R0-R12,LR}         // Push the existing registers on to the stack
    BL      print_sorted_header // Print header
    LDR     R4,=sorted_chars    // Starting memory location
    ADDS    R5,R4,#1280         // Ending memory location
print_sorted_loop:
    LDRB    R0,[R4],#1          // Load character and increment memory location
    LDR     R1,[R4],#4          // Load count and increment memory location
    CMP     R0,#0xFF            // Is this value being used?
    BLNE    print_count_line    // If so, print the count line
    CMP     R4,R5               // Have we reached the end?
    BNE     print_sorted_loop   // If not, loop again
    POP     {R0-R12,PC}         // Pop the registers off of the stack and return

print_sorted_header:
    PUSH    {R0-R12,LR}         // Push the existing registers on to the stack
    LDR     R0,=sorted_header   // Print header
    BL      puts                // |
    POP     {R0-R12,PC}         // Pop the registers off of the stack and return

// Data Section
    
    .data

counts: .space 1024
counts_end: .word 0
// Each element in the sorted character array is 5 bytes: a 1 byte char and a 4 byte count 
sorted_chars: .space 1280
char: .word 0
buffer: .space 4096
count_string: .asciz "0000000000" // max 4294967296
char_string: .asciz "000" // max 256
status_s: .asciz "Counting Characters"
header: .asciz "Character Counts:"
line_part1: .asciz "\tCharacter: "
line_part2: .asciz "\tCount: "
sorted_header: .asciz "Sorted Characters:"
