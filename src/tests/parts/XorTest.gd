# GdUnit generated TestSuite
class_name XorTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://parts/Xor.gd'


func test_evaluate_output_level() -> void:
	var part = XOR.new()
	part.controller = self
	part.update_input_level(0, 0, true, ClockState.new())
	assert_object(part.data.result).is_equal([1 ,0, true])
	
	part.data["result"] = null
	part.update_input_level(0, 0, false, ClockState.new())
	assert_object(part.data.result).is_equal([1 ,0, false])
	
	part.data["result"] = null
	part.update_input_level(0, 1, true, ClockState.new())
	assert_object(part.data.result).is_equal([1 ,0, true])
	
	part.data["result"] = null
	part.update_input_level(0, 0, true, ClockState.new())
	assert_object(part.data.result).is_equal([1 ,0, false])
	
	part.data["result"] = null
	part.update_input_level(0, 0, false, ClockState.new())
	assert_object(part.data.result).is_equal([1 ,0, true])
	
	part.data["result"] = null
	part.update_input_level(0, 1, false, ClockState.new())
	assert_object(part.data.result).is_equal([1 ,0, false])
	part.free()


func output_level_changed_handler(part, side, port, level):
	part.data["result"] = [side, port, level]
