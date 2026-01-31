extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_start_pressed() -> void:
	Global.vidas = 3
	get_tree().change_scene_to_file("res://scenes/levels/level1.tscn")

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/credits.tscn")

func _on_story_pressed() -> void:
	get_tree().change_scene_to_file("res://scripts/ui/intro.tscn")
