class_name Schematic

extends GraphEdit

signal invalid_instance(ob, note)
signal changed
signal title_changed(text)

const PART_INITIAL_OFFSET = Vector2(50, 50)

enum { LEFT, RIGHT }

var circuit: Circuit
var selected_parts = []
var part_initial_offset_delta = Vector2.ZERO
var parent_file = ""
var indicate_logic_levels = true
var tester
var test_step = 0
var test_output_line = 0
var compare_lines = []
var test_playing = false
@onready var test_runner = $C/TestRunner

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
	circuit = Circuit.new()
	emit_signal("title_changed", "")
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
	grab_focus()


func add_part(part):
	add_child(part)
	part.part_type = part.name
	part.position_offset = PART_INITIAL_OFFSET + scroll_offset / zoom \
		+ part_initial_offset_delta
	update_part_initial_offset_delta()
	part.controller = self
	
	# We want precise control of node names to keep circuit data robust
	# Godot can sneak in @ marks to the node name, so we assign the name after
	# the node was added to the scene and Godot gave it a name
	part.name = part.part_type + circuit.get_next_id()
	part.tooltip_text = part.name
	part.connect("position_offset_changed", part.changed)
	emit_signal("changed")


func add_block(file_name):
	if file_name == parent_file:
		G.warning.open("cannot open parent circuit as block.")
	else:
		var block = Parts.scenes["Block"].instantiate()
		block.data.circuit_file = file_name
		add_part(block)
	grab_focus()


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
	circuit.data.connections = get_connection_list()
	circuit.data.parts = []
	for node in get_children():
		if node is Part:
			circuit.data.parts.append(node.get_dict())
	circuit.data.snap_distance = snap_distance
	circuit.data.use_snap = use_snap
	circuit.data.minimap_enabled = minimap_enabled
	circuit.data.zoom = zoom
	circuit.data.scroll_offset = [scroll_offset.x, scroll_offset.y]
	circuit.save_data(file_name)


func load_circuit(file_name):
	grab_focus()
	clear()
	parent_file = file_name
	var load_result = circuit.load_data(file_name)
	if load_result == OK:
		setup_graph()
		add_parts()
		add_connections()
		set_all_io_connection_colors()
		colorize_pins()
		emit_signal("title_changed", circuit.data.title)
	else:
		G.warning.open("The circuit data was invalid!")


func add_parts():
	for node in circuit.data.parts:
		var part = Parts.scenes[node.part_type].instantiate()
		part.get_node("Tag").text = node.tag
		part.part_type = node.part_type
		part.data = node.data
		part.controller = self
		add_child(part)
		part.setup()
		part.name = node.node_name
		part.position_offset = Vector2(node.offset[0], node.offset[1])
		part.tooltip_text = part.name
		part.position_offset_changed.connect(part.changed)


func add_connections():
	for con in circuit.data.connections:
		connect_node(con.from, con.from_port, con.to, con.to_port)


# This is called to remove the effect of level indications
func set_all_connection_colors():
	for node in get_children():
		if node is Part:
			for idx in node.get_connection_input_count():
				var slot = node.get_connection_input_slot(idx)
				var color = Color.WHITE if node.get_slot_type_left(slot) == 0 else Color.YELLOW
				node.set_slot_color_left(slot, color)
			for idx in node.get_connection_output_count():
				var slot = node.get_connection_output_slot(idx)
				var color = Color.WHITE if node.get_slot_type_right(slot) == 0 else Color.YELLOW
				node.set_slot_color_right(slot, color)
	set_all_io_connection_colors()
	colorize_pins()
	clear_pins() # Allow V+ and Gnd to re-color the wire after the next input


func colorize_pins():
	for node in get_children():
		if node in [WireColor, BusColor, Vcc, Gnd]:
			set_pin_colors(node.name, node.data.color)


func set_all_io_connection_colors():
	for node in get_children():
		if node is IO:
			set_io_connection_colors(node)


func set_low_color():
	for node in get_children():
		if node is Gnd:
			node.set_color()


func set_high_color():
	for node in get_children():
		if node is Vcc:
			node.set_color()


