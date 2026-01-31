extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound

@onready var footstep_sound: AudioStreamPlayer2D = $FootstepSound
@export var footstep_sfx: Array[AudioStream] = []
@export_range(0.05, 1.0, 0.01) var footstep_interval := 0.22
var footstep_timer := 0.0


const SPEED = 300
const JUMP_VELOCITY = -850 #Proyecto -> config proy -> general -> busca gravity para ajustar

# Variable nueva para bloquear controles/animación
var herido : bool = false

func _ready() -> void:
	randomize()
	# Verificamos si venimos de usar la máscara
	if Global.viene_de_mascara == true:
		global_position = Global.posicion_jugador
		# Reseteamos la variable
		Global.viene_de_mascara = false

func _process(delta: float) -> void:
	if herido:
		# Reproducir animación de dolor y no hacer nada más
		animated_sprite_2d.animation = "dying"
		velocity += get_gravity() * delta
		move_and_slide()
		return
		
	# Agregar animacion
	if velocity.x > 1 or velocity.x < -1:
		animated_sprite_2d.animation = "running"
	else:
		animated_sprite_2d.animation = "idle"	
		
	# Agrega la gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite_2d.animation = "jumping"

	# Agrega el salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

	# Manejar las direcciones izq y der
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	
	var is_moving: bool = abs(velocity.x) > 20.0
	var can_step: bool = is_on_floor() and is_moving and not herido

	if can_step:
		footstep_timer -= delta
	if footstep_timer <= 0.0:
		_play_footstep()
		footstep_timer = footstep_interval
	else:
		# resetea para que al volver a correr no dispare un paso instantáneo raro
		footstep_timer = 0.0
	
	if direction == 1.0:
		animated_sprite_2d.flip_h = false
	elif direction == -1.0:
		animated_sprite_2d.flip_h = true
	
	# Agrega cambio de nivel con tecla
	if Input.is_action_just_pressed("mascara") and is_on_floor():
		# Guardamos la posición actual en el Global
		Global.posicion_jugador = global_position
		Global.viene_de_mascara = true
		
		# Decidimos a qué escena ir
		var ruta_nivel1 = "res://scenes/levels/level1.tscn"
		var ruta_nivel2 = "res://scenes/levels/level2.tscn"
		var escena_actual = get_tree().current_scene.scene_file_path
		
		if escena_actual == ruta_nivel1:
			get_tree().change_scene_to_file(ruta_nivel2)
		else:
			get_tree().change_scene_to_file(ruta_nivel1)
		
func recibir_daño():
	herido = true
	animated_sprite_2d.animation = "dying" 
	velocity.y = -300
	await get_tree().create_timer(0.6).timeout
	herido = false

func _play_footstep() -> void:
	if footstep_sfx.is_empty():
		return

	footstep_sound.stream = footstep_sfx[randi() % footstep_sfx.size()]
	footstep_sound.pitch_scale = randf_range(0.96, 1.04)
	footstep_sound.volume_db = randf_range(-9.0, -6.0)
	footstep_sound.play()
