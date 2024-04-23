extends FileDialog

var values: Array
var data: Dictionary

func open_file(ref_of_memory_values, ref_of_data):
	values = ref_of_memory_values
	data = ref_of_data
	if not data.file.is_empty():
		current_dir = data.file.get_base_dir()
		current_file = data.file.get_file()
	elif G.settings.test_dir.is_empty():
		current_dir = G.settings.last_dir
	else:
		current_dir = G.settings.test_dir
	popup_centered()


func _on_file_selected(file_path):
	var rom = get_parent()
	if rom is ROM:
		rom.load_data(file_path)
	data.file = file_path
