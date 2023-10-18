class_name TestCircuit

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
	
	# Get the output pin names of interest
	var tokens = output_format.split(" ", false)
	var output_pins = []
	var output_formats = []
	for token in tokens:
		var pf = token.split("%") # [pin_name, format]
		output_pins.append(pf[0])
		output_formats.append(pf[1])
	
	var output = get_output_header(output_pins, output_formats)

	# Get the test specifications
	var tests = []
	while true:
		start = spec.find("set", end)
		if start < 0: # Ends the parsing while loop
			break
		end = spec.find(";", start)
		if end < 0: # This should not occur
			break
		tests.append(spec.substr(start, end - start).replace(" ", "").replace("\n", ""))
	
	# Run the tests
	var results = []
	for test in tests:
		var pin_values = []
		var steps = test.split(",", false)
		for step in steps:
			tokens = step.split(" ", false)
			if tokens.size() > 0:
				match tokens[0]:
					"set":
						# Apply input levels and values to the parts
						tokens.resize(3)
						var pin_name = tokens[1]
						var value = int(tokens[2])
						pin_values.append(value)
						if inputs.has(pin_name):
							var target = inputs[pin_name] # [part, port, port_type]
							if target[2] == 0: # Wire
								target[0].update_input_level(0, target[1], value == "1")
							else: #Bus
								target[0].update_bus_input_value(0, target[1], value)
					"eval":
						# Get the required outputs from the parts
						for pin in output_pins:
							if outputs.has(pin):
								var target = outputs[pin]
								var pin_key = [1, target[1]] # [side, port]
								# Cast bools to int and set the value to 0 if the pin has not been touched
								pin_values.append(int(target[0].pins.get(pin_key, 0)))
							else:
								# Even if the pin is not found, add zero as the result value
								pin_values.append(0)
						results.append(pin_values)
					"output":
						get_output_results(output, results, output_formats)
	return output


func get_output_header(output_pins, output_formats):
	# Form the top line like: |   a   |   b   | out |
	var output = "|"
	for idx in output_pins.size():
		var widths = output_formats[idx].right(-1).split(".")
		widths.resize(3) # There should be 3 values: PadL.Length.PadR
		# Center align the pin name
		var min_length = int(widths[0]) + int(widths[1]) + int(widths[2])
		var pin_name = output_pins[idx]
		pin_name = pin_name.lpad((min_length + pin_name.length()) / 2, " ")
		output += pin_name.rpad(min_length, " ") + "|"
	return output + "\n"


func get_output_results(output, results, output_formats):
	# Add the result lines to output
	for result in results:
		output += "|"
		for idx in output_formats.size():
			# Format string: (S|B|D|X)PadL.Length.PadR
			var format = output_formats[idx]
			if format.length() == 0:
				format = "B1.1.1" # Default value
			var widths = format.right(-1).split(".")
			widths.resize(3) # There should be 3 values: PadL.Length.PadR
			var value = format_value(int(result[idx]), format[0], int(widths[1]))
			output += value.lpad(int(widths[0]) + value.length()) + " ".repeat(int(widths[2])) + "|"
		output += "\n"
	return output


func format_value(value, format, width):
	match format:
		"S", "D":
			value = str(value).rpad(width, " ")
		"X":
			format =  "%0" + str(width) + "X"
			value = format % [value]
		"B":
			var bits = PackedStringArray()
			for n in width:
				if value % 2:
					bits.append("1")
				else:
					bits.append("0")
				value /= 2
			bits.reverse()
			value = "".join(bits)
	return value
