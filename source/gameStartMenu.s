
@ Code section
.section .text

.global start_Menu


start_Menu:
	mov 	fp, sp	
	push	{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	
	
	mov		r0,	#0x10000
	bl		delayMicroseconds
	mov		r0,	#0x10000
	bl		delayMicroseconds
	bl		drawStart
	bl		update_Cursor	//needs to return something in r0
	
	pop		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov		pc, lr
	
	
	
	
	@----------------------------------Menu Cursor-------------------------------------
	
update_Cursor:
	mov 	fp, sp	
	push	{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	
	mov	r10, #1		// cursor location: 1 = restart, 0 = quit
					// initially set at start
update_start_cursor:
	@initialize variables
	mov		r5, #32				//width of image
	mov		r6, #32				//height of image
	mov		r7, #825			//x
	cmp		r10, #1				//Where the cursor is at
	moveq 	r8, #488			//y
	movne 	r8, #525			//490 for restart and 525 for quit

	@Set Address
	ldr 	r0, =menuCursor			//address for menuCursor
	
	@Set w and h
	ldr 	r1, =imgDim	 		// w and h
	str		r5, [r1]			// w = r5
	str		r6, [r1, #4]		// h = r6

	@Set x and y
	ldr 	r2, =xy				// x and y
	str		r7, [r2]			// x = r7
	str		r8, [r2, #4]		// y = r8

	@draw image
	bl	drawImg			//r0 = address for img, r1 = adderss for wh, r2 = address for xy

	@erase previous image
	cmp		r10, #1
	moveq	r8, #525		//y
	movne	r8, #488		//490 for restart and 525 for quit

	@Set Address
	ldr 	r0, =blackTile		//replace cursor with black tile
	
	@Set w and h
	ldr 	r1, =imgDim	 	// w and h
	str		r5, [r1]		// w = r5
	str		r6, [r1, #4]		// h = r6

	@Set x and y
	ldr 	r2, =xy			// x and y
	str		r7, [r2]		// x = r7
	str		r8, [r2, #4]		// y = r8

	@draw image
	bl	drawImg			//r0 = address for img, r1 = adderss for wh, r2 = address for xy


user_input_menu:	
	bl	find_Button	
	cmp	r0, #4			//move up
	moveq	r10, #1
	beq	update_start_cursor
	cmp	r0, #5			//move down
	moveq	r10, #10
	beq	update_start_cursor
	
	cmp	r0, #8			// A pressed	
	beq	return_input
	
	cmp	r0, #3			// Start pressed	
	moveq r10, #2
	beq	return_input
	
	b	user_input_menu

	
return_input:
	mov		r1, r10
	
	pop		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov		pc, lr
	

		
	@----------------------------------START MENU-------------------------------------------	
drawStart: 
	mov 	fp, sp	
	push	{r4, r5, r6, r7, r8, fp, lr}	
	
	@initialize variables
	mov		r5, #180		//width of image
	mov		r6, #165		//height of image
	mov		r7, #823		//x: 848 is center
	mov		r8, #450		//y: 780 is center

	@Set address
	ldr 	r0, =startMenu		//address for startMenu
	
	@Set w and h
	ldr 	r1, =imgDim 	// w and h
	str		r5, [r1]		// w = r5
	str		r6, [r1, #4]	// h = r6

	@Set x and y
	ldr 	r2, =xy			// x and y
	str		r7, [r2]		// x = r7
	str		r8, [r2, #4]	// y = r8

	@draw the image
	bl		drawImg			//r0 = address for img, r1 = adderss for wh, r2 = address for xy
	
	pop		{r4, r5, r6, r7, r8, fp, lr}
	mov		pc, lr

@ Data section
.section .data

imgDim:		.int 0, 0
xy:			.int 0, 0

