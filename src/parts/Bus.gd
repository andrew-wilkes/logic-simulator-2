class_name Bus

extends Part

func _init():
	category = UTILITY
	order = 96


func apply_power():
	if not pins.has([RIGHT, OUT]):
		update_output_value(OUT, 0)
