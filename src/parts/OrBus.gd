class_name OrBus

extends Part

func _init():
	order = 80
	category = ASYNC


func evaluate_bus_output_value(_side, _port, value):
	update_output_level(RIGHT, OUT, value > 0)
