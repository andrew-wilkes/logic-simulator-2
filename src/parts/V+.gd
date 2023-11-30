extends Part

class_name Vcc

func _init():
	category = UTILITY
	order = 90


func _ready():
	super()
	set_color()


func apply_power():
	update_output_level(RIGHT, 1, true)
	update_output_value(RIGHT, 0, INF)


func set_color():
	$ColorRect.color = G.settings.logic_high_color
	set_slot_color_right(1, G.settings.logic_high_color)
