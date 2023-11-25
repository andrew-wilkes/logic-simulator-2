class_name Wire

extends Part

func _init():
	category = UTILITY
	order = 74


func reset():
	update_output_level(RIGHT, OUT, false)
