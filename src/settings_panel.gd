extends MarginContainer

var setting_low_color = true

func _ready():
	%IndicateFrom.button_pressed = G.settings.indicate_from_levels
	%IndicateTo.button_pressed = G.settings.indicate_to_levels
	%LowColor.color = G.settings.logic_low_color
	%HighColor.color = G.settings.logic_high_color


func _on_low_color_gui_input(event):
	if event is InputEventMouseButton:
		setting_low_color = true
		$HBox/ColorPicker.color = G.settings.logic_low_color


func _on_high_color_gui_input(event):
	if event is InputEventMouseButton:
		setting_low_color = false
		$HBox/ColorPicker.color = G.settings.logic_high_color


func _on_color_picker_color_changed(color):
	if setting_low_color:
		%LowColor.color = color
		G.settings.logic_low_color = color
	else:
		%HighColor.color = color
		G.settings.logic_high_color = color
