extends CustomPopup

signal step()
signal stop()
signal play()
signal reset()

func _ready():
	%Alpha.value = G.settings.tester_alpha * 100.0


func _on_step_pressed():
	emit_signal("step")


func _on_play_pressed():
	emit_signal("play")


func _on_stop_pressed():
	emit_signal("stop")


func _on_reset_pressed():
	emit_signal("reset")


func _on_alpha_value_changed(value):
	var panel = get("theme_override_styles/panel")
	panel.bg_color.a = value / 100.0
	G.settings.tester_alpha = panel.bg_color.a
