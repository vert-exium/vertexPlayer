extends Node2D

@onready var largePlayer = $screenControl/largePlayingMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$bootMenu.visible = true
	Global.returnHome.connect(_returnHomeFunction)
	Global.doneLoading.connect(_hideLoading)
	Global.openSongMenu.connect(_showSongMenu)
	Global.openArtistsMenu.connect(_showArtistsMenu)
	Global.play_song.connect(_updateSong)
	Global.openPlaylistMenu.connect(_showPlaylistMenu)
	Global.openSettingsMenu.connect(_showSettingsMenu)
	Global.colorChanged.connect(_updateColor)
	Global.openLargePlayer.connect(_openPlay)
	Global.closeLargePlayer.connect(_closePlay)
	
	# connects next/previous buttons 
	$skipButton.pressed.connect(Global.skip_song)
	$backButton.pressed.connect(Global.previous_song.bind($audioPlayer))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _returnHomeFunction():
	_hide_all()
	$playBar.visible = true
	$menuBrowser.visible = true

func _hideLoading():
	$bootMenu.visible = false

func _showSongMenu():
	_hide_all()
	$songMenu.visible = true

func _showArtistsMenu():
	_hide_all()
	$artistsMenu.visible = true

func _showPlaylistMenu():
	_hide_all()
	$playlistMenu.visible = true


func _hide_all():
	$menuBrowser.visible = false
	$songMenu.visible = false
	$artistsMenu.visible = false
	$playlistMenu.visible = false
	$settingsMenu.visible = false


func _updateSong(path: String):
	$audioPlayer.stream = load(path)
	$audioPlayer.play()

func _on_audio_player_finished() -> void:
	# Automatically move to the next song when the current one ends
	Global.skip_song()


func _on_buffer_timer_timeout() -> void:
	if not $audioPlayer.playing:
		Global.resetPlaying.emit()


func _on_pause_button_pressed() -> void:
	if $audioPlayer.stream_paused == true:
		$audioPlayer.stream_paused = false
	elif $audioPlayer.stream_paused == false:
		$audioPlayer.stream_paused = true

func _showSettingsMenu():
	_hide_all()
	$settingsMenu.show()

func _updateColor():
	$back.self_modulate.v = Global.value
	$back.self_modulate.s = Global.saturation
	$back.self_modulate.h = Global.hue

func _openPlay():
	var posTween = create_tween()
	posTween.set_ease(Tween.EASE_OUT)
	posTween.set_trans(Tween.TRANS_CUBIC)
	posTween.tween_property(largePlayer, "position:y", 0.0, 0.5)

func _closePlay():
	var posTween = create_tween()
	posTween.set_ease(Tween.EASE_OUT)
	posTween.set_trans(Tween.TRANS_CUBIC)
	posTween.tween_property(largePlayer, "position:y", 326.0, 0.5)
