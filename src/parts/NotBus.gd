class_name NotBus

extends Part

func _init():
	order = 60
	category = ASYNC


func evaluate_bus_output_value(_side, _port, value):
	update_output_value(RIGHT, OUT, ~value)
