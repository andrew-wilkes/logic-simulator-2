extends PopupPanel

signal changed_color(color)

func _on_color_picker_color_changed(color):
	emit_signal("changed_color", color)
