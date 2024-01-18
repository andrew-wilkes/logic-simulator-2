class_name Bit

extends Part

enum { BIT_LOAD = 1, BIT_CLK }

var state = false

func _init():
	order = 90
	category = SYNC


func evaluate_output_level(port, level):
	if port == BIT_CLK:
		if level and pins.get([LEFT, BIT_LOAD], false):
			state = pins.get([LEFT, IN], false)
		else:
			update_output_level(OUT, state)
