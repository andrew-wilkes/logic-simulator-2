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
	set_wrap_value()
	%Bits.text = str(data.bits)
	reset()
	


func evaluate_output_level(side, port, level):
	if side == LEFT:
		if port == 4: # clk
			if level:
				if pins[[side, 1]]: # load
					value = pins[[side, 0]]
				elif pins[[side, 2]]: # inc
					value += 1
					# Stop memory address from being exceeded
					if value >= wrap_value:
						value = wrapi(value, 0, wrap_value)
				if pins[[side, 3]]: # reset
					value = 0
				$Value.text = get_display_hex_value(value)
			else:
				update_output_value(RIGHT, OUT, value)


func _on_bits_text_submitted(new_text):
	if new_text.is_valid_int():
		data.bits = clampi(int(new_text), 1, 1024)
		set_wrap_value()
	else:
		%Bits.text = ""


func set_wrap_value():
	wrap_value = int(pow(2, data.bits) - 1) + 1


func reset():
	value = 0
	$Value.text = get_display_hex_value(value)
	pins = { [0, 1]: false, [0, 2]: false, [0, 3]: false, [0, 4]: false }


func evaluate_bus_output_value(_side, _port, _value):
	# Don't let the load value immediately go to the output
	pass
