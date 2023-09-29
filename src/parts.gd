extends Node

# Autoload for providing access to the available parts

var scenes = {}
var names = []

func _init():
	var path = "res://parts/"
	var dir = DirAccess.open(path)
	var files = Array(dir.get_files()).filter(func(fn): return fn.ends_with("scn"))
	for file_name in files:
		var part_name = file_name.get_file().get_slice('.', 0).to_upper()
		if part_name != "BLOCK":
			names.append(part_name)
		scenes[part_name] = load(path + file_name)
	#print(scenes)
