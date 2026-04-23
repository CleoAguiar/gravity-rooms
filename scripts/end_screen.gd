extends Control

@onready var label: Label = $Label
@onready var button: Button = $Button

enum EndType {
	GAME_OVER,
	VICTORY
}

var current_type: EndType

func show_game_over():
	current_type = EndType.GAME_OVER
	
	visible = true
	get_tree().paused = true

	label.text = "Game Over"
	button.text = "Try again"

	#show()

func show_victory():
	current_type = EndType.VICTORY
	
	visible = true
	get_tree().paused = true

	label.text = "Congratulations!"
	button.text = "Continue"
	#show()

func _ready():
	visible = false

func _on_button_pressed():
	get_tree().paused = false
	visible = false
	
	match current_type:
		EndType.GAME_OVER:
			get_tree().current_scene.reset_level()
		EndType.VICTORY:
			get_tree().current_scene.reset_game()
