class_name PC

extends Part

var value = 0
var max_value = 0

func _init():
	order = 80
	category = SYNC
	data["bits"] = 16


func _ready():
	super()
	set_max_value()
	%Bits.text = str(data.bits)


func evaluate_output_level(side, port, level):
	if side == LEFT:
		if port == 4: # clk
			if level:
				if pins[[side, 1]]: # load
					value = clampi(pins[[side, 0]], 0, max_value)
				elif pins[[side, 2]]: # inc
					value = clampi(value + 1, 0, max_value)
				elif pins[[side, 3]]: # reset
					value = 0
				$Value.text = "%02X" % [value]
			else:
				update_output_value(RIGHT, 0, value)


func _on_bits_text_submitted(new_text):
	if new_text.is_valid_int():
		data.bits = clampi(int(new_text), 1, 1024)
		set_max_value()
	else:
		%Bits.text = ""


func set_max_value():
	max_value = int(pow(2, data.bits) - 1)
