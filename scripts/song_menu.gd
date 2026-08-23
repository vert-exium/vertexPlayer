extends Node2D

@onready var container = $Control/scrollContainer/verticalBoxCont
@onready var template_button = $Control/scrollContainer/verticalBoxCont/optionButton1

const AUDIO_DIR = "res://audio/imported/"
const DEFAULT_COVER = preload("res://assets/songIcon.png")

func _ready() -> void:
	template_button.hide()
	load_songs_from_directory()

func load_songs_from_directory() -> void:
	var dir = DirAccess.open(AUDIO_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".mp3"):
				create_song_button(AUDIO_DIR + file_name)
			file_name = dir.get_next()
	else:
		push_error("An error occurred when trying to access the audio directory.")

func create_song_button(file_path: String) -> void:
	var audio_stream: AudioStream = load(file_path)
	if not audio_stream:
		return
		
	var metadata := MusicMetadata.new(audio_stream)
	
	var new_button = template_button.duplicate()
	new_button.show()
	
	var icon_rect = new_button.get_node("icon")
	var title_label = new_button.get_node("optionLabel")
	var artist_label = new_button.get_node("artistLabel")
	
	var title: String = metadata.title
	if not title.is_empty():
		title_label.text = title
	else:
		title_label.text = file_path.get_file()
	
	var artist: String = metadata.get_most_relevent_artist()
	artist_label.text = artist if not artist.is_empty() else "Unknown Artist"
	
	var cover_texture: ImageTexture = metadata.get_most_relevent_cover()
	if cover_texture != null:
		icon_rect.texture = cover_texture
	else:
		icon_rect.texture = DEFAULT_COVER
		
	new_button.pressed.connect(_on_song_button_pressed.bind(file_path))
	container.add_child(new_button)

func _on_song_button_pressed(path: String) -> void:
	Global.play_song.emit(path)
