class_name Schematic

extends GraphEdit

signal invalid_instance(ob, note)
signal changed # Something changed that needs to be part of a save in order to be re-created on load
signal title_changed(text)

const PART_INITIAL_OFFSET = Vector2(50, 50)

enum { LEFT, RIGHT }

var circuit: Circuit
var selected_parts = []
var part_initial_offset_delta = Vector2.ZERO
var parent_file = ""
var tester
var test_output_line = 0
var compare_lines = []
var test_state = G.TEST_STATUS.STEPPABLE
var last_scroll_offset = Vector2.ZERO
var watch_for_scroll_offset_change = true
var start_time = 0.0
var busy = false
var frame_count = 0
var a_part_was_deleted = false
var loaded_parts = {}

func _ready():
	set_process(false)
	circuit = Circuit.new()
	node_deselected.connect(deselect_part)
	node_selected.connect(select_part)
	delete_nodes_request.connect(delete_selected_parts)
	connection_request.connect(connect_wire)
	disconnection_request.connect(disconnect_wire)
	duplicate_nodes_request.connect(duplicate_selected_parts)
	G.test_runner = $C/TestRunner


func _unhandled_key_input(event):
	if event.keycode == KEY_R and event.ctrl_pressed:
		remove_connections_between_selected_parts()


func connect_wire(from_part, from_pin, to_part, to_pin):
	# Add guards against invalid connections
	# The Part class is designed to be bi-directional
	# Only allow 1 connection to an input
	for con in get_connection_list():
		if to_part == con.to_node and to_pin == con.to_port:
			return
	connect_node(from_part, from_pin, to_part, to_pin)
	# Propagate bus value or level
	var from
	for node in get_children():
		if node.name == from_part:
			from = node
			break
	if from:
		for node in get_children():
			if node.name == to_part:
				var slot = from.get_output_port_slot(from_pin)
				var con_type = from.get_slot_type_right(slot)
				if con_type == 0:
					var level = from.pins.get([RIGHT, from_pin], false)
					node.update_input_level(LEFT, to_pin, level)
					node.update_output_level_with_color(LEFT, to_pin, level)
				else:
					node.update_bus_input_value(LEFT, to_pin, from.pins.get([RIGHT, from_pin], 0))
				break
	circuit_changed()


func disconnect_wire(from_part, from_pin, to_part, to_pin):
	disconnect_node(from_part, from_pin, to_part, to_pin)
	circuit_changed()


func remove_connections_to_part(part):
	for con in get_connection_list():
		if con.to_node == part.name or con.from_node == part.name:
			disconnect_node(con.from_node, con.from_port, con.to_node, con.to_port)
	circuit_changed()


func clear():
	grab_focus()
	circuit = Circuit.new()
	scroll_offset = Vector2.ZERO
	zoom = 1.0
	emit_signal("title_changed", "")
	parent_file = ""
	clear_connections()
	G.test_runner.hide()
	for node in get_children():
		if node is Part:
			remove_child(node)
			node.queue_free() # This is delayed
			a_part_was_deleted = true


func select_part(part):
	selected_parts.append(part)


func deselect_part(part):
	selected_parts.erase(part)


func delete_selected_parts(_arr):
	var flag_changed = false
	# _arr only lists parts that have a close button but none of our parts use the close button
	for part in selected_parts:
		if not is_object_instance_invalid(part, "delete_selected_parts"):
			delete_selected_part(part)
			flag_changed = true
	selected_parts.clear()
	if flag_changed:
		circuit_changed()


func delete_selected_part(part):
	for con in get_connection_list():
		if con.to_node == part.name or con.from_node == part.name:
			disconnect_node(con.from_node, con.from_port, con.to_node, con.to_port)
	remove_child(part)
	part.queue_free()
	a_part_was_deleted = true


