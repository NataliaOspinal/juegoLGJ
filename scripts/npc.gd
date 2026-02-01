extends Area2D

# 1. Preload de los recursos (Ajusta las rutas si es necesario)
const ARCHIVO_DIALOGO = preload("res://dialogos/conversacion_npc.dialogue")
const ESENA_CAJA = preload("res://assets/ui/caja_dialogo.tscn")

var player_en_zona: bool = false
# Semáforo: Evita abrir el chat si ya está abierto
var chat_ya_abierto: bool = false 

func _process(_delta: float) -> void:
	# Si el jugador está cerca Y el chat NO está abierto...
	if player_en_zona and not chat_ya_abierto:
		if Input.is_action_just_pressed("interact"):
			abrir_dialogo()

func abrir_dialogo():
	# 1. Ponemos el semáforo en rojo INMEDIATAMENTE
	chat_ya_abierto = true
	
	# 2. Instanciamos la caja de diálogo
	var globo = ESENA_CAJA.instantiate()
	get_tree().current_scene.add_child(globo)
	
	# 3. Iniciamos el diálogo (Ajusta "start" si tu título en el .dialogue es otro)
	globo.start(ARCHIVO_DIALOGO, "start")
	
	# 4. Conectamos una señal para saber cuándo se cierra la caja.
	# Cuando el nodo 'globo' desaparece de la escena (tree_exited),
	# ejecutamos el código que vuelve a poner el semáforo en verde.
	globo.tree_exited.connect(func(): 
		chat_ya_abierto = false
		print("Diálogo cerrado. Interacción habilitada de nuevo.")
	)

# --- Detección del Player ---
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player": # Asegúrate que tu jugador se llame "Player"
		player_en_zona = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_en_zona = false
