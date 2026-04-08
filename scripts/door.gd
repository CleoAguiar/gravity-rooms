extends Area2D

@export var label: Label

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var open_sound: AudioStreamPlayer2D = $OpenSound

var key_collected = false

func open_door():
	sprite_2d.play("opening")
	key_collected = true
	open_sound.play()

func _on_body_entered(_body: Node2D) -> void:
	if key_collected:
		print("Passou de fase")
		label.text = "Você conseguiu!"
	else:
		print("Sem chave")
		label.text = "Você precisa de uma chave!"
