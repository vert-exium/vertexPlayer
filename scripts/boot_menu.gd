extends Node2D


func _ready() -> void:
	$waitTimer.start()


func _process(delta: float) -> void:
	if $loadingBar.value > 99.9:
		Global.doneLoading.emit()
		queue_free()


func _on_wait_timer_timeout() -> void:
	var loadTween = create_tween()
	loadTween.set_trans(Tween.TRANS_CUBIC)
	loadTween.set_ease(Tween.EASE_OUT)
	loadTween.tween_property($loadingBar, "value", 102, 3.0)
