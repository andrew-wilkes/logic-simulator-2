class_name Settings

extends Resource

const FILENAME = "user://settings.res"

@export var last_dir = ""
@export var current_file = ""
@export var indicate_from_levels = true
@export var indicate_to_levels = false
@export var logic_high_color = Color.RED
@export var logic_low_color = Color.BLUE

func save_data():
	var _e = ResourceSaver.save(self, FILENAME)


func load_data():
	if ResourceLoader.exists(FILENAME):
		return ResourceLoader.load(FILENAME)
	else:
		last_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
		return self
