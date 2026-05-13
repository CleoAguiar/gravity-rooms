extends CharacterBody2D

# =========================
# REFERÊNCIAS
# =========================
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox
@onready var wall_raycast: RayCast2D = $WallRayCast
@onready var floor_raycast: RayCast2D = $FloorRayCast

# =========================
# ESTADOS (SEUS STATES)
# =========================
enum EnemyState {
	IDLE,
	RUN,
	JUMP,
	FALL,
	GROUND,
	ATTACK,
	HIT,
	DEAD
}

var current_state = EnemyState.IDLE

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

# Ataque
@export var attack_range := 50.0
@export var attack_cooldown := 1.0

var can_attack := true
var is_attacking := false

# =========================
# VARIÁVEIS
# =========================
var health := max_health
var is_hit := false
var dead = false
var direction := -1
var player = null
var level

# =========================
# READY
# =========================
func _ready():
	change_state(EnemyState.IDLE)
	#print("mask:", $Hitbox.collision_mask)

# =========================
# LOOP
# =========================
func _physics_process(delta):
	apply_gravity(delta)
	update_state()
	handle_state(delta)
	move_and_slide()

# =========================
# HITBOX
# =========================

func _on_hitbox_body_entered(body: Node2D):
	if current_state == EnemyState.DEAD:
		return
	
	if body.is_in_group("player"):
		body.take_damage(damage, position)

# =========================
# HURTBOX
# =========================

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if dead:
		return
	
	if area.is_in_group("player_attack"):
		take_damage(1)

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
		EnemyState.IDLE:
			sprite.play("idle")
		
		EnemyState.RUN:
			sprite.play("run")
		
		EnemyState.JUMP:
			sprite.play("jump")
		
		EnemyState.FALL:
			sprite.play("fall")
		
		EnemyState.GROUND:
			sprite.play("ground") # opcional
		
		EnemyState.ATTACK:
			sprite.play("attack")
		
		EnemyState.HIT:
			sprite.play("hit")
		
		EnemyState.DEAD:
			sprite.play("dead")

# =========================
# ATUALIZAÇÃO AUTOMÁTICA
# =========================
func update_state():
	if current_state == EnemyState.DEAD \
	or current_state == EnemyState.HIT \
	or current_state == EnemyState.ATTACK:
		return
	
	if not is_on_floor():
		if velocity.y * gravity_direction < 0:
			change_state(EnemyState.JUMP)
		else:
			change_state(EnemyState.FALL)
		return
	
	# Está no chão
	if abs(velocity.x) > 5:
		change_state(EnemyState.RUN)
	else:
		change_state(EnemyState.IDLE)

# =========================
# COMPORTAMENTO
# =========================
func handle_state(_delta):
	if current_state == EnemyState.DEAD:
		velocity = Vector2.ZERO
		return
	
	if current_state == EnemyState.ATTACK:
		velocity.x = 0
		return
	
	if player and can_attack:
		var enemy_center = hurtbox.global_position
		var player_center = player.hurtbox.global_position
		
		var distance_x = abs(player_center.x - enemy_center.x)
		
		if distance_x <= attack_range:
			direction = sign(player.global_position.x - global_position.x)
			sprite.flip_h = direction > 0
			attack()
			return
	
	# IA simples: patrulha
	patrol()

func patrol():
	velocity.x = direction * speed
	
	if wall_raycast.is_colliding() or not floor_raycast.is_colliding():
		turn()

# =========================
# TURN
# =========================
func turn():
	direction *= -1
	
	sprite.flip_h = direction > 0
	wall_raycast.target_position.x *= -1
	hitbox.position *= -1

# =========================
# ATTACK
# =========================
func attack():
	if is_attacking or dead:
		return
	
	is_attacking = true
	can_attack = false
	
	change_state(EnemyState.ATTACK)
	
	velocity.x = 0
	hitbox.monitoring = true
	await sprite.animation_finished
	hitbox.monitoring = false
	is_attacking = false
	
	change_state(EnemyState.IDLE)
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


# =========================
# DANO
# =========================
func take_damage(amount):
	if current_state == EnemyState.DEAD or is_hit:
		return
	
	is_hit = true
	health -= amount
	change_state(EnemyState.HIT)
	
	if health <= 0:
		die()
		return
	
	await sprite.animation_finished
	is_hit = false
	change_state(EnemyState.IDLE)


func die():
	change_state(EnemyState.DEAD)
	velocity = Vector2.ZERO
	
	hitbox.monitoring = false
	hitbox.set_deferred("monitoring", false)
	
	await sprite.animation_finished
	queue_free()

func apply_level_scale(scale_value: float):
	sprite.scale = Vector2(scale_value, scale_value)

func setup(_level, _player):
	level = _level
	player = _player
