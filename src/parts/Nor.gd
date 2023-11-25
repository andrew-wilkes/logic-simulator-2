class_name NOR

extends Part

func _init():
	reset()
	order = 700


func evaluate_output_level(side, _port, level):
	if side == LEFT:
		level = pins[[side, A]] or pins[[side, B]]
		update_output_level(RIGHT, OUT, not level)


func reset():
	pins = { [0, 0]: false, [0, 1]: false }