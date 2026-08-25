extends Node

# Stores global variables/data

signal returnHome
signal doneLoading
signal openSongMenu
signal openArtistsMenu
signal play_song(path: String)
signal resetPlaying
signal openPlaylistMenu


var song_list: Array[String] = []
var song_queue: Array[String] = []
var current_index: int = 0

var playlists: Dictionary = {}
const SAVE_PATH = "user://playlists.save"

func skip_song() -> void:
	if not song_queue.is_empty():
		var next_path = song_queue.pop_front()
		play_song.emit(next_path)
	elif not song_list.is_empty():
		current_index = (current_index + 1) % song_list.size()
		play_song.emit(song_list[current_index])

func previous_song(audio_player: AudioStreamPlayer) -> void:
	if audio_player.get_playback_position() > 5.0:
		audio_player.seek(0.0)
	elif not song_list.is_empty():
		current_index = (current_index - 1 + song_list.size()) % song_list.size()
		play_song.emit(song_list[current_index])

func add_to_queue(path: String) -> void:
	song_queue.push_back(path)

func _ready() -> void:
	load_playlists

func save_playlists() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(playlists)
		file.store_line(json_string)

func load_playlists() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var parsed_data = JSON.parse_string(json_string)
		if parsed_data is Dictionary:
			playlists = parsed_data



func play_playlist(playlist_name: String) -> void:
	if playlists.has(playlist_name) and not playlists[playlist_name].is_empty():
		song_list.assign(playlists[playlist_name])
		current_index = 0
		song_queue.clear()
		play_song.emit(song_list[current_index])


func add_song_to_playlist(song_path: String, playlist_name: String) -> void:
	if playlists.has(playlist_name):
		if not song_path in playlists[playlist_name]:
			playlists[playlist_name].append(song_path)
			save_playlists()
			print("Added song to: " + playlist_name)
		else:
			print("Song is already in this playlist.")

func remove_song_from_playlist(song_path: String, playlist_name: String) -> void:
	if playlists.has(playlist_name):
		playlists[playlist_name].erase(song_path)
		save_playlists()
		print("Removed song from: " + playlist_name)

func delete_playlist(playlist_name: String) -> void:
	if playlists.has(playlist_name):
		playlists.erase(playlist_name)
		save_playlists()
		print("Deleted playlist: " + playlist_name)
