extends Node2D

@onready var level_container: Node = $World/LevelContainer
@onready var fade: ColorRect = $FadeLayer/ColorRect
@onready var tutorial_manager: Node = $TutorialManager
@onready var ambient_sound: AudioStreamPlayer = $Audio/Ambient/AmbientSound

const START_LEVEL = "res://scenes/levels/level_01_neon_lab.tscn"
var current_level_path := ""
var current_level: Node = null

func reset_level():
	var tween = create_tween()
	tween.tween_property(fade, "self_modulate:a", 1.0, 0.15)
	await tween.finished

	await get_tree().process_frame

	if current_level and current_level.has_method("reset_level"):
		current_level.reset_level()

	await get_tree().create_timer(0.2).timeout

	load_level(current_level_path)

func setup_level(level):
	tutorial_manager.instruction = level.get_instructions()
	tutorial_manager.setup_instructions()

func load_level(path):
	current_level_path = path

	for child in level_container.get_children():
		child.queue_free()

	var level = load(path).instantiate()
	level_container.add_child(level)

	current_level = level

	await get_tree().process_frame

	setup_level(level)

	await get_tree().create_timer(0.1).timeout

	var tween = create_tween()
	tween.tween_property(fade, "self_modulate:a", 0.0, 0.25)
	await tween.finished

func _ready():
	fade.self_modulate.a
	
	load_level(START_LEVEL)
	
	# fade in inicial
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 0.3)
	
	ambient_sound.volume_db = -5
	ambient_sound.play()
	
	var tween_audio = create_tween()
	tween_audio.tween_property(ambient_sound, "volume_db", -15, 2.0)

func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		reset_level()
