extends CharacterBody2D  # <--- CAMBIO IMPORTANTE: Ya no es Node2D

# Configuración
@export var is_dangerous: bool = true
@export var push_force: float = 1000.0
const SPEED = 60.0

# Referencias visuales
@onready var anim_fantasma: AnimatedSprite2D = $Anim_Fantasma
@onready var anim_real: AnimatedSprite2D = $Anim_Real

# Referencias de áreas y sensores
@onready var killzone: Area2D = $Killzone
@onready var area_empuje: Area2D = $Area_Empuje
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight

# Gravedad (Obtenida de la configuración del proyecto)
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 1 # 1 = Derecha, -1 = Izquierda

func _ready() -> void:
	# Configuración inicial de visuales y áreas
	if is_dangerous:
		# MODO FANTASMA
		anim_fantasma.visible = true
		anim_real.visible = false
		killzone.monitoring = true
		area_empuje.monitoring = false
		anim_fantasma.play("default")
		
		# Ajuste sensores Fantasma
		ray_cast_left.position.x = -12 
		ray_cast_right.position.x = 12 
	else:
		# MODO REAL
		anim_fantasma.visible = false
		anim_real.visible = true
		killzone.monitoring = false
		area_empuje.monitoring = true
		anim_real.play("default")
		
		# Ajuste sensores Bicho Real (Ajusta estos valores si se cae)
		ray_cast_left.position.x = -5
		ray_cast_right.position.x = 5

func _physics_process(delta: float) -> void: # <--- Usamos _physics_process
	# 1. APLICAR GRAVEDAD
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. DETECCIÓN DE PRECIPICIOS Y PAREDES
	# Si toca pared (is_on_wall) O si se acaba el suelo (RayCasts)
	if is_on_wall() or (is_on_floor() and !detectar_suelo()):
		direction *= -1 # Invertir dirección
		voltear_sprites()
	
	# 3. MOVERSE
	velocity.x = direction * SPEED
	move_and_slide() # <--- Esto hace la magia de la física real

# Función auxiliar para verificar si los RayCasts ven suelo
func detectar_suelo() -> bool:
	if direction == 1:
		return ray_cast_right.is_colliding()
	else:
		return ray_cast_left.is_colliding()

func voltear_sprites() -> void:
	if direction > 0: # Derecha
		anim_fantasma.flip_h = false
		anim_real.flip_h = false
	else: # Izquierda
		anim_fantasma.flip_h = true
		anim_real.flip_h = true

# LÓGICA DE EMPUJE
func _on_area_empuje_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.has_method("apply_knockback"):
		
		# 1. Averiguamos si el jugador está a la derecha o izquierda del enemigo
		# sign() devuelve 1 si es positivo (derecha), -1 si es negativo (izquierda)
		var direccion_x = sign(body.global_position.x - global_position.x)
		
		# (Seguridad) Si están en el mismo pixel exacto, empujamos a la derecha por defecto
		if direccion_x == 0:
			direccion_x = 1
		
		# 2. Creamos un vector MANUALMENTE.
		# X = 1 o -1 (Puro lado)
		# Y = -0.2 (Un saltito MUY pequeño solo para despegarlo del suelo y evitar fricción)
		var vector_empuje = Vector2(direccion_x, -0.2).normalized()
		
		# 3. Aplicamos la fuerza
		# Como el vector es casi todo horizontal, la fuerza se irá a los lados.
		body.apply_knockback(vector_empuje * push_force)
