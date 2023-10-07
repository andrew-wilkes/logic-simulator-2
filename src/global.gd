extends Node

# Autoload with class name G

var settings

func _init():
	settings = Settings.new()
	settings = settings.load_data()
	settings.current_file = ""
