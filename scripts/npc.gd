extends Area2D

# --- CAMBIO IMPORTANTE ---
# En lugar de una constante fija, usamos una variable exportada.
# Esto hará que aparezca un campo en el Inspector para elegir el archivo.
@export var recurso_dialogo: DialogueResource
# -------------------------

# NUEVA VARIABLE PARA LA APARIENCIA
@export var nombre_animacion: String = "idle_azul"

# --- Referencia al Sprite ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const ESENA_CAJA = preload("res://assets/ui/caja_dialogo.tscn") # Asegúrate que esta ruta sea correcta

var player_en_zona: bool = false
var chat_ya_abierto: bool = false

func _ready() -> void:
	# Al iniciar el juego, reproducimos la animación que elegimos en el Inspector
	if sprite:
		sprite.play(nombre_animacion)

func _process(_delta: float) -> void:
	if player_en_zona and not chat_ya_abierto:
		if Input.is_action_just_pressed("interact"):
			abrir_dialogo()

func abrir_dialogo():
	# Verificamos que se haya asignado un diálogo antes de intentar abrirlo
	if recurso_dialogo == null:
		print("Error: No se ha asignado un archivo de diálogo a este NPC.")
		return

	chat_ya_abierto = true
	var globo = ESENA_CAJA.instantiate()
	get_tree().current_scene.add_child(globo)

	# Usamos la variable exportada 'recurso_dialogo'
	globo.start(recurso_dialogo, "start")

	globo.tree_exited.connect(func():
		chat_ya_abierto = false
	)

# --- Detección del Player ---
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player": # Asegúrate que tu jugador se llame "Player"
		player_en_zona = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_en_zona = false
