## Lance Reyes RedID: 823963277
## COMPE 271 PROJECT: Battleship
## May 2, 2022

##line up comments on same columns

.data

## prompts:
opening: 	    .asciiz "Welcome to Battleship \n"
row_prompt: 	    .asciiz "Enter a row range 0-7: \n"
column_prompt:      .asciiz "Enter a column range 0-7: \n"
restart:	    .asciiz "Would you like to play again? \n"
end_prompt:         .asciiz "Game has ended. Thanks for playing! \n "


cannon_ball_prompt: .asciiz "Number of cannonballs left: "
hit_prompt:	    .asciiz " of 15 targets hit \n"
combo_prompt:	    .asciiz "Combos: " 		
combo3_prompt:	    .asciiz "Combos of 3 rewards +1 cannonball"
combo6_prompt:	    .asciiz "Combos of 6 rewards +3 cannonball"
subtract_prompt:    .asciiz " cannonballs were lost"

## game ending prompts:
mine_hit:	    .asciiz "A mine was hit game over! \n"
no_cannonballs:	    .asciiz "No more cannonballs to fire: YOU LOSE! \n"
all_targets_hit:    .asciiz "All targets were hit: WINNER! \n"	

			
hit: 		    .byte '*'		## If target is hit
miss: 		    .byte 'X'		## If target is a miss
mine: 		    .byte '!'		## If a mine was struck, leads to game over
cannon_sub: 	    .byte '-'  		## If these are hit 0-3 cannonballs are lost


vertical: 	    .asciiz "|"
horizontal: 	    .asciiz "  -----------------"
newline: 	    .asciiz "\n" 
spacing: 	    .asciiz " " 	## used for alignment and reset char array
spacing1: 	    .asciiz "   "       ## used to align column numbers

## rules
rule1: 		    .asciiz "'*' == target hit \n"
rule2: 		    .asciiz "'X' == miss \n"
rule3: 		    .asciiz "'-' == cannonball(s) deducted \n"
rule4: 		    .asciiz "'!' == game over \n"
rule5: 		    .asciiz "Symbols can't be hit again"

num_count: 	    .word 0,1,2,3,4,5,6,7	## used for row and column numbers

#1 integer = 4 bytes
## Intialize Integer array with zeros
array: 		    .word 0,0,0,0,0,0,0,0,
	    	          0,0,0,0,0,0,0,0,
	    	          0,0,0,0,0,0,0,0,
	                  0,0,0,0,0,0,0,0,
	                  0,0,0,0,0,0,0,0,
	                  0,0,0,0,0,0,0,0,
	                  0,0,0,0,0,0,0,0,
	                  0,0,0,0,0,0,0,0,
#1 char = 1 byte     
## Intilalize the char array with white space   		
play_array: 	    .byte  ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
		           ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
		           ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
		           ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
		           ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
     		           ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
		           ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
		           ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',

.text

main:		
	jal 	refresh_byte_array	## refresh arrays when user wants to restart
	jal 	refresh_int_array
			
	li 	$v0, 4
	la 	$a0, opening
	syscall
	
	addi 	$s3, $zero, 30 		## amount of cannonballs		
	addi 	$s4, $zero, 0 		## count for targets hit
	addi 	$s5, $zero, 0		## count for amount of combos
	
	jal 	set_elements
	
