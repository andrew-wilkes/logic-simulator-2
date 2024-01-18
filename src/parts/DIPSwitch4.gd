class_name DipSwitch4

extends Part

var switches = []

func _init():
	category = UTILITY
	order = 84


func _ready():
	super()
	for node in get_children():
		if node is HBoxContainer:
			switches.append(node.get_child(1))
	var idx = 0
	for sw in switches:
		sw.pressed.connect(switch_changed.bind(idx))
		idx += 1


func evaluate_output_level(port, level):
	if switches[port].button_pressed:
		update_output_level(port, level)


func switch_changed(idx):
	if switches[idx].button_pressed:
		controller.reset_race_counters() # Cause V+ or Gnd to emit their levels
		# Propagate the input level to the output
		update_output_level_with_color(idx, pins.get([LEFT, idx], false))
	else:
		# Set output to white color
		set_slot_color_right(idx, Color.WHITE)
