class_name Block

# This Part allows for loading a circuit as a Block
# Then a part is created with inputs and outputs derived from the IO parts of the circuit.
# And the circuit within a block may also contain blocks.

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
var wire_color = Color.WHITE
var bus_color = Color.YELLOW
var memory

func _init():
	data = { "circuit_file": "", "wiring_hash": 0 }


func _ready():
	super() # It's easy to forget to call the parent _ready code to add the Tag etc.
	block_setup([G.settings.current_file])
	set_slots(max(input_pin_count, output_pin_count) - 1)
	configure_pins()
	reset()


func has_bad_hash():
	var current_hash = (input_map + output_map).hash()
	if current_hash != data.wiring_hash:
		data.wiring_hash = current_hash
		return true
	return false


func block_setup(_files):
	circuit = Circuit.new()
	if _files.has(data.circuit_file.get_file()):
		G.warning.open("Detected that %s is nested inside itself!" % [data.circuit_file.get_file()])
		return
	# Add the file name to the list of files to detect.
	# Ignore the path, this allows for files to be moved and can compare to current file.
	# Downside is that blocks must have unique names.
	var files = _files + [data.circuit_file.get_file()]
	var load_result = circuit.load_data(data.circuit_file)
	if load_result != OK:
		G.warning.open("The circuit block data from %s was invalid!" % [data.circuit_file.get_file()])
		return
	# Every circuit opened as a block is added to the available parts list
	var cname = circuit.data.title
	if cname.is_empty():
		# Use the file name without the extension
		cname = data.circuit_file.get_file().get_slice('.', 0)
	# If this is the top-level block and Tag is empty set it to cname
	if files.size() == 2 and $Tag.text.is_empty():
		$Tag.text = cname
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
	if data.get("wiring_hash", 0) == 0: # Set this for new blocks
		data.wiring_hash = (input_map + output_map).hash()
	add_parts(files)


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
	# If there are no wires connected to the part input then it is an input to the circuit.data
	for con in circuit.data.connections:
		if con.to_node == part.node_name:
			return false
	return true


func is_output(part):
	# If there are no wires connected to the part output then it is an output to the circuit.data
	for con in circuit.data.connections:
		if con.from_node == part.node_name:
			return false
	return true


func add_parts(files):
	for node in circuit.data.parts:
		var part = Parts.get_instance(node.part_type)
		part.tag = node.tag
		part.part_type = node.part_type
		part.data = node.data
		if part.part_type == "RAM":
			memory = part
		# Part instances have a name but circuit.data.parts store the name as node_name
		part.name = node.node_name
		part.show_display = false
		part.controller = self
		part.setup_instance()
		ConnectionSorter.set_part_outputs(part, circuit.data.connections)
		if part.part_type == "Block":
			part.block_setup(files)
		parts[part.name] = part


# Map external input to internal IO part
func evaluate_output_level(port: int, level):
	var map = input_map[port]
	var part = parts[map[PART]]
	part.update_output_level(map[PORT], level)
	if part.part_type == "IO":
		# Update the bus
		var value = 0
		for n in part.data.num_wires:
			value *= 2
			value += int(part.pins.get([LEFT, int(part.data.num_wires - n)], false))
		part.evaluate_bus_output_value(value, false)


# Map external bus input to internal part
func evaluate_bus_output_value(port: int, value: int, update_levels = true):
	var map = input_map[port]
	var part = parts[map[PART]]
	part.update_output_value(map[PORT], value)
	if update_levels and part.part_type == "IO":
		# This will ignore (clip) value bits above the range that the wires cover
		for n in part.data.num_wires:
			var level = bool(value % 2)
			value /= 2
			part.update_output_level(n + 1, level)


func output_level_changed_handler(part, port: int, level):
	var map_idx = [str(part.name), port] # part.name seems to be a pointer to a string
	var port_idx = output_map.find(map_idx)
	if port_idx > -1:
		pins[[RIGHT, port_idx]] = level
		controller.output_level_changed_handler(self, port_idx, level)
	else:
		for con in part.connections:
			if con.from_port == port:
				parts[con.to_node].update_input_level(con.to_port, level)


func bus_value_changed_handler(part, port: int, value: int):
	var map_idx = [str(part.name), port]
	var port_idx = output_map.find(map_idx)
	if port_idx > -1:
		pins[[RIGHT, port_idx]] = value
		controller.bus_value_changed_handler(self, port_idx, value)
		if part is IO:
			for n in part.data.num_wires:
				port_idx += 1
				var level = value % 2 == 1
				value /= 2
				pins[[RIGHT, port_idx]] = level
				controller.output_level_changed_handler(self, port_idx, level)
	else:
		for con in part.connections:
			if con.from_port == port:
				parts[con.to_node].update_bus_input_value(con.to_port, value)


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


func unstable_handler(_name, port):
	controller.unstable_handler(name + ":" + _name, port)


func compare_offsets(a, b):
		return Vector2(a.offset[0], a.offset[1]).length() < Vector2(b.offset[0], b.offset[1]).length()
