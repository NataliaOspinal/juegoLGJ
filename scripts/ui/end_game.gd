extends Control

const MAIN_MENU_SCENE := "res://scenes/ui/credits_new.tscn"

@onready var yes_button: Button = $Yes
@onready var no_button: Button = $No

func _ready() -> void:
	if is_instance_valid(yes_button) and not yes_button.pressed.is_connected(_on_yes_pressed):
		yes_button.pressed.connect(_on_yes_pressed)
	if is_instance_valid(no_button) and not no_button.pressed.is_connected(_on_no_pressed):
		no_button.pressed.connect(_on_no_pressed)

func _go_to_main_menu() -> void:
	var err := get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	if err != OK:
		push_error("No se pudo cambiar a la escena del menú principal: %s (err=%s)" % [MAIN_MENU_SCENE, err])

func _on_yes_pressed() -> void:
	Global.decision_final = "quitar"
	get_tree().change_scene_to_file("res://scenes/final_scene.tscn")

func _on_no_pressed() -> void:
	Global.decision_final = "mantener"
	get_tree().change_scene_to_file("res://scenes/final_scene.tscn")
