class_name HalfAdder

extends Part

func _init():
	pins = { [0, 0]: false, [0, 1]: false }
	order = 70
	category = ASYNC


func evaluate_output_level(_port, _level):
	var a = pins.get([LEFT, A], false)
	var b = pins.get([LEFT, B], false)
	update_output_level(0, a != b)
	update_output_level(1, a and b)
