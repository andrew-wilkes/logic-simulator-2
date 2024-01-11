class_name Mux

extends Part

func _init():
	order = 89
	category = ASYNC


func evaluate_output_level(side, _port, _level):
	if side == LEFT:
		var sel = pins.get([side, 2], false)
		update_output_level(RIGHT, OUT, pins.get([side, B if sel else A], false))
