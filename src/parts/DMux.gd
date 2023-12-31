class_name DMux

extends Part

func _init():
	order = 90
	category = ASYNC


func evaluate_output_level(side, _port, _level):
	if side == LEFT:
		var input = pins.get([side, IN], false)
		var sel = pins.get([side, 1], false)
		update_output_level(RIGHT, A, false if sel else input)
		update_output_level(RIGHT, B, input if sel else false)
