class_name MuxBus

extends Part

func _init():
	order = 84
	reset()
	category = ASYNC


func evaluate_output_level(side, _port, level):
	if side == LEFT:
		propagate_value(level)


func evaluate_bus_output_value(side, _port, _value):
	if side == LEFT:
		var sel = pins[[side, 2]]
		if side == B and sel or side == A and not sel:
			propagate_value(sel)


func propagate_value(sel):
	if sel:
		update_output_value(RIGHT, OUT, pins[[LEFT, B]])
	else:
		update_output_value(RIGHT, OUT, pins[[LEFT, A]])


func reset():
	pins = { [0, 0]: 0, [0, 1]: 0, [0, 2]: false }