func duplicate_selected_parts():
	var flag_changed = false
	# Base the location off the first selected part relative to the mouse cursor
	var offset = abs(get_local_mouse_position())
	var first_part = true
	var part_map = {}
	for part in selected_parts:
		# Sometimes a previously freed part is one of the selected parts
		if is_object_instance_invalid(part, "duplicate_selected_parts"):
			continue
		flag_changed = true
		if first_part:
			first_part = false
			offset = offset - part.position
			var part_offset = part.position_offset - scroll_offset
			# Can only seem to approximate the position when zoomed.
			# Ideally, the first selected part copy would position itself
			# exactly where the mouse cursor is.
			if zoom > 1.1 or zoom < 0.9:
				part_offset *= 0.8 / zoom
			offset = Vector2(offset.x / part.position.x * part_offset.x, \
				offset.y / part.position.y * part_offset.y)
		#var new_part = part.duplicate() # This does not work for WireColor or BusColor
		# after setting the color for some unknown reason
		#if new_part == null:
		var new_part = Parts.scenes[part.part_type].instantiate()
		new_part.position_offset = part.position_offset
		new_part.selected = false
		new_part.position_offset += offset
		new_part.data = part.data.duplicate()
		new_part.part_type = part.part_type
		new_part.controller = self
		add_child(new_part)
		new_part.setup()
		new_part.size.x = 0 # Shrink width
		new_part.name = part.part_type + circuit.get_next_id()
		part_map[part.name] = new_part.name
	# Duplicate connections between duplicated parts
	for con in get_connection_list():
		if part_map.has(con.from_node) and part_map.has(con.to_node):
			connect_node(part_map[con.from_node], con.from_port, part_map[con.to_node], con.to_port)
	if flag_changed:
		circuit_changed()


func remove_connections_between_selected_parts():
	var flag_changed = false
	var part_names = []
	for part in selected_parts:
		part_names.append(part.name)
	for con in get_connection_list():
		if part_names.has(con.from_node) and part_names.has(con.to_node):
			flag_changed = true
			disconnect_node(con.from_node, con.from_port, con.to_node, con.to_port)
	if flag_changed:
		circuit_changed()


func add_part_by_name(part_name):
	var part = Parts.scenes[part_name].instantiate()
	add_part(part)
	grab_focus()


func add_part(part):
	part.controller = self
	add_child(part)
	part.setup()
	part.part_type = part.name
	part.position_offset = PART_INITIAL_OFFSET + scroll_offset / zoom \
		+ part_initial_offset_delta
	part.size.x = 0 # Shrink width
	update_part_initial_offset_delta()
	
	# We want precise control of node names to keep circuit data robust
	# Godot can sneak in @ marks to the node name, so we assign the name after
	# the node was added to the scene and Godot gave it a name
	part.name = part.part_type + circuit.get_next_id()
	part.tooltip_text = part.name
	part.connect("position_offset_changed", part.changed)
	circuit_changed()


func add_block(file_name):
	if file_name == parent_file:
		G.warn_user("Cannot open parent circuit as block.")
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
	circuit.data.snapping_distance = snapping_distance
	circuit.data.snapping_enabled = snapping_enabled
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
		await get_tree().process_frame
		add_connections(false)
		emit_signal("title_changed", circuit.data.title)
		circuit_changed(false)
		reset_parts()
		set_all_io_connection_colors()
		colorize_pins()
	else:
		G.warn_user("The circuit data was invalid!")


func add_parts():
	loaded_parts = {}
	for node in circuit.data.parts:
		var part = Parts.scenes[node.part_type].instantiate()
		part.get_node("Tag").text = node.tag
		part.part_type = node.part_type
		part.data = node.data
		part.controller = self
		add_child(part)
		part.setup()
		part.name = node.node_name
		loaded_parts[part.name] = part
		part.position_offset = Vector2(node.offset[0], node.offset[1])
		part.tooltip_text = part.name
		part.position_offset_changed.connect(part.changed)
		part.size.x = 0 # Shrink width


