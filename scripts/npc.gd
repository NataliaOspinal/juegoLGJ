extends Area2D

# --- CAMBIO IMPORTANTE ---
# En lugar de una constante fija, usamos una variable exportada.
# Esto hará que aparezca un campo en el Inspector para elegir el archivo.
@export var recurso_dialogo: DialogueResource
# -------------------------

# NUEVA VARIABLE PARA LA APARIENCIA
@export var nombre_animacion: String = "idle_azul"
@export var escena_esencia: PackedScene
@export var id_npc: String = ""

# --- Referencia al Sprite ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const ESENA_CAJA = preload("res://assets/ui/caja_dialogo.tscn") # Asegúrate que esta ruta sea correcta

var player_en_zona: bool = false
var chat_ya_abierto: bool = false
var muriendo: bool = false

func _ready() -> void:
	if id_npc != "" and Global.npcs_liberados.has(id_npc):
		queue_free()
		return
	# Al iniciar el juego, reproducimos la animación que elegimos en el Inspector
	if sprite:
		sprite.play(nombre_animacion)

func _process(_delta: float) -> void:
	if player_en_zona and not chat_ya_abierto and not muriendo:
		if Input.is_action_just_pressed("interact"):
			abrir_dialogo()

func abrir_dialogo():
	if recurso_dialogo == null: return
	chat_ya_abierto = true
	var globo = ESENA_CAJA.instantiate()
	get_tree().current_scene.add_child(globo)
	globo.start(recurso_dialogo, "start", [self]) 
	globo.tree_exited.connect(func(): chat_ya_abierto = false)
	
func liberar_alma():
	muriendo = true
	
	if id_npc != "":
		if not Global.npcs_liberados.has(id_npc):
			Global.npcs_liberados.append(id_npc)
	
	# Si la animación es "idle_azul", se convierte en "muerte_azul"
	var anim_muerte = nombre_animacion.replace("idle", "muerte")
	
	if sprite.sprite_frames.has_animation(anim_muerte):
		sprite.play(anim_muerte)
		# Esperamos a que termine la animación
		await sprite.animation_finished
	
	# Instanciamos la Esencia
	if escena_esencia:
		var esencia = escena_esencia.instantiate()
		# IMPORTANTE: La agregamos al PADRE del NPC (el Nivel), no al NPC
		# Si la agregamos al NPC, desaparecería cuando el NPC muera.
		get_parent().add_child(esencia)
		esencia.global_position = global_position
	
	# Adiós NPC
	queue_free()

# --- Detección del Player ---
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player": # Asegúrate que tu jugador se llame "Player"
		player_en_zona = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_en_zona = false
