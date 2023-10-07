class_name Part

# This is the base class for Parts

extends GraphNode

enum { LEFT, RIGHT }
enum { WIRE_TYPE, BUS_TYPE }
enum { I_O, GATE, CHIP, MISC, BLOCK }

# This is based on the number of bits that may change per update of the value.
# The value is applied bit by bit so a stable state is reached after all of
# the bit levels have been applied.
# Using a high threshold should be faster than introducing delays in the part
# outputs.
const RACE_COUNT_THRESHOLD = 256

# Part properties
var tag = ""
var part_type = ""
var category = GATE
var data = {}
var node_name = "temp"
var show_display = true
var controller # The schematic or a parent block
var race_counter = {} # [side, port]: count
var pins = {} # [side, port]: level / value

var change_notification_timer: Timer

func _ready():
	connect("gui_input", _on_gui_input)
	if $Tag.visible:
		$Tag.connect("text_changed", _on_tag_text_changed)
	change_notification_timer = Timer.new()
	get_child(0).add_child(change_notification_timer)
	change_notification_timer.one_shot = true
	change_notification_timer.connect("timeout", _on_change_notification_timer_timeout)


func clear():
	controller = null
	race_counter = {}
	pins = {}


func update_input_level(side, port, level):
	prints("part update_input_level", self.name, side, port, level)
	var key = set_pin_value(side, port, level)
	if key != null:
		if race_counter.has(key):
			race_counter[key] += 1
			if race_counter[key] == RACE_COUNT_THRESHOLD:
				controller.unstable_handler(name, side, port)
				return
		else:
			race_counter[key] = 1
		evaluate_output_level(side, port, level)


func set_pin_value(side, port, value):
	# value will be an int or a bool to handle a wire or a bus
	# The function returns null if there was no change or the pin key
	# This makes it easy to emit a signal or not to indicate a change
	var key = [side, port]
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
	prints("part evaluate_output_level", self.name, side, port, level)
	# Put logic here to derive the new level
	side = (side + 1) % 2 # Used with IO part to alternate sides
	update_output_level(side, port, level)


func update_output_level(side, port, level):
	prints("part update_output_level", self.name, side, port, level)
	if set_pin_value(side, port, level) != null:
		controller.output_level_changed_handler(self, side, port, level)


# Override this function in extended parts
func evaluate_bus_output_value(side, port, value):
	# Put logic here to derive the new value
	side = (side + 1) % 2
	update_output_value(side, port, value)


func update_output_value(side, port, value):
	if set_pin_value(side, port, value) != null:
		controller.bus_value_changed_handler(self, side, port, value)


# Override this function for custom setup of the Part when it is loaded into the Schematic
func setup():
	pass


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
