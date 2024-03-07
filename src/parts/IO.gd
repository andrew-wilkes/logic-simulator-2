class_name IO

# It has 1 bus and 1 or more wires.
# Selected parts may be controlled and configured via a IO Manager panel.
# The wires and bus are synced to the same value of bits and integer.
# When setting the value externally, the output is emitted from both sides.
# The data flow is bidirectional.
# The external value setting feature has no meaning when the part is inside a block.
# The display value may be edited by the user to set the value. Also, this value
# is updated when the input on either side changes.
# The display may be made visible in blocks depending on settings.

extends Part

var current_value := 0 # This is accessed by the IO Manager panel
var level_outputs = []
var data_received := 0

func _init():
	data = {
		"num_wires": 1,
		"bus_color": "ffff00ff",
		"wire_color": "ffffffff",
		"labels": ["- Data -", "- D0 -"],
		"range": 0xff
	}
	category = UTILITY
	order = 100


func _ready():
	super()
	if show_display:
		display_update_timer = Timer.new()
		get_child(-1).add_child(display_update_timer)
		display_update_timer.timeout.connect(update_display)
		display_update_timer.start(0.1)
	if get_parent().name == "root":
		test_set_pins() # Done visually when running the scene.


func setup():
	set_pins()


func set_level_outputs():
	for idx in level_outputs.size():
		level_outputs[idx].free()
	level_outputs.resize(data.num_wires + 1)
	for idx in level_outputs.size():
		var cin = CircuitInput.new()
		cin.name = name
		cin.port = idx
		if idx < 1:
			cin.is_bus = true
		level_outputs[idx] = cin


func set_pins():
	# num_wires == number of bits, the bus is seperate
	var num_wires = get_input_port_count() - 1
	var to_add = data.num_wires - num_wires
	if to_add > 0:
		for n in to_add:
			var wire = $Wire1.duplicate()
			add_child(wire)
		# Move Tag to the end
		var tag_node = $Tag
		remove_child(tag_node)
		add_child(tag_node)
	if to_add < 0:
		for n in -to_add:
			controller.removing_slot(self, num_wires - n)
			get_child(-2).queue_free()
			remove_child(get_child(-2))
	await get_tree().process_frame
	set_pin_colors()
	set_labels()
	set_level_outputs()
	# Shrinking leaves a gap at the bottom
	size = Vector2.ZERO # Fit to the new size automatically


func set_labels():
	for n in data.labels.size():
		if n > data.num_wires:
			break
		get_child(n - data.num_wires - 2).text = data.labels[n]


func set_pin_colors():
	var is_wire = false
	var idx = 0
	for node in get_children():
		if node is Label:
			set_slot_enabled_left(idx, true)
			set_slot_enabled_right(idx, true)
			if is_wire:
				set_slot_color_left(idx, data.wire_color)
				set_slot_color_right(idx, data.wire_color)
			else:
				set_slot_color_left(idx, data.bus_color)
				set_slot_color_right(idx, data.bus_color)
				is_wire = true
		if node.name == "Tag":
			set_slot_enabled_left(idx, false)
			set_slot_enabled_right(idx, false)
		idx += 1


func value_changed(value):
	current_value = value
	update_output_levels_from_value(value, false)
	var cin = level_outputs[0]
	cin.value = value
	controller.inject_circuit_input(cin)


func update_output_levels_from_value(value: int, internal: bool):
	# This will ignore (clip) value bits above the range that the wires cover
	for n in data.num_wires:
		var level = bool(value % 2)
		value /= 2
		if internal:
			update_output_level(n + 1, level)
		else:
			var cin = level_outputs[n + 1]
			cin.level = level
			controller.inject_circuit_input(cin)


func evaluate_output_level(port, level):
	super(port, level)
	var value = 0
	for n in data.num_wires:
		value *= 2
		value += int(pins.get([LEFT, int(data.num_wires - n)], false))
	data_received = true
	evaluate_bus_output_value(0, value, false)


func evaluate_bus_output_value(port, value, update_levels = true):
	super(port, value)
	# A speed optimization could be to not call this unless there are wire connections.
	if update_levels:
		update_output_levels_from_value(value, true)
		data_received = true
	current_value = value


func test_set_pins():
	await get_tree().create_timer(1.0).timeout
	data.num_wires = 4
	data.labels = ["data","a","b","c","d"]
	set_pins()
	await get_tree().create_timer(1.0).timeout
	data.num_wires = 2
	data.labels = ["DIO","x","The yellow tail"]
	set_pins()


func reset():
	super()
	if show_display:
		value_changed(0)


func apply_power():
	pins = { [RIGHT, OUT]: 0 }
	for n in data.num_wires:
		pins[[RIGHT, n + 1]] = false


func update_display():
	if data_received:
		$Value.display_value(current_value, true, true)
		data_received = false


func _on_tree_exiting():
	for cin in level_outputs:
		cin.free()

