class_name HalfAdder

extends Part

func _init():
	pins = { [0, 0]: false, [0, 1]: false }
	order = 80
	category = ASYNC


func evaluate_output_level(side, _port, _level):
	if side == LEFT:
		update_output_level(RIGHT, 0, pins[[side, A]] != pins[[side, B]])
		update_output_level(RIGHT, 1, pins[[side, A]] and pins[[side, B]])
