extends Area2D

# Variable de bloqueo (empieza en falso)
var se_puede_recoger: bool = false

func _ready() -> void:
	modulate.a = 0.5 
	
	# Esperamos 1 segundo
	await get_tree().create_timer(1.0).timeout
	
	#  Desbloqueamos la recolección
	se_puede_recoger = true
	# Restauramos el color normal (si usaste el efecto visual)
	modulate.a = 1.0 

# Esta es la función que detecta cuando el jugador toca la esencia
func _on_body_entered(body: Node2D) -> void:
	# 3. EL FILTRO DE SEGURIDAD
	# Si todavía no ha pasado el segundo, ignoramos al jugador.
	if not se_puede_recoger:
		return
	# Verificamos que sea el Player quien la toca
	if body.name == "Player":
		print("+1 esencia")
		
		# Sumamos 1 a la variable global
		Global.esencias_colectadas += 1
		
		# Desaparecemos el objeto
		queue_free()
