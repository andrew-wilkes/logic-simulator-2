# GdUnit generated TestSuite
class_name DisassemblerTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://scenes/disassembler.gd'

var max_hack = "0000000000000000
1111110000010000
0000000000000001
1111010011010000
0000000000001010
1110001100000001
0000000000000001
1111110000010000
0000000000001100
1110101010000111
0000000000000000
1111110000010000
0000000000000010
1110001100001000
0000000000001110
1110101010000111"

func test_run() -> void:
	var d = Disassembler.new()
	var lines = d.disassemble(max_hack)
	assert_int(lines.size()).is_equal(19)
	print("\n".join(lines))
	d.free()
