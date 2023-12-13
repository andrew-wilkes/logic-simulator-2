extends CustomPopup

signal step()
signal stop()
signal play()
signal reset()

enum TEST { STEPPABLE, PLAYING, DONE }

func _ready():
	%Alpha.value = G.settings.tester_alpha * 100.0
	%Speed.value = G.settings.tester_speed
	%Notification.hide()
	%ProgressBar.hide()


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


func _on_speed_value_changed(value):
	G.settings.tester_speed = value


func set_button_status(state):
	match state:
		G.TEST_STATUS.STEPPABLE:
			%Step.disabled = false
			%Play.disabled = false
			%Stop.disabled = true
			%Reset.disabled = false
		G.TEST_STATUS.PLAYING:
			%Step.disabled = true
			%Play.disabled = true
			%Stop.disabled = false
			%Reset.disabled = false
		G.TEST_STATUS.DONE:
			%Step.disabled = true
			%Play.disabled = true
			%Stop.disabled = true
			%Reset.disabled = false


func notify(text, display_time = 5.0):
	%Notification.text = text
	%Notification.show()
	await get_tree().create_timer(display_time).timeout
	%Notification.text = ""
	%Notification.hide()


func update_bar(duration):
	%ProgressBar.show()
	%ProgressBar.value = 100.0
	var tween = get_tree().create_tween()
	tween.tween_property(%ProgressBar, "value", 0, duration)
	await tween.finished
	%ProgressBar.hide()
