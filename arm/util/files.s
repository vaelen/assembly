@@@ File Related Methods
@@@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab: 
@@@ vim: ft=arm 

@@@ External Methods
    .global read
    .global write
    .global open
    .global close

@@@ Exported Functions 
    .global open_read
    .global open_write

@@@ Code Section

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
