extends Node

#@export var instruction_path: NodePath
@export var hint_delay := 5.0
@export var blink_loops := 6

var time := 0.0
var blinking := false
var completed := false

var instruction: TileMapLayer
#@onready var instruction: TileMapLayer = get_node(instruction_path)

var tween: Tween
var original_y := 0.0

func on_gravity_used():
	complete_tutorial()


func _ready():
	if instruction:
		original_y = instruction.position.y


func _process(delta):
	if completed:
		return

	time += delta

	if time >= hint_delay and not blinking:
		start_hint()


func start_hint():
	blinking = true

	tween = create_tween()
	tween.set_loops(blink_loops)

	# Fade + movimento (bem visível)
	tween.tween_property(instruction, "modulate:a", 0.3, 0.4)
	tween.tween_property(instruction, "modulate:a", 1.0, 0.4)

	tween.parallel().tween_property(instruction, "position:y", original_y - 5, 0.4)
	tween.parallel().tween_property(instruction, "position:y", original_y, 0.4)


func complete_tutorial():
	if completed:
		return

	completed = true

	if tween:
		tween.kill()

	var t = create_tween()
	t.tween_property(instruction, "modulate:a", 0.0, 0.3)

	await t.finished
	instruction.visible = false
