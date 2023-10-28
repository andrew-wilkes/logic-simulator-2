class_name DFF

extends Part

var state = false

func _init():
	order = 90
	pins = { [0, 0]: false }
	category = SYNC


func evaluate_output_level(side, port, level):
	if side == LEFT:
		if port == 1: # clk
			if level:
				state = pins[[side, IN]]
			else:
				update_output_level(RIGHT, OUT, state)
