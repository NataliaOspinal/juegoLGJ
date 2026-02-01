extends Control

@export var next_scene_path := "res://scenes/gameplay/game.tscn"
@export var return_to_menu := false

@export_range(0.1, 5.0, 0.05) var fade_time := 0.6
@export_range(0.5, 15.0, 0.1) var post_slide_pause := 0.4

# Máquina de escribir
@export_range(0.005, 0.1, 0.005) var type_speed := 0.03
@export_range(0.1, 3.0, 0.1) var type_line_pause := 0.8

@onready var image: TextureRect = $Image
@onready var text: RichTextLabel = $TextBox/RichTextLabel
@onready var fade: ColorRect = $Fade
@onready var glitch: ColorRect = $Glitch

var index := 0
var playing := false
var skip_requested := false

var slides := [
	{
		"img": preload("res://assets/ui/intro/01.png"),
		"text": "Esta es Nuri.\nAprendió a vivir como se esperaba de ella: sonreía, trabajaba, cumplía.\nEntre tú y yo… no se permitía sentir demasiado.",
		"zoom_from": 1.03,
		"zoom_to": 1.10,
		"hold": 5.0
	},
	{
		"img": preload("res://assets/ui/intro/02.png"),
		"text": "Cuando algo iba mal, Nuri se culpaba.\nSi alguien fallaba, ella lo compensaba.\nNunca pedía ayuda.",
		"zoom_from": 1.02,
		"zoom_to": 1.10,
		"hold": 5.0
	},
	{
		"img": preload("res://assets/ui/intro/03.png"),
		"text": "Para no volver a sufrir, Nuri dejó de acercarse a lo que amaba.\nCreyó que así estaría a salvo.",
		"zoom_from": 1.02,
		"zoom_to": 1.08,
		"hold": 5.0
	},
	{
		"img": preload("res://assets/ui/intro/04.png"),
		"text": "Cierta noche, Nuri se acostó como de costumbre…\npero nunca más volvió a despertar.",
		"zoom_from": 1.01,
		"zoom_to": 1.06,
		"hold": 5.5
	}
]

var final_lines := [
	"Esto es Stillmind." ,
	"Stillmind existe para las almas que murieron cargando máscaras.",
	"En vida era experta en seguir instrucciones, en ponerse la máscara y sonreír. Tú eres diferente. Tú tienes el control ahora. No la dejes quieta. Muévela.",
	"Bienvenida, Nuri."
]

func _ready() -> void:
	fade.modulate.a = 1.0
	image.modulate.a = 0.0
	text.modulate.a = 0.0

	if glitch:
		glitch.modulate.a = 0.0

	_play_slide(0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		skip_requested = true
		_finish()
	elif event.is_action_pressed("ui_accept"):
		# Enter/Space: avanza si no está en medio de un tween/typewriter
		if not playing:
			_next()

func _play_slide(i: int) -> void:
	if playing:
		return

	playing = true
	index = i
	var s = slides[index]

	image.texture = s.img
	text.text = s.text

	image.scale = Vector2.ONE * s.zoom_from
	image.position = Vector2.ZERO

	image.modulate.a = 0.0
	text.modulate.a = 0.0

	var t := create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	# Fade in
	t.tween_property(fade, "modulate:a", 0.0, fade_time)
	t.parallel().tween_property(image, "modulate:a", 1.0, fade_time)
	t.parallel().tween_property(text, "modulate:a", 1.0, fade_time)

	# Zoom lento
	t.tween_property(
		image,
		"scale",
		Vector2.ONE * s.zoom_to,
		float(s.hold)
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Pequeña pausa de lectura
	t.tween_interval(post_slide_pause)

	# Fade out (menos agresivo: dejamos imagen, y fundimos a negro al final del último slide)
	if index < slides.size() - 1:
		t.tween_property(image, "modulate:a", 0.0, fade_time)
		t.parallel().tween_property(text, "modulate:a", 0.0, fade_time)
		t.parallel().tween_property(fade, "modulate:a", 1.0, fade_time)

	t.finished.connect(func():
		playing = false
		_next()
	)

func _next() -> void:
	if skip_requested:
		return

	if index + 1 >= slides.size():
		_play_final_sequence()
	else:
		_play_slide(index + 1)

func _play_final_sequence() -> void:
	if playing:
		return
	playing = true

	# Asegura negro total
	var t := create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(fade, "modulate:a", 1.0, fade_time)
	t.parallel().tween_property(text, "modulate:a", 0.0, fade_time)
	t.parallel().tween_property(image, "modulate:a", 0.0, fade_time)
	t.finished.connect(func():
		playing = false
		await _glitch_to_black()
		await _typewriter_lines(final_lines)
		_finish()
	)

func _glitch_to_black() -> void:
	if not glitch:
		await get_tree().create_timer(0.3).timeout
		return

	# Forzamos un color visible (si lo dejaste negro o con alpha 0 en editor, lo arregla)
	glitch.color = Color(1, 1, 1, 1)  # blanco
	glitch.visible = true

	for i in range(8):
		glitch.color.a = 0.85
		await get_tree().create_timer(0.03).timeout
		glitch.color.a = 0.0
		await get_tree().create_timer(0.05).timeout

	# Al final, apagado
	glitch.color.a = 0.0


func _typewriter_lines(lines: Array) -> void:
	playing = true
	text.bbcode_enabled = false
	text.text = ""
	text.modulate.a = 1.0

	for line in lines:
		if skip_requested:
			break
		await _type_line(line)
		await get_tree().create_timer(type_line_pause).timeout

	playing = false

func _type_line(line: String) -> void:
	text.text += "\n" if text.text.length() > 0 else ""
	for c in line:
		if skip_requested:
			return
		text.text += c
		await get_tree().create_timer(type_speed).timeout

func _finish() -> void:
	if return_to_menu:
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
