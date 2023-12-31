extends MarginContainer

signal low_color_changed()
signal high_color_changed()
signal level_indication_changed()

var setting_low_color = true

func _ready():
	%IndicateFrom.button_pressed = G.settings.indicate_from_levels
	%IndicateTo.button_pressed = G.settings.indicate_to_levels
	%LowColor.color = G.settings.logic_low_color
	%HighColor.color = G.settings.logic_high_color
	$HBox/ColorPicker.color = G.settings.logic_low_color
	%TestDir.text = G.settings.test_dir

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
		emit_signal("low_color_changed")
	else:
		%HighColor.color = color
		G.settings.logic_high_color = color
		emit_signal("high_color_changed")


func _on_indicate_from_pressed():
	G.settings.indicate_from_levels = %IndicateFrom.button_pressed
	emit_signal("level_indication_changed")


func _on_indicate_to_pressed():
	G.settings.indicate_to_levels = %IndicateTo.button_pressed
	emit_signal("level_indication_changed")


func _on_test_dir_button_pressed():
	$DirectoryPicker.current_dir = G.settings.last_dir
	$DirectoryPicker.popup_centered()


func _on_directory_picker_dir_selected(dir):
	%TestDir.text = dir
	G.settings.test_dir = dir
