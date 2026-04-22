extends Control

@onready var label: Label = $Label
@onready var button: Button = $Button

func show_game_over():
	visible = true
	get_tree().paused = true

	label.text = "Game Over"
	button.text = "Try again"

	show()

func show_victory():
	visible = true
	get_tree().paused = true

	label.text = "Congratulations!"
	button.text = "Play again"
	show()

func _ready():
	visible = false

func _on_button_pressed():
	#print("clicou no botão")
	get_tree().paused = false
	visible = false
	get_tree().current_scene.reset_level()
