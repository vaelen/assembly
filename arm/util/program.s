@@@ Count characters from STDIN
@@@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab: 
@@@ vim: ft=arm 

@@@ External Methods
    .global status
    .global init_counts
    .global count_from_file
    .global print_counts
    .global exit

@@@ Exported Methods
    .global _start

@@@ Code Section
    
_start:
    BL      status              @ Print status
    BL      init_counts         @ Initialize memory
    MOV     R0, #0              @ Set file handle to STDIN
    BL      count_from_file     @ Count characters from file handle
    BL      print_counts        @ Print counts
    BL      init_sorted_chars   @ Initialize memory
    BL      sort_chars          @ Sort characters
    BL      print_sorted        @ Print sorted characters
    MOV     R0, #0              @ Normal return code
    B       exit                @ exit
