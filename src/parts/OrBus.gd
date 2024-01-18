class_name OrBus

extends Part

func _init():
	order = 62
	category = ASYNC


func evaluate_bus_output_value(__port, value):
	update_output_level(OUT, value > 0)
