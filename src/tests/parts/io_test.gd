# GdUnit generated TestSuite
class_name NandTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://parts/io.gd'


func test_output_value_and_levels() -> void:
	var part = IO.new()
	part.num_wires = 16
	part.output_value_and_levels(0)
	assert_int(part.pins.size()).is_equal(17)
	var sum = 0
	for n in 17:
		sum += int(part.pins[[1, n + 2]])
	assert_int(sum).is_equal(0)
	part.output_value_and_levels(0xffff)
	assert_int(part.pins[[1, 2]]).is_equal(0xffff)
	sum = 0
	for n in 16:
		sum += int(part.pins[[1, n + 3]])
	assert_int(sum).is_equal(16)
	part.free()
