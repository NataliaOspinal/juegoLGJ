extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body):
	# --- FILTRO DE SEGURIDAD ---
	# Preguntamos: "¿El cuerpo que entró NO se llama Player?"
	# Si es un caracol, una caja o cualquier otra cosa, detenemos la función aquí.
	if body.name != "Player":
		return
	
	# Si pasamos el filtro, significa que SÍ es el Player.
	# Protección de doble golpe (si ya estamos muriendo, no morir de nuevo)
	if not timer.is_stopped():
		return
		
	print("Moriste")
	Global.vidas -= 1
	Engine.time_scale = 0.5
	timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	if Global.vidas > 0:
		get_tree().reload_current_scene()
	else:
		Global.vidas = 3
		get_tree().change_scene_to_file("res://scenes/levels/level1.tscn")
