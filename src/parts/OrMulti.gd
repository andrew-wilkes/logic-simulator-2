class_name OrMulti

extends Part

func _init():
	order = 81
	category = ASYNC
	pins = { [0, 0]: 0, [0, 1]: 0 }


func evaluate_bus_output_value(_port, _value):
	update_output_value(OUT, pins[[LEFT, A]] | pins[[LEFT, B]])
