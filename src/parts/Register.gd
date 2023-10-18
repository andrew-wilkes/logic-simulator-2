class_name Register

extends Part

var value = 0

func _init():
	order = 80
	category = SYNC


func evaluate_output_level(side, port, level):
	if side == LEFT:
		if port == 2: # clk
			if level and pins[[side, 1]]: # load
				value = pins[[side, 0]]
				$Value.text = "%02X" % [value]
			else:
				update_output_value(RIGHT, 0, value)
