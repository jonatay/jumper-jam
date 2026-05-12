extends Node

@onready var audio_stream_players: Array[Node] = get_children().filter(func(n) -> bool: return n is AudioStreamPlayer)

var sounds = {
	"CLICK": preload("uid://svqb3i5cdbar"),
	"FALL": preload("uid://cv2o5c1kc5u0s"),
	"JUMP": preload("uid://dkxfoic85c1hk"),
	#"JUMP": load("res://assets/sound/Jump2.wav")
}

# var time = 0.1
# func _process(delta: float) -> void:
# 	time -= delta
# 	if (time < 0):
# 		play_sound("JUMP")
# 		time = 0.1

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == 32: # space key
		play_sound("CLICK")

func play_sound(sound_name: String) -> void:
	if sound_name in sounds:
		var sound = sounds[sound_name]
		SoundManager.play_sound_effect(sound)
		# SoundManager.play_ui_sound(click)
		# SoundManager.play_ambient_sound(wind)
		# SoundManager.play_music(song)


	# 	# does not work in godot ... var player = audio_stream_players.find(func(p) -> bool: return not p.playing)
	# 	var player = null
	# 	for p in audio_stream_players:
	# 		if not p.playing:
	# 			player = p
	# 			break
	# 	#create new player if all are playing, more as demo bec really not needed
	# 	if !player:
	# 		UtlLogger.log_message("All audio players are busy, creating a new one.")
	# 		player = AudioStreamPlayer.new()
	# 		add_child(player)
	# 		audio_stream_players.append(player)
	# 	# play the sound
	# 	player.stream = sound
	# 	player.play()
