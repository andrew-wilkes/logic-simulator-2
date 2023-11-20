class_name Toggle

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
	update_output_level(RIGHT, OUT, level)
	indicate_level(RIGHT, 0, level)


func _on_button_toggled(button_pressed):
	output_clock(button_pressed)
