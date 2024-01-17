# GdUnit generated TestSuite
class_name OrTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://parts/Or.gd'


func test_evaluate_output_level() -> void:
	var part = OR.new()
	part.controller = self
	part.update_input_level(0, true)
	assert_object(part.data.result).is_equal([1 ,0, true])
	
	part.data["result"] = null
	part.update_input_level(0, false)
	assert_object(part.data.result).is_equal([1 ,0, false])
	
	part.data["result"] = null
	part.update_input_level(1, true)
	assert_object(part.data.result).is_equal([1 ,0, true])
	
	part.data["result"] = null
	part.update_input_level(0, true)
	assert_object(part.data.result).is_equal(null)
	part.free()


func output_level_changed_handler(part, port, level):
	part.data["result"] = [port, level]
