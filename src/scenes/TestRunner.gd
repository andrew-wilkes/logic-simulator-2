extends CustomPopup

signal step()
signal stop()
signal play()
signal reset()

func _on_step_pressed():
	emit_signal("step")


func _on_play_pressed():
	emit_signal("play")


func _on_stop_pressed():
	emit_signal("stop")


func _on_reset_pressed():
	emit_signal("reset")