func add_connections(checked):
	var bad_blocks = []
	for node in get_children():
		if node is Block and node.has_bad_hash():
			bad_blocks.append(node.name)
			G.warn_user(get_part_id(node) + " has changed internally, so disconnected." +\
				"\n Circuit file: " + node.data.circuit_file)
	for con in circuit.data.connections:
		if con.from_node in bad_blocks or con.to_node in bad_blocks:
			continue
		if checked:
			connect_node(con.from_node, con.from_port, con.to_node, con.to_port)
			continue
		# Check port compatibility since circuits translated from v1 may have invalid connections
		var from_part = loaded_parts[con.from_node]
		var to_part = loaded_parts[con.to_node]
		if con.from_port >= from_part.get_output_port_count():
			continue
		if con.to_port >= to_part.get_input_port_count():
			continue
		if from_part.get_output_port_type(con.from_port) == to_part.get_input_port_type(con.to_port):
			connect_node(con.from_node, con.from_port, con.to_node, con.to_port)


func get_part_id(part):
	if part.get_node("Tag").text.is_empty():
		return part.name
	else:
		return part.get_node("Tag").text


# This is called to remove the effect of level indications
func set_all_connection_colors():
	for node in get_children():
		if node is Part:
			for idx in node.get_input_port_count():
				var slot = node.get_input_port_slot(idx)
				var color = Color.WHITE if node.get_slot_type_left(slot) == 0 else Color.YELLOW
				node.set_slot_color_left(slot, color)
			for idx in node.get_output_port_count():
				var slot = node.get_output_port_slot(idx)
				var color = Color.WHITE if node.get_slot_type_right(slot) == 0 else Color.YELLOW
				node.set_slot_color_right(slot, color)
	set_all_io_connection_colors()
	colorize_pins()


func colorize_pins():
	for node in get_children():
		if node is Part:
			match node.part_type:
				"WireColor", "BusColor", "WireColorTag", "BusColorTag":
					set_pin_colors(node.name, node.data.color)
				"Vcc", "Gnd":
					set_pin_colors(node.name, node.set_color())


func set_low_color():
	for node in get_children():
		if node is Gnd:
			node.set_color()


func set_high_color():
	for node in get_children():
		if node is Vcc:
			node.set_color()


func set_all_io_connection_colors():
	for node in get_children():
		if node is IO:
			set_io_connection_colors(node)


func setup_graph():
	watch_for_scroll_offset_change = false
	snapping_distance = circuit.data.snapping_distance
	snapping_enabled = circuit.data.snapping_enabled
	zoom = circuit.data.zoom
	var off = circuit.data.scroll_offset
	# Can't seem to set the scroll_offset exactly
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
		if con.to_node == part.name and con.to_port == port \
			or con.from_node == part.name and con.from_port == port:
			disconnect_node(con.from_node, con.from_port, con.to_node, con.to_port)


func right_click_on_part(part):
	match part.part_type:
		"IO":
			$IOManagerPanel/IOManager.open(part)
			$IOManagerPanel.popup_centered()
		"ROM":
			part.open_file()
		"RAM", "Memory", "Screen":
			$MemoryManagerPanel/MemoryManager.open(part)
			$MemoryManagerPanel.popup_centered()
			$MemoryManagerPanel.position.y += 15


func output_level_changed_handler(part, side, port, level):
	for con in get_connection_list():
		if side == RIGHT:
			if con.from_node == part.name and con.from_port == port:
				var node = get_node(NodePath(con.to_node))
				node.update_input_level(LEFT, con.to_port, level)
				if G.settings.indicate_to_levels:
					node.indicate_level(LEFT, con.to_port, level)
		else:
			if con.to_node == part.name and con.to_port == port:
				var node = get_node(NodePath(con.from_node))
				node.update_input_level(RIGHT, con.from_port, level)
				if G.settings.indicate_to_levels:
					node.indicate_level(RIGHT, con.from_port, level)
		if G.settings.indicate_from_levels:
			part.indicate_level(side, port, level)


func bus_value_changed_handler(part, side, port, value):
	for con in get_connection_list():
		if side == RIGHT:
			if con.from_node == part.name and con.from_port == port:
				get_node(NodePath(con.to_node)).update_bus_input_value(LEFT, con.to_port, value)
		else:
			if con.to_node == part.name and con.to_port == port:
				get_node(NodePath(con.from_node)).update_bus_input_value(RIGHT, con.from_port, value)


