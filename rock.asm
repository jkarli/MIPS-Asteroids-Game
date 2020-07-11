.include "constants.asm"
.include "macros.asm"

# =================================================================================================
# Rocks
# =================================================================================================

.globl rocks_count
rocks_count:
enter
	la t0, objects
	li t1, 0
	li v0, 0

	_rocks_count_loop:
		lw t2, Object_type(t0)
		beq t2, TYPE_ROCK_L, _rocks_count_yes
		beq t2, TYPE_ROCK_M, _rocks_count_yes
		bne t2, TYPE_ROCK_S, _rocks_count_continue
		_rocks_count_yes:
			inc v0
	_rocks_count_continue:
	add t0, t0, Object_sizeof
	inc t1
	blt t1, MAX_OBJECTS, _rocks_count_loop
leave

# ------------------------------------------------------------------------------

# void rocks_init(int num_rocks)
.globl rocks_init
rocks_init:
enter s0, s1, s2
	move s0, a0
	li s1, 0
	_rocks_init_loop:
   		bge s1, s0, _end_rocks_init_loop
		li a0, 0x2000
		jal random
		add v0, v0, 0x3000
		rem s2, v0, 0x4000
		li a0, 0x5000
		jal random
		add v0, v0, 0x3000
		rem a1, v0, 0x4000
		move a0, s2
		li a2, TYPE_ROCK_L
		jal rock_new
    		add s1, s1, 1   		
    		j _rocks_init_loop
_end_rocks_init_loop:
leave s0, s1, s2

# ------------------------------------------------------------------------------

# void rock_new(x, y, type)
rock_new:
enter s0, s1, s2, s3
	move s0, a0
	move s1, a1
	move s2, a2
	move a0, s2
	jal Object_new
	move s3, v0
	beq s3, 0, _bound_box_size
		sw s0, Object_x(s3)
		sw s1, Object_y(s3)
	_bound_box_size:
		li a0, 360
		jal random #generates random angle	
		move a1, v0	
		beq s2, TYPE_ROCK_L, _large_rock
		beq s2, TYPE_ROCK_M, _medium_rock
		beq s2, TYPE_ROCK_S, _small_rock
		_large_rock:
			li t0, ROCK_L_HW
			sw t0, Object_hw(s3)
			li t1, ROCK_L_HH
			sw t1, Object_hh(s3)	
			li a0, ROCK_VEL
			j _set_velocity
		_medium_rock:
			li t0, ROCK_M_HW
			sw t0, Object_hw(s3)
			li t1, ROCK_M_HH
			sw t1, Object_hh(s3)	
			li a0, ROCK_VEL
			mul a0, a0, 4
			j _set_velocity
		_small_rock:
			li t0, ROCK_S_HW
			sw t0, Object_hw(s3)
			li t1, ROCK_S_HH
			sw t1, Object_hh(s3)	
			li a0, ROCK_VEL
			mul a0, a0, 12
			j _set_velocity
	_set_velocity:
		jal to_cartesian
		sw v0, Object_vx(s3)
		sw v1, Object_vy(s3)
leave s0, s1, s2, s3

# ------------------------------------------------------------------------------

.globl rock_update
rock_update:
enter s0
	move s0, a0
	
	move a0, s0
	jal Object_accumulate_velocity
	
	move a0, s0
	jal Object_wrap_position
	
	move a0, s0
	jal rock_collide_with_bullets
leave s0

# ------------------------------------------------------------------------------

rock_collide_with_bullets:
enter s0, s1, s2
	move s0, a0
	la s1, objects
	li s2, 0

	_Object_delete_all_loop:
		lw t0, Object_type(s1)
		bne t0, TYPE_BULLET, _not_bullet_or_in_rock
			move a0, s0
			lw a1, Object_x(s1)
			lw a2, Object_y(s1)
			jal Object_contains_point
			bne v0, 1, _not_bullet_or_in_rock
				move a0, s0
				jal rock_get_hit
				move a0, s1
				jal Object_delete
				j _loop_exit
		_not_bullet_or_in_rock:		
		add s1, s1, Object_sizeof
		add s2, s2, 1
		blt s2, MAX_OBJECTS, _Object_delete_all_loop
_loop_exit:
leave s0, s1, s2

# ------------------------------------------------------------------------------

rock_get_hit:
enter s0, s1
	move s0, a0
	lw s1, Object_type(s0)
	beq s1, TYPE_ROCK_L, _split_large
	beq s1, TYPE_ROCK_M, _split_medium
	j _end_rock_get_hit	
	 _split_large:
	 	lw a0, Object_x(s0)
	 	lw a1, Object_y(s0)
	 	li a2, TYPE_ROCK_M
	 	jal rock_new
	 	lw a0, Object_x(s0)
	 	lw a1, Object_y(s0)
	 	li a2, TYPE_ROCK_M
	 	jal rock_new
	 	j _end_rock_get_hit
	 _split_medium:
	 	lw a0, Object_x(s0)
	 	lw a1, Object_y(s0)
	 	li a2, TYPE_ROCK_S
	 	jal rock_new
	 	lw a0, Object_x(s0)
	 	lw a1, Object_y(s0)
	 	li a2, TYPE_ROCK_S
	 	jal rock_new 
_end_rock_get_hit:
	lw a0, Object_x(s0)
	lw a1, Object_y(s0)
	jal explosion_new
	move a0, s0
	jal Object_delete
leave s0, s1

# ------------------------------------------------------------------------------

.globl rock_collide_l
rock_collide_l:
enter
	jal rock_get_hit
	li a0, 3
	jal player_damage
leave

# ------------------------------------------------------------------------------

.globl rock_collide_m
rock_collide_m:
enter
	jal rock_get_hit
	li a0, 2
	jal player_damage
leave

# ------------------------------------------------------------------------------

.globl rock_collide_s
rock_collide_s:
enter
	jal rock_get_hit
	li a0, 1
	jal player_damage
leave

# ------------------------------------------------------------------------------

.globl rock_draw_l
rock_draw_l:
enter
	la a1, spr_rock_l
	jal Object_blit_5x5_trans
leave

# ------------------------------------------------------------------------------

.globl rock_draw_m
rock_draw_m:
enter
	la a1, spr_rock_m
	jal Object_blit_5x5_trans
leave

# ------------------------------------------------------------------------------

.globl rock_draw_s
rock_draw_s:
enter
	la a1, spr_rock_s
	jal Object_blit_5x5_trans
leave
