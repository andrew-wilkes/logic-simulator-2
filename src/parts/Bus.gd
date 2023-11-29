class_name Bus

extends Part

func _init():
	category = UTILITY
	order = 72


func reset():
	pins = { [RIGHT, OUT]: 0 }
