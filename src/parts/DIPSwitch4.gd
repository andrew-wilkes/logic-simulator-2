class_name DipSwitch4

extends Part

var switches = []
var inputs = [] # List of sides that are the input to a switch

func _init():
	category = UTILITY
	order = 90


func _ready():
	super()
	for node in get_children():
		if node is HBoxContainer:
			switches.append(node.get_child(1))
	switches.pop_back() # Remove the label
	inputs.resize(switches.size())
	inputs.fill(LEFT)
	var idx = 0
	for sw in switches:
		sw.pressed.connect(switch_changed.bind(idx))
		idx += 1


func evaluate_output_level(side, port, level):
	inputs[port] = side
	if switches[port].button_pressed:
		update_output_level(FLIP_SIDES[side], port, level)


func switch_changed(idx):
	if switches[idx].button_pressed:
		controller.reset_race_counters() # Cause V+ or Gnd to emit their levels
		# Propagate the input level to the output
		update_output_level(FLIP_SIDES[inputs[idx]], idx, pins.get([inputs[idx], idx], false))
