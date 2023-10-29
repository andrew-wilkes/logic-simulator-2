class_name Part

# This is the base class for Parts

extends GraphNode

enum { LEFT, RIGHT }
enum { WIRE_TYPE, BUS_TYPE }
enum { UTILITY, ASYNC, SYNC, BLOCK }
enum { A,B,C,D }

# This is based on the number of bits that may change per update of the value.
# The value is applied bit by bit so a stable state is reached after all of
# the bit levels have been applied.
# Using a high threshold should be faster than introducing delays in the part
# outputs.
const RACE_COUNT_THRESHOLD = 128
const DEBUG = false
const FLIP_SIDES = [RIGHT, LEFT]
const IN = 0
const OUT = 0

# Part properties
var tag = ""
var part_type = ""
var category = ASYNC
var order = 0
var data = {}
var show_display = true
var controller # The schematic or a parent block
var race_counter = {} # [side, port]: count
var pins = {} # [side, port]: level / value
var connections = {} # Used with parts in blocks

var change_notification_timer: Timer

func get_dict():
	return {
		node_name = name,
		part_type = part_type,
		tag = get_node("Tag").text,
		show_display = show_display,
		offset = [position_offset.x, position_offset.y],
		data = data
	}


func _ready():
	connect("gui_input", _on_gui_input)
	if $Tag.visible:
		$Tag.connect("text_changed", _on_tag_text_changed)
	change_notification_timer = Timer.new()
	get_child(0).add_child(change_notification_timer)
	change_notification_timer.one_shot = true
	change_notification_timer.connect("timeout", _on_change_notification_timer_timeout)
	set("theme_override_constants/separation", 10)
	set("theme_override_constants/port_offset", -6)


func update_input_level(side, port, level):
	if DEBUG:
		prints("part update_input_level", self.name, side, port, level)
	var key = set_pin_value(side, port, level)
	if key != null:
		if race_counter.has(key):
			race_counter[key] += 1
			if race_counter[key] == RACE_COUNT_THRESHOLD:
				controller.unstable_handler(self, side, port)
				return
		else:
			race_counter[key] = 1
		evaluate_output_level(side, port, level)


func set_pin_value(side, port, value):
	# value will be an int or a bool to handle a wire or a bus
	# The function returns null if there was no change or the pin key
	# This makes it easy to ignore no change to the level/value
	var key = [side, int(port)]
	if not pins.has(key):
		pins[key] = null
	if value == pins[key]:
		key = null
	else:
		pins[key] = value
	return key


func update_bus_input_value(side, port, value):
	if set_pin_value(side, port, value) != null:
		evaluate_bus_output_value(side, port, value)


# Override this function in extended parts
func evaluate_output_level(side, port, level):
	if DEBUG:
		prints("part evaluate_output_level", self.name, side, port, level)
	# Put logic here to derive the new level
	update_output_level(FLIP_SIDES[side], port, level)


func update_output_level(side, port, level):
	if DEBUG:
		prints("part update_output_level", self.name, side, port, level)
	if set_pin_value(side, port, level) != null:
		controller.output_level_changed_handler(self, side, port, level)


# Override this function in extended parts
func evaluate_bus_output_value(side, port, value):
	# Put logic here to derive the new value
	update_output_value(FLIP_SIDES[side], port, value)


func update_output_value(side, port, value):
	if set_pin_value(side, port, value) != null:
		controller.bus_value_changed_handler(self, side, port, value)


# Override this function for custom setup of the Part when it is loaded into the Schematic
func setup():
	pass


func reset_race_counter():
	race_counter.clear()


# We can trigger opening of PopUp windows using this after a user right-clicks on a part
func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			controller.right_click_on_part(self)


func changed():
	change_notification_timer.start()


func _on_change_notification_timer_timeout():
	controller.emit_signal("changed")


func _on_tag_text_changed(_new_text):
	changed()


# Override this function to apply a reset to a part that has memory
func reset():
	pass
