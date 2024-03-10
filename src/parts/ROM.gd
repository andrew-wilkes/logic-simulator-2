class_name ROM

extends BaseMemory

var old_address := 0
var data_loaded_by_user = false

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


func update_display():
	%Address.text = get_display_hex_value(current_address)
	%Data.text = get_display_hex_value(values[current_address])
