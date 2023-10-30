# GdUnit generated TestSuite
class_name TestTestCircuit
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://classes/test_circuit.gd'

const spec_file = "// This file is part of www.nand2tetris.org
// and the book \"The Elements of Computing Systems\"
// by Nisan and Schocken, MIT Press.
// File name: projects/02/Adder16.hdl
/**
 * 16-bit adder: Adds two 16-bit two's complement values.
 * The most significant carry bit is ignored.
 */

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
	assert_str(test_circuit.format_value(10, "D", 3)).is_equal(" 10")
	assert_str(test_circuit.format_value(10, "X", 4)).is_equal("000A")
	assert_str(test_circuit.format_value(21, "B", 8)).is_equal("00010101")
	test_circuit.free()


func test_set_output_header() -> void:
	var test_circuit = TestCircuit.new()
	test_circuit.output_format = "a%B1.3.1 b%D2.4.3"
	test_circuit.set_output_header()
	assert_str(test_circuit.output).is_equal("|  a  |    b    |\n")
	test_circuit.free()


func test_get_pin_list() -> void:
	var test_circuit = TestCircuit.new()
	test_circuit.tasks = [["output-list", "a%D1.3.1 bb%X1.1.1 ccc%B1.4.1 d"]]
	assert_object(test_circuit.get_pin_list()).is_equal(["a", "bb", "ccc", "d"])
	test_circuit.free()


func test_set_output_result() -> void:
	var test_circuit = TestCircuit.new()
	test_circuit.pin_states = { a = 1, bb = 10, ccc = 3, d = 0 }
	test_circuit.output_format = "a%D1.3.1 bb%X1.1.1 ccc%B1.4.1 d"
	test_circuit.set_output_result()
	assert_str(test_circuit.output).is_equal("|   1 | A | 0011 | 0 |")
	test_circuit.free()


func test_parse_spec() -> void:
	var test_circuit = TestCircuit.new()
	assert_object(test_circuit.parse_spec(spec_file)).is_equal([["load", "SimpleAdd.asm"], ["output-file", "SimpleAdd.out"], ["compare-to", "SimpleAdd.cmp"], ["echo", "Hello"], ["set", "RAM[0]", "256"], ["repeat", 4, "tick, output; tock, output;"], ["output-list", "RAM[0]%D2.6.2 RAM[2]%D2.6.2 aaa%D2.6.2"], ["output"]])
	test_circuit.free()


func test_get_int_from_string() -> void:
	var test_circuit = TestCircuit.new()
	assert_int(test_circuit.get_int_from_string("8")).is_equal(8)
	assert_int(test_circuit.get_int_from_string("%B1111111111111111")).is_equal(-1)
	assert_int(test_circuit.get_int_from_string("%B0111111111111111")).is_equal(32767)
	assert_int(test_circuit.get_int_from_string("%XFF")).is_equal(255)
	test_circuit.free()


func test_get_ios_from_hdl() -> void:
	var test_circuit = TestCircuit.new()
	assert_object(test_circuit.get_ios_from_hdl(hdl_file)).is_equal({
		"title": "ALU",
		"inputs": [["x", 1], ["y", 1], ["zx", 0], ["nx", 0], ["zy", 0], ["ny", 0], ["f", 0], ["no", 0]],
		"outputs": [["out", 1], ["zr", 0], ["ng", 0]]
	})
	test_circuit.free()


func test_clean_src() -> void:
	var test_circuit = TestCircuit.new()
	assert_str(test_circuit.clean_src(spec_file)).is_equal("load SimpleAdd.asm,output-file SimpleAdd.out,compare-to SimpleAdd.cmp,echo \"Hello\",set RAM[0] 256, repeat 4 { tick, output; tock, output;}output-list RAM[0] %D2.6.2 RAM[2]%D2.6.2 aaa %D2.6.2;output;")
	test_circuit.free()
