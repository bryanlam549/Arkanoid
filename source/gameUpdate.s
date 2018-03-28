

@ Code section
.section .text

.global updateInitialState, updatePlayingStatePaddle, updateBall

//r0 = button pressed
//r1 = address of paddle coordinates
//r2 = address of ball coordinates
updateInitialState:
	mov 		fp, sp	
	push		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov		r4, r0			//r4 = button pressed
	mov		r5, r1			//r5 = address of paddle coordinates
	mov		r6, r2			//r6 = address of ball coordinates
	mov		r7, r3			//r7 = speed of ball and paddle
	bl		draw_Floor
	
	ldr		r0, [r5]		//paddle x
	ldr		r1, [r5, #4]		//paddle y
	ldr		r2, [r6]		//ball x
	ldr		r3, [r6, #4]		//ball y
	
	@left is pressed
init_left_check:
	cmp		r4, #6			//Left button
	bne		init_right_check
	sub		r0, r7			//decrease x-coordinate by x amount of pix
	sub		r2, r7			//decrease ball x coordinate by x amount of pix
	cmp		r0, #592		//compare the x coordinate to edge of wall
	movlt		r0, #592		//press the paddle up to the wall
	cmp		r2, #648		//compare the x coordinate of ball w/ edge of wall
	movlt		r2, #648		//centerize the ball w/ the paddle
	str		r0, [r5]		//update paddle coordinates
	str		r2, [r6]		//update ball coordinates
	b		init_draw
	
	@right is pressed
init_right_check:
	cmp		r4, #7			//Right button
	bne		init_draw
	add		r0, r7 			//increase paddle x-coordinate by x amount of pix
	add		r2, r7			//increase ball x-coordinate by x amount of pix
	cmp		r0, #1104		//compare the x coordinate to edge of wall
	movgt		r0, #1104		//press the paddle up to the wall
	ldr		r8, =#1160		//Have to do this or else it gives an error for some reason
	cmp		r2, r8			//compare the x coordinate of ball w/ edge of wall
	movgt		r2, r8			//centerize the ball w/ the paddle
	str		r0, [r5]		//update the paddle coordinates
	str		r2, [r6]		//update the ball coordinates

init_draw:	
	bl		draw_Paddle	
	ldr		r0, [r6]
	ldr		r1, [r6, #4]
	bl		draw_Ball	
	pop		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov		pc, lr

updatePlayingStatePaddle:
	mov 		fp, sp	
	push		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	
	mov		r4, r0			//r4 = button pressed
	mov		r5, r1			//r5 = address of paddle coordinates
	mov		r6, r2			//r6 = speed of paddle
	bl		draw_Floor
	
	ldr		r0, [r5]		//paddle x
	ldr		r1, [r5, #4]		//paddle y

left_check:
	cmp		r4, #6			//Left button
	bne		right_check
	sub		r0, r6			//decrease x-coordinate by x amount of pix
	cmp		r0, #592		//compare the x coordinate to edge of wall
	movlt		r0, #592		//press the paddle up to the wall
	str		r0, [r5]		//update paddle coordinates
	b		draw

right_check:
	cmp		r4, #7			//Right button
	bne		draw
	add		r0, r6 			//increase paddle x-coordinate by x amount of pix
	cmp		r0, #1104		//compare x coordinate to edg
	movgt		r0, #1104		//press the paddle up to the wall	
	str		r0, [r5]		//update the paddle coordinates

draw:	
	ldr		r0, [r5]
	ldr		r1, [r5, #4]
	bl		draw_Paddle
	pop		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov		pc, lr	

//r0 = button pressed
//r1 = address of ball coordinates
updateBall:
	mov 		fp, sp	
	push		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	
	mov		r4, r0			//r4 = ball coordinates
	mov		r5, r1			//r5 = paddle coordinates
	@Update background while ball moves
	bl		draw_Background_Minus_Bricks

	ldr		r0, [r4]		//ball x
	ldr		r1, [r4, #4]		//ball y
	ldr		r2, [r5]		//paddle x
	ldr		r3, [r5, #4]		//paddle y
	ldr		r5, [r4, #8]		//ball angle: 0 =45, 1 = 60
	ldr		r6, [r4, #12]		//ball up/down direction: 0 = up, 1 = down
	ldr		r7, [r4, #16]		//ball left/right direction: 0 = left, 1 = right
	
	@move the ball depending on angle, y-direction and x-direction
	cmp		r5, #0			//45
	moveq		r8, #3
	moveq		r9, #3
	cmp		r5, #1			//60
	moveq		r8, #6
	moveq		r9, #3
	cmp		r6, #0			//up
	subeq		r1, r9
	cmp		r6, #1			//down
	addeq		r1, r9
	cmp		r7, #0			//left
	subeq		r0, r8
	cmp		r7, #1			//right
	addeq		r0, r8
	
	@Collision left wall
	cmp		r0, #592		//compare the x coordinate to edge of wall
	movlt		r0, #592		//press the ball up to the wall
	movlt		r7, #1			//move right now
	strlt		r7, [r4, #16]		//Update
	
	@Collision right wall
	cmp		r0, #1216		//compare the x coordinate to edge of wall
	movgt		r0, #1216		//press the ball up to the wall
	movgt		r7, #0			//move left now
	strgt		r7, [r4, #16]		//update
	
	@Collision ceiling			
	cmp		r1, #204		//compare the y coordinate to edge of ceiling
	movlt		r1, #204		//press the ball up to the wall
	movlt		r6, #1			//move down now
	strlt		r6, [r4, #12]		//update
	
	@Collision Paddle			testing.... keep it 45
	add		r10, r2, #128		//end of the paddle, x
	cmp		r0, r2			//compare ball&paddle beginning
	bgt		test_If_Between_Pad
	b		skip
test_If_Between_Pad:
	cmp		r0, r10
	bl		test_If_Touch_Pad
	b		skip
test_If_Touch_Pad:
	cmp		r1, #764		//compare y coordinate of ball w/ top of paddle
	movgt		r1, #764		//press the ball up to the paddle
	movgt		r6, #0			//move up now
	strgt		r6, [r4, #12]	//update

skip:	
	cmp		r1, #796		//compare the y coordinate floor
	bgt		lose			//You lose if you hit the floor
	
	@update ball info
	str		r0,[r4]
	str		r1, [r4, #4]	
	bl		draw_Ball
	
lose:
	pop		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov		pc, lr	


@ Data section
.section .data

imgDim:		.int 0, 0
xy:		.int 0, 0

