class_name Memory

extends RAM

func _init():
	super()
	order = 0
	category = SYNC
	data["size"] = "16K"


func evaluate_output_level(side, port, level):
	if side == LEFT:
		var address = pins[[side, 1]]
		if address >= 0x4000 and address < 0x6000 and port == 2: # load
			update_output_level(RIGHT, 3, level) # screen_load
		else:
			super(side, port, level)
		if port == 3: # clk
			update_output_level(RIGHT, 4, level) # clk_out


func update_value(value, address):
	if address < 0x4000: # Write to 16K RAM
		values[address] = value


func evaluate_bus_output_value(side, port, value):
	if side == LEFT:
		var address = pins[[side, 1]]
		if port == 1: # Change of address
			if address >= 0x4000 and address < 0x6000: # pass on screen address value
				update_output_value(RIGHT, 2, address - 0x4000)
			elif address < 0x4000: # Output 16K RAM value
				update_output_value(RIGHT, 0, values[value])
			elif address == 0x6000: # Output keyboard pin value
				update_output_value(RIGHT, 0, pins[[side, 4]])
		elif port == 0: # Change of data
			if address >= 0x4000 and address < 0x6000:
				update_output_value(RIGHT, 1, value) # screen_data output
		elif port == 4: # keyboard
			if address == 0x6000:
				update_output_value(RIGHT, 0, pins[[side, 4]])
		elif port == 5: # screen_data input
			if address >= 0x4000 and address < 0x6000:
				update_output_value(RIGHT, 0, value)
