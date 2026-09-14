extends Control

var capture_effect: AudioEffectCapture
var buffer: Array[float] = []
var resolution: int = 300


func _ready() -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	capture_effect = AudioServer.get_bus_effect(bus_index, 0)
	
	for i in range(resolution):
		buffer.append(0.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not capture_effect:
		return
	
	var frames_available = capture_effect.get_frames_available()
	if frames_available > 0:
		var data = capture_effect.get_buffer(frames_available)
		
		var step_size = max(1, data.size() / 25)
		
		for i in range(0, data.size(), step_size):
			buffer.push_back(data[i].x)
			buffer.pop_front()
	
	queue_redraw()

func _draw() -> void:
	var center_y = size.y / 2.0
	var wave_points = PackedVector2Array()
	
	for i in range(resolution):
		var x = (float(i) / resolution) * size.x
		var y = center_y + (buffer[i] * center_y)
		wave_points.append(Vector2(x, y))
	
	draw_polyline(wave_points, Color(1, 1, 1), 1.0, true)
