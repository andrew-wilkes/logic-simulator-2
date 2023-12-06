class_name RAM

extends BaseMemory

var max_value = 0
var max_address = 0

func _init():
	order = 80
	category = SYNC
	data["bits"] = 16
	data["size"] = "8K"


func _ready():
	super()
	set_max_value()
	max_address = get_max_address(data.size)
	resize_memory(max_address + 1)
	show_bits()


func show_bits():
		%Bits.text = str(data.bits)
		$Size.text = data.size


func _on_size_text_submitted(new_text):
	if new_text.length() > 0:
		if new_text.is_valid_int() or new_text.right(1) in ["K", "M"]\
			and new_text.left(-1).is_valid_int():
				data.size = new_text
				max_address = get_max_address(data.size)


func _on_bits_text_submitted(new_text):
	if new_text.is_valid_int():
		data.bits = clampi(int(new_text), 1, 1024)
		set_max_value()
	elif show_display:
		%Bits.text = ""


func set_max_value():
	max_value = int(pow(2, data.bits) - 1)


func get_max_address(dsize: String) -> int:
	var n = 0
	if dsize.is_valid_int():
		n = int(dsize)
	else:
		n = int(dsize.left(-1))
		if dsize.right(1) == "M":
			n *= 1024
		n *= 1024
	return n - 1


func evaluate_output_level(side, port, _level):
	if side == LEFT:
		var address = clampi(pins.get([LEFT, 1], 0), 0, max_address)
		var ld = pins.get([LEFT, 2], false)
		var clk = pins.get([LEFT, 3], false)
		if clk and ld:
			var value = clampi(pins.get([LEFT, 0], 0), -max_value - 1, max_value)
			update_value(value, address)
			update_probes()
		if port == 3 and not clk:
			set_output_data()


func update_value(value, address):
	values[address] = value


func evaluate_bus_output_value(side, port, _value):
	if side == LEFT and port == 1: # Change of address
		set_output_data()


func set_output_data(address = -1):
	if address < 0:
		address = clampi(pins.get([LEFT, 1], 0), 0, max_address)
	if show_display:
		%Address.text = get_display_hex_value(address)
		%Data.text = get_display_hex_value(values[address])
	update_output_value(RIGHT, OUT, values[address])
	for probe in probes:
		probe.update_data()


func resize_memory(num_bytes):
	values.resize(num_bytes)
	values.fill(0)


func reset():
	super()
	values.fill(0)
