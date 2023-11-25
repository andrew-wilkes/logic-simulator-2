class_name XOR

extends Part

func _init():
	reset()
	order = 600


func evaluate_output_level(side, _port, level):
	if side == LEFT:
		level = pins[[side, A]] != pins[[side, B]]
		update_output_level(RIGHT, OUT, level)


func reset():
	pins = { [0, 0]: false, [0, 1]: false }
