extends Node2D

@onready var ambient_sound: AudioStreamPlayer = $Audio/Ambient/AmbientSound
@onready var level_container: Node = $LevelContainer
@onready var tutorial_manager: Node = $TutorialManager

func reset_level():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	await tween.finished
	get_tree().reload_current_scene()

func setup_level(level):
	var instruction = level.get_node_or_null("TileMaps/Instruction")
	
	if instruction:
		tutorial_manager.instruction = instruction

func load_level(path):
	# limpa fase atual
	for child in level_container.get_children():
		child.queue_free()
	
	# instancia nova fase
	var level = load(path).instantiate()
	level_container.add_child(level)
	
	# injeta dependências
	setup_level(level)

func _ready():
	load_level("res://scenes/levels/Level01_NeonLab.tscn")
	
	ambient_sound.volume_db = -5
	ambient_sound.play()
	
	var tween = create_tween()
	tween.tween_property(ambient_sound, "volume_db", -15, 2.0)

func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		reset_level()
