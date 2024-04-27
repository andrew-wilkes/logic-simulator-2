class_name Keyboard

extends Part

var last_text_length = 0
var show_placeholder = false
var value_output: CircuitInput

func _init():
	order = 74
	category = UTILITY


func _ready():
	super()


func setup():
	value_output = CircuitInput.new()
	value_output.part = self
	value_output.port = OUT
	value_output.is_bus = true


func _on_chars_text_changed(new_text):
	var length = new_text.length()
	if length > last_text_length:
		# Output the character code of the last key that was typed by the user
		var char_code = new_text.right(1).to_ascii_buffer()[0]
		if DEBUG:
			print(char_code)
		value_output.value = char_code
		controller.inject_circuit_input(value_output)
	last_text_length = length


func _on_blink_timer_timeout():
	show_placeholder = !show_placeholder
	if show_placeholder and not $HB/Chars.has_focus():
		$HB/Chars.placeholder_text = ">"
	else:
		$HB/Chars.placeholder_text = ""


func _on_tree_exiting():
	value_output.free()


func _on_chars_gui_input(event):
	if event is InputEventKey:
		var keycode = event.keycode
		if event.pressed:
			match keycode:
				KEY_ENTER:
					keycode = 128
				KEY_BACKSPACE:
					keycode = 129
				KEY_LEFT:
					keycode = 130
				KEY_UP:
					keycode = 131
				KEY_RIGHT:
					keycode = 132
				KEY_DOWN:
					keycode = 133
				KEY_HOME:
					keycode = 134
				KEY_END:
					keycode = 135
				KEY_PAGEUP:
					keycode = 136
				KEY_PAGEDOWN:
					keycode = 137
				KEY_INSERT:
					keycode = 138
				KEY_DELETE:
					keycode = 139
				KEY_ESCAPE:
					keycode = 140
				KEY_F1:
					keycode = 141
				KEY_F2:
					keycode = 142
				KEY_F3:
					keycode = 143
				KEY_F4:
					keycode = 144
				KEY_F5:
					keycode = 145
				KEY_F6:
					keycode = 146
				KEY_F7:
					keycode = 147
				KEY_F8: # Closes the program on Linux
					keycode = 148
				KEY_F9:
					keycode = 149
				KEY_F10:
					keycode = 150
				KEY_F11:
					keycode = 151
				KEY_F12:
					keycode = 152
		else:
			keycode = 0
			%Chars.text = ""
		value_output.value = keycode
		controller.inject_circuit_input(value_output)
