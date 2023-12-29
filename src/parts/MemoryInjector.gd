class_name MemoryInjector

extends Part

var memory: Part

func _init():
	category = UTILITY
	order = 70
	data["address"] = 0


func _ready():
	super()
	%Address.display_value(data.address, false, false)


func evaluate_bus_output_value(_side, port, value):
	if port == 1 and memory:
		memory.update_value(value, data.address)
		memory.update_probes()


func _on_address_value_changed(value):
	data.address = value
	changed()
