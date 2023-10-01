extends Resource

class_name Settings

const FILENAME = "user://settings.res"

@export var last_dir = ""
@export var current_file = ""

func save_data():
	var _e = ResourceSaver.save(self, FILENAME)


func load_data():
	if ResourceLoader.exists(FILENAME):
		return ResourceLoader.load(FILENAME)
	else:
		last_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
		return self
