
@ Code section
.section .text

.global draw_Background, draw_Bricks, draw_Paddle, draw_Ball, draw_Floor, draw_Background_Minus_Bricks

draw_Background_Minus_Bricks:
	mov 	fp, sp	
	push	{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov		r9, #0			//Increment variable. How many tiles you want in x direction
	mov		r4, #0			//Increment variable. How many tiles you want in y direction
	mov		r5, #32			//width of image
	mov		r6, #32			//height of image
	mov		r7, #592		//x
	mov		r8, #396		//y

loopMinusBricks:
	ldr 	r0, =background	//address for background
	
	@Set w and h
	ldr 	r1, =imgDim 	// w and h
	str		r5, [r1]		// w = r5
	str		r6, [r1, #4]	// h = r6

	@Set x and y
	ldr 	r2, =xy			// x and y
	str		r7, [r2]		// x = r7
	str		r8, [r2, #4]	// y = r8
	bl		drawImg			//r0 = address for img, r1 = adderss for wh, r2 = address for xy
	
	@Add width or/and height and ++increment variable
	add		r7, r5			//Add the width to x for offset
	add		r9, #1
	cmp		r9, #20			//Want 20 tiles in the x direction
	blt		loopMinusBricks
	
	mov		r7, #592		//x
	mov		r9, #0			//Reset for a new row
	add		r8, r6			//Add the height to y for offset.
	add		r4, #1			//increment
	cmp		r4, #12			//Want 15 tiles in the y direction
	blt		loopMinusBricks

	pop		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov		pc, lr
@----------------------------------USED TO UPDATE PADDLE WHEN MOVE----------------------------------------
draw_Floor:
	mov 	fp, sp	
	push	{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov		r9, #0			//Increment variable. How many tiles you want in x direction
	mov		r4, #0			//Increment variable. How many tiles you want in y direction
	mov		r5, #32			//width of image
	mov		r6, #32			//height of image
	mov		r7, #592		//x
	mov		r8, #748		//y

loopFloor:
	ldr 	r0, =background	//address for background
	
	@Set w and h
	ldr 	r1, =imgDim 	// w and h
	str		r5, [r1]		// w = r5
	str		r6, [r1, #4]	// h = r6

	@Set x and y
	ldr 	r2, =xy			// x and y
	str		r7, [r2]		// x = r7
	str		r8, [r2, #4]	// y = r8
	bl		drawImg			//r0 = address for img, r1 = adderss for wh, r2 = address for xy
	
	@Add width or/and height and ++increment variable
	add		r7, r5			//Add the width to x for offset
	add		r9, #1
	cmp		r9, #20			//Want 20 tiles in the x direction
	blt		loopFloor
	
	mov		r7, #592		//x
	mov		r9, #0			//Reset for a new row
	add		r8, r6			//Add the height to y for offset.
	add		r4, #1			//increment
	cmp		r4, #2			//Want 19 tiles in the y direction
	blt		loopFloor

	pop		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov		pc, lr


//draws walls and background
draw_Background:
	mov 	fp, sp	
	push	{r4, r5, r6, r7, r8, r9, r10, fp, lr}

@----------------------------------DRAW THE LEFT WALL-----------------------------------------
	mov			r4, #0			//Increment variable. How many tiles you want to draw
	mov			r5, #32			//width of image
	mov			r6, #32			//height of image
	mov			r7, #560		//x
	mov			r8, #204		//y
	b			testLeft
loopLeft:
	ldr 		r0, =wall		//address for wall
	
	@Set w and h
	ldr 		r1, =imgDim 		// w and h
	str			r5, [r1]		// w = r5
	str			r6, [r1, #4]		// h = r6

	@Set x and y
	ldr 		r2, =xy			// x and y
	str		r7, [r2]		// x = r7
	str		r8, [r2, #4]		// y = r8

	@Add width or/and height and ++increment variable
	//add		r7, r5			//Add the width to x
	add		r8, r6			//Add the height to y
	add		r4, #1			//increment
	bl		drawImg			//r0 = address for img, r1 = adderss for wh, r2 = address for xy
testLeft:
	cmp		r4, #19			
	blt		loopLeft		

@----------------------------------DRAW THE CEILING-------------------------------------------

	mov		r4, #0			//Increment variable. How many tiles you want to draw
	mov		r5, #32			//width of image
	mov		r6, #32			//height of image
	mov		r7, #592		//x
	mov		r8, #172		//y
	b		testCeil
loopCeil:
	ldr 	r0, =ceiling			//address for ceiling
	
	@Set w and h
	ldr 	r1, =imgDim 			// w and h
	str		r5, [r1]		// w = r5
	str		r6, [r1, #4]		// h = r6

	@Set x and y
	ldr 		r2, =xy			// x and y
	str		r7, [r2]		// x = r7
	str		r8, [r2, #4]		// y = r8

	@Add width or/and height and ++increment variable
	add		r7, r5			//Add the width to x
	//add		r8, r6			//Add the height to y
	add		r4, #1			//increment
	bl		drawImg			//r0 = address for img, r1 = adderss for wh, r2 = address for xy
testCeil:
	cmp		r4, #20			
	blt		loopCeil		
	
@----------------------------------DRAW THE RIGHTCORNER-------------------------------------------

	mov		r4, #0			//Increment variable. How many tiles you want to draw
	mov		r5, #32			//width of image
	mov		r6, #32			//height of image
	mov		r7, #1232		//x
	mov		r8, #172		//y

	@set address
	ldr 	r0, =rightC			//address for rightcorner
	
	@Set w and h
	ldr 		r1, =imgDim 		// w and h
	str		r5, [r1]		// w = r5
	str		r6, [r1, #4]		// h = r6

	@Set x and y
	ldr 	r2, =xy				// x and y
	str		r7, [r2]		// x = r7
	str		r8, [r2, #4]		// y = r8

	@draw the image
	bl		drawImg			//r0 = address for img, r1 = adderss for wh, r2 = address for xy

@----------------------------------DRAW THE LEFTCORNER-------------------------------------------

	mov		r5, #32			//width of image
	mov		r6, #32			//height of image
	mov		r7, #560		//x
	mov		r8, #172		//y

	@Set address
	ldr 	r0, =leftC			//address for left corner
	
	@Set w and h
	ldr 		r1, =imgDim 		// w and h
	str		r5, [r1]		// w = r5
	str		r6, [r1, #4]		// h = r6

	@Set x and y
	ldr 	r2, =xy				// x and y
	str		r7, [r2]		// x = r7
	str		r8, [r2, #4]		// y = r8

	@draw the image
	bl		drawImg			//r0 = address for img, r1 = adderss for wh, r2 = address for xy

@----------------------------------DRAW THE RIGHT WALL-------------------------------------------

	mov		r4, #0			//Increment variable. How many tiles you want to draw
	mov		r5, #32			//width of image
	mov		r6, #32			//height of image
	mov		r7, #1232		//x
	mov		r8, #204		//y
	b		testRight
loopRight:
	ldr 	r0, =wall			//address for wall
	
	@Set w and h
	ldr 	r1, =imgDim 	// w and h
	str		r5, [r1]		// w = r5
	str		r6, [r1, #4]		// h = r6

	@Set x and y
	ldr 	r2, =xy				// x and y
	str		r7, [r2]		// x = r7
	str		r8, [r2, #4]		// y = r8

	@Add width or/and height and ++increment variable
	//add		r7, r5			//Add the width to x
	add		r8, r6			//Add the height to y
	add		r4, #1			//increment
	bl		drawImg			//r0 = address for img, r1 = adderss for wh, r2 = address for xy
testRight:
	cmp		r4, #19			
	blt		loopRight
	
	@----------------------------------DRAW THE BACKGROUND-------------------------------------------

	mov		r9, #0			//Increment variable. How many tiles you want in x direction
	mov		r4, #0			//Increment variable. How many tiles you want in y direction
	mov		r5, #32			//width of image
	mov		r6, #32			//height of image
	mov		r7, #592		//x
	mov		r8, #204		//y

loopBack:
	ldr 	r0, =background	//address for background
	
	@Set w and h
	ldr 	r1, =imgDim 	// w and h
	str		r5, [r1]		// w = r5
	str		r6, [r1, #4]		// h = r6

	@Set x and y
	ldr 		r2, =xy		// x and y
	str		r7, [r2]		// x = r7
	str		r8, [r2, #4]	// y = r8
	bl		drawImg			//r0 = address for img, r1 = adderss for wh, r2 = address for xy
	
	@Add width or/and height and ++increment variable
	add		r7, r5			//Add the width to x for offset
	add		r9, #1
	cmp		r9, #20			//Want 19 tiles in the x direction
	blt		loopBack
	
	mov		r7, #592		//x
	mov		r9, #0			//Reset for a new row
	add		r8, r6			//Add the height to y for offset.
	add		r4, #1			//increment
	cmp		r4, #19			//Want 19 tiles in the y direction
	blt		loopBack

	pop		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov		pc, lr

@----------------------------------DRAW THE BRICKS-------------------------------------------
draw_Bricks:
	mov 	fp, sp	
	push	{r4, r5, r6, r7, r8, r9, r10, fp, lr}

	mov		r4, #0			//Increment variable. How many tiles you want to draw
	mov		r5, #128		//width of image
	mov		r6, #32			//height of image
	mov		r7, #592		//x
	mov		r8, #204		//y	

	mov		r9, r0
draw:
	ldr		r10, [r9, r4, LSL#2]
	cmp		r10, #0
	beq		test_Brick
	cmp		r10, #1
	ldreq		r0, =brick1
	cmp		r10, #2
	ldreq		r0, =brick2
	cmp		r10, #3
	ldreq 		r0, =brick3		//address for brick3
	
	@Set w and h
	ldr 		r1, =imgDim 		// w and h
	str		r5, [r1]		// w = r5
	str		r6, [r1, #4]		// h = r6

	@Set x and y
	ldr 		r2, =xy			// x and y
	str		r7, [r2]		// x = r7
	str		r8, [r2, #4]		// y = r8

	bl		drawImg			//r0 = address for img, r1 = adderss for wh, r2 = address for xy
	
	@ increment variables
test_Brick:
	add		r4, #1			//increment index
	add		r7, r5			// increment y

	cmp		r4, #5
	moveq		r7, #592
	addeq		r8, r6

	cmp		r4, #10
	moveq		r7, #592
	addeq		r8, r6

	cmp		r4, #15
	moveq		r7, #592
	addeq		r8, r6

	cmp		r4, #20
	moveq		r7, #592
	addeq		r8, r6

	cmp		r4, #25
	moveq		r7, #592
	addeq		r8, r6

	cmp		r4, #30
	beq		end	

	b		draw

end:		
	pop		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov		pc, lr

@592 to 1104
@592, 720, 848, 976, 1104
@ r0 = x, r1 = y
	@----------------------------------DRAW THE PADDLE -------------------------------------------

draw_Paddle:
	mov 		fp, sp	
	push		{r4, r5, r6, r7, r8, r9, r10, fp, lr}	

	@initialize variables
	mov			r5, #128		//width of image
	mov			r6, #32			//height of image
	mov			r7, r0			//x: 848 is center
	mov			r8, r1			//y: 780

	@Set address
	ldr 		r0, =paddle		//address for paddle
	
	@Set w and h
	ldr 		r1, =imgDim 	// w and h
	str			r5, [r1]		// w = r5
	str			r6, [r1, #4]	// h = r6

	@Set x and y
	ldr 		r2, =xy			// x and y
	str			r7, [r2]		// x = r7
	str			r8, [r2, #4]	// y = r8

	@draw the image
	bl			drawImg			//r0 = address for img, r1 = adderss for wh, r2 = address for xy

	pop			{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov			pc, lr
		
	@----------------------------------DRAW THE BALL-------------------------------------------
	@r0=x, r1=y
draw_Ball:
	mov 		fp, sp	
	push		{r4, r5, r6, r7, r8, r9, r10, fp, lr}	

	@initialize variables
	mov			r5, #16			//width of image
	mov			r6, #16			//height of image
	mov			r7, r0			//x: 866 is center
	mov			r8, r1			//y: 764

	@Set address
	ldr 		r0, =ball		//address for paddle
	
	@Set w and h
	ldr 		r1, =imgDim 	// w and h
	str			r5, [r1]		// w = r5
	str			r6, [r1, #4]	// h = r6

	@Set x and y
	ldr 		r2, =xy			// x and y
	str			r7, [r2]		// x = r7
	str			r8, [r2, #4]	// y = r8

	@draw the image
	bl			drawImg			//r0 = address for img, r1 = adderss for wh, r2 = address for xy

	pop			{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov			pc, lr

@ Data section
.section .data

imgDim:		.int 0, 0
xy:			.int 0, 0

