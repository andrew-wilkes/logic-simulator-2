class_name Circuit

extends RefCounted

var data = {
	title = "",
	connections = [],
	parts = [],
	id_num = 0, # This is appended to new part names and then incremented
	version = 2.0,

	# Graph settings
	scroll_offset = [0, 0],
	snapping_distance = 20,
	snapping_enabled = true,
	zoom = 1.0,
	minimap_enabled = true,
}

func load_data(file_name):
	if FileAccess.file_exists(file_name):
		var file = FileAccess.open(file_name, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			data = JSON.parse_string(json_text)
			if data:
				# Convert color values
				for part in data.parts:
					convert_rgba_strings_to_colors(part.data)
				return OK
			# data is null if parse failed
		else:
			return FileAccess.get_open_error()
	else:
		return ERR_FILE_NOT_FOUND


func save_data(file_name):
	var save_file = FileAccess.open(file_name, FileAccess.WRITE)
	if save_file:
		for part in data.parts:
			convert_colors_to_rgba_strings(part.data)
		var json_string = JSON.stringify(data, "\t")
		save_file.store_line(json_string)


func get_next_id():
	data.id_num += 1
	return str(data.id_num)


func convert_colors_to_rgba_strings(d: Dictionary):
	for key in d.keys():
		if typeof(d[key]) == TYPE_COLOR:
			d[key] = d[key].to_html()


func convert_rgba_strings_to_colors(d: Dictionary):
	for key in d.keys():
		if key.ends_with("color"):
			d[key] = Color(d[key])
