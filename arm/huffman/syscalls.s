@@@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab: 
@@@ vim: ft=arm 

@@@ This file include Linux system calls
@@@ Reference: https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl
@@@ Reference: https: //github.com/torvalds/linux/blob/master/include/linux/syscalls.h
    
@@@ Exported Methods
    .global exit
    .global fork
    .global read
    .global write
    .global open
    .global close
    .global getpid
    .global getrandom

@@@ Code Section

exit:
    @@ Exit program
    @@ Arguments: R0 = Return code
    MOV     R7,#1               @ Syscall numbe, 1 = exit
    SWI     0                   @ Perform system call

fork:
    @@ Fork new process
    @@ Arguments: R0 = Pointer to a pt_regs struct
    PUSH    {R7,LR}             @ Push the existing registers on to the stack
    MOV     R7,#2               @ Syscall numbe, 2 = fork
    SWI     0                   @ Perform system call
    POP     {R7,PC}             @ Pop the registers off of the stack and return
    
read:
    @@ Read bytes from the given file handle
    @@ Arguments: R0 = File handle, R1 = Buffer, R2 = Bytes to Read
    PUSH    {R7,LR}             @ Push the existing registers on to the stack
    MOV     R7,#3               @ Syscall number: 3 is read()
    SWI     0                   @ Read from file handle
    POP     {R7,PC}             @ Pop the registers off of the stack and return

write:
    @@ Write bytes to the given file handle
    @@ Arguments: R0 = File handle, R1 = Buffer, R2 = Bytes to Write
    PUSH    {R7,LR}             @ Push the existing registers on to the stack
    MOV     R7,#4               @ Syscall number: 4 is write()
    SWI     0                   @ Write to file handle
    POP     {R7,PC}             @ Pop the registers off of the stack and return

open:
    @@ Opens a file
    @@ Arguments: 
    @@   R0 = Memory address of null terminated path string.
    @@   R1 = Flags
    @@   R2 = Mode
    PUSH    {R7,LR}             @ Push the existing registers on to the stack
    MOV     R7,#5               @ Syscall number: 5 is open()
    SWI     0                   @ Open file handle
    POP     {R7,PC}             @ Pop the registers off of the stack and return

close:
    @@ Closes a file
    @@ Arguments: R0 = File handle
    PUSH    {R7,LR}             @ Push the existing registers on to the stack
    MOV     R7,#6               @ Syscall number: 6 is close()
    SWI     0                   @ Close file handle
    POP     {R7,PC}             @ Pop the registers off of the stack and return

getpid:
    @@ Returns the current process id
    PUSH    {R7,LR}             @ Push the existing registers on to the stack
    MOV     R7,#20              @ Syscall number: 20 is getpid()
    SWI     0                   @ Close file handle
    POP     {R7,PC}             @ Pop the registers off of the stack and return

getrandom:
    @@ Gets random bytes from /dev/urandom
    @@ Arguments: R0 = Memory location of buffer
    @@            R1 = Number of bytes to read
    @@            R2 = Flags (GRND_RANDOM and/or GRND_NONBLOCK)
    @@                  GRND_NONBLOCK (1) - Return -1 if entropy pool is not yet initialized
    @@                  GRND_RANDOM (2) - Use /dev/random instead of /dev/urandom
    PUSH    {R7,LR}             @ Push the existing registers on to the stack
    MOV     R7,#384             @ Syscall number: 384 is getrandom()
    SWI     0                   @ Close file handle
    POP     {R7,PC}             @ Pop the registers off of the stack and return
