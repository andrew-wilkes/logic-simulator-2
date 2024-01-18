class_name NOT

# This is bi-directional
extends Part

func _init():
	order = 900


func evaluate_output_level(_port, level):
	update_output_level(OUT, not level)
