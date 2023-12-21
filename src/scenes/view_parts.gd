extends GraphEdit

# This script facilitates adding and removing control nodes to/from multiple parts.
# So the GraphNode slots need to be reconfigured to align with the ports.
# Then the code may be used in a EditorScript

signal changed

const GAP = 20
const EXCLUDE = ["V+", "Gnd", "Nand", "Wire", "Bus", "WireColor", "BusColor", "Screen"]

func _ready():
	get_window().mode = Window.MODE_MAXIMIZED
	changed.connect(change_capture)
	call_deferred("go")


func go():
	add_parts_to_graph()
	await get_tree().create_timer(1.0).timeout
	# Hide a popup
	get_node("TextView/FileDialog").hide()


func modify():
	await get_tree().create_timer(1.0).timeout
	remove_spacer()
	await get_tree().create_timer(1.0).timeout
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


# The Godot 4.1 version needed a spacer Control node which is no longer needed
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
		var part: GraphNode = Parts.scenes[part_name].instantiate()
		part.position_offset = Vector2(x, y)
		part.controller = self
		part.size.y = 0
		add_child(part)
		x += part.size.x + GAP
		row_height = max(row_height, part.size.y)
		if x > size.x:
			x = GAP
			y += row_height + GAP


func change_capture():
	print("Something changed")


# Mock functions to allow the parts to be added to the scene:

func output_level_changed_handler(_part, _side, _port, _level):
	pass


func bus_value_changed_handler(_part, _side, _port, _value):
	pass
