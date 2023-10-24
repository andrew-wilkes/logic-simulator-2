class_name TextView

extends Part

var panel

func _init():
	category = UTILITY
	order = 0
	data = {
		"file": "",
		"size": Vector2(800, 500)
	}


func _ready():
	super()
	panel = $C/Panel
	panel.hide()
	if G.settings.test_dir.is_empty():
		$FileDialog.current_dir = G.settings.last_dir
	else:
		$FileDialog.current_dir = G.settings.test_dir
	if data.file.is_empty():
		$FileDialog.popup_centered()
	else:
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
		%Title.text = data.file.get_file()
		$ViewButton.text = data.file.get_file()
		%Label.text = file.get_as_text()


func open_panel():
	$ViewButton.disabled = true
	panel.show()


func _on_popup_panel_size_changed():
	data.size = panel.size


func _on_file_button_pressed():
	$ViewButton.disabled = false
	panel.hide()
	$FileDialog.popup_centered()


func _on_close_button_pressed():
	$ViewButton.disabled = false
	panel.hide()


func _on_position_offset_changed():
	panel.position = get_global_position() + Vector2(0, 70)


func _on_file_dialog_canceled():
	$ViewButton.disabled = false
