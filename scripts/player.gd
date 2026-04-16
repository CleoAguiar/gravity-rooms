extends CharacterBody2D

signal gravity_used

enum PlayerState {
	GROUND,
	AIR,
	HIT
}

@onready var animated_sprite = $AnimatedSprite2D
@onready var jump_particles: GPUParticles2D = $JumpEffect
@onready var camera = get_viewport().get_camera_2d()
@onready var gravity_sound: AudioStreamPlayer2D = $GravitySound
@onready var error_sound: AudioStreamPlayer2D = $ErrorSound
@onready var land_sound: AudioStreamPlayer2D = $LandSound

var life := 3
var is_dead := false
var is_invulnerable := false

# Movimento
const SPEED = 200.0
const ACCELERATION = 900.0
const FRICTION = 800.0

# Pulo
const JUMP_FORCE = -300.0
const GRAVITY_FORCE = 900.0

# Feel
const COYOTE_TIME = 0.1

# Gravidade
var gravity_direction := 1
var gravity_active := false

# Energia
var max_gravity_energy := 3.0
var gravity_energy := 3.0
var drain_rate := 2.0
var recharge_rate := 2.5
var air_recharge_rate := 0.0

# Estado
var state: PlayerState = PlayerState.GROUND

# Timers
var coyote_timer := 0.0

# Jumps
var max_jumps := 2
var jumps_left := 2

# Chão / impacto
var was_on_floor := false
var fall_speed := 0.0
var did_double_jump := false

func _ready():
	change_state(PlayerState.GROUND)

# =========================
# RESET PLAYER
# =========================

func reset_state():
	# Movimento
	velocity = Vector2.ZERO
	
	# Estado
	change_state(PlayerState.GROUND)
	
	# Direção visual
	animated_sprite.flip_h = false
	animated_sprite.flip_v = false
	
	# Gravidade
	gravity_active = false
	gravity_direction = 1
	up_direction = Vector2.UP
	
	# Energia
	gravity_energy = max_gravity_energy
	
	# Jump / controle
	jumps_left = max_jumps
	coyote_timer = COYOTE_TIME
	
	# Impacto
	fall_speed = 0.0
	did_double_jump = false
	
	# Animação
	animated_sprite.play("idle")

# =========================
# STATE MACHINE
# =========================

func change_state(new_state: PlayerState):
	if state == new_state:
		return

	state = new_state

	match state:
		PlayerState.GROUND:
			enter_ground()
		PlayerState.AIR:
			enter_air()
		PlayerState.HIT:
			pass

# =========================
# GROUND
# =========================

func enter_ground():
	animated_sprite.play("idle")
	jumps_left = max_jumps
	coyote_timer = COYOTE_TIME

func ground_state(delta):
	move_horizontal(delta)

	if abs(velocity.x) > 5:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

	if Input.is_action_just_pressed("jump"):
		jump()
		return

	if not is_on_floor():
		change_state(PlayerState.AIR)

# =========================
# AIR
# =========================

func enter_air():
	animated_sprite.play("jump")

func air_state(delta):
	move_horizontal(delta)

	velocity.y += GRAVITY_FORCE * gravity_direction * delta
	coyote_timer -= delta

	if velocity.y * gravity_direction > 0:
		animated_sprite.play("fall")

	if Input.is_action_just_pressed("jump"):
		if coyote_timer > 0 or jumps_left > 0:
			jump()

	if is_on_floor():
		change_state(PlayerState.GROUND)

# =========================
# HIT
# =========================

func enter_hit():
	animated_sprite.play("hit")
	await get_tree().create_timer(0.5).timeout
	change_state(PlayerState.GROUND)

func hit_state(delta):
	# desacelera o knockback
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
	# continua aplicando gravidade
	velocity.y += GRAVITY_FORCE * gravity_direction * delta

# =========================
# GRAVIDADE
# =========================

func activate_gravity():
	gravity_active = true
	gravity_direction = -1

	up_direction = Vector2.UP * gravity_direction
	animated_sprite.flip_v = true

	velocity.y = 200 * gravity_direction

	play_gravity_impact()
	hit_stop()

	if camera:
		camera.shake(8.0)
	
	#TutorialManager.on_gravity_used()
	emit_signal("gravity_used")

	if !gravity_sound.playing:
		gravity_sound.pitch_scale = randf_range(0.9, 1.1)
		gravity_sound.play()

func deactivate_gravity():
	gravity_active = false
	gravity_direction = 1

	up_direction = Vector2.UP
	animated_sprite.flip_v = false

	play_gravity_impact()
	hit_stop()

	if camera:
		camera.shake(8.0)

func toggle_gravity():
	if gravity_active:
		deactivate_gravity()
	else:
		if gravity_energy > 0:
			activate_gravity()
		else:
			if !error_sound.playing:
				error_sound.pitch_scale = randf_range(0.95, 1.05)
				error_sound.play()

