extends Node2D

@onready var player: CharacterBody2D = $World/Player
@onready var level_container: Node = $World/LevelContainer
@onready var fade: ColorRect = $FadeLayer/ColorRect
@onready var tutorial_manager: Node = $TutorialManager
@onready var ambient_sound: AudioStreamPlayer = $Audio/Ambient/AmbientSound

var current_level_path := ""

func reset_level():
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.15)
	await tween.finished
	
	
	# delay cinematográfico
	await get_tree().create_timer(0.2).timeout
	
	load_level(current_level_path)
	
	var tween_in = create_tween()
	tween_in.tween_property(fade, "modulate:a", 0.0, 0.2)

func setup_level(level):
	var instructions = []
	
	for node in level.get_tree().get_nodes_in_group("instruction"):
		if level.is_ancestor_of(node):
			instructions.append(node)
	
	tutorial_manager.instruction = instructions
	
	# reset estado
	tutorial_manager.time = 0.0
	tutorial_manager.blinking = false
	tutorial_manager.completed = false

	
	tutorial_manager.setup_instructions()
	
	# Reposicionar player
	var spawn = level.get_node_or_null("SpawnPoint")
	if spawn:
		player.global_position = spawn.global_position
		player.reset_state()

func load_level(path):
	current_level_path = path
	
	# limpa fase
	for child in level_container.get_children():
		child.queue_free()
	
	var level = load(path).instantiate()
	level_container.add_child(level)
	
	setup_level(level)
	
	# pequeno delay antes de aparecer
	await get_tree().create_timer(0.1).timeout
	
	# fade in
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 0.25)
	
	await tween.finished
	
	# delay pós-fade (sensação de “entrada”)
	await get_tree().create_timer(0.1).timeout


func _ready():
	fade.modulate.a = 1.0
	
	load_level("res://scenes/levels/Level_Base.tscn")
	
	# fade in inicial
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 0.3)
	
	ambient_sound.volume_db = -5
	ambient_sound.play()
	
	var tween_audio = create_tween()
	tween_audio.tween_property(ambient_sound, "volume_db", -15, 2.0)
	tween.tween_property(ambient_sound, "volume_db", -15, 2.0)

func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		reset_level()
