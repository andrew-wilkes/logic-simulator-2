class_name Circuit

extends Resource

@export var name = ""
@export var connections = []
@export var parts = []

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
