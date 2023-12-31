class_name OrMulti

extends Part

func _init():
	order = 81
	category = ASYNC
	pins = { [0, 0]: 0, [0, 1]: 0 }


func evaluate_bus_output_value(side, _port, _value):
	if side == LEFT:
		update_output_value(RIGHT, OUT, pins[[LEFT, A]] | pins[[LEFT, B]])
