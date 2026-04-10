extends CanvasLayer

@onready var bar: ProgressBar = $Control/EnergyBG/EnergyBar

var player = null

func set_player(p):
	player = p

func update_bar():
	# exemplo simples
	bar.max_value = player.max_gravity_energy
	bar.value = player.gravity_energy

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if player:
		update_bar()
