class_name Tool

static func get_tool_scenes():
	var scenes = []
	var path = "res://tools/"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.get_extension().ends_with("scn"):
					scenes.append(path + file_name)
			file_name = dir.get_next()
	return scenes
