# GdUnit generated TestSuite
class_name IOTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://parts/io.gd'


func test_update_output_levels_from_value() -> void:
	var part = IO.new()
	part.controller = self
	part.data.num_wires = 16
	# Output to left side
	part.update_output_levels_from_value(0xaaaa)
	assert_int(part.pins.size()).is_equal(16)
	var sum = 0
	for n in 16:
		sum += int(part.pins[[0, n + 1]])
	assert_int(sum).is_equal(8)
	# Output to both sides
	part.update_output_levels_from_value(0xffff)
	assert_int(part.pins.size()).is_equal(32)
	sum = 0
	for n in 16:
		sum += int(part.pins[[0, n + 1]])
	assert_int(sum).is_equal(16)
	part.free()


func test_evaluate_output_level() -> void:
	var part = IO.new()
	part.controller = self
	part.data.num_wires = 4
	part.show_display = false
	part.update_input_level(3, true)
	assert_object(part.data.bus).is_equal([1 ,0, 0x04])
	part.free()


func output_level_changed_handler(part, port, level):
	part.data["wires"] = [port, level]


func bus_value_changed_handler(part, port, value):
	part.data["bus"] = [port, value]
