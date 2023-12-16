class_name Block

# This Part allows for loading a circuit as a Block
# Then a part is created with inputs and outputs derived from the IO parts of the circuit.
# And the circuit within a block may also contain blocks.
# Have to think about a requested feature of surfacing embedded displays.
# This could be via a right-click feature.
# Also, there should be reports of how the block is comprised in terms of a tree.
# Again, a possible right-click feature.

extends Part

enum { PART, PORT }

var circuit
var parts = {}
var input_map = []
var output_map = []
var input_pin_count = 0
var output_pin_count = 0
var inputs = []
var outputs = []
var file_chain = []
var wire_color = Color.WHITE
var bus_color = Color.YELLOW

func _init():
	data = { "circuit_file": "", "wiring_hash": 0 }


func _ready():
	super() # It's easy to forget to call the parent _ready code to add the Tag etc.
	block_setup()
	set_slots(max(input_pin_count, output_pin_count) - 1)
	configure_pins()
	reset()


func has_bad_hash():
	var current_hash = circuit.data.connections.hash()
	if current_hash != data.wiring_hash:
		data.wiring_hash = current_hash
		return true
	return false


func block_setup(_file_chain = []):
	file_chain = _file_chain
	circuit = Circuit.new()
	if file_chain.has(data.circuit_file):
		G.warning.open("Detected an infinite loop! %s was previously loaded as a block." % [data.circuit_file.get_file()])
		return
	file_chain.append(data.circuit_file)
	var load_result = circuit.load_data(data.circuit_file)
	if load_result != OK:
		G.warning.open("The circuit block data from %s was invalid!" % [data.circuit_file.get_file()])
		return
	if data.get("wiring_hash", 0) == 0: # Set this for new blocks
		data.wiring_hash = circuit.data.connections.hash()
	# Every circuit opened as a block is added to the available parts list
	var cname = circuit.data.title
	if cname.is_empty():
		# Use the file name without the extension
		cname = data.circuit_file.get_file().get_slice('.', 0)
	if not G.settings.blocks.has(cname):
		G.settings.blocks[cname] = data.circuit_file
	for part in circuit.data.parts:
		if part.part_type == "IO":
			if is_input(part):
				inputs.append(part)
				input_pin_count += part.data.num_wires + 1
			if is_output(part):
				outputs.append(part)
				output_pin_count += part.data.num_wires + 1
		if part.part_type in ["Bus", "Wire", "TriState"]:
			if is_input(part):
				inputs.append(part)
				input_pin_count += 1
			if is_output(part):
				outputs.append(part)
				output_pin_count += 1
	# Sort according to position offset
	inputs.sort_custom(compare_offsets)
	outputs.sort_custom(compare_offsets)
	# Create IO pin maps
	for io_part in inputs:
		# [part_name, port]
		input_map.append([io_part.node_name, 0])
		if io_part.part_type == "IO":
			for n in io_part.data.num_wires:
				# n is type float!
				# We use arrays as dictionary keys, so the data types in the array must be as expected
				input_map.append([io_part.node_name, int(n + 1)])
	for io_part in outputs:
		# [part_name, port]
		output_map.append([io_part.node_name, 0])
		if io_part.part_type == "IO":
			for n in io_part.data.num_wires:
				output_map.append([io_part.node_name, int(n + 1)])
	add_parts()


func set_slots(to_add):
	# Text is added later if there is a pin
	$Slot1.get_child(0).text = ""
	$Slot1.get_child(1).text = ""
	if to_add > 0:
		for n in to_add:
			var slot = $Slot1.duplicate()
			slot.name = "Slot" + str(n + 2)
			add_child(slot)
		# Move Tag to the end
		var tag_node = $Tag
		remove_child(tag_node)
		add_child(tag_node)


func configure_pins():
	clear_all_slots()
	var slot1 = 0
	# Find Slot1
	for  node in get_children():
		if node.name == "Slot1":
			break
		slot1 += 1
	var slot_idx = slot1
	for input in inputs:
		var label_idx = 0
		set_slot_enabled_left(slot_idx, true)
		set_slot_type_left(slot_idx, BUS_TYPE if input.part_type in ["IO", "Bus"] else WIRE_TYPE)
		set_slot_color_left(slot_idx, bus_color if input.part_type in ["IO", "Bus"] else wire_color)
		get_child(slot_idx).get_child(0).text = input.data.labels[label_idx]\
			if input.part_type == "IO" else input.tag
		if input.part_type == "IO":
			for n in input.data.num_wires:
				slot_idx += 1
				if label_idx + 1 < input.data.labels.size():
					label_idx += 1
				get_child(slot_idx).get_child(0).text = input.data.labels[label_idx]
				set_slot_enabled_left(slot_idx, true)
				set_slot_type_left(slot_idx, WIRE_TYPE)
				set_slot_color_left(slot_idx, wire_color)
		slot_idx += 1
	slot_idx = slot1
	for output in outputs:
		var label_idx = 0
		set_slot_enabled_right(slot_idx, true)
		set_slot_type_right(slot_idx, BUS_TYPE if output.part_type in ["IO", "Bus", "TriState"] else WIRE_TYPE)
		set_slot_color_right(slot_idx, bus_color if output.part_type in ["IO", "Bus", "TriState"] else wire_color)
		get_child(slot_idx).get_child(1).text = output.data.labels[label_idx]\
			if output.part_type == "IO" else output.tag
		if output.part_type == "IO":
			for n in output.data.num_wires:
				slot_idx += 1
				if label_idx + 1 < output.data.labels.size():
					label_idx += 1
				get_child(slot_idx).get_child(1).text = output.data.labels[label_idx]
				set_slot_enabled_right(slot_idx, true)
				set_slot_type_right(slot_idx, WIRE_TYPE)
				set_slot_color_right(slot_idx, wire_color)
		slot_idx += 1


