# GdUnit generated TestSuite
class_name PartTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://parts/part.gd'

func test_reset_race_counter() -> void:
	var part = Part.new()
	part.race_counter = { 0: 3, 1: 2 }
	part.reset_race_counter()
	assert_object(part.race_counter).is_equal({ 0: 0, 1: 0 })
	part.free()


func test_set_pin_value() -> void:
	var part = Part.new()
	assert_object(part.set_pin_value(1, 2, true)).is_equal([1, 2])
	assert_bool(part.pins[[1, 2]]).is_equal(true)
	assert_bool(part.set_pin_value(1, 2, true) == null).is_equal(true)
	assert_bool(part.set_pin_value(1, 2, false) == null).is_equal(false)
	part.free()


func test_evaluate_output_level() -> void:
	var part = monitor_signals(Part.new())
	part.evaluate_output_level(1, 2, true)
	await assert_signal(part).is_emitted('output_level_changed', [part, 1 ,2, true])
	part.free()


func test_evaluate_bus_output_value() -> void:
	var part = monitor_signals(Part.new())
	part.evaluate_bus_output_value(0, 0, 65535)
	await assert_signal(part).is_emitted('bus_value_changed', [part, 1 ,1, 65535])
	part.free()


func test_update_input_level() -> void:
	var part = monitor_signals(Part.new())
	part.update_input_level(1, 2, true)
	await assert_signal(part).is_emitted('output_level_changed', [part, 1 ,2, true])
	assert_dict(part.pins).has_size(2)
	assert_bool(part.pins[[1,2]]).is_equal(true)
	assert_int(part.race_counter[[1,2]]).is_equal(1)
	part.update_input_level(1, 2, true)
	await assert_signal(part).wait_until(50).is_not_emitted('output_level_changed')
	part.reset_race_counter()
	part.update_input_level(1, 2, false)
	await assert_signal(part).is_emitted('output_level_changed', [part, 1 ,2, false])
	part.update_input_level(1, 2, true)
	await assert_signal(part).is_emitted('unstable', [part, 1 ,2])


func test_update_bus_input_value() -> void:
	var part = monitor_signals(Part.new())
	part.update_bus_input_value(0, 4, 17)
	await assert_signal(part).is_emitted('bus_value_changed', [part, 1 ,1, 17])
	assert_int(part.pins[[0, 4]]).is_equal(17)
	part.update_bus_input_value(0, 4, 17)
	await assert_signal(part).wait_until(50).is_not_emitted('bus_value_changed')
	part.update_bus_input_value(0, 5, 18)
	await assert_signal(part).is_emitted('bus_value_changed', [part, 1 ,1, 18])
	assert_int(part.pins.size()).is_equal(4)
