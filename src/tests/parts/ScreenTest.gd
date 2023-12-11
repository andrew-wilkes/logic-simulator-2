# GdUnit generated TestSuite
class_name ScreenTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://parts/Screen.gd'


func test_get_word_from_number() -> void:
	var inst = Screen.new()
	assert_int(inst.get_word_from_number(0)).is_equal(0)
	assert_int(inst.get_word_from_number(-1)).is_equal(0xffff)
	assert_int(inst.get_word_from_number(0xffff)).is_equal(1)
	assert_int(inst.get_word_from_number(0xfffe)).is_equal(2)
	inst.free()
