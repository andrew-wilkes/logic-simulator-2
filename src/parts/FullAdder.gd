class_name FullAdder

extends Part

func _init():
	pins = { [0, 0]: false, [0, 1]: false, [0, 2]: false }
	order = 80
	category = ASYNC


func evaluate_output_level(side, _port, _level):
	if side == LEFT:
		var sum = int(pins[[side, 0]]) + int(pins[[side, 1]]) + int(pins[[side, 2]])
		update_output_level(RIGHT, 0, sum % 2 == 1)
		update_output_level(RIGHT, 1, sum > 1)
