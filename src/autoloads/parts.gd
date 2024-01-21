extends Node

# Autoload for providing access to the available parts.

var scenes = {}
var names = []
var scripts = {}

func _init():
	add_parts("res://parts/")
	if OS.is_debug_build():
		var path = "res://mods/"
		if DirAccess.dir_exists_absolute(path):
			add_parts(path)
		else:
			print(path + " doesn't exist.")
	add_mods()


func add_parts(path):
	var dir = DirAccess.open(path)
	var files = get_files(dir)
	for file_name in files:
		var part_name = file_name.get_file().get_slice('.', 0)
		# Don't add the Block part as a Part option in the menu.
		if part_name not in ["Block"]:
			names.append(part_name)
		scenes[part_name] = ResourceLoader.load(path + file_name.replace(".gd", ".tscn"))
		scripts[part_name] = ResourceLoader.load(path + file_name)


func get_files(dir):
	return Array(dir.get_files()).filter(func(fn): return fn.ends_with("gd"))


func add_mods():
	var mod_files = ModImporter.get_file_list()
	for file in mod_files:
		var scene = ModImporter.get_part_scene(file)
		if scene:
			var ob = scene.instantiate()
			if ob is Part:
				scenes[ob.name] = scene
				scripts[ob.name] = ob.script
			ob.free()


# This is used with circuit blocks where there are no visual elements internally.
# So the scene file is not used, but its script is instantiated to an object of part_type.
func get_instance(part_name):
	return scripts[part_name].new()
