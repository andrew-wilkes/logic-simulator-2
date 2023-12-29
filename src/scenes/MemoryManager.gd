extends Container

var ram: RAM
var list
var not_opened_yet = true
var base_addresses = {}
var base_addr:
	get:
		if not base_addresses.has(ram):
			base_addresses[ram] = 0
		return base_addresses[ram]
	set(value):
		base_addresses[ram] = value


func _ready():
	list = %SizeList.get_popup()
	var x = 1
	for n in 8:
		list.add_item(str(x) + "K")
		x *= 2
	list.index_pressed.connect(list_item_selected)


func list_item_selected(idx):
	ram.data.size = list.get_item_text(idx)
	ram.update()
	%SizeLabel.text = ram.data.size


func open(_ram: RAM):
	if not_opened_yet:
		not_opened_yet = false
		init_grid()
	ram = _ram
	set_word_visibility(ram.data.bits == 8)
	%SizeLabel.text = ram.data.size
	set_width_text(ram.data.bits)
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
			node.value_changed.connect(_on_word_value_changed.bind(node, row, n))


func update_grid():
	var num_words =  16
	var wide = false
	if ram.data.bits == 16:
		wide = true
		num_words = 8
	var idx = 0
	for row in 16:
		var chrs = []
		%Grid.get_child(idx).text = "%04x:" % [base_addr + row * num_words]
		for n in num_words:
			var word = ram.values[base_addr + row * num_words + n]
			var cell = %Grid.get_child(idx + n + 1)
			cell.clamp_value = 0x100 if ram.data.bits == 8 else 0x10000
			cell.display_value(word, false, not wide)
			cell.tooltip_text = int2bin(word)
			chrs.append(get_chr(word % 256))
			if wide:
				chrs.append(get_chr(word / 256))
		idx += 18
		%Grid.get_child(idx - 1).text = "".join(chrs)


func get_chr(n):
	return String.chr(n) if n > 31 and n < 127 else "-"


func set_word_visibility(show_all):
	for row in 16:
		for n in 8:
			%Grid.get_child(row * 18 + 9 + n).visible = show_all
	%Grid.columns = 18 if show_all else 10


func int2bin(x: int) -> String:
	var b = ""
	for n in ram.data.bits:
		b = str(x % 2) + b
		x /= 2
	return b


func _on_up_button_pressed():
	var step = 0x80 if ram.data.bits == 16 else 0x100
	base_addr = base_addr - step
	if base_addr < 0:
		base_addr = ram.mem_size - step
	update_grid()


func _on_down_button_pressed():
	var step = 0x80 if ram.data.bits == 16 else 0x100
	if base_addr + step < ram.mem_size:
		base_addr = base_addr + step
	else:
		base_addr = 0
	update_grid()


func _on_width_button_pressed():
	if ram.data.bits == 8:
		ram.data.bits = 16
	else:
		ram.data.bits = 8
	set_width_text(ram.data.bits)
	set_word_visibility(ram.data.bits == 8)
	ram.update()
	update_grid()
	get_parent().size.x = 0


func set_width_text(n):
	%WidthLabel.text = str(n) + "bits"


func _on_save_button_pressed():
	$FileDialog.popup_centered()


func _on_erase_button_pressed():
	ram.erase()
	update_grid()


func _on_file_dialog_file_selected(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(ram.values)
	G.notify_user("File saved")


func _on_word_value_changed(value, node, row, col):
	if ram.data.bits == 8:
		ram.set_value(base_addr + row * 16 + col, value % 0x100)
	else:
		ram.set_value(base_addr + row * 8 + col, value % 0x10000)
	node.tooltip_text = int2bin(value)
	ram.update_probes()
