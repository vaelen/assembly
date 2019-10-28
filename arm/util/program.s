/*
    Copyright 2019, Andrew C. Young <andrew@vaelen.org>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

// Count characters from STDIN

// External Methods
    .global status
    .global init_counts
    .global count_from_file
    .global print_counts
    .global exit

// Exported Methods
    .global _start

// Code Section
    
_start:
    BL      status              // Print status
    BL      init_counts         // Initialize memory
    MOV     R0, #0              // Set file handle to STDIN
    BL      count_from_file     // Count characters from file handle
    BL      print_counts        // Print counts
    BL      init_sorted_chars   // Initialize memory
    BL      sort_chars          // Sort characters
    BL      print_sorted        // Print sorted characters
    MOV     R0, #0              // Normal return code
    B       exit                // exit
