@@@ Helper methods for error checking
@@@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab: 
@@@ vim: ft=arm 

@@@ External procedures
    .global puts
    .global newline

@@@ Exported procedures
    .global check_read_error

@@@ Code Section
    
check_read_error:
    PUSH    {R0,R1,LR}
    MOV     R1,R0
    MOV     R0,#0
    CMP     R1,#-4              @ Check for interrupted system call
    LDREQ   R0,=eintr
    CMP     R1,#-5              @ Check for IO error
    LDREQ   R0,=eio   
    CMP     R1,#-9              @ Check for bad file descriptor
    LDREQ   R0,=ebadf
    CMP     R1,#-11             @ Check for try again
    LDREQ   R0,=efault
    CMP     R1,#-14             @ Check for bad address
    LDREQ   R0,=eagain
    CMP     R1,#-21             @ Check for a directory
    LDREQ   R0,=eisdir
    CMP     R1,#-22             @ Check for invalid
    LDREQ   R0,=einval
    CMP     R0,#0               @ If we have a message to print, then print it
    BLNE    puts         
    POP     {R0,R1,PC}

@@@ Data Section
    
.data

@@@ Error Codes
eintr:  .asciz "[ERROR] Interrupted System Call: The call was interrupted by a signal before any data was read."
eio:    .asciz "[ERROR] I/O Error"
ebadf:  .asciz "[ERROR] Bad File Number: Not a valid file descriptor"
eagain: .asciz "[ERROR] Try Again: Read would block but file is marked non-blocking"
efault: .asciz "[ERROR] Bad Address: Buffer is outside your addressible address space"
eisdir: .asciz "[ERROR] Trying to Read From a Directory Instead of a File"
einval: .asciz "[ERROR] Invalid Argument: Could not read file"

