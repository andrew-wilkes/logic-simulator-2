class_name Display

extends Part

var ports = [ false, false, false, false, false, false, false, false ]
var previous_ports

func _init():
	order = 80
	category = UTILITY
	@warning_ignore("integer_division")
	data = {
		color_index = 1 + 128 / 3,
		num_digits = 1
	}


func _ready():
	super()
	if show_display:
		display_update_timer = Timer.new()
		get_child(-1).add_child(display_update_timer)
		display_update_timer.timeout.connect(update_segments)
		display_update_timer.start(0.1)
	previous_ports = ports.duplicate()
	set_color(data.color_index)
	%Hue.set_value_no_signal(data.color_index)


func evaluate_output_level(port, level):
	ports[port] = level


func update_segments():
	var idx = 0
	for level in ports:
		if previous_ports[idx] != level:
			%Segments.material.set_shader_parameter(["a","b","c","d","e","f","g","dp"][idx], level)
		idx += 1
	previous_ports = ports.duplicate()


func _on_hue_value_changed(value):
	set_color(int(value))
	changed()


func set_color(color_index):
	# There are 129 steps of color_index
	# 0 sets black bg and white segments
	# 1 .. 128 sets black bg and colored segments based on hue value
	# 129 sets white bg and black segments
	var color
	var bg_color
	match color_index:
		0:
			color = Color.WHITE
			bg_color = Color.BLACK
		129:
			color = Color.BLACK
			bg_color = Color.WHITE
		_:
			color = Color.from_hsv((color_index - 1) / 128.0, 1.0, 1.0)
			bg_color = Color.BLACK
	set_digit_colors(color, bg_color)
	data.color_index = int(color_index)


func set_digit_colors(color, bg_color):
	%Segments.material.set_shader_parameter("color", color)
	%Segments.material.set_shader_parameter("bg_color", bg_color)


func setup():
	# This is needed to have separated shaders for the displays so that they don't sync their segment colors.
	# Marking the material as unique in the Editor does not achieve this aim.
	%Segments.material = %Segments.material.duplicate()
