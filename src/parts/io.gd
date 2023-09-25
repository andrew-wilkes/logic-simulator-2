class_name IO

extends Part

var max_value = 0xffff
var format = "0x%02X"
var num_wires

func _ready():
	#test_set_pins()
	$Value.connect("text_submitted", _on_text_entered)


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


func _on_text_entered(new_text):
	var value = 0
	if new_text.is_valid_integer():
		value = int(new_text)
	if new_text.is_valid_hex_number(true):
		value = new_text.hex_to_int()
	$Value.caret_position = 8
	output_value_and_levels(int(clamp(value, 0, max_value)))


func output_value_and_levels(value):
	update_output_value(1, 2, value)
	for n in num_wires:
		var level = bool(value % 2)
		value /= 2
		update_output_level(1, n + 3, level)


func set_display_value(value):
	$Value.text = format % [value]


func test_set_pins():
	await get_tree().create_timer(1.0).timeout
	set_pins(["data","a","b","c","d"])
	await get_tree().create_timer(1.0).timeout
	set_pins(["DIO","x","The yellow tail"])
