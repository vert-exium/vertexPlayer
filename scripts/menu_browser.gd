extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_option_button_2_pressed() -> void:
	Global.openSongMenu.emit()


func _on_option_button_1_pressed() -> void:
	Global.openArtistsMenu.emit()
