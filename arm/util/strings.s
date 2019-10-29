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

// Helper functions related to string manipulation

// External Methods
    .global itoa
    .global write

// Exported Methods
    .global newline
    .global print_registers
    .global print_r0
    .global print_r0_binary
    .global print_memory_binary
    .global strlen
    .global strcmp
    .global fputs
    .global puts
    .global int_string

// Code Section
    
newline:
    // Print a newline character
    PUSH    {R0,LR}
    LDR     R0,=newline_s
    BL      fputs 
    POP     {R0,PC}

print_registers:
    PUSH    {R0-R12,LR}         // Push the existing registers on to the stack
    BL      print_r0
    MOV     R0,R1
    BL      print_r0
    MOV     R0,R2
    BL      print_r0
    MOV     R0,R3
    BL      print_r0
    MOV     R0,R4
    BL      print_r0
    MOV     R0,R5
    BL      print_r0
    MOV     R0,R6
    BL      print_r0
    MOV     R0,R7
    BL      print_r0
    MOV     R0,R8
    BL      print_r0
    MOV     R0,R9
    BL      print_r0
    MOV     R0,R10
    BL      print_r0
    MOV     R0,R11
    BL      print_r0
    MOV     R0,R12
    BL      print_r0
    POP     {R0-R12,PC}         // Return when loop completes, restore registers

print_r0:
    PUSH    {R0,R1,LR}          // Push the existing registers on to the stack
    LDR     R1,=int_string      // | Write to the int_string memory location
    BL      itoa                // | Get string representation
    MOV     R0,R1               // Print the character string
    BL      fputs               // |
	LDR     R0,=space_s         // Print a space
	BL      fputs               // |
    POP     {R0,R1,PC}          // Return when loop completes, restore registers

print_r0_binary:
    PUSH    {R0,R1,LR}          // Push existing registers on to the stack
    LDR     R1,=binary_string   // Memory location of the string to print
    BL      word_to_binary      // Convert R0 to binary
    MOV     R0,R1               // Print the string
    BL      puts                
    POP     {R0,R1,PC}          // Return

print_memory_binary:
    // Prints a section of memory in binary
    // Arguments: R0 = memory start location, R1 = memory end location
    CMP     R0,R1               // Check for valid input values
    BXGT    LR                  // If R0 is greater than R1, return
    PUSH    {R0-R3,LR}          // Push existing registers on to the stack
    MOV     R2,R0               // R2 = Current memory location
    MOV     R3,R1               // R3 = Last memory location
    LDR     R1,=binary_string   // Memory location of the string to print
pmb_loop:
    LDR     R0,[R2]             // Load word of memory into R0
    BL      word_to_binary      // Convert R0 to binary
    MOV     R0,R1               // Print the string
    BL      puts                
    ADD     R2,#4               // Increment the memory location
    CMP     R2,R3               // Are we done?
    BLE     pmb_loop            // If not, loop
pmb_done:   
    POP     {R0-R3,PC}          // Return
    
puts:
    // Print the null terminated string at R0, followed by a newline
    PUSH    {R0,LR}             // Push the existing registers on to the stack
    BL      fputs               // Print the null terminated string at R0
    BL      newline             // Print a newline character
    POP     {R0,PC}             // Return when loop completes, restore registers
                
fputs:
    // Print the null terminated string at R0
    PUSH    {R0-R3,LR}         // Push the existing registers on to the stack
    BL      strlen              // Get the length of the string
    MOV     R2,R1               // String length is in R1
    MOV     R1,R0               // String starts at R0
    MOV     R0,#1               // Write to STDOUT
    BL      write               // Call write system call
    POP     {R0-R3,PC}         // Pop the registers off of the stack and return
    
strlen:
    // Finds the length of the string at address R0
    // Returns the length in R1 (TODO: This should be R0)
    PUSH    {R2,LR}             // Push the existing registers on to the stack
    SUBS    R1,R0,#1            // R1 = One byte before the first memory location
strlen_loop:
    ADDS    R1,R1,#1            // R1 = Current memory location
    LDRB    R2,[R1]             // R2 = Current byte
    CMP     R2,#0               // Check for null
    BNE     strlen_loop         // Loop if not null
    SUBS    R1,R1,R0            // R1 = Length of string
    POP     {R2,PC}             // Pop the registers off of the stack and return

strcmp:
    // Compares two strings
    PUSH    {R2-R3,LR}
strcmp_loop:
    LDRB    R2,[R0]             // Load next byte of string at R0
    LDRB    R3,[R1]             // Load next byte of string at R1
    CMP     R2,R3               // Compare bytes
    BLT     strcmp_lt
    BGT     strcmp_gt
    CMP     R2, #0              // If they are equal and both 0, return 0
    MOVEQ   R0, #0
    BEQ     strcmp_done
    ADDS    R0,R0,#1	        // Check the next byte
    ADDS    R1,R1,#1
    B       strcmp_loop
strcmp_lt:
    MOV     R0, #-1             // If the first string is less, return -1
    B       strcmp_done
strcmp_gt:
    MOV     R0, #1              // If the first string is more, return 1
strcmp_done:
    POP     {R2-R3,PC}
    
// Data Section
    
    .data

binary_string:   .asciz "00000000000000000000000000000000" // one word (4 bytes)
int_string: .asciz "0000000000" // max 4294967296
newline_s:  .asciz "\n"
space_s:    .asciz " "
