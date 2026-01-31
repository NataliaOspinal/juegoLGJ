extends Area2D

@onready var timer: Timer = $Timer

# Interruptor para diferenciar Huecos de Enemigos
# Si es TRUE (activado), te mata y reinicia el nivel.
# Si es FALSE (desactivado), solo te quita vida y sigues jugando.
@export var es_mortal : bool = false 

func _on_body_entered(body):
	# Filtro para que solo afecte al Jugador
	if body.name != "Player":
		return
	
	# Si ya estamos "heridos" (timer corriendo), ignorar golpes (invencibilidad temporal)
	if not timer.is_stopped():
		return
		
	# --- COMPORTAMIENTO 1: CAÍDA AL VACÍO (Muerte Inmediata) ---
	if es_mortal:
		print("Caíste al vacío - Reiniciando nivel")
		Global.vidas = 0 
		
		verificar_muerte() # Decidimos si reiniciar o Game Over
		return # Terminamos aquí, no hacemos nada más

	# Enemigo normal ---
	print("Golpeado por enemigo - Vidas restantes: ", Global.vidas - 1)
	Global.vidas -= 1
	
	# Efecto de impacto (Cámara lenta)
	Engine.time_scale = 0.5
	
	# Verificamos si este golpe nos mató
	if Global.vidas <= 0:
		# Si llegamos a 0, reiniciamos
		verificar_muerte()
	else:
		# Volver a velocidad normal, no se reinicia la escena
		timer.start()

func _on_timer_timeout() -> void:
	# Solo para resetear del estado de cámara lenta
	Engine.time_scale = 1.0

# Función auxiliar para manejar el reinicio
func verificar_muerte():
	Engine.time_scale = 1.0 # Asegurar velocidad normal antes de cambiar
	if Global.vidas > 0:
		call_deferred("reiniciar_nivel")
	else:
		print("GAME OVER TOTAL")
		Global.vidas = 3
		call_deferred("reiniciar_nivel")

func reiniciar_nivel():
	get_tree().reload_current_scene()
