extends Control

@onready var bar = $EnergyBG/EnergyBar
var player = null

func _ready():
	get_player()

func _process(delta):
	if player:
		update_bar(delta)

func get_player():
	var nodes = get_tree().get_nodes_in_group("Player")
	if nodes.size() > 0:
		player = nodes[0]

func update_bar(delta):
	var ratio = player.gravity_energy / player.max_gravity_energy
	
	# animação suave
	bar.scale.x = lerp(bar.scale.x, ratio, 10 * delta)

	# cor dinâmica
	if ratio > 0.6:
		bar.color = Color(0.3, 0.7, 1)
	elif ratio > 0.3:
		bar.color = Color(1, 0.8, 0.2)
	else:
		bar.color = Color(1, 0.3, 0.3)
