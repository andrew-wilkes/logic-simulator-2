extends Node

# Autoload for providing access to the available parts.

var scenes = {}
var names = []
var scripts = {}

func _ready():
	var parts_path = "res://parts/"
	var dir = DirAccess.open(parts_path)
	var files = G.get_file_list(dir, "scn")
	add_parts(parts_path, files)
	parts_path = "res://mods/"
	if OS.is_debug_build() and DirAccess.dir_exists_absolute(parts_path):
		files = []
		dir = DirAccess.open(parts_path)
		files = G.get_file_list(dir, "scn")
		add_parts(parts_path, files)


func load_mods():
	var parts_path = "res://parts/"
	var files = ModImporter.get_mod_files(parts_path)
	add_parts(parts_path, files)
	parts_path = "res://mods/"
	files = ModImporter.get_mod_files(parts_path)
	add_parts(parts_path, files)


func add_parts(path, files):
	for file_name in files:
		var part_name = file_name.get_file().get_slice('.', 0)
		# Don't add the Block part as a Part option in the menu.
		if part_name not in ["Block"]:
			if not names.has(part_name):
				names.append(part_name)
		scenes[part_name] = ResourceLoader.load(path + file_name)
		scripts[part_name] = ResourceLoader.load(path + part_name + ".gd")

# This is used with circuit blocks where there are no visual elements internally.
# So the scene file is not used, but its script is instantiated to an object of part_type.
func get_instance(part_name):
	return scripts[part_name].new()
