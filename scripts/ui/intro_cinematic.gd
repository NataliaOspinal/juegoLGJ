extends Control

@onready var video: VideoStreamPlayer = $VideoStreamPlayer

func _ready():
	MusicManager.stop_music()
	video.finished.connect(_on_video_finished)

func _on_video_finished():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
