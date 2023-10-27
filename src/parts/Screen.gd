class_name Screen

extends Part

var max_value = 0xffff
var max_address = 8 * 1024 - 1
var values = []
var pixels
var texture

func _init():
	order = 0
	category = UTILITY
	pins = { [0, 0]: 0, [0, 1]: 0, [1, 0]: 0 }
	data = {
		pixel_color = Color.WHITE,
		screen_color = Color.DARK_BLUE
	}


func _ready():
	super()
	resize_memory(max_address + 1)
	# Assign an image to the screen shader
	pixels = Image.create(512, 256, false, Image.FORMAT_RGBA8)
	pixels.fill(data.screen_color)
	texture = ImageTexture.create_from_image(pixels)
	$M/Pixels.material.set_shader_parameter("pixels", texture)


func evaluate_output_level(side, port, level):
	if side == LEFT:
		var address = clampi(pins[[side, 1]], 0, max_address)
		if port == 3: # clk
			if level:
				if pins[[side, 2]]: # load
					var value = clampi(pins[[side, 0]], 0, max_value)
					# Put code here to update pixels that need to change
					values[address] = value
			else:
				set_output_data()


func evaluate_bus_output_value(side, port, _value):
	if side == LEFT and port == 1: # Change of address
		set_output_data()


func set_output_data():
	var address = clampi(pins[[LEFT, 1]], 0, max_address)
	$Address.text = "%04X" % [address]
	$Data.text = "%02X" % [values[address]]
	update_output_value(RIGHT, 0, values[address])


func resize_memory(num_bytes):
	values.resize(num_bytes)
	values.fill(0)


func reset():
	values.fill(0)
	pixels.fill(data.screen_color)
	texture.update(pixels)


# Temporary test code to draw pixels on the screen when tapping the keyboard
func _unhandled_key_input(_event):
	pixels.set_pixel(512 * randf(), 80 * randf(), data.pixel_color)
	texture.update(pixels)
