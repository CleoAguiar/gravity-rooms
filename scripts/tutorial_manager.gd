extends Node

@export var hint_delay := 5.0
@export var blink_loops := 6

var time := 0.0
var blinking := false
var completed := false

var instruction: Array = []
var original_y: Dictionary = {}
var tween: Tween


func on_gravity_used():
	complete_tutorial()


func _ready():
	await get_tree().process_frame
	instruction = get_tree().get_nodes_in_group("tutorial_instruction")
	setup_instructions()


func setup_instructions():
	original_y.clear()
	
	for i in instruction:
		if i:
			original_y[i] = i.position.y


func _process(delta):
	if completed:
		return
	
	if instruction.is_empty():
		return

	time += delta

	if time >= hint_delay and not blinking:
		start_hint()


func start_hint():
	if instruction.is_empty():
		return

	# filtra válidos
	var valid := []
	
	for i in instruction:
		if i and original_y.has(i):
			valid.append(i)

	if valid.is_empty():
		return

	blinking = true
	tween = create_tween()
	tween.set_loops(blink_loops)

	for i in valid:
		tween.tween_property(i, "modulate:a", 0.3, 0.4)
		tween.tween_property(i, "modulate:a", 1.0, 0.4)

		tween.parallel().tween_property(i, "position:y", original_y[i] - 5, 0.4)
		tween.parallel().tween_property(i, "position:y", original_y[i], 0.4)


func complete_tutorial():
	if completed:
		return
	
	completed = true
	
	if tween:
		tween.kill()

	if instruction.is_empty():
		return
	
	var t = create_tween()

	var valid := []
	
	for i in instruction:
		if i:
			valid.append(i)

	if valid.is_empty():
		return

	for i in valid:
		t.tween_property(i, "modulate:a", 0.0, 0.3)

	await t.finished

	for i in valid:
		i.visible = false
