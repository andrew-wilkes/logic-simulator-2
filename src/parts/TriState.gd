class_name TriState

extends Part

var value = 0

func _init():
	order = 68
	category = UTILITY


func evaluate_output_level(_port, _level):
	propagate_value()


func evaluate_bus_output_value(_port, _value):
	value = _value
	propagate_value()


func propagate_value():
	if pins.get([LEFT, 1], false):
		update_output_value(OUT, value)
	else:
		pins[[RIGHT, OUT]] = -INF


func apply_power():
	pins = { [RIGHT, OUT]: -INF }
