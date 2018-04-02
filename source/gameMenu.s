
@ Code section
.section .text

.global gameMenu
gameMenu:	
	mov 	fp, sp	
	push	{r4, r5, r6, r7, r8, r9, r10, fp, lr}




		
@----------------------------------Menu----------------------------------------
	mov		r0,	#0x10000
	bl		delayMicroseconds
	mov		r0,	#0x10000
	bl		delayMicroseconds
	mov		r0,	#0x10000
	bl		delayMicroseconds
	mov		r0,	#0x10000
	bl		delayMicroseconds
	
	mov	r5, #704		//width of image
	mov	r6, #640		//height of image
	mov	r7, #560		//x
	mov	r8, #172		//y
	
	@Set address
	ldr 	r0, =menu		//address for menu
	
	@Set w and h
	ldr 	r1, =imgDim 		// w and h
	str	r5, [r1]		// w = r5
	str	r6, [r1, #4]		// h = r6

	@Set x and y
	ldr 	r2, =xy			// x and y
	str	r7, [r2]		// x = r7
	str	r8, [r2, #4]		// y = r8

	@drawImg
	bl	drawImg			//r0 = address for img, r1 = adderss for wh, r2 = address for xy
	
@----------------------------------COVER SCORE + LIVES ... because i didn't want to resize the menu...---------------------------------------
	mov		r9, #0			//Increment variable. How many tiles you want in x direction
	mov		r5, #32			//width of image
	mov		r6, #32			//height of image
	mov		r7, #560		//x
	mov		r8, #140		//y

loopCover_LS:
	ldr 	r0, =blackTile	//address for background
	
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
	cmp		r9, #22			//Want 20 tiles in the x direction
	blt		loopCover_LS

@----------------------------------Menu Cursor-------------------------------------
	
	mov	r10, #1			// cursor location: 1 = start, 0 = quit
					// initially set at start
update_cursor:	
	@initialize variables
	mov	r5, #32			//width of image
	mov	r6, #32			//height of image
	mov	r7, #830		//x
	cmp	r10, #1
	moveq	r8, #633		//y
	movne	r8, #712		//633 for start and 712 for quit

	@Set Address
	ldr 	r0, =menuCursor		//address for menuCursor
	
	@Set w and h
	ldr 	r1, =imgDim	 	// w and h
	str	r5, [r1]		// w = r5
	str	r6, [r1, #4]		// h = r6

	@Set x and y
	ldr 	r2, =xy			// x and y
	str	r7, [r2]		// x = r7
	str	r8, [r2, #4]		// y = r8

	@draw image
	bl	drawImg			//r0 = address for img, r1 = adderss for wh, r2 = address for xy

	@erase previous image
	cmp	r10, #1
	moveq	r8, #712		//y
	movne	r8, #633		//633 for start and 712 for quit

	@Set Address
	ldr 	r0, =blackTile		//replace cursor with black tile
	
	@Set w and h
	ldr 	r1, =imgDim	 	// w and h
	str	r5, [r1]		// w = r5
	str	r6, [r1, #4]		// h = r6

	@Set x and y
	ldr 	r2, =xy			// x and y
	str	r7, [r2]		// x = r7
	str	r8, [r2, #4]		// y = r8

	@draw image
	bl	drawImg			//r0 = address for img, r1 = adderss for wh, r2 = address for xy

user_input:	
	bl	find_Button	
	cmp	r0, #4			//move up
	moveq	r10, #1
	beq	update_cursor
	cmp	r0, #5			//move down
	moveq	r10, #0
	beq	update_cursor
	cmp	r0, #8			// A pressed	
	beq	return_input
	b	user_input

return_input:
	mov	r0, r10
	pop	{r4, r5, r6, r7, r8, r9, r10, fp, pc}
	mov		pc, lr
	
@ Data section
.section .data

imgDim:
	.int 0, 0
xy:	
	.int 0, 0