func unstable_handler(part, side, port):
	G.warn_user("Unstable input to %s on %s side, pin: %d" % [part.name, ["left", "right"][side], port])


func reset_race_counters():
	for node in get_children():
		if node is Part:
			node.reset_race_counter()
			if node is Block:
				node.reset_block_race_counters()


func set_pin_colors(to_part, color):
	for con in get_connection_list():
		if con.to_node == to_part:
			var from_node = get_node(NodePath(con.from_node))
			from_node.set_slot_color_right(from_node.get_output_port_slot(con.from_port), color)
			for con2 in get_connection_list():
				if con2.from_node == con.from_node and con2.from_port == con.from_port:
					var to_node = get_node(NodePath(con2.to_node))
					var slot = to_node.get_input_port_slot(con2.to_port)
					to_node.set_slot_color_left(slot, color)


func set_io_connection_colors(io_part):
	for con in get_connection_list():
		if con.from_node == io_part.name:
			var color = io_part.data.wire_color\
				if io_part.get_output_port_type(con.from_port) == 0\
					else io_part.data.bus_color
			var to_node = get_node(NodePath(con.to_node))
			var slot = to_node.get_input_port_slot(con.to_port)
			to_node.set_slot_color_left(slot, color)
			slot = io_part.get_output_port_slot(con.from_port)
			io_part.set_slot_color_right(slot, color)
		if con.to_node == io_part.name:
			var color = io_part.data.wire_color\
				if io_part.get_input_port_type(con.to_port) == 0\
					else io_part.data.bus_color
			var from_node = get_node(NodePath(con.from_node))
			var slot = from_node.get_output_port_slot(con.from_port)
			from_node.set_slot_color_right(slot, color)
			slot = io_part.get_input_port_slot(con.to_port)
			io_part.set_slot_color_left(slot, color)


func number_parts():
	var part_names = {}
	# Order the parts based on offset in grid
	# Create dictionary { pos: [part(s)] }
	var nodes = {}
	for node in get_children():
		if node is Part:
			var offlen = node.position_offset.length()
			if nodes.has(offlen):
				nodes[offlen].append(node)
			else:
				nodes[offlen] = [node]
	var keys = nodes.keys()
	keys.sort()
	var counts = {}
	for key in keys:
		var parts = nodes[key]
		for part in parts:
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
		con.from_node = part_names[con.from_node]
		con.to_node = part_names[con.to_node]
	clear_connections()
	add_connections(true)
	emit_signal("changed")


func set_circuit_title(text):
	circuit.data.title = text
	emit_signal("changed")


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
		G.warn_user("Error opening file: " + file_path)
		return
	var hdl = file.get_as_text()
	clear()
	var text_view = Parts.scenes["TextView"].instantiate()
	text_view.data.file = file_path
	add_part(text_view)
	text_view.changed()
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
	if file_path.find("03/") + file_path.find("05/") > -2:
		input_wires.append("clk")
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


func _on_scroll_offset_changed(offset):
	if last_scroll_offset != offset and watch_for_scroll_offset_change:
		emit_signal("changed")
	last_scroll_offset = offset
	watch_for_scroll_offset_change = true


func circuit_changed(emit = true):
	if emit:
		emit_signal("changed")
	# Update Memory links
	var probes = {}
	var memories = {}
	var injectors = {}
	for node in get_children():
		if node is MemoryProbe:
			node.memory = null
			probes[node.name] = node
		if node is MemoryInjector:
			injectors[node.name] = node
		if node is BaseMemory:
			node.probes.clear()
			memories[node.name] = node
		if node is Block:
			if node.memory:
				node.memory.probes.clear()
				memories[node.name] = node.memory
	for con in get_connection_list():
		if memories.has(con.from_node):
			if probes.has(con.to_node):
				memories[con.from_node].probes.append(probes[con.to_node])
				probes[con.to_node].memory = memories[con.from_node]
			if injectors.has(con.to_node):
				injectors[con.to_node].memory = memories[con.from_node]
	for pname in probes:
		probes[pname].update_data()


