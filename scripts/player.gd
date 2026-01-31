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
var sufijo_anim : String = "" # Guardará "" o "_masc"

func _ready() -> void:
	# 1. Recuperar posición si venimos de un portal
	if Global.viene_de_mascara:
		global_position = Global.posicion_jugador
		Global.viene_de_mascara = false
	
	# 2. Configurar la skin correcta al iniciar la escena
	if Global.skin_alternativa == true:
		sufijo_anim = "_masc"
	else:
		sufijo_anim = ""

func _process(delta: float) -> void:
	# --- 1. ESTADO DE HERIDO (Bloqueo de controles) ---
	if herido:
		# Aplicamos gravedad para que caiga si le pegan en el aire
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		# Animación de muerte/daño CON el sufijo correspondiente
		animated_sprite_2d.animation = "dying" + sufijo_anim
		move_and_slide()
		return # Cortamos aquí, no dejamos que se mueva ni salte

	# --- 2. FÍSICAS Y MOVIMIENTO ---
	
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

	# Movimiento Horizontal (Dash vs Correr)
	var direction := Input.get_axis("left", "right")
	
	if direction:
		if dashing:
			velocity.x = direction * DASH_SPEED
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Aplicar movimiento
	move_and_slide()

	# --- 3. ANIMACIONES (SISTEMA UNIFICADO) ---
	# Decidimos qué animación base toca
	var anim_base = "idle"
	
	if is_on_floor():
		if velocity.x != 0:
			if dashing:
				anim_base = "dash"
			else:
				anim_base = "running"
		else:
			anim_base = "idle"
	else:
		# Si está en el aire
		anim_base = "jumping"
	
	# APLICAMOS LA ANIMACIÓN + EL SUFIJO ("_masc" o "")
	animated_sprite_2d.animation = anim_base + sufijo_anim

	# Voltear sprite
	if direction == 1.0:
		animated_sprite_2d.flip_h = false
	elif direction == -1.0:
		animated_sprite_2d.flip_h = true
	
	# --- 4. SONIDOS DE PASOS ---
	var is_moving: bool = abs(velocity.x) > 20.0 and is_on_floor()
	
	if is_moving:
		footstep_timer -= delta
		if footstep_timer <= 0.0:
			_play_footstep()
			footstep_timer = footstep_interval
	else:
		footstep_timer = 0.0

	# --- 5. DASH INPUT ---
	if Input.is_action_just_pressed("dash") and can_dash and direction != 0:
		dashing = true
		can_dash = false
		dash_timer.start()
		dash_again_timer.start()
	
	# --- 6. CAMBIO DE NIVEL (MÁSCARA) ---
	if Input.is_action_just_pressed("mascara") and is_on_floor():
		# Guardar datos
		Global.posicion_jugador = global_position
		Global.viene_de_mascara = true
		
		# IMPORTANTE: Alternar el estado de la skin en el Global
		Global.skin_alternativa = !Global.skin_alternativa
		
		# Cambiar escena
		var ruta_nivel1 = "res://scenes/levels/level1.tscn"
		var ruta_nivel2 = "res://scenes/levels/level2.tscn"
		var actual = get_tree().current_scene.scene_file_path
		
		if actual == ruta_nivel1:
			get_tree().change_scene_to_file(ruta_nivel2)
		else:
			get_tree().change_scene_to_file(ruta_nivel1)

# --- FUNCIONES AUXILIARES ---

# Si tu Killzone llama a "recibir_daño", cámbiale el nombre aquí.
func recibir_daño():
	herido = true
	# Salto hacia atrás/arriba (Knockback)
	velocity.y = -300 
	
	# Esperamos
	await get_tree().create_timer(0.6).timeout
	
	herido = false

func _play_footstep() -> void:
	if footstep_sfx.is_empty():
		return
	footstep_sound.stream = footstep_sfx.pick_random() # Forma más corta de elegir random
	footstep_sound.pitch_scale = randf_range(0.96, 1.04)
	footstep_sound.volume_db = randf_range(-9.0, -6.0)
	footstep_sound.play()

func _on_dash_timer_timeout() -> void:
	dashing = false

func _on_dash_again_timer_timeout() -> void:
	can_dash = true
