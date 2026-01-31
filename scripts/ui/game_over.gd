extends Control

@onready var overlay: ColorRect = $Overlay
@onready var box: VBoxContainer = $VBoxContainer
@onready var retry: Button = $VBoxContainer/Retry
@onready var exit_btn: Button = $VBoxContainer/Exit

func _ready() -> void:
	MusicManager.duck_music(-12.0, 0.25)

	MusicManager.play_stinger(preload("res://assets/sounds/music/music_dead.wav"), -2.0)
	
	overlay.modulate.a = 0.0
	box.modulate.a = 0.0

	retry.modulate.a = 0.0
	exit_btn.modulate.a = 0.0

	box.position.y += 12

	_play_intro()

func _play_intro() -> void:
	var t := create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	t.tween_interval(0.15)

	t.tween_property(overlay, "modulate:a", 0.80, 0.7) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	t.parallel().tween_property(box, "modulate:a", 1.0, 0.45) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(box, "position:y", box.position.y - 12, 0.45) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	t.tween_interval(0.05)
	t.tween_property(retry, "modulate:a", 1.0, 0.25)
	t.tween_interval(0.05)
	t.tween_property(exit_btn, "modulate:a", 1.0, 0.25)

	t.finished.connect(func():
		retry.grab_focus()
	)

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	
func _process(delta: float) -> void:
	$VBoxContainer.modulate.a = 0.96 + 0.04 * sin(Time.get_ticks_msec() / 600.0)
