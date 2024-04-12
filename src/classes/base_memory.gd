extends Part

class_name BaseMemory

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
