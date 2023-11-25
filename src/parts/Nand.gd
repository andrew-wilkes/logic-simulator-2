class_name NAND

extends Part

func _init():
	reset()
	order = 1000


func evaluate_output_level(side, _port, level):
	if side == LEFT:
		level = not (pins[[side, A]] and pins[[side, B]])
		update_output_level(RIGHT, OUT, level)


func reset():
	pins = { [0, 0]: false, [0, 1]: false }
