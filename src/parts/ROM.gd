class_name ROM

extends RAM

var old_address := 0
var data_loaded_by_user = false

func _init():
	order = 2
	category = ASYNC
	data["bits"] = 16
	data["size"] = "8K"
	data["file"] = ""


func setup_instance():
	super()
	if file_exists():
		$DataLoader.values = values
		$DataLoader.load_data(data.file)


func evaluate_bus_output_value(port, _value):
	if port == 0: # Change of address
		set_output_data()


func set_output_data():
	current_address = pins.get([LEFT, 0], 0) % mem_size
	update_output_value(OUT, values[current_address])


func loaded_data():
	set_output_data()
	update_probes()
	if data_loaded_by_user:
		changed()


func open_file():
	data_loaded_by_user = true
	$DataLoader.open_file(values, data)


func _on_file_button_pressed():
	open_file()


func _on_inspect_button_pressed():
	controller.open_memory_manager(self)
