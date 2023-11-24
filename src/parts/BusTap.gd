class_name BusTap

extends Part

var last_bit_value = 0
var bit_mask = 0

func _init():
	category = UTILITY
	order = 72
	data["bit"] = 0


func _ready():
	super()
	set_bit_mask()
	%Bit.value = data.bit


func evaluate_bus_output_value(side, _port, value):
	if side == LEFT:
		var bit = value & bit_mask
		if bit != last_bit_value:
			last_bit_value = bit
			update_output_level(RIGHT, 0, bool(bit))


func _on_bit_value_changed(value):
	data.bit = int(value)
	set_bit_mask()


func set_bit_mask():
	bit_mask = int(pow(2, data.bit))
