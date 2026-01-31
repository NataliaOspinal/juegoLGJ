extends Area2D

@onready var timer: Timer = $Timer
@export var es_mortal : bool = false 

# Interruptor para diferenciar Huecos de Enemigos

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
	# Quitar la cámara lenta
	Engine.time_scale = 1.0
	
	# Verificamos estado
	if Global.vidas > 0:
		pass 
	else:
		print("GAME OVER - Cambiando de escena...")
		
		# CAMBIO PRINCIPAL: Vamos a la escena de Game Over
		get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn")
