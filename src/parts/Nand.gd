class_name NAND

extends Part

func _init():
	order = 1000


func evaluate_output_level(_port, level):
	level = not (pins.get([LEFT, A], false) and pins.get([LEFT, B], false))
	update_output_level(OUT, level)
