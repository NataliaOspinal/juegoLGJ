extends Control

# Referenciamos los nodos solo para "tomar prestado" su archivo de audio (.stream)
# No llamaremos a .play() directamente en ellos.
@onready var sfx_hover_node: AudioStreamPlayer = $SFX_Hover
@onready var sfx_click_node: AudioStreamPlayer = $SFX_Click

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
	# Verificamos si ya está sonando algo para no saturar (opcional)
	# Le pasamos el archivo de audio (.stream) al Manager Global
	if sfx_hover_node.stream:
		SFXManager.play_sfx(sfx_hover_node.stream)

func _on_any_button_pressed() -> void:
	# Le pasamos el sonido al Manager Global
	# Así, aunque la escena cambie INMEDIATAMENTE abajo, el sonido sigue vivo en el Global
	if sfx_click_node.stream:
		SFXManager.play_sfx(sfx_click_node.stream)


func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_start_pressed() -> void:
	Global.vidas = 3
	get_tree().change_scene_to_file("res://scenes/levels/level1.tscn")

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/credits_new.tscn")

func _on_story_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/intro_fake.tscn")

func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/tutorial.tscn")
