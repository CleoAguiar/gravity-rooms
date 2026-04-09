extends Camera2D

var target: Node2D

# Shake
var shake_strength := 0.0
var shake_decay := 10.0
var shake_offset := Vector2.ZERO

func _ready() -> void:
	set_camera_limits()

func _process(delta: float) -> void:
	if not target:
		return

	# Base: seguir player
	var base_position = target.position

	# Atualiza shake
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)
		shake_offset = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * shake_strength
	else:
		shake_offset = Vector2.ZERO

	# Aplica posição final
	global_position = base_position + shake_offset


func set_camera_limits():
	limit_left = -512
	limit_right = 512
	limit_top = -300
	limit_bottom = 300

# FUNÇÃO QUE O PLAYER CHAMA
func shake(intensity := 6.0):
	shake_strength = intensity
