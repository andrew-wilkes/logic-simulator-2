class_name NotMulti

extends Part

func _init():
	order = 83
	category = ASYNC


func evaluate_bus_output_value(_port, value):
	update_output_value(OUT, ~value)
