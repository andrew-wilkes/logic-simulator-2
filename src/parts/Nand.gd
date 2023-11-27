class_name NAND

extends Part

func _init():
	order = 1000


func evaluate_output_level(side, _port, level):
	if side == LEFT:
		level = not (pins.get([side, A], false) and pins.get([side, B], false))
		update_output_level(RIGHT, OUT, level)
