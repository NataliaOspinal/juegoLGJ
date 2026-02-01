extends Control

@export var next_scene_path := "res://scenes/gameplay/game.tscn"
@export var return_to_menu := false

@export_range(0.1, 5.0, 0.05) var fade_time := 0.6
@export_range(0.5, 15.0, 0.1) var post_slide_pause := 0.4

# Máquina de escribir (genérico)
@export_range(0.005, 0.1, 0.005) var type_speed := 0.03
@export_range(0.1, 3.0, 0.1) var type_line_pause := 0.8

# Máquina de escribir SOLO para las líneas finales
@export_range(0.01, 0.25, 0.005) var final_type_speed := 0.06
@export_range(0.1, 5.0, 0.1) var final_line_pause := 1.0
@export_range(0.0, 2.0, 0.05) var final_fade_between_lines := 0.25

@onready var image: TextureRect = $Image
@onready var text: RichTextLabel = $TextBox/RichTextLabel
@onready var fade: ColorRect = $Fade
@onready var glitch: ColorRect = $Glitch
@onready var text_box: Control = $TextBox

var index := 0
var playing := false
var skip_requested := false

# Guardamos layout original para poder restaurarlo tras la secuencia final
var _textbox_saved := false
var _textbox_anchor_left := 0.0
var _textbox_anchor_top := 0.0
var _textbox_anchor_right := 0.0
var _textbox_anchor_bottom := 0.0
var _textbox_offset_left := 0.0
var _textbox_offset_top := 0.0
var _textbox_offset_right := 0.0
var _textbox_offset_bottom := 0.0

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
	"En vida era experta en seguir instrucciones, en ponerse la máscara y sonreír.",
	"Tú eres diferente.",
	"Tú tienes el control ahora.",
	"No la dejes quieta. Muévela.",
	"Bienvenida, Nuri."
]

func _ready() -> void:
	fade.modulate.a = 1.0
	image.modulate.a = 0.0
	text.modulate.a = 0.0

	# Guardamos el layout inicial del textbox (viene anclado abajo en la escena)
	_save_textbox_layout()

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
		_apply_centered_final_text_layout()
		await _typewriter_final_lines(final_lines)
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

# Secuencia final: una línea por pantalla, más lenta y con glitch antes de la última
func _typewriter_final_lines(lines: Array) -> void:
	playing = true
	text.bbcode_enabled = false
	text.text = ""
	text.modulate.a = 1.0

	var last_index := lines.size() - 1
	for i in range(lines.size()):
		if skip_requested:
			break

		# Escribimos la línea
		text.text = ""  # cada línea sustituye a la anterior
		await _type_line_with_speed(String(lines[i]), final_type_speed)

		# Pausa de lectura
		await get_tree().create_timer(final_line_pause).timeout

		# Transición inmediata de glitch justo después de la línea anterior a la última
		# (o sea, al terminar el mensaje antes de "Bienvenida, Nuri.")
		if i == last_index - 1 and not skip_requested:
			await _glitch_transition_for_final()

		# Si no es la última, desaparece y pasa a la siguiente
		if i != last_index and i != last_index - 1 and final_fade_between_lines > 0.0:
			var tw := create_tween()
			tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tw.tween_property(text, "modulate:a", 0.0, final_fade_between_lines)
			await tw.finished
			text.modulate.a = 1.0

	playing = false

func _type_line_with_speed(line: String, speed: float) -> void:
	for c in line:
		if skip_requested:
			return
		text.text += c
		await get_tree().create_timer(speed).timeout

func _glitch_transition_for_final() -> void:
	# Fallo de pantalla corto e inmediato: corta el texto, destella varias veces.
	if skip_requested:
		return
	if not glitch:
		# fallback mínimo
		text.text = ""
		await get_tree().create_timer(0.15).timeout
		return

	# Corte inmediato del mensaje previo
	text.text = ""
	text.modulate.a = 0.0

	glitch.visible = true
	# Blanco para simular fallo/flash
	glitch.color = Color(1, 1, 1, 1)

	# Parpadeo rápido: sensación de "pantalla fallando"
	for j in range(10):
		glitch.color.a = 0.95
		await get_tree().create_timer(0.015).timeout
		glitch.color.a = 0.0
		await get_tree().create_timer(0.02).timeout

	glitch.color.a = 0.0
	text.modulate.a = 1.0

func _save_textbox_layout() -> void:
	if _textbox_saved or not is_instance_valid(text_box):
		return
	_textbox_saved = true
	_textbox_anchor_left = text_box.anchor_left
	_textbox_anchor_top = text_box.anchor_top
	_textbox_anchor_right = text_box.anchor_right
	_textbox_anchor_bottom = text_box.anchor_bottom
	_textbox_offset_left = text_box.offset_left
	_textbox_offset_top = text_box.offset_top
	_textbox_offset_right = text_box.offset_right
	_textbox_offset_bottom = text_box.offset_bottom

func _apply_centered_final_text_layout() -> void:
	if not is_instance_valid(text_box):
		return

	# Centramos el panel de texto en pantalla.
	# Mantiene el mismo tamaño que en la escena (por offsets), pero lo coloca en el centro.
	var w := text_box.size.x
	var h := text_box.size.y
	text_box.anchor_left = 0.5
	text_box.anchor_top = 0.5
	text_box.anchor_right = 0.5
	text_box.anchor_bottom = 0.5
	text_box.offset_left = -w * 0.5
	text_box.offset_top = -h * 0.5
	text_box.offset_right = w * 0.5
	text_box.offset_bottom = h * 0.5

	# Alineación del texto en el centro (y vertical, para que quede centrado dentro del panel)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _restore_textbox_layout() -> void:
	if not _textbox_saved or not is_instance_valid(text_box):
		return
	text_box.anchor_left = _textbox_anchor_left
	text_box.anchor_top = _textbox_anchor_top
	text_box.anchor_right = _textbox_anchor_right
	text_box.anchor_bottom = _textbox_anchor_bottom
	text_box.offset_left = _textbox_offset_left
	text_box.offset_top = _textbox_offset_top
	text_box.offset_right = _textbox_offset_right
	text_box.offset_bottom = _textbox_offset_bottom

	# Devolvemos alineación por defecto para no afectar otros textos
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	text.vertical_alignment = VERTICAL_ALIGNMENT_TOP

func _finish() -> void:
	_restore_textbox_layout()
	if return_to_menu:
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
