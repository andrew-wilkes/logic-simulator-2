# GdUnit generated TestSuite
class_name CircuitTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://classes/circuit.gd'

const temp_file = "res://temp.circ"

func test_convert_colors_to_rgba_strings() -> void:
	var data = {
		"x": 10,
		"bg_color": Color.MAGENTA
	}
	var circuit = Circuit.new()
	circuit.convert_colors_to_rgba_strings(data)
	assert_str(data.bg_color).is_equal(Color.MAGENTA.to_html())


func test_convert_rgba_strings_to_colors() -> void:
	var data = {
		"x": 10,
		"bg_color": "#ff00ffff"
	}
	var circuit = Circuit.new()
	circuit.convert_rgba_strings_to_colors(data)
	assert_object(data.bg_color).is_equal(Color.MAGENTA)
	data.bg_color = "ff0"
	circuit.convert_rgba_strings_to_colors(data)
	assert_object(data.bg_color).is_equal(Color.YELLOW)


func test_save_data() -> void:
	var circuit = Circuit.new()
	circuit.data.title = "Test Circuit"
	# Should save file that does not yet exist whilst checking for existence of file
	assert_int(circuit.save_data(temp_file, true)).is_equal(OK)
	assert_str(circuit.data.saved_to).is_equal(temp_file)
	circuit.data.saved_to = ""
	# Should detect existing file
	assert_int(circuit.save_data(temp_file, true)).is_equal(ERR_ALREADY_EXISTS)
	# User chooses to overwrite file
	assert_int(circuit.save_data(temp_file)).is_equal(OK)


func test_load_data() -> void:
	var circuit = Circuit.new()
	circuit.load_data(temp_file)
	assert_str(circuit.data.title).is_equal("Test Circuit")
	DirAccess.remove_absolute(temp_file)
	assert_int(Circuit.new().load_data("res://nofile.circ")).is_equal(ERR_FILE_NOT_FOUND)


func test_get_next_id() -> void:
	var circuit = Circuit.new()
	assert_int(circuit.data.id_num).is_equal(0)
	assert_str(circuit.get_next_id()).is_equal("1")
	assert_str(circuit.get_next_id()).is_equal("2")
