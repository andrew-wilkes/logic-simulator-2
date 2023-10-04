extends Part

class_name BusColor

func _init():
	data["color"] = Color.YELLOW


func _ready():
	$ColorRect.color = data.color
	$ColorPicker/M/ColorPicker.color = data.color


func _on_color_picker_changed_color(color):
	data.color = color
	set_slot_color_left(0, color)
	controller.set_pin_colors(name, color)
	$ColorRect.color = color


func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton:
		$ColorPicker.popup_centered()
