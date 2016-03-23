@ Count characters from STDIN
@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab: 
@ vim: ft=arm 

@ External Methods
.global status
.global init_counts
.global count_from_file
.global print_counts
.global sorted
.global print_sorted
.global sort_chars
.global print_sorted
.global open_read
.global check_read_error
.global exit

@ Exported Methods
.global _start

_start:
    BL      status              @ Print status
    BL      init_counts         @ Initialize memory
    LDR     R0, =path           @ Set file path
    BL      open_read           @ Open file for reading
    BL      check_read_error    @ Check for errors
    MOV     R4, R0              @ R4 = File Handle (Also still in R0)
    BL      count_from_file     @ Count characters from file handle
    BL      print_counts        @ Print counts
@    BL      init_sorted         @ Initialize memory
@    BL      sort_chars          @ Sort characters
@    BL      print_sorted        @ Print sorted characters
    MOV     R0, R4              @ Set file handle to close
    BL      close               @ Close file
    MOV     R0, #0              @ Normal return code
    B       exit                @ exit

.data

path: .asciz "test-count.txt"
