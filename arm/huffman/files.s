@@@ File Related Methods
@@@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab: 
@@@ vim: ft=arm 

@@@ Exported Functions
    .global read
    .global write
    .global open
    .global close
    .global open_read
    .global open_write

@@@ Code Section

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
    MOV     R7,#3               @ Syscall number: 4 is write()
    SWI     0                   @ Write to file handle
    POP     {R7,PC}             @ Pop the registers off of the stack and return

open_read:
    @@ Opens a file for reading
    @@ Arguments: R0 = Memory address of null termianted path string
    PUSH    {R1,R2,LR}          @ Push the existing registers on to the stack
    MOV     R1,#0               @ Read Only Flag
    MOV     R2,#0               @ Mode (Ignored)
    BL      open                @ Open the file
    POP     {R1,R2,PC}          @ Pop the registers off of the stack and return

open_write:
    @@ Opens a file for writing
    @@ Arguments: R0 = Memory address of null termianted path string
    PUSH    {R1,R2,LR}          @ Push the existing registers on to the stack
    MOV     R1,#1               @ Write Only Flag
    MOV     R2,#0               @ Mode (Use Default)
    BL      open                @ Open the file
    POP     {R1,R2,PC}          @ Pop the registers off of the stack and return

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