game_start:	
	beq 	$s3, 0 game_over	## while (cannonball_count != 0) 
	
	jal	 state_rules
	
	jal 	 print_grid  		## test code, enable this to print out the int array
	
	jal 	print_newline 
	jal 	print_grid_byte
	jal	combo_check
	jal 	display_counts
	jal 	store_input 		##collect user input into $t0(row wanted) and $t1 (column wanted)
	
	addi 	$s2,$zero 8		## total columns 

	mul 	$t0, $t0, $s2   	## x = row wanted* total columns, x is stored in $t0
  	add 	$t4, $t0, $t1   	## output = x + column wanted, location is stored in $t4
  	
  	sll 	$t4, $t4, 2 		## shift $t4 by 2 to get the correct postion in the int array
  	lw 	$t5, array($t4)   	## accesses array at position and stores into $t5
  	
  	addi	$t6, $zero, 5		## stores 5 in the array position, so position can't be selected again
  	sw	$t6, array($t4)		
  
  	
  	bne 	$t5, 0, skip0		## if (int_array value == 0)	
  	srl 	$t4, $t4, 2
  	lb	$a2, miss 
  	sb	$a2, play_array($t4)
  	addi 	$s3, $s3,   -1		## subtract cannonball count	
  	addi 	$s5, $zero, 0		## make combo count zero
  	
  	
 skip0:	
  	bne 	$t5, 1, skip1		## if (int_array value == 1)	
  	srl 	$t4, $t4, 2
  	lb	$a2, hit 
  	sb	$a2, play_array($t4)
  	addi 	$s4, $s4, 1 		 ## count for targets hit#
  	addi 	$s3, $s3,-1	 	 ## subtract cannonball count
  	addi 	$s5, $s5, 1 		 ## up combo count
  	bne	$s4, 15, skip1		 ## if all the targets were hit end the game 
  	la 	$a3, all_targets_hit
  	j 	game_over
  	
  	
 skip1:
  	bne 	$t5, 2, skip2		## if (int_array value == 2)	
  	srl 	$t4, $t4, 2
  	lb	$a2, mine 
  	sb	$a2, play_array($t4)
  	la 	$a3, mine_hit		## $a3 will be passed into label print_end_prompt
  	j 	game_over		## end game
  	
  	
  	
 skip2:	
	bne 	$t5, 3, skip3		## if (int_array value == 3)	
  	srl 	$t4, $t4, 2
  	lb	$a2, cannon_sub 
  	sb	$a2, play_array($t4)
  	jal	get_num			## get rng num
  	move 	$s6, $a0		## move num to register s6
  	move	$s7, $t5		## move value stored in array position to s7 (s7 used in deduct cannonballs label)
  	sub 	$s3, $s3, $s6  		## subtract cannonball count range from 0-3
  	addi 	$s5, $zero, 0 		## make combo count zero
  	
  	
 skip3:	
	j 	game_start			


game_over:
	bne 	$s3, 0, game_end1		## if (cannonballs == 0) 
	la 	$a3, no_cannonballs		## print the end game prompt when cannonballs = 0
	
game_end1:
	
	## print the end results
	jal 	print_grid_byte	
	jal	print_end_prompt	
	jal 	display_counts

	la 	$a0, restart
	li 	$v0, 50
	syscall

	bne 	$a0, 0, end		## If (user input == 0)	 ## for a0 yes -> 0, no -> 1 
	j 	main			##	jump to main(restart) 

end:					##else end program	 
	
	li 	$v0, 4
	la 	$a0, end_prompt
	syscall
	


exit:
	li 	$v0, 10
	syscall



print_horizontal: ## prints horizontal line _
	la 	$a0, horizontal
	li 	$v0, 4
	syscall
	jr 	$ra


print_vertical: ## prints vertical line |
	la 	$a0, vertical
	li 	$v0, 4
	syscall
	jr 	$ra
	

print_newline: ## prints newline
	la 	$a0, newline
	li 	$v0, 4
	syscall
	jr 	$ra
	
print_space: ## prints space
	la 	$a0, spacing
	li 	$v0, 4
	syscall
	jr 	$ra


