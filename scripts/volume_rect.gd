extends TextureRect

var normal_tex = preload("res://assets/buttons/volume/normal.png")
var hovered_tex = preload("res://assets/buttons/volume/hovered.png")
@export var audio_player: AudioStreamPlayer

var min_deg: float = -270.0
var max_deg: float = 30.0
var is_dragging: bool = false


func _ready() -> void:
	texture = normal_tex
	rotation_degrees = max_deg
	
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)

func _has_point(point: Vector2) -> bool:
	var center = size / 2.0
	var radius = min (size.x, size.y) / 2.0
	return point.distance_to(center) <= radius

func _on_hover() -> void:
	if not is_dragging:
		texture = hovered_tex

func _on_unhover() -> void:
	if not is_dragging:
		texture = normal_tex

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			texture = hovered_tex
		else:
			is_dragging = false
			if _has_point(get_local_mouse_position()):
				texture = hovered_tex
			else:
				texture = normal_tex

	if event is InputEventMouseMotion and is_dragging:
		var drag_amount = event.relative.x - event.relative.y
		var sensitivity = 1.5
		
		var new_rotation = rotation_degrees + (drag_amount * sensitivity)
		rotation_degrees = clamp(new_rotation, min_deg, max_deg)

	var volume_normalized = inverse_lerp(min_deg, max_deg, rotation_degrees)
	
	if audio_player:
		var safe_volume = max(volume_normalized, 0.0001)
		audio_player.volume_db = linear_to_db(safe_volume)
