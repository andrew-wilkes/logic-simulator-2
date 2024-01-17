class_name Wire

extends Part

func _init():
	category = UTILITY
	order = 98


func apply_power():
	# Set the output pin if it is null so that the tester will read it
	if not pins.has([RIGHT, OUT]):
		update_output_level_with_color(OUT, false)
