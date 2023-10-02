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

var circuit: Circuit
var parts = {}
var input_map = []
var output_map = []

func _init():
	data = {
	"circuit_file": ""
}


func _ready():
	circuit = Circuit.new().load_data(data.circuit_file)
	var input_pin_count = 0
	var output_pin_count = 0
	var inputs = []
	var outputs = []
	for part in circuit.parts:
		if part is IO:
			if is_input(part):
				inputs.append(part)
				input_pin_count += part.data.num_wires + 1
			else:
				outputs.append(part)
				output_pin_count += part.data.num_wires + 1
	set_slots(max(input_pin_count, output_pin_count))
	configure_pins(inputs, outputs)
	add_parts()
	# Create IO pin maps
	for io_part in inputs:
		# [part_name, port]
		input_map.append([io_part.node_name, 0])
		for n in io_part.data.num_wires:
			input_map.append([io_part.node_name, n + 1])
	for io_part in outputs:
		# [part_name, port]
		output_map.append([io_part.node_name, 0])
		for n in io_part.data.num_wires:
			output_map.append([io_part.node_name, n + 1])
	print(input_map)
	print(output_map)


func configure_pins(inputs, outputs):
	clear_all_slots()
	var slot_idx = 1
	for input in inputs:
		var label_idx = 0
		set_slot_enabled_left(slot_idx, true)
		set_slot_type_left(slot_idx, BUS_TYPE)
		set_slot_color_left(slot_idx, input.data.bus_color)
		get_child(slot_idx).get_child(0).text = input.data.labels[label_idx]
		for n in input.data.num_wires:
			slot_idx += 1
			label_idx += 1
			get_child(slot_idx).get_child(0).text = input.data.labels[label_idx]
			set_slot_enabled_left(slot_idx, true)
			set_slot_type_left(slot_idx, WIRE_TYPE)
			set_slot_color_left(slot_idx, input.data.wire_color)
		slot_idx += 1
	slot_idx = 1
	for output in outputs:
		var label_idx = 0
		set_slot_enabled_right(slot_idx, true)
		set_slot_type_right(slot_idx, BUS_TYPE)
		set_slot_color_right(slot_idx, output.data.bus_color)
		get_child(slot_idx).get_child(1).text = output.data.labels[label_idx]
		for n in output.data.num_wires:
			slot_idx += 1
			label_idx += 1
			get_child(slot_idx).get_child(1).text = output.data.labels[label_idx]
			set_slot_enabled_right(slot_idx, true)
			set_slot_type_right(slot_idx, WIRE_TYPE)
			set_slot_color_right(slot_idx, output.data.wire_color)
		slot_idx += 1


func is_input(part):
	# If there are no wires connected to the part, then it is an input to the circuit
	for con in circuit.connections:
		if con.to == part.node_name:
			return false
	return true


func set_slots(num_slots):
	var num_pins = get_child_count() - 2
	var to_add = num_slots - num_pins
	if to_add > 0:
		for n in to_add:
			var slot = $Slot1.duplicate()
			slot.name = "Slot" + str(n + 2)
			add_child(slot)
		# Move Tag to the end
		var tag_node = $Tag
		remove_child(tag_node)
		add_child(tag_node)
	if to_add < 0:
		for n in -to_add:
			var node_to_remove = get_child(-2 - n)
			remove_child(node_to_remove)
			node_to_remove.queue_free()
	# Shrinking leaves a gap at the bottom
	size = Vector2.ZERO # Fit to the new size automatically


func add_parts():
	for node in circuit.parts:
		var part = Parts.get_instance(node.part_type)
		part.tag = node.tag
		part.part_type = node.part_type
		part.data = node.data
		part.name = node.node_name
		part.node_name = node.node_name # Useful for debugging
		part.show_display = false
		part.connect("output_level_changed", output_level_changed_handler)
		part.connect("bus_value_changed", bus_value_changed_handler)
		parts[part.name] = part


func get_map(side, port):
	return input_map[port] if side == LEFT else output_map[port]


# Map external input to internal part
func evaluate_output_level(side, port, level):
	prints("block evaluate_output_level", self.name, side, port, level)
	var map = get_map(side, port)
	parts[map[PART]].update_output_level(side, map[PORT], level)


# Map external bus input to internal part
func evaluate_bus_output_value(side, port, value):
	var map = get_map(side, port)
	side = (side + 1) % 2 # Flip the side to the output side
	parts[map[PART]].update_output_value(side, map[PORT], value)


func output_level_changed_handler(part, side, port, level):
	prints("block output_level_changed_handler", part.name, side, port, level)
	var map_idx = [part.name, port]
	var port_idx = [output_map, input_map][side].find(map_idx)
	if port_idx > -1:
		emit_signal("output_level_changed", self, side, port_idx, level)
	else:
		update_internal_input_level(part, side, port, level)


func update_internal_input_level(part, side, port, level):
	prints("block update_internal_input_level", part.name, side, port, level)
	for con in circuit.connections:
		if side == RIGHT:
			if con.from == part.name and con.from_port == port:
				parts[con.to].update_input_level(LEFT, con.to_port, level)
		else:
			if con.to == part.name and con.to_port == port:
				parts[con.from].update_input_level(RIGHT, con.from_port, level)


func bus_value_changed_handler(part, side, port, value):
	var map_idx = [part.name, port]
	var port_idx = [input_map, output_map][side].find(map_idx)
	if port_idx > -1:
		emit_signal("bus_value_changed", self, side, port_idx, value)
	else:
		update_internal_bus_input_value(part, side, port, value)


func update_internal_bus_input_value(part, side, port, value):
	for con in circuit.connections:
		if side == RIGHT:
			if con.from == part.name and con.from_port == port:
				parts[con.to].update_bus_input_value(LEFT, con.to_port, value)
		else:
			if con.to == part.name and con.to_port == port:
				parts[con.from].update_bus_input_value(RIGHT, con.from_port, value)


func reset_block_race_counters():
	for part in parts:
		if part is Block:
			part.reset_block_race_counters()
