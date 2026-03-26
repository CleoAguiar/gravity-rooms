extends Area2D

func _on_body_entered(body: Node2D) -> void:
	print("I keep the key")
	queue_free()
