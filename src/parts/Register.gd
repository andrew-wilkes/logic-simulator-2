class_name Register

extends Part

var value = 0

func _init():
	order = 80
	category = SYNC
	clock_ports = [2]


func evaluate_output_level(side, port, _level):
	if side == LEFT:
		var ld = pins.get([side, 1], false)
		var clk = pins.get([side, 2], false)
		if clk and ld:
			value = pins.get([side, 0], 0)
			if show_display:
				$Value.text = get_display_hex_value(value)
			update_output_value(RIGHT, 1, value)
		if port == 2 and not clk:
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
