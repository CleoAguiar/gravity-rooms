extends Area2D

signal collected

func _on_body_entered(_body: Node2D) -> void:
	print("I keep the key")
	emit_signal("collected")
	queue_free()
