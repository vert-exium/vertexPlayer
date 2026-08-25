extends Node2D

@onready var container = $Control/scrollContainer/verticalBoxCont
@onready var template_button = $Control/scrollContainer/verticalBoxCont/optionButton1

const AUDIO_DIR = "res://audio/imported/"
const DEFAULT_COVER = preload("res://assets/songIcon.png")

var playlist_popup: PopupMenu
var selected_song_path: String = ""


func _ready() -> void:
	template_button.hide()
	
	playlist_popup = PopupMenu.new()
	add_child(playlist_popup)
	playlist_popup.id_pressed.connect(_on_playlist_popup_id_pressed)
	
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
		
	# Register song into the global playlist
	if not file_path in Global.song_list:
		Global.song_list.append(file_path)
		
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
	
	new_button.gui_input.connect(_on_song_button_gui_input.bind(file_path))
	
	container.add_child(new_button)

func _on_song_button_pressed(path: String) -> void:
	Global.current_index = Global.song_list.find(path)
	Global.play_song.emit(path)


func open_playlist_popup() -> void:
	playlist_popup.clear()
	
	playlist_popup.add_separator("Add to playlist:")
	
	var id_counter = 1
	for playlist_name in Global.playlists.keys():
		playlist_popup.add_item(playlist_name, id_counter)
		playlist_popup.set_item_metadata(id_counter, playlist_name)
		id_counter += 1
	##  ^^^  This part of the function clears the popup list, adds the header, and then for every playlist that exists,
	## creates an item in the menu that displays the name of the playlist 
	
	if playlist_popup.item_count > 1: 
		playlist_popup.position = get_viewport().get_mouse_position()
		playlist_popup.popup()
	else:
		print("No playlists found! Make one first")


func _on_playlist_popup_id_pressed(id: int) -> void:
	var playlist_name = playlist_popup.get_item_metadata(id)
	Global.add_song_to_playlist(selected_song_path, playlist_name)

func _on_song_button_gui_input(event: InputEvent, path: String) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		selected_song_path = path
		open_playlist_popup()
