extends Container

var base_addr = 0
var mem_size = 1024
var num_bits = 16
var mem = []

func _ready():
	mem.resize(1024)
	mem.fill(0x123)
	var list = %SizeList.get_popup()
	var x = 1
	for n in 8:
		list.add_item(str(x) + "K")
		x *= 2
	init_grid()
	set_word_visibility(false)
	update_grid()


func init_grid():
	var addr = %Grid.get_child(0)
	var word = %Grid.get_child(1)
	var chrs = %Grid.get_child(2)
	for row in 16:
		var words = 15
		if row > 0:
			%Grid.add_child(addr.duplicate())
			words = 16
		else:
			%Grid.remove_child(chrs)
		for n in words:
			%Grid.add_child(word.duplicate())
		if row > 0:
			%Grid.add_child(chrs.duplicate())
		else:
			%Grid.add_child(chrs)
		var node_idx = row * 18
		for n in 16:
			var node = %Grid.get_child(node_idx + n + 1)
			node.text_submitted.connect(_on_text_submitted.bind(node, row, n))


func update_grid():
	var num_words =  16
	var format = "%02x"
	var wide = false
	if num_bits == 16:
		format = "%04x"
		wide = true
		num_words = 8
	var idx = 0
	for row in 16:
		var chrs = []
		%Grid.get_child(idx).text = "%04x:" % [base_addr + row * num_words]
		for n in num_words:
			var word = mem[base_addr + row * num_words + n]
			%Grid.get_child(idx + n + 1).text = format % [word]
			%Grid.get_child(idx + n + 1).tooltip_text = int2bin(word)
			if wide:
				chrs.append(get_chr(word / 256))
			chrs.append(get_chr(word % 256))
		idx += 18
		%Grid.get_child(idx - 1).text = "".join(chrs)


func get_chr(n):
	return String.chr(n) if n > 31 or n < 127 else "-"


func set_word_visibility(show_all):
	for row in 16:
		for n in 8:
			%Grid.get_child(row * 18 + 9 + n).visible = show_all
	%Grid.columns = 18 if show_all else 10


func _on_text_submitted(new_text, node, row, col):
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
	if num_bits == 8:
		mem[base_addr + row * 16 + col] = value
	else:
		mem[base_addr + row * 8 + col] = value
	update_grid()
	node.caret_column = node.text.length()


func int2bin(x: int) -> String:
	var b = ""
	for n in num_bits:
		b = str(x % 2) + b
		x /= 2
	return b


func _on_up_button_pressed():
	var step = 0x80 if num_bits == 16 else 0x100
	base_addr = maxi(base_addr - step, 0)
	update_grid()


func _on_down_button_pressed():
	var step = 0x80 if num_bits == 16 else 0x100
	if base_addr + step < mem_size:
		base_addr = base_addr + step
	update_grid()


func _on_width_button_pressed():
	if num_bits == 8:
		num_bits = 16
	else:
		num_bits = 8
	%WidthLabel.text = str(num_bits)


func _on_save_button_pressed():
	pass # Replace with function body.


func _on_erase_button_pressed():
	mem.fill(0)
	update_grid()


func _on_ok_button_pressed():
	hide()
