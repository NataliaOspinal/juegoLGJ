extends CharacterBody2D

# --- REFERENCIAS A NODOS ---
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var footstep_sound: AudioStreamPlayer2D = $FootstepSound
@onready var dash_timer: Timer = $DashTimer
@onready var dash_again_timer: Timer = $DashAgainTimer

# --- CONFIGURACIÓN DE SONIDO ---
@export var footstep_sfx: Array[AudioStream] = []
@export_range(0.05, 1.0, 0.01) var footstep_interval := 0.22
var footstep_timer := 0.0

# --- CONFIGURACIÓN DE MOVIMIENTO ---
const DASH_SPEED = 900.0
const SPEED = 300
const JUMP_VELOCITY = -850 

var dashing = false
var can_dash = true

# --- VARIABLES DE ESTADO ---
var herido : bool = false
var sufijo_anim : String = "" 
var nivel_permite_dash : bool = false

# Variable para bloquear el movimiento mientras se pone la máscara
var is_transicionando: bool = false

func _ready() -> void:
	var ruta_actual = get_tree().current_scene.scene_file_path
	
	if "level1" in ruta_actual:
		nivel_permite_dash = true
		
		# --- CORRECCIÓN CLAVE ---
		# Si estamos en Level 1, forzamos que no haya máscara
		Global.skin_alternativa = false 
		sufijo_anim = "" 
		
	else:
		nivel_permite_dash = false
		# En otros niveles (Level 2), respetamos lo que diga la variable global
		if Global.skin_alternativa:
			sufijo_anim = "_masc"
		else:
			sufijo_anim = ""

	# Posicionar al jugador si viene de una transición
	if Global.viene_de_mascara:
		global_position = Global.posicion_jugador
		Global.viene_de_mascara = false

# CAMBIO IMPORTANTE: Usamos _physics_process para CharacterBody2D
func _physics_process(delta: float) -> void:
	# 1. BLOQUEO DE TRANSICIÓN
	# Si estamos poniéndonos la máscara, detenemos toda la lógica de movimiento aquí.
	if is_transicionando:
		return

	# -- ESTADO DE HERIDO --
	if herido:
		if not is_on_floor():
			velocity += get_gravity() * delta
		animated_sprite_2d.animation = "dying" + sufijo_anim
		move_and_slide()
		return

	# --- 2. FÍSICAS Y MOVIMIENTO ---
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

	var direction := Input.get_axis("left", "right")
	
	if direction:
		if dashing:
			velocity.x = direction * DASH_SPEED
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# --- 3. ANIMACIONES ---
	var anim_base = "idle"
	
	if dashing:
		anim_base = "dash"
	elif is_on_floor():
		if velocity.x != 0:
			anim_base = "running"
		else:
			anim_base = "idle"
	else:
		anim_base = "jumping"
	
	animated_sprite_2d.animation = anim_base + sufijo_anim

	if direction == 1.0:
		animated_sprite_2d.flip_h = false
	elif direction == -1.0:
		animated_sprite_2d.flip_h = true
	
	# --- 4. SONIDOS ---
	var is_moving: bool = abs(velocity.x) > 20.0 and is_on_floor()
	if is_moving:
		footstep_timer -= delta
		if footstep_timer <= 0.0:
			_play_footstep()
			footstep_timer = footstep_interval
	else:
		footstep_timer = 0.0

	# --- 5. DASH INPUT ---
	if Input.is_action_just_pressed("dash") and can_dash and direction != 0 and nivel_permite_dash:
		dashing = true
		can_dash = false
		dash_timer.start()
		dash_again_timer.start()
	
	# --- 6. DETECTAR INPUT DE MÁSCARA ---
	# (Aquí solo detectamos la tecla, la lógica pesada la pasamos a una función aparte)
	if Input.is_action_just_pressed("mascara") and is_on_floor():
		iniciar_transicion_nivel()
		
func apply_knockback(knockback_force: Vector2) -> void:
	# Aplicamos la fuerza directamente a la velocidad
	velocity = knockback_force
	move_and_slide()

# --- NUEVA FUNCIÓN PARA ORDENAR LA TRANSICIÓN ---
func iniciar_transicion_nivel():
	# A. Bloqueamos el input y movimiento (gracias al if al inicio de _physics_process)
	is_transicionando = true
	velocity = Vector2.ZERO # Frenamos al personaje en seco
	
	# B. Reproducimos la animación
	# Asegúrate de que "putting" existe en tus SpriteFrames. 
	# Si tienes una versión con y sin máscara, añade + sufijo_anim si es necesario.
	animated_sprite_2d.play("putting" + sufijo_anim)
	
	# C. Esperamos a que el nodo AnimatedSprite termine la animación
	await animated_sprite_2d.animation_finished
	
	# D. Lógica de cambio de escena
	Global.posicion_jugador = global_position
	Global.viene_de_mascara = true
	Global.skin_alternativa = !Global.skin_alternativa
	
	var ruta_nivel1 = "res://scenes/levels/level1.tscn"
	var ruta_nivel2 = "res://scenes/levels/level2.tscn"
	var actual = get_tree().current_scene.scene_file_path
	
	if actual == ruta_nivel1:
		get_tree().change_scene_to_file(ruta_nivel2)
	else:
		get_tree().change_scene_to_file(ruta_nivel1)

# --- FUNCIONES AUXILIARES ---

func recibir_daño():
	herido = true
	velocity.y = -300 
	await get_tree().create_timer(0.6).timeout
	herido = false

func _play_footstep() -> void:
	if footstep_sfx.is_empty():
		return
	footstep_sound.stream = footstep_sfx.pick_random()
	footstep_sound.pitch_scale = randf_range(0.96, 1.04)
	footstep_sound.volume_db = randf_range(-9.0, -6.0)
	footstep_sound.play()

func _on_dash_timer_timeout() -> void:
	dashing = false

func _on_dash_again_timer_timeout() -> void:
	can_dash = true
