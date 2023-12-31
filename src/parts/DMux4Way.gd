class_name DMux4Way

extends Part

func _init():
	order = 90
	category = ASYNC


func evaluate_output_level(side, _port, _level):
	if side == LEFT:
		var sel = 0
		for n in 2:
			sel *= 2
			sel += int(pins.get([side, 2 - n], false))
			update_outputs(sel)


func evaluate_bus_output_value(_side, _port, value):
	update_outputs(value % 4)


func update_outputs(sel):
	var input = pins.get([LEFT, 0], false)
	for n in 4:
		update_output_level(RIGHT, n, input if sel == n else false)
