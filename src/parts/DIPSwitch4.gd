class_name DipSwitch4

extends Part

var switches = []
var level_outputs = []

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


func setup():
	for idx in switches.size():
		var cin = CircuitInput.new()
		cin.part = self
		cin.port = idx
		level_outputs.append(cin)


func evaluate_output_level(port, level):
	if switches[port].button_pressed:
		update_output_level(port, level)


func switch_changed(idx):
	if switches[idx].button_pressed:
		var cin = level_outputs[idx]
		cin.level = pins.get([LEFT, idx], false)
		controller.inject_circuit_input(cin)
	else:
		# Set output to white color
		set_slot_color_right(idx, Color.WHITE)


func _on_tree_exiting():
	for cin in level_outputs:
		cin.free()
