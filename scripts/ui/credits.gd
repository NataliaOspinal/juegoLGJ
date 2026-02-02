extends ScrollContainer

@export var text_node: RichTextLabel
# credits_time queda como fallback (por compatibilidad con escenas existentes)
@export_range(0.0, 100000, 0.1) var credits_time: float = 25.0
@export_range(0, 100000, 0.1) var margin_increment: float = 0.0

# Texto estático (fuera del ScrollContainer) que debe aparecer al final.
@onready var rich_text_label: RichTextLabel = $"../RichTextLabel"

# Nueva forma recomendada: velocidad de scroll en píxeles/segundo.
# Si es > 0, el tiempo se calcula automáticamente en base a la distancia real.
@export_range(0.0, 5000.0, 1.0) var scroll_speed: float = 120.0

@export_range(0.0, 30.0, 0.1) var final_text_time: float = 4.0
@export_range(0.0, 5.0, 0.05) var fade_time: float = 0.35

@onready var margin: MarginContainer = $MarginContainer

var _scroll_target: int = 0
var _ended: bool = false
var _vbar: VScrollBar

func _process(_delta: float) -> void:
	# Detecta el final usando el valor real del scrollbar.
	# Esto evita desfasajes cuando scroll_vertical y max_value/page no coinciden 1:1.
	if _ended:
		set_process(false)
		return
	if _vbar == null:
		return
	if _scroll_target > 0 and _vbar.value >= float(_scroll_target) - 0.5:
		_on_scroll_finished()

func _ready() -> void:
	# El texto final debe empezar oculto.
	if is_instance_valid(rich_text_label):
		rich_text_label.visible = false
		rich_text_label.modulate.a = 0.0

	# Arrancamos desde abajo para evitar que se vea el texto en su posición "natural"
	# durante 1-2 frames mientras calculamos tamaños.
	scroll_vertical = 0
	margin.add_theme_constant_override("margin_top", 100000)
	margin.add_theme_constant_override("margin_bottom", 0)

	# Esperamos a que el control ya esté en el árbol y con layout aplicado.
	await get_tree().process_frame
	margin.queue_sort()
	text_node.queue_redraw()
	await get_tree().process_frame

	var window_size := DisplayServer.window_get_size().y

	# Ahora sí: colocamos el texto debajo de la pantalla
	var m := int(ceil(window_size + margin_increment))
	margin.add_theme_constant_override("margin_top", m)
	margin.add_theme_constant_override("margin_bottom", m)

	# Espera un frame más para recalcular scrollbars con el contenido final.
	await get_tree().process_frame

	# Aseguramos que seguimos en el inicio (abajo) antes de empezar a mover.
	scroll_vertical = 0

	# Cacheamos el scrollbar y calculamos un objetivo "visual" (sin cola invisible):
	# max_value - page es el punto donde el final del contenido llega al borde inferior.
	_vbar = get_v_scroll_bar()
	_scroll_target = 0
	if _vbar:
		_scroll_target = int(ceil(maxf(0.0, _vbar.max_value - _vbar.page)))

	# Duración basada en distancia real para una velocidad consistente.
	var duration := credits_time
	if scroll_speed > 0.0:
		duration = float(_scroll_target) / scroll_speed
	duration = clampf(duration, 2.0, 60.0)

	_ended = false
	set_process(true)

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scroll_vertical", _scroll_target, duration)
	tween.finished.connect(_on_scroll_finished)

func _on_scroll_finished() -> void:
	if _ended:
		return
	_ended = true

	# Fuerza el valor final para evitar quedarnos cerca pero sin gatillar.
	scroll_vertical = _scroll_target
	if _vbar:
		_vbar.value = float(_scroll_target)

	# Fade out del contenido scrolleable.
	var fade_out := create_tween()
	fade_out.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_out.tween_property(text_node, "modulate:a", 0.0, fade_time)
	fade_out.finished.connect(_show_final_text)

func _show_final_text() -> void:
	# Oculta el contenido que se desplaza.
	margin.visible = false

	# Si no existe el label final, terminamos.
	if not is_instance_valid(rich_text_label):
		_is_credits_over()
		return

	rich_text_label.visible = true

	var t := create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	# Fade in
	t.tween_property(rich_text_label, "modulate:a", 1.0, fade_time)
	# Espera
	t.tween_interval(final_text_time)
	# Fade out
	t.tween_property(rich_text_label, "modulate:a", 0.0, fade_time)
	t.finished.connect(_is_credits_over)

func _is_credits_over() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
