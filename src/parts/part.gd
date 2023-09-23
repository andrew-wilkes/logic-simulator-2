class_name Part

# This is the base class for Parts

extends GraphNode

signal output_level_changed(part, side, port, level)
signal bus_value_changed(part, side, port, value)

# Indicate unstable wire and stop flow
signal unstable(part, side, port)

enum { LEFT, RIGHT }

# Part properties
var tag = ""
var part_type = 0
var data = {}
var node_name = "temp"

var race_counter = {} # [side, port]: count
var pins = {} # [side, port]: level / value

func update_input_level(side, port, level):
	var key = [side, port]
	if not pins.has(key):
		pins[key] = not level
	if level != pins[key]:
		pins[key] = level
		if race_counter.has(key):
			race_counter[key] += 1
			if race_counter[key] == 2:
				emit_signal("unstable", self, side, port)
				return
		else:
			race_counter[key] = 0
		evaluate_output_level(side, port, level)


func update_bus_input_value(side, port, value):
	var key = [side, port]
	if not pins.has(key):
		pins[key] = value + 1
	if value != pins[key]:
		pins[key] = value
		evaluate_bus_output_value(side, port, value)


func reset_race_counter():
	for key in race_counter:
		race_counter[key] = 0


# Override these functions in extended parts
func evaluate_output_level(side, _port, level):
	emit_signal("output_level_changed", self, side, 1, level)


func evaluate_bus_output_value(side, _port, value):
	emit_signal("bus_value_changed", self, side, 2, value)
