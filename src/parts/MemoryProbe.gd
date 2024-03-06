class_name MemoryProbe

extends Part

# This needs to be set when connecting to this part
var memory: Part
var current_value = 0

func _init():
	category = UTILITY
	order = 72
	data["address"] = 0


func _ready():
	super()
	if show_display:
		display_update_timer = Timer.new()
		get_child(-1).add_child(display_update_timer)
		display_update_timer.timeout.connect(display_data)
		display_update_timer.start(0.1)
	%Address.display_value(data.address, false, false)


# Need to block updates from bus input from changing the output
# The bus input is used to link the probe to a memory chip
func update_bus_input_value(__port, _value):
	pass


func fetch_data():
	if memory and memory.values.size() > data.address:
		return memory.values[data.address]
	else:
		return 0


# Called from Memory part when the values change
func update_data():
	current_value = fetch_data()
	update_output_value(OUT, current_value)


func display_data():
	%Data.text = get_display_hex_value(current_value)


func _on_address_value_changed(value):
	data.address = value
	update_data()
	changed()
