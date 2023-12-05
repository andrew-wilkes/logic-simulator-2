class_name TestCircuit

# This class is used to test cicuits by the user when running the software
# Tests are described in .tst files in the www.nand2tetris.org format

extends Node

const CLOCK_PIN = "clk"
const LOOP_TIME_LIMIT = 10000 # ms

var running = true
var tasks
var output_format
var pin_states
var output
var inputs
var outputs
var repetitive_tasks = []
var repeat_counter = 0
var repeat_decrement = 1
var repetitive_task_idx = -1
var time = 0
var tick = false
var loop_start_time = 0
var test_step = 0

func get_io_nodes(parts, connections):
	# Inputs are unconnected pins on the left side of parts
	# Outputs are unconnected pins on the right side of parts
	inputs = {}
	outputs = {}
	for part in parts:
		if not part is Part:
			continue
		var num_inputs = part.get_input_port_count()
		var used_ports = []
		for con in connections:
			if con.to_node == part.name:
				used_ports.append(con.to_port)
		for port in num_inputs:
			if used_ports.has(port):
				continue
			var type = part.get_input_port_type(port)
			inputs[get_label_text(part, 0, port)] = [part, port, type]
		
		var num_outputs = part.get_output_port_count()
		used_ports = []
		for con in connections:
			if con.from_node == part.name:
				used_ports.append(con.from_port)
		for port in num_outputs:
			if used_ports.has(port):
				continue
			outputs[get_label_text(part, 1, port)] = [part, port]
	return [inputs, outputs]


func get_label_text(part, side, port):
	# If the part is Bus, Wire, or TriState then get the part.tag value
	if part.part_type in ["Bus", "Wire", "TriState", "MemoryProbe"]:
		return part.get_node("Tag").text
	var slot = part.get_input_port_slot(port) if side == 0 else \
		part.get_output_port_slot(port)
	var node = part.get_child(slot) # There may be a label or a container of nodes
	if node is Container:
		if side == 0:
			node = node.get_child(0)
		else:
			node = node.get_child(-1)
	return node.text


# Parse a .tst file
func init_tests(spec: String, io_nodes):
	inputs = io_nodes[0]
	outputs = io_nodes[1]
	output = ""
	output_format = ""
	pin_states = {}
	tasks = parse_spec(spec)


func reset():
	time = 0
	tick = false
	for key in pin_states:
		pin_states[key] = 0


func process_task(task):
	match task[0]:
		"output-list":
			output_format = task[1]
			set_output_header()
		"set":
			# Apply input levels and values to the parts
			var pin_name = task[1]
			var value = get_int_from_string(task[2], false)
			pin_states[pin_name] = "-"
			if inputs.has(pin_name):
				pin_states[pin_name] = value
				var target = inputs[pin_name] # [part, port, port_type]
				if target[2] == 0: # Wire
					target[0].update_input_level(0, target[1], value == 1)
				else: #Bus
					target[0].update_bus_input_value(0, target[1], value)
		"eval":
			get_output_values()
		"output":
			get_output_values()
			set_output_result()
		"tick", "tock":
			tick = true if task[0] == "tick" else false
			if not tick:
				time += 1 # tock
			if inputs.has(CLOCK_PIN):
				var target = inputs[CLOCK_PIN] # [part, port, port_type]
				target[0].update_input_level(0, target[1], tick)
			get_output_values()
		"repeat":
			if repeat_counter > 0:
				# Check if repeat should end
				repeat_counter -= 1
				if repeat_counter == 0:
					repetitive_tasks.clear()
				else:
					# Repeat the tasks
					test_step -= 1
					repetitive_task_idx = 0
			else:
				# New repeat
				repetitive_task_idx = 0
				test_step -= 1
				repeat_counter = task[1]
				repetitive_tasks = parse_spec(task[2])
		"while":
			if loop_start_time == 0:
				loop_start_time = Time.get_ticks_msec()
			# while x op y { tasks to repeat }
			var x = get_pin_value(task[1])
			var op = task[2]
			var y = get_pin_value(task[3])
			var is_true = false
			match op:
				">":
					is_true = x > y
				"<":
					is_true = x < y
				">=":
					is_true = x >= y
				"<=":
					is_true = x <= y
				"<>":
					is_true = x != y
				"=":
					is_true = x == y
			if loop_start_time > 0:
				if Time.get_ticks_msec() - loop_start_time > LOOP_TIME_LIMIT:
					loop_start_time = 0
					is_true = false
			if is_true:
				repetitive_task_idx = 0
				test_step -= 1
				if repetitive_tasks.size() == 0:
					repetitive_tasks = parse_spec(task[4])
			else:
				repetitive_tasks.clear()
		"echo":
			if G.message_panel:
				G.message_panel.show_message(task[1])


func get_pin_value(pin: String):
	if pin.is_valid_int():
		return int(pin)
	if outputs.has(pin):
		var target = outputs[pin]
		var pin_key = [1, target[1]] # [side, port]
		# Cast bools to int and set the value to 0 if the pin has not been touched
		return int(target[0].pins.get(pin_key, 0))
	if inputs.has(pin):
		var target = inputs[pin]
		var pin_key = [0, target[1]]
		return int(target[0].pins.get(pin_key, 0))
	return 0 # Default to zero (don't support a string value on a pin)


