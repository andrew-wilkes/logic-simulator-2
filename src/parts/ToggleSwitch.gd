class_name ToggleSwitch

extends Part

var race_counter_reset_counter = 0

func _init():
	category = UTILITY
	order = 0


func output_clock(level):
	race_counter_reset_counter += 1
	if race_counter_reset_counter > 3:
		race_counter_reset_counter = 0
		controller.reset_race_counters()
	update_output_level_with_color(RIGHT, OUT, level)


func _on_button_toggled(button_pressed):
	output_clock(button_pressed)


func apply_power():
	update_output_level_with_color(RIGHT, OUT, false)