func setup_graph():
	snap_distance = circuit.data.snap_distance
	use_snap = circuit.data.use_snap
	zoom = circuit.data.zoom
	var off = circuit.data.scroll_offset
	scroll_offset = Vector2(off[0], off[1])
	minimap_enabled = circuit.data.minimap_enabled


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
			$IOManagerPanel/IOManager.open(part)
			$IOManagerPanel.popup_centered()


func output_level_changed_handler(part, side, port, level):
	for con in get_connection_list():
		if side == RIGHT:
			if con.from == part.name and con.from_port == port:
				var node = get_node(NodePath(con.to))
				node.update_input_level(LEFT, con.to_port, level)
				if G.settings.indicate_to_levels:
					indicate_level(node, LEFT, con.to_port, level)
		else:
			if con.to == part.name and con.to_port == port:
				var node = get_node(NodePath(con.from))
				node.update_input_level(RIGHT, con.from_port, level)
				if G.settings.indicate_to_levels:
					indicate_level(node, RIGHT, con.from_port, level)
		if G.settings.indicate_from_levels:
			indicate_level(part, side, port, level)


func indicate_level(part, side, port, level):
	var color = G.settings.logic_high_color if level else G.settings.logic_low_color
	if side == LEFT:
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
	G.warning.open("Unstable input to %s on %s side, port: %d" % [part.name, ["left", "right"][side], port])


func reset_race_counters():
	for node in get_children():
		if node is Part:
			node.reset_race_counter()
			if node is Block:
				node.reset_block_race_counters()


func clear_pins():
	for node in get_children():
		if node is Part:
			node.pins.clear()


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


func number_parts():
	var part_names = {}
	# Order the parts based on position in grid
	# Create dictionary { pos: part }
	var nodes = {}
	for node in get_children():
		if node is Part:
			nodes[node.position_offset.length()] = node
	var keys = nodes.keys()
	keys.sort()
	var counts = {}
	for key in keys:
		var part = nodes[key]
		if counts.has(part.part_type):
			counts[part.part_type] += 1
		else:
			counts[part.part_type] = 1
		var new_name = part.part_type + str(counts[part.part_type])
		part.get_node("Tag").text = new_name
		part_names[part.name] = new_name
		part.name = new_name
		part.tooltip_text = new_name
	# Redo the connections with updated part names
	circuit.data.connections = get_connection_list()
	for con in circuit.data.connections:
		con.from = part_names[con.from]
		con.to = part_names[con.to]
	clear_connections()
	add_connections()
	emit_signal("changed")


func set_circuit_title(text):
	circuit.data.title = text
	emit_signal("changed")


func test_circuit():
	if circuit.data.title.is_empty():
		G.warning.open("No circuit title has been set.")
	else:
		var test_file = circuit.data.title + ".tst"
		# Find dir containing these files
		var result = G.find_file(G.settings.test_dir, test_file)
		if result.error:
			G.warning.open("File not found: " + test_file)
		else:
			var compare_file = result.path + "/" + circuit.data.title + ".cmp"
			if FileAccess.file_exists(compare_file):
				compare_file = FileAccess.open(compare_file, FileAccess.READ)
				if compare_file:
					compare_lines = compare_file.get_as_text().replace("\r", "").split("\n", false)
				tester = TestCircuit.new()
			var io_nodes = tester.get_io_nodes(get_children(), get_connection_list())
			var file = FileAccess.open(result.path + "/" + test_file, FileAccess.READ)
			if file:
					var test_spec = file.get_as_text()
					test_runner.set_title(test_file)
					tester.init_tests(test_spec, io_nodes)
					# Make panel fit the width of the test output
					for task in tester.tasks:
						if task[0] == "output-list":
							var width = task[1].length() * 8.2
							if test_runner.size.x < width:
								test_runner.size.x = width
					test_runner.open()
			else:
				G.warning.open("Error opening file: " + test_file)
				tester.free()


func add_bus_io(label, pos):
	var part = Parts.scenes["Bus"].instantiate()
	part.get_node("Tag").text = label
	add_part(part)
	part.position_offset = pos


