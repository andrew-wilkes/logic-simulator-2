class_name Keyboard

extends Part

var last_text_length = 0
var show_placeholder = false

func _init():
	order = 74
	category = UTILITY


func _ready():
	super()


func _on_chars_text_changed(new_text):
	var length = new_text.length()
	if length > last_text_length:
		# Output the character code of the last key that was typed by the user
		var char_code = new_text.right(1).to_ascii_buffer()[0]
		if DEBUG:
			print(char_code)
		update_output_value(OUT, char_code)
	last_text_length = length


# Emit 0 when key is released
func _unhandled_key_input(event):
	if not event.pressed:
		update_output_value(OUT, 0)


func _on_blink_timer_timeout():
	show_placeholder = !show_placeholder
	if show_placeholder and not $HB/Chars.has_focus():
		$HB/Chars.placeholder_text = ">"
	else:
		$HB/Chars.placeholder_text = ""
