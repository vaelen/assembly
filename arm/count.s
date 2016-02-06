@ Syscall 4 to write a string 
@ vim: set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab: 
@ vim: ft=arm 

.global _start

_start:
    LDR     R0,=status          @ Print status
    BL      print_string        @ |
    LDR     R0,=newline         @ Print a newline character
    BL      print_string        @ |
    BL      init_counts         @ Initialize memory
    LDR     R0,=input           @ Read from the input location
    BL      count_characters    @ Count characters
    BL      print_counts        @ Print counts
    B       exit                @ exit

count_characters:
    @ Counts the characters in the null terminated string
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    LDR     R4,=counts          @ R4 = Address of the count array
    SUBS    R1,R0,#1            @ R1 = One byte before the first memory location
  count_loop:
    ADDS    R1,R1,#1            @ R1 = Current memory location
    LDRB    R2,[R1]             @ R2 = Current byte
    LDR     R3,[R4,R2,LSL #2]   @ R3 = Current count (R4 + (R2*4))
    ADDS    R3,#1               @ Increment the count
    STR     R3,[R4,R2,LSL #2]   @ Store the count back into the array
    CMP     R2,#0               @ Check for null
    BNE     count_loop          @ Loop if not null
    POP     {R0-R12,PC}         @ Return when loop completes, restore registers

init_counts:
    @ Initialize the memory used for counting
    PUSH    {R0-R12,LR}         @ Push registers on to stack
    MOV     R0,#0               @ value to store
    MOV     R1,#0               @ value to store
    MOV     R2,#0               @ value to store
    MOV     R3,#0               @ value to store
    MOV     R4,#0               @ value to store
    MOV     R5,#0               @ value to store
    MOV     R6,#0               @ value to store
    MOV     R7,#0               @ value to store
    LDR     R11,=counts         @ Starting memory location
    LDR     R12,=counts_end     @ Ending memory location
  init_counts_loop:
    STMIA   R11!,{R0-R7}        @ Store 0 in the next 8 words of memory
    CMP     R11,R12
    BNE     init_counts_loop    @ Loop again if current != end
    POP     {R0-R12,PC}         @ Return when loop completes, restore registers

print_counts:
    @ Prints a list of counts
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    BL      print_count_header  @ Print header
    MOV     R0,#0               @ Character value
    LDR     R4,=counts          @ Starting memory location
    LDR     R5,=counts_end      @ Ending memory location
  print_counts_loop:
    LDR     R1,[R4],#4          @ Load count and increment memory location
    CMP     R1,#0               @ Did we have any matches?
    BLNE    print_count_line    @ Print the count line if we had a match
    ADDS    R0,R0,#1            @ Increment character number
    CMP     R4,R5               @ Have we reached the end?
    BNE     print_counts_loop   @ If not, loop again
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return

print_count_header:
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    LDR     R0,=header          @ Print header
    BL      print_string        @ |
    LDR     R0,=newline         @ Print a newline character
    BL      print_string        @ |
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return

print_count_line:
    @ Arguments: Character in R0, Count in R1
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    MOV     R4,R0               @ R4 = Character
    MOV     R5,R1               @ R5 = Count
    LDR     R0,=line_part1      @ Print the first part of the line
    BL      print_string        @ |
    MOV     R0,R4               @ Convert character to a string
    LDR     R1,=char_string     @ | Write to the char_string memory location
    BL      integer_to_string   @ | Get string representation
    MOV     R0,R1               @ Print the character string
    BL      print_string        @ |
    LDR     R0,=line_part2      @ Print the second part of the line
    BL      print_string        @ |
    MOV     R0,R5               @ Convert count to a string
    LDR     R1,=count_string    @ | Write to the count_string memory location
    BL      integer_to_string   @ | Get string representation
    MOV     R0,R1               @ Print the count string
    BL      print_string        @ |
    LDR     R0,=newline         @ Print a newline character
    BL      print_string        @ |
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return

integer_to_string:
    @ Converts an integer to a string
    @ Arguments: integer in R0, memory address in R1
    @ This works by using recursion
    @ It builds the value backwards on the stack then pops it off in the right order
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    MOV     R4,R1               @ Store the memory address in R4
    BL      i_to_s_helper       @ Recurse
    MOV     R6,#0               @ R6 = null terminator
    STREQB  R6,[R4]             @ Add a null terminator
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return

i_to_s_helper:
    @ Arguments: integer in R0, memory address in R4
    @ R
    PUSH    {R5,LR}             @ Push the registers on to the stack
    MOV     R1,#10              @ We will divide R0 by 10
    BL      divide              @ Divide R0 by R1 and return remainder in R0
    MOV     R5,R0               @ Put the remainder in R5
    MOV     R0,R2               @ Move the quotient into R0 for the next iteration
    CMP     R0,#0               @ Is this the end of the string?
    BLNE    i_to_s_helper       @ If not, recurse 
    ADD     R6,R5,#48           @ Add 48 to the remainder to get an ASCII character
    STRB    R6,[R4],#1          @ Store the byte into memory and increment the memory location
    POP     {R5,PC}             @ Pop the registers off of the stack and return

divide:
    @ Divides R0 by R1
    @ Returns the quotient in R2, and the remainder in R0
    PUSH    {R4-R12,LR}         @ Push the existing registers on to the stack
    MOV     R4,R1               @ Put the divisor in R4
    CMP     R4,R0,LSR #1        @ Compare the divisor (R0) with 2xR4
  divide_loop1:
    MOVLS   R4,R4,LSL #1        @ Double R4 if 2xR4 < divisor (R0)
    CMP     R4,R0,LSR #1        @ Compare the divisor (R0) with 2xR4
    BLS     divide_loop1        @ Looop if 2xR4 < divisor (R0)
    MOV     R2,#0               @ Initialize the quotient
  divide_loop2:
    CMP     R0,R4               @ Can we subtract R4?
    SUBCS   R0,R0,R4            @ If we can, then do so
    ADC     R2,R2,R2            @ Double the quotient, add new bit
    MOV     R4,R4,LSR #1        @ Divide R4 by 2
    CMP     R4,R1               @ Check if we've gone past the original divisor
    BHS     divide_loop2        @ If not, loop again
    POP     {R4-R12,PC}         @ Pop the registers off of the stack and return

print_string:
    @ Print the null terminated string at R0
    PUSH    {R0-R12,LR}         @ Push the existing registers on to the stack
    BL      strlen              @ Get the length of the string
    MOV     R2,R1               @ String length is in R1
    MOV     R1,R0               @ String starts at R0
    MOV     R0,#1               @ Write to STDOUT
    MOV     R7,#4               @ Syscall number
    SWI     0                   @ Perform system call
    POP     {R0-R12,PC}         @ Pop the registers off of the stack and return

strlen:
    @ Finds the length of the string at address R0
    @ Returns the length in R1
    PUSH    {R2,LR}             @ Push the existing registers on to the stack
    SUBS    R1,R0,#1            @ R1 = One byte before the first memory location
  strlen_loop:
    ADDS    R1,R1,#1            @ R1 = Current memory location
    LDRB    R2,[R1]             @ R2 = Current byte
    CMP     R2,#0               @ Check for null
    BNE     strlen_loop         @ Loop if not null
    SUBS    R1,R1,R0            @ R1 = Length of string
    POP     {R2,PC}             @ Pop the registers off of the stack and return
    

exit:
    MOV     R0,#0               @ Return code, 0 = success
    MOV     R7,#1               @ Syscall numbe, 1 = exit
    SWI     0                   @ Perform system call

.data

counts: .space 1024
counts_end: .word 0
count_string: .asciz "0000000000" @ max 4294967296
char_string: .asciz "000" @ max 256
newline: .asciz "\n"
status: .asciz "Counting Characters"
header: .asciz "Character Counts:"
line_part1: .asciz "\tCharacter: "
line_part2: .asciz "\tCount: "
input: .asciz "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec turpis tortor, euismod id lectus ut, rutrum vulputate odio. Donec dignissim nulla arcu, sagittis maximus mi facilisis fermentum. Vestibulum ut metus aliquet, imperdiet enim non, pharetra magna. Vestibulum at semper nibh. Interdum et malesuada fames ac ante ipsum primis in faucibus. Sed euismod diam at lorem tempor, ut porta metus maximus. Mauris at purus luctus, lobortis dolor vitae, convallis libero. Etiam tempor suscipit quam ac facilisis. Aenean mattis semper ipsum fermentum rutrum. Nunc suscipit scelerisque lacus, sed viverra neque aliquam et. Pellentesque metus ante, vehicula viverra blandit at, rutrum sed massa. Cras ut egestas lorem. Etiam pretium suscipit enim, ac suscipit lorem pharetra eget. Cras placerat semper consectetur.\n\nMaecenas luctus tellus ut tellus gravida sodales. Maecenas lobortis sem vitae rutrum pretium. Phasellus efficitur sapien felis, eu imperdiet augue lobortis sit amet. Integer purus odio, dapibus in est quis, posuere elementum felis. Nulla posuere, nibh sed scelerisque lobortis, est leo viverra libero, rhoncus cursus tellus orci nec libero. Morbi mattis urna dui, vel accumsan nunc sollicitudin id. Aenean consequat metus ut felis rutrum volutpat. Nulla a sollicitudin mi, eget volutpat nulla. Pellentesque gravida lacus odio, eu tempus quam imperdiet id. Integer tincidunt elementum tortor, sit amet cursus mi. Mauris augue diam, maximus viverra semper in, sagittis quis nunc. Fusce suscipit nec ex eget volutpat. Nunc laoreet ante vitae justo elementum commodo. Integer nec faucibus sapien. Duis vitae tempus tellus. Duis mollis consectetur laoreet.\n\nDuis fringilla in sapien non interdum. Integer arcu mi, semper at ornare ac, efficitur ut mi. Nunc pulvinar ultricies est, nec auctor urna vestibulum nec. Maecenas varius odio nisl, eu vulputate nibh pulvinar nec. Vestibulum a leo elit. Aenean ac varius velit. Integer eleifend convallis varius. In urna nisl, imperdiet quis sollicitudin nec, dapibus sit amet sem. Praesent mattis quis orci id vulputate. Nam odio neque, finibus non accumsan ac, commodo in nisl. Cras vulputate metus eget metus accumsan, et venenatis mauris luctus. Aenean et metus ut est dignissim maximus. Sed lacinia tellus ut nibh venenatis rhoncus. Pellentesque finibus, sem quis ultricies mattis, nisi dui varius risus, ut porttitor sapien metus egestas nunc.\n\nSuspendisse neque dui, convallis facilisis accumsan et, lobortis non nibh. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Cras pretium mi non leo vestibulum molestie. Etiam sit amet sapien odio. Etiam non libero et tortor posuere faucibus. Fusce eget est malesuada, vehicula sem nec, scelerisque dui. Sed non turpis ut felis consequat varius vel ut erat. Aliquam a porta purus, in aliquet nisl. Curabitur auctor quis neque ut blandit. Curabitur ut ex aliquam, viverra mauris at, varius lacus. In hac habitasse platea dictumst. Nulla lacus quam, efficitur commodo dapibus a, sodales rutrum quam. Phasellus sit amet sagittis urna, quis volutpat nunc. Vestibulum malesuada nibh odio, quis tincidunt augue ullamcorper a. Proin lobortis dictum ex non iaculis. Proin mauris nulla, malesuada vel erat ultrices, dictum elementum est.\n\nEtiam laoreet lorem ac ligula feugiat tincidunt. Cras vel massa molestie, sollicitudin urna sit amet, mollis odio. Nullam ac urna ex. Curabitur sodales diam eu ipsum molestie, id finibus elit interdum. Etiam vitae nulla turpis. Interdum et malesuada fames ac ante ipsum primis in faucibus. Nullam ut congue est, vitae rhoncus arcu. Pellentesque pellentesque rutrum ornare. Praesent a mollis orci. Aenean et ante urna. Aenean nibh quam, imperdiet non rutrum placerat, accumsan non ex."
