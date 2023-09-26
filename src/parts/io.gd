class_name IO

# It has 1 bus and 1 or more wires.
# When selected, the part will be connected to a UI control panel for configuring the part
# and adjusting the value.
# The wires and bus are synced to the same value of bits and integer.
# When setting the value externally, the output is emitted from both sides.
# The data flow is bidirectional.
# The external value setting feature has no meaning when the part is inside a block.
# The display value may be edited by the user to set the value. Also, this value
# is updated when the input on either side changes.
# The display may be made visible in blocks depending on settings.

extends Part

var max_value = 0xffff
var format = "0x%02X"
var num_wires

func _ready():
	#test_set_pins() # Done visually when running the scene.
	$Value.connect("text_submitted", _on_text_submitted)


func set_pins(labels: Array):
	num_wires = get_child_count() - 3
	var to_add = labels.size() - num_wires
	if to_add > 0:
		for n in to_add:
			var wire = $Wire1.duplicate()
			wire.name = "Wire" + str(n + 2)
			add_child(wire)
		# Move Tag to the end
		var tag_node = $Tag
		remove_child(tag_node)
		add_child(tag_node)
	if to_add < 0:
		for n in -to_add:
			get_child(-2 - n).queue_free()
	for n in labels.size():
		get_child(2 + n).get_child(0).text = labels[n]
		set_slot_enabled_left(n + 2, true)
		set_slot_enabled_right(n + 2, true)


func _on_text_submitted(new_text):
	var value = 0
	if new_text.is_valid_integer():
		value = int(new_text)
	if new_text.is_valid_hex_number(true):
		value = new_text.hex_to_int()
	$Value.caret_position = 8
	update_output_levels_from_value([0, 1], int(clamp(value, 0, max_value)))
	update_output_value(0, 2, value)
	update_output_value(1, 2, value)


func update_output_levels_from_value(sides: Array, value: int):
	for n in num_wires:
		var level = bool(value % 2)
		value /= 2
		for side in sides:
			update_output_level(side, n + 3, level)


func set_display_value(value):
	$Value.text = format % [value]


func evaluate_output_level(side, port, level):
	super(side, port, level)
	var value = 0
	for n in num_wires:
		value *= 2
		value += int(pins.get([side, num_wires + 2 - n], false))
	evaluate_bus_output_value(side, 2, value, false)


func evaluate_bus_output_value(side, port, value, update_levels = true):
	super(side, port, value)
	# A speed optimization could be to not call this unless there are wire connections.
	if update_levels:
		update_output_levels_from_value([(side + 1) % 2], value)
	if show_display:
		set_display_value(value)


func test_set_pins():
	await get_tree().create_timer(1.0).timeout
	set_pins(["data","a","b","c","d"])
	await get_tree().create_timer(1.0).timeout
	set_pins(["DIO","x","The yellow tail"])