func add_wire_io(label, pos):
	var part = Parts.scenes["Wire"].instantiate()
	part.get_node("Tag").text = label
	add_part(part)
	part.position_offset = pos


func create_circuit_from_hdl(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		G.warning.open("Error opening file: " + file_path)
		return
	var hdl = file.get_as_text()
	clear()
	var text_view = Parts.scenes["TextView"].instantiate()
	text_view.data.file = file_path
	add_child(text_view)
	text_view.position_offset = Vector2(800, 40)
	var test = TestCircuit.new()
	var details = test.get_ios_from_hdl(hdl)
	test.free()
	circuit.data.title = details.title
	emit_signal("title_changed", circuit.data.title)
	var count = 0
	# Add data bus inputs
	var input_wires = []
	for input in details.inputs:
		if input[1] == 1:
			add_bus_io(input[0], Vector2(100, 40 + 80 * count))
			count += 1
		else:
			input_wires.append(input[0])
	# Add wire inputs
	for input_wire in input_wires:
		add_wire_io(input_wire, Vector2(100, 40 + 80 * count))
		count += 1
	count = 0
	# Add data bus outputs
	var output_wires = []
	for output in details.outputs:
		if output[1] == 1:
			add_bus_io(output[0], Vector2(600, 40 + 80 * count))
			count += 1
		else:
			output_wires.append(output[0])
	# Add wire outputs
	for output_wire in output_wires:
		add_wire_io(output_wire, Vector2(600, 40 + 80 * count))
		count += 1
	grab_focus()


func _on_test_runner_reset():
	test_step = 0
	test_output_line = 0
	test_runner.set_text("")
	test_runner.text_area.clear() # Clear bbcode tags
	tester.reset()
	for part in get_children():
		if part is Part:
			part.reset()


func _on_test_runner_step():
	while test_step < tester.tasks.size():
		reset_race_counters()
		var task
		if tester.repeat_counter > 0:
			if tester.repetitive_task_idx == tester.repetitive_tasks.size():
				tester.repetitive_task_idx = 0
				if tester.while_task:
					# Repeat the while task and break out of this while loop
					tester.process_task(tester.while_task)
					break
			task = tester.repetitive_tasks[tester.repetitive_task_idx]
		else:
			task = tester.tasks[test_step]
		tester.process_task(task)
		if task[0] == "output-list":
			test_runner.text_area.add_text(tester.output)
			test_output_line += 1
		elif task[0] == "output":
			if test_output_line < compare_lines.size():
				add_compared_string(tester.output, compare_lines[test_output_line], test_runner.text_area)
				test_output_line += 1
			else:
				test_runner.text_area.add_text(tester.output)
			break
		if tester.repeat_counter > 0:
			tester.repeat_counter -= tester.repeat_decrement
			tester.repetitive_task_idx += 1
		else:
			test_step += 1
	if tester.repeat_counter > 0:
		tester.repeat_counter -= tester.repeat_decrement
		tester.repetitive_task_idx += 1
		if tester.repeat_counter == 0:
			tester.repetitive_tasks.clear()
	else:
		test_step += 1
	if test_step == tester.tasks.size():
		test_runner.text_area.add_text("DONE")
		test_playing = false
	if test_playing:
		$TestTimer.start()


func _on_test_runner_play():
	test_playing = true
	$TestTimer.start()


func _on_test_runner_stop():
	$TestTimer.stop()
	test_playing = false


func add_compared_string(out, comp, text_area: RichTextLabel):
	var green = false
	var red = false
	for idx in out.length():
		if idx == comp.length():
			break
		if idx == 0:
			if out[idx] == comp[idx]:
				text_area.push_color(Color.GREEN)
				green = true
			else:
				text_area.push_color(Color.RED)
				red = true
		else:
			if out[idx] == comp[idx]:
				if red:
					text_area.pop()
					red = false
					text_area.push_color(Color.GREEN)
					green = true
			else:
				if green:
					text_area.pop()
					green = false
					text_area.push_color(Color.RED)
					red = true
		text_area.add_text(comp[idx]) # Display the correct char
	if red or green:
		text_area.pop()
	text_area.add_text("\n")


func _on_test_timer_timeout():
	_on_test_runner_step()
