# GdUnit generated TestSuite
class_name TestTestCircuit
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://classes/test_circuit.gd'


func test_circuit_run_tests() -> void:
	var test = TestCircuit.new()
	var _spec = "// This file is part of www.nand2tetris.org
// and the book \"The Elements of Computing Systems\"
// by Nisan and Schocken, MIT Press.
// File name: projects/01/And.tst

load And.hdl,
output-file And.out,
compare-to And.cmp,
output-list a%B3.1.3 b%B3.1.3 out%B3.1.3;

set a 0,
set b 0,
eval,
output;

set a 0,
set b 1,
eval,
output;

set a 1,
set b 0,
eval,
output;

set a 1,
set b 1,
eval,
output;
"
	#test.run_tests(spec, [], [])
	assert_not_yet_implemented()
	test.free()


func test_format_value() -> void:
	var test_circuit = TestCircuit.new()
	assert_str(test_circuit.format_value(10, "S", 4)).is_equal("10  ")
	assert_str(test_circuit.format_value(10, "D", 3)).is_equal("10 ")
	assert_str(test_circuit.format_value(10, "X", 4)).is_equal("000A")
	assert_str(test_circuit.format_value(21, "B", 8)).is_equal("00010101")
	test_circuit.free()


func test_get_output_header() -> void:
	var test_circuit = TestCircuit.new()
	var output_pins = ["a", "b"]
	var output_formats = ["B1.3.1", "D2.4.3"]
	assert_str(test_circuit.get_output_header(output_pins, output_formats)).is_equal("|  a  |    b    |\n")
	test_circuit.free()


func test_get_output_result() -> void:
	var test_circuit = TestCircuit.new()
	var result = [[1,10,3,0]]
	var output_formats = ["D1.3.1", "X1.1.1", "B1.4.1", ""]
	assert_str(test_circuit.get_output_results("", result, output_formats)).is_equal("| 1   | A | 0011 | 0 |\n")
	test_circuit.free()
