extends Node2D

@export var npcs_para_terminar := 3
@export var end_game_scene_path := "res://scenes/ui/end_game.tscn"

func _ready() -> void:
	MusicManager.play_music("level2", preload("res://assets/sounds/music/music_conmascara.wav"))

	# Conectamos a todos los NPCs del nivel que expongan la señal `npc_liberado`.
	# (No dependemos de grupos ni nombres: recorremos el árbol.)
	_connect_npcs_in_tree()
	_check_end_condition()

func _connect_npcs_in_tree() -> void:
	for node in get_tree().current_scene.get_children():
		_connect_npcs_recursive(node)

func _connect_npcs_recursive(node: Node) -> void:
	if node == null:
		return
	if node.has_signal("npc_liberado"):
		# Evita duplicar conexiones
		if not node.npc_liberado.is_connected(_on_npc_liberado):
			node.npc_liberado.connect(_on_npc_liberado)
	for child in node.get_children():
		_connect_npcs_recursive(child)

func _on_npc_liberado(_id: String) -> void:
	_check_end_condition()

func _check_end_condition() -> void:
	# `Global.npcs_liberados` se llena en npc.gd al liberar un alma.
	# Cuando llegue a 3 (o el número configurado), terminamos.
	if Global.npcs_liberados.size() >= npcs_para_terminar:
		get_tree().change_scene_to_file(end_game_scene_path)
