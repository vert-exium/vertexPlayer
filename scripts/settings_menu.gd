extends Node2D

@onready var hue_slider = $Control/scrollContainer/verticalBoxCont/colorPanel/hueSlider
@onready var sat_slider = $Control/scrollContainer/verticalBoxCont/colorPanel/saturationSlider
@onready var val_slider = $Control/scrollContainer/verticalBoxCont/colorPanel/valueSlider

@onready var hue_preview = $Control/scrollContainer/verticalBoxCont/colorPanel/huePreview
@onready var sat_preview = $Control/scrollContainer/verticalBoxCont/colorPanel/saturationPreview
@onready var val_preview = $Control/scrollContainer/verticalBoxCont/colorPanel/valuePreview

var hue_grad_texture := GradientTexture1D.new()
var sat_grad_texture := GradientTexture1D.new()
var val_grad_texture := GradientTexture1D.new()

var hue_grad := Gradient.new()
var sat_grad := Gradient.new()
var val_grad := Gradient.new()

var hue: float = 24.0 / 359.0
var saturation: float = 73.0 / 100.0
var value: float = 98.0 / 100.0

var is_setup_done = false

func _ready() -> void:
	Global.hue = 24.0 / 359.0
	Global.saturation = 73.0 / 100.0
	Global.value = 98.0 / 100.0
	
	hue_slider.set_value_no_signal(Global.hue)
	sat_slider.set_value_no_signal(Global.saturation)
	val_slider.set_value_no_signal(Global.value)
	
	hue_grad_texture.gradient = hue_grad
	sat_grad_texture.gradient = sat_grad
	val_grad_texture.gradient = val_grad
	
	hue_preview.texture = hue_grad_texture
	sat_preview.texture = sat_grad_texture
	val_preview.texture = val_grad_texture
	
	hue_slider.value_changed.connect(_on_hsv_changed)
	sat_slider.value_changed.connect(_on_hsv_changed)
	val_slider.value_changed.connect(_on_hsv_changed)
	
	is_setup_done = true
	_on_hsv_changed(0.0)

func _on_hsv_changed(_dummy: float) -> void:
	if not is_setup_done:
		return
		
	Global.hue = hue_slider.value
	Global.saturation = sat_slider.value
	Global.value = val_slider.value
	
	$Control/scrollContainer/verticalBoxCont/colorPanel/hueValLabel.text = str(roundi(Global.hue * 359.0))
	$Control/scrollContainer/verticalBoxCont/colorPanel/satValLabel.text = str(roundi(Global.saturation * 100.0)) + "%"
	$Control/scrollContainer/verticalBoxCont/colorPanel/valValLabel.text = str(roundi(Global.value * 100.0)) + "%"
	
	_update_hue_gradient(Global.saturation, Global.value)
	_update_sat_gradient(Global.hue, Global.value)
	_update_val_gradient(Global.hue, Global.saturation)
	
	Global.colorChanged.emit()

func _update_hue_gradient(s: float, v: float) -> void:
	var steps = 6
	var new_offsets = PackedFloat32Array()
	var new_colors = PackedColorArray()
	
	for i in range(steps + 1):
		var t = float(i) / float(steps)
		new_offsets.append(t)
		new_colors.append(Color.from_hsv(t, s, v))
		
	hue_grad.offsets = new_offsets
	hue_grad.colors = new_colors

func _update_sat_gradient(h: float, v: float) -> void:
	sat_grad.offsets = PackedFloat32Array([0.0, 1.0])
	sat_grad.colors = PackedColorArray([Color.from_hsv(h, 0.0, v), Color.from_hsv(h, 1.0, v)])

func _update_val_gradient(h: float, s: float) -> void:
	val_grad.offsets = PackedFloat32Array([0.0, 1.0])
	val_grad.colors = PackedColorArray([Color.from_hsv(h, s, 0.0), Color.from_hsv(h, s, 1.0)])
