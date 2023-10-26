class_name ALU

extends Part

func _init():
	order = 80
	category = ASYNC
	pins = { [0, 0]: 0, [0, 1]: 0 }
	for n in 6:
		pins[[0, n + 2]] = false


func evaluate_output_level(side, _port, _level):
	if side == LEFT:
		update_outputs()


func evaluate_bus_output_value(side, _port, _value):
	if side == LEFT:
		update_outputs()


func update_outputs():
	var result = 0
	# There is no mod of bit depth since connected parts will determine how many bits are used
	var x = pins[[LEFT, 0]]
	var y = pins[[LEFT, 1]]
	if pins[[LEFT, 2]]: # zx
		x = 0
	if pins[[LEFT, 3]]: # nx
		x = ~x
	if pins[[LEFT, 4]]: # zy
		y = 0
	if pins[[LEFT, 5]]: # ny
		y = ~y
	if pins[[LEFT, 6]]: # f
		result = x + y
	else:
		result = x & y
	if pins[[LEFT, 7]]: # no
		result = ~result
	result &= 0xffff
	update_output_value(RIGHT, 0, result)
	update_output_level(RIGHT, 1, result == 0)
	update_output_level(RIGHT, 2, result > 0x0fff)
