extends Part

class_name Block

# The data should contain the path to a circuit file

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
	# Identify IO parts
	# Add pins and labels
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
		set_slot_type_left(slot_idx, 1)
		set_slot_color_left(slot_idx, input.data.bus_color)
		get_child(slot_idx).get_child(0).text = input.data.labels[label_idx]
		for n in input.data.num_wires:
			slot_idx += 1
			label_idx += 1
			get_child(slot_idx).get_child(0).text = input.data.labels[label_idx]
			set_slot_enabled_left(slot_idx, true)
			set_slot_type_left(slot_idx, 0)
			set_slot_color_left(slot_idx, input.data.wire_color)
		slot_idx += 1
	slot_idx = 1
	for output in outputs:
		var label_idx = 0
		set_slot_enabled_right(slot_idx, true)
		set_slot_type_right(slot_idx, 1)
		set_slot_color_right(slot_idx, output.data.bus_color)
		get_child(slot_idx).get_child(1).text = output.data.labels[label_idx]
		for n in output.data.num_wires:
			slot_idx += 1
			label_idx += 1
			get_child(slot_idx).get_child(1).text = output.data.labels[label_idx]
			set_slot_enabled_right(slot_idx, true)
			set_slot_type_right(slot_idx, 0)
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
			get_child(-2 - n).queue_free()
	# Shrinking leaves a gap at the bottom
	await get_tree().create_timer(0.1).timeout
	resize_part()


func resize_part():
	size = Vector2.ZERO # Fit to the new size automatically


func add_parts():
	for node in circuit.parts:
		var part = Parts.get_instance(node.part_type)
		part.tag = node.tag
		part.part_type = node.part_type
		part.data = node.data
		part.name = node.node_name
		parts[part.name] = part
