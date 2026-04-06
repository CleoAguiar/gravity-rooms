extends Node2D

var time_without_action := 0.0
var hint_delay := 5.0 # segundos até começar a piscar
var is_blinking := false
var used_gravity := false

@onready var instruction: TileMapLayer = $TileMaps/Instruction

func on_gravity_used():
	used_gravity = true
	instruction.visible = false

func start_blinking():
	is_blinking = true
	
	var tween = create_tween()
	tween.set_loops(4)

	tween.tween_property(instruction, "position:y", instruction.position.y - 5, 0.5)
	tween.tween_property(instruction, "position:y", instruction.position.y, 0.5)

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if used_gravity:
		return

	time_without_action += delta

	if time_without_action >= hint_delay and not is_blinking:
		start_blinking()
