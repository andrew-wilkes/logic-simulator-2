class_name MemoryInjector

extends Part

var memory: Part

func _init():
	category = UTILITY
	order = 72
	data["address"] = 0


func _ready():
	super()
	if show_display:
		%Address.text_submitted.connect(_on_address_text_submitted)
		display_address(data.address)


func _on_address_text_submitted(new_text):
	data.address = get_value_from_text(new_text)
	display_address(data.address)
	changed()


func display_address(value):
	%Address.text = get_display_hex_value(value)
	# The following line avoids the caret blinking at the start of the text
	%Address.caret_column = %Address.text.length()


func evaluate_bus_output_value(_side, port, value):
	if port == 1 and memory:
		memory.update_value(value, data.address)
		memory.update_probes()
