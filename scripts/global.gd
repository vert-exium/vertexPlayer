extends Node

# Stores global variables/data

signal returnHome
signal doneLoading
signal openSongMenu
signal openArtistsMenu
signal play_song(path: String)
signal resetPlaying
signal openPlaylistMenu
signal openSettingsMenu
signal colorChanged
signal openLargePlayer
signal closeLargePlayer




var hue: float
var saturation: float
var value: float
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
	load_playlists()
	_setup_user_songs()

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
		
		while song_queue.has(song_path):
			song_queue.erase(song_path)
		
		if song_list.has(song_path):
			var removed_index = song_list.find(song_path)
			song_list.erase(song_path)
			
			if removed_index < current_index and current_index > 0:
				current_index -= 1

func delete_playlist(playlist_name: String) -> void:
	if playlists.has(playlist_name):
		playlists.erase(playlist_name)
		save_playlists()
		print("Deleted playlist: " + playlist_name)
		song_queue.clear()
		song_list.clear()

func play_song_from_playlist(playlist_name: String, song_path: String) -> void:
	if playlists.has(playlist_name):
		song_list.assign(playlists[playlist_name])
		
		current_index = song_list.find(song_path)
		if current_index == -1:
			current_index = 0
		song_queue.clear()
		play_song.emit(song_list[current_index])

func rename_playlist(old_name: String, new_name: String) -> bool:
	if old_name == new_name or playlists.has(new_name):
		return false
	if playlists.has(old_name):
		playlists[new_name] = playlists[old_name]
		playlists.erase(old_name)
		save_playlists()
		print("Renamed playlist to: " + new_name)
		return true
	return false
	

func _setup_user_songs() -> void:
	if not DirAccess.dir_exists_absolute("user://audio/imported/"):
		DirAccess.make_dir_recursive_absolute("user://audio/imported")
		
	var default_songs = ["decay.mp3", "fade.mp3"]
	
	for song in default_songs:
		var user_path = "user://audio/imported/" + song
		
		if not FileAccess.file_exists(user_path):
			var res_path = "res://audio/imported/" + song
		
			var stream = load(res_path) as AudioStreamMP3
			
			if stream and stream.data.size() > 0:
				var file = FileAccess.open(user_path, FileAccess.WRITE)
				if file:
					file.store_buffer(stream.data)
					file.close()
					print("Successfully extracted: ", song)
				else:
					print("Failed to write to user folder: ", song)
			else:
				print("Could not load default song from res://: ", res_path)

func load_mp3_from_disk(path: String) -> AudioStreamMP3:
	if not FileAccess.file_exists(path):
		push_error("File does not exist at path: " + path)
		return null
		
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var stream = AudioStreamMP3.new()
		stream.data = file.get_buffer(file.get_length())
		file.close()
		return stream
	else:
		push_error("Failed to open audio file at path: " + path)
		return null
