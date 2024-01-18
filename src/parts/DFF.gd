class_name DFF

extends Part

var state = false

func _init():
	order = 90
	category = SYNC


func evaluate_output_level(port, level):
	if port == 1: # clk
		if level:
			state = pins.get([LEFT, IN], false)
		else:
			update_output_level(OUT, state)
