class_name Bit

extends Part

var state = false

func _init():
	order = 90
	pins = { [0, 0]: false, [0, 1]: false }
	category = CHIP


func evaluate_output_level(side, port, level):
	if side == LEFT:
		if port == 2: # clk
			if level and pins[[side, 1]]: # load
				state = pins[[side, 0]]
			else:
				update_output_level(RIGHT, 0, state)
