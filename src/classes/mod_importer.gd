class_name ModImporter

# This class is used to import extra parts from mod files.
# The scene file of a part is exported as a .pck file
# Filename format: lsx-name_of_scene.pck
# e.g. lsx-8080_cpu.pck would contain 8080_cpu.tscn
# These files must be located in the same folder as the executeable.
# The scene must extend the Part class and be located in: res://parts/

static func get_file_list():
	var files = []
	var path = OS.get_executable_path().get_base_dir() + "/"
	if OS.is_debug_build():
		path = "res://"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.get_extension() == "pck" and file_name.begins_with("lsx-"):
					files.append(path + file_name)
			file_name = dir.get_next()
	return files


static func get_part_scene(file):
	var success = ProjectSettings.load_resource_pack(file)
	if success:
		var scene = file.get_file().replace(".pck", ".tscn").replace("lsx-", "")
		return load("res://parts/" + scene)
