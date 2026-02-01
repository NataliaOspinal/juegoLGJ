extends Area2D

const ARCHIVO_DIALOGO = preload("res://dialogos/conversacion_npc.dialogue")
const CAJA_TEXTO = preload("res://assets/ui/caja_dialogo.tscn")

var player_en_zona : bool = false
var chat_abierto : bool = false # <--- NUEVA VARIABLE DE CONTROL

func _process(_delta: float) -> void:
	# Agregamos la condición: "Y que el chat NO esté abierto ya"
	if player_en_zona and not chat_abierto:
		if Input.is_action_just_pressed("interact"):
			mostrar_dialogo()

func mostrar_dialogo():
	chat_abierto = true # 1. Bloqueamos para que no se abra otro
	
	var globo = CAJA_TEXTO.instantiate()
	get_tree().current_scene.add_child(globo)
	globo.start(ARCHIVO_DIALOGO, "start")
	
	# 2. Conectamos una señal para saber cuándo se cierra la caja
	# Cuando el globo desaparezca (tree_exited), ejecutamos el código para desbloquear
	globo.tree_exited.connect(func(): chat_abierto = false)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_en_zona = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_en_zona = false
