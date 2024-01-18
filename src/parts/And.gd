class_name AND

extends Part

func _init():
	order = 800


func evaluate_output_level(_port, level):
	level = pins.get([LEFT, A], false) and pins.get([LEFT, B], false)
	update_output_level(OUT, level)
