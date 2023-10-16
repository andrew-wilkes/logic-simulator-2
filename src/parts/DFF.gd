class_name DFF

extends Part

var state = false

func _init():
	order = 90
	pins = { [0, 0]: false }
	category = CHIP


func evaluate_output_level(side, port, level):
	if side == LEFT:
		if port == 1: # clk
			if level:
				state = pins[[side, 0]]
			else:
				update_output_level(RIGHT, 0, state)
