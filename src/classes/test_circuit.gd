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
		if not part is Part:
			continue
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
		
		var num_outputs = part.get_connection_output_count()
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
	var slot = part.get_connection_input_slot(port) if side == 0 else \
		part.get_connection_output_slot(port)
	var node = part.get_child(slot)
	if not node is Label:
		node = node.get_child(side)
	return node.text


# Parse a .tst file
func run_tests(spec: String, inputs, outputs):
	var output = ""
	var output_format = ""
	var pin_states = {}
	var tasks = parse_spec(spec)

	# Process the tasks
	for task in tasks:
		match task[0]:
			"output-list":
				output_format = task[1]
				output = get_output_header(output_format)
			"set":
				# Apply input levels and values to the parts
				var pin_name = task[1]
				var value = get_int_from_string(task[2])
				pin_states[pin_name] = "-"
				if inputs.has(pin_name):
					pin_states[pin_name] = value
					var target = inputs[pin_name] # [part, port, port_type]
					if target[2] == 0: # Wire
						target[0].update_input_level(0, target[1], value == 1)
					else: #Bus
						target[0].update_bus_input_value(0, target[1], value)
			"eval":
				# Get the required outputs from the parts
				for pin in get_pin_list(tasks):
					if not pin_states.has(pin):
						pin_states[pin] = "-"
					if outputs.has(pin):
						var target = outputs[pin]
						var pin_key = [1, target[1]] # [side, port]
						# Cast bools to int and set the value to 0 if the pin has not been touched
						pin_states[pin] = int(target[0].pins.get(pin_key, 0))
			"output":
				output += get_output_result(pin_states, output_format)
	return output


func compare_pos(a, b):
	if a < 0:
		return false
	if b < 0:
		return true
	if a < b:
		return true


func get_closest_delimiter_position(text, from_idx, chars):
	var positions = []
	for chr in chars:
		positions.append(text.find(chr, from_idx)) # Appends -1 if not found
	positions.sort_custom(compare_pos)
	return positions[0]


# This function returns with whatever tasks it has listed so far if it hits something unexpected
func parse_spec(spec: String):
	var tasks = []
	# Convert spec to a string without comments or line breaks
	var lines = spec.replace("\r", "").split("\n", false)
	var clean_lines = []
	for line in lines:
		# Remove comments
		var pos = line.find("//")
		if pos >= 0:
			line = line.left(pos)
		clean_lines.append(line)
	spec = "".join(clean_lines)
	# Replace multiple spaces and tabs with 1 space
	var regex = RegEx.new()
	regex.compile("[\\s\t]+")
	spec = regex.sub(spec, " ", true)
	# Remove other types of comments
	regex.compile("/[\\*]{1,2}.+/")
	spec = regex.sub(spec, "", true)
	# Remove space between string and % since we split the formats based on a space between items
	regex.compile("\\s%")
	spec = regex.sub(spec, "%", true)
	
	var idx = 0
	while true:
		if idx >= spec.length():
			break
		# Get the shortest distance to the next delimiter from the start of the line
		var pos = get_closest_delimiter_position(spec, idx, " ,;")
		var token = spec.substr(idx, pos - idx)
		print(token)
		idx = pos + 1
		match token:
			"load", "output-file", "compare-to":
				# Find a string ending with , but allow for ;
				pos = get_closest_delimiter_position(spec, idx, ",;")
				if pos < 0:
					break # Syntax error
				tasks.append([token, spec.substr(idx, pos - idx)])
				idx = pos + 1
			"output-list":
				# Find a string ending with ; but allow for ,
				pos = get_closest_delimiter_position(spec, idx, ",;")
				if pos < 0:
					break # Syntax error
				tasks.append([token, spec.substr(idx, pos - idx)])
				idx = pos + 1
			"output", "eval":
				tasks.append([token])
			"set":
				# Find a string ending with , or ;
				pos = get_closest_delimiter_position(spec, idx, ",;")
				if pos < 0:
					break # Syntax error
				var task = [token] + Array(spec.substr(idx, pos - idx).split(" "))
				if task.size() != 3:
					break # Syntax error
				tasks.append(task)
				idx = pos + 1
			"repeat": # This needs more study to understand the syntax
				pos = spec.find(" ", idx)
				if pos < 0:
					break # Syntax error
				var reps = spec.substr(idx, pos - idx)
				if reps.is_valid_int():
					reps = int(reps)
					idx = pos + 1
					if spec[idx] != "{":
						break # Syntax error
					idx += 1
					pos = spec.find("}", idx)
					if pos < 0:
						break # Syntax error
					var sub_task = spec.substr(idx, pos - idx - 1).strip_edges()
					for n in reps:
						tasks.append([sub_task])
					idx = pos + 1
				else:
					break # Syntax error
	return tasks


func get_output_header(output_format: String):
	var output_formats = output_format.split(" ")
	# Form the top line like: |   a   |   b   | out |
	var output = "|"
	for format in output_formats:
		var pnf = format.split("%")
		var widths = pnf[1].split(".")
		widths.resize(3) # There should be 3 values: PadL.Length.PadR
		# Center align the pin name
		var min_length = int(widths[0]) + int(widths[1]) + int(widths[2])
		var pin_name = pnf[0]
		@warning_ignore("integer_division")
		pin_name = pin_name.lpad((min_length + pin_name.length()) / 2, " ")
		output += pin_name.rpad(min_length, " ") + "|"
	return output + "\n"


func get_pin_list(tasks):
	var pins = []
	for task in tasks:
		if task[0] == "output-list":
			var output_formats = task[1].split(" ")
			for format in output_formats:
				var pnf = format.split("%")
				pins.append(pnf[0])
	return pins


func get_output_result(pin_states, output_format):
	var formats = output_format.split(" ")
	var output = "|"
	for idx in pin_states.size():
		# Format string: (S|B|D|X)PadL.Length.PadR
		var pnf = formats[idx].split("%")
		if pnf.size() == 1:
			pnf.append("B1.1.1") # Default value
		var widths = pnf[1].right(-1).split(".")
		widths.resize(3) # There should be 3 values: PadL.Length.PadR
		var value = format_value(pin_states[pnf[0]], pnf[1][0], int(widths[1]))
		output += value.lpad(int(widths[0]) + value.length()) + " ".repeat(int(widths[2])) + "|"
	return output + "\n"


func format_value(value, format, width):
	if value is String:
		format = "S"
	match format:
		"S", "D":
			value = str(value).rpad(width, " ")
		"X":
			format =  "%0" + str(width) + "X"
			value = format % [value]
		"B":
			var bits = PackedStringArray()
			var negative = false
			if value < 1:
				negative = true
				value = -value
			for n in width:
				if value % 2:
					bits.append("1")
				else:
					bits.append("0")
				value /= 2
			if negative:
				var flip = false
				for idx in width:
					if flip:
						bits[idx] = "0" if bits[idx] == "1" else "1"
					else:
						if bits[idx] == "1":
							flip = true
			bits.reverse()
			value = "".join(bits)
	return value


func get_int_from_string(s):
	var x = 0
	if s[0] == "%":
		if s.length() > 2:
			var num = s.right(-2)
			match s[1]:
				"B":
					if num.is_valid_int():
						for idx in num.length():
							x *= 2
							x += int(num[idx])
				"X":
					if num.is_valid_hex_number():
						x = num.hex_to_int()
	else:
		x = int(s)
	return x
