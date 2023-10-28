class_name Memory

extends RAM

# Map the pins
enum { RAM_IN, RAM_ADDRESS, RAM_LOAD, RAM_CLK, RAM_KEYBOARD, RAM_SCREEN }
enum { RAM_OUT, RAM_SCREEN_DATA, RAM_SCREEN_ADDRESS, RAM_SCREEN_LOAD, RAM_CLK_OUT }

const SCREEN_START_ADDRESS = 0x4000
const KEYBOARD_ADDRESS = 0x6000

func _init():
	super()
	order = 0
	category = SYNC
	data["size"] = "16K"


func evaluate_output_level(side, port, level):
	if side == LEFT:
		var address = pins[[side, 1]]
		if address >= SCREEN_START_ADDRESS and address < KEYBOARD_ADDRESS and port == RAM_LOAD:
			update_output_level(RIGHT, RAM_SCREEN_LOAD, level)
		else:
			super(side, port, level)
		if port == RAM_CLK:
enum { RAM_OUT, RAM_SCREEN_DATA, RAM_SCREEN_ADDRESS, RAM_SCREEN_LOAD, RAM_CLK_OUT }
			update_output_level(RIGHT, RAM_CLK_OUT, level)


func update_value(value, address):
	if address < SCREEN_START_ADDRESS: # Write to 16K RAM
		values[address] = value


func evaluate_bus_output_value(side, port, value):
	if side == LEFT:
		var address = pins[[side, RAM_ADDRESS]]
		if port == RAM_IN and address >= SCREEN_START_ADDRESS and address < KEYBOARD_ADDRESS:
			update_output_value(RIGHT, RAM_SCREEN_DATA, value)
		elif port == RAM_ADDRESS:
			if address < SCREEN_START_ADDRESS: # Output 16K RAM value
				update_output_value(RIGHT, RAM_OUT, values[value]):
			elif address >= SCREEN_START_ADDRESS and address < KEYBOARD_ADDRESS: # Pass on screen address value
				update_output_value(RIGHT, RAM_SCREEN_ADDRESS, address - SCREEN_START_ADDRESS)
			elif address == 0x6000:
				update_output_value(RIGHT, RAM_OUT, pins[[side, RAM_KEYBOARD]])
		elif port == RAM_KEYBOARD and address == KEYBOARD_ADDRESS:
			update_output_value(RIGHT, RAM_OUT, pins[[side, RAM_KEYBOARD]])
		elif port == RAM_SCREEN and address >= SCREEN_START_ADDRESS and address < KEYBOARD_ADDRESS:
			update_output_value(RIGHT, RAM_OUT, value)