print_grid:	## prints out the int array,(label was used to help compare my int array and char array for play testing )
	
	## Intialize registers to 0
	addi 	$t4, $zero, 0  ## holds value in array postion
	addi 	$t5, $zero, 0  ## used to access array postion
	addi 	$t6, $zero, 0  ## column count
	addi 	$t8, $zero, 0  ## row count	

	sw 	$ra, 0($sp)	
	jal 	print_column_num  
	jal 	print_newline 
	jal 	print_horizontal
	jal 	print_newline
	jal	print_row_num
	
	
	while1:
	beq 	$t5, 256, after_grid

	jal 	print_vertical

	lw 	$t4, array($t5)
	addi 	$t5, $t5, 4		## goes through 2D array	

	bne 	$t6, 8, after1   	## if $t6 == 8 print the new line and set $t6 to zero 
	jal 	print_newline   	## else skipr to after1 and add 1 to $t6
	jal 	print_horizontal
	jal 	print_newline
	jal	print_row_num
	jal 	print_vertical	
	addi 	$t6, $zero, 0

	after1:
	addi 	$t6, $t6, 1

	#prints value
	li 	$v0, 1
	move 	$a0, $t4
	syscall

	j 	while1

	after_grid:	    	## jumpts to here after the while loop in print_grid is ran		
	jal 	print_vertical  ## prints the last vertical line
	jal 	print_newline
	jal 	print_horizontal
	
	lw 	$ra, 0($sp)
	jr	$ra



print_grid_byte:

	## intialize registers to 0
	addi 	$t4, $zero, 0  ## holds value in array postion
	addi 	$t5, $zero, 0  ## used to access array postion
	addi 	$t6, $zero, 0  ## column count
	addi 	$t8, $zero, 0  ## row count	

	sw 	$ra, 0($sp)
	jal 	print_column_num  
	jal 	print_newline 
	jal 	print_horizontal
	jal 	print_newline
	jal 	print_row_num 
	
	while2:
	
	beq 	$t5, 64, after_grid1

	jal print_vertical

	lb 	$t4, play_array($t5)
	addi 	$t5, $t5, 1		## goes through 2D array		

	bne 	$t6, 8, after2  	 ## if $t6 == 8 print the new line and set $t6 to zero 
	jal 	print_newline   	 ## else skipr to after2 and add 1 to $t6
	jal 	print_horizontal
	jal 	print_newline	
	jal 	print_row_num 	
	jal 	print_vertical	
	addi 	$t6, $zero, 0

	after2:
	
	addi 	$t6, $t6, 1

	#prints char 
	li 	$v0, 11
	move 	$a0, $t4
	syscall

	j while2
	

	after_grid1:	   		 ## jumpts to here after the while loop in print_grid is ran		
	jal 	print_vertical  	 ## prints the last vertical line
	jal 	print_newline
	jal 	print_horizontal
	
	lw 	$ra, 0($sp)
	jr	$ra



print_column_num:
	addi 	$t7, $zero, 0
	li 	$v0, 4
	la 	$a0, spacing1
	syscall


	while_col:

	beq  	$t7, 32, after_while  # 8 rows (0-7), 8*4= 32

	lw 	$t9, num_count($t7)
	addi 	$t7, $t7, 4
	
	li 	$v0, 1
	move 	$a0, $t9
	syscall

	li 	$v0, 4
	la 	$a0, spacing
	syscall

	j 	while_col

	after_while:

	jr 	$ra


print_row_num:
	beq  	$t8, 32, after_while1

	lw 	$t9, num_count($t8)
	addi 	$t8, $t8, 4

	li 	$v0, 1
	move	 $a0, $t9
	syscall

	li 	$v0, 4
	la 	$a0, spacing
	syscall

	after_while1:

	jr 	$ra



state_rules:
	addi 	$sp, $sp, -4	## make room 
	sw 	$ra, 0($sp) 	## store the main address stored  in $ra
	
	jal 	print_newline

	la 	$a0, rule1
	syscall

	la 	$a0, rule2
	syscall

	la 	$a0, rule3
	syscall

	la 	$a0, rule4
	syscall

	la 	$a0, rule5
	syscall

	jal 	 print_newline
	jal	 print_newline
	
	lw 	$ra, 0($sp)		## load main address to $ra
	jr 	$ra


