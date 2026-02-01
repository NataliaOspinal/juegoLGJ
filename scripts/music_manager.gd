extends Node

@export var fade_time := 1.0

@onready var a: AudioStreamPlayer = $A
@onready var b: AudioStreamPlayer = $B
@onready var stinger: AudioStreamPlayer = $Stinger


var using_a := true
var current_key := ""

func play_music(key: String, stream: AudioStream) -> void:
	if key == current_key:
		return
	current_key = key

	var from := a if using_a else b
	var to := b if using_a else a
	using_a = !using_a

	to.stream = stream
	to.volume_db = -80
	to.play()

	var t := create_tween()
	t.tween_property(from, "volume_db", -80, fade_time)
	t.parallel().tween_property(to, "volume_db", 0, fade_time)
	t.finished.connect(func():
		from.stop()
	)
	
func play_stinger(stream: AudioStream, volume_db: float = 0.0) -> void:
	stinger.stream = stream
	stinger.volume_db = volume_db
	stinger.play()

func duck_music(target_db: float = -10.0, time: float = 0.2) -> void:
	var from := a if using_a else b
	var t := create_tween()
	t.tween_property(from, "volume_db", target_db, time)

func restore_music(time: float = 0.6) -> void:
	var from := a if using_a else b
	var t := create_tween()
	t.tween_property(from, "volume_db", 0.0, time)
