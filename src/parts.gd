extends Node

# Autoload for providing access to the available parts

var scenes = {}
var names = []
var scripts = {}

func _init():
	var path = "res://parts/"
	var dir = DirAccess.open(path)
	# The circuit files may be saved as .tscn (text-based) or as .scn (binary).
	var files = Array(dir.get_files()).filter(func(fn): return fn.ends_with("scn"))
	for file_name in files:
		var part_name = file_name.get_file().get_slice('.', 0)
		# Don't add the Block part as a Part option in the menu
		if part_name != "Block":
			names.append(part_name)
		scenes[part_name] = load(path + file_name)
		scripts[part_name] = load(path + file_name.get_file().get_slice('.', 0) + ".gd")


# This is used with circuit blocks where there are no visual elements internally
# So the scene file is not used, but its script is instantiated to an object of part_type
func get_instance(part_name):
	return scripts[part_name].new()
