class_name DMux8Way

extends Part

func _init():
	order = 90
	category = ASYNC


func evaluate_output_level(_port, _level):
	var sel = 0
	for n in 3:
		sel *= 2
		sel += int(pins.get([LEFT, 3 - n], false))
		update_outputs(sel)


func evaluate_bus_output_value(__port, value):
	update_outputs(value % 8)


func update_outputs(sel):
	var input = pins.get([LEFT, 0], false)
	for n in 8:
		update_output_level(n, input if sel == n else false)
