extends Node

# Autoload for providing access to the available parts.

var scenes = {}
var names = []
var scripts = {}

func _init():
	var path = "res://parts/"
	var dir = DirAccess.open(path)
	var files = Array(dir.get_files()).filter(func(fn): return fn.ends_with("gd"))
	for file_name in files:
		var part_name = file_name.get_file().get_slice('.', 0)
		# Don't add the Block part as a Part option in the menu.
		if part_name not in ["Block"]:
			names.append(part_name)
		scenes[part_name] = ResourceLoader.load(path + file_name.replace(".gd", ".tscn"))
		scripts[part_name] = ResourceLoader.load(path + file_name)


# This is used with circuit blocks where there are no visual elements internally.
# So the scene file is not used, but its script is instantiated to an object of part_type.
func get_instance(part_name):
	return scripts[part_name].new()
