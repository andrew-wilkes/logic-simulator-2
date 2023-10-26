class_name TestCircuit

# This class is used to test cicuits
# Tests are described in .tst files in the www.nand2tetris.org format

extends Node

const CLOCK_PIN = "clk"

var running = true
var tasks
var output_format
var pin_states
var output
var inputs
var outputs
var repetitive_tasks
var repeat_counter = 0
var repeat_decrement = 1

func get_io_nodes(parts, connections):
	# Inputs are unconnected pins on the left side of parts
	# Outputs are unconnected pins on the right side of parts
	inputs = {}
	outputs = {}
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
	if node is Container:
		node = node.get_child(side)
	return node.text


# Parse a .tst file
func init_tests(spec: String, io_nodes):
	inputs = io_nodes[0]
	outputs = io_nodes[1]
	output = ""
	output_format = ""
	pin_states = {}
	tasks = parse_spec(spec)


func process_task(task):
	match task[0]:
		"output-list":
			output_format = task[1]
			set_output_header()
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
			for pin in get_pin_list():
				if not pin_states.has(pin):
					pin_states[pin] = "-"
				if outputs.has(pin):
					var target = outputs[pin]
					var pin_key = [1, target[1]] # [side, port]
					# Cast bools to int and set the value to 0 if the pin has not been touched
					pin_states[pin] = int(target[0].pins.get(pin_key, 0))
		"output":
			set_output_result()
		"tick", "tock":
			if inputs.has(CLOCK_PIN):
				var target = inputs[CLOCK_PIN] # [part, port, port_type]
				target[0].update_input_level(0, target[1], task[0] == "tick")
		"repeat":
			repeat_counter = task[1]
			repetitive_tasks = parse_spec(task[2])
			repeat_decrement = 0
			if repeat_counter > 0:
				repeat_decrement = 1
			else:
				repeat_counter = 1


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
	tasks = []
	spec = clean_src(spec)
	var idx = 0
	while true:
		if idx >= spec.length():
			break
		# Get the shortest distance to the next delimiter from the start of the line
		var pos = get_closest_delimiter_position(spec, idx, " ,;")
		var token = spec.substr(idx, pos - idx)
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
				# Remove space between string and % since we split the formats based on a space between items
				# An example in the Nand2Tetris docs Appendix B had a space between the pin name and %
				var regex = RegEx.new()
				regex.compile("\\s%")
				tasks.append([token, regex.sub(spec.substr(idx, pos - idx), "%", true)])
				idx = pos + 1
			"output", "eval", "tick", "tock":
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
			"echo":
				if spec[idx] != '"':
					break # Syntax error
				idx += 1
				pos = spec.find('"', idx)
				if pos < 0:
					break # Syntax error
				tasks.append([token, spec.substr(idx, pos - idx)])
			"repeat":
				var reps = 0 # Continuous loop
				if spec[idx] != "{":
					pos = spec.find(" ", idx)
					if pos < 0:
						break # Syntax error
					reps = spec.substr(idx, pos - idx)
					if reps.is_valid_int():
						reps = int(reps)
					else:
						break # Syntax error
					idx = pos + 1
					if spec[idx] != "{":
						break # Syntax error
				idx += 1
				pos = spec.find("}", idx)
				if pos < 0:
					break # Syntax error
				var sub_task = spec.substr(idx, pos - idx).strip_edges()
				tasks.append([token, reps, sub_task])
				idx = pos + 1
	return tasks


func clean_src(spec):
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
	return regex.sub(spec, "", true)


func set_output_header():
	var output_formats = output_format.split(" ")
	# Form the top line like: |   a   |   b   | out |
	output = "|"
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
	output += "\n"


func get_pin_list():
	var pins = []
	for task in tasks:
		if task[0] == "output-list":
			var output_formats = task[1].split(" ")
			for format in output_formats:
				var pnf = format.split("%")
				pins.append(pnf[0])
	return pins


func set_output_result():
	var formats = output_format.split(" ")
	output = "|"
	for idx in pin_states.size():
		# Format string: (S|B|D|X)%PadL.Length.PadR
		var pnf = formats[idx].split("%")
		if pnf.size() == 1:
			pnf.append("B1.1.1") # Default value
		var widths = pnf[1].right(-1).split(".")
		widths.resize(3) # There should be 3 values: [PadL, Length, PadR]
		var value = format_value(pin_states[pnf[0]], pnf[1][0], int(widths[1]))
		output += value.lpad(int(widths[0]) + value.length()) + " ".repeat(int(widths[2])) + "|"
	output += "\n"


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


func get_ios_from_hdl(hdl):
	hdl = clean_src(hdl)
	var result = {
		title = "",
		inputs = [],
		outputs = []
	}
	var idx = hdl.find("CHIP")
	if idx > -1:
		idx += 5
		var pos = hdl.find(" ", idx)
		if pos > idx:
			result.title = hdl.substr(idx, pos - idx)
			idx = pos
			pos = hdl.find("{", idx)
			if pos > idx:
				idx = pos
				pos = hdl.find("IN", idx)
				if pos > idx:
					idx = pos + 2
					pos = hdl.find(";", idx)
					if pos > idx:
						var pin_text = hdl.substr(idx, pos - idx)
						idx = pos
						var items = pin_text.replace(" ", "").split(",")
						for item in items:
							pos = item.find("[")
							if pos > -1:
								result.inputs.append([item.left(pos), 1]) # Bus
							else:
								result.inputs.append([item, 0]) # Wire
				pos = hdl.find("OUT", idx)
				if pos > idx:
					idx = pos + 3
					pos = hdl.find(";", idx)
					if pos > idx:
						var pin_text = hdl.substr(idx, pos - idx)
						idx = pos
						var items = pin_text.replace(" ", "").split(",")
						for item in items:
							pos = item.find("[")
							if pos > -1:
								result.outputs.append([item.left(pos), 1]) # Bus
							else:
								result.outputs.append([item, 0]) # Wire
	return result
