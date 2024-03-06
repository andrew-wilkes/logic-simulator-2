class_name ROM

extends BaseMemory

var old_address := 0

func _init():
	order = 2
	category = ASYNC
	data["bits"] = 16
	data["size"] = "8K"
	data["file"] = ""


func _ready():
	super()
	%Bits.text = str(data.bits)
	$Size.text = data.size
	if show_display:
		display_update_timer = Timer.new()
		get_child(-1).add_child(display_update_timer)
		display_update_timer.timeout.connect(update_display)
		display_update_timer.start(0.1)


func setup_instance():
	set_max_value()
	mem_size = get_mem_size(data.size)
	resize_memory(mem_size)
	if file_exists():
		load_data(data.file, false)


func evaluate_bus_output_value(port, _value):
	if port == 0: # Change of address
		set_output_data()


func set_output_data():
	current_address = pins.get([LEFT, 0], 0) % mem_size
	update_output_value(OUT, values[current_address])


func open_file():
	if not data.file.is_empty():
		$FileDialog.current_dir = data.file.get_base_dir()
		$FileDialog.current_file = data.file.get_file()
	elif G.settings.test_dir.is_empty():
		$FileDialog.current_dir = G.settings.last_dir
	else:
		$FileDialog.current_dir = G.settings.test_dir
	$FileDialog.popup_centered()


func _on_file_dialog_file_selected(file_path: String):
	load_data(file_path)
	data.file = file_path


func load_data(file_path, signal_changed = true):
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
		for idx in range(0, bytes.size(), 2):
			@warning_ignore("integer_division")
			values[idx / 2] = bytes[idx] + 256 * bytes[idx + 1]
			num_words += 1
	G.notify_user(str(num_words) + " words of data was loaded.")
	set_output_data()
	update_probes()
	if signal_changed:
		changed()


func update_display():
	%Address.text = get_display_hex_value(current_address)
	%Data.text = get_display_hex_value(values[current_address])
