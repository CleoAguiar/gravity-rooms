extends CharacterBody2D

enum PlayerState {
	GROUND,
	AIR
}

@onready var animated_sprite = $AnimatedSprite2D
@onready var tutorial_manager = get_parent().get_node_or_null("TutorialManager")
@onready var jump_particles: GPUParticles2D = $JumpEffect

# Movimento
const SPEED = 200.0
const ACCELERATION = 900.0
const FRICTION = 800.0

# Pulo
const JUMP_FORCE = -300.0
const GRAVITY_FORCE = 900.0

# Feel (polimento)
const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.1

# Gravidade
var gravity_direction := 1 # 1 normal, -1 invertida

# Estado
var state: PlayerState = PlayerState.GROUND

# Timers
var coyote_timer := 0.0
var jump_buffer_timer := 0.0

# Jumps
var max_jumps := 2
var jumps_left := 2

func _ready():
	change_state(PlayerState.GROUND)


# =========================
# 🔁 STATE MACHINE
# =========================

func change_state(new_state: PlayerState):
	if state == new_state:
		return

	match state:
		PlayerState.GROUND:
			exit_ground()
		PlayerState.AIR:
			exit_air()

	state = new_state

	match state:
		PlayerState.GROUND:
			enter_ground()
		PlayerState.AIR:
			enter_air()


# =========================
# 🌍 GROUND STATE
# =========================

func enter_ground():
	animated_sprite.play("idle")
	jumps_left = max_jumps

func ground_state(delta):
	move_horizontal(delta)

	if abs(velocity.x) > 5:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

	coyote_timer = COYOTE_TIME

	if jump_buffer_timer > 0:
		jump()
		return

	if Input.is_action_just_pressed("jump"):
		jump()
		return

	if not is_on_floor():
		change_state(PlayerState.AIR)

func exit_ground():
	pass


# =========================
# 🌌 AIR STATE
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
		# Pulo normal (com coyote)
		if coyote_timer > 0:
			jump()
			return
	
		# Pulo duplo
		elif jumps_left > 0:
			jump()
	
		jump_buffer_timer = JUMP_BUFFER_TIME

	if jump_buffer_timer > 0 and coyote_timer > 0:
		jump()
		return

	if is_on_floor():
		change_state(PlayerState.GROUND)

func exit_air():
	pass


# =========================
# 🎇 EFEITO PARTICULA
# =========================
func play_jump_effect(is_double_jump: bool):
	# Partícula
	if jump_particles:
		jump_particles.restart()
	
	# Squash & Stretch
	var tween = create_tween()
	
	if is_double_jump:
		# Mais exagerado no pulo duplo
		tween.tween_property(animated_sprite, "scale", Vector2(0.7, 1.3), 0.08)
	else:
		tween.tween_property(animated_sprite, "scale", Vector2(0.85, 1.15), 0.08)
	
	tween.tween_property(animated_sprite, "scale", Vector2(1, 1), 0.1)


# =========================
# 🎮 MOVIMENTO
# =========================

func move_horizontal(delta):
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = move_toward(
			velocity.x,
			direction * SPEED,
			ACCELERATION * delta
		)
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			FRICTION * delta
		)

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true


# =========================
# 🦘 PULO
# =========================

func jump():
	var is_double_jump := jumps_left < max_jumps
	velocity.y = JUMP_FORCE * gravity_direction
	
	# Boost pulo duplo mais forte
	if jumps_left == 1:
		velocity.y *= 1.1
	
	jump_buffer_timer = 0
	coyote_timer = 0
	
	jumps_left -= 1
	
	# Ajusta gravidade da partícula corretamente
	var mat = jump_particles.process_material as ParticleProcessMaterial
	if mat:
		mat.gravity = Vector3(0, 300 * gravity_direction, 0)
	
	# Efeito visual
	play_jump_effect(is_double_jump)
	
	change_state(PlayerState.AIR)


# =========================
# 🔄 GRAVIDADE
# =========================

func invert_gravity():
	gravity_direction *= -1

	up_direction = Vector2.UP * gravity_direction
	animated_sprite.flip_v = gravity_direction == -1

	velocity.y = 200 * gravity_direction

	coyote_timer = COYOTE_TIME

	# 🔥 Comunicação com o sistema de tutorial
	if tutorial_manager:
		tutorial_manager.on_gravity_used()


# =========================
# 🔁 LOOP PRINCIPAL
# =========================

func _physics_process(delta):

	if Input.is_action_just_pressed("gravity"):
		invert_gravity()

	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	match state:
		PlayerState.GROUND:
			ground_state(delta)
		PlayerState.AIR:
			air_state(delta)

	move_and_slide()
