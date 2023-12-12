class_name RAM

extends BaseMemory

var max_value = 0
var mem_size = 0

func _init():
	order = 80
	category = SYNC
	data["bits"] = 16
	data["size"] = "8K"
	clock_ports = [3]


func _ready():
	super()
	set_max_value()
	update()


func update():
	mem_size = get_mem_size(data.size)
	resize_memory(mem_size)
	show_bits()


func show_bits():
		%Bits.text = str(data.bits)
		$Size.text = data.size


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
	elif show_display:
		%Bits.text = ""


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


func evaluate_output_level(side, port, _level):
	if side == LEFT:
		var address = get_address()
		var ld = pins.get([LEFT, 2], false)
		var clk = pins.get([LEFT, 3], false)
		if clk and ld:
			var value = pins.get([LEFT, 0], 0)
			update_value(value, address)
			update_probes()
		if port == 3 and not clk:
			show_data(values[address])
			update_output_value(RIGHT, OUT, values[address])


func get_address():
	return pins.get([LEFT, 1], 0) % mem_size


func update_value(value: int, address: int):
	values[address % mem_size] = value


func evaluate_bus_output_value(side, port, value: int):
	if side == LEFT and port == 1: # Change of address
		show_address(value)
		show_data(values[value % mem_size])
		update_output_value(RIGHT, OUT, values[value % mem_size])


func show_data(value):
	if show_display:
		%Data.text = get_display_hex_value(value)


func show_address(address: int):
	if show_display:
		%Address.text = get_display_hex_value(address)


func resize_memory(num_bytes):
	values.resize(num_bytes)
	values.fill(0)


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
