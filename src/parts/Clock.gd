class_name Clock

extends Part

var fps = 0
var tick = false
var race_counter_reset_counter = 0

func _init():
	category = UTILITY
	order = 0


func _on_rate_value_changed(value):
	fps = value
	if fps > 0.5:
		$Timer.start(1 / fps)


func _on_timer_timeout():
	tick = not tick
	output_clock(tick)
	if fps > 0.5:
		$Timer.start(1 / fps)


func _on_pulse_button_button_down():
	output_clock(true)


func _on_pulse_button_button_up():
	output_clock(false)


func _on_reset_button_button_down():
	update_output_level(RIGHT, 1, true)
	indicate_level(RIGHT, 1, true)


func _on_reset_button_button_up():
	update_output_level(RIGHT, 1, false)
	indicate_level(RIGHT, 1, false)


func output_clock(level):
	race_counter_reset_counter += 1
	if race_counter_reset_counter > 3:
		race_counter_reset_counter = 0
		controller.reset_race_counters()
	update_output_level(RIGHT, OUT, level)
	indicate_level(RIGHT, OUT, level)
