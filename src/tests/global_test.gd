# GdUnit generated TestSuite
class_name GlobalTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://global.gd'


func test_hack_to_array_of_int() -> void:
	var hack = "0000000000000010
1110110000010000
0000000000000011
1110000010010000
0000000000000000
1110001100001000
"
	assert_object(G.hack_to_array_of_int(hack)).is_equal([2,60432,3,57488,0,58120])
