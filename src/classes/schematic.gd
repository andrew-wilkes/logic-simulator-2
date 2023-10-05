class_name Schematic

extends GraphEdit

signal invalid_instance(ob, note)
signal warning(text)
signal changed

const PART_INITIAL_OFFSET = Vector2(50, 50)
const level_colors = [Color.BLUE, Color.RED]

enum { LEFT, RIGHT }

var circuit: Circuit
var selected_parts = []
var part_initial_offset_delta = Vector2.ZERO
var parent_file = ""
var indicate_logic_levels = true

func _ready():
	circuit = Circuit.new()
	node_deselected.connect(deselect_part)
	node_selected.connect(select_part)
	delete_nodes_request.connect(delete_selected_parts)
	connection_request.connect(connect_wire)
	disconnection_request.connect(disconnect_wire)
	duplicate_nodes_request.connect(duplicate_selected_parts)


func connect_wire(from_part, from_pin, to_part, to_pin):
	# Add guards against invalid connections
	# The Part class is designed to be bi-directional
	# Only allow 1 connection to an input
	for con in get_connection_list():
		if to_part == con.to and to_pin == con.to_port:
			return
	connect_node(from_part, from_pin, to_part, to_pin)
	# Propagate bus value or level
	emit_signal("changed")


func disconnect_wire(from_part, from_pin, to_part, to_pin):
	disconnect_node(from_part, from_pin, to_part, to_pin)
	emit_signal("changed")


func remove_connections_to_part(part):
	for con in get_connection_list():
		if con.to == part.name or con.from == part.name:
			disconnect_node(con.from, con.from_port, con.to, con.to_port)
	emit_signal("changed")


func clear():
	grab_focus()
	parent_file = ""
	clear_connections()
	for node in get_children():
		if node is Part:
			remove_child(node)
			node.queue_free() # This is delayed


func select_part(part):
	selected_parts.append(part)


func deselect_part(part):
	selected_parts.erase(part)


func delete_selected_parts(_arr):
	# _arr only lists parts that have a close button
	for part in selected_parts:
		if not is_object_instance_invalid(part, "delete_selected_parts"):
			delete_selected_part(part)
	selected_parts.clear()


func delete_selected_part(part):
	for con in get_connection_list():
		if con.to == part.name or con.from == part.name:
			disconnect_node(con.from, con.from_port, con.to, con.to_port)
	remove_child(part)
	part.queue_free()
	emit_signal("changed")


func duplicate_selected_parts():
	emit_signal("changed")
	# Base the location off the first selected part relative to the mouse cursor
	var offset = abs(get_local_mouse_position())
	var first_part = true
	for part in selected_parts:
		# Sometimes a previously freed part is one of the selected parts
		if is_object_instance_invalid(part, "duplicate_selected_parts"):
			continue
		if first_part:
			first_part = false
			offset = offset - part.position
			var part_offset = part.position_offset - scroll_offset
			# Can only seem to approximate the position when zoomed.
			# Ideally, the first selected part copy would position itself
			# exacly where the mouse cursor is.
			# Are you up for the challenge to fix this?
			if zoom > 1.1 or zoom < 0.9:
				part_offset *= 0.8 / zoom
			offset = Vector2(offset.x / part.position.x * part_offset.x, \
				offset.y / part.position.y * part_offset.y)
		var new_part = part.duplicate()
		new_part.selected = false
		new_part.position_offset += offset
		new_part.data = part.data.duplicate()
		new_part.part_type = part.part_type
		new_part.controller = self
		add_child(new_part)
		new_part.name = part.part_type + circuit.get_next_id()


func add_part_by_name(part_name):
	var part = Parts.scenes[part_name].instantiate()
	add_part(part)


func add_part(part):
	part.part_type = part.name.to_upper()
	part.position_offset = PART_INITIAL_OFFSET + scroll_offset / zoom \
		+ part_initial_offset_delta
	update_part_initial_offset_delta()
	add_child(part)
	part.controller = self
	emit_signal("changed")
	
	# We want precise control of node names to keep circuit data robust
	# Godot can sneak in @ marks to the node name, so we assign the name after
	# the node was added to the scene and Godot gave it a name
	part.name = part.part_type + circuit.get_next_id()
	part.connect("position_offset_changed", part.changed)


func add_block(file_name):
	if file_name == parent_file:
		emit_signal("warning", "cannot open parent circuit as block.")
	else:
		var block = Parts.scenes["BLOCK"].instantiate()
		block.data.circuit_file = file_name
		add_part(block)


# Avoid overlapping parts that are added via the menu
# Place in a 4x4 pattern since 16 parts are likely to be the max entered in one
# go by a user I think
func update_part_initial_offset_delta():
	var x = part_initial_offset_delta.x
	var y = part_initial_offset_delta.y
	y += 20
	if y > 60:
		y = 0
		x += 20
		if x > 60:
			x = 0
	part_initial_offset_delta = Vector2(x, y)


func save_circuit(file_name):
	grab_focus()
	circuit.connections = get_connection_list()
	circuit.parts = []
	for node in get_children():
		if node is Part:
			# Don't change node in the scene
			var part = node.duplicate()
			# Save the name of the node
			part.node_name = node.name
			part.tag = node.get_node("Tag").text
			part.part_type = node.part_type
			part.data = node.data
			part.clear() # Wipe member values that we don't want to save
			circuit.parts.append(part)
	circuit.snap_distance = snap_distance
	circuit.use_snap = use_snap
	circuit.minimap_enabled = minimap_enabled
	circuit.zoom = zoom
	circuit.scroll_offset = scroll_offset
	circuit.save_data(file_name)


