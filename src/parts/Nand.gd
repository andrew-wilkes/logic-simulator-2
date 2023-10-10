class_name NAND

extends Part

func _init():
	pins = { [0, 0]: false, [0, 1]: false }


func evaluate_output_level(side, _port, level):
	if side == LEFT:
		level = not (pins[[side, 0]] and pins[[side, 1]])
		update_output_level(RIGHT, 0, level)
