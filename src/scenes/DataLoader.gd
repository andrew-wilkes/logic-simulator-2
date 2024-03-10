extends FileDialog

signal loaded_data()

var values: Array
var data: Dictionary

func open_file(ref_of_memory_values, ref_of_data):
	values = ref_of_memory_values
	data = ref_of_data
	if not data.file.is_empty():
		current_dir = data.file.get_base_dir()
		current_file = data.file.get_file()
	elif G.settings.test_dir.is_empty():
		current_dir = G.settings.last_dir
	else:
		current_dir = G.settings.test_dir
	popup_centered()


func load_data(file_path):
	values.fill(0)
	var num_words = 0
	if file_path.get_extension() == "hack":
		# .hack files contain binary strings
		var ints = G.hack_to_array_of_int(FileAccess.get_file_as_string(file_path))
		for addr in ints.size():
			values[addr] = ints[addr]
			num_words += 1
	else:
		var bytes = FileAccess.get_file_as_bytes(file_path)
		if values.size() < bytes.size():
			# Load 16 bit words
			for idx in range(0, bytes.size(), 2):
				@warning_ignore("integer_division")
				values[idx / 2] = bytes[idx] + 256 * bytes[idx + 1]
				num_words += 1
		else:
			# Copy bytes
			num_words = bytes.size()
			for idx in num_words:
				values[idx] = bytes[idx]
	G.notify_user(str(num_words) + " words of data was loaded.")
	emit_signal("loaded_data")


func _on_file_selected(file_path):
	load_data(file_path)
	data.file = file_path
