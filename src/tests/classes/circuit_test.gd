# GdUnit generated TestSuite
class_name CircuitTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://classes/circuit.gd'
const temp_file = "res://temp.res"

func test_save_data() -> void:
	var circuit = Circuit.new()
	circuit.title = "Test Circuit"
	# Should save file that does not yet exist whilst checking for existence of file
	assert_int(circuit.save_data(temp_file, true)).is_equal(OK)
	assert_str(circuit.saved_to).is_equal(temp_file)
	circuit.saved_to = ""
	# Should detect existing file
	assert_int(circuit.save_data(temp_file, true)).is_equal(ERR_ALREADY_EXISTS)
	# User chooses to overwrite file
	assert_int(circuit.save_data(temp_file)).is_equal(OK)


func test_load_data() -> void:
	var circuit = Circuit.new().load_data(temp_file)
	assert_str(circuit.title).is_equal("Test Circuit")
	DirAccess.remove_absolute(temp_file)
	assert_int(Circuit.new().load_data("res://nofile.res")).is_equal(ERR_FILE_NOT_FOUND)


func test_get_next_id() -> void:
	var circuit = Circuit.new()
	assert_int(circuit.id_num).is_equal(0)
	assert_str(circuit.get_next_id()).is_equal("1")
	assert_str(circuit.get_next_id()).is_equal("2")
