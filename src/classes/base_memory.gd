extends Part

class_name BaseMemory

signal data_loaded()

var values = []
var probes = []
var max_value = 0
var mem_size = 0
var current_address := 0

func update_probes():
	for probe in probes:
		probe.update_data()


func _on_size_text_submitted(new_text):
	if new_text.length() > 0:
		if new_text.is_valid_int() or new_text.right(1) in ["K", "M"]\
			and new_text.left(-1).is_valid_int():
				data.size = new_text
				mem_size = get_mem_size(data.size)


func _on_bits_text_submitted(new_text):
	if new_text.is_valid_int():
		data.bits = clampi(int(new_text), 1, 1024)
		set_max_value()


func set_max_value():
	max_value = int(pow(2, data.bits) - 1)


func get_mem_size(dsize: String) -> int:
	var n = 0
	if dsize.is_valid_int():
		n = int(dsize)
	else:
		n = int(dsize.left(-1))
		if dsize.right(1) == "M":
			n *= 1024
		n *= 1024
	return n


func resize_memory(num_bytes):
	values.resize(num_bytes)
	values.fill(0)


func load_data(file_path):
	values.fill(0)
	var num_words = 0
	if file_path.get_extension() == "hack":
		# .hack files contain binary strings
		var ints = G.hack_to_array_of_int(FileAccess.get_file_as_string(file_path))
		if ints.size() > values.size():
			resize_memory(ints.size())
		for addr in ints.size():
			values[addr] = ints[addr]
			num_words += 1
	else:
		var bytes = FileAccess.get_file_as_bytes(file_path)
		if values.size() < bytes.size():
			# Load 16 bit words
			for idx in range(0, bytes.size(), 2):
				@warning_ignore("integer_division")
				if idx / 2 == values.size():
					values.append(0) # Prevent possible overflow
				values[idx / 2] = bytes[idx] + 256 * bytes[idx + 1]
				num_words += 1
		else:
			# Copy bytes
			num_words = bytes.size()
			for idx in num_words:
				values[idx] = bytes[idx]
	G.notify_user(str(num_words) + " words of data was loaded.")
	emit_signal("data_loaded")
