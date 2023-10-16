class_name DMux

extends Part

func _init():
	order = 90
	pins = { [0, 0]: false, [0, 1]: false }
	category = CHIP


func evaluate_output_level(side, _port, _level):
	if side == LEFT:
		var input = pins[[side, 0]]
		var sel = pins[[side, 1]]
		update_output_level(RIGHT, 0, 0 if sel else input)
		update_output_level(RIGHT, 1, input if sel else false)
