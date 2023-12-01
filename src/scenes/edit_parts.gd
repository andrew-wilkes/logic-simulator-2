extends GraphEdit

# This tool facilitates adding and removing control nodes to/from multiple parts

const GAP = 20
const EXCLUDE = ["V+", "Gnd", "Nand", "Wire", "Bus", "WireColor", "BusColor", "Screen"]

func _ready():
	get_window().mode = Window.MODE_MAXIMIZED
	call_deferred("go")


func go():
	add_parts_to_graph()
	remove_spacer()
	move_ports()
	# Shrink height
	await get_tree().create_timer(0.5).timeout
	for node in get_children():
		if node is Part:
			node.size.y = 0


func move_ports():
	for node in get_children():
		if node is Part and node.name not in EXCLUDE:
			var part: GraphNode = node
			var slots = []
			for n in part.get_input_port_count():
				slots.append(part.get_input_port_slot(n))
			for slot in slots:
				part.set_slot_enabled_left(slot - 1, true)
				part.set_slot_type_left(slot - 1, part.get_slot_type_left(slot))
				part.set_slot_color_left(slot - 1, part.get_slot_color_left(slot))
				part.set_slot_enabled_left(slot, false)
			slots = []
			for n in part.get_output_port_count():
				slots.append(part.get_output_port_slot(n))
			for slot in slots:
				part.set_slot_enabled_right(slot - 1, true)
				part.set_slot_type_right(slot - 1, part.get_slot_type_right(slot))
				part.set_slot_color_right(slot - 1, part.get_slot_color_right(slot))
				part.set_slot_enabled_right(slot, false)


func remove_spacer():
	for node in get_children():
		if node is Part and node.name not in EXCLUDE:
			if node.get_child(0) is Control:
				node.get_child(0).queue_free()


func add_parts_to_graph():
	var x = GAP
	var y = GAP
	var row_height = 0
	for part_name in Parts.names:
		prints("Added:", part_name)
		var part: GraphNode = Parts.scenes[part_name].instantiate()
		part.position_offset = Vector2(x, y)
		part.controller = self
		add_child(part)
		x += part.size.x + GAP
		row_height = max(row_height, part.size.y)
		if x > size.x:
			x = GAP
			y += row_height + GAP


func output_level_changed_handler(_part, _side, _port, _level):
	pass


func bus_value_changed_handler(_part, _side, _port, _value):
	pass
