class_name NotMulti

extends Part

func _init():
	order = 83
	category = ASYNC


func evaluate_bus_output_value(side, _port, value):
	if side == LEFT:
		update_output_value(RIGHT, OUT, ~value)
