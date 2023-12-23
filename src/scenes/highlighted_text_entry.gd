extends LineEdit

@export_color_no_alpha var default_color = Color.WHITE
@export_color_no_alpha var highlight_color = Color.ORANGE

func set_text_color(default):
	var color = default_color if default else highlight_color
	set("theme_override_colors/font_color", color)


func _on_text_changed(_new_text):
	set_text_color(false)


func _on_text_submitted(_new_text):
	set_text_color(true)
