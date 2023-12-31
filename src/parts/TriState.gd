class_name TriState

extends Part

var value = 0

func _init():
	order = 68
	category = UTILITY


func evaluate_output_level(side, _port, _level):
	if side == LEFT:
		propagate_value()


func evaluate_bus_output_value(side, _port, _value):
	if side == LEFT:
		value = _value
		propagate_value()


func propagate_value():
	if pins.get([LEFT, 1], false):
		update_output_value(RIGHT, OUT, value)
	else:
		pins[[RIGHT, OUT]] = -INF


func apply_power():
	pins = { [RIGHT, OUT]: -INF }
