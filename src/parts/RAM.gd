class_name RAM

extends Part

var max_value = 0
var max_address = 0
var values = []
var display_values = true

func _init():
	order = 80
	category = SYNC
	data["bits"] = 16
	data["size"] = "8K"
	pins = { [0, 0]: 0, [0, 1]: 0, [0, 2]: false, [0, 3]: false, [1, 0]: 0 }


func _ready():
	super()
	update()


func update():
	set_max_value()
	max_address = get_max_address(data.size)
	resize_memory(max_address + 1)
	if display_values:
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
	else:
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


func evaluate_output_level(side, port, level):
	if side == LEFT:
		var address = clampi(pins[[side, 1]], 0, max_address)
		if port == 3: # clk
			if level:
				if pins[[side, 2]]: # load
					var value = clampi(pins[[side, 0]], -max_value - 1, max_value)
					update_value(value, address)
			else:
				set_output_data()


func update_value(value, address):
	values[address] = value


func evaluate_bus_output_value(side, port, _value):
	if side == LEFT and port == 1: # Change of address
		set_output_data()


func set_output_data():
	var address = clampi(pins[[LEFT, 1]], 0, max_address)
	%Address.text = "%04X" % [address]
	%Data.text = "%04X" % [values[address]]
	update_output_value(RIGHT, OUT, values[address])


func resize_memory(num_bytes):
	values.resize(num_bytes)
	values.fill(0)


func reset():
	super()
	values.fill(0)
