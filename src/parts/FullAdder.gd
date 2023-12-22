class_name FullAdder

extends Part

func _init():
	order = 68
	category = ASYNC


func evaluate_output_level(side, _port, _level):
	if side == LEFT:
		var sum = int(pins.get([side, A], false))\
			+ int(pins.get([side, B], false))\
			+ int(pins.get([side, C], false))
		update_output_level(RIGHT, 0, sum % 2 == 1)
		update_output_level(RIGHT, 1, sum > 1)
