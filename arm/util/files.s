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

// File Related Methods

// External Methods
    .global read
    .global write
    .global open
    .global close

// Exported Functions 
    .global open_read
    .global open_write

// Code Section

open_read:
    // Opens a file for reading
    // Arguments: R0 = Memory address of null termianted path string
    PUSH    {R1,R2,LR}          // Push the existing registers on to the stack
    MOV     R1,#0               // Read Only Flag
    MOV     R2,#0               // Mode (Ignored)
    BL      open                // Open the file
    POP     {R1,R2,PC}          // Pop the registers off of the stack and return

open_write:
    // Opens a file for writing
    // Arguments: R0 = Memory address of null termianted path string
    PUSH    {R1,R2,LR}          // Push the existing registers on to the stack
    MOV     R1,#1               // Write Only Flag
    MOV     R2,#0               // Mode (Use Default)
    BL      open                // Open the file
    POP     {R1,R2,PC}          // Pop the registers off of the stack and return
