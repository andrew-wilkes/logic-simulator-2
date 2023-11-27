class_name NOR

extends Part

func _init():
	order = 700


func evaluate_output_level(side, _port, level):
	if side == LEFT:
		level = pins.get([side, A], false) or pins.get([side, B], false)
		update_output_level(RIGHT, OUT, not level)
