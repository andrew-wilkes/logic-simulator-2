extends Control

enum { NO_ACTION, NEW, OPEN, OPEN_AS_BLOCK, SAVE, SAVE_AS, QUIT, ABOUT }

var saved = false
var menu_action = NO_ACTION
var settings

func _ready():
	settings = Settings.new()
	settings = settings.load_data()
	var add_part_menu: PopupMenu = $VB/HB/AddPartMenu.get_popup()
	for part_name in Parts.names:
		add_part_menu.add_item(part_name)
	add_part_menu.index_pressed.connect(part_to_add)
	$VB/Schematic.connect("warning", $WarningPanel.open)


func part_to_add(part_index):
	var part_name = Parts.names[part_index]
	$VB/Schematic.add_part_by_name(part_name)


func _on_save_button_pressed():
	do_action(SAVE)


func _on_load_button_pressed():
	do_action(OPEN)


func _on_block_button_pressed():
	do_action(OPEN_AS_BLOCK)


func do_action(action):
	menu_action = action
	match menu_action:
		OPEN, OPEN_AS_BLOCK:
			$FileDialog.title = "Load Circuit"
			$FileDialog.current_dir = settings.last_dir
			$FileDialog.current_file = settings.current_file
			$FileDialog.mode = FileDialog.FILE_MODE_OPEN_FILE
			$FileDialog.popup_centered()
		SAVE:
			if settings.current_file == "":
				$FileDialog.title = "Save Circuit"
				$FileDialog.current_dir = settings.last_dir
				$FileDialog.current_file = ""
				$FileDialog.mode = FileDialog.FILE_MODE_SAVE_FILE
				$FileDialog.popup_centered()
			else:
				save_file()


func _unhandled_key_input(event):
	if event.keycode == KEY_ESCAPE:
		try_to_quit()


# Listen for notification of quit request such as after user clicked on x of window
func _notification(what):
	if what == Node.NOTIFICATION_WM_CLOSE_REQUEST:
		try_to_quit()


func try_to_quit():
	settings.save_data()
	if saved:
		quit()
	else:
		get_viewport().set_input_as_handled()
		$Confirm.popup_centered()


func _on_confirm_confirmed():
	quit()


func quit():
	get_tree().quit()


func _on_file_dialog_file_selected(file_path):
	var file_name = file_path.get_file()
	if file_name.length() < 6:
		$WarningPanel.open("An invalid file name was entered!")
		return
	if menu_action != OPEN_AS_BLOCK:
		settings.current_file = file_path.get_file()
		settings.last_dir = file_path.get_base_dir()
	match menu_action:
		SAVE:
			save_file()
		OPEN:
			$VB/Schematic.load_circuit(file_path)
		OPEN_AS_BLOCK:
			$VB/Schematic.add_block(file_path)


func save_file():
	$VB/Schematic.save_circuit(settings.last_dir + "/" + settings.current_file)
