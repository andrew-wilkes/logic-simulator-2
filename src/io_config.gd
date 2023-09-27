extends PopupPanel

signal num_bits_changed(part, num_bits)
signal value_changed(part, value)
signal bus_color_changed(part, color)
signal wire_color_changed(part, color)

var set_bus_color = false
var set_wire_color = false
var _wire_color
var _bus_color
var color_picker

func _ready():
	color_picker = $M/HB/ColorPicker
	hide_color_picker()
	setup(Color.YELLOW, Color.WHITE)


func setup(bus_color, wire_color):
	_bus_color = bus_color
	_wire_color = wire_color


func hide_color_picker():
	color_picker.hide()
	size = Vector2.ZERO
	set_bus_color = false
	set_wire_color = false


func _on_popup_hide():
	hide_color_picker()


func _on_bus_color_pressed():
	set_wire_color = false
	if set_bus_color:
		_bus_color = color_picker.color
		$M/HB/VB/BusLabel.modulate = _bus_color
		hide_color_picker()
	else:
		set_bus_color = true
		color_picker.color = _bus_color
		color_picker.show()


func _on_wire_color_pressed():
	set_bus_color = false
	if set_wire_color:
		_wire_color = color_picker.color
		$M/HB/VB/WireLabel.modulate = _wire_color
		hide_color_picker()
	else:
		set_wire_color = true
		color_picker.color = _wire_color
		color_picker.show()
