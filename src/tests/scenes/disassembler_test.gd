# GdUnit generated TestSuite
class_name DisassemblerTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://scenes/disassembler.gd'


func test_run() -> void:
	var d = Disassembler.new()
	var hack = "0000000000001100"
	assert_str(d.run(hack)).is_equal("@12               // 0x000c")
	assert_object(d.symbols).is_equal({ 12: "a" })
	hack = "1110110000010000"
	assert_str(d.run(hack)).is_equal("D=A")
	d.free()
