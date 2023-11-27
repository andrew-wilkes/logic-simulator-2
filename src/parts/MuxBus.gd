class_name MuxBus

extends Part

func _init():
	order = 84
	category = ASYNC


func evaluate_output_level(side, _port, level):
	if side == LEFT:
		propagate_value(level)


func evaluate_bus_output_value(side, port, _value):
	if side == LEFT:
		var sel = pins.get([side, 2], false)
		if port == B and sel or port == A and not sel:
			propagate_value(sel)


func propagate_value(sel):
	if sel:
		update_output_value(RIGHT, OUT, pins.get([LEFT, B], 0))
	else:
		update_output_value(RIGHT, OUT, pins.get([LEFT, A], 0))
