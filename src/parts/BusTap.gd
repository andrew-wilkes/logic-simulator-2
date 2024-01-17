class_name BusTap

extends Part

var last_bit_value = -1
var bit_mask = 0

func _init():
	category = UTILITY
	order = 94
	data["bit"] = 0


func _ready():
	super()
	%Bit.set_value_no_signal(data.bit)
	set_bit_mask()


func setup_instance():
	set_bit_mask()


func evaluate_bus_output_value(_port, value):
	var bit = value & bit_mask
	if bit != last_bit_value:
		last_bit_value = bit
		update_output_level(0, bool(bit))


func _on_bit_value_changed(value):
	data.bit = int(value)
	set_bit_mask()
	changed()


func set_bit_mask():
	bit_mask = int(pow(2, data.bit))


func reset():
	super()
	last_bit_value = -1
