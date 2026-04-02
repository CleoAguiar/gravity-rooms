extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -300.0

@onready var animated_sprite = $AnimatedSprite2D

var gravity_direction := 1 # 1 = normal, -1 = invertida

func _physics_process(delta: float) -> void:
	# Alternar gravidade
	if Input.is_action_just_pressed("gravity"):
		gravity_direction *= -1
		
		# Atualiza o "chão"
		up_direction = Vector2.UP * gravity_direction
		
		# Vira o sprite
		animated_sprite.flip_v = gravity_direction == -1
		
		# Impulso que dá o "feeling bom"
		# 150 → mais suave / 200 → equilíbrio / 250+ → mais arcade / agressivo
		velocity.y = 200 * gravity_direction

	# Aplicar gravidade
	if not is_on_floor():
		velocity += get_gravity() * gravity_direction * delta

	# Pulo
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY * gravity_direction

	# Movimento horizontal
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Animações
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	# Movimento
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
