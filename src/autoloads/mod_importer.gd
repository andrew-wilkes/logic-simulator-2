extends Node

# This class is used to import extra parts and tools from mod files.
# The scene file is exported as a .pck file
# Filename format: lsx-name_of_scene.pck
# e.g. lsx-8080_cpu.pck would contain 8080_cpu.tscn
# These files must be located in the same folder as the executeable.
# The supported (scanned paths) are: res://part res://mod and res://tool
# res://mod and res://tool are not included in the code repository
# res://mod is used for new parts that extend the Part class
# res://tool is used for Tools that are added to the Tool menu and are
# automatically contained in a PopupPanel.

var mod_scenes = []

func load_scenes():
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
					if ProjectSettings.load_resource_pack(path + file_name):
						if OS.is_debug_build():
							prints("loaded", file_name)
					var mod_scene = ResourceLoader.load("res://mod.tres")
					if mod_scene:
						mod_scenes.append_array(mod_scene.scenes)
			file_name = dir.get_next()


func get_mod_files(path):
	var files = []
	for scene in mod_scenes:
		if scene.resource_path.begins_with(path):
			files.append(scene.resource_path.get_file())
	return files
