extends Node2D

@onready var container = $Control/scrollContainer/verticalBoxCont
@onready var template_button = $Control/scrollContainer/verticalBoxCont/optionButton1

@onready var details_control = $detailsControl
@onready var details_container = $detailsControl/songListScroll/VBoxContainer
@onready var song_template = $detailsControl/songListScroll/VBoxContainer/songTemplate
@onready var playlist_title = $detailsControl/playlistTitleLabel

const DEFAULT_COVER = preload("res://assets/songIcon.png")

var currently_viewed_playlist: String = ""


func _ready() -> void:
	template_button.hide()
	song_template.hide()
	_show_main_view()
	
	$homeButton.pressed.connect(_on_home_pressed)
	$addPlaylistButton.pressed.connect(_on_add_playlist_pressed)
	

	$detailsControl/backToPlaylists.pressed.connect(_show_main_view)
	$detailsControl/playPlaylist.pressed.connect(_on_play_playlist_pressed)
	$detailsControl/deletePlaylist.pressed.connect(_on_delete_playlist_pressed)
	
	Global.openPlaylistMenu.connect(populate_playlists)
	populate_playlists()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func populate_playlists() -> void:
	for child in container.get_children():
		if child != template_button:
			child.queue_free()
##               ^^^       ^^^
## Makes sure that only the template button (optionButton1) is present and deletes any other children
	for playlist_name in Global.playlists.keys():
		var new_button = template_button.duplicate()
		new_button.show()
##          ^^^^          ^^^^
## For each playlist, duplicates the template button and shows the newly duplicated button
		var title_label = new_button.get_node("optionLabel")
		title_label.text = playlist_name
	## ^^ Updates the new label to the correct name of the playlist
	
		new_button.pressed.connect(func(): open_playlist_details(playlist_name))
		container.add_child(new_button)


func _on_home_pressed() -> void:
	Global.returnHome.emit()
# just returns to the home menu when the home button is pressed

func _on_add_playlist_pressed() -> void:
	var new_name = "Playlist " + str(Global.playlists.size() + 1)
	Global.playlists[new_name] = []
	Global.save_playlists()
	populate_playlists()

func open_playlist_details(playlist_name: String) -> void:
	currently_viewed_playlist = playlist_name
	playlist_title.text = playlist_name
	
	for child in details_container.get_children():
		if child != song_template:
			child.queue_free()
	
	for song_path in Global.playlists[playlist_name]:
		var new_song_row = song_template.duplicate()
		new_song_row.show()
		
		var title_label = new_song_row.get_node("songNameLabel")
		var artist_label = new_song_row.get_node("artistLabel")
		var icon_rect = new_song_row.get_node("icon")
		var delete_btn = new_song_row.get_node("removeSongButton")
		
		var audio_stream: AudioStream = load(song_path)
		if audio_stream:
			var metadata := MusicMetadata.new(audio_stream)
			
			var title: String = metadata.title
			title_label.text = title if not title.is_empty() else song_path.get_file()
			
			var artist: String = metadata.get_most_relevent_artist()
			artist_label.text = artist if not artist.is_empty() else "Unknown Artist"
			
			var cover_texture: ImageTexture = metadata.get_most_relevent_cover()
			if cover_texture != null:
				icon_rect.texture = cover_texture
			else:
				icon_rect.texture = DEFAULT_COVER
				
			delete_btn.pressed.connect(func(): _on_remove_song_pressed(song_path, new_song_row))
			
			details_container.add_child(new_song_row)
		
		_show_details_view()
		
func _on_remove_song_pressed(song_path: String, node_to_delete: Node) -> void:
	Global.remove_song_from_playlist(song_path, currently_viewed_playlist)
	node_to_delete.queue_free()


func _on_delete_playlist_pressed() -> void:
	Global.delete_playlist(currently_viewed_playlist)
	_show_main_view()
	populate_playlists()


func _on_play_playlist_pressed() -> void:
	Global.play_playlist(currently_viewed_playlist)

func _show_details_view() -> void:
	$Control.hide()
	$homeButton.hide()
	$addPlaylistButton.hide()
	details_control.show()

func _show_main_view() -> void:
	details_control.hide()
	$Control.show()
	$homeButton.show()
	$addPlaylistButton.show()