store_input: 	## move collected inputs to registers t0 and t1

	sw 	$ra, 0($sp)
	
	jal 	print_newline

	la 	$a0, row_prompt
	syscall

	li 	$v0, 5
	syscall

	move	$t0, $v0 	## input moved to register t0

	li 	$v0, 4
	la 	$a0, column_prompt
	syscall

	li 	$v0, 5
	syscall

	move 	$t1, $v0	##input moved to register t1
	
	lw 	$ra, 0($sp)

	jr 	$ra
	
	
	
get_num: ## randomly generates numbers

	 ## lfsr used to create random numbers
	 ## Code used is from TA: Hanieh Moein but is modified to print out only 1 digit
	
	 ## syscall 42 random int range
	 ## $a0 has a randomized seed
	 ## $a1 has the upper bound limit
	
	sw 	$ra, -4($sp)	## make more room
	
	li	$v0, 42 
	li 	$a1, 16 	## range is up to 15
	syscall

## based on TA: Hanieh Moein code for lfsr and is slightly modified
######################################################################################################################################################################
	move	$s1, $a0 ## random int is moved		
	move 	$s6, $s1 ## random seed is copied 
	
	jal 	RAND4 	## is returned in V0 
	
	move 	$a0, $v0				
######################################################################################################################################################################
## end of used code
	
	div	$a0, $a0, 4				## range: numbers 0-3	
	
	lw 	$ra, -4($sp)
	jr 	$ra						
	
	
	
	
	
## Used code from TA Hanieh Moein and is unmodified
############################################################################################################################################################

RAND4:

	move 	$t0, $s1 ### R1 and R2 
	move 	$t1, $s1 

	#srl $t0, $t0, 0 ### x1 
	andi 	$t0, $t0, 1 ### R4 R3 R2 R1 & 1 = 0 0 0 R1

	srl 	$t1, $t1, 1 ##### R4 R3 R2 R1 >> 1 = 0 R4 R3 R2
	andi 	$t1, $t1, 1 ### 0 R4 R3 R2 & 1 = 0 0 0 R2


	xor 	$t2, $t1, $t0 #### y = R2 xor R1

	bnez 	$t2, else ### Y 0

	### y ==0 
	srl 	$s1, $s1 , 1 ### 0 X4 X3 X2 : final number
	move 	$v0, $s1
	jr 	$ra 

else:
	###y ==1 
	srl 	$s1, $s1, 1 ### X >> 1 :  0 X4 X3 X2
	sll 	$t2,$t2, 3 ### Y << 3:  	Y 0  0  0
	or 	$s1, $t2, $s1 ### Xnew :    Y X4 X3 X2 final number
	
	
	move	$v0, $s1
	jr 	$ra 
								## end of used code from TA
#####################################################################################################################################################################


## will set the int array with random numbers 
set_elements:			
	
	## reset values before accessing array 
	addi 	$t4, $zero, 0   ##  used to store $a0
	addi 	$t5, $zero, 0   ## used to access array postion
							
	addi 	$t6, $zero, 0	## 1's count	need 15
	addi 	$t7, $zero, 0	## 2's count	need 2
	addi 	$t3, $zero, 0	## 3's count	need 8
	
											
	sw 	$ra, 0($sp)
	
	while3:
	beq 	$t5,256, after_while3
	jal 	get_num 			## rng number stored in $a0
	
	move 	$t4, $a0
	
	
	## checks for 1
	beq 	$t6, 15, skip_one_check		## if (x_count != 15) 
	bne 	$t4, 1,  skip_one_check		## if(random number == 1)
	sw  	$t4, array($t5)
	addi 	$t6, $t6, 1 
	
	skip_one_check: 			## check for 2
	beq 	$t7, 3, skip_two_check		## if (y_count != 3) 
	bne 	$t4, 2, skip_two_check		## if(random number == 2)
	sw  	$t4, array($t5)
	addi 	$t7, $t7, 1 
	
	skip_two_check: 			## checks for 3
	beq 	$t3, 8, skip_three_check	## if (z_count != 8) 
	bne 	$t4, 3, skip_three_check	## if(random number == 3)
	sw  	$t4, array($t5)
	addi 	$t3, $t3, 1 
	
	skip_three_check: 			## checks for 0
	bne $t4, 0, skip_zero_check
	sw  	$t4, array($t5)			## if(random number == 0)

	skip_zero_check:
	addi 	$t5,$t5,4
	j 	while3
	
	
	after_while3: 	## fill array with 1's based on whats left of the count
	
	## reset to 0
	addi 	$t5, $zero, 0  ## used to access array postion
	
	
	pad:	## pads more ones just in case intial doesnt include enough
	beq 	$t6, 15, skip			## if (x_count != 15) 
		
	lw	$t4, array($t5)	
	bne 	$t4, 0, skip_inner	## if(array position value == 0)
	addi	$t4, $t4, 1
	sw  	$t4, array($t5)		## change 0 to 1 and store it back in
	addi 	$t6, $t6, 1 		## 1 count
		
	skip_inner:
	addi 	$t5,$t5,4
	j pad
	
	skip: 
	
	lw 	$ra, 0($sp)	## load main address to $ra
	jr 	$ra

