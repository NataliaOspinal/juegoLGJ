extends ScrollContainer

@export var text_node: RichTextLabel
# credits_time queda como fallback (por compatibilidad con escenas existentes)
@export_range(0.0, 100000, 0.1) var credits_time: float = 25.0
@export_range(0, 100000, 0.1) var margin_increment: float = 0.0

# Nueva forma recomendada: velocidad de scroll en píxeles/segundo.
# Si es > 0, el tiempo se calcula automáticamente en base a la distancia real.
@export_range(0.0, 5000.0, 1.0) var scroll_speed: float = 120.0

@onready var margin: MarginContainer = $MarginContainer

func _ready() -> void:
	# Arrancamos desde abajo para evitar que se vea el texto en su posición "natural"
	# durante 1-2 frames mientras calculamos tamaños.
	scroll_vertical = 0
	margin.add_theme_constant_override("margin_top", 100000)
	margin.add_theme_constant_override("margin_bottom", 0)

	# Esperamos a que el control ya esté en el árbol y con layout aplicado.
	await get_tree().process_frame
	# Fuerza un re-layout inmediato (más robusto que esperar frames “a ciegas”).
	margin.queue_sort()
	text_node.queue_redraw()
	await get_tree().process_frame

	var window_size := DisplayServer.window_get_size().y

	# Ahora sí: colocamos el texto debajo de la pantalla
	var m := int(ceil(window_size + margin_increment))
	margin.add_theme_constant_override("margin_top", m)
	margin.add_theme_constant_override("margin_bottom", m)

	# Un frame más para que el ScrollContainer recalcule el tamaño del contenido
	# y el ScrollBar tenga un max_value correcto.
	await get_tree().process_frame

	# Aseguramos que seguimos en el inicio (abajo) antes de empezar a mover.
	scroll_vertical = 0

	# Destino real: el máximo scroll vertical posible.
	var vbar := get_v_scroll_bar()
	var scroll_amount: int = 0
	if vbar:
		scroll_amount = int(ceil(vbar.max_value))

	# Duración basada en distancia real para una velocidad consistente.
	var duration := credits_time
	if scroll_speed > 0.0:
		duration = float(scroll_amount) / scroll_speed
	# Evita duraciones absurdas (muy cortas o muy largas) por edge-cases.
	duration = clampf(duration, 2.0, 60.0)

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "scroll_vertical", scroll_amount, duration)
	tween.finished.connect(_is_credits_over)

func _is_credits_over() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
