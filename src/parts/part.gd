class_name Part

# This is the base class for Parts

extends GraphNode

signal output_level_changed(part, side, port, level)
signal bus_value_changed(part, side, port, value)
signal removing_slot(part, port)
signal right_click_on_part(part)
signal reset_race_counters()

# Indicate unstable wire and stop flow of level or value
signal unstable(part, side, port)

enum { LEFT, RIGHT }
enum { WIRE_TYPE, BUS_TYPE }

# Part properties
var tag = ""
var part_type = ""
var data = {}
var node_name = "temp"
var show_display = true

var race_counter = {} # [side, port]: count
var pins = {} # [side, port]: level / value

func _ready():
	connect("gui_input", _on_gui_input)


func update_input_level(side, port, level):
	var nom = name
	prints("update_input_level", nom, side, port, level)
	var key = set_pin_value(side, port, level)
	if key != null:
		if race_counter.has(key):
			race_counter[key] += 1
			if race_counter[key] == 2:
				emit_signal("unstable", name, side, port)
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
	var nom = name
	prints("update_bus_input_value", nom, side, port, value)
	if set_pin_value(side, port, value) != null:
		evaluate_bus_output_value(side, port, value)


# Override this function in extended parts
func evaluate_output_level(side, port, level):
	# Put logic here to derive the new level
	side = (side + 1) % 2 # Used with IO part to alternate sides
	update_output_level(side, port, level)


func update_output_level(side, port, level):
	if set_pin_value(side, port, level) != null:
		emit_signal("output_level_changed", self, side, port, level)


# Override this function in extended parts
func evaluate_bus_output_value(side, port, value):
	# Put logic here to derive the new value
	side = (side + 1) % 2
	update_output_value(side, port, value)


func update_output_value(side, port, value):
	if set_pin_value(side, port, value) != null:
		emit_signal("bus_value_changed", self, side, port, value)


# Override this function for custom setup of the Part when it is loaded into the Schematic
func setup():
	pass


# We can trigger opening of PopUp windows using this after a user right-clicks on a part
func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			emit_signal("right_click_on_part", self)
