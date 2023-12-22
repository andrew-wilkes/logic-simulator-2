extends Part

class_name WireColor

func _init():
	data["color"] = "ffffffff"
	category = UTILITY
	order = 30


func _ready():
	super()
	$ColorRect.color = data.color
	$ColorPicker/M/ColorPicker.color = data.color


func _on_color_picker_changed_color(color):
	data.color = color
	set_slot_color_left(0, color)
	controller.set_pin_colors(name, color)
	$ColorRect.color = color
	changed()


func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			$ColorPicker.popup_centered()
		else:
			controller.set_all_connection_colors()
