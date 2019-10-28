ARM Assembly Utility Methods
================================

This folder contains various utility methods written in ARM assembly language.
It doesn't require linking against any other code to function properly.
It does not use the standard C library.

Sorting Algorithms:
- Radix Sort
- Bubble Sort (broken)
- Quick Sort (broken)

Data Structures:
- Minimum Heap (Priority Queue)

Number Handling:
- itoa - integer to string
- div - division with remainder
- word_to_binary - word to binary string

String Handling:
- newline
- strlen
- puts
- fputs

File Functions:
- open_read - open a file for reading
- open_write - open a file for writing

Error Handling:
- check_read_error - check error codes from a read operation

Misc:
- Methods for counting characters in a file
- Methods for printing various debugging information

Linux System Calls:
- exit
- fork
- read
- write
- open
- close
- getpid
- getrandom
