class_name Screen

extends RAM

var pixels
var texture

func _init():
	super()
	order = 0
	category = UTILITY
	display_values = false
	data["pixel_color"] = Color.WHITE
	data["screen_color"] = Color.DARK_BLUE


func _ready():
	super()
	# Assign an image to the screen shader
	pixels = Image.create(512, 256, false, Image.FORMAT_RGBA8)
	pixels.fill(data.screen_color)
	texture = ImageTexture.create_from_image(pixels)
	$M/Pixels.material.set_shader_parameter("pixels", texture)
	if get_parent().name == "root":
		test()


func test():
	var start_time = Time.get_ticks_msec()
	for address in 1024 * 8:
		update_value(0xff, address) # 0b0101010100000000
	print(Time.get_ticks_msec() - start_time)


func update_value(new_val, address):
	var old_val = values[address]
	values[address] = new_val
	# Convert negative integers
	if new_val < 0:
		new_val = 0xffff + new_val + 1
	if old_val < 0:
		old_val = 0xffff + old_val + 1
	var x = address % 32 * 16
	var y = address / 32
	for n in 16:
		if old_val & 1 != new_val & 1:
			pixels.set_pixel(x + n, y, data.pixel_color\
				if new_val & 1 else data.screen_color)
		old_val /= 2
		new_val /= 2
	texture.update(pixels)
