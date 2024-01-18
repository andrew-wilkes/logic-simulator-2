class_name XOR

extends Part

func _init():
	order = 600


func evaluate_output_level(_port, level):
	level = pins.get([LEFT, A], false) != pins.get([LEFT, B], false)
	update_output_level(OUT, level)
