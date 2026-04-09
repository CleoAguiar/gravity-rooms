extends Area2D

signal collected

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sound: AudioStreamPlayer2D = $PickupSound

var base_scale: Vector2
var base_position: Vector2

var collected_once := false

func float_animation():
	var tween = create_tween().set_loops()

	tween.tween_property(self, "position:y", base_position.y - 6, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(self, "position:y", base_position.y + 6, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func pulse_effect():
	var tween = create_tween().set_loops()

	tween.tween_property(sprite, "scale", base_scale * 1.05, 0.6)
	tween.tween_property(sprite, "scale", base_scale, 0.6)

func _ready():
	base_scale = sprite.scale
	base_position = position
	
	float_animation()
	pulse_effect()


func _on_body_entered(body: Node2D) -> void:
	if collected_once:
		return
	
	if not body.is_in_group("Player"):
		return
	else:
		sound.pitch_scale = randf_range(0.98, 1.05)
		sound.play()
		
		# Esconde visualmente
		sprite.visible = false
		collision.set_deferred("disabled", true)
		
		# Espera o som terminar antes de deletar
		await sound.finished
		
		emit_signal("collected")
		call_deferred("queue_free")
