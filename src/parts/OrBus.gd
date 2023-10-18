class_name OrBus

extends Part

func _init():
	order = 80
	category = GATE


func evaluate_bus_output_value(side, _port, value):
	if side == LEFT:
		update_output_level(RIGHT, 0, value > 0)
