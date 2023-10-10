extends Control

signal part_selected(part_name)
signal block_selected(file_name)

func _ready():
	var lists = []
	lists.resize($HB.get_child_count() - 1)
	for idx in lists.size():
		lists[idx] = []
	for part_name in Parts.names:
		var part = Parts.get_instance(part_name)
		lists[part.category].append([part.order, part_name])
		part.free()
	for list in lists:
		list.sort_custom(func(a, b): return a[0] > b[0])
	for idx in lists.size():
		var item_list = $HB.get_child(idx).get_child(1)
		for item in lists[idx]:
			item_list.add_item(item[1]) # Add part name
	update_block_list()
	for idx in $HB.get_child_count():
		$HB.get_child(idx).get_child(1).item_clicked.connect(_on_list_item_clicked.bind(idx))


func update_block_list():
	var list = $HB.get_child(Part.BLOCK).get_child(1)
	var listed_blocks = []
	for idx in list.item_count:
		listed_blocks.append(list.get_item_text(idx))
	for block_title in G.settings.blocks:
		if not listed_blocks.has(block_title):
			list.add_item(block_title)


func _on_list_item_clicked(index, _at_position, mouse_button_index, column_index):
	get_parent().hide()
	var list = $HB.get_child(column_index).get_child(1)
	list.deselect(index)
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		if column_index == Part.BLOCK:
			emit_signal("block_selected", G.settings.blocks[list.get_item_text(index)])
		else:
			emit_signal("part_selected", list.get_item_text(index))
	else:
		if column_index == Part.BLOCK:
			# Delete block entry
			G.settings.blocks.erase(list.get_item_text(index))
			list.remove_item(index)
