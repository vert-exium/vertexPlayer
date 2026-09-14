extends TextureProgressBar

var bus_index: int


func _ready() -> void:
	bus_index = AudioServer.get_bus_index("Master")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var peak_db = AudioServer.get_bus_peak_volume_left_db(bus_index, 0)
	
	var target_value = db_to_linear(peak_db)
	value = lerpf(value, target_value, 0.1)
