extends Node2D

func reset_level():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	await tween.finished
	get_tree().reload_current_scene()

func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		reset_level()
