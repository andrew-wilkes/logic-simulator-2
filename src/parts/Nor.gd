class_name NOR

extends Part

func _init():
	order = 700


func evaluate_output_level(_port, level):
	level = pins.get([LEFT, A], false) or pins.get([LEFT, B], false)
	update_output_level(OUT, not level)
