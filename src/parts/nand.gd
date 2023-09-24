class_name NAND

extends Part

func _init():
	pins = { [0, 1]: false, [0, 2]: false }


func evaluate_output_level(side, _port, level):
	if side == 0:
		level = not (pins[[side, 1]] and pins[[side, 2]])
		# Set output pin level
		if set_pin_value(1, 1, level):
			emit_signal("output_level_changed", self, 1, 1, level)
