.section	.text

.global find_Button, initialize_GPIO, Read_SNES

// Returns number to r0 corresponding to button pressed
// 0 = B, 1 = Y, 2 = Select, 3 = Start, 4 = Joy_Up, 5 = Joy_Down
// 6 = Joy_Left, 7 = Joy_Right, 8 = A, 9 = X, 10 = Left, 11 = Right
find_Button:
	push	{r4, r5, r6, fp, lr}	

read_input:					// read SNES input until button pressed
	bl	Read_SNES
	mov	r5, #0xffff
	cmp	r0, r5
	beq	read_input
	
	mov	r6, #0				// index of button

find_pressed:					// find pressed button
	lsrs	r0, #1				// lsr until 0 found
	blo	continue
	add	r6, #1				// increment index by 1 and re-loop
	b	find_pressed

continue:					// wait for user to release button
	bl	Read_SNES

return_button:
	mov	r0, r6
	pop	{r4, r5, r6, fp, pc}



initialize_GPIO:
	push	{r4, r5, r6, fp, lr}	

	bl	getGpioPtr			// get GPIO address pointer and store for later		
	ldr	r1, =gpioBaseAddress
	str	r0, [r1]

	mov	r0, #11				// initiate clock
	mov	r1, #0b001
	bl	Init_GPIO
		
	mov	r0, #9				// initiate latch
	mov	r1, #0b001
	bl	Init_GPIO

	mov	r0, #10				// initiate data
	mov	r1, #0b000
	bl	Init_GPIO

	pop	{r4, r5, r6, fp, pc}

// SUBROUTINES
// r0 = line number, r1 = function code
// void function, initializes GPIO
Init_GPIO:
	push	{r4, r5, r6, fp, lr}
	mov	r4, r1
	mov	r1, #0
	ldr	r6, =gpioBaseAddress
	ldr	r6, [r6]

	b	Init_end

Init_loop:					// use to find line number div 10 and line number mod 10 
	sub	r0, #10				// r0 = n mod 10
	add	r1, #1				// r1 = n div 10

Init_end:
	cmp	r0, #10
	bge	Init_loop

	ldr	r3, [r6, r1, LSL #2]		// load address of GPIO with offset
	
	mov	r5, #3
	mul	r0, r5				// r1*3 = first bit for pin
	mov	r2, #0b111			// use r2 to bitclear

	bic	r3, r2, LSL r0
	orr	r3, r4, LSL r0			// set function code

	str	r3, [r6, r1, LSL #2]

	pop	{r4, r5, r6, fp, pc}


// r0 = 0 (clear) or 1 (write)
// clear or write latch
Write_Latch:
	mov	fp, sp
	ldr	r1, =gpioBaseAddress		// load GPIO base address
	ldr	r1, [r1]
	mov	r2, #9				// pin 9 = latch line
	mov	r3, #1				// need to write 1 to GPCLR0 or GPSET0
	lsl	r3, r2
	teq	r0, #0				// clear if r0 = 0, else write
	streq	r3, [r1, #40]			// GPCLR0
	strne	r3, [r1, #28]			// GPSET0
	mov	pc, lr

// r0 = 0 (clear) or 1 (write)
// clear or write clock
Write_Clock:
	mov	fp, sp
	ldr	r1, =gpioBaseAddress		// load GPIO base address
	ldr	r1, [r1]
	mov	r2, #11				// pin 11 = latch line
	mov	r3, #1				// need to write 1 to GPCLR0 or GPSET0
	lsl	r3, r2				// align bit for pin 11
	teq	r0, #0				// clear if r0 = 0, else write
	streq	r3, [r1, #40]			// GPCLR0
	strne	r3, [r1, #28]			// GPSET0
	mov	pc, lr

// reads input from pin 10 data line
Read_Data:
	mov	fp, sp
	ldr	r0, =gpioBaseAddress		// load GPIO base address
	ldr	r0, [r0]
	ldr	r1, [r0, #52]			// GPLEV0
	mov	r2, #10				// pin 10 = data line
	mov	r3, #1
	lsl	r3, r2				// shift 1 for pin 10
	and	r1, r3				// mask everything
	teq	r1, #0
	moveq	r0, #0			// if r1 = 0, return 0 to r0
	movne	r0, #1			// else return 1 to r0
	mov	pc, lr


// reads SNES controller input
Read_SNES:
	push	{r4, r5, fp, lr}

	mov	r0, #1				// write clock
	bl	Write_Clock

	mov	r0, #1				// write latch
	bl	Write_Latch

	mov	r0, #12				// delay by 12ms
	bl	delayMicroseconds

	mov	r0, #0				// clear latch
	bl	Write_Latch

	mov	r4, #0				// initialize i = 0 for loop
	mov	r5, #0				// r5 = 16 bit buttons number
	b	pulseCheck

pulseLoop:					// run pulse loop 16 times
	mov	r0, #6				// delay by 6ms
	bl	delayMicroseconds

	mov	r0, #0				// clear clock
	bl	Write_Clock

	mov	r0, #6				// delay by 6ms
	bl	delayMicroseconds

	bl	Read_Data			// read input and add to 16 bit string after LSL
	lsl	r0, r4				// lsl data by 1
	orr	r5, r0

	mov	r0, #1				// write to clock
	bl	Write_Clock

	add	r4, #1	

pulseCheck:
	cmp	r4, #16				// do pulseLoop 16 times
	bne	pulseLoop

return:						// return 16 bit buttons number to r0
	mov	r0, r5
	pop	{r4, r5, fp, pc}

@ Data section
.section .data


.align	2
.global gpioBaseAddress
gpioBaseAddress:
	.int	0
