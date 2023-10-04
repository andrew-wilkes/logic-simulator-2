extends Part

class_name WireColor

func _init():
	data["color"] = Color.WHITE


func _ready():
	$ColorPickerButton.color = data.color


func _on_color_picker_button_color_changed(color):
	data.color = color
	controller.set_pin_colors(name, color)
