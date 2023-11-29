extends Part

class_name Gnd

func _init():
	category = UTILITY
	order = 80


func _ready():
	super()
	set_color()


func reset():
	super()
	call_deferred("apply_power")


func apply_power():
	controller.bus_value_changed_handler(self, LEFT, 0, 0)
	controller.bus_value_changed_handler(self, RIGHT, 0, 0)
	controller.output_level_changed_handler(self, LEFT, 1, false)
	controller.output_level_changed_handler(self, RIGHT, 1, false)


func set_color():
	$ColorRect.color = G.settings.logic_low_color
	set_slot_color_left(1, G.settings.logic_low_color)
	set_slot_color_right(1, G.settings.logic_low_color)
