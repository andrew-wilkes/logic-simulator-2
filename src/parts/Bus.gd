class_name Bus

extends Part

func _init():
	category = UTILITY
	order = 72


func apply_power():
	if not pins.has([RIGHT, OUT]):
		update_output_value(RIGHT, OUT, 0)