# =========================
# MOVIMENTO
# =========================

func move_horizontal(delta):
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

# =========================
# PULO
# =========================

func jump():
	var mat = jump_particles.process_material as ParticleProcessMaterial
	var is_double_jump := jumps_left < max_jumps
	
	velocity.y = JUMP_FORCE * gravity_direction
	
	if mat:
		mat.gravity = Vector3(0, 300 * gravity_direction, 0)
	
	if jumps_left == 1:
		velocity.y *= 1.1

	jumps_left -= 1
	coyote_timer = 0
	
	if is_double_jump:
		did_double_jump = true

	velocity.y = JUMP_FORCE * gravity_direction
		
	play_jump_effect(is_double_jump)
	change_state(PlayerState.AIR)

# =========================
# IMPACTOS
# =========================

func play_gravity_impact():
	var tween = create_tween()
	tween.tween_property(animated_sprite, "scale", Vector2(1.3, 0.7), 0.08)
	tween.tween_property(animated_sprite, "scale", Vector2(1, 1), 0.12)

func play_land_feedback():
	var should_play := false

	# Caso 1: queda forte
	if fall_speed > 60:
		should_play = true
	
	# Caso 2: pulo duplo (mesmo que baixo)
	elif did_double_jump and fall_speed > 15:
		should_play = true

	if should_play:
		var strength = clamp(fall_speed / 100.0, 0.5, 1.2)

		land_sound.pitch_scale = randf_range(0.9, 1.1)
		land_sound.volume_db = lerp(-14.0, -6.0, strength)
		land_sound.play()

		var scale_y = lerp(0.9, 0.7, strength)
		var scale_x = lerp(1.1, 1.3, strength)

		var tween = create_tween()
		tween.tween_property(animated_sprite, "scale", Vector2(scale_x, scale_y), 0.05)
		tween.tween_property(animated_sprite, "scale", Vector2(1, 1), 0.1)

	# reset sempre
	fall_speed = 0.0
	did_double_jump = false

# =========================
# HIT STOP
# =========================

func hit_stop(duration := 0.05):
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration).timeout
	Engine.time_scale = 1.0

# =========================
# EFEITOS
# =========================

func play_jump_effect(is_double_jump: bool):
	if jump_particles:
		jump_particles.restart()

	var tween = create_tween()

	if is_double_jump:
		tween.tween_property(animated_sprite, "scale", Vector2(0.7, 1.3), 0.08)
	else:
		tween.tween_property(animated_sprite, "scale", Vector2(0.85, 1.15), 0.08)

	tween.tween_property(animated_sprite, "scale", Vector2(1, 1), 0.1)

# =========================
# DAMAGE
# =========================

func take_damage(amount: int, from_position: Vector2):
	if is_dead or is_invulnerable:
		return
	
	is_invulnerable = true
	life -= amount
	print("Player tomou dano! Vida:", life)
	
	var dir = sign(global_position.x - from_position.x)
	velocity.x = dir * 400
	velocity.y = -180 * gravity_direction
	
	#var direction = (global_position - from_position).normalized()
	#velocity = direction * 200
	change_state(PlayerState.HIT)
	
	await get_tree().create_timer(0.3).timeout
	
	is_invulnerable = false
	
	if is_on_floor():
		change_state(PlayerState.GROUND)
	else:
		change_state(PlayerState.AIR)
	
	if life <= 0:
		die()

# =========================
# DIE
# =========================

func die():
	is_dead = true
	print("Player morreu")
	
	# Aqui você pode:
	# - tocar animação
	# - reiniciar fase
	# - desabilitar movimento
	
# =========================
# LOOP
# =========================

func _physics_process(delta):

	if Input.is_action_just_pressed("gravity"):
		toggle_gravity()

	# Energia
	if gravity_active:
		gravity_energy -= drain_rate * delta

		if gravity_energy <= 0:
			gravity_energy = 0
			deactivate_gravity()
	else:
		if is_on_floor():
			gravity_energy += recharge_rate * delta
		else:
			gravity_energy += air_recharge_rate * delta

	gravity_energy = clamp(gravity_energy, 0, max_gravity_energy)

	# Acumula queda
	if not is_on_floor():
		fall_speed += abs(velocity.y) * delta

	match state:
		PlayerState.GROUND:
			ground_state(delta)
		PlayerState.AIR:
			air_state(delta)
		PlayerState.HIT:
			hit_state(delta)

	move_and_slide()

	var is_on_floor_now = is_on_floor()

	if not was_on_floor and is_on_floor_now:
		play_land_feedback()

	was_on_floor = is_on_floor_now

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hitbox"):
		var enemy = area.get_parent()
		
		if enemy != null and enemy.get("damage") != null:
			take_damage(enemy.damage, enemy.global_position)
