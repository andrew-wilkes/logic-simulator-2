# GdUnit generated TestSuite
class_name IOTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://parts/io.gd'


func test_update_output_levels_from_value() -> void:
	var part = IO.new()
	part.num_wires = 16
	# Output to left side
	part.update_output_levels_from_value([0], 0xaaaa)
	assert_int(part.pins.size()).is_equal(16)
	var sum = 0
	for n in 16:
		sum += int(part.pins[[0, n + 3]])
	assert_int(sum).is_equal(8)
	# Output to both sides
	part.update_output_levels_from_value([0, 1], 0xffff)
	assert_int(part.pins.size()).is_equal(32)
	sum = 0
	for n in 16:
		sum += int(part.pins[[0, n + 3]])
	assert_int(sum).is_equal(16)
	part.free()


func test_evaluate_output_level() -> void:
	var part = monitor_signals(IO.new())
	part.num_wires = 4
	part.show_display = false
	part.pins[[0, 5]] = true
	# This would be called if there was a new input level to port 5 (D2) on the left side
	part.evaluate_output_level(0, 5, true)
	await assert_signal(part).is_emitted('bus_value_changed', [part, 1 ,2, 0x04])
