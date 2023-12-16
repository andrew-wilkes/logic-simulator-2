class_name Register

extends Part

var value = 0

func _init():
	order = 80
	category = SYNC


func evaluate_output_level(side, port, level):
	if side == LEFT and port == 2:
		if level:
			var ld = pins.get([side, 1], false)
			if ld:
				value = pins.get([side, 0], 0)
				if show_display:
					$Value.text = get_display_hex_value(value)
				update_output_value(RIGHT, 1, value)
		else:
			update_output_value(RIGHT, OUT, value)


func evaluate_bus_output_value(side, _port, _value):
	# Don't let the load value immediately go to the output
	if side == LEFT and pins.get([side, 1], false) and pins.get([side, 2], false):
		value = _value
		update_output_value(RIGHT, 1, value)
		if show_display:
			$Value.text = get_display_hex_value(value)


func reset():
	super()
	value = 0
	if show_display:
		$Value.text = get_display_hex_value(value)
