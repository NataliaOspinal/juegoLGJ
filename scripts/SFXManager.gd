# SFXManager.gd
extends Node

# Creamos varios reproductores para que puedan sonar varios sonidos a la vez
func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0):
	var player = AudioStreamPlayer.new()
	add_child(player) # El player ahora es hijo del Autoload (nunca muere)
	
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()
	
	# Conectamos la señal finished para borrar el player cuando termine y liberar memoria
