extends Node2D

@export var player_scene: PackedScene
@export var key_scene: PackedScene
@export var door_scene: PackedScene
@export var camera_zoom: Vector2 = Vector2(0.8, 0.8)

@onready var player_spawn: Marker2D = $Spawns/PlayerSpawn
@onready var key_spawn: Marker2D = $Spawns/KeySpawn
@onready var door_spawn: Marker2D = $Spawns/DoorSpawn
@onready var ui_label: Label = $UI/Label
@onready var tile_map: TileMap = $World/TileMap

var player_instance: CharacterBody2D
var key_instance: Area2D
var door_instance: Area2D

func _ready():
	validate_scenes()
	spawn_all()

# Validação (evita erro silencioso)
func validate_scenes():
	assert(player_scene != null, "player_scene não definido!")
	assert(key_scene != null, "key_scene não definido!")
	assert(door_scene != null, "door_scene não definido!")

func spawn_all():
	spawn_player()
	spawn_key()
	spawn_door()

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
	add_child(player_instance)

	setup_camera(player_instance)

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

# KEY
func spawn_key():
	key_instance = key_scene.instantiate()
	key_instance.global_position = key_spawn.global_position
	add_child(key_instance)

	key_instance.collected.connect(_on_key_collected)

# DOOR
func spawn_door():
	door_instance = door_scene.instantiate()
	door_instance.global_position = door_spawn.global_position

	door_instance.ui_label = ui_label

	add_child(door_instance)

# EVENTO
func _on_key_collected():
	get_tree().call_group("doors", "open_door")

# Instruction
func get_instructions() -> Array:
	return get_tree().get_nodes_in_group("instruction").filter(
		func(n): return is_ancestor_of(n)
	)
