class_name Keyboard

extends Part

var last_text_length = 0

func _init():
	order = 0
	category = UTILITY


func _on_chars_text_changed(new_text):
	var length = new_text.length()
	if length > last_text_length:
		# Output the character code of the last key that was typed by the user
		var char_code = new_text.right(1).to_ascii_buffer()[0]
		if DEBUG:
			print(char_code)
		update_output_value(RIGHT, 0, char_code)
	last_text_length = length
