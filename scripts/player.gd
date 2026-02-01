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

func _ready() -> void:
	if Global.viene_de_mascara:
		global_position = Global.posicion_jugador
		Global.viene_de_mascara = false
	
	if Global.skin_alternativa == true:
		sufijo_anim = "_masc"
	else:
		sufijo_anim = ""
		
	var ruta_actual = get_tree().current_scene.scene_file_path
	if "level1" in ruta_actual:
		nivel_permite_dash = true
	else:
		nivel_permite_dash = false

func _process(delta: float) -> void:
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

	# --- 3. ANIMACIONES (CORREGIDO) ---
	var anim_base = "idle"
	
	# PRIORIDAD 1: ¿Está haciendo DASH? (No importa si es aire o suelo)
	if dashing:
		anim_base = "dash"
	
	# PRIORIDAD 2: Si NO es dash, ¿Está en el suelo?
	elif is_on_floor():
		if velocity.x != 0:
			anim_base = "running"
		else:
			anim_base = "idle"
			
	# PRIORIDAD 3: Si NO es dash y NO está en el suelo -> Salto
	else:
		anim_base = "jumping"
	
	# Aplicamos el nombre final + sufijo
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
	
	# --- 6. CAMBIO DE NIVEL ---
	if Input.is_action_just_pressed("mascara") and is_on_floor():
		Engine.time_scale = 1.0 
		
		# Guardar datos
		Global.posicion_jugador = global_position
		Global.viene_de_mascara = true
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
