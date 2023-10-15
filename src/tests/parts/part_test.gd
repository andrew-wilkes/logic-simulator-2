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
	assert_object(part.race_counter).is_equal({})
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
	part.controller = self
	part.evaluate_output_level(1, 2, true)
	assert_object(part.data.result).is_equal([0 ,2, true])
	part.free()


func output_level_changed_handler(part, side, port, level):
	part.data["result"] = [side, port, level]


func test_evaluate_bus_output_value() -> void:
	var part = Part.new()
	part.controller = self
	part.evaluate_bus_output_value(0, 0, 65535)
	assert_object(part.data.result).is_equal([1 ,0, 65535])
	part.free()


func bus_value_changed_handler(part, side, port, value):
	part.data["result"] = [side, port, value]


func test_update_input_level() -> void:
	var part = monitor_signals(Part.new())
	part.controller = self
	part.update_input_level(1, 2, true)
	assert_object(part.data.result).is_equal([0 ,2, true])
	assert_dict(part.pins).has_size(2)
	assert_bool(part.pins[[1,2]]).is_equal(true)
	assert_int(part.race_counter[[1,2]]).is_equal(1)
	part.data["result"] = null
	part.update_input_level(1, 2, true)
	assert_object(part.data.result).is_equal(null)
	part.update_input_level(1, 2, false)
	assert_object(part.data.result).is_equal([0 ,2, false])


func test_update_bus_input_value() -> void:
	var part = monitor_signals(Part.new())
	part.controller = self
	part.update_bus_input_value(0, 4, 17)
	assert_object(part.data.result).is_equal([1 ,4, 17])
	assert_int(part.pins[[0, 4]]).is_equal(17)
	part.data["result"] = null
	part.update_bus_input_value(0, 4, 17)
	assert_object(part.data.result).is_equal(null)
	part.update_bus_input_value(0, 5, 18)
	assert_object(part.data.result).is_equal([1 ,5, 18])
	assert_int(part.pins.size()).is_equal(4)
