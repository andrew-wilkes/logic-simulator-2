class_name DFF

extends Part

var state = false

func _init():
	order = 90
	category = SYNC
	clock_ports = [1]


func evaluate_output_level(side, port, level):
	if side == LEFT:
		if port == 1: # clk
			if level:
				state = pins.get([side, IN], false)
			else:
				update_output_level(RIGHT, OUT, state)
