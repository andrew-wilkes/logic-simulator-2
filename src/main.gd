extends Control

enum { NO_ACTION, NEW, OPEN, OPEN_AS_BLOCK, SAVE, SAVE_AS, QUIT, ABOUT }

var saved = false
var menu_action = NO_ACTION
var schematic
var tools = []

func _ready():
	schematic = $VB/Schematic
	%ToolsButton.get_popup().add_item("Number parts")
	%ToolsButton.get_popup().add_item("Test circuit")
	%ToolsButton.get_popup().add_item("Load HDL circuit")
	%ToolsButton.get_popup().add_item("List Warnings")
	%ToolsButton.get_popup().index_pressed.connect(tool_action)
	schematic.changed.connect(set_current_file_color)
	schematic.title_changed.connect(%Title.set_text)
	%Title.text_changed.connect(schematic.set_circuit_title)
	$PartListPanel/PartList.part_selected.connect(schematic.add_part_by_name)
	$PartListPanel/PartList.block_selected.connect(schematic.add_block)
	$SettingsPanel/SettingsPanel.level_indication_changed.connect(schematic.set_all_connection_colors)
	$SettingsPanel/SettingsPanel.low_color_changed.connect(schematic.set_low_color)
	$SettingsPanel/SettingsPanel.high_color_changed.connect(schematic.set_high_color)
	$AboutPanel/AboutTabs/About/Text.meta_clicked.connect(_on_about_text_meta_clicked)
	$HelpPanel/HelpTabs/Nand2Tetris/RichText.meta_clicked.connect(_on_nand_text_meta_clicked)
	%Title.text_submitted.connect(unfocus)
	G.warning = $WarningPanel
	G.warnings = $WarningsPanel/Warnings
	var tool_path = "res://tools/"
	var files = G.get_scene_file_list(tool_path)
	add_tools(tool_path, files)
	ModImporter.load_scenes()
	Parts.load_mods()
	$PartListPanel/PartList.build()
	files = ModImporter.get_mod_files(tool_path)
	add_tools(tool_path, files)


func tool_action(idx):
	match idx:
		0:
			schematic.number_parts()
		1:
			# Test circuit
			if G.settings.test_dir.is_empty():
				G.warning.open("Test file directory has not been set in settings.")
			else:
				schematic.test_circuit()
		2:
			if G.settings.test_dir.is_empty():
				$LoadHDL.current_dir = G.settings.last_dir
			else:
				$LoadHDL.current_dir = G.settings.test_dir
			$LoadHDL.popup_centered()
		3:
			$WarningsPanel.popup_centered()
		_:
			tools[idx - 4].popup_centered()


func add_tools(tool_path, files):
	for file_name in files:
		var tool = ResourceLoader.load(tool_path + file_name).instantiate()
		%ToolsButton.get_popup().add_item(tool.title)
		var tool_panel = PopupPanel.new()
		tool_panel.borderless = false
		tool_panel.unresizable = false
		var title = tool.get("title")
		if title:
			tool_panel.title = title
		else:
			tool_panel.title = "Untitled Tool"
		add_child(tool_panel)
		tool_panel.add_child(tool)
		tools.append(tool_panel)


#region File Code
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
	G.warnings.clear()


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
		G.warning.open("An invalid file name was entered!")
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
			G.warnings.clear()
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
	unfocus()


func _on_load_dialog_canceled():
	unfocus()
#endregion


#region Hot Key Code
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
			KEY_P, KEY_SPACE:
				if event.ctrl_pressed:
					_on_add_part_button_pressed()
			KEY_T:
				if event.ctrl_pressed:
					%ToolsButton.get_popup().show()
					%ToolsButton.get_popup().position = \
						%ToolsButton.position + Vector2(0, %ToolsButton.size.y)
			KEY_H:
				if event.ctrl_pressed:
					_on_help_button_pressed()
			KEY_AT:
				if event.ctrl_pressed:
					# Test something
					G.notify_user("You found an Easter egg :-)")


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
		# This doesn't prevent window from closing
		get_viewport().set_input_as_handled()
		$Confirm.popup_centered()


func _on_confirm_confirmed():
	quit()


func quit():
	get_tree().quit()
#endregion


func _on_tools_button_pressed():
	unfocus()


func _on_settings_button_pressed():
	$SettingsPanel.popup_centered()
	unfocus()


func _on_help_button_pressed():
	$HelpPanel.popup_centered()
	unfocus()


func _on_learn_button_pressed():
	$LearnPanel.popup_centered()
	unfocus()


func _on_about_button_pressed():
	$AboutPanel.popup_centered()
	unfocus()


func _on_add_part_button_pressed():
	$PartListPanel/PartList.update_block_list()
	$PartListPanel.popup_centered()
	$PartListPanel.position.y += 15


# This removes the highlighting around menu buttons
func unfocus(_arg = null):
	schematic.grab_focus()


func _on_about_text_meta_clicked(meta):
	open_meta_target(str(meta))


func _on_nand_text_meta_clicked(meta):
	open_meta_target(str(meta))


func open_meta_target(target):
	var endpoints = {
		"nand": "https://www.nand2tetris.org/software",
		"coffee": "https://buymeacoffee.com/gdscriptdude"
	}
	var _e = OS.shell_open(endpoints[target])


func _on_load_hdl_file_selected(path):
	set_current_file("")
	schematic.create_circuit_from_hdl(path)


func _on_clear_levels_button_pressed():
	schematic.reset_pins()
	schematic.set_all_connection_colors()
	unfocus()
