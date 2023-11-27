class_name XOR

extends Part

func _init():
	order = 600


func evaluate_output_level(side, _port, level):
	if side == LEFT:
		level = pins.get([side, A], false) != pins.get([side, B], false)
		update_output_level(RIGHT, OUT, level)
