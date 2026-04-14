extends CharacterBody2D

# =========================
# ESTADOS (SEUS STATES)
# =========================
enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	GROUND,
	ATTACK,
	HIT,
	DEAD
}

var current_state = State.IDLE

# =========================
# CONFIG
# =========================
@export var speed := 40.0
@export var jump_force := -250.0
@export var gravity := 900.0
@export var max_health := 3
@export var damage := 1

# Gravidade invertida
var gravity_direction := 1 # 1 normal | -1 invertida

# =========================
# REFERÊNCIAS
# =========================
@onready var sprite = $AnimatedSprite2D

# =========================
# VARIÁVEIS
# =========================
var health := max_health
var direction := -1
var player = null
var level

# =========================
# READY
# =========================
func _ready():
	change_state(State.IDLE)
	print("mask:", $Hitbox.collision_mask)

# =========================
# LOOP
# =========================
func _physics_process(delta):
	apply_gravity(delta)
	update_state()
	handle_state(delta)
	move_and_slide()

# =========================
# GRAVIDADE
# =========================
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * gravity_direction * delta

func invert_gravity():
	gravity_direction *= -1
	scale.y *= -1

# =========================
# STATE MACHINE
# =========================
func change_state(new_state):
	if current_state == new_state:
		return
	
	current_state = new_state
	
	match current_state:
		State.IDLE:
			sprite.play("idle")
		
		State.RUN:
			sprite.play("run")
		
		State.JUMP:
			sprite.play("jump")
		
		State.FALL:
			sprite.play("fall")
		
		State.GROUND:
			sprite.play("ground") # opcional
		
		State.ATTACK:
			sprite.play("attack")
		
		State.HIT:
			sprite.play("hit")
		
		State.DEAD:
			sprite.play("dead")

# =========================
# ATUALIZAÇÃO AUTOMÁTICA
# =========================
func update_state():
	if current_state == State.DEAD or current_state == State.HIT:
		return
	
	if not is_on_floor():
		if velocity.y * gravity_direction < 0:
			change_state(State.JUMP)
		else:
			change_state(State.FALL)
		return
	
	# Está no chão
	if abs(velocity.x) > 5:
		change_state(State.RUN)
	else:
		change_state(State.IDLE)

# =========================
# COMPORTAMENTO
# =========================
func handle_state(_delta):
	if current_state == State.DEAD:
		velocity = Vector2.ZERO
		return
	
	# IA simples: patrulha
	patrol()

func patrol():
	velocity.x = direction * speed
	
	if is_on_wall():
		direction *= -1
		flip()

# =========================
# UTIL
# =========================
func flip():
	sprite.flip_h = direction > 0

# =========================
# DANO
# =========================
func take_damage(amount):
	if current_state == State.DEAD:
		return
	
	health -= amount
	change_state(State.HIT)
	
	if health <= 0:
		die()

func die():
	change_state(State.DEAD)
	velocity = Vector2.ZERO
	
	await sprite.animation_finished
	queue_free()

func apply_level_scale(scale_value: float):
	$AnimatedSprite2D.scale = Vector2(scale_value, scale_value)

func setup(_level, _player):
	level = _level
	player = _player

func _on_hitbox_body_entered(body: Node2D) -> void:
	print("entrou:", body.name)
	if body.is_in_group("player"):
		body.take_damage(damage)
		print("hit player")
