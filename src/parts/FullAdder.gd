class_name FullAdder

extends Part

func _init():
	order = 68
	category = ASYNC


func evaluate_output_level(_port, _level):
	var sum = int(pins.get([LEFT, A], false))\
		+ int(pins.get([LEFT, B], false))\
		+ int(pins.get([LEFT, C], false))
	update_output_level(0, sum % 2 == 1)
	update_output_level(1, sum > 1)