display_counts:			## shows the count for cannonballs left, and how many hits and combos
	sw 	$ra, 0($sp)
		
	jal 	print_newline
		
	li 	$v0, 4
	la 	$a0, cannon_ball_prompt
	syscall
		
	li	$v0, 1
	move	 $a0, $s3
	syscall
		
	jal print_newline
		
	li	$v0, 1
	move	 $a0, $s4
	syscall

	li 	$v0, 4
	la 	$a0, hit_prompt
	syscall
		
		
	li 	$v0, 4
	la 	$a0, combo_prompt
	syscall
		
	li	$v0, 1
	move	$a0, $s5
	syscall
		
	jal 	print_newline
		
	bne 	$s7, 3, next2
	jal 	deduct_cannonballs_prompt
		
	next2:
	addi 	$s7, $zero, 0	## make s7 0 so the deduct cannonballs prompt only appears when s7 is 3
		 
	lw 	$ra, 0($sp)
	jr 	$ra

print_end_prompt:		# prompts are passed to $a3 and moved to $a0
	sw 	$ra, 0($sp)
	jal 	print_newline
	
	li 	$v0, 4
	move 	$a0, $a3
	syscall
	
	lw 	$ra, 0($sp)
	jr 	$ra
	
	
combo_check:			## ups the cannonball count when combos are hit
	sw 	$ra, 0($sp)
	jal 	print_newline
	
	bne 	$s5,3, next		
	addi 	$s3, $s3, 1
	li 	$v0, 4
	la 	$a0, combo3_prompt
	syscall
		
	next:
	bne 	$s5,6, next1
	addi 	$s3, $s3, 3
	li 	$v0, 4
	la 	$a0, combo6_prompt
	syscall
	
	next1:
	lw 	$ra, 0($sp)
	jr	$ra

deduct_cannonballs_prompt:	## prints the statement on the amount of cannonballs were lost when landing on a '-'
	li 	$v0, 1 
	move	$a0, $s6
	syscall
	
	li 	$v0, 4
	la 	$a0, subtract_prompt
	syscall
	
	jr $ra


refresh_byte_array:
	addi 	$t5, $zero, 0  ## holds " "
	addi 	$t6, $zero, 0  ## holds count
	
	lb 	$t5, spacing
	
	while_loop:
	beq 	$t6, 64, return
	sb 	$t5, play_array($t6)
	addi 	$t6, $t6, 1
	j 	while_loop
	
	return:
	## refresh registers
	addi 	$t5, $zero, 0  ## used to access array postion
	addi 	$t6, $zero, 0  ## column count
	
	jr $ra
	
refresh_int_array:
	addi 	$t6, $zero, 0  ## holds count
		
	while_loop2:
	beq 	$t6, 256, return2
	sw 	$zero, array($t6)
	addi 	$t6, $t6, 4
	j 	while_loop2
	
	return2:
	## refresh registers
	addi 	$t6, $zero, 0  ## column count
	
	jr 	$ra
	
	

