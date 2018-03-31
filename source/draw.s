

@ Code section
.section .text

.global drawImg, DrawPixel, draw_Char, draw_Score_Char, quit_game

draw_Score_Char:
	mov 	fp, sp	
	push	{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	
	//score is in r0
	//r4 is the 10th place value: the increment value
	//r5 is the first digit: the remainder
	mov		r4, #0
	mov		r5, r0
remainder:
	cmp		r5, #9
	subgt	r5, #10
	addgt	r4, #1
	bgt		remainder

	
	@erase previous characters
	mov		r0, r5
	sub		r0, #1
	mov		r1, #648
	mov		r2, #0x0
	bl		draw_Char
	
	mov		r0, r4
	sub		r0, #1
	mov		r1, #640
	mov		r2, #0x0
	bl		draw_Char
	
	@update
	mov		r0, r5
	//add		r0, #1
	mov		r1, #648
	mov		r2, #0x00FF0000
	bl		draw_Char
	
	
	mov		r0, r4
	//add		r0, #1
	mov		r1, #640
	mov		r2, #0x00FF0000
	bl		draw_Char
	
	
	pop		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov		pc, lr

//Draw the character r0 to (0,0)
draw_Char:	
	push		{r4-r9, lr}

	chAdr		.req	r4
	px			.req	r5
	py			.req	r6
	row			.req	r7
	mask		.req	r8
	
	mov			r10, r2				//Is the color
	mov			r9, r1				//Is the x coordinate
	mov			r2, r0				//Is the number value to draw
	add			r2, #48
	ldr			chAdr, =font		@ load the address of the font map
	mov			r3, r2				@ load the character into r0
	add			chAdr,	r3, lsl #4	@ char address = font base + (char * 16)

	mov			py, #160			@ init the Y coordinate (pixel coordinate)
	
charLoop$:
	mov			px, r9			@ init the X coordinate

	mov			mask, #0x01			@ set the bitmask to 1 in the LSB
	
	ldrb		row, [chAdr], #1	@ load the row byte, post increment chAdr

rowLoop$:
	tst			row,	mask		@ test row byte against the bitmask
	beq			noPixel$

	mov			r0, px
	mov			r1, py
	mov			r2, r10				@ color
	bl			DrawPixel			@ draw red pixel at (px, py)

noPixel$:
	add			px, #1				@ increment x coordinate by 1
	lsl			mask, #1			@ shift bitmask left by 1

	tst			mask,	#0x100		@ test if the bitmask has shifted 8 times (test 9th bit)
	beq			rowLoop$

	add			py, #1				@ increment y coordinate by 1
	
	tst			chAdr, #0xF
	bne			charLoop$			@ loop back to charLoop$, unless address evenly divisibly by 16 (ie: at the next char)
	
	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask

	pop		{r4-r9, pc}
@ Draw Image
@  r0 - address of image
@  r1 - address of wh
@  r2 - address of xy
drawImg:
	mov 	fp, sp	
	push	{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	
	
	
	mov		r4, r0			//address
	mov		r5, r1			//address for wh
	mov		r6, r2			//address for xy
	@initialize incrememnt variables
	mov		r7, #0			//pixel drawn
	mov		r8, #0			//col pixel
	mov		r9, #0			//row pixel
	ldr		r0, [r5]		//w
	ldr		r1, [r5, #4]	//h
	mul		r10, r0, r1		//r10 = w*h
	b		testImg
drawImgLoop:
	ldr		r0, [r6]		//x
	ldr		r1, [r6, #4]	//y
	
	add		r0, r8			//col
	add		r1, r9			//row
	ldr		r2, [r4, r7, lsl #2]	//color pixel
	bl		DrawPixel		//Draw this pixel
	
	add		r7, #1			//pixels drawn
	add		r8, #1			//increment col of pixel
@test width
	ldr		r0, [r5]		//Width of image
	cmp		r8, r0			//Compares the width of image
	blt		drawImgLoop		//loops if r6 is less than width of img
	
	mov		r8, #0			//reset column number
	add		r9, #1			//Increment row number
@test height
	ldr		r0, [r5, #4]	//Height of image
	cmp		r9, r0			//Compares the height of image
	blt		drawImgLoop		//loops if r7 is less than height of image
testImg:
	cmp		r7, r10			//Compares pixels drawn to amount of pixels
	blt		drawImgLoop		//loop if there are still pixels to be drawn
	
	pop		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov		pc, lr


@ Draw Pixel
@  r0 - x
@  r1 - y
@  r2 - colour

DrawPixel:
	@mov 	fp, sp					why don't i use this?
	push	{r4, r5}
	offset	.req	r4
	ldr		r5, =frameBufferInfo	

	@ offset = (y * width) + x
	ldr		r3, [r5, #4]			// r3 = width
	mul		r1, r3
	add		offset,	r0, r1
	@ offset *= 4 (32 bits per pixel/8 = 4 bytes per pixel)
	lsl		offset, #2

	@ store the colour (word) at frame buffer pointer + offset
	ldr		r0, [r5]				//r0 = frame buffer pointer
	str		r2, [r0, offset]

	pop		{r4, r5}
	bx		lr						//What does this do?!
	@mov		pc, lr				why don't i use this?
	
@----------------------------------Erase screen----------------------------------------
quit_game:
	mov 	fp, sp	
	push	{r4, r5, r6, r7, r8, fp, lr}


	mov	r5, #704		//width of image
	mov	r6, #672		//height of image
	mov	r7, #560		//x
	mov	r8, #140		//y
	
	@Set address
	ldr 	r0, =erase		//address for menu
	
	@Set w and h
	ldr 	r1, =imgDim 	// w and h
	str	r5, [r1]			// w = r5
	str	r6, [r1, #4]		// h = r6

	@Set x and y
	ldr 	r2, =xy			// x and y
	str	r7, [r2]			// x = r7
	str	r8, [r2, #4]		// y = r8

	@drawImg
	bl	drawImg				//r0 = address for img, r1 = adderss for wh, r2 = address for xy
	pop	{r4, r5, r6, r7, r8, fp, lr}
	mov		pc, lr
	
@ Data section
.section .data

imgDim:		.int 0, 0
xy:			.int 0, 0

.align
.global frameBufferInfo
//it'll just be the screen length
frameBufferInfo:
	.int	0		@ frame buffer pointer
	.int	0		@ screen width
	.int	0		@ screen height

.align 4
font: .incbin "font.bin"
