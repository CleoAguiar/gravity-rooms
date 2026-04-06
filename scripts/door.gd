extends Area2D

@export var label: Label

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var key_collected = false

func open_door():
	print("abrindo porta")
	sprite_2d.play("opening")
	key_collected = true

func _on_body_entered(_body: Node2D) -> void:
	if key_collected:
		print("Passou de fase")
		label.text = "Você conseguiu!"
	else:
		print("Sem chave")
		label.text = "Você precisa de uma chave!"
