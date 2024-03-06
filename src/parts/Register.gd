class_name Register

extends Part

var value = 0

func _init():
	order = 80
	category = SYNC


func _ready():
	super()
	if show_display:
		display_update_timer = Timer.new()
		get_child(-1).add_child(display_update_timer)
		display_update_timer.timeout.connect(update_display)
		display_update_timer.start(0.1)


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


func update_display():
	$Value.text = get_display_hex_value(value)
