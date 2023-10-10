extends Part

class_name Gnd

func _init():
	category = MISC
	order = 60


func _ready():
	super()
	set_color()


func reset_race_counter():
	super()
	update_output_level(LEFT, 0, false)
	update_output_level(RIGHT, 0, false)


func set_color():
	$ColorRect.color = G.settings.logic_low_color
	set_slot_color_left(0, G.settings.logic_low_color)
	set_slot_color_right(0, G.settings.logic_low_color)
