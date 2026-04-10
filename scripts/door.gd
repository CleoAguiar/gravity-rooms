extends Area2D

signal player_entered

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var open_sound: AudioStreamPlayer2D = $OpenSound

var key_collected = false
var ui_label: Label

func open_door():
	sprite_2d.play("opening")
	key_collected = true
	open_sound.play()

func _on_body_entered(_body: Node2D) -> void:
	if key_collected:
		if ui_label:
			emit_signal("player_entered")
			ui_label.text = "Você conseguiu!"
	else:
		if ui_label:
			ui_label.text = "Você precisa de uma chave!"
