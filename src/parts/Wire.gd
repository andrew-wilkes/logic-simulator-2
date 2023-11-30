class_name Wire

extends Part

func _init():
	category = UTILITY
	order = 74


func reset():
	# Set the output pin so that the tester will read it
	update_output_level_with_color(RIGHT, OUT, false)
