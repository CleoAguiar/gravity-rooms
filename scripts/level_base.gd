extends Node2D

signal level_completed

@export var player_scene: PackedScene
@export var key_scene: PackedScene
@export var door_scene: PackedScene
@export var camera_zoom: Vector2 = Vector2(0.8, 0.8)
@export var level_scale: float = 1.0
@export var enemy_scene: PackedScene

@onready var player_spawn: Marker2D = $World/Spawns/PlayerSpawn
@onready var key_spawn: Marker2D = $World/Spawns/KeySpawn
@onready var door_spawn: Marker2D = $World/Spawns/DoorSpawn
@onready var enemy_spawns: Node2D = $World/Spawns/EnemySpawns
@onready var entities: Node2D = $World/Entities

@onready var ui_label: Label = $UI/Label
@onready var tile_map: TileMap = $World/TileMap

var player_instance: CharacterBody2D
var key_instance: Area2D
var door_instance: Area2D
var enemy_instance: CharacterBody2D

var original_shape_size
var original_shape_radius

func _ready():
	validate_scenes()
	spawn_all()
	apply_scale_to_entities()

# Validação (evita erro silencioso)
func validate_scenes():
	assert(player_scene != null, "player_scene não definido!")
	assert(key_scene != null, "key_scene não definido!")
	assert(door_scene != null, "door_scene não definido!")

func spawn_all():
	spawn_player()
	spawn_key()
	spawn_door()
	spawn_enemies()
	
func apply_scale_to_entities():
	for child in entities.get_children():
		if child.has_method("apply_level_scale"):
			child.apply_level_scale(level_scale)
		else:
			child.scale = Vector2(level_scale, level_scale)

func reset_level():
	if player_instance:
		player_instance.queue_free()
	if key_instance:
		key_instance.queue_free()
	if door_instance:
		door_instance.queue_free()
	spawn_all()

# TileMap
func get_tilemap_bounds() -> Rect2:
	var used_rect = tile_map.get_used_rect()

	var top_left = tile_map.map_to_local(used_rect.position)
	var bottom_right = tile_map.map_to_local(used_rect.position + used_rect.size)

	return Rect2(top_left, bottom_right - top_left)

# PLAYER + CAMERA
func spawn_player():
	player_instance = player_scene.instantiate()
	player_instance.global_position = player_spawn.global_position
	apply_level_scale(player_instance)
	add_child(player_instance)
	setup_camera(player_instance)
	
	player_instance.add_to_group("player")
	get_tree().call_group("HUD", "set_player", player_instance)

func respawn_player(spawn_position: Vector2):
	if player_instance:
		player_instance.global_position = spawn_position
		player_instance.reset_state()

func find_camera(node: Node) -> Camera2D:
	for child in node.get_children():
		if child is Camera2D:
			return child
		var result = find_camera(child)
		if result:
			return result
	
	return null

func setup_camera(player: Node2D):
	var camera = find_camera(player)
	
	if camera == null:
		push_error("Camera2D não encontrada no Player!")
		return
	
	var bounds = get_tilemap_bounds()
	
	camera.limit_left = bounds.position.x
	camera.limit_right = bounds.position.x + bounds.size.x
	camera.limit_top = bounds.position.y
	camera.limit_bottom = bounds.position.y + bounds.size.y
	
	camera.zoom = camera_zoom

# SCALE TO ENTITIES
func apply_level_scale(node: Node2D):
	if node.is_in_group("enemy"):
		if node.has_method("apply_level_scale"):
			node.apply_level_scale(level_scale)
	else:
		node.scale = Vector2(level_scale, level_scale)
# KEY
func spawn_key():
	key_instance = key_scene.instantiate()
	key_instance.global_position = key_spawn.global_position
	apply_level_scale(key_instance)
	add_child(key_instance)
	key_instance.collected.connect(_on_key_collected)

# DOOR
func spawn_door():
	door_instance = door_scene.instantiate()
	door_instance.global_position = door_spawn.global_position
	apply_level_scale(door_instance)
	door_instance.ui_label = ui_label
	add_child(door_instance)

# ENEMY
func spawn_enemy(pos: Vector2):
	enemy_instance = enemy_scene.instantiate()
	
	entities.add_child(enemy_instance)
	enemy_instance.global_position = pos
	
	apply_level_scale(enemy_instance)
	entities.add_child(enemy_instance)

	# Injeta dependências
	enemy_instance.setup(self, player_instance)

func spawn_enemies():
	if enemy_scene == null:
		return
	
	for spawn_point in enemy_spawns.get_children():
		if spawn_point is Marker2D:
			spawn_enemy(spawn_point.global_position)
	
# EVENTO
func _on_key_collected():
	get_tree().call_group("doors", "open_door")

func _on_door_player_entered():
	emit_signal("level_completed")

# Instruction
func get_instructions() -> Array:
	return get_tree().get_nodes_in_group("tutorial_instruction").filter(
		func(n): return is_ancestor_of(n)
	)
