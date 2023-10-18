class_name NotBus

extends Part

func _init():
	order = 80
	category = GATE


func evaluate_bus_output_value(side, _port, value):
	if side == LEFT:
		update_output_value(RIGHT, 0, ~value)
