extends CharacterBody2D

enum PlayerState {
	idle, 
	jump,
	run
}

@onready var animated_sprite = $AnimatedSprite2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0

var status : PlayerState
var gravity_direction := 1 # 1 = normal, -1 = invertida

func move():
	# Movimento horizontal
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

func go_to_idle_state():
	status = PlayerState.idle
	animated_sprite.play("idle")
func idle_state():
	move()
	if velocity.x !=0:
		go_to_run_state()
		return

	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

func exit_to_idle_state():
	pass
	
func go_to_jump_state():
	status = PlayerState.jump
	animated_sprite.play("jump")
	velocity.y = JUMP_VELOCITY * gravity_direction
func jump_state():
	move()
	if is_on_floor():
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_run_state()
		return
func exit_to_jump_state():
	pass

func go_to_run_state():
	status = PlayerState.run
	animated_sprite.play("run")
func run_state():
	move()
	if velocity.x == 0:
		go_to_idle_state()
		return
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

func exit_to_run_state():
	pass

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	# Alternar gravidade
	if Input.is_action_just_pressed("gravity"):
		gravity_direction *= -1
		
		# Atualiza o "chão"
		up_direction = Vector2.UP * gravity_direction
		
		# Vira o sprite gravidade
		animated_sprite.flip_v = gravity_direction == -1
		
		# Impulso que dá o "feeling bom"
		# 150 → mais suave / 200 → equilíbrio / 250+ → mais arcade / agressivo
		velocity.y = 200 * gravity_direction
		
	# Aplicar gravidade
	if not is_on_floor():
		velocity += get_gravity() * gravity_direction * delta
		
	match status:
		PlayerState.idle:
			idle_state()
		PlayerState.jump:
			jump_state()
		PlayerState.run:
			run_state()
	
	move_and_slide()
