extends Node2D

@onready var song_label: Label = $songLabel
@onready var artist_label: Label = $artistLabel
@onready var cover_rect: TextureRect = $coverRect

const DEFAULT_COVER = preload("res://assets/songIcon.png")

var current_metadata: MusicMetadata = null

func _ready() -> void:
	Global.play_song.connect(load_song_metadata)

func load_song_metadata(mp3_path: String) -> void:
	var audio_stream: AudioStream = load(mp3_path)
	if not audio_stream:
		push_error("Failed to load audio stream at path: " + mp3_path)
		return

	current_metadata = MusicMetadata.new(audio_stream)

	var title: String = current_metadata.title
	if not title.is_empty(): song_label.text = title 
	else:
		song_label.text = "Unknown Title"


	var artist: String = current_metadata.get_most_relevent_artist()
	artist_label.text = artist if not artist.is_empty() else "Unknown Artist"

	var cover_texture: ImageTexture = current_metadata.get_most_relevent_cover()
	if cover_texture != null:
		cover_rect.texture = cover_texture
	else:
		cover_rect.texture = DEFAULT_COVER
