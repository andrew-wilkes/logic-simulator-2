class_name Bit

extends Part

enum { BIT_LOAD = 1, BIT_CLK }

var state = false

func _init():
	order = 90
	category = SYNC
	clock_ports = [3]


func evaluate_output_level(side, port, level):
	if side == LEFT:
		if port == BIT_CLK:
			if level and pins.get([side, BIT_LOAD], false):
				state = pins.get([side, IN], false)
			else:
				update_output_level(RIGHT, OUT, state)