func is_input(part):
	# If there are no wires connected to the part input side, then it is an input to the circuit.data
	for con in circuit.data.connections:
		if con.to_node == part.node_name:
			return false
	return true


func is_output(part):
	# If there are no wires connected to the part output side, then it is an output to the circuit.data
	for con in circuit.data.connections:
		if con.from_node == part.node_name:
			return false
	return true


func add_parts():
	for node in circuit.data.parts:
		var part = Parts.get_instance(node.part_type)
		part.tag = node.tag
		part.part_type = node.part_type
		part.data = node.data
		# Part instances have a name but circuit.data.parts store the name as node_name
		part.name = node.node_name
		part.show_display = false
		part.setup_instance()
		part.controller = self
		add_connections_to_part(part)
		if part.part_type == "Block":
			part.block_setup(file_chain)
		parts[part.name] = part


func get_map(side: int, port: int):
	return input_map[port] if side == LEFT else output_map[port]


# Map external input to internal IO part
func evaluate_output_level(input_side: int, port: int, level):
	if DEBUG:
		prints("block evaluate_output_level", self.name, input_side, port, level)
	var map = get_map(input_side, port)
	var part = parts[map[PART]]
	var output_side = FLIP_SIDES[input_side]
	part.update_output_level(output_side, map[PORT], level)
	if part.part_type == "IO":
		# Update the bus
		var value = 0
		for n in part.data.num_wires:
			value *= 2
			value += int(part.pins.get([output_side, int(part.data.num_wires - n)], false))
		part.evaluate_bus_output_value(input_side, 0, value, false)


# Map external bus input to internal part
func evaluate_bus_output_value(side: int, port: int, value: int, update_levels = true):
	var map = get_map(side, port)
	# Flip the side to the output side
	side = FLIP_SIDES[side]
	var part = parts[map[PART]]
	part.update_output_value(side, map[PORT], value)
	if update_levels and part.part_type == "IO":
		# This will ignore (clip) value bits above the range that the wires cover
		for n in part.data.num_wires:
			var level = bool(value % 2)
			value /= 2
			part.update_output_level(side, n + 1, level)


func output_level_changed_handler(part, side: int, port: int, level):
	if DEBUG:
		prints("block output_level_changed_handler", part.name, side, port, level)
	var map_idx = [str(part.name), port] # part.name seems to be a pointer to a string
	var port_idx = [input_map, output_map][side].find(map_idx)
	if port_idx > -1:
		pins[[side, port_idx]] = level
		controller.output_level_changed_handler(self, side, port_idx, level)
	else:
		update_internal_input_level(part, side, port, level)


func update_internal_input_level(part, side: int, port: int, level):
	if DEBUG:
		prints("block update_internal_input_level", part.name, side, port, level)
	var cons = part.connections.get([side, port])
	if cons:
		for connection in cons:
			parts[connection[0]].update_input_level(int(side == 0), connection[1], level)


func add_connections_to_part(part):
	for con in circuit.data.connections:
		if con.from_node == part.name:
			var key = [RIGHT, int(con.from_port)]
			var value = [con.to_node, con.to_port]
			add_to_connections(part, key, value)
		elif con.to_node == part.name:
			var key = [LEFT, int(con.to_port)]
			var value = [con.from_node, con.from_port]
			add_to_connections(part, key, value)


func add_to_connections(part, key, value):
	if part.connections.has(key):
		part.connections[key].append(value)
	else:
		part.connections[key] = [value]


func bus_value_changed_handler(part, side: int, port: int, value: int):
	var map_idx = [str(part.name), port]
	var port_idx = [input_map, output_map][side].find(map_idx)
	if port_idx > -1:
		pins[[side, port_idx]] = value
		controller.bus_value_changed_handler(self, side, port_idx, value)
		if part is IO:
			for n in part.data.num_wires:
				port_idx += 1
				var level = value % 2 == 1
				value /= 2
				pins[[side, port_idx]] = level
				controller.output_level_changed_handler(self, side, port_idx, level)
	else:
		update_internal_bus_input_value(part, side, port, value)


func update_internal_bus_input_value(part, side: int, port: int, value):
	var cons = part.connections.get([side, port])
	if cons:
		for connection in cons:
			parts[connection[0]].update_bus_input_value(int(side == 0), connection[1], value)


func reset_block_race_counters():
	for part in parts.values():
		part.race_counter.clear()
		if part is Block:
			part.reset_block_race_counters()


func reset():
	super()
	for part in parts.values():
		part.reset()
	for idx in outputs.size():
		if outputs[idx].part_type == "TriState":
			pins[[RIGHT, idx]] = -INF
	# Output pins of input parts need to be null
	# so that they react to outer parts
	for input in inputs:
		input.pins = {}


func unstable_handler(_name, side, port):
	controller.unstable_handler(name + ":" + _name, side, port)


func compare_offsets(a, b):
		return Vector2(a.offset[0], a.offset[1]).length() < Vector2(b.offset[0], b.offset[1]).length()
