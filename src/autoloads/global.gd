extends Node

# Autoload with class name G

var settings
var warning
var message_panel

func _init():
	settings = Settings.new()
	settings = settings.load_data()
	settings.current_file = ""


func find_file(path, fn):
	var result = { "error": true, "path": "" }
	return dir_search(path, fn, result, 1)

const MAX_DIR_SEARCH_DEPTH = 3

func dir_search(path, fn, result, depth):
	if depth > MAX_DIR_SEARCH_DEPTH:
		return result
	var dirs = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
	else:
		return result
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			dirs.append(file_name)
		else:
			if file_name == fn:
				result.path = path
				result.error = false
				return result
		file_name = dir.get_next()
	for sub_dir in dirs:
		result = dir_search(path + "/" + sub_dir, fn, result, depth + 1)
		if not result.error:
			break
	return result


func hack_to_array_of_int(hack: String):
	var words = []
	var lines = hack.replace("\r", "\n").split("\n", false)
	for num in lines:
		var x = 0
		if num.is_valid_int():
			for idx in num.length():
				x *= 2
				x += int(num[idx])
		words.append(x)
	return words


func notify_user(msg):
	warning.open(msg, "", Color.DARK_SLATE_BLUE)


func warn_user(msg):
	warning.open(msg)
