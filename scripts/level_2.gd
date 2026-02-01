extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_music("level2", preload("res://assets/sounds/music/music_conmascara.wav"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
