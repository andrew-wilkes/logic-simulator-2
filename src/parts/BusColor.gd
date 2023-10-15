extends Part

class_name BusColor

func _init():
	data["color"] = 0xffff00ff
	category = MISC
	order = 70


func _ready():
	super()
	$ColorRect.color = data.color
	$ColorPicker/M/ColorPicker.color = data.color


func _on_color_picker_changed_color(color):
	data.color = color.to_rgba32()
	set_slot_color_left(0, color)
	controller.set_pin_colors(name, color)
	$ColorRect.color = color
	changed()


func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton:
		$ColorPicker.popup_centered()
