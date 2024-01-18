class_name ALU

extends Part

func _init():
	order = 0
	category = ASYNC


func evaluate_output_level(_port, _level):
	update_outputs()


func evaluate_bus_output_value(_port, _value):
	update_outputs()


func update_outputs():
	var result = 0
	# There is no mod of bit depth since connected parts will determine how many bits are used
	var x = pins.get([LEFT, 0], 0)
	var y = pins.get([LEFT, 1], 0)
	if pins.get([LEFT, 2], false): # zx
		x = 0
	if pins.get([LEFT, 3], false): # nx
		x = ~x
	if pins.get([LEFT, 4], false): # zy
		y = 0
	if pins.get([LEFT, 5], false): # ny
		y = ~y
	if pins.get([LEFT, 6], false): # f
		result = x + y
	else:
		result = x & y
	if pins.get([LEFT, 7], false): # no
		result = ~result
	result &= 0xffff
	update_output_value(0, result)
	update_output_level(1, result == 0)
	update_output_level(2, result > 0x7fff)