#region Tester Code
func test_circuit():
	if circuit.data.title.is_empty():
		G.warn_user("No circuit title has been set.")
	else:
		var test_file = circuit.data.title + ".tst"
		# Find dir containing these files
		var result = G.find_file(G.settings.test_dir, test_file)
		if result.error:
			G.warn_user("File not found: " + test_file)
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
					G.test_runner.set_title(test_file)
					tester.init_tests(test_spec, io_nodes)
					reset_test_environment()
					# Make panel fit the width of the test output
					for task in tester.tasks:
						if task[0] == "output-list":
							var width = task[1].length() * 8.2
							if G.test_runner.size.x < width:
								G.test_runner.size.x = width
					G.test_runner.open()
			else:
				G.warn_user("Error opening file: " + test_file)


func _on_test_runner_reset():
	reset_test_environment()


func reset_test_environment():
	reset_parts()
	set_all_connection_colors()
	tester.test_step = 0
	test_output_line = 0
	G.test_runner.set_text("")
	G.test_runner.text_area.clear() # Clear bbcode tags
	tester.reset()
	test_state = G.TEST_STATUS.STEPPABLE
	G.test_runner.set_button_status(test_state)
	a_part_was_deleted = false


func reset_parts():
	for part in get_children():
		if part is Part:
			part.reset()


func reset_pins():
	for part in get_children():
		if part is Part:
			part.pins = {}


func _on_test_runner_step():
	if test_state == G.TEST_STATUS.STEPPABLE:
		G.test_runner.set_button_status(test_state)
		run_test()


func _on_test_runner_play():
	if test_state != G.TEST_STATUS.DONE:
		test_state = G.TEST_STATUS.PLAYING
		G.test_runner.set_button_status(test_state)
		start_time = Time.get_ticks_msec()
		set_process(true)


func _on_test_runner_stop():
	if test_state != G.TEST_STATUS.DONE:
		test_state = G.TEST_STATUS.STEPPABLE
		G.test_runner.set_button_status(test_state)
		set_process(false)


func run_test():
	busy = true
	var break_out = false
	while true:
		if a_part_was_deleted:
			# A deleted part will cause a crash so abort the tests
			test_state = G.TEST_STATUS.DONE
			set_process(false)
			G.test_runner.hide()
			break
		if tester.test_step == tester.tasks.size():
			if OS.is_debug_build():
				print("Run time: %dms" % [Time.get_ticks_msec() - start_time])
			G.test_runner.text_area.add_text("DONE")
			test_state = G.TEST_STATUS.DONE
			G.test_runner.set_button_status(test_state)
			set_process(false)
			break
		reset_race_counters()
		var task
		if tester.repetitive_task_idx >= 0:
			task = tester.repetitive_tasks[tester.repetitive_task_idx]
			tester.repetitive_task_idx += 1
			if tester.repetitive_task_idx == tester.repetitive_tasks.size():
				tester.repetitive_task_idx = -1
				# Break out after completing the pending task to cause
				# the next task to be the while or repeat task
				break_out = true
		else:
			task = tester.tasks[tester.test_step]
			tester.test_step += 1
		tester.process_task(task)
		match task[0]:
			"output-list":
				G.test_runner.text_area.add_text(tester.output)
				test_output_line += 1
			"output":
				if test_output_line < compare_lines.size():
					add_compared_string(tester.output, compare_lines[test_output_line], G.test_runner.text_area)
					test_output_line += 1
				else:
					G.test_runner.text_area.add_text(tester.output)
				break
		if break_out:
			break
	busy = false


func _process(delta):
	frame_count -= 1
	if frame_count < 0 and test_state == G.TEST_STATUS.PLAYING and not busy:
		run_test()
		frame_count = G.settings.tester_speed / delta / 60.0


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
#endregion
