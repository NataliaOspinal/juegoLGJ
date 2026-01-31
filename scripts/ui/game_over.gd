extends Control

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
