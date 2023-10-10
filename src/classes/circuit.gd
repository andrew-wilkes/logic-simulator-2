class_name Circuit

extends Object

var data = {
	title = "",
	connections = [],
	parts = [],
	id_num = 0, # This is appended to new part names and then incremented
	version = 2.0,

	# Graph settings
	scroll_offset = [0, 0],
	snap_distance = 20,
	use_snap = true,
	zoom = 1.0,
	minimap_enabled = true,

	saved_to = "",
}

func load_data(file_name):
	if FileAccess.file_exists(file_name):
		var file = FileAccess.open(file_name, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			data = JSON.parse_string(json_text)
			if data:
				return OK
			# data is null if parse failed
		else:
			return FileAccess.get_open_error()
	else:
		return ERR_FILE_NOT_FOUND


func save_data(file_name, check_if_exists = false):
	var error = OK
	if check_if_exists and data.saved_to != file_name and FileAccess.file_exists(file_name):
		error = ERR_ALREADY_EXISTS
	else:
		var save_file = FileAccess.open(file_name, FileAccess.WRITE)
		if save_file:
			var json_string = JSON.stringify(data, "\t")
			save_file.store_line(json_string)
	return error


func get_next_id():
	data.id_num += 1
	return str(data.id_num)
