class_name RAM

extends BaseMemory

func _init():
	order = 80
	category = SYNC
	data["bits"] = 16
	data["size"] = "8K"


func _ready():
	super()
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


func evaluate_output_level(side, port, level):
	if side == LEFT and port == 3: # clk edge
		var address = get_address()
		if level:
			var ld = pins.get([LEFT, 2], false)
			if ld:
				var value = pins.get([LEFT, 0], 0)
				update_value(value, address)
				update_probes()
		else:
			show_data(values[address])
			update_output_value(RIGHT, OUT, values[address])


func get_address():
	return pins.get([LEFT, 1], 0) % mem_size


func update_value(value: int, address: int):
	values[address % mem_size] = value


func evaluate_bus_output_value(side, port, value: int):
	if side == LEFT and port == 1: # Change of address
		show_address(value % mem_size)
		show_data(values[value % mem_size])
		update_output_value(RIGHT, OUT, values[value % mem_size])


func show_data(value):
	if show_display:
		%Data.text = get_display_hex_value(value)


func show_address(address: int):
	if show_display:
		%Address.text = get_display_hex_value(address)


func reset():
	super()
	values.fill(0)


func erase():
	values.fill(0)
	show_data(0)
	update_output_value(RIGHT, OUT, 0)
	update_probes()


func set_value(address, value):
	values[address] = value
	if address == get_address():
		update_output_value(RIGHT, OUT, value)
		show_address(address)
		show_data(value)
