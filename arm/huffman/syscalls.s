
@ Count characters from STDIN
@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab: 
@ vim: ft=arm 

@ Exported Methods
.global exit

exit:
    @ Exit program with return code from R0
    MOV     R7,#1               @ Syscall numbe, 1 = exit
    SWI     0                   @ Perform system call
