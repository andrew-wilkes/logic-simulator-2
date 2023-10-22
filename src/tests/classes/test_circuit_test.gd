# GdUnit generated TestSuite
class_name TestTestCircuit
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://classes/test_circuit.gd'

const spec_file = "// This file is part of www.nand2tetris.org
/* and the book \"The Elements of Computing Systems\"
 by Nisan and Schocken, MIT Press./
/** File name: projects/07/StackArithmetic/SimpleAdd/SimpleAdd.tst

 Tests SimpleAdd.asm on the CPU emulator./

load SimpleAdd.asm,
output-file SimpleAdd.out,
compare-to SimpleAdd.cmp,

echo \"Hello\",

set RAM[0] 256,  // initializes the stack pointer 

repeat 4 {      // enough cycles to complete the execution
	tick,
	output;
	tock,
	output;
}

// Outputs the stack pointer and the value at the stack's base
output-list RAM[0] %D2.6.2 RAM[2]%D2.6.2  aaa   %D2.6.2;
output;"

var hdl_file = "// if (no == 1) sets out = !out   // bitwise not
CHIP ALU {
	IN  
		x[16], y[16],  // 16-bit inputs        
		zx, // zero the x input?
		nx, // negate the x input?
		zy, // zero the y input?
		ny, // negate the y input?
		f,  // compute (out = x + y) or (out = x & y)?
		no; // negate the out output?
	OUT 
		out[16], // 16-bit output
		zr,      // (out == 0, 1, 0)
		ng;      // (out < 0,  1, 0)

	PARTS:
	//// Replace this comment with your code.
}"

func test_format_value() -> void:
	var test_circuit = TestCircuit.new()
	assert_str(test_circuit.format_value(10, "S", 4)).is_equal("10  ")
	assert_str(test_circuit.format_value(10, "D", 3)).is_equal("10 ")
	assert_str(test_circuit.format_value(10, "X", 4)).is_equal("000A")
	assert_str(test_circuit.format_value(21, "B", 8)).is_equal("00010101")
	test_circuit.free()


func test_get_output_header() -> void:
	var test_circuit = TestCircuit.new()
	var output_format = "a%B1.3.1 b%D2.4.3"
	var output = test_circuit.get_output_header(output_format)
	assert_str(output).is_equal("|  a  |    b    |\n")
	test_circuit.free()


func test_get_pin_list() -> void:
	var test_circuit = TestCircuit.new()
	var tasks = [["output-list", "a%D1.3.1 bb%X1.1.1 ccc%B1.4.1 d"]]
	assert_object(test_circuit.get_pin_list(tasks)).is_equal(["a", "bb", "ccc", "d"])
	test_circuit.free()


func test_get_output_result() -> void:
	var test_circuit = TestCircuit.new()
	var pin_states = { a = 1, bb = 10, ccc = 3, d = 0 }
	var output_format = "a%D1.3.1 bb%X1.1.1 ccc%B1.4.1 d"
	var output = test_circuit.get_output_result(pin_states, output_format)
	assert_str(output).is_equal("| 1   | A | 0011 | 0 |\n")
	test_circuit.free()


func test_parse_spec() -> void:
	var test_circuit = TestCircuit.new()
	assert_object(test_circuit.parse_spec(spec_file)).is_equal([])
	test_circuit.free()


func test_get_int_from_string() -> void:
	var test_circuit = TestCircuit.new()
	assert_int(test_circuit.get_int_from_string("8")).is_equal(8)
	assert_int(test_circuit.get_int_from_string("%B1111111111111111")).is_equal(65535)
	assert_int(test_circuit.get_int_from_string("%XFF")).is_equal(255)
	test_circuit.free()


func test_get_ios_from_hdl() -> void:
	var test_circuit = TestCircuit.new()
	assert_object(test_circuit.get_ios_from_hdl(hdl_file)).is_equal({
		"title": "ALU",
		"inputs": [["x[16]", 1], ["y[16]", 1], ["zx", 0], ["nx", 0], ["zy", 0], ["ny", 0], ["f", 0], ["no", 0]],
		"outputs": [["out[16]", 1], ["zr", 0], ["ng", 0]]
	})
	test_circuit.free()
