extends MarginContainer

class_name Assembler6502

const MAP = [["BRK", "impl"], ["ORA", "X,ind"], ["JAM", ""], ["SLO", "X,ind"], ["NOP", "zpg"], ["ORA", "zpg"], ["ASL", "zpg"], ["SLO", "zpg"], ["PHP", "impl"], ["ORA", "#"], ["ASL", "A"], ["ANC", "#"], ["NOP", "abs"], ["ORA", "abs"], ["ASL", "abs"], ["SLO", "abs"], ["BPL", "rel"], ["ORA", "ind,Y"], ["JAM", ""], ["SLO", "ind,Y"], ["NOP", "zpg,X"], ["ORA", "zpg,X"], ["ASL", "zpg,X"], ["SLO", "zpg,X"], ["CLC", "impl"], ["ORA", "abs,Y"], ["NOP", "impl"], ["SLO", "abs,Y"], ["NOP", "abs,X"], ["ORA", "abs,X"], ["ASL", "abs,X"], ["SLO", "abs,X"], ["JSR", "abs"], ["AND", "X,ind"], ["JAM", ""], ["RLA", "X,ind"], ["BIT", "zpg"], ["AND", "zpg"], ["ROL", "zpg"], ["RLA", "zpg"], ["PLP", "impl"], ["AND", "#"], ["ROL", "A"], ["ANC", "#"], ["BIT", "abs"], ["AND", "abs"], ["ROL", "abs"], ["RLA", "abs"], ["BMI", "rel"], ["AND", "ind,Y"], ["JAM", ""], ["RLA", "ind,Y"], ["NOP", "zpg,X"], ["AND", "zpg,X"], ["ROL", "zpg,X"], ["RLA", "zpg,X"], ["SEC", "impl"], ["AND", "abs,Y"], ["NOP", "impl"], ["RLA", "abs,Y"], ["NOP", "abs,X"], ["AND", "abs,X"], ["ROL", "abs,X"], ["RLA", "abs,X"], ["RTI", "impl"], ["EOR", "X,ind"], ["JAM", ""], ["SRE", "X,ind"], ["NOP", "zpg"], ["EOR", "zpg"], ["LSR", "zpg"], ["SRE", "zpg"], ["PHA", "impl"], ["EOR", "#"], ["LSR", "A"], ["ALR", "#"], ["JMP", "abs"], ["EOR", "abs"], ["LSR", "abs"], ["SRE", "abs"], ["BVC", "rel"], ["EOR", "ind,Y"], ["JAM", ""], ["SRE", "ind,Y"], ["NOP", "zpg,X"], ["EOR", "zpg,X"], ["LSR", "zpg,X"], ["SRE", "zpg,X"], ["CLI", "impl"], ["EOR", "abs,Y"], ["NOP", "impl"], ["SRE", "abs,Y"], ["NOP", "abs,X"], ["EOR", "abs,X"], ["LSR", "abs,X"], ["SRE", "abs,X"], ["RTS", "impl"], ["ADC", "X,ind"], ["JAM", ""], ["RRA", "X,ind"], ["NOP", "zpg"], ["ADC", "zpg"], ["ROR", "zpg"], ["RRA", "zpg"], ["PLA", "impl"], ["ADC", "#"], ["ROR", "A"], ["ARR", "#"], ["JMP", "ind"], ["ADC", "abs"], ["ROR", "abs"], ["RRA", "abs"], ["BVS", "rel"], ["ADC", "ind,Y"], ["JAM", ""], ["RRA", "ind,Y"], ["NOP", "zpg,X"], ["ADC", "zpg,X"], ["ROR", "zpg,X"], ["RRA", "zpg,X"], ["SEI", "impl"], ["ADC", "abs,Y"], ["NOP", "impl"], ["RRA", "abs,Y"], ["NOP", "abs,X"], ["ADC", "abs,X"], ["ROR", "abs,X"], ["RRA", "abs,X"], ["NOP", "#"], ["STA", "X,ind"], ["NOP", "#"], ["SAX", "X,ind"], ["STY", "zpg"], ["STA", "zpg"], ["STX", "zpg"], ["SAX", "zpg"], ["DEY", "impl"], ["NOP", "#"], ["TXA", "impl"], ["ANE", "#"], ["STY", "abs"], ["STA", "abs"], ["STX", "abs"], ["SAX", "abs"], ["BCC", "rel"], ["STA", "ind,Y"], ["JAM", ""], ["SHA", "ind,Y"], ["STY", "zpg,X"], ["STA", "zpg,X"], ["STX", "zpg,Y"], ["SAX", "zpg,Y"], ["TYA", "impl"], ["STA", "abs,Y"], ["TXS", "impl"], ["TAS", "abs,Y"], ["SHY", "abs,X"], ["STA", "abs,X"], ["SHX", "abs,Y"], ["SHA", "abs,Y"], ["LDY", "#"], ["LDA", "X,ind"], ["LDX", "#"], ["LAX", "X,ind"], ["LDY", "zpg"], ["LDA", "zpg"], ["LDX", "zpg"], ["LAX", "zpg"], ["TAY", "impl"], ["LDA", "#"], ["TAX", "impl"], ["LXA", "#"], ["LDY", "abs"], ["LDA", "abs"], ["LDX", "abs"], ["LAX", "abs"], ["BCS", "rel"], ["LDA", "ind,Y"], ["JAM", ""], ["LAX", "ind,Y"], ["LDY", "zpg,X"], ["LDA", "zpg,X"], ["LDX", "zpg,Y"], ["LAX", "zpg,Y"], ["CLV", "impl"], ["LDA", "abs,Y"], ["TSX", "impl"], ["LAS", "abs,Y"], ["LDY", "abs,X"], ["LDA", "abs,X"], ["LDX", "abs,Y"], ["LAX", "abs,Y"], ["CPY", "#"], ["CMP", "X,ind"], ["NOP", "#"], ["DCP", "X,ind"], ["CPY", "zpg"], ["CMP", "zpg"], ["DEC", "zpg"], ["DCP", "zpg"], ["INY", "impl"], ["CMP", "#"], ["DEX", "impl"], ["SBX", "#"], ["CPY", "abs"], ["CMP", "abs"], ["DEC", "abs"], ["DCP", "abs"], ["BNE", "rel"], ["CMP", "ind,Y"], ["JAM", ""], ["DCP", "ind,Y"], ["NOP", "zpg,X"], ["CMP", "zpg,X"], ["DEC", "zpg,X"], ["DCP", "zpg,X"], ["CLD", "impl"], ["CMP", "abs,Y"], ["NOP", "impl"], ["DCP", "abs,Y"], ["NOP", "abs,X"], ["CMP", "abs,X"], ["DEC", "abs,X"], ["DCP", "abs,X"], ["CPX", "#"], ["SBC", "X,ind"], ["NOP", "#"], ["ISC", "X,ind"], ["CPX", "zpg"], ["SBC", "zpg"], ["INC", "zpg"], ["ISC", "zpg"], ["INX", "impl"], ["SBC", "#"], ["NOP", "impl"], ["USBC", "#"], ["CPX", "abs"], ["SBC", "abs"], ["INC", "abs"], ["ISC", "abs"], ["BEQ", "rel"], ["SBC", "ind,Y"], ["JAM", ""], ["ISC", "ind,Y"], ["NOP", "zpg,X"], ["SBC", "zpg,X"], ["INC", "zpg,X"], ["ISC", "zpg,X"], ["SED", "impl"], ["SBC", "abs,Y"], ["NOP", "impl"], ["ISC", "abs,Y"], ["NOP", "abs,X"], ["SBC", "abs,X"], ["INC", "abs,X"], ["ISC", "abs,X"]]
const OP_CODES = ["BRK", "NOP", "PHP", "BPL", "CLC", "JSR", "BIT", "PLP", "BMI", "SEC", "RTI", "PHA", "JMP", "BVC", "CLI", "RTS", "PLA", "BVS", "SEI", "STY", "DEY", "BCC", "TYA", "SHY", "LDY", "TAY", "BCS", "CLV", "CPY", "INY", "BNE", "CLD", "CPX", "INX", "BEQ", "SED", "ORA", "AND", "EOR", "ADC", "STA", "LDA", "CMP", "SBC", "JAM", "ASL", "ROL", "LSR", "ROR", "STX", "TXA", "TXS", "SHX", "LDX", "TAX", "TSX", "DEC", "DEX", "INC", "SLO", "ANC", "RLA", "SRE", "ALR", "RRA", "ARR", "SAX", "ANE", "SHA", "TAS", "LAX", "LXA", "LAS", "DCP", "SBX", "ISC", "USBC"]

