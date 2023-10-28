class_name Bit

extends Part

enum { BIT_LOAD = 1, BIT_CLK }

var state = false

func _init():
	order = 90
	pins = { [0, 0]: false, [0, 1]: false }
	category = SYNC


func evaluate_output_level(side, port, level):
	if side == LEFT:
		if port == BIT_CLK:
			if level and pins[[side, BIT_LOAD]]:
				state = pins[[side, IN]]
			else:
				update_output_level(RIGHT, OUT, state)
