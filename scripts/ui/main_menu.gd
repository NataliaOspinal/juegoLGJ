extends Control

func _ready() -> void:
	MusicManager.play_music(
		"menu",
		preload("res://assets/sounds/music/music_menú.wav")
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_start_pressed() -> void:
	Global.vidas = 3
	get_tree().change_scene_to_file("res://scenes/levels/level1.tscn")

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/credits_new.tscn")

func _on_story_pressed() -> void:
	get_tree().change_scene_to_file("res://scripts/ui/intro.tscn")
