extends Part

class_name Vcc

func _init():
	category = UTILITY
	order = 90


func _ready():
	super()
	set_color()


func reset_race_counter():
	super()
	controller.output_level_changed_handler(self, LEFT, 0, true)
	controller.output_level_changed_handler(self, RIGHT, 0, true)


func set_color():
	$ColorRect.color = G.settings.logic_high_color
	set_slot_color_left(0, G.settings.logic_high_color)
	set_slot_color_right(0, G.settings.logic_high_color)
