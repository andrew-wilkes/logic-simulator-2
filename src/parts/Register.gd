class_name Register

extends Part

var value = 0

func _init():
	order = 80
	category = SYNC


func evaluate_output_level(side, port, level):
	if side == LEFT and port == 2: # clk
		if level:
			var ld = pins.get([side, 1], false)
			if ld:
				value = pins.get([side, 0], 0)
				if show_display:
					$Value.text = get_display_hex_value(value)
				update_output_value(RIGHT, 1, value)
		else:
			update_output_value(RIGHT, OUT, value)


func evaluate_bus_output_value(_side, _port, _value):
	# Only update on clock edge
	pass


func reset():
	super()
	value = 0
	if show_display:
		$Value.text = get_display_hex_value(value)
