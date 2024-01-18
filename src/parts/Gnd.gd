extends Part

class_name Gnd

func _init():
	category = UTILITY
	order = 90


func _ready():
	super()
	set_color()


func reset():
	super()
	call_deferred("apply_power")


func apply_power():
	update_output_level(1, false)
	update_output_value(0, 0)


func set_color():
	var color = G.settings.logic_low_color
	$ColorRect.color = color
	set_slot_color_right(1, color)
	return color
