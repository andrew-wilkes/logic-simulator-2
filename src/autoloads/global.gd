extends Node

# Autoload with class name G

enum TEST_STATUS { STEPPABLE, PLAYING, DONE }

var settings
var warning
var warnings
var message_panel
var test_runner
var debug_timestamp = 0

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
		var x = binary_to_int(num)
		words.append(x)
	return words


func binary_to_int(num: String, negate = false):
	var x = 0
	if num.is_valid_int():
		for idx in num.length():
			x *= 2
			x += int(num[idx])
	if negate and x > 0x7fff: # negative?
		x = ~x + 1
		x &= 0xffff
		x = -x
	return x


func notify_user(msg):
	warning.open(msg, "", Color.DARK_SLATE_BLUE)


func warn_user(msg):
	warning.open(msg)
	warnings.add_text(msg)


func debug(text = ""):
	var now = Time.get_ticks_msec()
	prints("DEBUG", text, "T +", str(now - debug_timestamp) + "ms")
	debug_timestamp = now


func format_value(x, show_minus, shorten_hex, clamp_value = 0):
	if x < - 0x10000:
		return "HIGH-Z"
	if x < 0:
		if show_minus:
			return str(x)
		else:
			x = 0x10000 + x
	if x < 0x100 and shorten_hex:
		return "0x%02X" % x
	if clamp_value > 0:
		x %= clamp_value
		if clamp_value < 0x10000:
			return "0x%02X" % x
	return "0x%04X" % x


func int2bin(x: int, num_bits) -> String:
	var b = ""
	for n in num_bits:
		b = str(x % 2) + b
		x /= 2
	return b


func get_file_list(dir, ext):
	return Array(Array(ResourceLoader.list_directory(dir)).filter(func(fn): return fn.ends_with(ext)))


func get_scene_file_list(dir_path):
	var files = []
	if DirAccess.dir_exists_absolute(dir_path):
		var gd_files = get_file_list(dir_path, "gd")
		for filename in gd_files:
			var scene_file = get_file_name(dir_path, filename)
			if scene_file != "":
				files.append(scene_file)
	return files


func get_file_name(dir_path, filename):
	var scene_file = filename.replace(".gd", ".tscn")
	if not ResourceLoader.exists(dir_path + scene_file):
		scene_file = filename.replace(".gd", ".scn")
		if not ResourceLoader.exists(dir_path + scene_file):
			scene_file = "" # This should not happen normally
	return scene_file
