extends Control


func _ready():
	pass


func _on_button_pressed():
	var part = Part.new()
	part.title = "Test"
	$VB/Schematic.add_part(part)
