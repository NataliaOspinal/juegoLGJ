extends ScrollContainer

@export var text_node: RichTextLabel
@export_range(1, 100000, 0.1) var credits_time: float = 25.0
@export_range(0, 100000, 0.1) var margin_increment: float = 0.0

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

	var text_box_size := text_node.get_content_height()
	var window_size := DisplayServer.window_get_size().y

	# Ahora sí: colocamos el texto debajo de la pantalla
	var m := int(ceil(window_size + margin_increment))
	margin.add_theme_constant_override("margin_top", m)
	margin.add_theme_constant_override("margin_bottom", m)

	# Aseguramos que seguimos en el inicio (abajo) antes de empezar a mover.
	scroll_vertical = 0

	var scroll_amount: int = int(ceil(float(text_box_size) * 3.0 / 4.0 + float(window_size) * 2.0 + margin_increment))

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "scroll_vertical", scroll_amount, credits_time)
	tween.finished.connect(_is_credits_over)

func _is_credits_over() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

