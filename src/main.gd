extends Control

enum { NO_ACTION, NEW, OPEN, OPEN_AS_BLOCK, SAVE, SAVE_AS, QUIT, ABOUT }

var saved = false
var menu_action = NO_ACTION
var schematic

func _ready():
	schematic = $VB/Schematic
	var add_part_menu: PopupMenu = %AddPartMenu.get_popup()
	for part_name in Parts.names:
		add_part_menu.add_item(part_name)
	add_part_menu.index_pressed.connect(part_to_add)
	%ToolsButton.get_popup().add_item("Number parts")
	%ToolsButton.get_popup().index_pressed.connect(tool_action)
	schematic.connect("warning", $WarningPanel.open)
	schematic.connect("changed", set_current_file_color)


func part_to_add(part_index):
	var part_name = Parts.names[part_index]
	schematic.add_part_by_name(part_name)


func tool_action(idx):
	match idx:
		0:
			schematic.number_parts()

#### FILE CODE ####

func _on_save_button_pressed():
	do_action(SAVE)


func _on_save_as_button_pressed():
	G.settings.current_file = ""
	do_action(SAVE)


func _on_load_button_pressed():
	do_action(OPEN)


func _on_block_button_pressed():
	do_action(OPEN_AS_BLOCK)


func _on_new_button_pressed():
	set_current_file("")
	schematic.clear()


func do_action(action):
	menu_action = action
	match menu_action:
		OPEN, OPEN_AS_BLOCK:
			$LoadDialog.current_dir = G.settings.last_dir
			$LoadDialog.current_file = G.settings.current_file
			$LoadDialog.popup_centered()
		SAVE:
			if G.settings.current_file == "":
				$SaveDialog.current_dir = G.settings.last_dir
				$SaveDialog.current_file = G.settings.current_file
				$SaveDialog.popup_centered()
			else:
				set_current_file_color(false)
				save_file()


func _on_file_dialog_file_selected(file_path):
	var file_name = file_path.get_file()
	if file_name.length() < 6:
		$WarningPanel.open("An invalid file name was entered!")
		return
	if menu_action != OPEN_AS_BLOCK:
		# When saving, the file associated with current schematic is to be saved
		# The file loaded as a block doesn't need to be remembered
		set_current_file(file_path.get_file())
		G.settings.last_dir = file_path.get_base_dir()
	match menu_action:
		SAVE:
			save_file()
		OPEN:
			schematic.load_circuit(file_path)
		OPEN_AS_BLOCK:
			schematic.add_block(file_path)


func save_file():
	schematic.save_circuit(G.settings.last_dir + "/" + G.settings.current_file)


func set_current_file(file_name, changed = false):
	%CurrentFile.text = file_name
	set_current_file_color(changed)
	G.settings.current_file = file_name


func set_current_file_color(changed = true):
	var color = Color.RED if changed else Color.GREEN
	%CurrentFile.set("theme_override_colors/font_color", color)


func _on_save_dialog_canceled():
	schematic.grab_focus()


func _on_load_dialog_canceled():
	schematic.grab_focus()

#### /FILE CODE ####

#### QUIT CODE ####

func _unhandled_key_input(event: InputEvent):
	if event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				try_to_quit()
			KEY_N:
				if event.ctrl_pressed:
					_on_new_button_pressed()
			KEY_S:
				if event.ctrl_pressed:
					if event.shift_pressed:
						_on_save_as_button_pressed()
					else:
						_on_save_button_pressed()
			KEY_O, KEY_L:
				if event.ctrl_pressed:
					if event.shift_pressed:
						_on_block_button_pressed()
					else:
						_on_load_button_pressed()
			KEY_P:
				if event.ctrl_pressed:
					%AddPartMenu.get_popup().show()
					%AddPartMenu.get_popup().position = \
						%AddPartMenu.position + Vector2(0, %AddPartMenu.size.y)
			KEY_T:
				if event.ctrl_pressed:
					%ToolsButton.get_popup().show()
					%ToolsButton.get_popup().position = \
						%ToolsButton.position + Vector2(0, %ToolsButton.size.y)
			KEY_H:
				if event.ctrl_pressed:
					_on_help_button_pressed()


# Listen for notification of quit request such as after user clicked on x of window
func _notification(what):
	if what == Node.NOTIFICATION_WM_CLOSE_REQUEST:
		try_to_quit()


func try_to_quit():
	# Always save the G.settings
	# The saved var is tracking changes to the circuit
	G.settings.save_data()
	if saved:
		quit()
	else:
		get_viewport().set_input_as_handled()
		$Confirm.popup_centered()


func _on_confirm_confirmed():
	quit()


func quit():
	get_tree().quit()

#### /QUIT CODE ####


func _on_tools_button_pressed():
	pass # Replace with function body.


func _on_settings_button_pressed():
	pass # Replace with function body.


func _on_help_button_pressed():
	pass # Replace with function body.


func _on_learn_button_pressed():
	pass # Replace with function body.


func _on_about_button_pressed():
	pass # Replace with function body.
