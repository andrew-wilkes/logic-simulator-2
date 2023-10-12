extends Part

class_name WireColor

func _init():
	data["color"] = 0xffffffff
	category = MISC
	order = 60


func _ready():
	super()
	$ColorRect.color = Color.hex(data.color)
	$ColorPicker/M/ColorPicker.color = Color.hex(data.color)


func _on_color_picker_changed_color(color):
	data.color = color.to_rgba32()
	set_slot_color_left(0, color)
	controller.set_pin_colors(name, color.to_rgba32())
	$ColorRect.color = color
	changed()


func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			$ColorPicker.popup_centered()
		else:
			controller.set_all_connection_colors()
