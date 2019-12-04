/******************************************************************************
* file: assigment6-part3.s
* author: Basant Kumar
* Guide: Prof. Madhumutyam IITM, PACE
******************************************************************************/


@ BSS section
.bss

@ DATA SECTION
.data
//number of element of fibonacci
N: .word 0
//store nth fibonacci number
FIBONACCI_NUM: .word 0


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

  ldr r0, =N
  ldr r0, [r0]              //value of N
  sub sp, sp, r0, lsl #2
  bl FIBONACCI              //r0 contains Nth fibonacci number
  ldr r1, =FIBONACCI_NUM    //store nth fibonacci number at FIBONACCI_NUM
  str r0, [r1]
exit:
  SWI SWI_Exit

//Generate fibonacci series
.text
FIBONACCI:
  mov r1, #0
  mov r2, #1
loop:
  str lr,[sp],#4
  sub r0,r0,#1
  cmp r0, #1
  bgt f_cont
  sub sp,sp,#4
  b return
f_cont:
  bl loop
return:
  ldr lr,[sp],#-4
  add r0,r1,r2
  mov r1, r2
  mov r2, r0
  mov pc,lr


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