enum { LOAD, SAVE, SAVE_CODE }

var title = "6502 Assembler"
var labels = {}
var ordered_labels
var number_regex
var hex_number_regex
var char_regex
var binary_regex
var bytes: PackedByteArray
var list = []
var src = ""
var file_mode = LOAD
@onready var fd: FileDialog = $FileDialog

func _init():
	bytes = PackedByteArray()
	bytes.resize(0x10000)
	number_regex = RegEx.new()
	number_regex.compile("-?\\d+")
	hex_number_regex = RegEx.new()
	hex_number_regex.compile("(-?)\\$(\\w+)")
	char_regex = RegEx.new()
	char_regex.compile("'(.)'")
	binary_regex = RegEx.new()
	binary_regex.compile("%([0,1]{8})")


func get_number(txt):
	var num = get_number_from_text(txt)
	if num > 65535:
		num = -2
	return num


func get_number_from_text(txt):
	# Return -1 if no matches could be satisfied
	var result = binary_regex.search(txt)
	if result:
		var b = result.get_string(1)
		return G.binary_to_int(b)
	result = hex_number_regex.search(txt)
	if result:
		var num = result.get_string(1) + result.get_string(2)
		if num.is_valid_hex_number():
			num = num.hex_to_int()
			if num < 0: num = 256 + num
			return num
	result = number_regex.search(txt)
	if result:
		var num = result.get_string()
		if num.is_valid_int():
			num = int(num)
			if num < 0: num = 256 + num
			return num
	result = char_regex.search(txt)
	if result:
		return result.get_string(1).to_ascii_buffer()[0]
	return -1


