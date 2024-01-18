class_name Mux

extends Part

func _init():
	order = 89
	category = ASYNC


func evaluate_output_level(_port, _level):
	var sel = pins.get([LEFT, 2], false)
	update_output_level(OUT, pins.get([B if sel else A], false))
