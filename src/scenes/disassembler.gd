extends MarginContainer

class_name Disassembler

var symbols = {}
var next_symbol = 97 # a

const COMPS = { 0b0101010: "0", 0b0111111: "1", 0b0111010: "-1", 0b0001100: "D", 0b0110000: "A",
	0b0001101: "!D", 0b0110001: "!A",0b0001111: "-D",0b0110011: "-A", 0b0011111: "D+1",
	0b0110111: "A+1", 0b0001110: "D-1",0b0110010: "A-1", 0b0000010: "D+A", 0b0010011: "D-A",
	0b0000111: "A-D", 0b0000000: "D&A", 0b0010101: "D|A", 0b1110000: "M", 0b1110001: "!M",
	0b1110011: "-M", 0b1110111: "M+1", 0b1110010: "M-1", 0b1000010: "D+M",0b1010011: "D-M",
	0b1000111: "M-D", 0b1000000: "D&M", 0b1010101: "D|M" }

func run(hack):
	var lines = PackedStringArray()
	var words = G.hack_to_array_of_int(hack)
	for word in words:
		if word < 0x8000:
			# A-instruction
			lines.append("@%-16d // 0x%04x" % [word, word])
			symbols[word] = char(next_symbol)
			next_symbol += 1
		else:
			# C-instruction
			var dest = (word & 0x38) >> 3
			var cinst = [ "", "M", "D", "MD", "A", "AM", "AD", "AMD" ][dest]
			if dest > 0:
				cinst += "="
			var comp = (word & 0x1fc0) >> 6
			cinst += COMPS.get(comp, "???")
			var jump = word & 3
			if jump > 0:
				cinst += ";" + [ "", "JGT", "JEQ", "JGE", "JLT", "JNE", "JLE", "JMP" ][jump]
			lines.append("%s" % [cinst])
	return lines[0]