func get_output_values():
	# Get the required outputs from the parts
	for pin in get_pin_list():
		if not pin_states.has(pin):
			pin_states[pin] = 0
		if outputs.has(pin):
			var target = outputs[pin]
			var pin_key = [1, target[1]] # [side, port]
			# Cast bools to int and set the value to 0 if the pin has not been touched
			pin_states[pin] = int(target[0].pins.get(pin_key, 0))


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


# This simple text parser returns with whatever tasks it has listed so far if it hits something unexpected
func parse_spec(spec: String):
	var _tasks = []
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
				_tasks.append([token, spec.substr(idx, pos - idx)])
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
				_tasks.append([token, regex.sub(spec.substr(idx, pos - idx), "%", true)])
				idx = pos + 1
			"output", "eval", "tick", "tock":
				_tasks.append([token])
			"set":
				# Find a string ending with , or ;
				pos = get_closest_delimiter_position(spec, idx, ",;")
				if pos < 0:
					break # Syntax error
				var task = [token] + Array(spec.substr(idx, pos - idx).split(" "))
				if task.size() != 3:
					break # Syntax error
				_tasks.append(task)
				idx = pos + 1
			"echo":
				if spec[idx] != '"':
					break # Syntax error
				idx += 1
				pos = spec.find('"', idx)
				if pos < 0:
					break # Syntax error
				_tasks.append([token, spec.substr(idx, pos - idx)])
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
				_tasks.append([token, reps, sub_task])
				idx = pos + 1
			"while":
				pos = spec.find(" ", idx)
				if pos < 0:
					break # Syntax error
				var x = spec.substr(idx, pos - idx)
				idx = pos + 1
				pos = spec.find(" ", idx)
				if pos < 0:
					break # Syntax error
				var op = spec.substr(idx, pos - idx)
				idx = pos + 1
				pos = spec.find(" ", idx)
				if pos < 0:
					break # Syntax error
				var y = spec.substr(idx, pos - idx)
				idx = pos + 1
				if spec[idx] != "{":
					break # Syntax error
				idx += 1
				pos = spec.find("}", idx)
				if pos < 0:
					break # Syntax error
				var sub_task = spec.substr(idx, pos - idx).strip_edges()
				_tasks.append([token, x, op, y, sub_task])
				idx = pos + 1
	return _tasks


func clean_src(spec):
	# Convert spec to a string without comments or line breaks
	var lines = spec.replace("\r", "\n").split("\n", false)
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
	regex.compile("/\\*{1,2}.+\\*/")
	return regex.sub(spec, "", true)


func set_output_header():
	var missing_pins = []
	var output_formats = output_format.split(" ")
	# Form the top line like: |   a   |   b   | out |
	output = "|"
	for format in output_formats:
		var pnf = format.split("%")
		var widths = pnf[1].split(".")
		widths.resize(3) # There should be 3 values: PadL.Length.PadR
		# Center align the pin name
		var length = int(widths[0]) + int(widths[1]) + int(widths[2])
		var pin_name = pnf[0]
		if not inputs.has(pin_name) and not outputs.has(pin_name):
			if pin_name not in ["time"]: # List of non-pins
				missing_pins.append(pin_name)
		var padsize = length - pin_name.length()
		if padsize < 0:
			# Trim
			pin_name = pin_name.left(padsize)
		elif padsize > 0:
			# Add left/right padding
			@warning_ignore("integer_division")
			var lpad = padsize / 2
			pin_name = " ".repeat(lpad) + pin_name + " ".repeat(padsize - lpad)
		output += pin_name + "|"
	output += "\n"
	if missing_pins.size() > 0:
		G.warn_user("Missing pins:\n" + "\n".join(missing_pins))


func get_pin_list():
	var pins = []
	for task in tasks:
		if task[0] == "output-list":
			var output_formats = task[1].split(" ")
			for format in output_formats:
				var pnf = format.split("%")
				pins.append(pnf[0])
			break
	return pins


func set_output_result():
	var formats = output_format.split(" ")
	output = "|"
	for idx in formats.size():
		# Format string: (S|B|D|X)%PadL.Length.PadR
		var pnf = formats[idx].split("%")
		if pnf.size() == 1:
			pnf.append("B1.1.1") # Default value
		var _widths = pnf[1].right(-1).split(".")
		_widths.resize(3) # There should be 3 values: [PadL, Length, PadR]
		var widths = [int(_widths[0]), int(_widths[1]), int(_widths[2])]
		var value
		if pnf[0] == "time":
			value = get_tick_tock_str()
		else:
			value = pin_states.get(pnf[0], 0)
			# The case for high Z
			if value < - 0x10000:
				output += "*".repeat(widths[0] + widths[1] + widths[2]) + "|"
				continue
		value = format_value(value, pnf[1][0], widths[1])
		output += value.lpad(widths[0] + value.length()) + " ".repeat(widths[2]) + "|"


func get_tick_tock_str():
	if tick:
		return str(time) + "+"
	else:
		return str(time)


func format_value(value, format, width):
	if value is String:
		format = "S"
	match format:
		"S":
			value = str(value).rpad(width, " ")
		"D":
			if value > 0:
				value &= 0xffff
				if value > 0x7fff: # negative?
					value -= 0x10000
			value = str(value).lpad(width, " ")
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


func get_int_from_string(s, negate = true):
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
					if negate and x > 0x7fff: # negative?
						x = ~x + 1
						x &= 0xffff
						x = -x
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
