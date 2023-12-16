class_name Memory

# This is a specialized memory-mapper device called Memory in Nand2Tetris.
# It provides 16K of RAM from 0x0000 to 0x3fff and maps the display words from
# 0x4000 to 0x5fff (8K) and the Keyword data value maps to 0x6000
# It features an interface to the Screen which displays 256 rows and 512 columns
# of pixels.

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


func show_bits():
	pass # Mask off this RAM feature


func evaluate_output_level(side, port, level):
	if side == LEFT:
		# Direct the signals to the 16K RAM or the Screen
		var address = get_address()
		if address < SCREEN_START_ADDRESS:
			super(side, port, level)
		elif address < KEYBOARD_ADDRESS:
			if port == RAM_CLK:
				update_output_level(RIGHT, RAM_CLK_OUT, level)
			elif port == RAM_LOAD:
				update_output_level(RIGHT, RAM_SCREEN_LOAD, level)


func evaluate_bus_output_value(side, port, value):
	if side == LEFT:
		var address = get_address()
		if port == RAM_IN:
			# Pass changed data value to screen data bus
			update_output_value(RIGHT, RAM_SCREEN_DATA, value)
		elif port == RAM_ADDRESS:
			# Change of address
			show_address(address)
			if address < SCREEN_START_ADDRESS: # Output 16K RAM value
				update_output_value(RIGHT, RAM_OUT, values[value])
				show_data(values[value])
			elif address < KEYBOARD_ADDRESS: # Pass on screen address value
				update_output_value(RIGHT, RAM_SCREEN_ADDRESS, address - SCREEN_START_ADDRESS)
				# Output value from Screen memory
				update_output_value(RIGHT, RAM_OUT, pins.get([LEFT, RAM_SCREEN], 0))
				show_data(value)
			elif address == KEYBOARD_ADDRESS:
				value = pins.get([side, RAM_KEYBOARD], 0)
				update_output_value(RIGHT, RAM_OUT, value)
				show_data(value)
		elif port == RAM_KEYBOARD and address == KEYBOARD_ADDRESS:
			# Keyboard input value changed
			value = pins.get([side, RAM_KEYBOARD], 0)
			update_output_value(RIGHT, RAM_OUT, value)
			show_data(value)
		elif port == RAM_SCREEN and address >= SCREEN_START_ADDRESS and address < KEYBOARD_ADDRESS:
			update_output_value(RIGHT, RAM_OUT, value)
			show_data(value)


func get_address():
	return pins.get([LEFT, RAM_ADDRESS], 0) & 0x6fff
