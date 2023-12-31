class_name HalfAdder

extends Part

func _init():
	pins = { [0, 0]: false, [0, 1]: false }
	order = 70
	category = ASYNC


func evaluate_output_level(side, _port, _level):
	if side == LEFT:
		var a = pins.get([side, A], false)
		var b = pins.get([side, B], false)
		update_output_level(RIGHT, 0, a != b)
		update_output_level(RIGHT, 1, a and b)
