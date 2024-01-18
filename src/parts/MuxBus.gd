class_name MuxBus

extends Part

func _init():
	order = 58
	category = ASYNC


func evaluate_output_level(_port, level):
	propagate_value(level)


func evaluate_bus_output_value(port, _value):
	var sel = pins.get([LEFT, 2], false)
	if port == B and sel or port == A and not sel:
		propagate_value(sel)


func propagate_value(sel):
	if sel:
		update_output_value(OUT, pins.get([LEFT, B], 0))
	else:
		update_output_value(OUT, pins.get([LEFT, A], 0))
