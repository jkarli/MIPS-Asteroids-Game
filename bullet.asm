.include "constants.asm"
.include "macros.asm"

# =================================================================================================
# Bullet
# =================================================================================================

# void bullet_new(x: a0, y: a1, angle: a2)
.globl bullet_new
bullet_new:
enter s0, s1, s2, s3
	move s0, a0
	move s1, a1
	move s2, a2
	li a0, TYPE_BULLET
	jal Object_new
	move s3, v0
	beq s3, 0, _set_velocity
		sw s0, Object_x(s3)
		sw s1, Object_y(s3)
	_set_velocity:
		li a0, BULLET_THRUST
		move a1, s2
		jal to_cartesian
		sw v0, Object_vx(s3)
		sw v1, Object_vy(s3)		
	li t0, BULLET_LIFE
 	sw t0, Bullet_frame(s3)		
_end_bullet_new:
leave s0, s1, s2, s3

# ------------------------------------------------------------------------------

.globl bullet_update
bullet_update:
enter
	lw t0, Bullet_frame(a0)
	sub t0, t0, 1
	sw t0, Bullet_frame(a0)
	lw t0, Bullet_frame(a0)
	bne t0, 0 _bullet_active
		jal Object_delete
		j _end_bullet_update
	_bullet_active:
		jal Object_accumulate_velocity
		jal Object_wrap_position
_end_bullet_update:
leave

# ------------------------------------------------------------------------------

.globl bullet_draw
bullet_draw:
enter s0
	move s0, a0
	lw a0, Object_x(s0)
	sra a0, a0, 8
	lw a1, Object_y(s0)
	sra a1, a1, 8
	li a2, COLOR_RED
	jal display_set_pixel
leave s0
