class_name Add

extends Part

var ab = [0, 0]

func _init():
	order = 80
	category = ASYNC


func evaluate_bus_output_value(side, port, value):
	if side == LEFT:
		ab[port] = value
		update_output_value(RIGHT, 0, ab[0] + ab[1])
