extends MarginContainer

signal bus_color_changed(part, color)
signal wire_color_changed(part, color)

const DEFAULT_SLIDER_LIMIT = 0xff
const PIN_NAMES_BUTTON_TEXTS = [ "Edit pin names", "Apply pin names" ]

@onready var color_picker = $HB/ColorPicker

var part
var step := 0
var set_bus_color = false
var set_wire_color = false
var slider_value_changed = false

func open(_part: IO):
	part = _part
	hide_pin_names()
	hide_color_picker()
	set_button_text_colors()
	list_pin_names()
	set_range(part.data.range)
	%Value.display_value(part.current_value, true, true)
	%NumWires.value = part.data.num_wires
	slider_value_changed = false
	set_slider_value()


func hide_color_picker():
	color_picker.hide()
	get_parent().size = Vector2.ZERO
	set_bus_color = false
	set_wire_color = false


func _on_bus_color_pressed():
	set_wire_color = false
	if set_bus_color:
		hide_color_picker()
	else:
		hide_pin_names()
		set_bus_color = true
		color_picker.color = part.data.bus_color
		color_picker.show()


func _on_wire_color_pressed():
	set_bus_color = false
	if set_wire_color:
		hide_color_picker()
	else:
		hide_pin_names()
		set_wire_color = true
		color_picker.color = part.data.wire_color
		color_picker.show()


func set_button_text_colors():
	$HB/VB/WireColor.set("theme_override_colors/font_color", part.data.wire_color)
	$HB/VB/BusColor.set("theme_override_colors/font_color", part.data.bus_color)


func _on_color_picker_color_changed(color):
	if set_wire_color:
		part.data.wire_color = color_picker.color
	else:
		part.data.bus_color = color_picker.color
	set_button_text_colors()
	part.set_pin_colors()
	part.controller.set_io_connection_colors(part)
	part.changed()


func _on_pins_button_pressed():
	if $HB/Pins.visible:
		hide_pin_names()
		part.data.labels = %Names.text.split("\n")
		part.set_labels()
		part.changed()
		%PinsButton.text = PIN_NAMES_BUTTON_TEXTS[0]
	else:
		hide_color_picker()
		$HB/Pins.show()
		%PinsButton.text = PIN_NAMES_BUTTON_TEXTS[1]


func _on_gen_pin_names_button_pressed():
	%Names.clear()
	var prefix = %Prefix.text
	var suffix = %Suffix.text
	var txt = PackedStringArray([prefix])
	for n in %NumWires.value:
		txt.append(prefix + str(n) + suffix)
	%Names.text = "\n".join(txt)


func hide_pin_names():
	$HB/Pins.hide()
	get_parent().size = Vector2.ZERO


func list_pin_names():
	%Names.text = "\n".join(part.data.labels)


func _on_up_button_pressed():
	up_down_initiate(1)


func _on_down_button_pressed():
	up_down_initiate(-1)


func up_down_initiate(_step):
	step = _step
	change_value()
	update_value()
	$RepeatTimer.start(0.5)


func _on_v_slider_value_changed(value):
	var limit = DEFAULT_SLIDER_LIMIT
	if part.data.range > 0:
		limit = part.data.range
	part.current_value = int(value * limit / %VSlider.max_value)
	slider_value_changed = true
	%Value.display_value(part.current_value, true, true)
	$UpdateTimer.start()


func _on_repeat_timer_timeout():
	match step:
		1:
			if not %UpButton.button_pressed:
				step = 0
		-1:
			if not %DownButton.button_pressed:
				step = 0
	if step != 0:
		change_value()
		update_value()
		# Possible Godot 4 bug here. $RepeatTimer.start() uses last value
		# rather than the default value.
		$RepeatTimer.start(0.1)


func change_value():
	if part.data.range > 0:
		part.current_value = clampi(part.current_value + step, 0, part.data.range)
	else:
		part.current_value = posmod(part.current_value + step, DEFAULT_SLIDER_LIMIT + 1)
	%Value.display_value(part.current_value, true, true)
	set_slider_value()


func _on_update_timer_timeout():
	update_value()


func set_slider_value():
	if slider_value_changed:
		slider_value_changed = false
	else:
		# Update slider position and ignore its signal
		var limit = DEFAULT_SLIDER_LIMIT
		if part.data.range > 0:
			limit = part.data.range
		%VSlider.set_value_no_signal(part.current_value * %VSlider.max_value / limit)


func set_range(value):
	%Range.text = part.get_formatted_hex_string(value)
	%Range.caret_column = %Range.text.length()


func _on_range_text_submitted(new_text):
	var value = 0
	if new_text.is_valid_int():
		value = int(new_text)
	if new_text.is_valid_hex_number(true):
		value = new_text.hex_to_int()
	set_range(value)
	part.data.range = value
	part.changed()


func _on_num_wires_value_changed(value):
	var new_num = clampi(value, 1, 256)
	if new_num != part.data.num_wires:
		part.data.num_wires = new_num
		part.set_pins()
		part.changed()


func _on_hidden():
	hide_color_picker()
	%PinsButton.text = PIN_NAMES_BUTTON_TEXTS[0]


func _on_value_value_changed(value):
	part.current_value = value
	update_value()
	set_slider_value()


func update_value():
	part.controller.reset_race_counters()
	part.evaluate_bus_output_value(0, 0, part.current_value)
	part.evaluate_bus_output_value(1, 0, part.current_value)
