extends Area2D

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func open_door():
	print("abrindo porta")
	sprite_2d.play("opening")
	collision.set_deferred("disabled", true)

func _on_body_entered(body: Node2D) -> void:
	print("Passou de fase")
