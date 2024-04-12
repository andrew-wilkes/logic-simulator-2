extends Node

# Autoload for providing access to the available parts.

const parts_paths = ["res://parts/", "res://mods/"]

var scenes = {}
var names = []
var scripts = {}

func _ready():
	for parts_path in parts_paths:
		var files = G.get_scene_file_list(parts_path, true)
		add_parts(parts_path, files)


func load_mods():
	for parts_path in parts_paths:
		var files = ModImporter.get_mod_files(parts_path)
		add_parts(parts_path, files)
		pass


func add_parts(path, files):
	for file_name in files:
		var part_name = file_name.get_file().get_slice('.', 0)
		# Don't add the Block part as a Part option in the menu.
		if part_name not in ["Block"]:
			# A mod may override an existing part
			if not names.has(part_name):
				names.append(part_name)
		scenes[part_name] = ResourceLoader.load(path + file_name)
		scripts[part_name] = ResourceLoader.load(path + part_name + ".gd")

# This is used with circuit blocks where there are no visual elements internally.
# So the scene file is not used, but its script is instantiated to an object of part_type.
func get_instance(part_name):
	return scripts[part_name].new()
