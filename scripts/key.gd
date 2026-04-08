extends Area2D

signal collected

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sound: AudioStreamPlayer2D = $PickupSound




func _on_body_entered(_body: Node2D) -> void:
	sound.pitch_scale = randf_range(0.95, 1.1)
	sound.play()
	
	# Esconde visualmente
	sprite.visible = false
	collision.disabled = true
	
	# Espera o som terminar antes de deletar
	await sound.finished
	
	emit_signal("collected")
	queue_free()
