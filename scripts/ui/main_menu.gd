extends Control

@onready var sfx_hover: AudioStreamPlayer = $SFX_Hover
@onready var sfx_click: AudioStreamPlayer = $SFX_Click

func _ready() -> void:
	MusicManager.play_music(
		"menu",
		preload("res://assets/sounds/music/music_menú.wav")
	)

	for btn in get_tree().get_nodes_in_group("menu_buttons"):
		if btn is BaseButton:
			btn.mouse_entered.connect(_on_any_button_hover)
			btn.focus_entered.connect(_on_any_button_hover)
			btn.pressed.connect(_on_any_button_pressed)

func _on_any_button_hover() -> void:
	if not sfx_hover.playing:
		sfx_hover.play()

func _on_any_button_pressed() -> void:
	sfx_click.play()

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
	get_tree().change_scene_to_file("res://scenes/ui/intro.tscn")

func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/tutorial.tscn")
