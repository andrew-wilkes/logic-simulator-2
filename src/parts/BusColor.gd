extends Part

class_name BusColor

func _init():
	data["color"] = "ffff00ff"
	category = UTILITY
	order = 28


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
		$ColorPicker.popup_centered()
