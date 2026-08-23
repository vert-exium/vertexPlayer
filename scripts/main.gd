extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$bootMenu.visible = true
	Global.returnHome.connect(_returnHomeFunction)
	Global.doneLoading.connect(_hideLoading)
	Global.openSongMenu.connect(_showSongMenu)
	Global.openArtistsMenu.connect(_showArtistsMenu)

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

func _hide_all():
	$menuBrowser.visible = false
	$songMenu.visible = false
	$artistsMenu.visible = false
