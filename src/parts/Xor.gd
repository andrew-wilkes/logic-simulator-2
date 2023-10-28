class_name XOR

extends Part

func _init():
	pins = { [0, 0]: false, [0, 1]: false }
	order = 600


func evaluate_output_level(side, _port, level):
	if side == LEFT:
		level = pins[[side, A]] != pins[[side, B]]
		update_output_level(RIGHT, OUT, level)
