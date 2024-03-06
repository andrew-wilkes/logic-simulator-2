class_name PC

extends Part

var value = 0
var wrap_value = 0

func _init():
	order = 80
	category = SYNC
	data["bits"] = 16


func _ready():
	super()
	if show_display:
		%Bits.text = str(data.bits)
		display_update_timer = Timer.new()
		get_child(-1).add_child(display_update_timer)
		display_update_timer.timeout.connect(update_display)
		display_update_timer.start(0.1)
	reset()


func evaluate_output_level(port, level):
	if port == 4: # clk edge
		if level:
			if pins.get([LEFT, 3], false): # reset
				value = 0
			elif pins.get([LEFT, 1], false): # load
				value = pins.get([LEFT, 0], 0)
			elif pins.get([LEFT, 2], false): # inc
				value += 1
			set_limited_value()
		else:
			update_output_value(OUT, value)


func _on_bits_text_submitted(new_text):
	if new_text.is_valid_int():
		data.bits = clampi(int(new_text), 1, 1024)
		set_wrap_value()
	elif show_display:
		%Bits.text = ""


func set_wrap_value():
	wrap_value = int(pow(2, data.bits) - 1) + 1


func reset():
	super()
	value = 0


func setup_instance():
	set_wrap_value()


func evaluate_bus_output_value(_port, _value):
	# load and clk
	if pins.get([LEFT, 1], false) and pins.get([LEFT, 4], false):
		value = _value
		set_limited_value()


func set_limited_value():
	# Stop memory address from being exceeded
	if value >= wrap_value:
		value = wrapi(value, 0, wrap_value)


func update_display():
	$Value.text = get_display_hex_value(value)
