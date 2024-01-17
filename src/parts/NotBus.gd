class_name NotBus

extends Part

func _init():
	order = 60
	category = ASYNC


func evaluate_bus_output_value(__port, value):
	update_output_value(OUT, ~value)