func load_circuit(file_name):
	grab_focus()
	parent_file = file_name
	clear()
	circuit = Circuit.new().load_data(file_name)
	if circuit is Circuit:
		setup_graph()
		add_parts()
		add_connections()
		set_all_io_connection_colors()
		colorize_pins()
	else:
		emit_signal("warning", "The circuit data was invalid!")


func add_parts():
	for node in circuit.parts:
		if is_object_instance_invalid(node, "add_parts"):
			continue
		var part = Parts.scenes[node.part_type].instantiate()
		part.get_node("Tag").text = node.tag
		part.part_type = node.part_type
		part.data = node.data
		add_child(part)
		part.setup()
		part.controller = self
		part.name = node.node_name
		part.position_offset = node.position_offset
		part.tooltip_text = part.name
		part.connect("position_offset_changed", part.changed)


func add_connections():
	for con in circuit.connections:
		connect_node(con.from, con.from_port, con.to, con.to_port)


func colorize_pins():
	for node in get_children():
		if node is WireColor or node is BusColor:
			set_pin_colors(node.name, node.data.color)


func set_all_io_connection_colors():
	for node in get_children():
		if node is IO:
			set_io_connection_colors(node)


func setup_graph():
	snap_distance = circuit.snap_distance
	use_snap = circuit.use_snap
	zoom = circuit.zoom
	scroll_offset = circuit.scroll_offset
	minimap_enabled = circuit.minimap_enabled


# This function is included because it is difficult to debug situations 
# of freed nodes still persisting in say a weak reference state.
# In this software we frequently delete, duplicate, and create nodes.
func is_object_instance_invalid(ob, note = ""):
	if is_instance_valid(ob):
		return false
	else:
		emit_signal("invalid_instance", ob, note)
		return true


func removing_slot(part, port):
	for con in get_connection_list():
		if con.to == part.name and con.to_port == port \
			or con.from == part.name and con.from_port == port:
			disconnect_node(con.from, con.from_port, con.to, con.to_port)


func right_click_on_part(part):
	match part.part_type:
		"IO":
			$IOManager.open(part)


func output_level_changed_handler(part, side, port, level):
	for con in get_connection_list():
		if side == RIGHT:
			if con.from == part.name and con.from_port == port:
				get_node(NodePath(con.to)).update_input_level(LEFT, con.to_port, level)
		else:
			if con.to == part.name and con.to_port == port:
				get_node(NodePath(con.from)).update_input_level(RIGHT, con.from_port, level)
		if indicate_logic_levels:
			indicate_output_level(part, side, port, level)


func indicate_output_level(part, side, port, level):
	var color = level_colors[int(level)]
	if side == LEFT:
		# Check that this returns the number of available ports rather than connections
		if port < part.get_connection_input_count():
			var slot = part.get_connection_input_slot(port)
			part.set_slot_color_left(slot, color)
	else:
		if port < part.get_connection_output_count():
			var slot = part.get_connection_output_slot(port)
			part.set_slot_color_right(slot, color)


func bus_value_changed_handler(part, side, port, value):
	for con in get_connection_list():
		if side == RIGHT:
			if con.from == part.name and con.from_port == port:
				get_node(NodePath(con.to)).update_bus_input_value(LEFT, con.to_port, value)
		else:
			if con.to == part.name and con.to_port == port:
				get_node(NodePath(con.from)).update_bus_input_value(RIGHT, con.from_port, value)


func unstable_handler(part, side, port):
	emit_signal("warning", "Unstable input to %s side: %d port: %d" % [part, side, port])


func reset_race_counters():
	for node in get_children():
		if node is Part:
			node.race_counter.clear()
			prints("Reset ", node.name, node.race_counter)
			if node is Block:
				node.reset_block_race_counters()


func set_pin_colors(to_part, color):
	for con in get_connection_list():
		if con.to == to_part:
			var from_node = get_node(NodePath(con.from))
			from_node.set_slot_color_right(from_node.get_connection_output_slot(con.from_port), color)
			for con2 in get_connection_list():
				if con2.from == con.from and con2.from_port == con.from_port:
					var to_node = get_node(NodePath(con2.to))
					var slot = to_node.get_connection_input_slot(con2.to_port)
					to_node.set_slot_color_left(slot, color)


func set_io_connection_colors(io_part):
	for con in get_connection_list():
		if con.from == io_part.name:
			var color = io_part.data.wire_color\
				if io_part.get_connection_output_type(con.from_port) == 0\
					else io_part.data.bus_color
			var to_node = get_node(NodePath(con.to))
			var slot = to_node.get_connection_input_slot(con.to_port)
			to_node.set_slot_color_left(slot, color)
			slot = io_part.get_connection_output_slot(con.from_port)
			io_part.set_slot_color_right(slot, color)
		if con.to == io_part.name:
			var color = io_part.data.wire_color\
				if io_part.get_connection_input_type(con.to_port) == 0\
					else io_part.data.bus_color
			var from_node = get_node(NodePath(con.from))
			var slot = from_node.get_connection_output_slot(con.from_port)
			from_node.set_slot_color_right(slot, color)
			slot = io_part.get_connection_input_slot(con.to_port)
			io_part.set_slot_color_left(slot, color)
