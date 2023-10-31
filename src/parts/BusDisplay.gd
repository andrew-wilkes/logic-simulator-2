class_name BusDisplay

extends Display

enum { HEX, DEC, BIN, MAP }

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
	%ModeButton.text = ["Hex", "Dec", "Bin", "Map"][data.mode]


func _on_mode_button_pressed():
	data.mode = (int(data.mode) + 1) % 4
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
		# Shrink the width of the node after the digit was removed
		await get_tree().create_timer(0.1).timeout
		size.x = 0


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
				MAP:
					digit = n % 0x100
					n /= 0x100
			# Display digit
			# Set shader to accept 7 bit pattern
			$HB.get_child(data.num_digits - idx - 1).material.set_shader_parameter("segs", get_code(digit))
	if port == 1:
		data.dp_position = n
		set_dp()


func set_digit_colors(color, bg_color):
	for idx in data.num_digits:
		$HB.get_child(idx).material.set_shader_parameter("color", color)
		$HB.get_child(idx).material.set_shader_parameter("bg_color", bg_color)


func get_code(n):
	var codes = [
		0x00, # (space)
		0x86, # !
		0x22, # "
		0x7E, # #
		0x6D, # $
		0xD2, # %
		0x46, # &
		0x20, # '
		0x29, # (
		0x0B, # )
		0x21, # *
		0x70, # +
		0x10, # ,
		0x40, # -
		0x80, # .
		0x52, # /
		0x3F, # 0
		0x06, # 1
		0x5B, # 2
		0x4F, # 3
		0x66, # 4
		0x6D, # 5
		0x7D, # 6
		0x07, # 7
		0x7F, # 8
		0x6F, # 9
		0x09, # :
		0x0D, # ;
		0x61, # <
		0x48, # =
		0x43, # >
		0xD3, # ?
		0x5F, # @
		0x77, # A
		0x7C, # B
		0x39, # C
		0x5E, # D
		0x79, # E
		0x71, # F
		0x3D, # G
		0x76, # H
		0x30, # I
		0x1E, # J
		0x75, # K
		0x38, # L
		0x15, # M
		0x37, # N
		0x3F, # O
		0x73, # P
		0x6B, # Q
		0x33, # R
		0x6D, # S
		0x78, # T
		0x3E, # U
		0x3E, # V
		0x2A, # W
		0x76, # X
		0x6E, # Y
		0x5B, # Z
		0x39, # [
		0x64, # \
		0x0F, # ]
		0x23, # ^
		0x08, # _
		0x02, # `
		0x5F, # a
		0x7C, # b
		0x58, # c
		0x5E, # d
		0x7B, # e
		0x71, # f
		0x6F, # g
		0x74, # h
		0x10, # i
		0x0C, # j
		0x75, # k
		0x30, # l
		0x14, # m
		0x54, # n
		0x5C, # o
		0x73, # p
		0x67, # q
		0x50, # r
		0x6D, # s
		0x78, # t
		0x1C, # u
		0x1C, # v
		0x14, # w
		0x76, # x
		0x6E, # y
		0x5B, # z
		0x46, # {
		0x30, # |
		0x70, # }
		0x01, # ~
		0x00, # (del)
	]
	
	if data.mode > 2:
		if n < 32 or n > 95:
			return codes[0]
		else:
			return codes[n - 32]
	if n < 10:
		return codes[16 + n]
	if n < 16:
		return codes[23 + n]
