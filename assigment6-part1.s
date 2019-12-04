/******************************************************************************
* file: assigment6-part1.s
* author: Basant Kumar
* Guide: Prof. Madhumutyam IITM, PACE
******************************************************************************/


@ BSS section
.bss

@ DATA SECTION
.data
//Output
OUTPUT: .word -1

//number of element in array
N: .word 0
//search element in array
SEARCH: .word 0
//64bit temp to take input and convert to BCD and store in list
TEMP: .word 0, 0, 0
//array
LIST: .word


@ TEXT section
.text

.globl _main

.equ SWI_Open, 0x66         // open a file
.equ SWI_Close,0x68         // close a file
.equ SWI_PrChr,0x00         // Write 1 byte to file handle
.equ SWI_RdBytes, 0x6a      // Read n bytes from file handle
.equ SWI_WrBytes, 0x69      // Write n bytes to file handle
.equ Stdin, 0               // 0 is the file descriptor for STDIN
.equ Stdout, 1              // Set output target to be Stdout
.equ SWI_Exit, 0x11         // Stop execution

_main:
  mov R0,#Stdin             // read from STDIN
  ldr R1, =N                // load address of the buffer to read bytes
  mov R2,#4                 // read 4 bytes
  swi SWI_RdBytes           // invoke system call
  bl ASSCI2INT

// enter array elements
  ldr r6, [r1]
  ldr r1, =TEMP
  ldr r3, =LIST
input_element:
  mov R0,#Stdin
  str r0, [r1]
  mov R2,#8
  swi SWI_RdBytes
  bl ASSCI2INT
  ldr r0, [r1]
  str r0, [r3]
  add r3, r3, #4
  sub r6, r6, #1
  cmp r6, #0
  bgt input_element

// enter search element
  ldr r6, [r1]
  ldr r1, =TEMP
  ldr r3, =SEARCH
  mov R0,#Stdin
  str r0, [r1]
  mov R2,#8
  swi SWI_RdBytes
  bl ASSCI2INT
  ldr r0, [r1]
  str r0, [r3]

//serach in array
  ldr r0, =LIST     //array base address as 1st arg
  ldr r1, =N
  ldr r1, [r1]      //size of array as 2nd arg
  ldr r2, =SEARCH
  ldr r2, [r2]      //search element as 3rd arg
  bl SEARCH_ARRAY   //return output in r0
  ldr r1, =OUTPUT
  str r0, [r1]      //store result in OUTPUT
exit:
  SWI SWI_Exit

// In worst case linear search take N iteration to search a element in array
.text
SEARCH_ARRAY:
  STMFD SP!,{LR}
  mov r3, #0       //counter init
loop:
  ldr r4, [r0, r3, lsl #2]
  cmp r4, r2
  add r3, r3, #1
  beq found
  cmp r3, r1
  ble loop
  mvn r3, #0

found:
  mov r0, r3
  LDMFD SP!,{PC}


.text
ASSCI2INT:
  STMFD SP!,{r3, LR}
  mov r0, #0          //counter for 4byte processing
  mov r3, #0          //bcd converted number init
  ldrb r2, [r1]

compare:
  cmp r2, #0
  beq store
  cmp r2, #'0'         //boundary check for digit greater than zero
  bmi error
  cmp r2, #'9'         //boundary check for digit samller than nine
  bgt error
  sub r2, r2, #'0'     //r2 = r2 - 0
  mov r5, r3
  lsl r3, r3, #2         //multiply by 10*x = 2*(2^2*x+x)
  add r3, r3, r5         //2^2*x+x
  lsl r3, r3, #1         //2*(2^2*x+x)
  add r3, r3, r2         // 10*prev + curr

next:
  cmp r0, #8              //check string termination
  add r0, r0, #1
  ldrb r2, [r1, r0]        //read next
  ble compare             //if not equal jump to level:compare for next character comparision

store:
  str r3, [r1]          //store bcd in TEMP
  LDMFD SP!,{r3, PC}

error: // for wrong input terminate program
  SWI SWI_Exit

.end