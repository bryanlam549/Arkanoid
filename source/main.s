//TODO: value packs


.global main, brick_array, life_Score, ball_coordinates, value_Pack_On_Map, paddle_coordinates
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
	@initialize value pack positions
	ldr		r0, =value_Pack_On_Map
	mov		r1, #0
	str		r1, [r0]
	str		r1, [r0, #8]
	mov		r1, #396		//ones on the first rwo
	str		r1, [r0, #4]
	mov		r1, #300		//ones on the second row
	str		r1, [r0, #12]
	
	@also initialize brick array
	mov		r3, #3				// brick 3
	mov		r2, #2				// brick 2
	mov		r1, #1				// brick 1
	
	ldr		r0, =brick_array	// brick array
	mov		r4, #-1				//increment variable
	bl		test_brick_array
initialize_brick_array:
	cmp		r4, #10
	strlt	r3, [r0, r4, lsl #2]
	blt		test_brick_array
	cmp		r4, #20
	strlt	r2, [r0, r4, lsl #2]
	blt		test_brick_array
	cmp		r4, #30
	strlt	r1, [r0, r4, lsl #2]
	blt		test_brick_array
	
test_brick_array:
	add		r4, #1
	cmp		r4, #30
	blt		initialize_brick_array
	
	@initialize lives and score
	mov		r0, #3
	mov		r1, #0
	ldr		r2, =life_Score
	str		r0, [r2]
	str		r1, [r2, #4]
	b		initial_pixels
	
initialize_values_after_life_lost:	//Whenver you lose a life. But don't reset lives, score or brick arrays
	@Erase value packs images after death
	ldr		r0, =value_Pack_On_Map
	ldr		r1, [r0]
	cmp		r1, #1
	moveq	r1, #0
	streq	r1, [r0]
	ldr		r1, [r0, #8]
	cmp		r1, #1
	moveq	r1, #0
	streq	r1, [r0]
	
	@game over if life = 0
	ldr		r0, =life_Score
	ldr		r1, [r0]
	cmp		r1, #0
	blt		game_Over			//should be gameover
	
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
	
initial_pixels:						//initial state, ball still on paddle

	@draw the game
	bl		draw_Background

	ldr		r0, =brick_array
	bl		draw_Bricks
	
	bl		draw_Lives_Score
	ldr		r0, =life_Score
	ldr		r0, [r0]
	mov		r1, #1224
	mov		r2, #0x00FF0000
	bl		draw_Char
	ldr		r0, =life_Score
	ldr		r0, [r0, #4]
	bl		draw_Score_Char
	
	ldr		r4, =paddle_coordinates
	ldr		r0, [r4]			//x
	ldr		r1, [r4, #4]			//y
	bl		draw_Paddle			//r0 = x, r1 = y

	ldr		r5, =ball_coordinates
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

	@TODO: Add value pack scores: 
	cmp			r2, #1
	ldreq		r0, =life_Score
	ldreq		r0, [r0, #4]
	//ldreq		r1, =value_pack_score
	//ldreq		r1, [r1]
	//add		r0, r1
	bleq		draw_Score_Char

	//Also update score when you get a value pack

	@checks win: Checks only score of bricks
	ldr		r0, =life_Score
	ldr		r0, [r0, #4]
	cmp		r0, #60
	beq		winner
	
	@checks lose life and lose
	cmp		r3, #1				//Means you hit the floor
	ldreq	r1, =life_Score
	ldreq	r2, [r1]
	subeq	r2, #1
	streq	r2, [r1]
	beq		initialize_values_after_life_lost
	
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
	movlo	r2, #4
	movhi	r2, #2
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
	bl		exit

winner:
	bl			draw_Winner
	bl			find_Button
	bl			start

game_Over:
	bl			draw_Game_Over
	bl			find_Button
	bl			start
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
	.int	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

life_Score:			//life, score
	.int	3, 0
	
value_Pack_On_Map:
	.int	0, 396, 0, 332	//valuepack1, y-coordinate, valuepack2 and y-coordinate
						//valuepack1&2 = 1 on map, = 0 not on map
