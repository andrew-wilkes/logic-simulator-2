# GdUnit generated TestSuite
class_name Test
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://parts/Add.gd'


func test_evaluate_bus_output_value() -> void:
	var part = Add.new()
	part.controller = self
	part.evaluate_bus_output_value(0, 0)
	assert_object(part.data.result).is_equal([1 ,0, 0])
	
	part.data["result"] = null
	part.evaluate_bus_output_value(0, 400)
	assert_object(part.data.result).is_equal([1 ,0, 400])
	
	part.data["result"] = null
	part.evaluate_bus_output_value(1, 50)
	assert_object(part.data.result).is_equal([1 ,0, 450])
	
	part.data["result"] = null
	part.evaluate_bus_output_value(1, -150)
	assert_object(part.data.result).is_equal([1 ,0, 250])
	part.free()


func bus_value_changed_handler(part, port, level):
	part.data["result"] = [port, level]
