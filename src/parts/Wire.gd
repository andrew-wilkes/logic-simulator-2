class_name Wire

extends Part

func _init():
	category = UTILITY
	order = 74


func reset():
	pins = { [RIGHT, OUT]: false }
