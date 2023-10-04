extends Part

class_name BusColor

func _init():
	data["color"] = Color.YELLOW


func _ready():
	$ColorPickerButton.color = data.color


func _on_color_picker_button_color_changed(color):
	data.color = color
	set_slot_color_left(0, color)
	controller.set_pin_colors(name, color)
