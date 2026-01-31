extends HBoxContainer

# Creamos dos "huecos" para arrastrar tus imágenes en el editor
@export var textura_vida_llena : Texture2D
@export var textura_vida_vacia : Texture2D

func _process(_delta: float) -> void:
	# Vamos a revisar cada uno de los hijos (los TextureRects)
	# Cuántos corazones pusiste
	for i in get_child_count():
		# Obtenemos el corazón actual (0, 1 o 2)
		var corazon = get_child(i)
		
		# Si el índice es menor que las vidas actuales, está lleno
		# Ejemplo: Si tengo 2 vidas:
		# i=0 (Corazón 1) < 2 -> LLENO
		# i=1 (Corazón 2) < 2 -> LLENO
		# i=2 (Corazón 3) es igual a 2 (no menor) -> VACÍO
		
		if i < Global.vidas:
			corazon.texture = textura_vida_llena
		else:
			corazon.texture = textura_vida_vacia
