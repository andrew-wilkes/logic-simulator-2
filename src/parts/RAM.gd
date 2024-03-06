class_name RAM

extends BaseMemory

func _init():
	order = 80
	category = SYNC
	data["bits"] = 16
	data["size"] = "8K"


func _ready():
	super()
	if show_display:
		display_update_timer = Timer.new()
		get_child(-1).add_child(display_update_timer)
		display_update_timer.timeout.connect(update_display)
		display_update_timer.start(0.1)
	set_max_value()
	update()


func setup_instance():
	update()


func update():
	mem_size = get_mem_size(data.size)
	resize_memory(mem_size)
	if show_display:
		show_bits()


func show_bits():
		%Bits.text = str(data.bits)
		$Size.text = data.size


func evaluate_output_level(port, level):
	if port == 3: # clk edge
		current_address = get_address()
		if level:
			var ld = pins.get([LEFT, 2], false)
			if ld:
				var value = pins.get([LEFT, 0], 0)
				update_value(value, current_address)
				update_probes()
		else:
			update_output_value(OUT, values[current_address])


func get_address():
	return pins.get([LEFT, 1], 0) % mem_size


func update_value(value: int, address: int):
	values[address % mem_size] = value


func evaluate_bus_output_value(port, value: int):
	if port == 1: # Change of address
		current_address = value % mem_size
		update_output_value(OUT, values[current_address])


func reset():
	super()
	values.fill(0)


func erase():
	values.fill(0)
	update_output_value(OUT, 0)
	update_probes()


func set_value(address, value):
	values[address] = value
	if address == get_address():
		update_output_value(OUT, value)


func update_display():
	%Address.text = get_display_hex_value(current_address)
	%Data.text = get_display_hex_value(values[current_address])
