extends Container

var mem: BaseMemory
var list
var not_opened_yet = true
var base_addresses = {}
var base_addr:
	get:
		if not base_addresses.has(mem):
			base_addresses[mem] = 0
		return base_addresses[mem]
	set(value):
		base_addresses[mem] = value


func _ready():
	list = %SizeList.get_popup()
	var x = 1
	for n in 8:
		list.add_item(str(x) + "K")
		x *= 2
	list.index_pressed.connect(list_item_selected)


func list_item_selected(idx):
	mem.data.size = list.get_item_text(idx)
	mem.update()
	%SizeLabel.text = mem.data.size


func open(_mem: BaseMemory):
	if not_opened_yet:
		not_opened_yet = false
		init_grid()
	mem = _mem
	set_word_visibility(mem.data.bits == 8)
	%SizeLabel.text = mem.data.size
	set_width_text(mem.data.bits)
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
	if mem.data.bits == 16:
		wide = true
		num_words = 8
	var idx = 0
	for row in 16:
		var chrs = []
		%Grid.get_child(idx).text = "%04x:" % [base_addr + row * num_words]
		for n in num_words:
			var word = mem.values[base_addr + row * num_words + n]
			var cell = %Grid.get_child(idx + n + 1)
			cell.clamp_value = 0x100 if mem.data.bits == 8 else 0x10000
			cell.display_value(word, false, not wide)
			cell.tooltip_text = G.int2bin(word, mem.data.bits)
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


func _on_up_button_pressed():
	var step = 0x80 if mem.data.bits == 16 else 0x100
	base_addr = base_addr - step
	if base_addr < 0:
		base_addr = mem.mem_size - step
	update_grid()


func _on_down_button_pressed():
	var step = 0x80 if mem.data.bits == 16 else 0x100
	if base_addr + step < mem.mem_size:
		base_addr = base_addr + step
	else:
		base_addr = 0
	update_grid()


func _on_width_button_pressed():
	if mem.data.bits == 8:
		mem.data.bits = 16
	else:
		mem.data.bits = 8
	set_width_text(mem.data.bits)
	set_word_visibility(mem.data.bits == 8)
	mem.update()
	update_grid()
	get_parent().size.x = 0


func set_width_text(n):
	%WidthLabel.text = str(n) + "bits"


func _on_save_button_pressed():
	$FileDialog.popup_centered()


func _on_erase_button_pressed():
	mem.erase()
	update_grid()


func _on_file_dialog_file_selected(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	var bytes = PackedByteArray()
	bytes.resize(mem.values.size() * 2)
	# Store as 2 bytes per value
	var idx = 0
	for value in mem.values:
		bytes[idx] = value % 256
		idx += 1
		bytes[idx] = value / 256
		idx += 1
	file.store_buffer(bytes)
	G.notify_user("File saved")


func _on_word_value_changed(value, node, row, col):
	if mem.data.bits == 8:
		mem.set_value(base_addr + row * 16 + col, value % 0x100)
	else:
		mem.set_value(base_addr + row * 8 + col, value % 0x10000)
	node.tooltip_text = G.int2bin(value, mem.data.bits)
	mem.update_probes()
