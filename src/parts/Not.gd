class_name NOT

# This is bi-directional
extends Part

func _init():
	order = 90


func evaluate_output_level(side, _port, level):
	level = not pins[[side, 0]]
	side = (side + 1) % 2
	update_output_level(side, 0, level)
