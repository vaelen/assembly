@ File Related Methods
@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab: 
@ vim: ft=arm 

@ Exported Functions
.global read

read:
    @ Read bytes from the given file handle
    @ Arguments: R0 = File handle, R1 = Buffer, R2 = Bytes to Read
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    MOV     R7,#3               @ Syscall number: 3 is read()
    SWI     0                   @ Read from file handle
