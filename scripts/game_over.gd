extends Control

func _ready():
	visible = false

func show_game_over():
	visible = true
	get_tree().paused = true

func _on_button_pressed():
	print("clicou no botão")
	get_tree().paused = false
	get_tree().reload_current_scene()
