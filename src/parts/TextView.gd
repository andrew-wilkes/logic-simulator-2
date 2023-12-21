class_name TextView

extends Part

var panel

func _init():
	category = UTILITY
	order = 0
	data = {
		"file": "",
		"size": [470, 500]
	}


func _ready():
	super()
	panel = $C/Panel
	panel.hide()
	panel.size = Vector2(data.size[0], data.size[1])
	panel.position = get_global_position() + Vector2(120, 0)
	if G.settings.test_dir.is_empty():
		$FileDialog.current_dir = G.settings.last_dir
	else:
		$FileDialog.current_dir = G.settings.test_dir
	if data.file.is_empty():
		$ViewButton.disabled = true
		$FileDialog.popup_centered()
	if file_exists():
		load_file()


func _on_file_dialog_file_selected(path):
	data.file = path
	load_file()
	open_panel()


func _on_view_button_pressed():
	if data.file.is_empty():
		$FileDialog.popup_centered()
	else:
		open_panel()


func load_file():
	var file = FileAccess.open(data.file, FileAccess.READ)
	if file:
		panel.set_title(data.file.get_file())
		$ViewButton.text = data.file.get_file()
		panel.set_text(file.get_as_text())


func open_panel():
	$ViewButton.disabled = true
	panel.show()


func _on_popup_panel_size_changed():
	data.size = [panel.size.x, panel.size.y]


func _on_custom_popup_left_button_pressed():
	$ViewButton.disabled = false
	panel.hide()
	$FileDialog.popup_centered()


func _on_close_button_pressed():
	$ViewButton.disabled = false
	panel.hide()


func _on_file_dialog_canceled():
	$ViewButton.disabled = false


func _on_panel_resized():
	data.size = [panel.size.x, panel.size.y]


func _on_panel_hidden():
	$ViewButton.disabled = false
