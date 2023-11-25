class_name Bus

extends Part

func _init():
	category = UTILITY
	order = 72


func reset():
	update_output_value(RIGHT, OUT, 0)
