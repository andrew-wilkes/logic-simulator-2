class_name Add

extends Part

var ab = [0, 0]

func _init():
	order = 64
	category = ASYNC


func evaluate_bus_output_value(port, value):
	ab[port] = value
	update_output_value(OUT, ab[A] + ab[B])
