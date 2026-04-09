extends Node2D

@export var player_scene: PackedScene
@export var key_scene: PackedScene
@export var door_scene: PackedScene

@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var key_spawn: Marker2D = $KeySpawn
@onready var door_spawn: Marker2D = $DoorSpawn


func _ready():
	spawn_player()
	spawn_key()
	spawn_door()

func _on_key_collected():
	get_tree().call_group("doors", "open_door")

func spawn_player():
	var player = player_scene.instantiate()
	player.position = player_spawn.position
	add_child(player)

func spawn_key():
	var key = key_scene.instantiate()
	key.position = key_spawn.position
	add_child(key)
	key.collected.connect(_on_key_collected)

func spawn_door():
	var door = door_scene.instantiate()
	door.position = door_spawn.position
	add_child(door)
