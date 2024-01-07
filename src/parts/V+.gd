extends Part

class_name Vcc

func _init():
	category = UTILITY
	order = 92


func _ready():
	super()
	set_color()
	apply_power()


func apply_power():
	update_output_level(RIGHT, 1, true)
	update_output_value(RIGHT, 0, 0xffff)


func set_color():
	var color = G.settings.logic_high_color
	$ColorRect.color = color
	set_slot_color_right(1, color)
	return color
