class_name Register

extends Part

var value = 0

func _init():
	order = 80
	category = SYNC


func evaluate_output_level(port, level):
	if port == 2: # clk
		if level:
			var ld = pins.get([LEFT, 1], false)
			if ld:
				value = pins.get([LEFT, 0], 0)
				if show_display:
					$Value.text = get_display_hex_value(value)
				update_output_value(1, value)
		else:
			update_output_value(OUT, value)


func evaluate_bus_output_value(__port, _value):
	# Only update on clock edge
	pass


func reset():
	super()
	value = 0
	if show_display:
		$Value.text = get_display_hex_value(value)
