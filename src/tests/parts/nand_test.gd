# GdUnit generated TestSuite
class_name NandTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://parts/nand.gd'

func test_evaluate_output_level() -> void:
	var part = monitor_signals(NAND.new())
	part.update_input_level(0, 1, true)
	await assert_signal(part).is_emitted('output_level_changed', [part, 1 ,1, true])
	part.update_input_level(0, 2, true)
	await assert_signal(part).is_emitted('output_level_changed', [part, 1 ,1, false])
	part.reset_race_counter()
	part.update_input_level(0, 1, false)
	await assert_signal(part).is_emitted('output_level_changed', [part, 1 ,1, true])
	part.update_input_level(0, 2, false)
	await assert_signal(part).wait_until(50).is_not_emitted('output_level_changed')
