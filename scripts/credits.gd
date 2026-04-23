extends Control

@onready var timer: Timer = $Timer

func _ready() -> void:
	get_tree().paused = false
	timer.start()

func _on_timer_timeout():
	go_to_main_menu()

func go_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/levels/level_end.tscn")
	#get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
