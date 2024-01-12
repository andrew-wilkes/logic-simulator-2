class_name Disassembler

extends MarginContainer

const COMPS = { 0b0101010: "0", 0b0111111: "1", 0b0111010: "-1", 0b0001100: "D", 0b0110000: "A",
	0b0001101: "!D", 0b0110001: "!A",0b0001111: "-D",0b0110011: "-A", 0b0011111: "D+1",
	0b0110111: "A+1", 0b0001110: "D-1",0b0110010: "A-1", 0b0000010: "D+A", 0b0010011: "D-A",
	0b0000111: "A-D", 0b0000000: "D&A", 0b0010101: "D|A", 0b1110000: "M", 0b1110001: "!M",
	0b1110011: "-M", 0b1110111: "M+1", 0b1110010: "M-1", 0b1000010: "D+M",0b1010011: "D-M",
	0b1000111: "M-D", 0b1000000: "D&M", 0b1010101: "D|M" }

const INDENT_WIDTH = 10

func disassemble(hack):
	var labels = {}
	var vars = {}
	var next_var_code = 105 # i
	var next_label_code = 65 # A
	var address = 0
	var last_instruction_was_A = false
	var a_value = 0
	var instructions = []
	var words = G.hack_to_array_of_int(hack)
	for word in words:
		if word < 0x8000:
			# A-instruction
			a_value = word
			last_instruction_was_A = true
		else:
			# C-instruction
			var comp = (word & 0x1fc0) >> 6
			var dest = (word & 0x38) >> 3
			var jump = word & 7
			if last_instruction_was_A:
				# Format the value
				last_instruction_was_A = false
				if jump > 0:
					if not labels.has(a_value):
						labels[a_value] = char(next_label_code).repeat(4)
						next_label_code += 1
					instructions.append("[color=cyan]@" + labels[a_value] + "[/color]")
				else:
					if a_value == 0x4000:
						instructions.append("@SCREEN // 0x%04x" % [a_value])
					elif a_value == 0x6000:
						instructions.append("@KBD // 0x%04x" % [a_value])
					elif comp < 64 and dest & 1 == 0:
						# A reg
						instructions.append("@" + str(a_value))
					else:
						# RAM access
						if a_value < 0x10:
							# Virtual register
							instructions.append("@R" + str(a_value))
						else:
							# Variable
							if not vars.has(a_value):
								vars[a_value] = char(next_var_code)
								next_var_code += 1
							instructions.append("@" + vars[a_value])
			var cinst = [ "", "M", "D", "MD", "A", "AM", "AD", "AMD" ][dest]
			if dest > 0:
				cinst += "="
			cinst += COMPS.get(comp, "???")
			if jump > 0:
				cinst += ";" + [ "", "JGT", "JEQ", "JGE", "JLT", "JNE", "JLE", "JMP" ][jump]
			instructions.append("%s" % [cinst])
		address += 1
	var lines = PackedStringArray()
	address = 0
	var format = "[color=SALMON]%-" + str(INDENT_WIDTH) + "d[/color][color=SILVER]%s[/color]"
	var header_format = "%-" + str(INDENT_WIDTH) + "s%s"
	lines.append(header_format % ["Address", "Instruction"])
	for instr in instructions:
		if labels.has(address):
			lines.append("([color=cyan]" + labels[address] + "[/color])")
		lines.append(format % [address, instr])
		address += 1
	return lines


func load_data(hack):
	var lines = disassemble(hack)
	$Code.text = "\n".join(lines)
