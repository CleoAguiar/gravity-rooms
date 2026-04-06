extends CharacterBody2D

enum PlayerState {
	GROUND,
	AIR
}

@onready var animated_sprite = $AnimatedSprite2D

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

func _ready():
	change_state(PlayerState.GROUND)

# =========================
# 🔁 STATE MACHINE
# =========================

func change_state(new_state: PlayerState):
	if state == new_state:
		return

	# EXIT
	match state:
		PlayerState.GROUND:
			exit_ground()
		PlayerState.AIR:
			exit_air()

	state = new_state

	# ENTER
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

func ground_state(delta):
	move_horizontal(delta)

	# Atualiza animação
	if abs(velocity.x) > 5:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

	# Reset coyote
	coyote_timer = COYOTE_TIME

	# Jump buffer
	if jump_buffer_timer > 0:
		jump()
		return

	# Input de pulo
	if Input.is_action_just_pressed("jump"):
		jump()
		return

	# Caiu do chão
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

	# Gravidade
	velocity.y += GRAVITY_FORCE * gravity_direction * delta

	# Atualiza coyote
	coyote_timer -= delta

	# Detecta subida/queda
	if velocity.y * gravity_direction > 0:
		animated_sprite.play("fall")

	# Jump buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME

	# Executa pulo se ainda estiver no coyote
	if jump_buffer_timer > 0 and coyote_timer > 0:
		jump()
		return

	# Aterrissagem
	if is_on_floor():
		change_state(PlayerState.GROUND)

func exit_air():
	pass

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

	# Flip sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

# =========================
# 🦘 PULO
# =========================

func jump():
	velocity.y = JUMP_FORCE * gravity_direction
	jump_buffer_timer = 0
	coyote_timer = 0
	change_state(PlayerState.AIR)

# =========================
# 🔄 GRAVIDADE
# =========================

func invert_gravity():
	gravity_direction *= -1

	up_direction = Vector2.UP * gravity_direction
	animated_sprite.flip_v = gravity_direction == -1

	# Impulso pra dar feeling
	velocity.y = 200 * gravity_direction

	# Pequena tolerância pós-inversão
	coyote_timer = COYOTE_TIME

# =========================
# 🔁 LOOP PRINCIPAL
# =========================

func _physics_process(delta):

	# Input global
	if Input.is_action_just_pressed("gravity"):
		invert_gravity()

	# Atualiza buffer
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	# Máquina de estados
	match state:
		PlayerState.GROUND:
			ground_state(delta)
		PlayerState.AIR:
			air_state(delta)

	move_and_slide()
