class_name DMux

extends Part

func _init():
	order = 90
	category = ASYNC


func evaluate_output_level(_port, _level):
	var input = pins.get([LEFT, IN], false)
	var sel = pins.get([LEFT, 1], false)
	update_output_level(A, false if sel else input)
	update_output_level(B, input if sel else false)
