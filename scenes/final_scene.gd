extends Control

# --- CONFIGURACIÓN ---
# Arrastra aquí tu archivo 'final.dialogue' que creaste en el paso 1
const DIALOGO_RECURSO = preload("res://dialogos/final.dialogue")

# Imágenes de fondo de la escena (NO las de la caja de diálogo)
const FONDO_BUENO = preload("res://assets/images/background/mundo feliz fondo.png") # Ajusta ruta
const FONDO_MALO = preload("res://assets/images/background/Fondo triste.png")   # Ajusta ruta
const CREDITOS = preload("res://scenes/ui/credits_new.tscn")


# --- REFERENCIAS ---
# Asegúrate de que el nombre coincida con tu nodo en la escena
@onready var caja_dialogo = $CajaDialogo 
@onready var texture_rect_fondo = $TextureRect

func _ready() -> void:
	# Esperamos un poco para que no sea brusco
	await get_tree().create_timer(1.0).timeout
	iniciar_final()

func iniciar_final() -> void:
	if Global.decision_final == "quitar":
		# 1. Cambiamos el fondo de la escena
		texture_rect_fondo.texture = FONDO_BUENO
		
		# 2. Iniciamos el diálogo usando la función ORIGINAL de tu caja
		# start(recurso, titulo_de_seccion)
		caja_dialogo.start(DIALOGO_RECURSO, "final_quitar")
		
		
	elif Global.decision_final == "mantener":
		# 1. Cambiamos el fondo de la escena
		texture_rect_fondo.texture = FONDO_MALO
		
		# 2. Iniciamos el diálogo correspondiente
		caja_dialogo.start(DIALOGO_RECURSO, "final_mantener")
	
	await DialogueManager.dialogue_ended
	
	# 3. Una vez terminado, cambiamos a los créditos
	get_tree().change_scene_to_packed(CREDITOS)