func replace_labels(operand):
	for label in ordered_labels:
		operand = operand.replace(label, str(labels[label]))
	return operand


func is_label(txt):
	var chr = txt[0].to_upper()
	return chr >= "A" and chr <= "Z"


func clean_text(txt):
	var clean_lines = []
	var lines = txt.replace("\r", "\n").split("\n", false)
	for line in lines:
		clean_lines.append(line.replace("\t", " ").lstrip(" "))
	return clean_lines


func process_lines_pass1(lines):
	var addr = 0
	var line_num = 0
	for line in lines:
		line_num += 1
		var label = ""
		var directive = ""
		var op_code = -1
		var op_token = ""
		var no_comment_line = remove_comment(line, ";")
		if no_comment_line.length() < 1: continue
		var tokens = no_comment_line.to_upper().split(" ", false)
		var operand = ""
		for token in tokens:
			if token.ends_with(":"):
				if token.length() < 2:
					return format_error(line_num, "Invalid label")
				label = token.left(-1)
				# Assign initial value to label
				labels[label] = addr
				directive = "label"
				continue
			if token.begins_with("."):
				directive = token.right(-1)
				op_code = -2 # Don't evaluate next token as op code
				continue
			if op_code == -1:
				op_token = token
				op_code = -2 # Skip op code
				directive = ""
				continue
			else:
				operand += token
		# Evaluate operand
		if directive == "":
			match operand:
				"", "A":
					addr += 1
				_ when operand.begins_with("("):
					if operand.ends_with("X)"):
						addr += 2
					elif operand.ends_with(")"):
						addr += 3
					else:
						addr += 2
				_ when op_token.begins_with("B"):
					addr += 2
				_ when get_number(operand) > 255:
					addr += 3
				_ when is_label(operand):
					# A label that has a 16 bit value
					addr += 3
				_:
					addr += 2
		else:
			match directive:
				"ORG":
					addr = get_number(operand)
					if addr < 0:
						return format_error(line_num, "Invalid .org value: " + operand)
					if label != "":
						labels[label] = addr
				"DB":
					var values = operand.split(",")
					addr += values.size()
				"DW":
					var values = operand.split(",")
					addr += 2 * values.size()
				"DL":
					var values = operand.split(",")
					addr += 3 * values.size()
				"DS":
					addr += get_number(operand)
	ordered_labels = labels.keys()
	ordered_labels.sort()
	ordered_labels.reverse()
	return "ok"


