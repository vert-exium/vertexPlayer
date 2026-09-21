extends TextureProgressBar

@export var audio_player: AudioStreamPlayer 

func _process(_delta: float) -> void:
	if audio_player and audio_player.stream and audio_player.playing:
		max_value = audio_player.stream.get_length()
		value = audio_player.get_playback_position()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if audio_player and audio_player.stream:
			var click_ratio = event.position.x / size.x
			var target_time = click_ratio * max_value
			audio_player.seek(target_time)
			value = target_time
