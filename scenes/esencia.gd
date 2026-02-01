extends Area2D

func _on_body_entered(body):
	# Verificamos que sea el Player quien la toca
	if body.name == "Player":
		print("+1 esencia")
		
		# Sumamos 1 a la variable global
		Global.esencias_colectadas += 1
		
		# Desaparecemos el objeto
		queue_free()
