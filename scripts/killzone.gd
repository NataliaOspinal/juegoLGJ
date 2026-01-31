extends Area2D

@onready var timer: Timer = $Timer
@export var es_mortal : bool = false 

# Interruptor para diferenciar Huecos de Enemigos
# Si es TRUE (activado), te mata y reinicia el nivel.
# Si es FALSE (desactivado), solo te quita vida y sigues jugando.
@export var es_mortal : bool = false 

func _on_body_entered(body):
	# Solo nos importa si es el Jugador
	if body.name != "Player":
		return
	
	# Si el timer corre, no hacemos nada (invencible)
	if not timer.is_stopped():
		return

	if body.has_method("recibir_daño"):
		body.recibir_daño() 
		
	if es_mortal:
		print("Caída al vacío - Game Over instantáneo")
		
		# Forzamos las vidas a 0.
		Global.vidas = 0 
		
		# Ponemos cámara lenta para mas drama
		Engine.time_scale = 0.5 
		
		# Iniciamos el timer para dar tiempo a ver las vidas grises antes de reiniciar
		timer.start()
		return # Terminamos aquí	
		
	# Lógica de vidas y reinicio
	if es_mortal:
		Global.vidas = 0
		timer.start()
	else:
		Global.vidas -= 1
		timer.start()
		
	Engine.time_scale = 0.5

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	
	# Verificamos estado
	if Global.vidas > 0:
		# Si aún quedan vidas, el jugador sigue jugando ahí mismo
		pass 
	else:
		# Si las vidas son 0 (porque caímos o porque nos mató un enemigo)
		print("GAME OVER - Reiniciando...")
		
		# Restablecemos las vidas para el próximo intento
		Global.vidas = 3 
		
		# Reiniciamos el nivel
		get_tree().reload_current_scene()
