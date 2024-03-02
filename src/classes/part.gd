class_name Part

# This is the base class for Parts

extends GraphNode

enum { LEFT, RIGHT }
enum { WIRE_TYPE, BUS_TYPE }
enum { UTILITY, ASYNC, SYNC, BLOCK }
enum { A,B,C,D }

# If this value is too low we get false flags.
# If too high get stack overflows with unstable circuits.
# A value of 10 seems to be a good choice when testing.
const RACE_COUNT_THRESHOLD = 10
const DEBUG = false
const IN = 0
const OUT = 0

# Part properties
var tag = ""
var part_type = ""
var category = ASYNC
var order = 0
var data = {}
var show_display = true
var controller # The schematic or a parent block
var race_counter = {} # [port]: count
var connections = [] # Used to store a sorted list of output connections
var pins = {} # [port]: level / value
var change_notification_timer: Timer

func get_dict():
	return {
		node_name = name,
		part_type = part_type,
		tag = get_node("Tag").text,
		show_display = show_display,
		offset = [position_offset.x, position_offset.y],
		data = data
	}


func _ready():
	gui_input.connect(_on_gui_input)
	if $Tag and $Tag.visible:
		$Tag.text_changed.connect(_on_tag_text_changed)
		$Tag.set("context_menu_enabled", false)
	change_notification_timer = Timer.new()
	get_child(-1).add_child(change_notification_timer)
	change_notification_timer.one_shot = true
	change_notification_timer.timeout.connect(_on_change_notification_timer_timeout)
	set("theme_override_constants/separation", 10)
	set("theme_override_constants/port_offset", -6)
	set("mouse_default_cursor_shape", CURSOR_DRAG)
	setup_instance()
	call_deferred("shrink_height")
	if get_parent().name == "root":
		controller = Controller.new()
		var free_ob = Callable(controller, "free")
		tree_exiting.connect(free_ob)


# Some parts such as BusColor have extra height for some reason when added to the scene
# So this can be call_deffered to correct it
func shrink_height():
	size.y = 0


# This function is used to set up vars that are needed by an instance of the class
func setup_instance():
	pass


func update_input_level(port, level):
	if DEBUG:
		prints("part update_input_level", self.name, port, level)
	var key = set_pin_value(LEFT, port, level)
	if key != null:
		if race_counter.has(key):
			race_counter[key] += 1
			if race_counter[key] == RACE_COUNT_THRESHOLD:
				controller.unstable_handler(self, port)
				return
		else:
			race_counter[key] = 1
		evaluate_output_level(port, level)


func set_pin_value(side, port, value):
	# value will be an int or a bool to handle a wire or a bus
	# The function returns null if there was no change or the pin key
	# This makes it easy to ignore no change to the level/value
	var key = [side, int(port)]
	if not pins.has(key):
		pins[key] = null
	if value == pins[key]:
		key = null
	else:
		pins[key] = value
	return key


func update_bus_input_value(port, value):
	if set_pin_value(LEFT, port, value) != null:
		evaluate_bus_output_value(port, value)


# Override this function in extended parts
func evaluate_output_level(port, level):
	if DEBUG:
		prints("part evaluate_output_level", self.name, port, level)
	# Put logic here to derive the new level
	update_output_level(port, level)


func update_output_level(port, level):
	if DEBUG:
		prints("part update_output_level", self.name, port, level)
	if set_pin_value(RIGHT, port, level) != null:
		controller.output_level_changed_handler(self, port, level)


# Override this function in extended parts
func evaluate_bus_output_value(port, value):
	# Put logic here to derive the new value
	update_output_value(port, value)


func update_output_value(port, value):
	if set_pin_value(RIGHT, port, value) != null:
		controller.bus_value_changed_handler(self, port, value)


# Override this function for custom setup of the Part when it is loaded into the Schematic
func setup():
	pass


func reset_race_counter():
	race_counter.clear()


# We can trigger opening of PopUp windows using this after a user right-clicks on a part
func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			controller.right_click_on_part(self)


func changed():
	change_notification_timer.start()
	size.x = 0 # To shrink the width after reducing the Tag text length


func _on_change_notification_timer_timeout():
	controller.emit_signal("changed")


func _on_tag_text_changed(_new_text):
	changed()


# Override this function to apply a reset of pins and values
func reset():
	pins = {}
	call_deferred("apply_power")


# Override this function to apply the levels from clocks or bias levels
func apply_power():
	pass


# Set the output pin color and emit the output level
func update_output_level_with_color(port, level):
	update_output_level(port, level)
	indicate_level(RIGHT, port, level)


func indicate_level(side, port, level):
	var color = G.settings.logic_high_color if level else G.settings.logic_low_color
	if side == LEFT:
		if port < get_input_port_count():
			var slot = get_input_port_slot(port)
			set_slot_color_left(slot, color)
	else:
		if port < get_output_port_count():
			var slot = get_output_port_slot(port)
			set_slot_color_right(slot, color)


func get_display_hex_value(value):
	if value < - 0x10000:
		return "HIGH-Z"
	if value < 0:
		value = 0x10000 + value
	return "0x%04X" % [value]


func get_value_from_text(new_text):
	var value = 0
	if new_text.is_valid_int():
		value = int(new_text)
	if new_text.is_valid_hex_number(true):
		value = new_text.hex_to_int()
	return value


func get_formatted_hex_string(x):
	if x < 0:
		return str(x)
	if x < 0x100:
		return "0x%02X" % x
	return "0x%04X" % x


func file_exists():
	if data.file.is_empty():
		return false
	if FileAccess.file_exists(data.file):
		return true
	G.warn_user("File missing at: " + data.file)
	if show_display: # Not loaded in a block
		data.file = ""
		controller.emit_signal("changed")
	return false
