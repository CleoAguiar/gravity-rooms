extends Camera2D

var target: Node2D

# Shake
var shake_strength := 0.0
var shake_decay := 10.0
var shake_offset := Vector2.ZERO

func _ready() -> void:
	get_target()

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
	position = base_position + shake_offset


func get_target():
	var nodes = get_tree().get_nodes_in_group("Player")
	if nodes.size() == 0:
		push_error("Player not found")
		return
	
	target = nodes[0]


# FUNÇÃO QUE O PLAYER CHAMA
func shake(intensity := 6.0):
	shake_strength = intensity
