.global main, brick_array
main:
	@ ask for frame buffer information
	ldr 		r0, =frameBufferInfo 		// frame buffer information structure
	bl		initFbInfo
	bl		initialize_GPIO

start:
	bl		gameMenu			//return start or quit into r0
	cmp		r0, #0				//Quit
	bleq		exit				//go exit and draw black box


@initial game state if not exit
initialize_values:					//Whenver you press restart, you'd go back here
	@store initial paddle coordinates
	ldr		r4, =paddle_coordinates
	mov		r0, #848			//starting x coordinates for paddle
	str		r0, [r4]			//store current x value
	mov		r1, #780			//starting y coorinates for paddle
	str		r1, [r4, #4]			//store current y value
	@store initial ball coordinates 
	ldr		r5, =ball_coordinates
	mov		r0, #904			//starting x coordinates for ball
	str		r0, [r5]			//store current x value
	mov		r1, #764			//startign y coorinates for ball
	str		r1, [r5, #4]			//store current y value
	mov		r2, #0				//angle = 45, y-direction = up
	str		r2, [r5, #8]			//store the starting angle
	str		r2, [r5, #12]			//store the starting y-direction
	mov		r2, #1				//x-direction = right
	str		r2, [r5, #16]			//store the starting x-direction
	@also initialize brick array
	//do this
	//And intialize lives=3 + score=0
	
initial_pixels:						//initial state, ball still on paddle

	@draw the game
	bl		draw_Background
	
	ldr		r0, =brick_array
	bl		draw_Bricks
	
	ldr		r0, [r4]			//x
	ldr		r1, [r4, #4]			//y
	bl		draw_Paddle			//r0 = x, r1 = y

	ldr		r0, [r5]			//x
	ldr		r1, [r5, #4]			//y
	bl		draw_Ball			//r0 = x, r1 = y

initial_game_state:
	//when button is left, right, B, A, Start
							// read SNES input until button pressed
	bl		Read_SNES
	mov		r7, r0
	mov		r5, #0xffff
	cmp		r0, r5
	beq		initial_game_state
	
	mov		r6, #0				// index of button

init_find_pressed:					// find pressed button
	lsrs		r0, #1				// lsr until 0 found
	blo		init_continue
	add		r6, #1				// increment index by 1 and re-loop
	b		init_find_pressed

init_continue:
	mov		r0, #3000						// wait for user to release button
	bl		delayMicroseconds
	mov		r0, r6	
left_check:
	cmp		r0, #6
	bne		right_check			//Left
	ldr		r1, =paddle_coordinates
	ldr		r2, =ball_coordinates
	lsrs		r7, #9
	movlo		r3, #6
	movhi		r3, #3
	bl		updateInitialState

right_check:
	cmp		r0, #7				//Right
	bne		other_buttons
	ldr		r1, =paddle_coordinates
	ldr		r2, =ball_coordinates
	lsrs		r7, #9
	movlo		r3, #6
	movhi		r3, #3
	bl		updateInitialState

other_buttons:	
	cmp		r0, #0				//B
	bleq		playing_state

	cmp		r0, #3				//Start
	bleq		start_Menu			//Should return restart, or quit
	cmp		r1, #10				//quit
	bleq		start				//go to main menu
	cmp		r1, #1				//Restart	
	bleq		initialize_values//go to initial game state
	cmp		r1, #2				//Start closes menu
	bleq		initial_pixels			//Doing this for now as place holder, actually this works. so..
	//bleq		saved_state			//go to the saved state before pressing start
	
	bl		initial_game_state

saved_state:
	bl		draw_Background
	
	ldr		r0, =brick_array
	bl		draw_Bricks

	ldr		r4, =paddle_coordinates
	ldr		r0, [r4]			//x
	ldr		r1, [r4, #4]			//y
	bl		draw_Paddle			//r0 = x, r1 = y


	ldr		r5, =ball_coordinates
	ldr		r0, [r5]			//x
	ldr		r1, [r5, #4]			//y
	bl		draw_Ball			//r0 = x, r1 = y



playing_state:						//The ball has been released
read_input:						// read SNES input until button pressed
	ldr		r0, =ball_coordinates
	ldr		r1, =paddle_coordinates
	bl		updateBall
	//r0 = if ball hit the floor
	//branch to lose life. and lose life = 0 will branch to game over.
	//Will also return if it hits a brick too? If hits a brick then update bricks
	
	
	bl		Read_SNES
	mov		r7, r0
	mov		r5, #0xffff
	cmp		r0, r5
	beq		read_input	
	mov		r6, #0				// index of button
find_pressed:						// find pressed button
	lsrs 		r0, #1					// lsr until 0 found
	blo		continue
	add		r6, #1				// increment index by 1 and re-loop
	b		find_pressed
continue:						// wait for user to release button	
	//Checks if left or rights being pressed
	mov		r0, r6		
	ldr		r1, =paddle_coordinates
	lsrs	r7, #9
	movlo	r2, #6
	movhi	r2, #3
	bl		updatePlayingStatePaddle
		
	
	mov		r0, r6
	cmp		r0, #3				//Start
	bleq		start_Menu			//Should return restart, or quit
	cmp		r1, #10				//quit
	bleq		start				//go to main menu
	cmp		r1, #1				//Restart	
	bleq		initialize_values//go to initial game state
	cmp		r1, #2				//Start closes menu
	bleq		saved_state			//go to the saved state before pressing start
	
	bl		playing_state
	
	

exit:
	bl			quit_game
	@ stop
	haltLoop$:
		b	haltLoop$

@ Data section
.section .data

paddle_coordinates:
	.int	0, 0

ball_coordinates:	//x, y, 45/60, up/down, left/right
	.int	0, 0, 0, 0, 0 

brick_array:
	.int	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
