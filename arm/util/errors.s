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

// Helper methods for error checking

// External procedures
    .global puts
    .global newline

// Exported procedures
    .global check_read_error

// Code Section
    
check_read_error:
    PUSH    {R0,R1,LR}
    MOV     R1,R0
    MOV     R0,#0
    CMP     R1,#-4              // Check for interrupted system call
    LDREQ   R0,=eintr
    CMP     R1,#-5              // Check for IO error
    LDREQ   R0,=eio   
    CMP     R1,#-9              // Check for bad file descriptor
    LDREQ   R0,=ebadf
    CMP     R1,#-11             // Check for try again
    LDREQ   R0,=efault
    CMP     R1,#-14             // Check for bad address
    LDREQ   R0,=eagain
    CMP     R1,#-21             // Check for a directory
    LDREQ   R0,=eisdir
    CMP     R1,#-22             // Check for invalid
    LDREQ   R0,=einval
    CMP     R0,#0               // If we have a message to print, then print it
    BLNE    puts         
    POP     {R0,R1,PC}

// Data Section
    
.data

// Error Codes
eintr:  .asciz "[ERROR] Interrupted System Call: The call was interrupted by a signal before any data was read."
eio:    .asciz "[ERROR] I/O Error"
ebadf:  .asciz "[ERROR] Bad File Number: Not a valid file descriptor"
eagain: .asciz "[ERROR] Try Again: Read would block but file is marked non-blocking"
efault: .asciz "[ERROR] Bad Address: Buffer is outside your addressible address space"
eisdir: .asciz "[ERROR] Trying to Read From a Directory Instead of a File"
einval: .asciz "[ERROR] Invalid Argument: Could not read file"

