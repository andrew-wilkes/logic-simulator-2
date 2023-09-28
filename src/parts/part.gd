class_name Part

# This is the base class for Parts

extends GraphNode

signal output_level_changed(part, side, port, level)
signal bus_value_changed(part, side, port, value)

# Indicate unstable wire and stop flow of level or value
signal unstable(part, side, port)

enum { LEFT, RIGHT }

# Part properties
var tag = ""
var part_type = ""
var data = {}
var node_name = "temp"
var show_display = true

var race_counter = {} # [side, port]: count
var pins = {} # [side, port]: level / value

func update_input_level(side, port, level):
	var key = set_pin_value(side, port, level)
	if key != null:
		if race_counter.has(key):
			race_counter[key] += 1
			if race_counter[key] == 2:
				emit_signal("unstable", self, side, port)
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


func reset_race_counter():
	for key in race_counter:
		race_counter[key] = 0


# Override this function in extended parts
func evaluate_output_level(side, port, level):
	# Logic to derive the new level
	side = (side + 1) % 2 # Used with IO part to alternate sides
	update_output_level(side, port, level)


func update_output_level(side, port, level):
	if set_pin_value(side, port, level) != null:
		emit_signal("output_level_changed", self, side, port, level)


# Override this function in extended parts
func evaluate_bus_output_value(side, port, value):
	# Logic to derive the new value
	side = (side + 1) % 2
	update_output_value(side, port, value)


func update_output_value(side, port, value):
	if set_pin_value(side, port, value) != null:
		emit_signal("bus_value_changed", self, side, port, value)


# Override this function for custom setup of the Part when it is loaded into the Schematic
func setup():
	pass
