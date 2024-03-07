class_name ToggleSwitch

extends Part

var switch_output: CircuitInput

func _init():
	category = UTILITY
	order = 86


func setup():
	switch_output = CircuitInput.new()
	switch_output.name = name
	switch_output.port = OUT


func _on_button_toggled(button_pressed):
	switch_output.level = button_pressed
	controller.inject_circuit_input(switch_output)


func apply_power():
	switch_output.level = false
	controller.inject_circuit_input(switch_output)


func _on_tree_exiting():
	switch_output.free()
