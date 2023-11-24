class_name Register

extends Part

var value = 0

func _init():
	order = 80
	category = SYNC
	pins = { [0, 1]: false }


func evaluate_output_level(side, port, level):
	if side == LEFT:
		if port == 2: # clk
			if level:
				if pins[[side, 1]]: # load
					value = pins[[side, 0]]
					$Value.text = "%04X" % [value]
			else:
				update_output_value(RIGHT, 0, value)


func evaluate_bus_output_value(_side, _port, _value):
	pass


func reset():
	value = 0
