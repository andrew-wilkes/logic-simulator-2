class_name Inc

extends Part

var max_value = 0

func _init():
	order = 66
	category = ASYNC
	data["bits"] = 16


func _ready():
	super()
	set_max_value()
	%Bits.text = str(data.bits)
	


func evaluate_bus_output_value(side, _port, value):
	if side == LEFT:
		update_output_value(RIGHT, 0, (value + 1) % max_value)


func _on_bits_text_submitted(new_text):
	if new_text.is_valid_int():
		data.bits = clampi(int(new_text), 1, 1024)
		set_max_value()
	else:
		%Bits.text = ""


func set_max_value():
	max_value = int(pow(2, data.bits))
