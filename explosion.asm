.include "constants.asm"
.include "macros.asm"

# =================================================================================================
# Explosions
# =================================================================================================

# void explosion_new(x, y)
.globl explosion_new
explosion_new:
enter s0, s1
	move s0, a0  #x
	move s1, a1  #y
	li a0, TYPE_EXPLOSION
	jal Object_new
	beq v0, 0, _set_half
		sw s0, Object_x(v0)
		sw s1, Object_y(v0)
	_set_half:
		li t0, EXPLOSION_HW
		sw t0, Object_hw(v0)
		li t1, EXPLOSION_HH
		sw t1, Object_hh(v0)
		
	li t0, EXPLOSION_ANIM_DELAY
	sw t0, Explosion_timer(v0)
	li t0, 0
	sw t0, Explosion_frame(v0)
leave s0, s1

# ------------------------------------------------------------------------------

.globl explosion_update
explosion_update:
enter s0
	move s0, a0
	lw t0, Explosion_timer(s0)
	beq t0, 0, _next_frame
		sub t0, t0, 1
		sw t0, Explosion_timer(s0)
		j _end_explosion_update
	_next_frame:
		li t1, EXPLOSION_ANIM_DELAY
		sw t1, Explosion_timer(s0)
		lw t2, Explosion_frame(s0)
		add t2, t2, 1
		sw t2, Explosion_frame(s0)
		lw t2, Explosion_frame(s0)
		blt, t2, 6 _end_explosion_update
			move a0, s0
			jal Object_delete
_end_explosion_update:
leave s0

# ------------------------------------------------------------------------------

.globl explosion_draw
explosion_draw:
enter s0
	move s0, a0
	
	move a0, s0	
	lw t0, Explosion_frame(s0)
	mul t0, t0, 4
	la t1, spr_explosion_frames
	add t0, t1, t0
	lw a1, (t0)
	jal Object_blit_5x5_trans	
leave s0
