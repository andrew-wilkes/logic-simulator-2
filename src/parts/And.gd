class_name AND

extends Part

func _init():
	reset()
	order = 800


func evaluate_output_level(side, _port, level):
	if side == LEFT:
		level = pins.get([side, A], false) and pins.get([side, B], false)
		update_output_level(RIGHT, OUT, level)
