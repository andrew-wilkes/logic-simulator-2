class_name Circuit

extends Resource

@export var title = ""
@export var connections = []
@export var parts = []
@export var id_num = 0
@export var version = 2.0

# Settings
@export var scroll_offset = Vector2.ZERO
@export var snap_distance = 20
@export var use_snap = true
@export var zoom = 1.0
@export var minimap_enabled = true

var saved_to = ""

func load_data(file_name):
	if ResourceLoader.exists(file_name):
		return ResourceLoader.load(file_name)
	else:
		return ERR_FILE_NOT_FOUND


func save_data(file_name, check_if_exists = false):
	var error = OK
	if check_if_exists and saved_to != file_name and ResourceLoader.exists(file_name):
		error = ERR_ALREADY_EXISTS
	else:
		error = ResourceSaver.save(self, file_name)
		if error == OK:
			saved_to = file_name
	return error


func get_next_id():
	id_num += 1
	return str(id_num)
