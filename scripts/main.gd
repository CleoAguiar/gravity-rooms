extends Node2D

@onready var level_container: Node = $World/LevelContainer
@onready var fade: ColorRect = $FadeLayer/ColorRect
@onready var tutorial_manager: Node = $TutorialManager
@onready var ambient_sound: AudioStreamPlayer = $Audio/Ambient/AmbientSound

var levels = [
	"res://scenes/levels/level_01_neon_lab.tscn",
	"res://scenes/levels/level_02_neon_lab.tscn",
	"res://scenes/levels/level_03_neon_lab.tscn",
	"res://scenes/levels/level_end.tscn"
]

var current_level_index := 0
var current_level_node: Node = null

var current_level_path := ""
var loading := false


func reset_level():
	if loading:
		return

	var tween = create_tween()
	tween.tween_property(fade, "self_modulate:a", 1.0, 0.15)
	await tween.finished

	await get_tree().process_frame

	if current_level_node and current_level_node.has_method("reset_level"):
		current_level_node.reset_level()

	await get_tree().create_timer(0.2).timeout

	load_level(current_level_path)


func setup_level(level):
	# Garante que o level ainda existe
	if not is_instance_valid(level):
		return
	
	# PLAYER
	var player = level.get_node_or_null("Player")
	
	# HUD (energia)
	var hud = get_node("HUD")
	if hud and player:
		hud.set_player(player)
	
	# TUTORIAL
	if tutorial_manager and level.has_method("get_instructions"):
		var instructions = level.get_instructions()
		tutorial_manager.start_tutorial(instructions)


func load_level(scene_path: String):	
	current_level_path = scene_path
	
	# Remove players antigos
	for p in get_tree().get_nodes_in_group("player"):
		p.queue_free()

	# Remove fase atual com segurança
	if is_instance_valid(current_level_node):
		current_level_node.queue_free()
		await current_level_node.tree_exited
		current_level_node = null
	
	# Carrega nova fase
	var scene = load(scene_path)
	var level_instance = scene.instantiate()
	
	# Conecta o sinal DEPOIS de instanciar
	if level_instance.has_signal("level_completed"):
		level_instance.connect("level_completed", Callable(self, "next_level"))
	
	level_container.add_child(level_instance)
	current_level_node = level_instance
	
	# Espera o node entrar na árvore
	await get_tree().process_frame
	
	# Segurança extra antes de usar
	if is_instance_valid(level_instance):
		setup_level(level_instance)

func next_level():
	current_level_index += 1
	
	print("Indo para índice:", current_level_index)
	if current_level_index >= levels.size():
		print("Fim do jogo!")
		return
	
	load_level(levels[current_level_index])

func change_level(next_level_path: String):
	await fade_out()
	load_level(next_level_path)
	await fade_in()

func fade_out():
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.5)
	await tween.finished

func fade_in():
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 0.5)
	await tween.finished

func _ready():
	load_level(levels[current_level_index])

	# fade inicial
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 0.3)

	ambient_sound.volume_db = -5
	ambient_sound.play()

	var tween_audio = create_tween()
	tween_audio.tween_property(ambient_sound, "volume_db", -15, 2.0)


func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		reset_level()
