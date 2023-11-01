extends Part

class_name Gnd

func _init():
	category = UTILITY
	order = 80


func _ready():
	super()
	set_color()


func reset_race_counter():
	super()
	controller.output_level_changed_handler(self, LEFT, 0, false)
	controller.output_level_changed_handler(self, RIGHT, 0, false)


func set_color():
	$ColorRect.color = G.settings.logic_low_color
	set_slot_color_left(0, G.settings.logic_low_color)
	set_slot_color_right(0, G.settings.logic_low_color)
