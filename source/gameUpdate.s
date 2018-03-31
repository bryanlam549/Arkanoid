

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
	
	//bl		draw_Floor2
	ldr		r7, [r5]		//paddle x
	ldr		r8, [r5, #4]	//paddle y
	
left_check:
	cmp		r4, #6			//Left button
	bleq		draw_Floor2
	bne		right_check
	
	sub		r7, r6			//decrease x-coordinate by x amount of pix
	cmp		r7, #592		//compare the x coordinate to edge of wall
	movlt	r7, #592		//press the paddle up to the wall
	str		r7, [r5]		//update paddle coordinates
	b		draw

right_check:
	cmp		r4, #7			//Right buttons
	bleq	draw_Floor2
	bne		draw
	add		r7, r6 			//increase paddle x-coordinate by x amount of pix
	cmp		r7, #1104		//compare x coordinate to edg
	movgt	r7, #1104		//press the paddle up to the wall	
	str		r7, [r5]		//update the paddle coordinates

draw:	
	ldr		r0, [r5]
	ldr		r1, [r5, #4]
	bl		draw_Paddle
	pop		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov		pc, lr	


//r0 = button pressed
//r1 = address of ball coordinates
updateBall:						//returns brick collision in r2 and paddle collision in r3
	mov 		fp, sp	
	push		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	
	mov			r4, r0			//r4 = ball coordinates
	mov			r5, r1			//r5 = paddle coordinates
	@Update background while ball moves


//	ldr			r2, [r4, #4]	//ball y
//	cmp			r2, #396
//	blgt		draw_Background_Minus_Bricks
//	ldr			r0, =brick_array
//	bllt		draw_Bricks

	
//	bl		draw_Background_Minus_Bricks
//Try...only updating brick arrays when its hit. 
//	ldr		r0, =brick_array
//	bl		draw_Bricks

	mov			r0, #3000
	bl			delayMicroseconds
	
	mov			r2, r4
	bl			ball_Direction
	mov			r2, r4
	bl			wall_Collision
	mov			r2, r4
	bl			brick_Collision
	mov			r6, r2			// r6 = 1 means brick has been hit
	mov			r2, r4
	mov			r3, r5
	bl			paddle_Collision
	cmp			r3, #1			//Means the floor has been hit
	
	mov			r9, r0
	mov			r10, r1
	beq			exit
	
update_ball_info:
	@update bricks if it gets hit
	cmp		r6, #1
	ldreq		r0, =brick_array
	bleq		draw_Bricks
	@update ball info
	mov			r0, r9
	mov			r1, r10
	str			r0,	[r4]
	str			r1, [r4, #4]	
	bl			draw_Ball
	
exit:
	mov			r2, r6
	pop			{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov			pc, lr



// tests paddle collision
// returns 0 in r3 if player loses life, otherwise returns 1
paddle_Collision:
	mov 		fp, sp	
	push		{r4, r5, r6, r7, r8, r9, r10, fp, lr}

	mov			r4, r2
	mov			r5, r3

	ldr			r2, [r5]		//paddle x
	ldr			r3, [r5, #4]	//paddle y
	ldr			r5, [r4, #8]	//ball angle: 0 =45, 1 = 60
	ldr			r6, [r4, #12]	//ball up/down direction: 0 = up, 1 = down
	ldr			r7, [r4, #16]	//ball left/right direction: 0 = left, 1 = right
	
	@Collision Paddle		
	@right tip
	add			r10, r2, #128	//end of the right tip 
	add			r8, r2, #92		//beginning of the right tip
	cmp			r0, r8			//compare ball& beginning of right tip
	bgt			test_If_Between_Right_Tip

	@middle right
	add			r10, r2, #92	//end of the middle right portion
	add			r8, r2, #64		//beginning of the middle right portion
	cmp			r0, r8			//compare ball& beginning of middle right
	bgt			test_If_Between_Middle_Right
	@middle left
	add			r10, r2, #64	//end of the middle left portion
	add			r8, r2, #36		//beginning of the middle right portion
	cmp			r0, r8			//compare ball& beginning of middle right 
	bgt			test_If_Between_Middle_Left

	@left tip
	add			r10, r2, #36	//end of the left tip of the paddle
	cmp			r0, r2			//compare ball&paddle beginning
	bgt			test_If_Between_Left_Tip
	
	b			not_On_Paddle

test_If_Between_Right_Tip:
	cmp			r0, r10
	movlt		r9, #4
	blt		test_If_Touch_Pad
	b			not_On_Paddle

test_If_Between_Middle_Right:
	cmp			r0, r10
	movlt		r9, #3
	blt		test_If_Touch_Pad
	b			not_On_Paddle

test_If_Between_Middle_Left:
	cmp			r0, r10
	movlt		r9, #2
	blt		test_If_Touch_Pad
	b			not_On_Paddle

	
test_If_Between_Left_Tip:
	cmp			r0, r10
	movlt		r9, #1
	blt		test_If_Touch_Pad
	b			not_On_Paddle
	
test_If_Touch_Pad:
	cmp			r1, #764		//compare y coordinate of ball w/ top of paddle
	movgt		r1, #764		//press the ball up to the paddle
	movgt		r6, #0			//move up now
	strgt		r6, [r4, #12]	//update
	bgt		which_Paddle_Portion
	b			not_On_Paddle
	
which_Paddle_Portion:
	cmp			r9, #4			//hit right tip
	moveq		r5, #1			//move at 60 degrees now
	moveq		r7, #1			//move right now
	streq		r5, [r4, #8]	//update angle
	streq		r7, [r4, #16]	//update left/right
	
	cmp			r9, #3			//hit middle right
	moveq		r5, #0			//move at 45 degrees now
	moveq		r7, #1			//move right now
	streq		r5, [r4, #8]	//update angle
	streq		r7, [r4, #16]	//update left/right

	cmp			r9, #2			//hit middle left
	moveq		r5, #0			//move at 45 degrees now
	moveq		r7, #0			//move right now
	streq		r5, [r4, #8]	//update angle
	streq		r7, [r4, #16]	//update left/right
	
	
	cmp			r9, #1			//hit left tip
	moveq		r5, #1			//move at 60 degrees now
	moveq		r7, #0			//move left now
	streq		r5, [r4, #8]	//update angle
	streq		r7, [r4, #16]	//update left/right
	
not_On_Paddle:	
	mov			r9, #0			//do i do this? yes i do...
	cmp			r1, #796		//compare the y coordinate floor or 764
	movgt		r3, #1			//You lose if you hit the floor
	
	pop			{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov			pc, lr
	
// checks for brick collision
// TODO: value pack array update
brick_Collision:
	mov 		fp, sp	
	push		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov			r4, r2

	ldr			r5, [r4, #8]	//ball angle: 0 =45, 1 = 60
	ldr			r6, [r4, #12]	//ball up/down direction: 0 = up, 1 = down
	ldr			r7, [r4, #16]	//ball left/right direction: 0 = left, 1 = right
	@Collision Brick: r8-r10 is free and r3 but... try not to use r3
	//ball x = r0
	//ball y = r1
	
	@First row of the bricks
	ldr			r10, =brick_array	//Brick array
	cmp			r1, #236			//see if ball is hitting the 1st row
	mov			r3, #0
	blt			continue_Brick_Collision
	@Second row of the bricks
	cmp			r1, #268			//see if ball is hitting the 2nd row
	mov			r3, #5
	blt			continue_Brick_Collision
	@Third row of the bricks
	cmp			r1, #300			//see if ball is hitting the 3rd row
	mov			r3, #10
	blt			continue_Brick_Collision
	@Fourth row of the bricks
	cmp			r1, #332			//see if ball is hitting the 4th row
	mov			r3, #15
	blt			continue_Brick_Collision
	@Fifth row of the bricks
	cmp			r1, #364			//see if ball is hitting the 5th row
	mov			r3, #20
	blt			continue_Brick_Collision
	@Sixth row of the bricks
	cmp			r1, #396			//see if ball is hitting the 6th row
	mov			r3, #25
	blt			continue_Brick_Collision
	bl			exit_Brick_Collision
	
continue_Brick_Collision:
	add			r6, #1
	cmp			r6, #1
	movgt		r6, #0
	mov			r8, r0	 			//ball x coordinate...
	sub			r8, #592			//game map x coordinate
	lsr			r8, #7 				//r8 = Brick array number
	add			r8, r3
	ldr			r9, [r10, r8, lsl #2]//r9 = brick value
	cmp			r9, #0				//Do while brick is present...
	subne		r9, #1				//Change brick value
	strne		r9, [r10, r8, lsl #2]//Update the brick
	strne		r6, [r4, #12]		//update up/down dir
		
	
	@update score
	ldrne		r9, =life_Score		
	ldrne		r10, [r9, #4]
	addne		r10, #1
	strne		r10, [r9, #4]
	movne		r2, #1 			//means you hit a brick

	beq			check_if_hit_side	//when you are in the row, you wanna check if you hit the of a brick
	bl			brick_Not_Hit

check_if_hit_side:
	//r8 is brick array number
	//r9 is nothing. so free reg is r9, r10, maybe r3???
	cmp			r5, #0			//if ball is moving 45 degrees
	moveq		r9, #3
	cmp			r5, #1			//if ball is moving 60 degrees
	moveq		r9, #6		
	
	//Checks if it'll hit the side of a brick	
	cmp			r7, #0			//if ball is moving left
	subeq		r10, r0, r9		//r10 = future x if continues
	subeq		r8, #1
	cmp			r7, #1			//if ball is moving right
	addeq		r10, r0, r9		//r10 = future x if continues
	addeq		r8, #1
	sub			r10, #592
	lsr			r10, #7 		//r10 = Brick array number
	add			r10, r3			//r3 is the array offset. Set from before. (hopefully, we wont need paddle y later!)
	cmp			r10, r8			//When r10 = r8, that means it makes contact w/ that brick
	beq			hit_side
	b			exit_Brick_Collision

hit_side:

	@reverse left/right direction when you hit the side
	add			r7, #1
	cmp			r7, #1
	movgt		r7, #0
	
	ldr			r10, =brick_array	
	ldr			r9, [r10, r8, lsl #2]
	cmp			r9, #0				
	subne		r9, #1				//Change brick value
	strne		r9, [r10, r8, lsl #2]//Update the brick
	
	
	
	@update score if you hit the side too
	ldrne			r9, =life_Score		
	ldrne			r10, [r9, #4]
	addne			r10, #1
	strne			r10, [r9, #4]
	movne			r2, #1		//means you hit a brick
	
	@IF brick value is zero, dont reverse direction
	addeq		r7, #1
	cmp			r7, #1
	movgt		r7, #0
	str			r7, [r4, #16]		//update left/right
	
exit_Brick_Collision:	
	pop			{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov			pc, lr

// check for wall collision
wall_Collision:
	mov 		fp, sp
	push		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov			r4, r2
	
	ldr			r6, [r4, #12]	//ball up/down direction: 0 = up, 1 = down
	ldr			r7, [r4, #16]	//ball left/right direction: 0 = left, 1 = right
	
	@Collision left wall
	cmp			r0, #592		//compare the x coordinate to edge of wall
	movlt		r0, #592		//press the ball up to the wall
	movlt		r7, #1			//move right now
	strlt		r7, [r4, #16]	//Update
	
	@Collision right wall
	cmp			r0, #1216		//compare the x coordinate to edge of wall
	movgt		r0, #1216		//press the ball up to the wall
	movgt		r7, #0			//move left now
	strgt		r7, [r4, #16]	//update
	
	@Collision ceiling			
	cmp			r1, #204		//compare the y coordinate to edge of ceiling
	movlt		r1, #204		//press the ball up to the wall
	movlt		r6, #1			//move down now
	strlt		r6, [r4, #12]	//update
	
	
brick_Not_Hit:
	pop			{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov			pc, lr

@move the ball depending on angle, y-direction and x-direction
ball_Direction:
	mov 		fp, sp	
	push		{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov			r4, r2
	
	ldr			r0, [r4]
	ldr			r1, [r4, #4]
	ldr			r5, [r4, #8]	//ball angle: 0 =45, 1 = 60
	ldr			r6, [r4, #12]	//ball up/down direction: 0 = up, 1 = down
	ldr			r7, [r4, #16]	//ball left/right direction: 0 = left, 1 = right
	
	cmp			r5, #0			//45
	moveq		r8, #2
	moveq		r9, #2
	
	cmp			r5, #1			//60
	moveq		r8, #2
	moveq		r9, #1
	
	cmp			r6, #0			//up
	subeq		r1, r9
	
	cmp			r6, #1			//down
	addeq		r1, r9
	
	cmp			r7, #0			//left
	subeq		r0, r8
	
	cmp			r7, #1			//right
	addeq		r0, r8
	
	pop			{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov			pc, lr

@ Data section
.section .data

imgDim:		.int 0, 0
xy:		.int 0, 0

