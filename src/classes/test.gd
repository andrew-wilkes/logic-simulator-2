class_name Test

# This class is used to test cicuits
# Tests are described in .tst files in the www.nand2tetris.org format

extends Node

func get_io_nodes(parts, connections):
	# Inputs are unconnected pins on the left side of parts
	# Outputs are unconnected pins on the right side of parts
	var inputs = {}
	var outputs = {}
	for part in parts:
		var num_inputs = part.get_connection_input_count()
		var used_ports = []
		for con in connections:
			if con.to == part.name:
				used_ports.append(con.to_port)
		for port in num_inputs:
			if used_ports.has(port):
				continue
			var type = part.get_connection_input_type(port)
			inputs[get_label_text(part, 0, port)] = [part, port, type]
		
		var num_outputs = part.get_connection_input_count()
		used_ports = []
		for con in connections:
			if con.from == part.name:
				used_ports.append(con.from_port)
		for port in num_outputs:
			if used_ports.has(port):
				continue
			outputs[get_label_text(part, 1, port)] = [part, port]
	return [inputs, outputs]


func get_label_text(part, side, port):
	var node = part.get_child(part.get_connection_input_slot(port))
	if not node is Label:
		node = node.get_child(side)
	return node.text


# Parse a .tst file
func run_tests(spec: String, inputs, outputs):
	# Get output list format
	var start = spec.find("output-list")
	var end = spec.find(";", start)
	var output_format = spec.substr(start + 12, end - start - 12)
	var tokens = output_format.split(" ", false)
	
	var output_pins = []
	for token in tokens:
		output_pins.append(token.split("%")[0])

	# Get the tests
	var tests = []
	while true:
		start = spec.find("set", end)
		if start < 0:
			break
		end = spec.find(";", start)
		if end < 0: # This should not occur
			break
		tests.append(spec.substr(start, end - start).replace(" ", "").replace("\n", ""))
	
	# Run the tests
	var output_values = []
	for test in tests:
		var steps = test.split(",", false)
		for step in steps:
			tokens = step.split(" ", false)
			if tokens.size() > 0:
				match tokens[0]:
					"set":
						if tokens.size() == 3:
							if inputs.has(tokens[1]): # pin name
								var target = inputs[tokens[1]] # [part, port, port_type]
								if target[2] == 0:
									target[0].update_input_level(0, target[1], tokens[2] == "1")
								else:
									target[0].update_bus_input_value(0, target[1], int(tokens[2]))
					"eval":
						# Get the required outputs
						for pin in output_pins:
							if outputs.has(pin):
								var target = outputs[pin]
								var pin_key = [1, target[1]]
								output_values.append(int(target[0].pins.get(pin_key, 0)))
							else:
								output_values.append(0)
					"output":
						pass # Add the output text to the result
