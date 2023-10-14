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

var format = "0x%02X"
var current_value = 0 # This is accessed by the IO Manager panel

func _init():
	data = {
		"num_wires": 1,
		"bus_color": 0xffff00ff,
		"wire_color": 0xffffffff,
		"labels": ["- Data -", "- D0 -"],
		"range": 0xff
	}
	category = MISC
	order = 100


func _ready():
	super()
	if get_parent().name == "root":
		test_set_pins() # Done visually when running the scene.
	$Value.connect("text_submitted", _on_text_submitted)
	bug_fix() # Godot 4.1.stable


func bug_fix():
	for node in get_children():
		if node is LineEdit and node.name != "Tag" and node.name != "Value":
			remove_child(node)
			node.queue_free()


func setup():
	set_pins()


func set_pins():
	# num_wires == number of bits, the bus is seperate
	var num_wires = get_child_count() - 4
	var to_add = data.num_wires - num_wires
	if to_add > 0:
		for n in to_add:
			var wire = $Wire1.duplicate()
			add_child(wire)
			wire.name = "Wire" + str(n + 2)
		# Move Tag to the end
		var tag_node = $Tag
		remove_child(tag_node)
		add_child(tag_node)
	if to_add < 0:
		for n in -to_add:
			controller.removing_slot(self, num_wires - n)
			get_child(-2).queue_free()
			remove_child(get_child(-2))
	set_pin_colors()
	set_labels()
	# Shrinking leaves a gap at the bottom
	size = Vector2.ZERO # Fit to the new size automatically


func set_labels():
	for n in data.labels.size():
		if n > data.num_wires:
			break
		get_child(2 + n).get_child(0).text = data.labels[n]


func set_pin_colors():
	for idx in range(2, data.num_wires + 3):
		set_slot_enabled_left(idx, true)
		set_slot_enabled_right(idx, true)
		if idx > 2:
			set_slot_color_left(idx, Color.hex(data.wire_color))
			set_slot_color_right(idx, Color.hex(data.wire_color))
		else:
			set_slot_color_left(idx, Color.hex(data.bus_color))
			set_slot_color_right(idx, Color.hex(data.bus_color))
	# Ensure that the Tag doesn't have pins
	# !!! Check if this is related to the extra Tag bug !!!
	set_slot_enabled_left(data.num_wires + 3, false)
	set_slot_enabled_right(data.num_wires + 3, false)


func _on_text_submitted(new_text):
	var value = 0
	if new_text.is_valid_int():
		value = int(new_text)
	if new_text.is_valid_hex_number(true):
		value = new_text.hex_to_int()
	# This formats the value as well as updating it from the IO panel
	set_display_value(value)
	current_value = value
	# The change may propagate before the race reset has occurred,
	# so the threshold value may need to be increased
	controller.reset_race_counters()
	update_output_levels_from_value([0, 1], value)
	update_output_value(0, 0, value)
	update_output_value(1, 0, value)


func update_output_levels_from_value(sides: Array, value: int):
	# This will ignore (clip) value bits above the range that the wires cover
	for n in data.num_wires:
		var level = bool(value % 2)
		value /= 2
		for side in sides:
			update_output_level(side, n + 1, level)


func set_display_value(value):
	$Value.text = format % [value]
	# The following line avoids the caret blinking at the start of the text
	$Value.caret_column = $Value.text.length()


func evaluate_output_level(side, port, level):
	super(side, port, level)
	var value = 0
	for n in data.num_wires:
		value *= 2
		value += int(pins.get([side, int(data.num_wires - n)], false))
	evaluate_bus_output_value(side, 0, value, false)


func evaluate_bus_output_value(side, port, value, update_levels = true):
	super(side, port, value)
	# A speed optimization could be to not call this unless there are wire connections.
	if update_levels:
		update_output_levels_from_value([(side + 1) % 2], value)
	if show_display:
		set_display_value(value)
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
