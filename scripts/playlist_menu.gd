extends Node2D

@onready var container = $Control/scrollContainer/verticalBoxCont
@onready var template_button = $Control/scrollContainer/verticalBoxCont/optionButton1

func _ready() -> void:
	template_button.hide()
	$homeButton.pressed.connect(_on_home_pressed)
	$addPlaylistButton.pressed.connect(_on_add_playlist_pressed)
	Global.openPlaylistMenu.connect(populate_playlists)


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
	
		new_button.pressed.connect(func(): Global.play_playlist(playlist_name))
		container.add_child(new_button)
	## connects to a function to play the playlist


func _on_home_pressed() -> void:
	Global.returnHome.emit()
# just returns to the home menu when the home button is pressed

func _on_add_playlist_pressed() -> void:
	var new_name = "Playlist " + str(Global.playlists.size() + 1)
	Global.playlists[new_name] = []
	Global.save_playlists()
	populate_playlists()
