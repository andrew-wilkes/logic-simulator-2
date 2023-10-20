class_name DMux8Way

extends Part

func _init():
	order = 90
	pins = { [0, 0]: false, [0, 1]: false, [0, 2]: false, [0, 3]: false }
	category = ASYNC


func evaluate_output_level(side, _port, _level):
	if side == LEFT:
		var sel = 0
		for n in 3:
			sel *= 2
			sel += int(pins[[side, n + 1]])
			update_outputs(sel)


func evaluate_bus_output_value(_side, _port, value):
	update_outputs(value % 8)


func update_outputs(sel):
	var input = pins[[LEFT, 0]]
	for n in 8:
		update_output_level(RIGHT, n, input if sel == n else false)
