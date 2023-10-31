class_name BusDisplay

extends Display

enum { HEX, DEC, BIN }

func _init():
	super()
	data["num_digits"] = 2
	data["mode"] = 0
	data["dp_position"] = 0


func _ready():
	set_mode_text()
	for n in data.num_digits - 1:
		add_digit()
	set_dp()
	super()


func set_mode_text():
	%ModeButton.text = ["Hex", "Dec", "Bin"][data.mode]


func _on_mode_button_pressed():
	data.mode = (int(data.mode) + 1) % 3
	set_mode_text()
	changed()


func _on_add_button_pressed():
	add_digit()
	data.num_digits += 1
	changed()


func _on_remove_button_pressed():
	if data.num_digits > 1:
		data.num_digits -= 1
		$HB.get_child(data.num_digits).queue_free()
		changed()


func make_unique(node):
	var mat = node.get_material().duplicate()
	node.set_material(mat)


func add_digit():
	var new_seg = %Segments.duplicate()
	make_unique(new_seg)
	$HB.add_child(new_seg)


func set_dp():
	for idx in data.num_digits:
		var on = true if data.num_digits - idx - 1 == data.dp_position and idx < data.num_digits - 1 else false
		$HB.get_child(idx).material.set_shader_parameter("dp", on)


func evaluate_bus_output_value(_side, port, value):
	var n = int(value)
	if port == 0:
		# Assume that negative numbers are 16 bits
		if n < 0:
			n = 65536 + n
		for idx in data.num_digits:
			var digit
			match int(data.mode):
				HEX:
					digit = n % 0x10
					n /= 0x10
				DEC:
					digit = n % 10
					n /= 10
				BIN:
					digit = n % 2
					n /= 2
			# Display digit
			# Set shader to accept 7 bit pattern
			$HB.get_child(data.num_digits - idx - 1).material.set_shader_parameter("segs", digit)
	if port == 1:
		data.dp_position = n
		set_dp()


func set_digit_colors(color, bg_color):
	for idx in data.num_digits:
		$HB.get_child(idx).material.set_shader_parameter("color", color)
		$HB.get_child(idx).material.set_shader_parameter("bg_color", bg_color)