func process_lines_pass2(lines):
	list = []
	var addr = 0
	var line_num = 0
	for line in lines:
		line_num += 1
		var list_line = ""
		var num_bytes = 0
		var mode = ""
		var directive = ""
		var op_code = -1
		var op_token = ""
		var no_comment_line = remove_comment(line, ";")
		if no_comment_line.length() < 1:
			list.append(line)
			continue
		var tokens = no_comment_line.to_upper().split(" ", false)
		var operand = ""
		for token in tokens:
			if token.ends_with(":"):
				mode = "label"
				list_line = line
				continue
			if token.begins_with("."):
				mode = "dir"
				directive = token.right(-1)
				op_code = -2 # Don't evaluate next token as op code
				continue
			if op_code == -1:
				op_token = token
				op_code = OP_CODES.find(op_token)
				if op_code < 0:
					return format_error(line_num, "Invalid op_code " + token)
			else:
				operand += token
		# Evaluate operand
		operand = replace_labels(operand)
		var num: int = get_number(operand)
		match mode:
			"":
				match operand:
					"":
						mode = "impl"
					"A":
						mode = "A"
					_:
						var last_chr = operand[-1]
						match operand[0]:
							"#":
								mode = "#"
								num_bytes = 1
							"(":
								num_bytes = 1
								match last_chr:
									")" when operand[-2] == "X":
										mode = "X,ind"
									"Y":
										mode = "ind,Y"
									_:
										mode = "ind"
										num_bytes = 2
							_ when op_token.begins_with("B"):
								mode = "rel"
								num_bytes = 1
								# Convert number to a relative offset
								num = num - addr - 2
								if num < 0: num = 256 + num
							_ when num > 255:
								num_bytes = 2
								match last_chr:
									"X":
										mode = "abs,X"
									"Y":
										mode = "abs,Y"
									_:
										mode = "abs"
							_:
								num_bytes = 1
								match last_chr:
									"X":
										mode = "zpg,X"
									"Y":
										mode = "zpg,Y"
									_:
										mode = "zpg"
				bytes[addr] = MAP.find([op_token, mode])
				list_line = "%04x : %02x" % [addr, bytes[addr]]
				addr += 1
				# Add bytes for number
				if num_bytes > 0:
					bytes[addr] = num & 0xff
					list_line += "%02x" % bytes[addr]
					addr += 1
					if num_bytes == 2:
						bytes[addr] = num / 256
						list_line += "%02x" % bytes[addr]
						addr += 1
				list_line = list_line.rpad(16) + line
			"dir":
				match directive:
					"ORG":
						addr = get_number(operand)
						list_line = "%04x = %s" % [addr, line]
					"DB":
						list_line = "%04x : " % addr
						var values = operand.split(",")
						for value in values:
							var v = get_number(value) & 0xff
							list_line += "%02x" % v
							bytes[addr] = v
							addr += 1
						list_line = list_line.rpad(16) + line
					"DW":
						list_line = "%04x : " % addr
						var values = operand.split(",")
						for value in values:
							num = get_number(value)
							var v = num & 0xff
							list_line += "%02x" % v
							bytes[addr] = v
							addr += 1
							v = (num / 0x100) & 0xff
							list_line += "%02x" % v
							bytes[addr] = v
							addr += 1
						list_line = list_line.rpad(16) + line
					"DL":
						list_line = "%04x : " % addr
						var values = operand.split(",")
						for value in values:
							num = get_number_from_text(value)
							for n in 4:
								var v = num & 0xff
								list_line += "%02x" % v
								bytes[addr] = v
								num /= 0x100
								addr += 1
						list_line = list_line.rpad(16) + line
					"DS":
						list_line = ("%04x : " % addr).rpad(16) + line
						addr += get_number(operand)
		list.append(list_line)
	return "ok"


func format_error(line_num, err_msg):
	return "Line %-6d%s" % [line_num, err_msg]


func remove_comment(line, delim):
	var pos = line.find(delim)
	if pos >= 0:
		return line.left(pos)
	return line


func _on_compile_button_pressed():
	bytes.clear()
	bytes.resize(0x10000)
	src = %Code.text
	var lines = clean_text(src)
	var result = process_lines_pass1(lines)
	if result == "ok":
		result = process_lines_pass2(lines)
		if result == "ok":
			%Report.text = "Compilation successful!"
	if result != "ok":
		%Report.text = result


func _on_help_button_pressed():
	$HelpPanel.popup_centered()


func _on_open_button_pressed():
	fd.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fd.filters = PackedStringArray(["*.asm ; Assembly files"])
	file_mode = LOAD
	open_file_dialog()


func _on_save_button_pressed():
	fd.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	fd.filters = PackedStringArray(["*.asm ; Assembly files"])
	file_mode = SAVE
	open_file_dialog()


func _on_save_code_button_pressed():
	fd.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	fd.filters = PackedStringArray(["*.bin ; Binary files"])
	fd.current_file = fd.current_file.get_basename() + ".bin"
	file_mode = SAVE_CODE
	open_file_dialog()


func _on_new_button_pressed():
	%Code.text = ""


func open_file_dialog():
	%Report.text = ""
	fd.current_dir = G.settings.last_dir
	fd.popup_centered()


func _on_file_dialog_file_selected(path: String):
	G.settings.last_dir = path.get_base_dir()
	%Report.text = ""
	match file_mode:
		LOAD:
			src = FileAccess.get_file_as_string(path)
			%Code.text = src
		SAVE:
			src = %Code.text
			var file = FileAccess.open(path, FileAccess.WRITE)
			file.store_string(src)
		SAVE_CODE:
			var file = FileAccess.open(path, FileAccess.WRITE)
			file.store_buffer(bytes)
			# Store list file
			var list_path = path.replace(path.get_extension(), "lst")
			file = FileAccess.open(list_path, FileAccess.WRITE)
			file.store_string("\n".join(list))
			%Report.text = "Saved ROM data to: " + path + "\nSaved list file to: " + list_path
