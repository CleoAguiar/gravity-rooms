extends Node2D

@onready var ambient_sound: AudioStreamPlayer2D = $AmbientSound

func reset_level():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	await tween.finished
	get_tree().reload_current_scene()

func _ready():
	ambient_sound.volume_db = -5
	ambient_sound.play()
	
	var tween = create_tween()
	tween.tween_property(ambient_sound, "volume_db", -15, 2.0)

func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		reset_level()
