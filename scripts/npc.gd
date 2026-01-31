extends Area2D

@onready var label: Label = $Label
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var player_en_zona : bool = false
var dialogo_actual : int = 0
var player_ref : Node2D = null # Guardamos referencia al jugador para saber dónde está

# Lista de frases
var frases = [
	"¡Hola viajero!",
	"Ten cuidado, he visto caracoles muy agresivos.",
	"Dicen que si presionas Q cambias de dimensión...",
	"¡Buena suerte!"
]

func _ready() -> void:
	# Iniciamos animación (asegúrate de tener una anim llamada "idle")
	animated_sprite.play("idle") 
	label.visible = false

func _process(_delta: float) -> void:
	if player_en_zona:
		# 1. Detectar tecla de interacción
		if Input.is_action_just_pressed("interactuar"):
			avanzar_dialogo()
			
		# Hacer que el NPC mire al jugador
		if player_ref != null:
			if player_ref.global_position.x < global_position.x:
				animated_sprite.flip_h = true  # Jugador a la izquierda
			else:
				animated_sprite.flip_h = false # Jugador a la derecha

func _on_body_entered(body: Node2D) -> void:
	# Aseguramos que sea el Jugador y no un caracol
	if body.name == "Player":
		player_en_zona = true
		player_ref = body # Guardamos quién es el jugador
		label.text = "[E] Hablar"
		label.visible = true
		dialogo_actual = 0 # Reiniciamos el diálogo al entrar

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_en_zona = false
		player_ref = null
		label.visible = false
		# No reiniciamos 'dialogo_actual' aquí para que no se pierda si te alejas un poco por error,
		# pero lo reiniciamos en el 'entered' para que la próxima vez empiece de cero.

func avanzar_dialogo():
	# Si aún quedan frases
	if dialogo_actual < frases.size():
		label.text = frases[dialogo_actual]
		dialogo_actual += 1
	else:
		# Volver a mostrar la instrucción
		label.text = "[E] Repetir"
		dialogo_actual = 0
