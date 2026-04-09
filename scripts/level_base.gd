extends Node2D

@export var player_scene: PackedScene
@export var key_scene: PackedScene
@export var door_scene: PackedScene

@onready var player_spawn: Marker2D = $Spawns/PlayerSpawn
@onready var key_spawn: Marker2D = $Spawns/KeySpawn
@onready var door_spawn: Marker2D = $Spawns/DoorSpawn
@onready var ui_label: Label = $UI/Label
@onready var tile_map: TileMap = $World/TileMap

var player_ref: Node2D

func _ready():
	validate_scenes()
	spawn_player()
	spawn_key()
	spawn_door()

# Validação (evita erro silencioso)
func validate_scenes():
	assert(player_scene != null, "player_scene não definido!")
	assert(key_scene != null, "key_scene não definido!")
	assert(door_scene != null, "door_scene não definido!")

# TileMap
func get_tilemap_bounds() -> Rect2:
	var used_rect = tile_map.get_used_rect()

	var top_left = tile_map.map_to_local(used_rect.position)
	var bottom_right = tile_map.map_to_local(used_rect.position + used_rect.size)

	return Rect2(top_left, bottom_right - top_left)

# PLAYER + CAMERA
func spawn_player():
	var player = player_scene.instantiate()
	player.global_position = player_spawn.global_position
	add_child(player)

	player_ref = player

	setup_camera(player)

func respawn_player(spawn_position: Vector2):
	player_spawn.global_position = spawn_position
	player_spawn.reset_state()

func find_camera(node: Node) -> Camera2D:
	for child in node.get_children():
		if child is Camera2D:
			return child
		
		var result = find_camera(child)
		if result:
			return result
	
	return null

func setup_camera(player: Node2D):
	#var camera: Camera2D = player.get_node_or_null("Camera2D")
	var camera = find_camera(player)

	if camera == null:
		push_error("Camera2D não encontrada no Player!")
		return

	var bounds = get_tilemap_bounds()

	camera.limit_left = bounds.position.x
	camera.limit_right = bounds.position.x + bounds.size.x
	camera.limit_top = bounds.position.y
	camera.limit_bottom = bounds.position.y + bounds.size.y

# KEY
func spawn_key():
	var key = key_scene.instantiate()
	key.global_position = key_spawn.global_position
	add_child(key)

	key.collected.connect(_on_key_collected)

# DOOR
func spawn_door():
	var door = door_scene.instantiate()
	door.global_position = door_spawn.global_position
	
	if "ui_label" in door:
		door.ui_label = ui_label
	
	add_child(door) 

# EVENTO
func _on_key_collected():
	get_tree().call_group("doors", "open_door")
