extends LineEdit

signal value_changed(value)

@export_color_no_alpha var default_color = Color.WHITE
@export_color_no_alpha var highlight_color = Color.ORANGE
@export var show_minus = true
@export var shorten_hex = true
@export var clamp_value = 0

var previous_text = ""

func set_text_color(default):
	var color = default_color if default else highlight_color
	set("theme_override_colors/font_color", color)


func _on_text_changed(_new_text):
	set_text_color(false)


func _on_text_submitted(new_text):
	var value = 0
	if new_text.is_valid_int():
		value = int(new_text)
	if new_text.is_valid_hex_number(true):
		value = new_text.hex_to_int()
	elif new_text.begins_with("b"):
		new_text = new_text.right(-1)
		if new_text.is_valid_int():
			for idx in new_text.length():
				value *= 2
				if new_text[idx] == "1":
					value += 1
	set_text_color(true)
	value_changed.emit(value)
	display_value(value, show_minus, shorten_hex)


func display_value(value, show_minus_, shorten_hex_):
	text = G.format_value(value, show_minus_, shorten_hex_, clamp_value)
	# The following line avoids the caret blinking at the start of the text
	caret_column = text.length()


func _on_focus_entered():
	previous_text = text
	text = ""


# Avoid leaving blanks
func _on_focus_exited():
	if text == "":
		text = previous_text
