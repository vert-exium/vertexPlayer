extends TextureRect 

@export var audio_player: AudioStreamPlayer
@onready var knob: TextureRect = $Knob 

var is_dragging: bool = false
var min_y: float = 20.0
var max_y: float = 436.0
var target_y: float = 0.0

func _ready() -> void:
	target_y = knob.position.y

func _process(delta: float) -> void:
	# Fixed: using knob.position.y instead of track's position.y
	knob.position.y = lerpf(knob.position.y, target_y, delta * 15.0)
	
	var volume_normalized = inverse_lerp(max_y, min_y, knob.position.y)
	
	if audio_player:
		var safe_volume = max(volume_normalized, 0.0001)
		audio_player.volume_db = linear_to_db(safe_volume)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if knob.get_rect().has_point(get_local_mouse_position()):
					is_dragging = true
			else:
				is_dragging = false # Fixed: now properly triggers on release
		elif event.pressed:
			var scroll_step = max_y * 0.05
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				target_y = clamp(target_y - scroll_step, min_y, max_y)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				target_y = clamp(target_y + scroll_step, min_y, max_y)

	if event is InputEventMouseMotion and is_dragging:
		target_y = clamp(target_y + event.relative.y, min_y, max_y)
